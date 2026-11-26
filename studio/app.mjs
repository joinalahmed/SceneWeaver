import {
  validateProject,
  blankProject,
  WEATHER,
  artworkRect,
  id,
  assetName,
  clamp,
  reorder,
  timeLabel,
} from "./model.mjs";
import { generateSwift, zipFiles } from "./export.mjs";
import { createRenderer, decodeArtwork } from "./render.mjs?v=playback-3";

import { advanceDayHour } from "./playback.mjs";

const $ = (selector) => document.querySelector(selector);
const icon = (name) =>
  `<svg class="icon" aria-hidden="true"><use href="#i-${name}"/></svg>`;
const escape = (value) =>
  String(value).replace(
    /[&<>"']/g,
    (c) =>
      ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" })[
        c
      ],
  );
let project = blankProject(),
  images = new Map(),
  selected = null,
  lightID = null,
  tool = "select",
  guides = true,
  currentFrame,
  loading = false;
let playing = false,
  playTimer,
  playTimestamp;
function syncPlayback() {
  $("#play").innerHTML = icon(playing ? "pause" : "play");
  $("#play").setAttribute(
    "aria-label",
    playing ? "Pause day cycle" : "Play day cycle",
  );
  $("#play").setAttribute("aria-pressed", playing);
}
function setPlayback(value, save = true) {
  playing = value;
  clearInterval(playTimer);
  if (playing) {
    playTimestamp = performance.now();
    playTimer = setInterval(() => {
      const now = performance.now();
      if (!document.hidden) {
        project.settings.hour = advanceDayHour(
          project.settings.hour,
          now - playTimestamp,
        );
        $("#hour").value = project.settings.hour;
        $("#hour-label").textContent = timeLabel(project.settings.hour);
      }
      playTimestamp = now;
    }, 120);
  } else if (save) changed(false);
  syncPlayback();
}
document.addEventListener("visibilitychange", () => {
  playTimestamp = performance.now();
});

let catalog = [],
  toastTimer,
  saveTimer,
  history = [];
const selectedLayer = () => project.layers.find((l) => l.id === selected);
const selectedLight = () =>
  selectedLayer()?.lights.find((l) => l.id === lightID);
function setInspector(tab) {
  document.body.dataset.inspector = tab;
  $("#layer-properties").hidden = tab !== "layer";
  $("#scene-settings").hidden = tab !== "scene";
  document
    .querySelectorAll("[data-inspector][role=tab]")
    .forEach((button) =>
      button.setAttribute("aria-selected", button.dataset.inspector === tab),
    );
}
function setPanel(panel) {
  document.body.dataset.panel = panel;
  document
    .querySelectorAll("#mobile-nav [data-panel]")
    .forEach((button) =>
      button.setAttribute("aria-pressed", button.dataset.panel === panel),
    );
}
function fitArtboard() {
  const area = $("#stage-area");
  if (!area.clientWidth || !area.clientHeight) return;
  const css = getComputedStyle(area),
    caption = $(".artboard-caption");
  const width =
    area.clientWidth -
    parseFloat(css.paddingLeft) -
    parseFloat(css.paddingRight);
  const height =
    area.clientHeight -
    parseFloat(css.paddingTop) -
    parseFloat(css.paddingBottom) -
    caption.offsetHeight -
    8;
  $(".artboard").style.width =
    `${Math.max(1, Math.min(width, Math.max(40, height) * project.settings.viewport))}px`;
}
document
  .querySelectorAll("[data-inspector][role=tab]")
  .forEach(
    (button) => (button.onclick = () => setInspector(button.dataset.inspector)),
  );
document
  .querySelectorAll("#mobile-nav [data-panel]")
  .forEach((button) => (button.onclick = () => setPanel(button.dataset.panel)));
new ResizeObserver(fitArtboard).observe($("#stage-area"));
function toast(message) {
  $("#toast").textContent = message;
  $("#toast").classList.add("visible");
  clearTimeout(toastTimer);
  toastTimer = setTimeout(() => $("#toast").classList.remove("visible"), 5500);
}
function checkpoint() {
  history.push(structuredClone(project));
  if (history.length > 12) history.shift();
  $("#undo").disabled = false;
}
function changed(rebuild = true) {
  if (rebuild) render();
  $("#save-status").textContent = "Saving changes…";
  clearTimeout(saveTimer);
  saveTimer = setTimeout(async () => {
    try {
      await persist();
      $("#save-status").textContent = "Saved on this device";
    } catch {
      $("#save-status").textContent = "Download to save";
      toast(
        "Browser storage is unavailable. Use Save project to keep your work.",
      );
    }
  }, 600);
}
function commit(action) {
  checkpoint();
  action();
  changed();
}
async function database() {
  return new Promise((resolve, reject) => {
    const request = indexedDB.open("sceneweaver-studio", 1);
    request.onupgradeneeded = () =>
      request.result.createObjectStore("projects");
    request.onsuccess = () => resolve(request.result);
    request.onerror = () => reject(request.error);
  });
}
async function storage(mode, action) {
  const db = await database();
  return new Promise((resolve, reject) => {
    const tx = db.transaction("projects", mode),
      request = action(tx.objectStore("projects"));
    let result;
    request.onsuccess = () => {
      result = request.result;
    };
    tx.oncomplete = () => {
      db.close();
      resolve(result);
    };
    tx.onerror = () => {
      db.close();
      reject(tx.error);
    };
    tx.onabort = () => {
      db.close();
      reject(tx.error);
    };
  });
}
async function persist() {
  await storage("readwrite", (store) => store.put(project, "current"));
}
async function applyProject(input, { undo = true } = {}) {
  setPlayback(false, false);
  const next = validateProject(input),
    decoded = new Map();
  await Promise.all(
    next.layers.map(async (layer) =>
      decoded.set(layer.id, await decodeArtwork(layer.asset.data)),
    ),
  );
  if (undo) checkpoint();
  project = next;
  images = decoded;
  selected = next.layers.at(-1)?.id ?? null;
  lightID = null;
  tool = "select";
  setInspector("layer");
  setPanel("canvas");
  changed();
}
function setTool(value) {
  tool = value;
  document
    .querySelectorAll("[data-tool]")
    .forEach((b) => b.classList.toggle("active", b.dataset.tool === tool));
  $("#stage").style.cursor = tool === "select" ? "default" : "crosshair";
  $("#placement-hint").textContent =
    tool === "select"
      ? "Select a layer to edit its lights."
      : `Click on the selected layer to place a ${tool === "lamp" ? "lamp" : "floodlight"}. Drag its handle to refine.`;
}
function render() {
  $("#undo").disabled = history.length === 0;
  const s = project.settings;
  $("#project-name").value = project.name;
  $("#hour").value = s.hour;
  $("#hour-label").textContent = timeLabel(s.hour);
  $("#weather").value = s.weather;
  $("#ground").value = s.ground;
  $("#ground-value").textContent = `${s.ground} pt`;
  $("#overscan").value = s.overscan;
  $("#overscan-value").textContent = `${Math.round(s.overscan * 100)}%`;
  $("#art-aspect").value = s.aspectRatio;
  $("#viewport").value =
    Array.from($("#viewport").options).find(
      (o) => Math.abs(Number(o.value) - s.viewport) < 0.001,
    )?.value ?? "";
  $("#stage").style.aspectRatio = s.viewport;
  $("#stage").style.width = "100%";
  fitArtboard();
  $("#layer-count").textContent =
    `${project.layers.length} layer${project.layers.length === 1 ? "" : "s"}`;
  $("#empty-state").hidden = project.layers.length > 0;
  $("#scene-summary").textContent =
    `${project.name} · ${project.layers.filter((l) => l.visible).length} visible layers`;
  syncPlayback();
  $("#layers").innerHTML = [...project.layers]
    .reverse()
    .map(
      (l) =>
        `<div class="layer ${selected === l.id ? "selected" : ""} ${l.visible ? "" : "hidden"}" data-layer="${escape(l.id)}" draggable="true"><button class="layer-select" aria-label="Select ${escape(l.name)}" aria-pressed="${selected === l.id}"><img class="layer-thumb" alt="" src="${escape(l.asset.data)}"><span><span class="layer-name">${escape(l.name)}</span><span class="layer-meta">Depth ${l.depth.toFixed(1)} · ${l.lights.length} light${l.lights.length === 1 ? "" : "s"}</span></span></button><button class="eye" data-visible="${escape(l.id)}" title="${l.visible ? "Hide" : "Show"} layer" aria-label="${l.visible ? "Hide" : "Show"} ${escape(l.name)}">${icon(l.visible ? "eye" : "eyeOff")}</button></div>`,
    )
    .join("");
  const l = selectedLayer();
  $("#layer-inspector").innerHTML = l
    ? `<div class="section-label"><h2>Selected layer</h2><span class="subtle">${project.layers.indexOf(l) + 1} / ${project.layers.length}</span></div><label class="field-label" for="layer-name">Layer name</label><input id="layer-name" type="text" maxlength="100" value="${escape(l.name)}"><label class="field-label" for="asset-name" style="margin-top:14px">Xcode asset name</label><input id="asset-name" type="text" maxlength="64" value="${escape(l.asset.name)}"><div class="range-label"><label for="depth">Motion depth</label><output id="depth-value">${l.depth.toFixed(1)}</output></div><input id="depth" type="range" min="0" max="8" step="0.1" value="${l.depth}"><div class="range-label"><label for="dim">Night dimming</label><output id="dim-value">${Math.round(l.dim * 100)}%</output></div><input id="dim" type="range" min="0" max="0.9" step="0.01" value="${l.dim}"><div class="layer-actions"><button id="layer-back" ${project.layers.indexOf(l) === 0 ? "disabled" : ""} title="Move backward">${icon("back")} Back</button><button id="layer-front" ${project.layers.indexOf(l) === project.layers.length - 1 ? "disabled" : ""} title="Move forward">${icon("front")} Front</button><button id="delete-layer" class="danger">Delete</button></div><div class="range-label"><span>Lights on this plate</span><span>${l.lights.length}</span></div><div class="lights-list">${l.lights.map((x, i) => `<button data-light="${escape(x.id)}" class="${x.id === lightID ? "active" : ""}">${icon(x.type === "lamp" ? "lamp" : "flood")} ${i + 1}</button>`).join("") || '<span class="help">Choose Lamp or Floodlight above the canvas.</span>'}</div>`
    : '<h2>No layer selected</h2><p class="help">Choose a layer or import aligned transparent artwork to begin.</p>';
  const light = selectedLight();
  $("#light-inspector").innerHTML = light
    ? `<div class="section-label"><h2>${light.type === "lamp" ? "Lamp" : "Floodlight"}</h2><button class="small" id="delete-light" aria-label="Delete selected light">Remove</button></div><div class="input-row"><label for="light-x">X position</label><input id="light-x" type="number" min="0" max="1" step="0.001" value="${light.x.toFixed(3)}"></div><div class="input-row"><label for="light-y">Y position</label><input id="light-y" type="number" min="0" max="1" step="0.001" value="${light.y.toFixed(3)}"></div><div class="range-label"><label for="light-radius">${light.type === "lamp" ? "Halo" : "Flood"} radius</label><output id="radius-value">${light.radius.toFixed(3)}</output></div><input id="light-radius" type="range" min="0.001" max="${light.type === "lamp" ? ".08" : ".6"}" step="0.001" value="${light.radius}">${light.type === "flood" ? `<div class="range-label"><label for="light-intensity">Intensity</label><output id="intensity-value">${Math.round(light.intensity * 100)}%</output></div><input id="light-intensity" type="range" min="0" max="1" step="0.01" value="${light.intensity}">` : ""}<div class="input-row"><label for="light-color">Light color</label><input id="light-color" type="color" value="${light.color}"></div><p class="help">Positions are normalized to the image, from its top left. Night lighting fades in automatically.</p>`
    : "";
  $("#schedule").innerHTML = [
    "Dawn",
    "Sunrise",
    "Noon",
    "Afternoon",
    "Sunset",
    "Night",
  ]
    .map(
      (name, i) =>
        `<label>${name}<input type="number" data-schedule="${i}" min="0" max="24" step="0.05" value="${s.schedule[i]}"></label>`,
    )
    .join("");
  renderHandles();
  setTool(tool);
}
function renderHandles() {
  const l = selectedLayer();
  $("#handles").replaceChildren();
  if (!guides || !l?.visible) return;
  for (const light of l.lights) {
    const b = document.createElement("button");
    b.className = `handle ${light.type} ${light.id === lightID ? "selected" : ""}`;
    b.dataset.handle = light.id;
    b.setAttribute(
      "aria-label",
      `${light.type} at ${Math.round(light.x * 100)}%, ${Math.round(light.y * 100)}%. Drag or use arrow keys to move.`,
    );
    b.title = "Drag to move · arrow keys to nudge";
    $("#handles").append(b);
  }
  positionHandles();
}
function positionHandles() {
  const rect = currentFrame?.rects.get(selected);
  if (!rect) return;
  const layer = selectedLayer();
  for (const b of $("#handles").children) {
    const l = layer?.lights.find((x) => x.id === b.dataset.handle);
    if (l) {
      b.style.left = `${rect.x + l.x * rect.width}px`;
      b.style.top = `${rect.y + l.y * rect.height}px`;
    }
  }
}
createRenderer(
  $("#preview"),
  () => ({ ...project, settings: { ...project.settings, motion: playing } }),
  () => images,
  (frame) => {
    currentFrame = frame;
    positionHandles();
  },
);

$("#layers").addEventListener("click", (e) => {
  const visibility = e.target.closest("[data-visible]");
  if (visibility) {
    commit(() => {
      const l = project.layers.find((l) => l.id === visibility.dataset.visible);
      l.visible = !l.visible;
    });
    return;
  }
  const el = e.target.closest("[data-layer]");
  if (el) {
    selected = el.dataset.layer;
    lightID = null;
    setInspector("layer");
    setPanel("canvas");
    render();
  }
});
$("#layers").addEventListener("keydown", (e) => {
  if (["Enter", " "].includes(e.key) && e.target.matches("[data-layer]")) {
    e.preventDefault();
    e.target.click();
  }
});
let dragLayer;
$("#layers").addEventListener("dragstart", (e) => {
  dragLayer = e.target.closest("[data-layer]")?.dataset.layer;
  if (dragLayer) {
    e.dataTransfer.setData("text/plain", dragLayer);
    e.target.classList.add("dragging");
  }
});
$("#layers").addEventListener("dragend", () => {
  dragLayer = null;
  render();
});
$("#layers").addEventListener("dragover", (e) => e.preventDefault());
$("#layers").addEventListener("drop", (e) => {
  e.preventDefault();
  const target = e.target.closest("[data-layer]")?.dataset.layer;
  if (target && dragLayer && target !== dragLayer)
    commit(() => {
      project.layers = reorder(
        project.layers,
        project.layers.findIndex((l) => l.id === dragLayer),
        project.layers.findIndex((l) => l.id === target),
      );
    });
});
document.querySelectorAll("[data-tool]").forEach(
  (b) =>
    (b.onclick = () => {
      if (!selectedLayer()) {
        toast("Select an image layer first.");
        return;
      }
      setTool(b.dataset.tool);
    }),
);
$("#toggle-guides").onclick = () => {
  guides = !guides;
  $("#toggle-guides").setAttribute("aria-pressed", guides);
  renderHandles();
};
let dragging;
$("#stage").addEventListener("pointerdown", (e) => {
  const handle = e.target.closest("[data-handle]"),
    layer = selectedLayer();
  if (!layer?.visible) return;
  if (handle) {
    setInspector("layer");
    e.preventDefault();
    checkpoint();
    lightID = handle.dataset.handle;
    render();
    dragging = { id: lightID, pointer: e.pointerId };
    $("#stage").setPointerCapture(e.pointerId);
    return;
  }
  if (tool === "select") return;
  setInspector("layer");
  const rect = currentFrame?.rects.get(selected),
    box = $("#stage").getBoundingClientRect();
  if (!rect) return;
  const x = (e.clientX - box.left - rect.x) / rect.width,
    y = (e.clientY - box.top - rect.y) / rect.height;
  if (x < 0 || x > 1 || y < 0 || y > 1) {
    toast("Place lights inside the selected artwork plate.");
    return;
  }
  if (layer.lights.length >= 100) {
    toast("This plate already has 100 lights.");
    return;
  }
  commit(() => {
    const light = {
      id: id(),
      type: tool,
      x,
      y,
      radius: tool === "lamp" ? 0.012 : 0.17,
      intensity: 0.34,
      color: tool === "lamp" ? "#ffd682" : "#ffc76b",
    };
    layer.lights.push(light);
    lightID = light.id;
  });
});
$("#stage").addEventListener("pointermove", (e) => {
  if (!dragging) return;
  const light = selectedLight(),
    rect = currentFrame?.rects.get(selected),
    box = $("#stage").getBoundingClientRect();
  if (!light || !rect) return;
  light.x = clamp((e.clientX - box.left - rect.x) / rect.width, 0, 1);
  light.y = clamp((e.clientY - box.top - rect.y) / rect.height, 0, 1);
  if ($("#light-x")) $("#light-x").value = light.x.toFixed(3);
  if ($("#light-y")) $("#light-y").value = light.y.toFixed(3);
});
for (const event of ["pointerup", "pointercancel"])
  $("#stage").addEventListener(event, () => {
    if (dragging) {
      dragging = null;
      changed();
    }
  });
$("#handles").addEventListener("keydown", (e) => {
  if (!e.target.dataset.handle) return;
  const arrows = ["ArrowUp", "ArrowDown", "ArrowLeft", "ArrowRight"];
  if (![...arrows, "Enter", " "].includes(e.key)) return;
  e.preventDefault();
  lightID = e.target.dataset.handle;
  setInspector("layer");
  if (arrows.includes(e.key)) {
    checkpoint();
    const light = selectedLight(),
      step = e.shiftKey ? 0.01 : 0.001;
    if (e.key === "ArrowUp") light.y = clamp(light.y - step, 0, 1);
    if (e.key === "ArrowDown") light.y = clamp(light.y + step, 0, 1);
    if (e.key === "ArrowLeft") light.x = clamp(light.x - step, 0, 1);
    if (e.key === "ArrowRight") light.x = clamp(light.x + step, 0, 1);
    changed();
  } else render();
  [...$("#handles").children]
    .find((button) => button.dataset.handle === lightID)
    ?.focus({ preventScroll: true });
});

for (const key of ["hour", "ground", "overscan"]) {
  $("#" + key).addEventListener("pointerdown", () => {
    if (key === "hour") setPlayback(false);
    checkpoint();
  });
  $("#" + key).addEventListener("input", (e) => {
    if (key === "hour") setPlayback(false);
    project.settings[key] = Number(e.target.value);
    $(
      "#" +
        {
          hour: "hour-label",
          ground: "ground-value",
          overscan: "overscan-value",
        }[key],
    ).textContent =
      key === "hour"
        ? timeLabel(project.settings.hour)
        : key === "ground"
          ? `${project.settings.ground} pt`
          : `${Math.round(project.settings.overscan * 100)}%`;
    changed(false);
  });
}
$("#weather").onchange = (e) =>
  commit(() => (project.settings.weather = e.target.value));
$("#viewport").onchange = (e) =>
  commit(() => (project.settings.viewport = Number(e.target.value)));
$("#art-aspect").onchange = (e) => {
  const value = Number(e.target.value);
  if (value < 0.25 || value > 4 || !Number.isFinite(value)) {
    render();
    toast("Artwork ratio must be between 0.25 and 4.");
    return;
  }
  commit(() => (project.settings.aspectRatio = value));
};
$("#project-name").onchange = (e) => {
  const value = e.target.value.trim();
  if (value) commit(() => (project.name = value));
  else render();
};
$("#play").onclick = () => {
  if (!playing) checkpoint();
  setPlayback(!playing);
};
document.querySelectorAll("[data-hour]").forEach(
  (b) =>
    (b.onclick = () =>
      commit(() => {
        setPlayback(false, false);
        project.settings.hour = Number(b.dataset.hour);
      })),
);
$(".inspector").addEventListener("pointerdown", (e) => {
  if (e.target.matches("input[type=range],input[type=color]")) checkpoint();
});
$(".inspector").addEventListener("input", (e) => {
  const l = selectedLayer(),
    light = selectedLight(),
    value = Number(e.target.value);
  if (e.target.id === "depth" && l) {
    l.depth = value;
    $("#depth-value").textContent = value.toFixed(1);
    changed(false);
  }
  if (e.target.id === "dim" && l) {
    l.dim = value;
    $("#dim-value").textContent = `${Math.round(value * 100)}%`;
    changed(false);
  }
  if (e.target.id === "light-radius" && light) {
    light.radius = value;
    $("#radius-value").textContent = value.toFixed(3);
    changed(false);
  }
  if (e.target.id === "light-intensity" && light) {
    light.intensity = value;
    $("#intensity-value").textContent = `${Math.round(value * 100)}%`;
    changed(false);
  }
  if (e.target.id === "light-color" && light) {
    light.color = e.target.value;
    changed(false);
  }
});
$(".inspector").addEventListener("change", (e) => {
  const l = selectedLayer(),
    light = selectedLight(),
    value = Number(e.target.value);
  if (e.target.id === "layer-name" && l) {
    const name = e.target.value.trim();
    if (name) commit(() => (l.name = name));
    else render();
  }
  if (e.target.id === "asset-name" && l) {
    const name = e.target.value.trim();
    if (
      !/^[A-Za-z][A-Za-z0-9_]{0,63}$/.test(name) ||
      project.layers.some(
        (other) =>
          other !== l && other.asset.name.toLowerCase() === name.toLowerCase(),
      )
    ) {
      toast(
        "Use a unique asset name, starting with a letter, with letters, numbers and underscores only.",
      );
      render();
      return;
    }
    commit(() => (l.asset.name = name));
  }
  if (["light-x", "light-y"].includes(e.target.id) && light) {
    if (!Number.isFinite(value) || value < 0 || value > 1) {
      render();
      return;
    }
    commit(() => (light[e.target.id.at(-1)] = value));
  }
  if (e.target.dataset.schedule !== undefined) {
    const next = [...project.settings.schedule];
    next[Number(e.target.dataset.schedule)] = value;
    try {
      validateProject({
        ...project,
        settings: { ...project.settings, schedule: next },
      });
      commit(() => (project.settings.schedule = next));
    } catch (error) {
      toast(error.message);
      render();
    }
  }
});
$(".inspector").addEventListener("click", (e) => {
  const l = selectedLayer();
  if (e.target.dataset.light) {
    lightID = e.target.dataset.light;
    render();
    return;
  }
  if (!l) return;
  if (e.target.id === "delete-layer")
    commit(() => {
      images.delete(l.id);
      project.layers = project.layers.filter((x) => x !== l);
      selected = project.layers.at(-1)?.id ?? null;
      lightID = null;
    });
  if (e.target.id === "delete-light")
    commit(() => {
      l.lights = l.lights.filter((x) => x.id !== lightID);
      lightID = null;
    });
  if (["layer-front", "layer-back"].includes(e.target.id))
    commit(() => {
      const from = project.layers.indexOf(l);
      project.layers = reorder(
        project.layers,
        from,
        from + (e.target.id === "layer-front" ? 1 : -1),
      );
    });
});

async function importImages(files) {
  const list = [...files];
  if (!list.length) return;
  if (project.layers.length + list.length > 24) {
    toast("A project supports up to 24 layers.");
    return;
  }
  $("#add-layer").disabled = true;
  try {
    const additions = [];
    for (const file of list) {
      if (!["image/png", "image/jpeg", "image/webp"].includes(file.type))
        throw Error(
          "Import PNG, JPEG or WebP artwork. Transparent PNG or WebP is best.",
        );
      if (file.size > 12000000)
        throw Error("Each image must be smaller than 12 MB.");
      const data = await new Promise((resolve, reject) => {
          const r = new FileReader();
          r.onload = () => resolve(r.result);
          r.onerror = reject;
          r.readAsDataURL(file);
        }),
        image = await decodeArtwork(data);
      let name = assetName(file.name.replace(/\.[^.]+$/, "")),
        suffix = 1;
      while (
        [...project.layers, ...additions.map((x) => x.layer)].some(
          (l) => l.asset.name.toLowerCase() === name.toLowerCase(),
        )
      )
        name =
          assetName(file.name.replace(/\.[^.]+$/, "")).slice(0, 60) + suffix++;
      const layer = {
        id: id(),
        name: file.name.replace(/\.[^.]+$/, ""),
        visible: true,
        depth: 1,
        dim: 0.46,
        asset: { name, data },
        lights: [],
      };
      additions.push({ layer, image });
    }
    validateProject({
      ...project,
      layers: [...project.layers, ...additions.map((x) => x.layer)],
    });
    commit(() => {
      for (const { layer, image } of additions) {
        project.layers.push(layer);
        images.set(layer.id, image);
        selected = layer.id;
      }
      lightID = null;
    });
    toast(
      `Added ${additions.length} image layer${additions.length === 1 ? "" : "s"}. Set the shared artwork ratio to match your source canvas.`,
    );
  } catch (error) {
    toast(error.message || "Could not open this artwork.");
  } finally {
    $("#add-layer").disabled = false;
  }
}
$("#add-layer").onclick = () => $("#image-input").click();
$("#drop-zone").onclick = () => $("#image-input").click();
$("#drop-zone").onkeydown = (e) => {
  if (["Enter", " "].includes(e.key)) {
    e.preventDefault();
    $("#image-input").click();
  }
};
$("#image-input").onchange = async (e) => {
  await importImages(e.target.files);
  e.target.value = "";
};
$("#drop-zone").ondragover = (e) => {
  e.preventDefault();
  $("#drop-zone").classList.add("over");
};
$("#drop-zone").ondragleave = () => $("#drop-zone").classList.remove("over");
$("#drop-zone").ondrop = (e) => {
  e.preventDefault();
  $("#drop-zone").classList.remove("over");
  importImages(e.dataTransfer.files);
};
function download(blob, name) {
  const url = URL.createObjectURL(blob),
    a = document.createElement("a");
  a.href = url;
  a.download = name;
  a.click();
  setTimeout(() => URL.revokeObjectURL(url), 10000);
}
const slug = () =>
  project.name
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-|-$/g, "") || "sceneweaver";
$("#save-project").onclick = () => {
  download(
    new Blob([JSON.stringify(project, null, 2)], { type: "application/json" }),
    `${slug()}.sceneweaver.json`,
  );
  toast("Project saved with embedded artwork.");
};
$("#open-project").onclick = () => $("#project-input").click();
$("#project-input").onchange = async (e) => {
  const file = e.target.files[0];
  if (!file) return;
  try {
    if (file.size > 50000000)
      throw Error("Project exceeds the 50 MB import limit.");
    await applyProject(JSON.parse(await file.text()));
    $("#preset").value = "";
    toast("Project opened.");
  } catch (error) {
    toast(error.message || "Could not open this project.");
  } finally {
    e.target.value = "";
  }
};
function showCode() {
  try {
    $("#swift-code").textContent = generateSwift(project);
    $("#code-dialog").showModal();
  } catch (error) {
    toast(error.message);
  }
}
$("#view-code").onclick = showCode;
$("#close-code").onclick = () => $("#code-dialog").close();
$("#copy-code").onclick = async () => {
  try {
    await navigator.clipboard.writeText(generateSwift(project));
    toast("Swift code copied.");
  } catch {
    toast("Clipboard is unavailable. Use Download Swift.");
  }
};
$("#download-code").onclick = () =>
  download(
    new Blob([generateSwift(project)], { type: "text/plain" }),
    "ComposedScene.swift",
  );
async function exportBundle() {
  if (loading) return;
  loading = true;
  $("#export").disabled = true;
  $("#export-dialog").disabled = true;
  try {
    const p = validateProject(project),
      exportImages = new Map(images),
      files = [
        { name: "ComposedScene.swift", data: generateSwift(p) },
        { name: "sceneweaver-project.json", data: JSON.stringify(p, null, 2) },
        {
          name: "Assets.xcassets/Contents.json",
          data: JSON.stringify({
            info: { version: 1, author: "SceneWeaver Studio" },
          }),
        },
      ];
    for (const layer of p.layers.filter((l) => l.visible)) {
      const image = exportImages.get(layer.id);
      if (!image) throw Error(`Artwork for ${layer.name} is not ready.`);
      const canvas = document.createElement("canvas");
      canvas.width = image.naturalWidth;
      canvas.height = image.naturalHeight;
      canvas.getContext("2d").drawImage(image, 0, 0);
      const png = await new Promise((resolve) =>
        canvas.toBlob(resolve, "image/png"),
      );
      if (!png) throw Error("Could not rasterize artwork.");
      files.push(
        {
          name: `Assets.xcassets/${layer.asset.name}.imageset/${layer.asset.name}.png`,
          data: new Uint8Array(await png.arrayBuffer()),
        },
        {
          name: `Assets.xcassets/${layer.asset.name}.imageset/Contents.json`,
          data: JSON.stringify(
            {
              images: [
                { filename: `${layer.asset.name}.png`, idiom: "universal" },
              ],
              info: { version: 1, author: "SceneWeaver Studio" },
            },
            null,
            2,
          ),
        },
      );
    }
    files.push({
      name: "README.txt",
      data: `${p.name}\n\n1. Add https://github.com/joinalahmed/SceneWeaver to your Xcode app target (0.1.0 or later).\n2. Add ComposedScene.swift and Assets.xcassets to the app target. If you already have an asset catalog, merge the imagesets into it.\n3. Use ComposedScene() in your UI. It follows the current clock; provide previewDate to inspect a fixed time.\n\nThe artwork and lamp coordinates are exported together. Browser rendering approximates the native Canvas engine; check your final composition on an iOS simulator or device.\n\nThe built-in artwork is MIT licensed (copyright 2026 Joinal Ahmed). Your imported artwork retains its own license.\nProject preview hour: ${timeLabel(p.settings.hour)}.\n`,
    });
    download(zipFiles(files), `${slug()}-swiftui.zip`);
    toast(
      "SwiftUI bundle exported. Add the view and asset catalog to your app.",
    );
  } catch (error) {
    toast(error.message || "Export failed.");
  } finally {
    loading = false;
    $("#export").disabled = false;
    $("#export-dialog").disabled = false;
  }
}
$("#export").onclick = exportBundle;
$("#export-dialog").onclick = exportBundle;
$("#preset").onchange = async (e) => {
  const value = e.target.value;
  try {
    if (value === "blank") {
      await applyProject(blankProject());
      return;
    }
    const entry = catalog.find((s) => s.id === value);
    if (entry) await loadPreset(entry);
  } catch (error) {
    toast(error.message);
  }
};
async function loadPreset(entry, { undo = true } = {}) {
  const url = new URL(`assets/${entry.project}`, location.href),
    response = await fetch(url);
  if (!response.ok) throw Error("Could not load the starter scene.");
  const p = validateProject(await response.json(), { allowSources: true });
  for (const l of p.layers) {
    const assetURL = new URL(l.asset.src, url);
    if (
      assetURL.origin !== location.origin ||
      !assetURL.pathname.startsWith(new URL("assets/", location.href).pathname)
    )
      throw Error("Starter artwork must stay inside the asset catalog.");
    const res = await fetch(assetURL);
    if (!res.ok) throw Error(`Missing starter artwork: ${l.asset.name}`);
    const blob = await res.blob();
    l.asset = {
      name: l.asset.name,
      data: await new Promise((resolve, reject) => {
        const reader = new FileReader();
        reader.onload = () => resolve(reader.result);
        reader.onerror = reject;
        reader.readAsDataURL(blob);
      }),
    };
  }
  await applyProject(p, { undo });
  $("#preset").value = entry.id;
}
async function undo() {
  if (!history.length) return;
  const previous = history.pop();
  try {
    await applyProject(previous, { undo: false });
    toast("Undid the last edit.");
  } catch (error) {
    toast(error.message);
  }
}
$("#undo").onclick = undo;
document.addEventListener("keydown", (e) => {
  if (e.key === "Escape" && tool !== "select") setTool("select");
  if ((e.metaKey || e.ctrlKey) && e.key.toLowerCase() === "s") {
    e.preventDefault();
    $("#save-project").click();
  }
  if (
    (e.metaKey || e.ctrlKey) &&
    e.key.toLowerCase() === "z" &&
    !e.target.matches("input,select,textarea") &&
    history.length
  ) {
    e.preventDefault();
    undo();
  }
});

async function start() {
  try {
    const response = await fetch("assets/catalog.json");
    if (!response.ok) throw Error("Could not load the scene catalog.");
    catalog = (await response.json()).scenes;
    $("#preset").innerHTML =
      catalog
        .map(
          (x) => `<option value="${escape(x.id)}">${escape(x.name)}</option>`,
        )
        .join("") + '<option value="blank">Blank canvas</option>';
    let saved;
    try {
      saved = await storage("readonly", (store) => store.get("current"));
    } catch {
      /* Saving remains available through project downloads. */
    }
    if (saved) {
      await applyProject(saved, { undo: false });
      $("#preset").value = "";
    } else if (catalog[0]) await loadPreset(catalog[0], { undo: false });
  } catch (error) {
    toast(error.message);
    render();
  }
}
render();
start();
