import Flutter
import UIKit
import UniformTypeIdentifiers

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate, UIDocumentPickerDelegate {
  private static let storageChannel = "ua.ovdphub/mobile_external_storage"
  private static let maxWorkspaceTextBytes = 20 * 1024 * 1024
  private static let bookmarkPrefix = "ovdp.external.folder."
  private static let labelPrefix = "ovdp.external.folder.label."

  private enum PendingPicker {
    case exportBackup(result: FlutterResult, temporaryURL: URL)
    case importBackup(result: FlutterResult, maxBytes: Int)
    case workspaceFolder(result: FlutterResult)
  }

  private struct StorageError: Error {
    let code: String
    let message: String
  }

  private var pendingPicker: PendingPicker?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    let channel = FlutterMethodChannel(
      name: Self.storageChannel,
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    channel.setMethodCallHandler { [weak self] call, result in
      self?.handleStorageCall(call, result: result)
    }
  }

  private func handleStorageCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "exportEncryptedBackup":
      startBackupExport(call, result: result)
    case "importEncryptedBackup":
      startBackupImport(call, result: result)
    case "chooseWorkspaceFolder":
      startWorkspaceFolderPicker(result: result)
    case "workspaceFolderAvailable":
      runStorage(result: result) {
        let grantId = try self.requireGrantId(call)
        return self.workspaceFolderAvailable(grantId)
      }
    case "readWorkspaceText":
      runStorage(result: result) {
        let grantId = try self.requireGrantId(call)
        let path = try self.requireRelativePath(self.argument(call, "relativePath", as: String.self))
        let maxBytes = try self.requirePositiveLimit(self.argument(call, "maxBytes", as: Int.self))
        return try self.readWorkspaceText(grantId: grantId, path: path, maxBytes: maxBytes)
      }
    case "writeWorkspaceText":
      runStorage(result: result) {
        let grantId = try self.requireGrantId(call)
        let path = try self.requireRelativePath(self.argument(call, "relativePath", as: String.self))
        guard let content: String = self.argument(call, "content", as: String.self) else {
          throw StorageError(code: "workspace.external_write_failed", message: "Missing content")
        }
        let data = Data(content.utf8)
        guard data.count <= Self.maxWorkspaceTextBytes else {
          throw StorageError(code: "workspace.file_too_large", message: "Workspace file is too large")
        }
        let replace: Bool = self.argument(call, "replace", as: Bool.self) ?? false
        try self.writeWorkspaceText(grantId: grantId, path: path, data: data, replace: replace)
        return nil
      }
    case "listWorkspaceFiles":
      runStorage(result: result) {
        let grantId = try self.requireGrantId(call)
        let raw: String = self.argument(call, "relativeDirectory", as: String.self) ?? ""
        let path = raw.isEmpty ? [] : try self.requireRelativePath(raw)
        return try self.listWorkspaceFiles(grantId: grantId, directory: path)
      }
    case "deleteWorkspaceFile":
      runStorage(result: result) {
        let grantId = try self.requireGrantId(call)
        let path = try self.requireRelativePath(self.argument(call, "relativePath", as: String.self))
        try self.deleteWorkspaceFile(grantId: grantId, path: path)
        return nil
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func startBackupExport(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard ensureNoPendingPicker(result) else { return }
    guard let typed: FlutterStandardTypedData = argument(call, "bytes", as: FlutterStandardTypedData.self),
          !typed.data.isEmpty else {
      result(FlutterError(code: "vault.invalid_file", message: "Backup bytes are empty", details: nil))
      return
    }
    let name = sanitizeSuggestedName(argument(call, "suggestedName", as: String.self))
    do {
      let folder = FileManager.default.temporaryDirectory
        .appendingPathComponent("OVDP-Hub-portable", isDirectory: true)
      try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
      let temporary = folder.appendingPathComponent("\(UUID().uuidString)-\(name)", isDirectory: false)
      try typed.data.write(to: temporary, options: .atomic)
      pendingPicker = .exportBackup(result: result, temporaryURL: temporary)
      let picker = UIDocumentPickerViewController(forExporting: [temporary], asCopy: true)
      picker.delegate = self
      presentPicker(picker, result: result)
    } catch {
      pendingPicker = nil
      sendError(result, error, fallback: "portfolio.backup_export_failed")
    }
  }

  private func startBackupImport(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard ensureNoPendingPicker(result) else { return }
    do {
      let maxBytes = try requirePositiveLimit(argument(call, "maxBytes", as: Int.self))
      pendingPicker = .importBackup(result: result, maxBytes: maxBytes)
      let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.json, .data], asCopy: false)
      picker.allowsMultipleSelection = false
      picker.delegate = self
      presentPicker(picker, result: result)
    } catch {
      pendingPicker = nil
      sendError(result, error, fallback: "portfolio.backup_import_failed")
    }
  }

  private func startWorkspaceFolderPicker(result: @escaping FlutterResult) {
    guard ensureNoPendingPicker(result) else { return }
    pendingPicker = .workspaceFolder(result: result)
    let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.folder], asCopy: false)
    picker.allowsMultipleSelection = false
    picker.delegate = self
    presentPicker(picker, result: result)
  }

  private func presentPicker(_ picker: UIDocumentPickerViewController, result: @escaping FlutterResult) {
    guard let presenter = activePresenter() else {
      pendingPicker = nil
      result(FlutterError(code: "workspace.external_pick_failed", message: "No active window", details: nil))
      return
    }
    presenter.present(picker, animated: true)
  }

  private func activePresenter() -> UIViewController? {
    let windows = UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .filter { $0.activationState == .foregroundActive || $0.activationState == .foregroundInactive }
      .flatMap { $0.windows }
    var controller = windows.first(where: { $0.isKeyWindow })?.rootViewController
      ?? windows.first?.rootViewController
    while let presented = controller?.presentedViewController {
      controller = presented
    }
    return controller
  }

  private func ensureNoPendingPicker(_ result: @escaping FlutterResult) -> Bool {
    guard pendingPicker == nil else {
      result(FlutterError(code: "workspace.picker_busy", message: "Another system picker is already open", details: nil))
      return false
    }
    return true
  }

  func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
    guard let pending = pendingPicker else { return }
    pendingPicker = nil
    guard let url = urls.first else {
      completeCancelled(pending)
      return
    }

    switch pending {
    case let .exportBackup(result, temporaryURL):
      try? FileManager.default.removeItem(at: temporaryURL)
      result(url.lastPathComponent.isEmpty ? "OVDP Hub backup" : url.lastPathComponent)
    case let .importBackup(result, maxBytes):
      runStorage(result: result) {
        let data = try self.withSecurityScope(url, code: "portfolio.backup_import_failed") { scopedURL in
          try self.coordinateRead(scopedURL) { coordinatedURL in
            try self.readLimitedData(coordinatedURL, maxBytes: maxBytes)
          }
        }
        return FlutterStandardTypedData(bytes: data)
      }
    case let .workspaceFolder(result):
      runStorage(result: result) {
        let values = try url.resourceValues(forKeys: [.isDirectoryKey, .nameKey])
        guard values.isDirectory == true else {
          throw StorageError(code: "workspace.external_pick_failed", message: "Selected item is not a folder")
        }
        let started = url.startAccessingSecurityScopedResource()
        guard started else {
          throw StorageError(code: "workspace.external_permission_lost", message: "Unable to access selected folder")
        }
        defer { url.stopAccessingSecurityScopedResource() }
        let bookmark = try url.bookmarkData(
          options: [.withSecurityScope],
          includingResourceValuesForKeys: [.isDirectoryKey, .nameKey],
          relativeTo: nil
        )
        let grantId = UUID().uuidString
        let label = values.name?.isEmpty == false ? values.name! : (url.lastPathComponent.isEmpty ? "External workspace" : url.lastPathComponent)
        UserDefaults.standard.set(bookmark, forKey: Self.bookmarkPrefix + grantId)
        UserDefaults.standard.set(label, forKey: Self.labelPrefix + grantId)
        return ["id": grantId, "label": label]
      }
    }
  }

  func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
    guard let pending = pendingPicker else { return }
    pendingPicker = nil
    completeCancelled(pending)
  }

  private func completeCancelled(_ pending: PendingPicker) {
    switch pending {
    case let .exportBackup(result, temporaryURL):
      try? FileManager.default.removeItem(at: temporaryURL)
      result(nil)
    case let .importBackup(result, _):
      result(nil)
    case let .workspaceFolder(result):
      result(nil)
    }
  }

  private func workspaceFolderAvailable(_ grantId: String) -> Bool {
    do {
      return try withWorkspaceURL(grantId) { root in
        try coordinateRead(root) { coordinatedRoot in
          let values = try coordinatedRoot.resourceValues(forKeys: [.isDirectoryKey])
          return values.isDirectory == true
        }
      }
    } catch {
      return false
    }
  }

  private func readWorkspaceText(grantId: String, path: [String], maxBytes: Int) throws -> String? {
    try withWorkspaceURL(grantId) { root in
      try coordinateRead(root) { coordinatedRoot in
        let target = try self.resolveWorkspaceURL(root: coordinatedRoot, path: path, createParents: false)
        guard FileManager.default.fileExists(atPath: target.path) else { return nil }
        try self.rejectDirectoryOrSymlink(target, operation: "workspace.external_read_failed")
        let data = try self.readLimitedData(target, maxBytes: maxBytes)
        guard let text = String(data: data, encoding: .utf8) else {
          throw StorageError(code: "workspace.external_read_failed", message: "Workspace file is not valid UTF-8")
        }
        return text
      }
    }
  }

  private func writeWorkspaceText(grantId: String, path: [String], data: Data, replace: Bool) throws {
    try withWorkspaceURL(grantId) { root in
      try coordinateWrite(root) { coordinatedRoot in
        let target = try self.resolveWorkspaceURL(root: coordinatedRoot, path: path, createParents: true)
        let fm = FileManager.default
        var isDirectory: ObjCBool = false
        if fm.fileExists(atPath: target.path, isDirectory: &isDirectory) {
          if isDirectory.boolValue {
            throw StorageError(code: "workspace.external_write_failed", message: "Destination is a directory")
          }
          try self.rejectSymlink(target, operation: "workspace.external_write_failed")
          if !replace {
            throw StorageError(code: "workspace.external_file_exists", message: "Destination already exists")
          }
        }
        let parent = target.deletingLastPathComponent()
        let pending = parent.appendingPathComponent(".ovdp-\(UUID().uuidString).pending", isDirectory: false)
        do {
          try data.write(to: pending, options: .atomic)
          if fm.fileExists(atPath: target.path) {
            _ = try fm.replaceItemAt(target, withItemAt: pending, backupItemName: nil, options: [])
          } else {
            try fm.moveItem(at: pending, to: target)
          }
        } catch {
          try? fm.removeItem(at: pending)
          throw error
        }
      }
    }
  }

  private func listWorkspaceFiles(grantId: String, directory: [String]) throws -> [String] {
    try withWorkspaceURL(grantId) { root in
      try coordinateRead(root) { coordinatedRoot in
        let folder = try self.resolveWorkspaceURL(root: coordinatedRoot, path: directory, createParents: false)
        let values = try folder.resourceValues(forKeys: [.isDirectoryKey, .isSymbolicLinkKey])
        guard values.isDirectory == true, values.isSymbolicLink != true else {
          throw StorageError(code: "workspace.external_list_failed", message: "Workspace directory is unavailable")
        }
        let urls = try FileManager.default.contentsOfDirectory(
          at: folder,
          includingPropertiesForKeys: [.isDirectoryKey, .isSymbolicLinkKey],
          options: [.skipsHiddenFiles]
        )
        return try urls.compactMap { url in
          let entry = try url.resourceValues(forKeys: [.isDirectoryKey, .isSymbolicLinkKey])
          if entry.isDirectory == true || entry.isSymbolicLink == true { return nil }
          return url.lastPathComponent
        }.sorted()
      }
    }
  }

  private func deleteWorkspaceFile(grantId: String, path: [String]) throws {
    try withWorkspaceURL(grantId) { root in
      try coordinateWrite(root) { coordinatedRoot in
        let target = try self.resolveWorkspaceURL(root: coordinatedRoot, path: path, createParents: false)
        guard FileManager.default.fileExists(atPath: target.path) else { return }
        try self.rejectDirectoryOrSymlink(target, operation: "workspace.external_delete_failed")
        try FileManager.default.removeItem(at: target)
      }
    }
  }

  private func withWorkspaceURL<T>(_ grantId: String, operation: (URL) throws -> T) throws -> T {
    guard let bookmark = UserDefaults.standard.data(forKey: Self.bookmarkPrefix + grantId) else {
      throw StorageError(code: "workspace.external_permission_lost", message: "Unknown external folder grant")
    }
    var stale = false
    let url: URL
    do {
      url = try URL(
        resolvingBookmarkData: bookmark,
        options: [.withSecurityScope, .withoutUI],
        relativeTo: nil,
        bookmarkDataIsStale: &stale
      )
    } catch {
      throw StorageError(code: "workspace.external_permission_lost", message: "Unable to resolve external folder bookmark")
    }
    let started = url.startAccessingSecurityScopedResource()
    guard started else {
      throw StorageError(code: "workspace.external_permission_lost", message: "External folder permission is unavailable")
    }
    defer { url.stopAccessingSecurityScopedResource() }

    if stale {
      do {
        let refreshed = try url.bookmarkData(
          options: [.withSecurityScope],
          includingResourceValuesForKeys: [.isDirectoryKey, .nameKey],
          relativeTo: nil
        )
        UserDefaults.standard.set(refreshed, forKey: Self.bookmarkPrefix + grantId)
      } catch {
        throw StorageError(code: "workspace.external_permission_lost", message: "External folder bookmark is stale")
      }
    }
    return try operation(url)
  }

  private func withSecurityScope<T>(_ url: URL, code: String, operation: (URL) throws -> T) throws -> T {
    let started = url.startAccessingSecurityScopedResource()
    guard started else {
      throw StorageError(code: code, message: "Unable to access selected item")
    }
    defer { url.stopAccessingSecurityScopedResource() }
    return try operation(url)
  }

  private func coordinateRead<T>(_ url: URL, operation: (URL) throws -> T) throws -> T {
    let coordinator = NSFileCoordinator()
    var coordinatorError: NSError?
    var outcome: Result<T, Error>?
    coordinator.coordinate(readingItemAt: url, options: [], error: &coordinatorError) { coordinatedURL in
      outcome = Result { try operation(coordinatedURL) }
    }
    if let coordinatorError { throw coordinatorError }
    guard let outcome else {
      throw StorageError(code: "workspace.external_read_failed", message: "File coordination failed")
    }
    return try outcome.get()
  }

  private func coordinateWrite<T>(_ url: URL, operation: (URL) throws -> T) throws -> T {
    let coordinator = NSFileCoordinator()
    var coordinatorError: NSError?
    var outcome: Result<T, Error>?
    coordinator.coordinate(writingItemAt: url, options: .forMerging, error: &coordinatorError) { coordinatedURL in
      outcome = Result { try operation(coordinatedURL) }
    }
    if let coordinatorError { throw coordinatorError }
    guard let outcome else {
      throw StorageError(code: "workspace.external_write_failed", message: "File coordination failed")
    }
    return try outcome.get()
  }

  private func resolveWorkspaceURL(root: URL, path: [String], createParents: Bool) throws -> URL {
    guard !path.isEmpty else { return root }
    var current = root
    for (index, component) in path.enumerated() {
      let next = current.appendingPathComponent(component, isDirectory: index < path.count - 1)
      if index < path.count - 1 {
        var isDirectory: ObjCBool = false
        if FileManager.default.fileExists(atPath: next.path, isDirectory: &isDirectory) {
          guard isDirectory.boolValue else {
            throw StorageError(code: "workspace.external_write_failed", message: "Parent path is not a directory")
          }
          try rejectSymlink(next, operation: "workspace.external_permission_lost")
        } else if createParents {
          try FileManager.default.createDirectory(at: next, withIntermediateDirectories: false)
        } else {
          throw StorageError(code: "workspace.external_read_failed", message: "Workspace directory is missing")
        }
      }
      current = next
    }
    return current
  }

  private func rejectDirectoryOrSymlink(_ url: URL, operation: String) throws {
    let values = try url.resourceValues(forKeys: [.isDirectoryKey, .isSymbolicLinkKey])
    if values.isDirectory == true || values.isSymbolicLink == true {
      throw StorageError(code: operation, message: "Refusing directory or symbolic-link access")
    }
  }

  private func rejectSymlink(_ url: URL, operation: String) throws {
    let values = try url.resourceValues(forKeys: [.isSymbolicLinkKey])
    if values.isSymbolicLink == true {
      throw StorageError(code: operation, message: "Symbolic links are not allowed")
    }
  }

  private func readLimitedData(_ url: URL, maxBytes: Int) throws -> Data {
    let handle = try FileHandle(forReadingFrom: url)
    defer { try? handle.close() }
    var data = Data()
    while data.count <= maxBytes {
      let remaining = maxBytes + 1 - data.count
      guard remaining > 0 else { break }
      let chunk = try handle.read(upToCount: min(64 * 1024, remaining)) ?? Data()
      if chunk.isEmpty { break }
      data.append(chunk)
      if data.count > maxBytes {
        throw StorageError(code: "vault.file_too_large", message: "Selected file is too large")
      }
    }
    return data
  }

  private func requireGrantId(_ call: FlutterMethodCall) throws -> String {
    guard let id: String = argument(call, "grantId", as: String.self),
          id.count >= 8, id.count <= 80,
          id.unicodeScalars.allSatisfy({ CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-")).contains($0) }) else {
      throw StorageError(code: "workspace.external_grant_invalid", message: "Invalid grant id")
    }
    return id
  }

  private func requirePositiveLimit(_ value: Int?) throws -> Int {
    guard let value, value > 0, value <= 64 * 1024 * 1024 else {
      throw StorageError(code: "workspace.invalid_limit", message: "Invalid read limit")
    }
    return value
  }

  private func requireRelativePath(_ value: String?) throws -> [String] {
    guard let value, !value.isEmpty, value.count <= 512,
          !value.hasPrefix("/"), !value.contains("\\") else {
      throw StorageError(code: "workspace.invalid_relative_path", message: "Invalid relative path")
    }
    let parts = value.split(separator: "/", omittingEmptySubsequences: false).map(String.init)
    guard parts.allSatisfy({ !$0.isEmpty && $0 != "." && $0 != ".." }) else {
      throw StorageError(code: "workspace.invalid_relative_path", message: "Invalid relative path")
    }
    return parts
  }

  private func sanitizeSuggestedName(_ raw: String?) -> String {
    let fallback = "OVDP-Hub-portfolio-backup.ovdp-vault.json"
    guard let raw else { return fallback }
    let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
    if trimmed.isEmpty || trimmed.count > 160 || trimmed.contains("/") || trimmed.contains("\\") || trimmed == "." || trimmed == ".." {
      return fallback
    }
    return trimmed
  }

  private func argument<T>(_ call: FlutterMethodCall, _ key: String, as type: T.Type) -> T? {
    (call.arguments as? [String: Any])?[key] as? T
  }

  private func runStorage(result: @escaping FlutterResult, operation: @escaping () throws -> Any?) {
    DispatchQueue.global(qos: .userInitiated).async {
      do {
        let value = try operation()
        DispatchQueue.main.async { result(value) }
      } catch {
        DispatchQueue.main.async { self.sendError(result, error, fallback: "workspace.external_operation_failed") }
      }
    }
  }

  private func sendError(_ result: @escaping FlutterResult, _ error: Error, fallback: String) {
    if let storage = error as? StorageError {
      result(FlutterError(code: storage.code, message: storage.message, details: nil))
      return
    }
    result(FlutterError(code: fallback, message: String(describing: error), details: nil))
  }
}
