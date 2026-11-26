#!/usr/bin/env node
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
