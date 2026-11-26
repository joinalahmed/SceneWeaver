import test from "node:test";
import assert from "node:assert/strict";
import { createElement } from "react";
import { renderToString } from "react-dom/server";
import { SceneView } from "../dist/index.js";
const project = {
  version: 1,
  name: "SSR",
  settings: {
    hour: 18,
    weather: "clear",
    ground: 36,
    aspectRatio: 1.5,
    overscan: 1.12,
    viewport: 1.5,
    motion: true,
    schedule: [5, 6, 12, 15, 18, 19.5],
  },
  layers: [],
};
test("server rendering requires no DOM, image decoder or browser globals", () => {
  assert.equal(typeof document, "undefined");
  const html = renderToString(
    createElement(
      SceneView,
      {
        project,
        label: "An alpine landscape",
        className: "hero",
        hour: "local",
      },
      createElement("h2", null, "Continue reading"),
    ),
  );
  assert.match(html, /aria-label="An alpine landscape"/);
  assert.match(html, /Continue reading/);
  assert.match(html, /aspect-ratio:1.5/);
  assert.match(html, /data-scene-state="loading"/);
});
test("an unlabeled scene is decorative and renders its loading fallback", () => {
  const html = renderToString(
    createElement(SceneView, {
      project,
      fallback: createElement("p", null, "Preparing landscape"),
    }),
  );
  assert.match(html, /aria-hidden="true"/);
  assert.match(html, /Preparing landscape/);
});
test("invalid runtime input does not crash SSR before client-side validation", () => {
  assert.doesNotThrow(() =>
    renderToString(createElement(SceneView, { project: null })),
  );
});
