import { drawAircraft, drawBirds } from "./incidental.mjs";
// Canvas translation of SceneView.swift's atmosphere for image-layer scenes.
import { mix, ramp } from "./model.mjs";
export const unit = (i, salt) => {
  const v = Math.sin(i * 12.9898 + salt * 78.233) * 43758.5453;
  return v - Math.floor(v);
};
export const rgba = (v, a = 1) =>
  `rgba(${v.map((x) => Math.round(Math.max(0, Math.min(1, x)) * 255)).join(",")},${a})`;
export const OVERCAST = {
  clear: 0,
  partlyCloudy: 0.18,
  cloudy: 0.55,
  fog: 0.62,
  drizzle: 0.55,
  rain: 0.68,
  snow: 0.55,
  thunderstorm: 0.82,
};
export function sunPoint(width, horizon, hour, dates, arc = 128) {
  const [dawn, rise, , , set, night] = dates,
    noon = (rise + set) / 2;
  const level = Math.cos((Math.PI * (set - rise)) / 24),
    scale = (arc - 14) / Math.max(1 - level, 0.05);
  const height = (Math.cos((Math.PI * (hour - noon)) / 12) - level) * scale;
  return {
    x: 18 + ((hour - dawn) / (night - dawn)) * (width - 36),
    y:
      height >= 0
        ? horizon - height
        : horizon + 21 * (1 - Math.exp(height / 21)),
  };
}
export function groundColor(
  skyLow,
  darkness,
  glow,
  overcast,
  illustrated = false,
) {
  const daylight = 1 - ramp(darkness, 0.12, 0.85);
  const clear = mix(
    [0.16, 0.23, 0.31],
    [0.36, 0.24, 0.21],
    Math.min(1, Math.max(0, glow)) * 0.8,
  );
  return mix(
    illustrated ? [0.02, 0.03, 0.06] : [0.07, 0.07, 0.08],
    mix(clear, skyLow, 0.12 + 0.16 * overcast),
    daylight * 0.75,
  );
}
function disc(ctx, x, y, r, fill) {
  ctx.fillStyle = fill;
  ctx.beginPath();
  ctx.arc(x, y, r, 0, Math.PI * 2);
  ctx.fill();
}
function halo(ctx, x, y, r, color) {
  const g = ctx.createRadialGradient(x, y, 0, x, y, r);
  g.addColorStop(0, color);
  g.addColorStop(1, "transparent");
  disc(ctx, x, y, r, g);
}
function bank(ctx, x, y, w, h, v) {
  ctx.beginPath();
  ctx.moveTo(x, y + 0.12 * h);
  for (const [a, b, c, d, e, f] of [
    [0.02, -0.16, 0.12, -0.55, 0.25, -0.48],
    [0.29, -0.78, 0.38, -1.04, 0.52, -0.88 - v * 0.18],
    [0.65, -1.03, 0.69, -0.65, 0.76, -0.43],
    [0.9, -0.55, 0.99, -0.19, 1, 0.1],
    [0.84, 0.33, 0.16, 0.35, 0, 0.12],
  ])
    ctx.bezierCurveTo(
      x + a * w,
      y + b * h,
      x + c * w,
      y + d * h,
      x + e * w,
      y + f * h,
    );
  ctx.closePath();
}
export function drawAtmosphere(ctx, w, h, s, sky, time, moving) {
  const horizon = h - s.ground,
    top =
      horizon - (s.reservedHeight === undefined ? 128 : s.reservedHeight + 4),
    cloud = OVERCAST[s.weather],
    dark = sky.darkness;
  const grey = mix([0.17, 0.19, 0.23], [0.06, 0.07, 0.09], dark),
    high = mix(sky.top, grey, cloud),
    low = mix(sky.low, grey, cloud);
  const g = ctx.createLinearGradient(0, Math.max(0, top - 120), 0, horizon);
  g.addColorStop(0, rgba(high));
  g.addColorStop(1, rgba(low));
  ctx.fillStyle = g;
  ctx.fillRect(0, 0, w, h);
  if (s.showsSunPath !== false && sky.glow > 0.02 && cloud < 0.8) {
    const morning = s.hour < (s.schedule[1] + s.schedule[4]) / 2;
    const p = sunPoint(
      w,
      horizon,
      s.schedule[morning ? 1 : 4],
      s.schedule,
      horizon - top,
    );
    halo(
      ctx,
      p.x,
      horizon,
      250,
      rgba([1, 0.6, 0.28], 0.72 * sky.glow * (1 - cloud)),
    );
  }
  const strength = ramp(dark, 0.55, 0.95) * (1 - cloud);
  if (strength > 0.03)
    for (let i = 0; i < 80; i++) {
      const twinkle =
        0.55 + 0.45 * Math.sin(time * (0.5 + unit(i, 4)) + unit(i, 5) * 6.28);
      disc(
        ctx,
        unit(i, 1) * w,
        unit(i, 2) * (horizon - 40),
        0.6 + unit(i, 3) * 0.9,
        rgba([1, 1, 1], (0.3 + unit(i, 6) * 0.6) * twinkle * strength),
      );
    }
  if (moving && dark > 0.9 && cloud < 0.3) {
    const turn = Math.floor(time / 17),
      part = (time - turn * 17) / 0.9,
      i = turn % 100000;
    if (part < 1) {
      const slope = unit(i, 83) > 0.5 ? 1 : -1,
        x = w * (0.25 + unit(i, 81) * 0.6) + slope * part * 110,
        y = Math.max(20, top - 150) + unit(i, 82) * 120 + part * 46;
      const g = ctx.createLinearGradient(x - slope * 34, y - 14, x, y);
      g.addColorStop(0, "transparent");
      g.addColorStop(1, rgba([1, 1, 1], 0.85 * Math.sin(Math.PI * part)));
      ctx.strokeStyle = g;
      ctx.lineWidth = 1.4;
      ctx.beginPath();
      ctx.moveTo(x - slope * 34, y - 14);
      ctx.lineTo(x, y);
      ctx.stroke();
    }
  }
  const moonOpacity = ramp(dark, 0.7, 0.92) * (1 - ramp(cloud, 0.3, 0.8));
  if (!s.ownMoon && moonOpacity > 0.02) {
    const standard = s.showsSunPath !== false && !s.illustrated;
    const x = w * (standard ? (s.rtl ? 0.18 : 0.82) : 0.8),
      y = standard
        ? horizon -
          (s.reservedHeight === undefined ? 96 : s.reservedHeight - 10)
        : top - 12;
    ctx.save();
    ctx.globalAlpha = moonOpacity;
    halo(ctx, x, y, 46, rgba([1, 1, 1], 0.16 * (1 - cloud)));
    // Draw only the visible crescent. Never paint a sky-colored cutout over stars.
    ctx.fillStyle = rgba([0.96, 0.95, 0.88], 1 - cloud * 0.5);
    ctx.save();
    ctx.beginPath();
    ctx.arc(x, y, 15, 0, Math.PI * 2);
    ctx.clip();
    ctx.beginPath();
    ctx.rect(x - 16, y - 16, 32, 32);
    ctx.arc(x + 9, y - 5, 14, 0, Math.PI * 2);
    ctx.fill("evenodd");
    ctx.restore();
    ctx.restore();
  }
  if (
    s.showsSunPath !== false &&
    s.hour >= s.schedule[1] &&
    s.hour <= s.schedule[4]
  ) {
    const p = sunPoint(w, horizon, s.hour, s.schedule, horizon - top),
      lowSun = 1 - ramp(horizon - p.y, 4, 70),
      visibility = 1 - ramp(cloud, 0.2, 0.82);
    if (visibility > 0.01) {
      const warm = mix([1, 0.72, 0.3], [1, 0.46, 0.2], lowSun),
        reach = 40 + 8 * lowSun + (moving ? 3 * Math.sin(time * 0.9) : 0);
      halo(
        ctx,
        p.x,
        p.y,
        reach,
        rgba(warm, 0.55 * (1 - cloud * 0.7) * visibility),
      );
      if (cloud < 0.4) {
        ctx.beginPath();
        const turn = moving ? time * 0.1 : 0;
        for (let i = 0; i < 12; i++) {
          const a = (i * Math.PI) / 6 + turn,
            outer = i % 2 === 0 ? 18 : 15.5;
          ctx.moveTo(p.x + Math.cos(a) * 12.5, p.y + Math.sin(a) * 12.5);
          ctx.lineTo(p.x + Math.cos(a) * outer, p.y + Math.sin(a) * outer);
        }
        ctx.strokeStyle = rgba(warm, 0.45 * (1 - cloud * 2));
        ctx.lineWidth = 1.5;
        ctx.lineCap = "round";
        ctx.stroke();
      }
      disc(
        ctx,
        p.x,
        p.y,
        8 + 1.5 * lowSun,
        rgba(
          mix(
            mix([1, 0.8, 0.38], [1, 0.52, 0.24], lowSun),
            [0.82, 0.82, 0.8],
            cloud * 0.7,
          ),
          visibility,
        ),
      );
    }
  }
  if (s.wild === false && moving && s.showsSunPath !== false)
    drawAircraft(ctx, w, horizon, time, dark, s.weather, s.illustrated, s.rtl);
  const count =
    { clear: 2, partlyCloudy: 4, fog: 2, thunderstorm: 7 }[s.weather] ?? 6;
  const tone = mix(
    mix(
      mix([1, 1, 1], [0.7, 0.73, 0.78], cloud),
      [1, 0.74, 0.58],
      sky.glow * 0.55 * (1 - cloud),
    ),
    [0.55, 0.6, 0.72],
    ramp(dark, 0.5, 0.95),
  );
  const opacity =
    (0.3 - cloud * 0.08) *
    (1 - 0.35 * dark) *
    (s.weather === "clear" ? 0.5 : 1);
  for (let i = 0; i < count; i++) {
    const cw = (88 + unit(i, 11) * 86) * (s.weather === "clear" ? 0.72 : 1),
      ch = cw * (0.16 + unit(i, 15) * 0.08),
      travel = w + cw * 2.8;
    const x =
        ((unit(i, 12) * travel + time * (1.4 + unit(i, 13) * 2.2)) % travel) -
        cw * 1.4,
      y =
        top -
        34 +
        unit(i, 14) * 128 * 0.62 +
        Math.sin(time * 0.035 + i * 2.1) * 2,
      alpha = opacity * (0.55 + unit(i, 16) * 0.35);
    bank(ctx, x - cw * 0.12, y + ch * 0.1, cw * 1.24, ch * 0.85, unit(i, 17));
    ctx.fillStyle = rgba(tone, alpha * 0.3);
    ctx.fill();
    bank(ctx, x, y, cw, ch, unit(i, 17));
    const g = ctx.createLinearGradient(x, y - ch, x, y + ch * 0.3);
    g.addColorStop(0, rgba(tone, alpha));
    g.addColorStop(1, rgba(mix(tone, sky.low, 0.32), alpha * 0.55));
    ctx.fillStyle = g;
    ctx.fill();
  }
  if (s.weather === "fog") {
    ctx.save();
    ctx.filter = "blur(22px)";
    for (let i = 0; i < 5; i++) {
      const x =
        ((unit(i, 21) * w + time * (3 + unit(i, 22) * 4)) % w) - w * 0.8;
      ctx.beginPath();
      ctx.ellipse(
        x + w * 0.8,
        top + 128 * (0.3 + i * 0.15) + 15,
        w * 0.8,
        15,
        0,
        0,
        Math.PI * 2,
      );
      ctx.fillStyle = "rgba(255,255,255,.12)";
      ctx.fill();
    }
    ctx.restore();
  }
  if (s.wild === false && moving) drawBirds(ctx, w, top, time, dark, s.weather);
  const start = Math.max(0, horizon - 32),
    span = Math.max(1, h - start),
    floor = ctx.createLinearGradient(0, start, 0, h);
  floor.addColorStop(0, "transparent");
  floor.addColorStop(
    Math.min(1, Math.max(0, (horizon - start) / span)),
    rgba(
      groundColor(
        low,
        dark,
        sky.glow,
        cloud,
        s.illustrated || s.showsSunPath === false,
      ),
    ),
  );
  floor.addColorStop(1, "black");
  ctx.fillStyle = floor;
  ctx.fillRect(0, start, w, h - start);
}
export function drawWeather(ctx, w, h, s, time, moving) {
  const horizon = h - s.ground,
    visibility = (y) =>
      1 - ramp(y, horizon, horizon + Math.max(1, Math.min(s.ground, 24)));
  const drops = { drizzle: 40, rain: 90, thunderstorm: 130 }[s.weather] ?? 0;
  ctx.lineCap = "butt";
  ctx.lineWidth = 1;
  for (let i = 0; i < drops; i++) {
    const y = ((unit(i, 33) + time * (0.6 + unit(i, 32) * 0.5)) % 1) * h,
      x = unit(i, 31) * (w + 30) - 15,
      length = 10 + unit(i, 34) * 10;
    ctx.strokeStyle = rgba(
      [1, 1, 1],
      (0.2 + unit(i, 35) * 0.18) * visibility(y),
    );
    ctx.beginPath();
    ctx.moveTo(x, y);
    ctx.lineTo(x - length * 0.18, y + length);
    ctx.stroke();
  }
  if (s.weather === "snow")
    for (let i = 0; i < 70; i++) {
      const y = ((unit(i, 43) + time * (0.04 + unit(i, 42) * 0.05)) % 1) * h,
        x = unit(i, 41) * w + Math.sin(time * 0.6 + unit(i, 44) * 6.28) * 8;
      disc(
        ctx,
        x,
        y,
        1 + unit(i, 45) * 1.5,
        rgba([1, 1, 1], (0.45 + unit(i, 46) * 0.4) * visibility(y)),
      );
    }
  if (moving && s.weather === "thunderstorm") {
    const turn = Math.floor(time / 7.5),
      since = time - turn * 7.5;
    const pulse =
      since < 0.18
        ? 1 - since / 0.18
        : since > 0.26
          ? Math.max(0, 1 - (since - 0.26) / 0.24) * 0.6
          : 0;
    if (pulse > 0) {
      ctx.fillStyle = rgba([1, 1, 1], 0.22 * pulse);
      ctx.fillRect(0, 0, w, horizon);
      const i = turn % 100000;
      let x = w * (0.2 + unit(i, 71) * 0.6),
        y = horizon - 218;
      ctx.beginPath();
      ctx.moveTo(x, y);
      for (let step = 0; step < 7; step++) {
        x += (unit(i * 7 + step, 72) - 0.5) * 34;
        y += 22 + unit(i * 7 + step, 73) * 12;
        ctx.lineTo(x, y);
      }
      ctx.strokeStyle = rgba([1, 1, 1], 0.9 * pulse);
      ctx.lineWidth = 1.6;
      ctx.lineCap = "round";
      ctx.lineJoin = "round";
      ctx.stroke();
    }
  }
}
