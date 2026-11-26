import { build } from "esbuild";
import { mkdir, cp, readFile, writeFile } from "node:fs/promises";
import { fileURLToPath } from "node:url";
import path from "node:path";
const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), ".."),
  out = path.join(root, "../../studio/react");
await mkdir(out, { recursive: true });
await build({
  entryPoints: [path.join(root, "example/App.tsx")],
  outfile: path.join(out, "app.js"),
  bundle: true,
  format: "esm",
  jsx: "automatic",
  minify: true,
  define: { "process.env.NODE_ENV": '"production"' },
  legalComments: "eof",
});
for (const name of ["index.html", "example.css"])
  await cp(path.join(root, "example", name), path.join(out, name));
const notices = await Promise.all(
  ["react", "react-dom", "scheduler"].map(
    async (name) =>
      `${name}\n\n${await readFile(path.join(root, "node_modules", name, "LICENSE"), "utf8")}`,
  ),
);
await writeFile(
  path.join(out, "THIRD_PARTY_LICENSES.txt"),
  notices.join("\n\n"),
);
const tests = path.join(root, "build/browser");
await mkdir(tests, { recursive: true });
await build({
  entryPoints: [path.join(root, "tests/fixture.tsx")],
  outfile: path.join(tests, "fixture.js"),
  bundle: true,
  format: "esm",
  jsx: "automatic",
  define: { "process.env.NODE_ENV": '"development"' },
});
await writeFile(
  path.join(tests, "index.html"),
  '<!doctype html><html lang="en"><head><meta charset="utf-8"><title>React lifecycle tests</title><link rel="icon" href="data:,"></head><body style="margin:0"><div id="root"></div><script type="module" src="fixture.js"></script></body></html>',
);
console.log("Built React playground and StrictMode browser fixture.");
