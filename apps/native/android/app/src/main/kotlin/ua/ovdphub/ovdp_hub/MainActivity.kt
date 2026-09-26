package ua.ovdphub.ovdp_hub

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.provider.DocumentsContract
import android.provider.OpenableColumns
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.io.FileNotFoundException
import java.util.UUID

class MainActivity : FlutterActivity() {
    companion object {
        private const val CHANNEL = "ua.ovdphub/mobile_external_storage"
        private const val REQUEST_EXPORT_BACKUP = 7101
        private const val REQUEST_IMPORT_BACKUP = 7102
        private const val REQUEST_WORKSPACE_FOLDER = 7103
        private const val PREFS = "ovdp_external_storage"
        private const val MAX_WORKSPACE_TEXT_BYTES = 20 * 1024 * 1024
    }

    private var pendingResult: MethodChannel.Result? = null
    private var pendingBackupBytes: ByteArray? = null
    private var pendingImportLimit: Int = 20 * 1024 * 1024

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result -> handleStorageCall(call, result) }
    }

    private fun handleStorageCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "exportEncryptedBackup" -> startBackupExport(call, result)
            "importEncryptedBackup" -> startBackupImport(call, result)
            "chooseWorkspaceFolder" -> startWorkspaceFolderPicker(result)
            "workspaceFolderAvailable" -> runStorage(result) {
                workspaceFolderAvailable(requireGrantId(call))
            }
            "readWorkspaceText" -> runStorage(result) {
                readWorkspaceText(
                    requireGrantId(call),
                    requireRelativePath(call.argument<String>("relativePath")),
                    requirePositiveLimit(call.argument<Int>("maxBytes")),
                )
            }
            "writeWorkspaceText" -> runStorage(result) {
                val content = call.argument<String>("content")
                    ?: throw StorageError("workspace.external_write_failed", "Missing content")
                val bytes = content.toByteArray(Charsets.UTF_8)
                if (bytes.size > MAX_WORKSPACE_TEXT_BYTES) {
                    throw StorageError("workspace.file_too_large", "Workspace file is too large")
                }
                writeWorkspaceText(
                    requireGrantId(call),
                    requireRelativePath(call.argument<String>("relativePath")),
                    bytes,
                    call.argument<Boolean>("replace") ?: false,
                )
                null
            }
            "listWorkspaceFiles" -> runStorage(result) {
                val raw = call.argument<String>("relativeDirectory") ?: ""
                val segments = if (raw.isEmpty()) emptyList() else requireRelativePath(raw)
                listWorkspaceFiles(requireGrantId(call), segments)
            }
            "deleteWorkspaceFile" -> runStorage(result) {
                deleteWorkspaceFile(
                    requireGrantId(call),
                    requireRelativePath(call.argument<String>("relativePath")),
                )
                null
            }
            else -> result.notImplemented()
        }
    }

    private fun startBackupExport(call: MethodCall, result: MethodChannel.Result) {
        ensureNoPendingPicker(result) ?: return
        val name = sanitizeSuggestedName(call.argument<String>("suggestedName"))
        val bytes = call.argument<ByteArray>("bytes")
        if (bytes == null || bytes.isEmpty()) {
            result.error("vault.invalid_file", "Backup bytes are empty", null)
            return
        }
        pendingResult = result
        pendingBackupBytes = bytes.copyOf()
        val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = "application/json"
            putExtra(Intent.EXTRA_TITLE, name)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
        }
        @Suppress("DEPRECATION")
        startActivityForResult(intent, REQUEST_EXPORT_BACKUP)
    }

    private fun startBackupImport(call: MethodCall, result: MethodChannel.Result) {
        ensureNoPendingPicker(result) ?: return
        pendingImportLimit = requirePositiveLimit(call.argument<Int>("maxBytes"))
        pendingResult = result
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = "application/json"
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        @Suppress("DEPRECATION")
        startActivityForResult(intent, REQUEST_IMPORT_BACKUP)
    }

    private fun startWorkspaceFolderPicker(result: MethodChannel.Result) {
        ensureNoPendingPicker(result) ?: return
        pendingResult = result
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
            addFlags(
                Intent.FLAG_GRANT_READ_URI_PERMISSION or
                    Intent.FLAG_GRANT_WRITE_URI_PERMISSION or
                    Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION or
                    Intent.FLAG_GRANT_PREFIX_URI_PERMISSION,
            )
        }
        @Suppress("DEPRECATION")
        startActivityForResult(intent, REQUEST_WORKSPACE_FOLDER)
    }

    private fun ensureNoPendingPicker(result: MethodChannel.Result): Unit? {
        if (pendingResult != null) {
            result.error("workspace.picker_busy", "Another system picker is already open", null)
            return null
        }
        return Unit
    }

    @Deprecated("Deprecated in Android API; FlutterActivity still forwards this callback reliably.")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        val result = pendingResult ?: return
        if (requestCode !in setOf(REQUEST_EXPORT_BACKUP, REQUEST_IMPORT_BACKUP, REQUEST_WORKSPACE_FOLDER)) {
            return
        }
        pendingResult = null
        if (resultCode != Activity.RESULT_OK || data?.data == null) {
            pendingBackupBytes = null
            result.success(null)
            return
        }
        val uri = data.data!!
        try {
            when (requestCode) {
                REQUEST_EXPORT_BACKUP -> {
                    val bytes = pendingBackupBytes
                        ?: throw StorageError("portfolio.backup_export_failed", "Missing pending backup bytes")
                    pendingBackupBytes = null
                    contentResolver.openOutputStream(uri, "wt")?.use { output ->
                        output.write(bytes)
                        output.flush()
                    } ?: throw FileNotFoundException("Unable to open selected backup destination")
                    result.success(displayName(uri) ?: "OVDP Hub backup")
                }
                REQUEST_IMPORT_BACKUP -> {
                    val bytes = readUriLimited(uri, pendingImportLimit)
                    result.success(bytes)
                }
                REQUEST_WORKSPACE_FOLDER -> {
                    val takeFlags = data.flags and
                        (Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
                    contentResolver.takePersistableUriPermission(uri, takeFlags)
                    val permission = contentResolver.persistedUriPermissions.firstOrNull {
                        it.uri == uri && it.isReadPermission && it.isWritePermission
                    } ?: throw StorageError(
                        "workspace.external_permission_lost",
                        "Provider did not persist read/write access",
                    )
                    val id = UUID.randomUUID().toString()
                    val label = treeDisplayName(permission.uri) ?: "External workspace"
                    getSharedPreferences(PREFS, MODE_PRIVATE).edit()
                        .putString("folder.$id.uri", permission.uri.toString())
                        .putString("folder.$id.label", label)
                        .apply()
                    result.success(mapOf("id" to id, "label" to label))
                }
            }
        } catch (error: Throwable) {
            pendingBackupBytes = null
            sendError(result, error)
        }
    }

    private fun runStorage(result: MethodChannel.Result, operation: () -> Any?) {
        Thread {
            try {
                val value = operation()
                runOnUiThread { result.success(value) }
            } catch (error: Throwable) {
                runOnUiThread { sendError(result, error) }
            }
        }.start()
    }

    private fun requireGrantId(call: MethodCall): String {
        val id = call.argument<String>("grantId") ?: ""
        if (!Regex("^[A-Za-z0-9-]{8,80}$").matches(id)) {
            throw StorageError("workspace.external_grant_invalid", "Invalid grant id")
        }
        return id
    }

    private fun requirePositiveLimit(value: Int?): Int {
        if (value == null || value <= 0 || value > 64 * 1024 * 1024) {
            throw StorageError("workspace.invalid_limit", "Invalid read limit")
        }
        return value
    }

    private fun requireRelativePath(value: String?): List<String> {
        val path = value ?: ""
        if (path.isEmpty() || path.length > 512 || path.startsWith('/') || path.contains('\\')) {
            throw StorageError("workspace.invalid_relative_path", "Invalid relative path")
        }
        val segments = path.split('/')
        if (segments.any { it.isEmpty() || it == "." || it == ".." }) {
            throw StorageError("workspace.invalid_relative_path", "Invalid relative path")
        }
        return segments
    }

    private fun workspaceFolderAvailable(grantId: String): Boolean {
        val treeUri = grantUri(grantId) ?: return false
        val hasPermission = contentResolver.persistedUriPermissions.any {
            it.uri == treeUri && it.isReadPermission && it.isWritePermission
        }
        if (!hasPermission) return false
        return try {
            contentResolver.query(
                rootDocumentUri(treeUri),
                arrayOf(DocumentsContract.Document.COLUMN_DOCUMENT_ID),
                null,
                null,
                null,
            )?.use { it.moveToFirst() } ?: false
        } catch (_: SecurityException) {
            false
        } catch (_: FileNotFoundException) {
            false
        }
    }

    private fun readWorkspaceText(grantId: String, path: List<String>, maxBytes: Int): String? {
        val treeUri = requireAvailableGrant(grantId)
        val document = resolveDocument(treeUri, path, createParents = false) ?: return null
        if (document.mimeType == DocumentsContract.Document.MIME_TYPE_DIR) {
            throw StorageError("workspace.external_read_failed", "Expected a file")
        }
        val bytes = readUriLimited(document.uri, maxBytes)
        return bytes.toString(Charsets.UTF_8)
    }

    private fun writeWorkspaceText(
        grantId: String,
        path: List<String>,
        bytes: ByteArray,
        replace: Boolean,
    ) {
        val treeUri = requireAvailableGrant(grantId)
        val parent = resolveDirectory(treeUri, path.dropLast(1), create = true)
        val name = path.last()
        val existing = findChild(treeUri, parent, name)
        val target = if (existing != null) {
            if (!replace) {
                throw StorageError("workspace.external_file_exists", "Destination already exists")
            }
            if (existing.mimeType == DocumentsContract.Document.MIME_TYPE_DIR) {
                throw StorageError("workspace.external_write_failed", "Destination is a directory")
            }
            existing.uri
        } else {
            DocumentsContract.createDocument(contentResolver, parent, mimeTypeFor(name), name)
                ?: throw StorageError("workspace.external_write_failed", "Provider could not create file")
        }
        contentResolver.openOutputStream(target, "wt")?.use { output ->
            output.write(bytes)
            output.flush()
        } ?: throw StorageError("workspace.external_write_failed", "Provider could not open file")
    }

    private fun listWorkspaceFiles(grantId: String, directory: List<String>): List<String> {
        val treeUri = requireAvailableGrant(grantId)
        val parent = resolveDirectory(treeUri, directory, create = false)
        val parentId = DocumentsContract.getDocumentId(parent)
        val childrenUri = DocumentsContract.buildChildDocumentsUriUsingTree(treeUri, parentId)
        val names = mutableListOf<String>()
        contentResolver.query(
            childrenUri,
            arrayOf(
                DocumentsContract.Document.COLUMN_DISPLAY_NAME,
                DocumentsContract.Document.COLUMN_MIME_TYPE,
            ),
            null,
            null,
            null,
        )?.use { cursor ->
            val nameIndex = cursor.getColumnIndexOrThrow(DocumentsContract.Document.COLUMN_DISPLAY_NAME)
            val typeIndex = cursor.getColumnIndexOrThrow(DocumentsContract.Document.COLUMN_MIME_TYPE)
            while (cursor.moveToNext()) {
                if (cursor.getString(typeIndex) != DocumentsContract.Document.MIME_TYPE_DIR) {
                    names.add(cursor.getString(nameIndex))
                }
            }
        }
        return names.sorted()
    }

    private fun deleteWorkspaceFile(grantId: String, path: List<String>) {
        val treeUri = requireAvailableGrant(grantId)
        val document = resolveDocument(treeUri, path, createParents = false) ?: return
        if (document.mimeType == DocumentsContract.Document.MIME_TYPE_DIR) {
            throw StorageError("workspace.external_delete_failed", "Refusing to delete directory")
        }
        if (!DocumentsContract.deleteDocument(contentResolver, document.uri)) {
            throw StorageError("workspace.external_delete_failed", "Provider refused delete")
        }
    }

    private fun requireAvailableGrant(grantId: String): Uri {
        val uri = grantUri(grantId)
            ?: throw StorageError("workspace.external_permission_lost", "Unknown external folder grant")
        if (!workspaceFolderAvailable(grantId)) {
            throw StorageError("workspace.external_permission_lost", "External folder permission is unavailable")
        }
        return uri
    }

    private fun grantUri(grantId: String): Uri? {
        val raw = getSharedPreferences(PREFS, MODE_PRIVATE).getString("folder.$grantId.uri", null)
            ?: return null
        return Uri.parse(raw)
    }

    private fun rootDocumentUri(treeUri: Uri): Uri = DocumentsContract.buildDocumentUriUsingTree(
        treeUri,
        DocumentsContract.getTreeDocumentId(treeUri),
    )

    private data class DocumentRef(val uri: Uri, val mimeType: String)

    private fun resolveDocument(
        treeUri: Uri,
        path: List<String>,
        createParents: Boolean,
    ): DocumentRef? {
        if (path.isEmpty()) {
            return DocumentRef(rootDocumentUri(treeUri), DocumentsContract.Document.MIME_TYPE_DIR)
        }
        var current = rootDocumentUri(treeUri)
        path.forEachIndexed { index, name ->
            val child = findChild(treeUri, current, name)
            if (child == null) {
                if (createParents && index < path.lastIndex) {
                    current = DocumentsContract.createDocument(
                        contentResolver,
                        current,
                        DocumentsContract.Document.MIME_TYPE_DIR,
                        name,
                    ) ?: throw StorageError(
                        "workspace.external_write_failed",
                        "Provider could not create directory",
                    )
                } else {
                    return null
                }
            } else {
                if (index < path.lastIndex && child.mimeType != DocumentsContract.Document.MIME_TYPE_DIR) {
                    throw StorageError("workspace.external_read_failed", "Path component is not a directory")
                }
                current = child.uri
                if (index == path.lastIndex) return child
            }
        }
        return DocumentRef(current, DocumentsContract.Document.MIME_TYPE_DIR)
    }

    private fun resolveDirectory(treeUri: Uri, path: List<String>, create: Boolean): Uri {
        var current = rootDocumentUri(treeUri)
        for (name in path) {
            val child = findChild(treeUri, current, name)
            current = when {
                child == null && create -> DocumentsContract.createDocument(
                    contentResolver,
                    current,
                    DocumentsContract.Document.MIME_TYPE_DIR,
                    name,
                ) ?: throw StorageError(
                    "workspace.external_write_failed",
                    "Provider could not create directory",
                )
                child == null -> throw StorageError("workspace.external_missing", "Directory is missing")
                child.mimeType != DocumentsContract.Document.MIME_TYPE_DIR ->
                    throw StorageError("workspace.external_invalid", "Path component is not a directory")
                else -> child.uri
            }
        }
        return current
    }

    private fun findChild(treeUri: Uri, parent: Uri, name: String): DocumentRef? {
        val parentId = DocumentsContract.getDocumentId(parent)
        val childrenUri = DocumentsContract.buildChildDocumentsUriUsingTree(treeUri, parentId)
        contentResolver.query(
            childrenUri,
            arrayOf(
                DocumentsContract.Document.COLUMN_DOCUMENT_ID,
                DocumentsContract.Document.COLUMN_DISPLAY_NAME,
                DocumentsContract.Document.COLUMN_MIME_TYPE,
            ),
            null,
            null,
            null,
        )?.use { cursor ->
            val idIndex = cursor.getColumnIndexOrThrow(DocumentsContract.Document.COLUMN_DOCUMENT_ID)
            val nameIndex = cursor.getColumnIndexOrThrow(DocumentsContract.Document.COLUMN_DISPLAY_NAME)
            val typeIndex = cursor.getColumnIndexOrThrow(DocumentsContract.Document.COLUMN_MIME_TYPE)
            while (cursor.moveToNext()) {
                if (cursor.getString(nameIndex) == name) {
                    val childUri = DocumentsContract.buildDocumentUriUsingTree(
                        treeUri,
                        cursor.getString(idIndex),
                    )
                    return DocumentRef(childUri, cursor.getString(typeIndex))
                }
            }
        }
        return null
    }

    private fun readUriLimited(uri: Uri, maxBytes: Int): ByteArray {
        val input = contentResolver.openInputStream(uri)
            ?: throw FileNotFoundException("Unable to open selected document")
        input.use { stream ->
            val output = ByteArrayOutputStream()
            val buffer = ByteArray(16 * 1024)
            var total = 0
            while (true) {
                val count = stream.read(buffer)
                if (count < 0) break
                total += count
                if (total > maxBytes) {
                    throw StorageError("vault.file_too_large", "Selected file exceeds size limit")
                }
                output.write(buffer, 0, count)
            }
            return output.toByteArray()
        }
    }

    private fun treeDisplayName(treeUri: Uri): String? {
        val documentUri = rootDocumentUri(treeUri)
        return contentResolver.query(
            documentUri,
            arrayOf(DocumentsContract.Document.COLUMN_DISPLAY_NAME),
            null,
            null,
            null,
        )?.use { cursor ->
            if (cursor.moveToFirst()) {
                cursor.getString(cursor.getColumnIndexOrThrow(DocumentsContract.Document.COLUMN_DISPLAY_NAME))
            } else null
        }
    }

    private fun displayName(uri: Uri): String? = contentResolver.query(
        uri,
        arrayOf(OpenableColumns.DISPLAY_NAME),
        null,
        null,
        null,
    )?.use { cursor ->
        if (cursor.moveToFirst()) {
            cursor.getString(cursor.getColumnIndexOrThrow(OpenableColumns.DISPLAY_NAME))
        } else null
    }

    private fun mimeTypeFor(name: String): String = when {
        name.endsWith(".json", ignoreCase = true) -> "application/json"
        name.endsWith(".csv", ignoreCase = true) -> "text/csv"
        name.endsWith(".ics", ignoreCase = true) -> "text/calendar"
        else -> "text/plain"
    }

    private fun sanitizeSuggestedName(raw: String?): String {
        val value = raw?.trim() ?: "OVDP-Hub-portfolio-backup.ovdp-vault.json"
        if (value.isEmpty() || value.length > 160 || value.contains('/') || value.contains('\\')) {
            throw StorageError("portfolio.backup_export_failed", "Invalid suggested file name")
        }
        return value
    }

    private fun sendError(result: MethodChannel.Result, error: Throwable) {
        val storage = error as? StorageError
        result.error(
            storage?.code ?: "workspace.external_operation_failed",
            storage?.message ?: error.message ?: error.javaClass.simpleName,
            null,
        )
    }

    private class StorageError(val code: String, override val message: String) : Exception(message)
}
