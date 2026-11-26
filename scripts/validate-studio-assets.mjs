#!/usr/bin/env node
import {gunzipSync} from "node:zlib";
import {createHash} from "node:crypto";
import {validateNativeScene} from "../studio/native-scene.mjs";
import { readFile } from "node:fs/promises";
import { fileURLToPath } from "node:url";
import path from "node:path";
import { validateProject } from "../studio/model.mjs";
const root = path.resolve(
  path.dirname(fileURLToPath(import.meta.url)),
  "../studio/assets",
);
const catalog = JSON.parse(
  await readFile(path.join(root, "catalog.json"), "utf8"),
);
if (
  catalog.version !== 1 ||
  !Array.isArray(catalog.scenes) ||
  !catalog.scenes.length
)
  throw Error("Invalid scene catalog.");
const ids = new Set();
for (const scene of catalog.scenes) {
  if (!scene.id || ids.has(scene.id) || !scene.name)
    throw Error("Scene IDs must be unique and names nonempty.");
  ids.add(scene.id);
  if (!/^[A-Za-z0-9_-]+\.json$/.test(scene.project))
    throw Error("Scene project files must be JSON files in studio/assets.");
  const project = validateProject(
    JSON.parse(await readFile(path.join(root, scene.project), "utf8")),
    { allowSources: true },
  );
  if(project.nativeScene?.src){const buffer=await readFile(path.join(root,project.nativeScene.src));validateNativeScene(JSON.parse((buffer[0]===31?gunzipSync(buffer):buffer).toString("utf8")));}
  if(scene.thumbnail)await readFile(path.join(root,scene.thumbnail));
  for (const layer of project.layers) {
    if (!layer.asset.src)
      throw Error(
        "Catalog scenes must use relative source files, not embedded data.",
      );
    const bytes = await readFile(path.join(root, layer.asset.src));
    let width, height;
    if (layer.asset.src.endsWith(".svg")) {
      const text = bytes.toString("utf8");
      if (
        /<script|<foreignObject|<!DOCTYPE|<!ENTITY|\bon\w+\s*=|(?:href|src)\s*=\s*["'](?!#|data:)/i.test(
          text,
        )
      )
        throw Error("SVG assets must be self-contained.");
      const box = text.match(
        /viewBox=["']\s*0\s+0\s+([\d.]+)\s+([\d.]+)\s*["']/,
      );
      if (!box)
        throw Error(
          `SVG requires an explicit 0 0 width height viewBox: ${layer.asset.src}`,
        );
      [width, height] = box.slice(1).map(Number);
    } else if (layer.asset.src.endsWith(".png")) {
      if (bytes.subarray(0, 8).toString("hex") !== "89504e470d0a1a0a")
        throw Error("Invalid PNG.");
      width = bytes.readUInt32BE(16);
      height = bytes.readUInt32BE(20);
    }
    if (
      width &&
      Math.abs(width / height - project.settings.aspectRatio) > 0.005
    )
      throw Error(
        `${layer.asset.src}: canvas aspect ratio does not match the scene.`,
      );
  }
  console.log(`PASS ${scene.name}: ${project.layers.length} aligned plates`);
}

const inventory=JSON.parse(await readFile(path.join(root,"swift-inventory.json"),"utf8"));
const nativeIDs=new Set(catalog.scenes.map(s=>s.nativeID));
if(inventory.length!==catalog.scenes.length||inventory.some(s=>!nativeIDs.has(s.id)))throw Error("SwiftUI and web catalog inventories differ.");
const manifest=JSON.parse(await readFile(path.join(root,"runtime/manifest.json"),"utf8"));
const hash=bytes=>createHash("sha256").update(bytes).digest("hex");
for(const [file,expected] of Object.entries(manifest.sources))if(hash(await readFile(path.resolve(root,"../..",file)))!==expected)throw Error(`Rebuild the Swift browser runtime after changing ${file}.`);
const compressed=await readFile(path.join(root,"runtime/sceneweaver-0.2.0.wasm.gz"));
if(hash(compressed)!==manifest.compressedSha256||hash(gunzipSync(compressed))!==manifest.sha256)throw Error("Browser Swift runtime checksum mismatch.");
console.log(`PASS catalog parity: ${inventory.length} matching scenes and verified Swift runtime sources.`);
