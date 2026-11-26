import test from "node:test";
import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import {
  blankProject,
  validateProject,
  artworkRect,
  reorder,
  skyAt,
} from "../model.mjs";
import { generateSwift, zipFiles } from "../export.mjs";
const data = "data:image/png;base64,iVBORw0KGgo=";
function fixture() {
  const p = blankProject();
  p.layers = [
    {
      id: "base",
      name: "Cabin",
      visible: true,
      depth: 1.3,
      dim: 0.46,
      asset: { name: "Cabin", data },
      lights: [
        {
          id: "light",
          type: "lamp",
          x: 0.3,
          y: 0.5,
          radius: 0.012,
          intensity: 0.34,
          color: "#ffd78a",
        },
        {
          id: "flood",
          type: "flood",
          x: 0.7,
          y: 0.8,
          radius: 0.17,
          intensity: 0.4,
          color: "#ffc76b",
        },
      ],
    },
    {
      id: "front",
      name: "Trees",
      visible: true,
      depth: 2.4,
      dim: 0.25,
      asset: { name: "Trees", data },
      lights: [],
    },
  ];
  return p;
}
test("project round trip preserves order, lighting, assets and schedule", () => {
  const p = fixture();
  assert.deepEqual(validateProject(JSON.parse(JSON.stringify(p))), p);
});
test("untrusted projects cannot bypass bounds, IDs, asset names or ordered dates", () => {
  for (const mutate of [
    (p) => (p.settings.schedule[1] = 4),
    (p) => (p.settings.hour = NaN),
    (p) => (p.layers[0].lights[0].x = 1.2),
    (p) => (p.layers[0].asset.name = "bad/name"),
    (p) => (p.layers[1].id = "base"),
    (p) => (p.layers[1].asset.name = "cabin"),
    (p) =>
      (p.layers[0].asset = {
        name: "Cabin",
        src: "https://example.com/art.png",
      }),
  ]) {
    const p = fixture();
    mutate(p);
    assert.throws(() => validateProject(p));
  }
});
test("artwork stays anchored and covers both sides under depth motion", () => {
  for (const width of [320, 402, 660, 1000])
    for (const motion of [-1, 0, 1])
      for (const depth of [0, 1, 3, 8]) {
        const r = artworkRect(
          width,
          500,
          { aspectRatio: 1.5, overscan: 1.12 },
          motion,
          depth,
        );
        assert.ok(r.x <= 0);
        assert.ok(r.x + r.width >= width);
        assert.ok(Math.abs(r.y + r.height - 500) < 1e-8);
      }
});
test("reordering preserves the authored objects and changes occlusion order", () => {
  const p = fixture(),
    layers = reorder(p.layers, 0, 1);
  assert.equal(layers[1], p.layers[0]);
  assert.equal(p.layers[0].id, "base");
});
test("Swift export keeps each lamp above its plate and below the next plate", () => {
  const swift = generateSwift(fixture());
  assert.ok(swift.indexOf('Image("Cabin")') < swift.indexOf("SceneLamp("));
  assert.ok(swift.indexOf("SceneLamp(") < swift.indexOf('Image("Trees")'));
  assert.match(swift, /ArtworkLight\(x: 0.7, y: 0.8/);
  assert.match(swift, /schedule\(for: previewDate \?\? clock.date\)/);
});
test("hidden layers are omitted and preview playback does not override native accessibility", () => {
  const p = fixture();
  p.layers[1].visible = false;
  p.settings.motion = false;
  const swift = generateSwift(p);
  assert.ok(!swift.includes('Image("Trees")'));
  assert.ok(!swift.includes(".environment("));
});
test("empty scenes export a typed empty LayeredArtwork array", () => {
  assert.match(
    generateSwift(blankProject()),
    /LayeredArtwork\(layers: \[\s*\]/,
  );
});
test("daylight interpolation reaches day, dusk, and night endpoints", () => {
  assert.equal(skyAt(12).darkness, 0);
  assert.equal(skyAt(22).darkness, 1);
  assert.ok(skyAt(18).glow > 0.9);
  assert.equal(skyAt(6).darkness, 0.28);
});
test("ZIP preserves Unicode filenames and binary asset bytes", async () => {
  const bytes = new Uint8Array(
    await zipFiles([
      { name: "scène.png", data: new Uint8Array([0, 255, 12]) },
      { name: "View.swift", data: "import SwiftUI" },
    ]).arrayBuffer(),
  );
  const v = new DataView(bytes.buffer);
  assert.equal(v.getUint32(0, true), 0x04034b50);
  const nameLength = v.getUint16(26, true);
  assert.equal(
    new TextDecoder().decode(bytes.subarray(30, 30 + nameLength)),
    "scène.png",
  );
  assert.deepEqual(
    [...bytes.subarray(30 + nameLength, 33 + nameLength)],
    [0, 255, 12],
  );
  assert.equal(v.getUint16(bytes.length - 12, true), 2);
});
