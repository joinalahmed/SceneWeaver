import { validateNativeScene } from "./native-scene.mjs";
export const WEATHER = [
  "clear",
  "partlyCloudy",
  "cloudy",
  "fog",
  "drizzle",
  "rain",
  "snow",
  "thunderstorm",
];
export const DEFAULT_SCHEDULE = [5, 6, 12, 15, 18, 19.5];
export const clamp = (n, a, b) => Math.max(a, Math.min(b, n));
export const id = () => globalThis.crypto.randomUUID();
export const assetName = (value) =>
  ("A" + String(value).replace(/[^a-zA-Z0-9_]/g, "")).slice(0, 64);
const finite = (x, lo, hi, label) => {
  if (typeof x !== "number" || !Number.isFinite(x) || x < lo || x > hi)
    throw Error(`${label} must be between ${lo} and ${hi}.`);
  return x;
};
const string = (x, label, max = 100) => {
  if (typeof x !== "string" || !x.trim() || x.length > max)
    throw Error(
      `${label} must be a nonempty string of at most ${max} characters.`,
    );
  return x;
};
export function validateProject(input, { allowSources = false } = {}) {
  if (!input || input.version !== 1)
    throw Error("This is not a SceneWeaver Studio version 1 project.");
  const settings = input.settings;
  if (!settings) throw Error("Missing scene settings.");
  const schedule = settings.schedule;
  if (!Array.isArray(schedule) || schedule.length !== 6)
    throw Error("Supply six daylight transitions.");
  schedule.forEach((h, i) => {
    finite(h, 0, 24, "Daylight time");
    if (i && h <= schedule[i - 1])
      throw Error("Daylight transitions must increase from dawn to night.");
  });
  if (!WEATHER.includes(settings.weather))
    throw Error("Unsupported weather condition.");
  if (!Array.isArray(input.layers) || input.layers.length > 24)
    throw Error("A project supports up to 24 layers.");
  const ids = new Set(),
    names = new Set();
  const layers = input.layers.map((l, index) => {
    if (!l || !l.asset) throw Error(`Layer ${index + 1} is missing artwork.`);
    const key = string(l.id, "Layer ID");
    if (ids.has(key)) throw Error("Layer IDs must be unique.");
    ids.add(key);
    const name = string(l.asset.name, "Asset name", 64);
    if (!/^[A-Za-z][A-Za-z0-9_]*$/.test(name))
      throw Error(
        "Asset names must start with a letter and contain only letters, digits and underscores.",
      );
    if (names.has(name.toLowerCase()))
      throw Error("Each layer needs a unique asset name.");
    names.add(name.toLowerCase());
    const asset = { name };
    if (
      typeof l.asset.data === "string" &&
      /^data:image\/(png|jpeg|webp|svg\+xml)(;base64,|,)/.test(l.asset.data)
    ) {
      if (l.asset.data.length > 16000000)
        throw Error("Artwork must be smaller than 12 MB per layer.");
      asset.data = l.asset.data;
    } else if (
      allowSources &&
      typeof l.asset.src === "string" &&
      /^[A-Za-z0-9_./-]+\.(svg|png|webp|jpe?g)$/.test(l.asset.src) &&
      !l.asset.src.includes("..") &&
      !l.asset.src.startsWith("/")
    )
      asset.src = l.asset.src;
    else
      throw Error(
        `Missing embedded artwork for ${name}. Open a self-contained Studio project.`,
      );
    if (!Array.isArray(l.lights) || l.lights.length > 100)
      throw Error("A layer supports up to 100 lights.");
    const lightIDs = new Set();
    const lights = l.lights.map((light) => {
      if (!["lamp", "flood"].includes(light.type))
        throw Error("Unknown light type.");
      const lightID = string(light.id, "Light ID");
      if (lightIDs.has(lightID))
        throw Error("Light IDs must be unique within a layer.");
      lightIDs.add(lightID);
      if (!/^#[0-9a-fA-F]{6}$/.test(light.color))
        throw Error("Light colors must be six-digit hex values.");
      return {
        id: lightID,
        type: light.type,
        x: finite(light.x, 0, 1, "Light X"),
        y: finite(light.y, 0, 1, "Light Y"),
        radius: finite(light.radius, 0.001, 1, "Light radius"),
        intensity: finite(light.intensity, 0, 1, "Light intensity"),
        color: light.color,
        ...(light.fixture
          ? {
              fixture: true,
              near: light.near === true,
              reflection: finite(light.reflection ?? 0, 0, 0.5, "Reflection"),
              phaseIndex: finite(light.phaseIndex ?? 0, 0, 1000, "Light phase"),
            }
          : {}),
      };
    });
    return {
      id: key,
      name: string(l.name, "Layer name"),
      visible: l.visible !== false,
      depth: finite(l.depth, 0, 8, "Depth"),
      dim: finite(l.dim, 0, 0.9, "Ambient dimming"),
      asset,
      lights,
      ...(l.crowd
        ? {
            crowd: ["orbit", "crossing"].includes(l.crowd)
              ? l.crowd
              : (() => {
                  throw Error("Invalid crowd pattern.");
                })(),
          }
        : {}),
      ...(l.clock
        ? {
            clock: {
              x: finite(l.clock.x, 0, 1, "Clock X"),
              y: finite(l.clock.y, 0, 1, "Clock Y"),
              radius: finite(l.clock.radius, 0.001, 0.2, "Clock radius"),
            },
          }
        : {}),
      ...(l.boat ? { boat: validateBoat(l.boat) } : {}),
      ...(l.water !== undefined
        ? { water: l.water === null ? null : validateWater(l.water) }
        : {}),
    };
  });
  if (
    layers.reduce((total, l) => total + (l.asset.data?.length ?? 0), 0) >
    48000000
  )
    throw Error(
      "Embedded artwork exceeds the 48 MB project limit. Reduce image sizes before importing.",
    );
  return {
    version: 1,
    name: string(input.name, "Project name"),
    settings: {
      hour: finite(settings.hour, 0, 23.99, "Displayed hour"),
      weather: settings.weather,
      ground: finite(settings.ground, 0, 160, "Ground height"),
      aspectRatio: finite(
        settings.aspectRatio,
        0.25,
        4,
        "Artwork aspect ratio",
      ),
      overscan: finite(settings.overscan, 1, 1.6, "Overscan"),
      viewport: finite(settings.viewport, 0.5, 2.5, "Viewport aspect ratio"),
      motion: settings.motion !== false,
      schedule: [...schedule],
      ...(settings.reservedHeight ? {reservedHeight:{widthFactor:finite(settings.reservedHeight.widthFactor,0,4,"Reserved height factor"),offset:finite(settings.reservedHeight.offset,0,300,"Reserved height offset")}} : {}),
      ...(settings.showsSunPath === undefined ? {} : {showsSunPath:settings.showsSunPath !== false}),
    },
    layers,
    ...(input.nativeScene
      ? {
          nativeScene: validateNativeReference(input.nativeScene, allowSources),
        }
      : {}),
  };
}
export function blankProject() {
  return {
    version: 1,
    name: "Untitled scene",
    settings: {
      hour: 18,
      weather: "clear",
      ground: 36,
      aspectRatio: 1.5,
      overscan: 1.12,
      viewport: 1.5,
      motion: true,
      schedule: [...DEFAULT_SCHEDULE],
    },
    layers: [],
  };
}
export function artworkRect(
  width,
  horizon,
  { aspectRatio, overscan },
  motion = 0,
  depth = 1,
) {
  const w = width * Math.max(1, overscan);
  return {
    x: (width - w) / 2 + motion * width * 0.0015 * depth,
    y: horizon - w / aspectRatio,
    width: w,
    height: w / aspectRatio,
  };
}
export function reorder(layers, from, to) {
  const result = [...layers];
  if (from < 0 || to < 0 || from >= result.length || to >= result.length)
    return result;
  const [layer] = result.splice(from, 1);
  result.splice(to, 0, layer);
  return result;
}
export const mix = (a, b, t) => a.map((v, i) => v + (b[i] - v) * t);
export const ramp = (v, a, b) => clamp((v - a) / (b - a), 0, 1);
export function skyAt(hour, dates = DEFAULT_SCHEDULE) {
  const [dawn, rise, noon, afternoon, set, nightfall] = dates;
  const night = [[0.02, 0.03, 0.09], [0.07, 0.1, 0.23], 1, 0];
  const between = (a, b, t) => a + (b - a) * t;
  const moments = [
    [dawn - 2 / 3, night],
    [dawn, [[0.03, 0.05, 0.15], [0.14, 0.17, 0.36], 0.92, 0.12]],
    [
      between(dawn, rise, 0.55),
      [[0.08, 0.1, 0.28], [0.5, 0.32, 0.4], 0.62, 0.6],
    ],
    [rise, [[0.13, 0.22, 0.47], [0.93, 0.6, 0.4], 0.28, 1]],
    [
      Math.min(rise + 0.75, between(rise, noon, 0.5)),
      [[0.09, 0.27, 0.56], [0.56, 0.71, 0.88], 0, 0.22],
    ],
    [noon, [[0.05, 0.18, 0.43], [0.21, 0.45, 0.74], 0, 0]],
    [afternoon, [[0.06, 0.17, 0.4], [0.3, 0.46, 0.67], 0, 0]],
    [
      Math.max(set - 3300 / 3600, between(afternoon, set, 0.35)),
      [[0.09, 0.17, 0.4], [0.66, 0.54, 0.46], 0.05, 0.45],
    ],
    [set, [[0.13, 0.11, 0.32], [0.93, 0.44, 0.27], 0.35, 1]],
    [
      between(set, nightfall, 0.45),
      [[0.07, 0.07, 0.24], [0.54, 0.26, 0.32], 0.66, 0.55],
    ],
    [nightfall, [[0.03, 0.04, 0.14], [0.11, 0.14, 0.33], 0.92, 0.08]],
    [nightfall + 2 / 3, night],
  ];
  let value = night;
  for (let i = 0; i < moments.length - 1; i++) {
    const [start, a] = moments[i],
      [end, b] = moments[i + 1];
    if (hour >= start && hour < end) {
      const t = (hour - start) / Math.max(end - start, 1 / 3600);
      value = [
        mix(a[0], b[0], t),
        mix(a[1], b[1], t),
        a[2] + (b[2] - a[2]) * t,
        a[3] + (b[3] - a[3]) * t,
      ];
      break;
    }
  }
  return { top: value[0], low: value[1], darkness: value[2], glow: value[3] };
}
export function timeLabel(hour) {
  const minutes = Math.round(hour * 60);
  return `${String(Math.floor(minutes / 60) % 24).padStart(2, "0")}:${String(minutes % 60).padStart(2, "0")}`;
}

function validateWater(water) {
  const result = {
    x: finite(water.x, 0, 1, "Water X"),
    y: finite(water.y, 0, 1, "Water Y"),
    width: finite(water.width, 0.001, 1, "Water width"),
    height: finite(water.height, 0.001, 1, "Water height"),
    opacity: finite(water.opacity, 0, 1, "Water opacity"),
  };
  if (result.x + result.width > 1.000001 || result.y + result.height > 1.000001)
    throw Error("Water bounds must stay inside the artwork.");
  return result;
}

function validateNativeReference(value, allowSources) {
  const id = string(value.id, "Native scene ID");
  if (!/^[a-zA-Z0-9_-]+$/.test(id)) throw Error("Invalid native scene ID.");
  const runtime={};
  if(value.runtimeData){if(typeof value.runtimeData!=="string"||!/^data:application\/wasm(?:\+gzip)?;base64,[A-Za-z0-9+/=]+$/.test(value.runtimeData)||value.runtimeData.length>40000000)throw Error("Invalid embedded Swift runtime.");runtime.runtimeData=value.runtimeData;}
  else if(value.runtimeSrc){if(!allowSources||!/^runtime\/[a-zA-Z0-9_.-]+\.wasm(?:\.gz)?$/.test(value.runtimeSrc))throw Error("Invalid Swift runtime source.");runtime.runtimeSrc=value.runtimeSrc;}
  if (value.data) return { id, data: validateNativeScene(value.data),...runtime };
  if (
    allowSources &&
    typeof value.src === "string" &&
    /^library\/[a-zA-Z0-9_.-]+\.json(?:\.gz)?$/.test(value.src)
  )
    return { id, src: value.src,...runtime };
  throw Error("Missing embedded native scene geometry.");
}

function validateBoat(boat) {
  if (!/^#[0-9a-fA-F]{6}$/.test(boat.color)) throw Error("Invalid boat color.");
  return {
    x: finite(boat.x, 0, 1, "Boat X"),
    y: finite(boat.y, 0, 1, "Boat Y"),
    amplitude: finite(boat.amplitude, 0, 0.5, "Boat drift"),
    frequency: finite(boat.frequency, 0, 10, "Boat speed"),
    width: finite(boat.width, 1, 200, "Boat width"),
    height: finite(boat.height, 0.001, 0.2, "Boat height"),
    color: boat.color,
  };
}
