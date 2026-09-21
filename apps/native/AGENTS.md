# Flutter application rules

- Organize features by catalog, collections, workspace, calculator and navigation.
- UI renders immutable states and forwards user actions. No filesystem/API access, financial formulas or business state in widgets.
- Cubits coordinate scenarios; repository implementations own persistence and API access; pricing remains independent.
- Every feature Cubit has an immutable State with copyWith. Defensively freeze nested collections, not just top-level fields.
- Inject repositories and clocks for tests. Cancel subscriptions on close and ignore asynchronous completions after close.
- Serialize workspace switches and writes. Failed/cancelled switches preserve current data and drafts. Save failure preserves the draft.
- Test error paths, race conditions, restoration and reference financial examples. Run flutter analyze, flutter test and attempt the target release build.
- SDK and dependency versions are fixed via documented SDK version and committed pubspec.lock. No unreviewed automatic upgrades.
