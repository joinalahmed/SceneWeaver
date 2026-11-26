import { artworkRect, skyAt, ramp } from "./model.mjs";
import { drawAtmosphere, drawWeather, rgba as rgb } from "./atmosphere.mjs";
export function createRenderer(canvas, getProject, getImages, onFrame) {
  const ctx = canvas.getContext("2d"),
    material = document.createElement("canvas"),
    m = material.getContext("2d", { willReadFrequently: true });
  if (!ctx || !m) throw new Error("Canvas 2D is unavailable in this browser.");
  const plates = new Map();
  let raf,
    start = performance.now(),
    last = 0,
    frozen = 0,
    wasMoving = true;
  const reduced = matchMedia("(prefers-reduced-motion: reduce)");
  function frame(ms) {
    raf = requestAnimationFrame(frame);
    if (ms - last < 40) return;
    last = ms;
    const p = getProject();
    if (!p) return;
    const bounds = canvas.getBoundingClientRect(),
      w = bounds.width,
      h = bounds.height,
      dpr = Math.min(devicePixelRatio || 1, 2);
    if (!w || !h) return;
    if (
      canvas.width !== Math.round(w * dpr) ||
      canvas.height !== Math.round(h * dpr)
    ) {
      canvas.width = Math.round(w * dpr);
      canvas.height = Math.round(h * dpr);
    }
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    ctx.clearRect(0, 0, w, h);
    const moving = p.settings.motion && !reduced.matches;
    if (moving && !wasMoving) start = ms - frozen * 1000;
    const time = moving ? (ms - start) / 1000 : 0;
    if (moving) frozen = time;
    wasMoving = moving;
    const s = p.settings,
      horizon = h - s.ground,
      sky = skyAt(s.hour, s.schedule);
    drawAtmosphere(ctx, w, h, s, sky, time, moving);
    function halo(x, y, r, color) {
      const g = ctx.createRadialGradient(x, y, 0, x, y, r);
      g.addColorStop(0, color);
      g.addColorStop(1, "transparent");
      ctx.fillStyle = g;
      ctx.fillRect(x - r, y - r, r * 2, r * 2);
    }
    const motion = moving ? Math.sin(time * 0.06) : 0,
      rects = new Map();
    for (const layer of p.layers) {
      const rect = artworkRect(w, horizon, s, motion, layer.depth);
      rects.set(layer.id, rect);
      if (!layer.visible) continue;
      const image = getImages().get(layer.id);
      if (!image) continue;
      const key = JSON.stringify([
        layer.dim,
        layer.lights.filter((l) => l.type === "flood"),
        sky.darkness,
        sky.glow,
      ]);
      let cache = plates.get(layer.id);
      if (!cache || cache.key !== key || cache.image !== image) {
        const pw = Math.min(1600, image.naturalWidth),
          ph = Math.round((pw / image.naturalWidth) * image.naturalHeight);
        material.width = pw;
        material.height = ph;
        m.clearRect(0, 0, pw, ph);
        m.drawImage(image, 0, 0, pw, ph);
        const dim = layer.dim,
          dark = sky.darkness,
          glow = sky.glow;
        // A diagonal color matrix matches SwiftUI's colorMultiply filter,
        // preserving the plate's alpha (including antialiased edges).
        const pixels = m.getImageData(0, 0, pw, ph);
        const tint = [
          1 - dark * dim,
          1 - dark * (dim - 0.025) - glow * 0.025,
          1 - dark * (dim - 0.12) - glow * 0.065,
        ];
        for (let i = 0; i < pixels.data.length; i += 4)
          for (let c = 0; c < 3; c++) pixels.data[i + c] *= tint[c];
        m.putImageData(pixels, 0, 0);
        m.globalCompositeOperation = "source-atop";
        for (const light of layer.lights.filter((l) => l.type === "flood")) {
          const x = light.x * pw,
            y = light.y * ph,
            r = Math.max(1, light.radius * pw),
            g = m.createRadialGradient(x, y, 0, x, y, r);
          g.addColorStop(
            0,
            light.color +
              Math.round(ramp(dark, 0.15, 0.8) * light.intensity * 255)
                .toString(16)
                .padStart(2, "0"),
          );
          g.addColorStop(1, light.color + "00");
          m.fillStyle = g;
          m.fillRect(x - r, y - r, 2 * r, 2 * r);
        }
        const sun = m.createRadialGradient(
          pw * 0.22,
          ph * 0.35,
          0,
          pw * 0.22,
          ph * 0.35,
          pw * 0.8,
        );
        sun.addColorStop(0, `rgba(255,189,92,${glow * 0.18})`);
        sun.addColorStop(1, "transparent");
        m.fillStyle = sun;
        m.fillRect(0, 0, pw, ph);
        m.globalCompositeOperation = "source-over";
        const plate = document.createElement("canvas");
        plate.width = pw;
        plate.height = ph;
        plate.getContext("2d").drawImage(material, 0, 0);
        cache = { key, plate, image };
        plates.set(layer.id, cache);
      }
      ctx.drawImage(cache.plate, rect.x, rect.y, rect.width, rect.height);
      const on = ramp(sky.darkness, 0.12, 0.65);
      for (const light of layer.lights.filter((l) => l.type === "lamp")) {
        if (on < 0.001) continue;
        const x = rect.x + light.x * rect.width,
          y = rect.y + light.y * rect.height,
          r = Math.max(0.5, rect.width * light.radius);
        halo(
          x,
          y,
          r,
          light.color +
            Math.round(on * 0.65 * 255)
              .toString(16)
              .padStart(2, "0"),
        );
        ctx.fillStyle = `rgba(255,247,204,${on})`;
        ctx.beginPath();
        ctx.arc(x, y, Math.max(0.45, rect.width * 0.0012), 0, Math.PI * 2);
        ctx.fill();
      }
    }
    // Removed layers must release their cached image surfaces.
    for (const key of plates.keys())
      if (!p.layers.some((l) => l.id === key)) plates.delete(key);
    drawWeather(ctx, w, h, s, time, moving);
    onFrame({ rects, width: w, height: h, sky });
  }
  raf = requestAnimationFrame(frame);
  return {
    destroy() {
      cancelAnimationFrame(raf);
      plates.clear();
    },
  };
}
export async function decodeArtwork(data) {
  if (data.startsWith("data:image/svg+xml")) {
    const text = await (await fetch(data)).text();
    if (
      /<script|<foreignObject|<!DOCTYPE|<!ENTITY|\bon\w+\s*=|(?:href|src)\s*=\s*["'](?!#|data:)|url\(\s*["']?(?:https?:|\/\/)/i.test(
        text,
      )
    )
      throw Error(
        "SVG artwork must be self-contained, without scripts, external references or embedded HTML.",
      );
  }
  const img = new Image();
  img.src = data;
  await img.decode();
  if (img.naturalWidth * img.naturalHeight > 40000000)
    throw Error("Artwork exceeds 40 megapixels. Use a smaller image.");
  return img;
}
