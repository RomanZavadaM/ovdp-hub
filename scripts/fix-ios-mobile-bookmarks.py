from pathlib import Path

path = Path("apps/native/ios/Runner/AppDelegate.swift")
text = path.read_text(encoding="utf-8")

replacements = [
    (
        "options: [.withSecurityScope],\n          includingResourceValuesForKeys: [.isDirectoryKey, .nameKey],",
        "options: .minimalBookmark,\n          includingResourceValuesForKeys: [.isDirectoryKey, .nameKey],",
        2,
    ),
    (
        "options: [.withSecurityScope, .withoutUI],\n        relativeTo: nil,",
        "options: .withoutUI,\n        relativeTo: nil,",
        1,
    ),
]

for old, new, expected in replacements:
    count = text.count(old)
    if count != expected:
        raise SystemExit(f"expected {expected} matches, found {count}: {old!r}")
    text = text.replace(old, new)

path.write_text(text, encoding="utf-8")
print("iOS bookmark options updated for UIKit directory access")
