import test from "node:test";
import assert from "node:assert/strict";
import { createAnimationClock } from "../playback.mjs";
test("pause retains the current frame and resume excludes time spent paused", () => {
  const time = createAnimationClock();
  assert.equal(time(1000, true), 0);
  assert.equal(time(3000, true), 2);
  assert.equal(time(3050, false), 2);
  assert.equal(time(60000, false), 2);
  assert.equal(time(60050, true), 2);
  assert.equal(time(61050, true), 3);
});
test("initially paused scenes start at rest and reduced motion resets animation", () => {
  const time = createAnimationClock();
  assert.equal(time(1000, false), 0);
  assert.equal(time(3000, true), 0);
  assert.equal(time(5000, true), 2);
  assert.equal(time(6000, true, true), 0);
  assert.equal(time(7000, true, true), 0);
  assert.equal(time(8000, true), 0);
  assert.equal(time(9000, true), 1);
});

test("day-cycle preview advances, wraps midnight and stays in project bounds", async () => {
  const { advanceDayHour } = await import("../playback.mjs");
  assert.equal(advanceDayHour(10, 2500), 11);
  assert.equal(advanceDayHour(23, 5000), 1);
  assert.equal(advanceDayHour(10, 0), 10);
  assert.equal(advanceDayHour(10, -100), 10);
  assert.ok(advanceDayHour(23.99, 1) <= 23.99);
});
