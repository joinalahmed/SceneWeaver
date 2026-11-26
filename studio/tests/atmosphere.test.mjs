import test from "node:test";
import assert from "node:assert/strict";
import {
  sunPoint,
  groundColor,
  drawWeather,
  OVERCAST,
} from "../atmosphere.mjs";
import { DEFAULT_SCHEDULE, skyAt, mix } from "../model.mjs";

test("native sun curve crosses the horizon at sunrise and sunset, with a 114-point apex", () => {
  const width = 660,
    horizon = 400;
  const rise = sunPoint(width, horizon, 6, DEFAULT_SCHEDULE);
  const noon = sunPoint(width, horizon, 12, DEFAULT_SCHEDULE);
  const set = sunPoint(width, horizon, 18, DEFAULT_SCHEDULE);
  assert.equal(rise.y, horizon);
  assert.equal(set.y, horizon);
  assert.equal(noon.y, 286);
  assert.ok(Math.abs(rise.x - (18 + 624 / 14.5)) < 1e-9);
  assert.ok(rise.x < noon.x && noon.x < set.x);
  assert.ok(sunPoint(width, horizon, 5, DEFAULT_SCHEDULE).y > horizon);
});
test("short winter and long summer schedules still meet both horizon crossings", () => {
  for (const dates of [
    [6, 8, 12, 14, 16, 18],
    [2, 4, 12, 16, 22, 23],
  ]) {
    for (const hour of [dates[1], dates[4]])
      assert.ok(Math.abs(sunPoint(402, 300, hour, dates).y - 300) < 1e-9);
    assert.equal(sunPoint(402, 300, (dates[1] + dates[4]) / 2, dates).y, 186);
  }
});
test("ground follows native daylight/weather palette instead of a fixed dark band", () => {
  assert.deepEqual(groundColor([0.07, 0.1, 0.23], 1, 0, 0), [0.07, 0.07, 0.08]);
  const sky = skyAt(12),
    expected = mix(
      [0.07, 0.07, 0.08],
      mix([0.16, 0.23, 0.31], sky.low, 0.12),
      0.75,
    );
  assert.deepEqual(groundColor(sky.low, 0, 0, 0), expected);
  assert.notDeepEqual(groundColor(sky.low, 0, 0, OVERCAST.rain), expected);
});
function context() {
  return {
    strokes: [],
    fills: [],
    beginPath() {},
    moveTo() {},
    lineTo() {},
    arc() {},
    fill() {
      this.fills.push(this.fillStyle);
    },
    stroke() {
      this.strokes.push(this.strokeStyle);
    },
    fillRect() {
      this.fills.push(this.fillStyle);
    },
  };
}
test("precipitation matches native particle counts and fades out below the horizon", () => {
  for (const [weather, count] of [
    ["clear", 0],
    ["drizzle", 40],
    ["rain", 90],
    ["thunderstorm", 130],
    ["snow", 70],
  ]) {
    const ctx = context();
    drawWeather(ctx, 660, 440, { ground: 36, weather }, 10, false);
    assert.equal(ctx.strokes.length + ctx.fills.length, count);
    if (count) {
      const alphas = [...ctx.strokes, ...ctx.fills].map((s) =>
        Number(s.match(/,([^,]+)\)$/)[1]),
      );
      assert.ok(alphas.some((a) => a === 0));
      assert.ok(alphas.some((a) => a > 0));
    }
  }
});
test("storm bolts use the native 7.5-second double pulse and respect reduced motion", () => {
  const paused = context(),
    active = context(),
    quiet = context();
  drawWeather(
    paused,
    660,
    440,
    { ground: 36, weather: "thunderstorm" },
    7.55,
    false,
  );
  drawWeather(
    active,
    660,
    440,
    { ground: 36, weather: "thunderstorm" },
    7.55,
    true,
  );
  drawWeather(
    quiet,
    660,
    440,
    { ground: 36, weather: "thunderstorm" },
    8.5,
    true,
  );
  assert.equal(paused.strokes.length, 130);
  assert.equal(quiet.strokes.length, 130);
  assert.equal(active.strokes.length, 131);
  assert.equal(active.fills.length, 1);
});
