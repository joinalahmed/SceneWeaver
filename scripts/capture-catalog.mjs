// Capture thumbnails from the actual shared renderer, one selected scene at a time.
import {createRequire} from 'node:module';
import {readFile,writeFile,mkdir} from 'node:fs/promises';
import {gunzipSync}from'node:zlib';
import path from 'node:path';
const require=createRequire(import.meta.url),{chromium}=require(process.env.PLAYWRIGHT_MODULE||'playwright');
const root=path.resolve(new URL('../studio/assets/',import.meta.url).pathname), catalog=JSON.parse(await readFile(path.join(root,'catalog.json'),'utf8'));
await mkdir(path.join(root,'thumbnails'),{recursive:true});
const browser=await chromium.launch({headless:true});
try {
 const page=await browser.newPage({viewport:{width:600,height:500},deviceScaleFactor:1});await page.goto(process.env.STUDIO_URL||'http://127.0.0.1:5173/studio/');
 for(const [index,entry]of catalog.scenes.entries()){
  if(process.argv.length>2 && !process.argv.slice(2).includes(entry.id))continue;
  const project=JSON.parse(await readFile(path.join(root,entry.project),'utf8'));
  if(project.nativeScene){const file=await readFile(path.join(root,project.nativeScene.src));const data=JSON.parse(file[0]===31?gunzipSync(file):file);delete data.motion;
   const ids=new Map(),pool=[];const intern=id=>{if(!ids.has(id)){ids.set(id,pool.length);pool.push(data.paths[id])}return ids.get(id)};
   for(const frame of[data.day,data.night]){for(const group of['solids','holes','lights'])frame[group]=frame[group].map(intern);for(const tint of frame.tints)tint.path=intern(tint.path)}data.paths=pool;
   project.nativeScene={id:project.nativeScene.id,data};
  }
  const encoded=await page.evaluate(async project=>{
   const {createRenderer,decodeArtwork}=await import('./render.mjs?v=library-5');
   const images=new Map();await Promise.all(project.layers.map(async l=>images.set(l.id,await decodeArtwork(new URL(l.asset.src,new URL('assets/',location.href)).href))));
   project.settings.motion=false;const canvas=document.createElement('canvas');canvas.style.cssText='width:402px;height:268px;position:fixed;opacity:0;left:0;top:0';document.body.append(canvas);
   return await new Promise((resolve,reject)=>{let renderer;const timeout=setTimeout(()=>reject(Error('Thumbnail render timed out')),10000);renderer=createRenderer(canvas,()=>project,()=>images,()=>{clearTimeout(timeout);const data=canvas.toDataURL('image/webp',.72);renderer.destroy();canvas.remove();resolve(data.split(',')[1])})});
  },project);
  entry.thumbnail=`thumbnails/${entry.id}.webp`;await writeFile(path.join(root,entry.thumbnail),Buffer.from(encoded,'base64'));
  if(index%40===0)console.log(`Captured ${index+1}/${catalog.scenes.length}`);
 }
 await writeFile(path.join(root,'catalog.json'),JSON.stringify(catalog,null,2)+'\n');
 // The native layered gallery uses these exact same transparent plates.
 for(const[file,name]of[['gallery/distant.svg','GalleryDistant'],['gallery/near.svg','GalleryNear']]){
  const encoded=await page.evaluate(async file=>{const image=new Image();image.src=new URL(file,new URL('assets/',location.href)).href;await image.decode();const canvas=document.createElement('canvas');canvas.width=image.naturalWidth;canvas.height=image.naturalHeight;canvas.getContext('2d').drawImage(image,0,0);return canvas.toDataURL().split(',')[1]},file);
  await writeFile(new URL(`../Sources/SceneWeaverCatalog/Resources/${name}.png`,import.meta.url),Buffer.from(encoded,'base64'));
 }
 console.log(`Captured all ${catalog.scenes.length} thumbnails and shared native gallery plates.`);
}finally{await browser.close()}
