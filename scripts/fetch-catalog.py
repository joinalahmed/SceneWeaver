#!/usr/bin/env python3
"""Fetch the versioned scene geometry archive and verify every installed file."""
from pathlib import Path
import hashlib
import json
import subprocess
import tempfile
import zipfile

ROOT = Path(__file__).resolve().parent.parent
MANIFEST = ROOT / 'studio/assets/catalog-manifest.json'

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def main():
    manifest = json.loads(MANIFEST.read_text())
    target = ROOT / 'studio/assets/library'
    target.mkdir(exist_ok=True)
    missing = [name for name, expected in manifest['files'].items()
               if not (target / name).is_file() or digest(target / name) != expected]
    if missing:
        with tempfile.TemporaryDirectory(prefix='sceneweaver-catalog-') as temporary:
            archive = Path(temporary) / 'catalog.zip'
            subprocess.run(['curl', '--fail', '--location', '--silent', '--show-error', '--retry', '3',
                            manifest['url'], '--output', str(archive)], check=True)
            if digest(archive) != manifest['sha256']:
                raise SystemExit('Scene catalog archive checksum mismatch.')
            with zipfile.ZipFile(archive) as source:
                if set(source.namelist()) != set(manifest['files']):
                    raise SystemExit('Catalog archive does not match its inventory.')
                for name, expected in manifest['files'].items():
                    if Path(name).name != name or not name.endswith('.geometry.json.gz'):
                        raise SystemExit('Unexpected catalog archive path.')
                    data = source.read(name)
                    if hashlib.sha256(data).hexdigest() != expected:
                        raise SystemExit(f'Checksum mismatch: {name}')
                    (target / name).write_bytes(data)
    print(f"Verified {len(manifest['files'])} scene geometry files ({manifest['version']}).")

if __name__ == '__main__':
    main()
