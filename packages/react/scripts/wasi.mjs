import {build}from'esbuild';import{readFile,writeFile,mkdir}from'node:fs/promises';import path from'node:path';import{fileURLToPath}from'node:url';
const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'..'),output=path.join(root,'../../studio/assets/runtime');await mkdir(output,{recursive:true});
await build({entryPoints:[path.join(root,'node_modules/@bjorn3/browser_wasi_shim/dist/index.js')],outfile:path.join(output,'wasi.mjs'),format:'esm',bundle:true,minify:true,target:'es2020',legalComments:'eof'});
await writeFile(path.join(output,'WASI-LICENSE-MIT.txt'),await readFile(path.join(root,'node_modules/@bjorn3/browser_wasi_shim/LICENSE-MIT'),'utf8'));
