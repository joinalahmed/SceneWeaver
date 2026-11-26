#!/usr/bin/env python3
"""Compile canonical Swift scene recipes for the browser with the official Wasm SDK."""
from pathlib import Path
import os
import gzip
import hashlib
import json
import shutil
import subprocess

ROOT=Path(__file__).resolve().parent.parent
PACKAGE=ROOT/'Tools/WasmRuntime'
recipe_files=sorted((ROOT/'Sources/SceneWeaverCatalog/Recipes').glob('*.swift'))
for source in recipe_files:
    text=source.read_text()
    if source.stem=='Cityscapes':text+='\nprivate typealias Calendar = SceneCalendar\n'
    (PACKAGE/'Sources/Recipes'/source.name).write_text(text)
shutil.copyfile(ROOT/'Sources/SceneWeaver/ScenePen.swift',PACKAGE/'Sources/SceneWeaver/ScenePen.swift')
swift=os.environ.get('SCENEWEAVER_SWIFT','swift')
subprocess.run([swift,'build','--package-path',str(PACKAGE),'--swift-sdk','swift-6.4.2-RELEASE_wasm','-c','release'],check=True)
product=next((PACKAGE/'.build').rglob('SceneWeaverRuntime.wasm'))
target=ROOT/'studio/assets/runtime';target.mkdir(exist_ok=True)
data=product.read_bytes()
(target/'sceneweaver-0.2.0.wasm.gz').write_bytes(gzip.compress(data,compresslevel=9,mtime=0))
source_files=[ROOT/'Sources/SceneWeaver/ScenePen.swift', *recipe_files, *sorted((PACKAGE/'Sources/SwiftUI').glob('*.swift')), PACKAGE/'Sources/Recipes/Runtime.swift', PACKAGE/'Sources/Recipes/main.swift', PACKAGE/'Sources/SceneWeaver/ArtworkLayout.swift', PACKAGE/'Package.swift', ROOT/'scripts/build-wasm.py']
manifest={'version':'0.2.0','sha256':hashlib.sha256(data).hexdigest(),'compressedSha256':hashlib.sha256((target/'sceneweaver-0.2.0.wasm.gz').read_bytes()).hexdigest(),'sources':{str(p.relative_to(ROOT)):hashlib.sha256(p.read_bytes()).hexdigest()for p in source_files}}
(target/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
(target/'version.mjs').write_text('export const RUNTIME_SHA256 = '+json.dumps(manifest['sha256'])+';\n')
print(f'Built browser Swift runtime: {product.stat().st_size:,} bytes')
