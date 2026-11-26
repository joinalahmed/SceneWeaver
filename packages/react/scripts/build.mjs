import { build } from "esbuild";
import { execFileSync } from "node:child_process";
import { cp, mkdir, rm, readFile, writeFile } from "node:fs/promises";
import { fileURLToPath } from "node:url";
import path from "node:path";
const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
await rm(path.join(root, "dist"), { recursive: true, force: true });
await rm(path.join(root, "build"), { recursive: true, force: true });
await mkdir(path.join(root, "dist"), { recursive: true });
execFileSync(
  path.join(root, "node_modules/.bin/tsc"),
  ["--project", path.join(root, "tsconfig.json")],
  { cwd: root, stdio: "inherit" },
);
await build({
  entryPoints: [path.join(root, "src/index.tsx")],
  outfile: path.join(root, "dist/index.js"),
  bundle: true,
  format: "esm",
  platform: "browser",
  target: "es2020",
  jsx: "automatic",
  external: ["react", "react/*"],
  banner: { js: '"use client";' },
  sourcemap: true,
});
for (const name of ["index", "load-project", "types", "library", "pen"])
  await cp(
    path.join(root, `build/types/packages/react/src/${name}.d.ts`),
    path.join(root, `dist/${name}.d.ts`),
  );
await cp(path.join(root, "../../LICENSE"), path.join(root, "LICENSE"));
console.log(
  "Built React component, shared renderer and TypeScript declarations.",
);

await writeFile(path.join(root,"THIRD_PARTY_NOTICES.txt"), await readFile(path.join(root,"../../studio/assets/runtime/WASI-LICENSE-MIT.txt"),"utf8"));
