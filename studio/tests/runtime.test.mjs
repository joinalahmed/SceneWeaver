import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {gunzipSync} from 'node:zlib';
import {WASI} from 'node:wasi';
const root=new URL('../assets/',import.meta.url);
test('all 421 procedural recipes execute live in Swift at native and narrow RTL widths',async()=>{
 const wasi=new WASI({version:'preview1',args:[],env:{TZ:'UTC',SWIFT_DETERMINISTIC_HASHING:'1'},preopens:{}});
 const bytes=gunzipSync(readFileSync(new URL('runtime/sceneweaver-0.2.0.wasm.gz',root)));
 const {instance}=await WebAssembly.instantiate(bytes,{wasi_snapshot_preview1:wasi.wasiImport});wasi.initialize(instance);
 const e=instance.exports,enc=new TextEncoder(),dec=new TextDecoder();
 const index=id=>{const b=enc.encode(id),p=e.scene_alloc(b.length);new Uint8Array(e.memory.buffer,p,b.length).set(b);const i=e.scene_index(p,b.length);e.scene_free(p);return i};
 const render=(i,width,time,night,hour,rtl)=>{const p=e.scene_render(i,width,224,time,night,hour,rtl);assert.ok(p);const text=dec.decode(new Uint8Array(e.memory.buffer,p,e.scene_result_length()));assert.ok(!/NaN|Infinity/.test(text));return JSON.parse(text)};
 const catalog=JSON.parse(readFileSync(new URL('catalog.json',root)));assert.equal(catalog.scenes.length,428);let count=0;
 for(const entry of catalog.scenes){const project=JSON.parse(readFileSync(new URL(entry.project,root)));if(!project.nativeScene)continue;
  const i=index(project.nativeScene.id);assert.ok(i>=0,entry.id);
  for(const args of [[402,0,0,12,0],[320,31.7,1,22,1]]){const g=render(i,...args);assert.equal(g.width,args[0]);assert.ok(g.paths.length,entry.id);assert.equal(g.version,1)}count++;
 }
 assert.equal(count,421);
 const london=index('london');assert.ok(london>=0);
 assert.notDeepEqual(render(london,402,1,0,9,0).paths,render(london,402,1,0,17,0).paths,'landmark clocks follow the supplied hour');
});
