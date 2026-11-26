import { unit, rgba } from "./atmosphere.mjs";
import { ramp } from "./model.mjs";
export function drawClock(ctx, rect, clock, hour, darkness) {
  const x = rect.x + rect.width * clock.x,
    y = rect.y + rect.height * clock.y,
    r = rect.width * clock.radius;
  ctx.fillStyle = rgba([0.98, 0.94, 0.79], 1 - darkness * 0.3);
  ctx.beginPath();
  ctx.arc(x, y, r, 0, Math.PI * 2);
  ctx.fill();
  const minutes = Math.floor((hour % 1) * 60),
    hours = (Math.floor(hour) % 12) + minutes / 60;
  ctx.beginPath();
  for (const [angle, length] of [
    [(hours / 12) * Math.PI * 2, 0.5],
    [(minutes / 60) * Math.PI * 2, 0.78],
  ]) {
    ctx.moveTo(x, y);
    ctx.lineTo(
      x + Math.sin(angle) * length * r,
      y - Math.cos(angle) * length * r,
    );
  }
  ctx.strokeStyle = rgba([0.19, 0.17, 0.11]);
  ctx.lineWidth = Math.max(0.4, rect.width * 0.0011);
  ctx.lineCap = "round";
  ctx.stroke();
}
export function drawCrowd(ctx, rect, pattern, time, darkness) {
  const orbit = pattern === "orbit",
    count = orbit ? 420 : 38,
    white = new Path2D(),
    dark = new Path2D(),
    heads = new Path2D(),
    shadows = new Path2D();
  for (let i = 0; i < count; i++) {
    let nx, ny;
    if (orbit) {
      const angle = i * 2.399963 - time * 0.014,
        radius = 0.22 + (i % 6) * 0.025 + unit(i, 845) * 0.02;
      nx = 0.49 + Math.cos(angle) * radius;
      ny = 0.83 + Math.sin(angle) * radius * 0.36;
      if (nx > 0.6 && nx < 0.73 && ny > 0.75 && ny < 0.84) continue;
      if (nx > 0.59 && nx < 0.67 && ny > 0.86 && ny < 0.94) continue;
    } else {
      const fraction =
        (unit(i, 403) + time * (i % 2 === 0 ? 0.0006 : -0.0005)) % 1;
      nx = 0.12 + (fraction < 0 ? fraction + 1 : fraction) * 0.76;
      ny = 0.82 + unit(i, 807) * 0.15;
    }
    const x = rect.x + nx * rect.width,
      y = rect.y + ny * rect.height,
      h = rect.width * (orbit ? 0.0046 : 0.01) * (0.65 + (ny - 0.7) * 2.5),
      p = i % 4 === 0 ? dark : white;
    p.moveTo(x - h * 0.2, y);
    p.lineTo(x + h * 0.2, y);
    p.lineTo(x + h * 0.12, y - h * 0.75);
    p.quadraticCurveTo(x, y - h * 0.94, x - h * 0.12, y - h * 0.75);
    p.closePath();
    heads.moveTo(x + h * 0.09, y - h * 0.93);
    heads.ellipse(x, y - h * 0.93, h * 0.09, h * 0.09, 0, 0, Math.PI * 2);
    shadows.moveTo(x + h * 0.5, y + h * 0.04);
    shadows.ellipse(
      x + h * 0.2,
      y + h * 0.04,
      h * 0.3,
      h * 0.09,
      0,
      0,
      Math.PI * 2,
    );
  }
  for (const [path, color] of [
    [shadows, "rgba(0,0,0,.13)"],
    [
      white,
      rgba([
        0.96 - darkness * 0.3,
        0.96 - darkness * 0.3,
        0.96 - darkness * 0.3,
      ]),
    ],
    [dark, rgba([0.2, 0.23, 0.22])],
    [heads, rgba([0.48, 0.39, 0.27], 0.8)],
  ]) {
    ctx.fillStyle = color;
    ctx.fill(path);
  }
}
export function drawFixture(ctx, rect, light, time, darkness, index) {
  const on = ramp(darkness, 0.12, 0.65);
  if (on <= 0.001) return;
  const x = rect.x + rect.width * light.x,
    y = rect.y + rect.height * light.y,
    r = rect.width * light.radius,
    shimmer =
      0.97 + 0.03 * Math.sin(time * 0.45 + (light.phaseIndex ?? index) * 1.3);
  const color = [
    parseInt(light.color.slice(1, 3), 16) / 255,
    parseInt(light.color.slice(3, 5), 16) / 255,
    parseInt(light.color.slice(5, 7), 16) / 255,
  ];
  const g = ctx.createRadialGradient(x, y, 0, x, y, r);
  g.addColorStop(0, rgba(color, on * 0.65 * shimmer));
  g.addColorStop(0.5, rgba(color, on * 0.18));
  g.addColorStop(1, "transparent");
  ctx.fillStyle = g;
  ctx.fillRect(x - r, y - r, r * 2, r * 2);
  const core = rect.width * (light.near ? 0.0017 : 0.001);
  ctx.fillStyle = rgba([1, 0.96, 0.72], on);
  ctx.beginPath();
  ctx.arc(x, y, core, 0, Math.PI * 2);
  ctx.fill();
}
export function drawReflections(ctx, rect, lights, pattern, darkness) {
  const on = ramp(darkness, 0.12, 0.7);
  if (on <= 0.001) return;
  for (const light of lights)
    if (light.reflection > 0) {
      const x = rect.x + rect.width * light.x,
        y =
          rect.y +
          rect.height *
            (pattern === "orbit" ? Math.max(0.82, light.y + 0.1) : 0.88),
        w = rect.width * (light.near ? 0.022 : 0.013),
        h = rect.height * light.reflection;
      ctx.save();
      ctx.filter = `blur(${rect.width * 0.002}px)`;
      const g = ctx.createLinearGradient(x, y, x, y + h);
      g.addColorStop(0, rgba([1, 0.78, 0.36], on * 0.24));
      g.addColorStop(1, "transparent");
      ctx.fillStyle = g;
      ctx.beginPath();
      ctx.ellipse(x, y + h / 2, w / 2, h / 2, 0, 0, Math.PI * 2);
      ctx.fill();
      ctx.restore();
    }
}
