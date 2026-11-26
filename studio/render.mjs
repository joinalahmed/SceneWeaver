import { renderNativeRuntime } from "./wasm-runtime.mjs";
import { ScenePen } from "./scene-pen.mjs";
import {
  drawClock,
  drawCrowd,
  drawFixture,
  drawReflections,
} from "./crowds.mjs";
import { drawTraffic } from "./incidental.mjs";
import { drawNativeScene, nativePalette } from "./native-scene.mjs";
import { artworkRect, skyAt, ramp, mix } from "./model.mjs?v=library-6";
import {
  drawAtmosphere,
  drawWeather,
  rgba as rgb,
  OVERCAST,
} from "./atmosphere.mjs?v=library-6";
import { drawWater, drawBoat } from "./water.mjs?v=library-6";
import { createAnimationClock } from "./playback.mjs";
export function createRenderer(
  canvas,
  getProject,
  getImages,
  onFrame,
  { referenceWidth, getDefinition } = {},
) {
  const ctx = canvas.getContext("2d"),
    material = document.createElement("canvas"),
    m = material.getContext("2d", { willReadFrequently: true });
  if (!ctx || !m) throw new Error("Canvas 2D is unavailable in this browser.");
  const plates = new Map();
  let raf,
    last = 0;
  const animationTime = createAnimationClock();
  const reduced = matchMedia("(prefers-reduced-motion: reduce)");
  const visibilityChanged = () =>
    animationTime(performance.now(), false, reduced.matches);
  document.addEventListener("visibilitychange", visibilityChanged);
  function frame(ms) {
    raf = requestAnimationFrame(frame);
    if (ms - last < 40) return;
    last = ms;
    const p = getProject();
    if (!p) return;
    const bounds = canvas.getBoundingClientRect(),
      scale = referenceWidth ? bounds.width / referenceWidth : 1,
      w = bounds.width / scale,
      h = bounds.height / scale,
      dpr = Math.min(devicePixelRatio || 1, 2);
    if (!w || !h) return;
    if (
      canvas.width !== Math.round(bounds.width * dpr) ||
      canvas.height !== Math.round(bounds.height * dpr)
    ) {
      canvas.width = Math.round(bounds.width * dpr);
      canvas.height = Math.round(bounds.height * dpr);
    }
    ctx.setTransform(dpr * scale, 0, 0, dpr * scale, 0, 0);
    ctx.clearRect(0, 0, w, h);
    const moving = !reduced.matches;
    const time = animationTime(
      ms,
      p.settings.motion && moving,
      reduced.matches,
    );
    const s = p.settings,
      horizon = h - s.ground,
      sky = skyAt(s.hour, s.schedule);
    const definition = getDefinition?.();
    const sceneOptions = definition ?? p.nativeScene?.data;
    const rtl = getComputedStyle(canvas).direction === "rtl";
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const grey = mix([0.17, 0.19, 0.23], [0.06, 0.07, 0.09], sky.darkness),
      skyLow = mix(sky.low, grey, OVERCAST[s.weather]);
    const palette = nativePalette(
      skyLow,
      sky.darkness,
      sky.glow,
      OVERCAST[s.weather],
      sceneOptions?.illustrated,
    );
    const nativeFrame = {
      size: { width: w, height: h },
      horizon,
      time,
      date: new Date(today.getTime() + s.hour * 3600000),
      darkness: sky.darkness,
      glow: sky.glow,
      motionEnabled: moving,
      rtl,
      layoutDirection: rtl ? "rtl" : "ltr",
      weather: s.weather,
      contentColor: rgb(mix(palette.landmark, skyLow, 0.16)),
    };
    drawAtmosphere(
      ctx,
      w,
      h,
      {
        ...s,
        ownMoon: sceneOptions?.ownMoon,
        wild: sceneOptions?.wild,
        illustrated: sceneOptions?.illustrated,
        rtl,
        reservedHeight: definition?.reservedHeight?.(w) ?? (s.reservedHeight ? w*s.reservedHeight.widthFactor+s.reservedHeight.offset : undefined),
      },
      sky,
      time,
      moving,
    );
    function halo(x, y, r, color) {
      const g = ctx.createRadialGradient(x, y, 0, x, y, r);
      g.addColorStop(0, color);
      g.addColorStop(1, "transparent");
      ctx.fillStyle = g;
      ctx.fillRect(x - r, y - r, r * 2, r * 2);
    }
    if (definition?.render) {
      ctx.save();
      definition.render(ctx, nativeFrame);
      ctx.restore();
    } else if (definition && (definition.draw || !p.nativeScene)) {
      const pen = new ScenePen({
        width: w,
        horizon,
        time,
        night: ramp(sky.darkness, 0.3, 0.72),
        clockDate: nativeFrame.date,
        illustrated: definition.illustrated,
      });
      definition.draw?.(pen);
      if (rtl && definition.movesForRTL) pen.moveToLeftMargin();
      drawNativeScene(
        ctx,
        { width: w, height: h, horizon },
        pen.toGeometry({
          backdrop: definition.backdrop ?? "open",
          wild: definition.wild ?? true,
          ownMoon: definition.ownMoon,
          illustrated: definition.illustrated,
          distantBuildingHeights: definition.distantBuildingHeights,
          nearBuildingHeights: definition.nearBuildingHeights,
        }),
        { ...nativeFrame, skyLow, overcast: OVERCAST[s.weather] },
      );
    } else if (p.nativeScene?.data)
      drawNativeScene(
        ctx,
        { width: w, height: h, horizon },
        renderNativeRuntime(p.nativeScene,w,horizon,time,ramp(sky.darkness,.30,.72),s.hour,rtl),
        {
          darkness: sky.darkness,
          glow: sky.glow,
          time,
          motionEnabled: moving,
          skyLow,
          rtl,
          overcast: OVERCAST[s.weather],
        },
      );
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
      if (layer.clock) drawClock(ctx, rect, layer.clock, s.hour, sky.darkness);
      if (layer.crowd) {
        drawCrowd(ctx, rect, layer.crowd, time, sky.darkness);
        drawReflections(
          ctx,
          rect,
          p.layers.flatMap((l) => l.lights.filter((light) => light.fixture)),
          layer.crowd,
          sky.darkness,
        );
      }
      if (layer.boat) drawBoat(ctx, rect, layer.boat, time);
      if (layer.water) drawWater(ctx, rect, layer.water, time, sky.darkness);
      const on = ramp(sky.darkness, 0.12, 0.65);
      for (const light of layer.lights.filter((l) => l.type === "lamp")) {
        if (on < 0.001) continue;
        if (light.fixture) {
          drawFixture(ctx, rect, light, time, sky.darkness, 0);
          continue;
        }
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
    if (p.layers.some((l) => l.crowd)) {
      const fade = ctx.createLinearGradient(0, horizon - 13, 0, horizon + 1);
      fade.addColorStop(0, "transparent");
      fade.addColorStop(1, "rgba(0,0,0,.9)");
      ctx.fillStyle = fade;
      ctx.fillRect(0, horizon - 13, w, 14);
    }
    // Removed layers must release their cached image surfaces.
    for (const key of plates.keys())
      if (!p.layers.some((l) => l.id === key)) plates.delete(key);
    if (
      p.nativeScene?.data?.wild === false &&
      moving &&
      ramp(sky.darkness, 0.3, 0.72) > 0.3
    )
      drawTraffic(ctx, w, horizon, time, ramp(sky.darkness, 0.3, 0.72));
    drawWeather(ctx, w, h, s, time, moving);
    onFrame({
      rects: new Map(
        [...rects].map(([id, r]) => [
          id,
          {
            x: r.x * scale,
            y: r.y * scale,
            width: r.width * scale,
            height: r.height * scale,
          },
        ]),
      ),
      width: bounds.width,
      height: bounds.height,
      sky,
    });
  }
  raf = requestAnimationFrame(frame);
  return {
    destroy() {
      cancelAnimationFrame(raf);
      document.removeEventListener("visibilitychange", visibilityChanged);
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
