import {WASI,File,OpenFile,ConsoleStdout}from'./assets/runtime/wasi.mjs';
import {RUNTIME_SHA256}from'./assets/runtime/version.mjs';
const requests=new Map(),bindings=new WeakMap();
const encode=bytes=>{let s='';for(let i=0;i<bytes.length;i+=32768)s+=String.fromCharCode(...bytes.subarray(i,i+32768));return btoa(s)};
async function initialize(source){
 let compressed;
 if(source.startsWith('data:application/wasm')){const bytes=atob(source.split(',')[1]);compressed=Uint8Array.from(bytes,c=>c.charCodeAt(0))}
 else{const response=await fetch(source);if(!response.ok)throw Error(`Could not load Swift renderer (HTTP ${response.status}).`);compressed=new Uint8Array(await response.arrayBuffer())}
 if(compressed.length>30000000)throw Error('Swift renderer exceeds 30 MB.');
 const bytes=compressed[0]===31&&compressed[1]===139?new Uint8Array(await new Response(new Blob([compressed]).stream().pipeThrough(new DecompressionStream('gzip'))).arrayBuffer()):compressed;
 const digest=[...new Uint8Array(await crypto.subtle.digest('SHA-256',bytes))].map(x=>x.toString(16).padStart(2,'0')).join('');
 if(![RUNTIME_SHA256,'6325afd6cb3e63f88f9cbb5c1e958d08dfd28176e37e5c4a200ebec19e0b87c4'].includes(digest))throw Error('This scene needs a different SceneWeaver runtime version. Update the component or re-export the scene.');
 const module=await WebAssembly.compile(bytes);
 if(WebAssembly.Module.imports(module).some(i=>i.module!=='wasi_snapshot_preview1'))throw Error('Unsupported scene runtime imports.');
 const wasi=new WASI([],['TZ=UTC','SWIFT_DETERMINISTIC_HASHING=1'],[new OpenFile(new File([])),ConsoleStdout.lineBuffered(()=>{}),ConsoleStdout.lineBuffered(()=>{})]);
 const instance=await WebAssembly.instantiate(module,{wasi_snapshot_preview1:wasi.wasiImport});wasi.initialize(instance);const e=instance.exports,indices=new Map(),encoder=new TextEncoder(),decoder=new TextDecoder();
 const portable=compressed[0]===31&&compressed[1]===139?compressed:new Uint8Array(await new Response(new Blob([bytes]).stream().pipeThrough(new CompressionStream('gzip'))).arrayBuffer());
 return{dataURL:'data:application/wasm+gzip;base64,'+encode(portable),render(id,width,horizon,time,night,hour,rtl){
   if(!indices.has(id)){const value=encoder.encode(id),pointer=e.scene_alloc(value.length);new Uint8Array(e.memory.buffer,pointer,value.length).set(value);const index=e.scene_index(pointer,value.length);e.scene_free(pointer);if(index<0)throw Error(`Unknown Swift scene: ${id}`);indices.set(id,index)}
   const pointer=e.scene_render(indices.get(id),width,horizon,time,night,hour,rtl?1:0);if(!pointer)throw Error(`Could not render Swift scene: ${id}`);
   return JSON.parse(decoder.decode(new Uint8Array(e.memory.buffer,pointer,e.scene_result_length())));
 }};
}
export function loadNativeRuntime(source){if(!requests.has(source)){const request=initialize(source).catch(error=>{requests.delete(source);throw error});requests.set(source,request)}return requests.get(source)}
export async function attachNativeRuntime(reference,baseURL){
 const source=reference.runtimeData??(reference.runtimeSrc?new URL(reference.runtimeSrc,baseURL).href:null);if(!source)return;
 const runtime=await loadNativeRuntime(source);reference.runtimeData=runtime.dataURL;delete reference.runtimeSrc;bindings.set(reference.data,{runtime,id:reference.id});
 // Reopening an exported project reuses the same initialized module.
 if(!requests.has(runtime.dataURL))requests.set(runtime.dataURL,Promise.resolve(runtime));
}
export function renderNativeRuntime(reference,width,horizon,time,night,hour,rtl){
 const binding=bindings.get(reference.data);if(!binding)return reference.data;
 const key=[width,horizon,time,night,hour,rtl].join('|');if(binding.key===key)return binding.result;
 const result=binding.runtime.render(binding.id,width,horizon,time,night,hour,rtl);result._surfaceOwner=reference.data;binding.key=key;binding.result=result;return result;
}
