from pathlib import Path


def replace_once(path: str, old: str, new: str) -> None:
    file = Path(path)
    text = file.read_text(encoding="utf-8")
    count = text.count(old)
    if count != 1:
        raise SystemExit(f"{path}: expected exactly one match, found {count}")
    file.write_text(text.replace(old, new), encoding="utf-8")


replace_once(
    "apps/native/lib/features/portfolio/portfolio_cubit.dart",
    "final workspacePath = hubRepository.current?.path;",
    "final workspacePath = hubRepository.current?.localPath;",
)

replace_once(
    ".github/workflows/native.yml",
    "    if: github.event_name == 'workflow_dispatch' && contains(fromJSON('[\"android\",\"all\"]'), inputs.packages)\n",
    "    if: >-\n      (github.event_name == 'pull_request' && github.event.pull_request.draft == false) ||\n      (github.event_name == 'workflow_dispatch' && contains(fromJSON('[\"android\",\"all\"]'), inputs.packages))\n",
)

replace_once(
    ".github/workflows/native.yml",
    "    if: github.event_name == 'workflow_dispatch' && contains(fromJSON('[\"ios\",\"all\"]'), inputs.packages)\n",
    "    if: >-\n      (github.event_name == 'pull_request' && github.event.pull_request.draft == false) ||\n      (github.event_name == 'workflow_dispatch' && contains(fromJSON('[\"ios\",\"all\"]'), inputs.packages))\n",
)

print("mobile storage finalization patch applied")
