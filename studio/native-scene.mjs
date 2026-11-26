import { mix, ramp } from "./model.mjs";
import { rgba, unit } from "./atmosphere.mjs";
const cache = new WeakMap();
const nativeSurfaces = new WeakMap();
const validated = new WeakSet();
export function validateNativeScene(value) {
  if (value && typeof value === "object" && validated.has(value)) return value;
  if (
    !value ||
    value.version !== 1 ||
    value.width !== 402 ||
    value.horizon !== 224 ||
    !Array.isArray(value.paths) ||
    value.paths.length > 100000
  )
    throw Error("Invalid native scene geometry.");
  if (
    value.paths.reduce(
      (n, p) => n + (typeof p === "string" ? p.length : 1e9),
      0,
    ) > 30000000 ||
    value.paths.some((p) => !/^[MLQCZmlqcz0-9., eE+\-]*$/.test(p))
  )
    throw Error("Unsupported native path data.");
  const allFrames = [value.day, value.night];
  if (value.motion) {
    const m = value.motion;
    if (
      !Array.isArray(m.frames) ||
      m.frames.length > 600 ||
      m.frames.length < 2 ||
      !Number.isFinite(m.fps) ||
      m.fps <= 0 ||
      m.fps > 60 ||
      Math.abs(m.duration - m.frames.length / m.fps) > 0.01
    )
      throw Error("Invalid native motion clip.");
    for (const frame of m.frames)
      for (const key of ["day", "night"]) {
        if (!frame[key] || typeof frame[key] !== "object")
          throw Error("Invalid native motion frame.");
        allFrames.push({ ...value[key], ...frame[key] });
      }
  }
  for (const frame of allFrames) {
    if (!frame) throw Error("Missing native lighting frame.");
    const index = (n) =>
      Number.isInteger(n) && n >= 0 && n < value.paths.length;
    for (const group of ["solids", "holes", "lights"])
      if (
        !Array.isArray(frame[group]) ||
        frame[group].length > 50000 ||
        frame[group].some((n) => !index(n))
      )
        throw Error("Invalid native drawing group.");
    const color = (c) =>
      Array.isArray(c) &&
      c.length === 4 &&
      c.every(
        (n) => typeof n === "number" && Number.isFinite(n) && n >= 0 && n <= 1,
      );
    if (
      !Array.isArray(frame.tints) ||
      frame.tints.length > 50000 ||
      frame.tints.some(
        (t) =>
          !index(t.path) || !color(t.color) || (t.lower && !color(t.lower)),
      )
    )
      throw Error("Invalid native material.");
    if (
      !Array.isArray(frame.beacons) ||
      frame.beacons.length > 1000 ||
      frame.beacons.some(
        (p) =>
          !Array.isArray(p) ||
          p.length !== 2 ||
          p.some((n) => !Number.isFinite(n)),
      )
    )
      throw Error("Invalid native beacon.");
  }
  if (!["towers", "low", "hills", "open"].includes(value.backdrop))
    throw Error("Invalid native backdrop.");
  validated.add(value);
  return value;
}
const svgCache=new Map();
function svgPath(text){if(!svgCache.has(text)){if(svgCache.size>10000)svgCache.clear();svgCache.set(text,new Path2D(text))}return svgCache.get(text)}
function pathsFor(data) {
  return id => {
    const value=typeof id==='string'?id:data.paths[id];
    return typeof value==='string'?svgPath(value):value;
  };
}
function paintPath(ctx,path){
  if(path instanceof Path2D){ctx.fill(path);return}
  for(const part of path.parts){ctx.save();if(part.transform)ctx.transform(...part.transform);const p=svgPath(part.d);
    if(part.stroke){ctx.strokeStyle=ctx.fillStyle;ctx.lineWidth=part.stroke.width;ctx.lineCap=part.stroke.cap;ctx.lineJoin=part.stroke.join;ctx.stroke(p)}else ctx.fill(p);ctx.restore();}
}
function containsPath(ctx,path,x,y){
  if(path instanceof Path2D)return ctx.isPointInPath(path,x,y);
  for(const part of path.parts){ctx.save();if(part.transform)ctx.transform(...part.transform);const p=svgPath(part.d);let found;if(part.stroke){ctx.lineWidth=part.stroke.width;ctx.lineCap=part.stroke.cap;ctx.lineJoin=part.stroke.join;found=ctx.isPointInStroke(p,x,y)}else found=ctx.isPointInPath(p,x,y);ctx.restore();if(found)return true}return false;
}
export function nativePalette(low, dark, glow, overcast, illustrated) {
  const daylight = 1 - ramp(dark, 0.12, 0.85);
  if (illustrated) {
    const sun = mix(
      [0.43, 0.34, 0.26],
      [0.48, 0.32, 0.23],
      Math.min(1, Math.max(0, glow)) * 0.55,
    );
    const landmark = mix(
      [0.24, 0.25, 0.27],
      mix(sun, low, overcast * 0.06),
      daylight,
    );
    return {
      landmark,
      foreground: mix([0.02, 0.03, 0.06], landmark, 0.7),
      daylight,
    };
  }
  const weather = mix(
    mix(
      [0.16, 0.23, 0.31],
      [0.36, 0.24, 0.21],
      Math.min(1, Math.max(0, glow)) * 0.8,
    ),
    low,
    0.12 + 0.16 * overcast,
  );
  return {
    landmark: mix([0.07, 0.07, 0.08], weather, daylight),
    foreground: mix([0.07, 0.07, 0.08], weather, daylight * 0.75),
    daylight,
  };
}
function buildings(width, seed, low, high) {
  const result = [];
  let x = -6,
    i = 0;
  while (x < width + 6) {
    const w = 14 + unit(i, seed) * 24,
      h = low + unit(i, seed + 1) * (high - low);
    result.push({ x, width: w, height: h });
    x += w + 2;
    i++;
  }
  return result;
}
export function drawNativeScene(ctx, size, data, frame) {
  const { width: w, height: h, horizon } = size,
    {
      darkness: dark,
      glow,
      time,
      motionEnabled,
      skyLow,
      overcast,
      rtl = false,
    } = frame;
  const palette = nativePalette(skyLow, dark, glow, overcast, data.illustrated),
    lights = ramp(dark, 0.3, 0.72);
  const backdrop = data.backdrop,
    distant =
      backdrop === "towers"
        ? buildings(w, 50, ...(data.distantBuildingHeights ?? [16, 42]))
        : backdrop === "low"
          ? buildings(w, 50, 10, 28)
          : [];
  ctx.save();
  ctx.fillStyle = rgba(
    mix(
      skyLow,
      [0.02, 0.03, 0.06],
      data.illustrated ? 0.76 : 0.62 - palette.daylight * 0.08,
    ),
  );
  ctx.beginPath();
  if (backdrop === "hills") {
    ctx.moveTo(-8, horizon);
    for (let x = -8; x <= w + 8; x += 6) {
      const height =
        30 +
        16 * Math.sin(x * 0.018 + 1.3) +
        9 * Math.sin(x * 0.047 + 0.4) +
        4 * Math.sin(x * 0.11 + 2.1);
      ctx.lineTo(x, horizon - Math.max(height, 6));
    }
    ctx.lineTo(w + 8, horizon);
    ctx.closePath();
  }
  for (const b of distant) ctx.rect(b.x, horizon - b.height, b.width, b.height);
  ctx.fill();
  for (const [i, b] of distant.entries())
    if (b.height > 15) {
      const top = horizon - b.height;
      ctx.fillStyle = rgba(skyLow, 0.11);
      ctx.fillRect(
        b.x + b.width * 0.22,
        top + 2,
        0.7,
        Math.max(0, b.height - 4),
      );
      if (lights > 0.02)
        for (let row = 0; row < Math.floor(b.height / 11); row++) {
          const id = i * 31 + row,
            turn = Math.trunc((time / 28 + unit(id, 111)) % 5000);
          if (unit(id + turn * 7919, 112) <= 0.66) continue;
          ctx.fillStyle = rgba([1, 0.82, 0.56], 0.38 * lights);
          ctx.fillRect(
            b.x + 3 + unit(id, 113) * Math.max(0, b.width - 7),
            top + 5 + row * 10,
            1.1,
            1.5,
          );
        }
    }
  const nativeCache = nativeSurfaces.get(data._surfaceOwner ?? data) ?? {
    surface: document.createElement("canvas"),
  };
  nativeSurfaces.set(data._surfaceOwner ?? data, nativeCache);
  const surface = nativeCache.surface;
  if (
    surface.width !== Math.max(1, Math.round(w * 2)) ||
    surface.height !== Math.max(1, Math.round(h * 2))
  ) {
    surface.width = Math.max(1, Math.round(w * 2));
    surface.height = Math.max(1, Math.round(h * 2));
  }
  const s = surface.getContext("2d");
  s.setTransform(2, 0, 0, 2, 0, 0);
  s.clearRect(0, 0, w, h);
  const near = data.wild
    ? []
    : buildings(w, 70, ...(data.nearBuildingHeights ?? [7, 22]));
  s.fillStyle = rgba(palette.foreground);
  for (const [i, b] of near.entries()) {
    s.fillRect(b.x, horizon - b.height, b.width, b.height);
    if (unit(i, 73) > 0.74)
      s.fillRect(b.x + b.width / 2 - 0.75, horizon - b.height - 9, 1.5, 9);
    else if (unit(i, 73) < 0.24)
      s.fillRect(b.x + b.width * 0.2, horizon - b.height - 5, b.width * 0.6, 5);
  }
  const p = pathsFor(data),
    scale = w / data.width,
    pose = motionPose(data, time, "day"),
    nightPose = motionPose(data, time, "night");
  const used = [
    ...pose.solids,
    ...pose.holes,
    ...pose.lights,
    ...pose.tints.map((t) => t.path),
  ];
  const xShift =
    rtl && data.movesForRTL
      ? (8 - Math.min(...used.map((id) => pathBounds(data, id).x))) * scale
      : 0;
  s.save();
  s.translate(xShift, horizon);
  s.scale(scale, scale);
  s.translate(0, -data.horizon);
  s.fillStyle = rgba(palette.landmark);
  for (const id of pose.solids) paintPath(s,p(id));
  s.globalCompositeOperation = "destination-out";
  s.fillStyle = "black";
  for (const id of pose.holes) paintPath(s,p(id));
  s.restore();
  ctx.drawImage(surface, 0, 0, w, h);
  ctx.translate(xShift, horizon);
  ctx.scale(scale, scale);
  ctx.translate(0, -data.horizon);
  // Colored materials retain the native day/night colors instead of receiving
  // a generic image tint. Cutouts only affect the silhouette layer.
  for (let i = 0; i < pose.tints.length; i++) {
    const a = pose.tints[i],
      b = nightPose.tints[i] ?? a;
    if (a.nightOnly && lights <= 0.02) continue;
    const color = mix(a.color, b.color, lights),
      opacity = a.nightOnly ? lights : 1;
    ctx.globalAlpha = opacity;
    if (a.lower) {
      const lower = mix(a.lower, b.lower ?? a.lower, lights),
        path = p(a.path);
      const g = ctx.createLinearGradient(
        0,
        a.bounds?.[1] ?? 0,
        0,
        (a.bounds?.[1] ?? 0) + (a.bounds?.[3] ?? data.horizon),
      );
      g.addColorStop(0, rgba(color.slice(0, 3), color[3]));
      g.addColorStop(1, rgba(lower.slice(0, 3), lower[3]));
      ctx.fillStyle = g;
      paintPath(ctx,path);
    } else {
      ctx.fillStyle = rgba(color.slice(0, 3), color[3]);
      paintPath(ctx,p(a.path));
    }
  }
  ctx.globalAlpha = 1;
  if (lights > 0.02)
    for (const [index, b] of near.entries())
      if (b.height > 16) {
        for (let window = 0; window < Math.floor(b.height / 9); window++) {
          const id = index * 31 + window,
            stays = 14 + unit(id, 79) * 34,
            turn = Math.trunc(((time + unit(id, 80) * stays) / stays) % 5000);
          if (unit(id + turn * 7919, 77) <= 1 - 0.5 * lights) continue;
          const x = b.x + 3 + unit(id, 78) * Math.max(0, b.width - 8),
            y = horizon - b.height + 5 + window * 9;
          const px = (x + 1 - xShift) / scale,
            py = (y + 1.5 - horizon) / scale + data.horizon;
          let covered = false;
          ctx.save();
          ctx.setTransform(1, 0, 0, 1, 0, 0);
          for (const shape of [...pose.solids, ...pose.holes]) {
            const box = pathBounds(data, shape);
            if (
              px >= box.x &&
              px <= box.x + box.width &&
              py >= box.y &&
              py <= box.y + box.height &&
              containsPath(ctx,p(shape),px,py)
            ) {
              covered = true;
              break;
            }
          }
          ctx.restore();
          if (covered) continue;
          ctx.fillStyle = "rgba(255,214,133,.75)";
          ctx.fillRect(
            (x - xShift) / scale,
            (y - horizon) / scale + data.horizon,
            2 / scale,
            3 / scale,
          );
        }
      }
  if (lights > 0.02) {
    ctx.fillStyle = rgba([1, 0.86, 0.56], 0.92 * lights);
    for (const id of pose.lights) paintPath(ctx,p(id));
  }
  if (lights > 0.5)
    for (const [i, point] of pose.beacons.entries()) {
      if (motionEnabled && (time / 1.9 + unit(i, 95)) % 1 >= 0.38) continue;
      const [x, y] = point,
        g = ctx.createRadialGradient(x, y, 0, x, y, 4.5);
      g.addColorStop(0, "rgba(255,64,51,.45)");
      g.addColorStop(1, "transparent");
      ctx.fillStyle = g;
      ctx.fillRect(x - 4.5, y - 4.5, 9, 9);
      ctx.fillStyle = "rgb(255,82,66)";
      ctx.beginPath();
      ctx.arc(x, y, 1.3, 0, Math.PI * 2);
      ctx.fill();
    }
  ctx.restore();
}

const pathTokens = new WeakMap();
function interpolatePath(data, a, b, t) {
  if (a === b || t < 0.001) return a;
  let pool = pathTokens.get(data);
  if (!pool) {
    pool = new Map();
    pathTokens.set(data, pool);
  }
  const tokens = (id) => {
    if (!pool.has(id))
      pool.set(
        id,
        data.paths[id]
          .match(/[MLQCZ]|[-+]?(?:\d*\.)?\d+(?:e[-+]?\d+)?/gi)
          .map((v) => (Number.isFinite(Number(v)) ? Number(v) : v)),
      );
    return pool.get(id);
  };
  const x = tokens(a),
    y = tokens(b);
  if (
    x.length !== y.length ||
    x.some((v, i) => typeof v === "string" && v !== y[i])
  )
    return t < 0.5 ? a : b;
  return x
    .map((v, i) =>
      typeof v === "number" ? (v + (y[i] - v) * t).toFixed(3) : v,
    )
    .join(" ");
}
function motionPose(data, time, key) {
  if (!data.motion) return data[key];
  const { frames, fps } = data.motion,
    position = (Math.max(0, time) * fps) % frames.length;
  const index = Math.floor(position),
    t = position - index;
  const a = { ...data[key], ...frames[index][key] },
    b = { ...data[key], ...frames[(index + 1) % frames.length][key] };
  for (const group of ["solids", "holes", "lights"])
    if (a[group] !== b[group] && a[group].length === b[group].length)
      a[group] = a[group].map((id, i) =>
        interpolatePath(data, id, b[group][i], t),
      );
  if (a.tints !== b.tints && a.tints.length === b.tints.length)
    a.tints = a.tints.map((v, i) => ({
      ...v,
      path: interpolatePath(data, v.path, b.tints[i].path, t),
      color: mix(v.color, b.tints[i].color, t),
    }));
  return a;
}

const boundsCache = new WeakMap();
function pathBounds(data, id) {
  let cache = boundsCache.get(data);
  if (!cache) {
    cache = new Map();
    boundsCache.set(data, cache);
  }
  const text = typeof id === "string" ? id : data.paths[id];
  if(typeof text==='object'&&text.bounds){const [x,y,width,height]=text.bounds;return{x,y,width,height}}
  if (cache.has(text)) return cache.get(text);
  const numbers = (text.match(/[-+]?(?:\d*\.)?\d+(?:e[-+]?\d+)?/gi) || []).map(
      Number,
    ),
    xs = numbers.filter((_, i) => i % 2 === 0),
    ys = numbers.filter((_, i) => i % 2 === 1);
  const x = xs.length ? Math.min(...xs) : Infinity,
    y = ys.length ? Math.min(...ys) : Infinity,
    result = {
      x,
      y,
      width: xs.length ? Math.max(...xs) - x : 0,
      height: ys.length ? Math.max(...ys) - y : 0,
    };
  if (typeof id !== "string") cache.set(text, result);
  return result;
}
