import test from "node:test";
import assert from "node:assert/strict";
import { createElement } from "react";
import { renderToString } from "react-dom/server";
import { SceneView, SceneLibrary, ScenePen, ScenePath } from "../dist/index.js";
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

test("procedural definitions and the full library are SSR safe", () => {
  const view=renderToString(createElement(SceneView,{definition:{draw(pen){pen.block(0,20,30)}}}));
  assert.match(view,/data-scene-state="loading"/);
  const library=renderToString(createElement(SceneLibrary,{catalogURL:"/scenes/catalog.json",onSelect(){}}));
  assert.match(library,/Search/);
  const pen=new ScenePen({width:402,horizon:224});pen.at(100).block(0,20,30);
  assert.equal(pen.toGeometry().day.solids.length,1);
  assert.ok(new ScenePath().moveTo(0,0).lineTo(4,8).description.includes('L'));
});
