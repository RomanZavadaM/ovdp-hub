from pathlib import Path

path = Path("apps/native/lib/features/portfolio/portfolio_cubit.dart")
text = path.read_text(encoding="utf-8")
old = "final workspacePath = hubRepository.current?.path;"
new = "final workspacePath = hubRepository.current?.localPath;"
count = text.count(old)
if count != 1:
    raise SystemExit(f"expected exactly one legacy workspacePath match, found {count}")
path.write_text(text.replace(old, new), encoding="utf-8")
print("legacy migration path guard applied")
