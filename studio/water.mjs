// Image-space water highlights, drawn between a water plate and its foreground.
// The native export emits the same normalized geometry and timing.
import { unit, rgba } from "./atmosphere.mjs";
export function drawWater(ctx, rect, water, time, darkness) {
  const x = rect.x + water.x * rect.width,
    y = rect.y + water.y * rect.height;
  const width = rect.width * water.width,
    height = rect.height * water.height;
  ctx.save();
  ctx.beginPath();
  ctx.rect(x, y, width, height);
  ctx.clip();
  ctx.lineCap = "round";
  ctx.lineWidth = Math.max(0.5, rect.width * 0.001);
  for (let i = 0; i < 32; i++) {
    const phase = time * 1.3 + i * 0.9;
    const px =
      x + unit(i, 91) * width + Math.sin(phase * 0.6) * rect.width * 0.012;
    const py = y + unit(i, 92) * height;
    const length =
      rect.width * (0.012 + unit(i, 93) * 0.032) * (1 + Math.sin(phase) * 0.25);
    const opacity =
      water.opacity *
      (0.35 + 0.65 * (0.5 + 0.5 * Math.sin(phase))) *
      (1 - darkness * 0.45);
    ctx.strokeStyle = rgba([0.75, 0.86, 0.88], opacity);
    ctx.beginPath();
    ctx.moveTo(px - length / 2, py);
    ctx.lineTo(px + length / 2, py);
    ctx.stroke();
  }
  ctx.restore();
}
