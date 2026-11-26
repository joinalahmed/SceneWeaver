import { unit, rgba } from "./atmosphere.mjs";
import { mix, ramp } from "./model.mjs";
export function drawAircraft(
  ctx,
  w,
  horizon,
  time,
  dark,
  weather,
  illustrated = false,
  rtl = false,
) {
  if (["rain", "thunderstorm", "snow", "fog"].includes(weather)) return;
  const cycle = Math.floor(time / 120),
    phase = time - cycle * 120,
    helicopter = phase >= 65 && phase < 94,
    progress = phase < 23 ? phase / 23 : helicopter ? (phase - 65) / 29 : -1;
  if (progress < 0) return;
  const direction = cycle % 2 === 0 ? 1 : -1,
    x =
      direction > 0 ? -30 + progress * (w + 60) : w + 30 - progress * (w + 60),
    y =
      horizon -
      (helicopter ? 62 : 82) +
      (helicopter ? Math.sin(time * 0.8) * 1.5 : Math.sin(time * 0.16) * 0.8);
  const fromClock = rtl ? w - x : x,
    visibility = illustrated ? 1 : ramp(fromClock / Math.max(w, 1), 0.64, 0.75);
  if (visibility <= 0.01) return;
  ctx.save();
  ctx.globalAlpha = visibility;
  ctx.translate(x, y);
  ctx.scale(direction, 1);
  ctx.fillStyle = ctx.strokeStyle = rgba(
    mix([0.08, 0.1, 0.15], [0.72, 0.76, 0.83], dark),
    0.75,
  );
  ctx.lineWidth = 1;
  ctx.lineCap = "round";
  ctx.beginPath();
  if (helicopter) {
    ctx.moveTo(-19, -1);
    ctx.lineTo(-7, 0);
    ctx.bezierCurveTo(-2, -7, 7, -6, 10, 3);
    ctx.bezierCurveTo(10, 7, -1, 7, -5, 5);
    ctx.lineTo(-9, 2);
    ctx.lineTo(-20, 2);
    ctx.closePath();
    ctx.fill();
    const reach = 7 + Math.abs(Math.sin(time * 12)) * 6;
    ctx.beginPath();
    ctx.moveTo(-2 - reach, -8);
    ctx.lineTo(-2 + reach, -8);
    ctx.moveTo(-2, -8);
    ctx.lineTo(-2, -5);
    ctx.moveTo(-7, 8);
    ctx.lineTo(7, 8);
    ctx.moveTo(-4, 5);
    ctx.lineTo(-5, 8);
    ctx.moveTo(5, 5);
    ctx.lineTo(4, 8);
    ctx.stroke();
  } else {
    ctx.moveTo(-20, -1);
    ctx.lineTo(-23, -6);
    ctx.lineTo(-19, -6);
    ctx.lineTo(-14, -2);
    ctx.lineTo(15, -2);
    ctx.quadraticCurveTo(21, -1, 21, 1);
    ctx.quadraticCurveTo(19, 3, 14, 3);
    for (const p of [
      [3, 3],
      [-4, 7],
      [-9, 7],
      [-5, 3],
      [-17, 3],
    ])
      ctx.lineTo(...p);
    ctx.closePath();
    ctx.fill();
  }
  if (dark > 0.5 && time % 2.4 < 0.25) {
    ctx.fillStyle = "rgba(255,0,0,.85)";
    ctx.beginPath();
    ctx.arc(-12, -1, 1, 0, Math.PI * 2);
    ctx.fill();
  }
  ctx.restore();
}
export function drawBirds(ctx, w, top, time, dark, weather) {
  if (dark >= 0.6 || ["rain", "thunderstorm", "snow", "fog"].includes(weather))
    return;
  ctx.save();
  ctx.strokeStyle = rgba([0.03, 0.05, 0.1], 0.7 * (1 - dark));
  ctx.lineWidth = 1.2;
  ctx.lineCap = "round";
  ctx.lineJoin = "round";
  for (let flock = 0; flock < 2; flock++) {
    const crossing = 44 + unit(flock, 61) * 26,
      shifted = time + unit(flock, 62) * crossing,
      lap = Math.floor(shifted / crossing),
      part = shifted / crossing - lap,
      seed = flock * 1000 + (lap % 900),
      direction = unit(seed, 63) > 0.5 ? 1 : -1,
      span = w + 140,
      leadX = direction > 0 ? -70 + part * span : w + 70 - part * span,
      leadY =
        top -
        60 +
        unit(seed, 64) * 128 * 0.6 +
        Math.sin(time * 0.35 + flock) * 6,
      count = 3 + Math.floor(unit(seed, 65) * 4);
    for (let bird = 0; bird < count; bird++) {
      const row = Math.floor((bird + 1) / 2),
        side = bird % 2 === 0 ? 1 : -1,
        x = leadX - direction * row * 11 + Math.sin(time * 0.7 + bird) * 1.5,
        y = leadY + side * row * 6 + Math.cos(time * 0.9 + bird * 1.7) * 1.5,
        lift = 1 + Math.sin(time * 7 + bird * 1.3 + flock) * 2.4,
        wing = 4.4;
      ctx.beginPath();
      ctx.moveTo(x - wing, y - lift);
      ctx.quadraticCurveTo(x - wing * 0.5, y - lift * 1.3 - 0.6, x, y);
      ctx.quadraticCurveTo(
        x + wing * 0.5,
        y - lift * 1.3 - 0.6,
        x + wing,
        y - lift,
      );
      ctx.stroke();
    }
  }
  ctx.restore();
}
export function drawTraffic(ctx, w, horizon, time, strength) {
  for (let car = 0; car < 9; car++) {
    const forward = car % 2 === 0,
      speed = 9 + unit(car, 91) * 12,
      run = w + 40,
      along = (unit(car, 92) * run + time * speed) % run,
      x = forward ? along - 20 : run - along - 20,
      y = horizon + (forward ? 1.6 : 3.4);
    ctx.fillStyle = rgba(
      forward ? [1, 0.95, 0.8] : [1, 0.3, 0.25],
      0.8 * strength,
    );
    for (const px of [x, x - (forward ? -2.6 : 2.6)]) {
      ctx.beginPath();
      ctx.arc(px, y, 1, 0, Math.PI * 2);
      ctx.fill();
    }
  }
}
