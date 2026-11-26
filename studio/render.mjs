import { artworkRect, skyAt, mix, ramp, clamp } from "./model.mjs";
const rgb = (v, a = 1) =>
  `rgba(${v.map((x) => Math.round(clamp(x, 0, 1) * 255)).join(",")},${a})`;
const noise = (i, s) => {
  const v = Math.sin(i * 12.9898 + s * 78.233) * 43758.5453;
  return v - Math.floor(v);
};
const overcast = {
  clear: 0,
  partlyCloudy: 0.18,
  cloudy: 0.55,
  fog: 0.62,
  drizzle: 0.55,
  rain: 0.68,
  snow: 0.55,
  thunderstorm: 0.82,
};
export function createRenderer(canvas, getProject, getImages, onFrame) {
  const ctx = canvas.getContext("2d"),
    material = document.createElement("canvas"),
    m = material.getContext("2d");
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
      sky = skyAt(s.hour, s.schedule),
      cloud = overcast[s.weather];
    const grey = mix([0.17, 0.19, 0.23], [0.06, 0.07, 0.09], sky.darkness),
      top = mix(sky.top, grey, cloud),
      low = mix(sky.low, grey, cloud);
    const grad = ctx.createLinearGradient(0, 0, 0, horizon);
    grad.addColorStop(0, rgb(top));
    grad.addColorStop(1, rgb(low));
    ctx.fillStyle = grad;
    ctx.fillRect(0, 0, w, h);
    if (sky.darkness > 0.3) {
      for (let i = 0; i < 110; i++) {
        ctx.globalAlpha =
          ramp(sky.darkness, 0.3, 0.9) *
          (1 - cloud) *
          (0.3 + noise(i, 6) * 0.7) *
          (0.85 + 0.15 * Math.sin(time * 0.6 + i));
        ctx.fillStyle = "#e9ebed";
        ctx.beginPath();
        ctx.arc(
          noise(i, 2) * w,
          noise(i, 3) * Math.max(0, horizon - 30),
          0.45 + noise(i, 4),
          0,
          Math.PI * 2,
        );
        ctx.fill();
      }
      ctx.globalAlpha = 1;
    }
    function halo(x, y, r, color) {
      const g = ctx.createRadialGradient(x, y, 0, x, y, r);
      g.addColorStop(0, color);
      g.addColorStop(1, "transparent");
      ctx.fillStyle = g;
      ctx.fillRect(x - r, y - r, r * 2, r * 2);
    }
    const [_, rise, , , set] = s.schedule;
    if (s.hour >= rise && s.hour <= set && cloud < 0.7) {
      const phase = (s.hour - rise) / (set - rise),
        x = w * (0.12 + phase * 0.76),
        y = horizon - 45 - Math.sin(phase * Math.PI) * Math.min(h * 0.55, 180);
      halo(x, y, 45, `rgba(255,208,116,${0.25 * (1 - cloud)})`);
      ctx.fillStyle = "#ffd37e";
      ctx.beginPath();
      ctx.arc(x, y, 10, 0, Math.PI * 2);
      ctx.fill();
    }
    if (sky.darkness > 0.6) {
      const x = w * 0.82,
        y = Math.max(30, h * 0.2);
      halo(x, y, 42, `rgba(212,220,244,${sky.darkness * 0.12})`);
      ctx.fillStyle = `rgba(247,239,201,${sky.darkness})`;
      ctx.beginPath();
      ctx.arc(x, y, 13, 0, Math.PI * 2);
      ctx.fill();
      ctx.fillStyle = rgb(mix(top, low, y / horizon));
      ctx.beginPath();
      ctx.arc(x + 6, y - 4, 12, 0, Math.PI * 2);
      ctx.fill();
    }
    if (cloud > 0 || s.weather === "clear") {
      for (let i = 0; i < (cloud > 0.3 ? 8 : 3); i++) {
        const x = ((noise(i, 91) * w + time * (3 + i)) % (w + 200)) - 100,
          y = h * (0.12 + noise(i, 92) * 0.26);
        ctx.fillStyle = `rgba(200,210,211,${(0.035 + cloud * 0.13) * (1 - sky.darkness * 0.6)})`;
        ctx.beginPath();
        ctx.ellipse(x, y, 50 + i * 8, 9 + i * 2, 0, 0, Math.PI * 2);
        ctx.fill();
      }
    }
    const floor = ctx.createLinearGradient(0, horizon - 32, 0, h);
    floor.addColorStop(0, "transparent");
    floor.addColorStop(32 / (s.ground + 32), "#111c25");
    floor.addColorStop(1, "#070d13");
    ctx.fillStyle = floor;
    ctx.fillRect(0, horizon - 32, w, s.ground + 32);
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
        m.globalCompositeOperation = "multiply";
        m.fillStyle = rgb([
          1 - dark * dim,
          1 - dark * (dim - 0.025) - glow * 0.025,
          1 - dark * (dim - 0.12) - glow * 0.065,
        ]);
        m.fillRect(0, 0, pw, ph);
        m.globalCompositeOperation = "destination-in";
        m.drawImage(image, 0, 0, pw, ph);
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
    const ground = ctx.createLinearGradient(0, horizon, 0, h);
    ground.addColorStop(0, "transparent");
    ground.addColorStop(1, "#070d13");
    ctx.fillStyle = ground;
    ctx.fillRect(0, horizon, w, s.ground);
    if (["drizzle", "rain", "snow", "thunderstorm"].includes(s.weather)) {
      const snow = s.weather === "snow",
        count = s.weather === "drizzle" ? 50 : 130;
      ctx.strokeStyle = "rgba(207,226,239,.38)";
      ctx.fillStyle = "rgba(233,242,245,.7)";
      ctx.lineWidth = 0.7;
      for (let i = 0; i < count; i++) {
        const x = (noise(i, 81) * w - time * (snow ? 5 : 40) + w * 100) % w,
          y = (noise(i, 82) * h + time * (snow ? 17 : 280)) % h;
        if (snow) {
          ctx.beginPath();
          ctx.arc(
            x + Math.sin(i + time * 0.4) * 5,
            y,
            1 + noise(i, 9),
            0,
            Math.PI * 2,
          );
          ctx.fill();
        } else {
          ctx.beginPath();
          ctx.moveTo(x, y);
          ctx.lineTo(x - 3, y + 11);
          ctx.stroke();
        }
      }
    }
    if (s.weather === "fog") {
      ctx.fillStyle = "rgba(168,184,186,.20)";
      ctx.fillRect(0, h * 0.45, w, h * 0.55);
    }
    if (moving && s.weather === "thunderstorm" && time % 11 < 0.12) {
      ctx.fillStyle = "rgba(216,225,255,.32)";
      ctx.fillRect(0, 0, w, h);
    }
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
