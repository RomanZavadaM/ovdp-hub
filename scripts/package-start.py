"""Package committed native sources only; never include local workspaces/builds."""
import io
import json
import os
from pathlib import Path
import re
import subprocess
import zipfile

root = Path(__file__).resolve().parents[1]
version = re.search(r'^version:\s*(\d+\.\d+\.\d+)\+', (root / 'apps/native/pubspec.yaml').read_text(encoding='utf-8-sig'), re.M).group(1)
run = os.environ['GITHUB_RUN_NUMBER']
attempt = os.environ.get('GITHUB_RUN_ATTEMPT', '1')
if not run.isdigit() or not attempt.isdigit():
    raise SystemExit('Invalid package identity')
stem = f'OVDP-Hub-{version}-test-{run}-{attempt}-START'
stage = root / 'build/start-upload'
folder = stage / stem
folder.mkdir(parents=True, exist_ok=False)
archive = subprocess.check_output(['git', 'archive', '--format=zip', 'HEAD:apps/native'], cwd=root)
with zipfile.ZipFile(io.BytesIO(archive)) as src:
    for entry in src.infolist():
        path = Path(entry.filename)
        if path.is_absolute() or '..' in path.parts or any(p in {'build', '.dart_tool', '.git', 'ephemeral', 'Pods'} for p in path.parts) or path.suffix.lower() in {'.db', '.sqlite', '.sqlite3', '.p12', '.jks'}:
            raise SystemExit(f'Unexpected package file: {entry.filename}')
        target = folder / path
        if entry.is_dir():
            target.mkdir(parents=True, exist_ok=True)
        else:
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(src.read(entry))
for required in ['START.bat', 'START.command', 'START-README.md', 'pubspec.yaml', 'pubspec.lock', 'lib/main.dart', 'assets/nbu-snapshot.json']:
    if not (folder / required).is_file():
        raise SystemExit(f'Missing required file: {required}')
launcher = (folder / 'START.bat').read_bytes()
if any(b >= 128 for b in launcher) or b'\r\n' not in launcher:
    raise SystemExit('Windows launcher must use ASCII and CRLF')
(folder / 'START.command').chmod(0o755)
(folder / 'build-info.json').write_text(json.dumps({'version': version, 'run': run, 'attempt': attempt, 'commit': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=root, text=True).strip(), 'kind': 'source-start'}, indent=2), encoding='utf8')
with open(os.environ['GITHUB_OUTPUT'], 'a', encoding='utf8') as out:
    out.write(f'package_name={stem}\npackage_path={stage.as_posix()}\n')
print(stem)
