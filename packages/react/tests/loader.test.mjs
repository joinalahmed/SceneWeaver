import test from "node:test";
import assert from "node:assert/strict";
import { createServer } from "node:http";
import { loadSceneProject } from "../dist/index.js";
const settings = {
  hour: 18,
  weather: "clear",
  ground: 36,
  aspectRatio: 1.5,
  overscan: 1.12,
  viewport: 1.5,
  motion: true,
  schedule: [5, 6, 12, 15, 18, 19.5],
};
const svg =
  '<svg xmlns="http://www.w3.org/2000/svg" width="30" height="20" viewBox="0 0 30 20"><path d="M0 10h30v10H0Z" fill="green"/></svg>';
const embedded = {
  version: 1,
  name: "Embedded",
  settings,
  layers: [
    {
      id: "art",
      name: "Artwork",
      visible: true,
      depth: 1,
      dim: 0.46,
      asset: {
        name: "Art",
        data:
          "data:image/svg+xml;base64," + Buffer.from(svg).toString("base64"),
      },
      lights: [],
    },
  ],
};
test("embedded projects validate without browser globals or network and remain immutable", async () => {
  const before = structuredClone(embedded),
    result = await loadSceneProject(embedded);
  assert.deepEqual(result, before);
  assert.deepEqual(embedded, before);
  assert.notEqual(result, embedded);
});
test("invalid project structure and aborted loads reject predictably", async () => {
  await assert.rejects(loadSceneProject({ version: 2 }), /version 1/);
  const controller = new AbortController();
  controller.abort();
  await assert.rejects(
    loadSceneProject(embedded, { signal: controller.signal }),
    { name: "AbortError" },
  );
});
test("project URLs resolve assets relative to the project document, report HTTP failures, and cancel", async (t) => {
  const project = structuredClone(embedded);
  project.layers[0].asset = { name: "Art", src: "images/art.svg" };
  const server = createServer((req, res) => {
    if (req.url === "/scenes/project.json") {
      res.setHeader("Content-Type", "application/json");
      res.end(JSON.stringify(project));
    } else if (req.url === "/scenes/images/art.svg") {
      res.setHeader("Content-Type", "image/svg+xml");
      res.end(svg);
    } else if (req.url === "/slow") {
      const timer = setTimeout(() => res.end("{}"), 5000);
      req.on("close", () => clearTimeout(timer));
    } else {
      res.statusCode = 404;
      res.end("missing");
    }
  });
  await new Promise((resolve) => server.listen(0, "127.0.0.1", resolve));
  t.after(() => {
    server.closeAllConnections();
    server.close();
  });
  const base = `http://127.0.0.1:${server.address().port}`;
  const result = await loadSceneProject(`${base}/scenes/project.json`);
  assert.equal(result.layers[0].asset.data, embedded.layers[0].asset.data);
  const rootRelative = structuredClone(project);
  rootRelative.layers[0].asset.src = "/scenes/images/art.svg";
  assert.deepEqual(
    await loadSceneProject(rootRelative, { baseURL: base }),
    result,
  );
  await assert.rejects(loadSceneProject(`${base}/missing.json`), /HTTP 404/);
  const controller = new AbortController();
  const loading = loadSceneProject(`${base}/slow`, {
    signal: controller.signal,
  });
  controller.abort();
  await assert.rejects(loading, { name: "AbortError" });
});
test("non-HTTP source URLs are rejected", async () => {
  await assert.rejects(
    loadSceneProject("javascript:alert(1)"),
    /HTTP or HTTPS/,
  );
});
