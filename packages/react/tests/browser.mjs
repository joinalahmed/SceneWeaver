import { createRequire } from "node:module";
import { mkdir } from "node:fs/promises";
import assert from "node:assert/strict";
const require = createRequire(import.meta.url),
  { chromium } = require(process.env.PLAYWRIGHT_MODULE || "playwright");
const origin = process.env.REACT_TEST_ORIGIN || "http://127.0.0.1:5173";
const output = process.env.REACT_TEST_OUTPUT || "/tmp/sceneweaver-react-tests";
await mkdir(output, { recursive: true });
const browser = await chromium.launch({ headless: true });
try {
  const page = await browser.newPage({
      viewport: { width: 1100, height: 800 },
    }),
    errors = [];
  page.on("pageerror", (e) => errors.push(e.message));
  page.on("console", (m) => {
    if (["error", "warning"].includes(m.type())) errors.push(m.text());
  });
  await page.goto(`${origin}/packages/react/build/browser/`);
  await page.locator('[data-scene-state="ready"]').waitFor();
  await page.waitForTimeout(200);
  assert.equal(
    await page.evaluate(() => window.sceneTest.metrics.ready),
    1,
    "StrictMode must not deliver stale ready callbacks.",
  );
  assert.equal(
    await page.evaluate(() => window.sceneTest.metrics.frames.size),
    1,
    "Only one animation loop may be active.",
  );
  const pixel = () => page.locator("canvas").evaluate((c) => c.toDataURL());
  await page.evaluate(() => {
    window.sceneTest.setHour(22);
    window.sceneTest.setPaused(true);
  });
  await page.waitForTimeout(150);
  const night = await pixel();
  await page.waitForTimeout(150);
  assert.equal(
    await pixel(),
    night,
    "Paused motion must render a stable rest pose.",
  );
  await page.evaluate(() => window.sceneTest.setHour(10));
  await page.waitForTimeout(150);
  assert.notEqual(
    await pixel(),
    night,
    "Controlled time must update the rendered sky.",
  );
  assert.equal(
    await page.evaluate(() => window.sceneTest.metrics.ready),
    1,
    "Time and pause updates must not reload assets.",
  );
  await page.evaluate(() => window.sceneTest.setWeather("rain"));
  await page.waitForTimeout(100);
  await page.locator("#overlay-button").click();
  await page.setViewportSize({ width: 390, height: 844 });
  await page.waitForTimeout(150);
  assert.equal(
    await page.locator("canvas").evaluate((c) => c.width),
    390,
    "Canvas must resize to its CSS dimensions.",
  );
  await page.route("**/slow-project.json", async (route) => {
    await new Promise((r) => setTimeout(r, 250));
    try {
      await route.fulfill({ json: { version: 2 } });
    } catch {
      /* Request was intentionally aborted. */
    }
  });
  await page.evaluate(() => window.sceneTest.setSource("/slow-project.json"));
  await page.waitForTimeout(30);
  await page.evaluate(() =>
    window.sceneTest.setSource("/studio/assets/harbor.json"),
  );
  await page.waitForFunction(() => window.sceneTest.metrics.ready === 2);
  await page.waitForTimeout(300);
  assert.deepEqual(
    await page.evaluate(() => window.sceneTest.metrics.errors),
    [],
    "An aborted stale scene must not become a visible error.",
  );
  await page.evaluate(() => window.sceneTest.setSource({ version: 2 }));
  await page.getByRole("alert").waitFor();
  assert.equal(
    await page.evaluate(() => window.sceneTest.metrics.errors.length),
    1,
  );
  await page.evaluate(() =>
    window.sceneTest.setSource("/studio/assets/alpine.json"),
  );
  await page.waitForFunction(() => window.sceneTest.metrics.ready === 3);
  await page.emulateMedia({ reducedMotion: "reduce" });
  await page.evaluate(() => window.sceneTest.setPaused(false));
  await page.waitForTimeout(150);
  const reduced = await pixel();
  await page.waitForTimeout(150);
  assert.equal(
    await pixel(),
    reduced,
    "System Reduce Motion must freeze ambient animation.",
  );
  await page.evaluate(() => window.sceneTest.setMounted(false));
  await page.locator("canvas").waitFor({ state: "detached" });
  await page.waitForTimeout(100);
  assert.equal(
    await page.evaluate(() => window.sceneTest.metrics.frames.size),
    0,
    "Unmount must cancel every scheduled Canvas frame.",
  );
  await page.evaluate(() => window.sceneTest.setMounted(true));
  await page.waitForFunction(() => window.sceneTest.metrics.ready === 4);
  assert.equal(
    await page.evaluate(() => window.sceneTest.metrics.frames.size),
    1,
  );
  assert.deepEqual(errors, []);
  const demo = await browser.newPage({
    viewport: { width: 1440, height: 1000 },
  });
  demo.on("pageerror", (e) => errors.push(e.message));
  await demo.goto(`${origin}/studio/react/`);
  await demo.locator('[data-scene-state="ready"]').waitFor();
  await demo.waitForTimeout(200);
  await demo.screenshot({
    path: `${output}/react-playground.png`,
    fullPage: true,
  });
  await demo.setViewportSize({ width: 375, height: 812 });
  await demo.screenshot({ path: `${output}/react-mobile.png`, fullPage: true });
  assert.ok(
    await demo.evaluate(
      () => document.documentElement.scrollWidth <= innerWidth,
    ),
  );
  assert.deepEqual(errors, []);
  console.log(
    "PASS React StrictMode lifecycle, controlled updates, asset loading, stale-request cancellation, error recovery, resizing, overlays, Reduce Motion and unmount cleanup.",
  );
} finally {
  await browser.close();
}
