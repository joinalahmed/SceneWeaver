// Run against a local Studio server. PLAYWRIGHT_MODULE can point at an existing
// Playwright installation; otherwise install Playwright in your development environment.
import { createRequire } from "node:module";
import { mkdir, readFile, writeFile } from "node:fs/promises";
import assert from "node:assert/strict";
const require = createRequire(import.meta.url);
const { chromium } = require(process.env.PLAYWRIGHT_MODULE || "playwright");
const output =
  process.env.STUDIO_TEST_OUTPUT || "/tmp/sceneweaver-studio-tests";
await mkdir(output, { recursive: true });
const browser = await chromium.launch({ headless: true });
try {
  const page = await browser.newPage({
    viewport: { width: 1440, height: 1000 },
    acceptDownloads: true,
  });
  const errors = [];
  page.on("pageerror", (e) => errors.push(e.message));
  page.on("console", (m) => {
    if (["error", "warning"].includes(m.type())) errors.push(m.text());
  });
  page.on("response", (r) => {
    if (r.status() >= 400) errors.push(`HTTP ${r.status()}: ${r.url()}`);
  });
  await page.goto(process.env.STUDIO_URL || "http://127.0.0.1:5173/studio/");
  await page.locator('[data-layer="alpine-cabin"]').waitFor();
  assert.equal(await page.locator(".layer").count(), 3);
  await page.locator('[data-layer="alpine-cabin"]').click();
  await page.locator('[data-hour="22"]').click();
  await page.locator('[data-tool="lamp"]').click();
  const box = await page.locator("#stage").boundingBox();
  await page.mouse.click(box.x + box.width * 0.52, box.y + box.height * 0.7);
  assert.equal(await page.locator(".handle").count(), 5);
  const before = Number(await page.locator("#light-x").inputValue());
  const handle = await page.locator(".handle.selected").boundingBox();
  await page.mouse.move(
    handle.x + handle.width / 2,
    handle.y + handle.height / 2,
  );
  await page.mouse.down();
  await page.mouse.move(handle.x + 40, handle.y - 25, { steps: 5 });
  await page.mouse.up();
  assert.ok(Number(await page.locator("#light-x").inputValue()) > before);
  await page.locator("#layer-front").click();
  assert.equal(
    await page.locator(".layer").first().getAttribute("data-layer"),
    "alpine-cabin",
  );
  await page.locator("#weather").selectOption("rain");
  const save = page.waitForEvent("download");
  await page.locator("#save-project").click();
  const saved = await save;
  await saved.saveAs(`${output}/project.json`);
  const project = JSON.parse(await readFile(`${output}/project.json`, "utf8"));
  assert.equal(project.settings.weather, "rain");
  assert.equal(project.layers.at(-1).lights.length, 5);
  await page.locator("#view-code").click();
  assert.match(
    await page.locator("#swift-code").innerText(),
    /weather: \.rain/,
  );
  await page.locator("#close-code").click();
  const bundle = page.waitForEvent("download");
  await page.locator("#export").click();
  await (await bundle).saveAs(`${output}/export.zip`);
  await page.locator("#preset").selectOption("blank");
  await page.locator("#empty-state").waitFor({ state: "visible" });
  await page.locator("#project-input").setInputFiles(`${output}/project.json`);
  await page.locator('[data-layer="alpine-cabin"]').waitFor();
  assert.equal(await page.locator("#weather").inputValue(), "rain");
  // A fresh navigation restores locally saved, embedded artwork.
  await page.waitForTimeout(800);
  await page.reload();
  await page.locator('[data-layer="alpine-cabin"]').waitFor();
  assert.equal(await page.locator("#weather").inputValue(), "rain");
  // Import actual raster artwork, then remove it through the inspector.
  await page
    .locator("#image-input")
    .setInputFiles({
      name: "user-layer.png",
      mimeType: "image/png",
      buffer: Buffer.from(
        "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQIHWP4z8DwHwAFgAI/ScLbtAAAAABJRU5ErkJggg==",
        "base64",
      ),
    });
  await page.waitForFunction(
    () => document.querySelectorAll(".layer").length === 4,
  );
  await page.locator("#delete-layer").click();
  assert.equal(await page.locator(".layer").count(), 3);
  await page.locator("#preset").selectOption("harbor");
  await page.locator('[data-layer="harbor-lighthouse"]').waitFor();
  await page.locator("#play").click();
  await page.screenshot({ path: `${output}/desktop.png`, fullPage: true });
  await page.setViewportSize({ width: 390, height: 844 });
  await page.locator("#viewport").selectOption("0.5625");
  await page.screenshot({ path: `${output}/mobile.png`, fullPage: true });
  assert.ok(
    await page.evaluate(
      () => document.documentElement.scrollWidth <= window.innerWidth,
    ),
  );
  await page.locator("#preset").selectOption("alpine");
  await page.locator('[data-layer="alpine-cabin"]').waitFor();
  await page.setViewportSize({ width: 1440, height: 1000 });
  await page.locator('[data-layer="alpine-cabin"]').click();
  await page.waitForTimeout(6000);
  for (const [width, height] of [
    [375, 812],
    [768, 1024],
    [1440, 900],
  ]) {
    await page.setViewportSize({ width, height });
    await page.waitForTimeout(250);
    const stage = await page.locator("#stage").boundingBox();
    assert.ok(
      Math.abs(stage.width / stage.height - 1.5) < 0.01,
      "The selected artboard ratio must survive resizing.",
    );
    assert.ok(
      await page.evaluate(
        () => document.documentElement.scrollWidth <= innerWidth,
      ),
      `Overflow at ${width}px`,
    );
    assert.equal(await page.getByRole("heading", { level: 1 }).count(), 1);
    await writeFile(
      `${output}/accessibility-${width}.txt`,
      await page.locator("body").ariaSnapshot(),
    );
    await page.screenshot({
      path: `${output}/verified-${width}.png`,
      fullPage: true,
    });
  }
  await page.screenshot({ path: `${output}/studio.png`, fullPage: true });
  assert.deepEqual(errors, []);
  console.log(
    `PASS browser composition, light placement and drag, reorder, project round trip, persistence, artwork import, ZIP export and mobile layout. Artifacts: ${output}`,
  );
} finally {
  await browser.close();
}
