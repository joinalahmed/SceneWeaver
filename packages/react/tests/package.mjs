import { execFileSync } from "node:child_process";
import { mkdtemp, writeFile, rm, readFile } from "node:fs/promises";
import path from "node:path";
import os from "node:os";
import { fileURLToPath } from "node:url";
import assert from "node:assert/strict";
const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const temporary = await mkdtemp(
  path.join(os.tmpdir(), "sceneweaver-react-consumer-"),
);
try {
  const packed = JSON.parse(
    execFileSync("npm", ["pack", "--json", "--pack-destination", temporary], {
      cwd: root,
      encoding: "utf8",
    }).trim(),
  );
  const artifact = path.join(temporary, packed[0].filename),
    files = packed[0].files.map((f) => f.path);
  assert.ok(files.includes("dist/index.js"));
  assert.ok(files.includes("dist/index.d.ts"));
  assert.ok(files.includes("LICENSE"));
  assert.ok(
    !files.some(
      (f) =>
        f.startsWith("node_modules/") ||
        f.startsWith("src/") ||
        f.startsWith("tests/"),
    ),
  );
  assert.match(
    await readFile(path.join(root, "dist/index.js"), "utf8"),
    /^"use client"/,
  );
  for (const version of ["18.3.1", "19.3.1"]) {
    const consumer = path.join(temporary, `consumer-${version}`);
    await import("node:fs/promises").then((fs) => fs.mkdir(consumer));
    await writeFile(
      path.join(consumer, "package.json"),
      JSON.stringify({
        name: "sceneweaver-consumer-test",
        version: "1.0.0",
        private: true,
        type: "module",
      }),
    );
    execFileSync(
      "npm",
      [
        "install",
        "--ignore-scripts",
        "--no-audit",
        "--no-fund",
        artifact,
        `react@${version}`,
        `react-dom@${version}`,
        `@types/react@${version.startsWith("18") ? "18.3.32" : "19.3.3"}`,
      ],
      { cwd: consumer, stdio: "pipe" },
    );
    await writeFile(
      path.join(consumer, "consumer.tsx"),
      `import {SceneView,loadSceneProject,type SceneProject} from 'sceneweaver-react';\nconst project: SceneProject={version:1,name:'Consumer',settings:{hour:18,weather:'clear',ground:36,aspectRatio:1.5,overscan:1.12,viewport:1.5,motion:true,schedule:[5,6,12,15,18,19.5]},layers:[]};\nconst view=<SceneView project={project} hour="local" weather="rain" paused label="Landscape"><button>Open book</button></SceneView>;\nconst json={version:1,settings:{weather:'clear'},layers:[]}; const fromJSON=<SceneView project={json}/>;\nconst loaded=loadSceneProject(project);\nvoid [view,fromJSON,loaded];\n`,
    );
    execFileSync(
      path.join(root, "node_modules/.bin/tsc"),
      [
        "--noEmit",
        "--strict",
        "--module",
        "NodeNext",
        "--moduleResolution",
        "NodeNext",
        "--jsx",
        "react-jsx",
        "--target",
        "ES2020",
        "consumer.tsx",
      ],
      { cwd: consumer, stdio: "pipe" },
    );
    execFileSync(
      process.execPath,
      [
        "--input-type=module",
        "-e",
        `import{SceneView}from'sceneweaver-react';import{createElement}from'react';import{renderToString}from'react-dom/server';const html=renderToString(createElement(SceneView,{project:'/scene.json',label:'Packed scene'}));if(!html.includes('Packed scene'))throw Error('Packed SSR failed');`,
      ],
      { cwd: consumer, stdio: "pipe" },
    );
    console.log(
      `PASS packed-package install, public exports, TypeScript and SSR with React ${version}`,
    );
  }
} finally {
  await rm(temporary, { recursive: true, force: true });
}
