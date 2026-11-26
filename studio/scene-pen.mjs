/** Platform-neutral path construction. Browser-only Path2D is created at draw time. */
export class ScenePath {
  constructor(commands = []) {
    this.commands = commands;
  }
  move(to) {
    this.commands.push(["M", to.x, to.y]);
    return this;
  }
  moveTo(x, y) {
    return this.move(typeof x === "object" ? x : { x, y });
  }
  addLine(to) {
    this.commands.push(["L", to.x, to.y]);
    return this;
  }
  lineTo(x, y) {
    return this.addLine(typeof x === "object" ? x : { x, y });
  }
  addCurve(to, a, b) {
    this.commands.push(["C", a.x, a.y, b.x, b.y, to.x, to.y]);
    return this;
  }
  bezierCurveTo(ax, ay, bx, by, x, y) {
    return this.addCurve({ x, y }, { x: ax, y: ay }, { x: bx, y: by });
  }
  addQuadCurve(to, c) {
    this.commands.push(["Q", c.x, c.y, to.x, to.y]);
    return this;
  }
  quadraticCurveTo(cx, cy, x, y) {
    return this.addQuadCurve({ x, y }, { x: cx, y: cy });
  }
  closeSubpath() {
    this.commands.push(["Z"]);
    return this;
  }
  closePath() {
    return this.closeSubpath();
  }
  addPath(other) {
    this.commands.push(...other.commands.map((c) => [...c]));
    return this;
  }
  applying([a, b, c, d, tx, ty]) {
    return new ScenePath(
      this.commands.map(([op, ...v]) => {
        const result = [op];
        for (let i = 0; i < v.length; i += 2)
          result.push(
            a * v[i] + c * v[i + 1] + tx,
            b * v[i] + d * v[i + 1] + ty,
          );
        return result;
      }),
    );
  }
  get boundingRect() {
    const points = this.commands.flatMap((c) => c.slice(1)),
      xs = points.filter((_, i) => i % 2 === 0),
      ys = points.filter((_, i) => i % 2 === 1);
    if (!xs.length) return { x: 0, y: 0, width: 0, height: 0 };
    const x = Math.min(...xs),
      y = Math.min(...ys);
    return { x, y, width: Math.max(...xs) - x, height: Math.max(...ys) - y };
  }
  get description() {
    return this.commands.map((c) => c.join(" ")).join(" ");
  }
}
const color = (value) => {
  if (Array.isArray(value))
    return [value[0], value[1], value[2], value[3] ?? 1];
  if (/^#[a-f\d]{6}$/i.test(value))
    return [
      parseInt(value.slice(1, 3), 16) / 255,
      parseInt(value.slice(3, 5), 16) / 255,
      parseInt(value.slice(5, 7), 16) / 255,
      1,
    ];
  throw Error("ScenePen colors must be #RRGGBB or [red,green,blue,alpha].");
};
/** Native-equivalent pen coordinates: X about at(fromRight), positive Y above the horizon. */
export class ScenePen {
  constructor({
    width,
    horizon,
    time = 0,
    night = 0,
    clockDate = new Date(),
    illustrated = false,
  }) {
    Object.assign(this, {
      width,
      horizon,
      time,
      night,
      clockDate,
      illustrated,
      solids: [],
      holes: [],
      lights: [],
      tints: [],
      beacons: [],
      centre: 0,
    });
  }
  static noise(a, b) {
    const v = Math.sin(a * 12.9898 + b * 78.233) * 43758.5453;
    return v - Math.floor(v);
  }
  at(fromRight) {
    this.centre = this.width - fromRight;
    return this;
  }
  point(x, y) {
    return { x: this.centre + x, y: this.horizon - y };
  }
  put(path, layer = "solid") {
    this[
      { solid: "solids", hole: "holes", light: "lights" }[layer] ?? "solids"
    ].push(path);
    return this;
  }
  blockPath(x, w, h, y = 0) {
    const p = new ScenePath();
    return p
      .move(this.point(x - w / 2, y))
      .addLine(this.point(x - w / 2, y + h))
      .addLine(this.point(x + w / 2, y + h))
      .addLine(this.point(x + w / 2, y))
      .closeSubpath();
  }
  discPath(x, y, r) {
    const p = new ScenePath(),
      k = 0.5522847498307936,
      c = this.point(x, y);
    return p
      .moveTo(c.x + r, c.y)
      .bezierCurveTo(c.x + r, c.y + k * r, c.x + k * r, c.y + r, c.x, c.y + r)
      .bezierCurveTo(c.x - k * r, c.y + r, c.x - r, c.y + k * r, c.x - r, c.y)
      .bezierCurveTo(c.x - r, c.y - k * r, c.x - k * r, c.y - r, c.x, c.y - r)
      .bezierCurveTo(c.x + k * r, c.y - r, c.x + r, c.y - k * r, c.x + r, c.y)
      .closeSubpath();
  }
  domePath(x, w, y, rise = w / 2) {
    const a = w / 2,
      b = rise,
      k = 0.5523,
      p = new ScenePath();
    return p
      .move(this.point(x - a, y))
      .addCurve(
        this.point(x, y + b),
        this.point(x - a, y + b * k),
        this.point(x - a * k, y + b),
      )
      .addCurve(
        this.point(x + a, y),
        this.point(x + a * k, y + b),
        this.point(x + a, y + b * k),
      )
      .closeSubpath();
  }
  polygon(points) {
    const p = new ScenePath();
    for (const [i, v] of points.entries())
      i ? p.addLine(this.point(...v)) : p.move(this.point(...v));
    return p.closeSubpath();
  }
  block(x, w, h, y = 0, layer = "solid") {
    return this.put(this.blockPath(x, w, h, y), layer);
  }
  disc(x, y, r, layer = "solid") {
    return this.put(this.discPath(x, y, r), layer);
  }
  dome(x, w, y, rise = w / 2, layer = "solid") {
    return this.put(this.domePath(x, w, y, rise), layer);
  }
  shape(points, layer = "solid") {
    return this.put(this.polygon(points), layer);
  }
  curve(layer, build) {
    if (typeof layer === "function") {
      build = layer;
      layer = "solid";
    }
    const p = new ScenePath();
    build(p, (x, y) => this.point(x, y));
    return this.put(p, layer);
  }
  tint(path, value, nightOnly = false) {
    this.tints.push({ path, color: color(value), nightOnly });
    return this;
  }
  wash(path, top, bottom) {
    this.tints.push({
      path,
      color: color(top),
      lower: color(bottom),
      nightOnly: false,
    });
    return this;
  }
  detail(path, strength = 1) {
    return this.tint(
      path,
      this.illustrated
        ? [0.88, 0.82, 0.71, (0.28 + this.night * 0.08) * strength]
        : [0.72, 0.76, 0.8, (0.18 + this.night * 0.12) * strength],
    );
  }
  beacon(x, y) {
    this.beacons.push(this.point(x, y));
    return this;
  }
  spire(x, w, y, top) {
    return this.shape([
      [x - w / 2, y],
      [x + w / 2, y],
      [x, top],
    ]);
  }
  onion(x, w, y, h) {
    this.curve((p, at) =>
      p
        .move(at(x - w * 0.3, y))
        .addCurve(
          at(x - w * 0.2, y + h * 0.72),
          at(x - w * 0.72, y + h * 0.1),
          at(x - w * 0.62, y + h * 0.58),
        )
        .addQuadCurve(at(x, y + h), at(x - w * 0.04, y + h * 0.84))
        .addQuadCurve(
          at(x + w * 0.2, y + h * 0.72),
          at(x + w * 0.04, y + h * 0.84),
        )
        .addCurve(
          at(x + w * 0.3, y),
          at(x + w * 0.62, y + h * 0.58),
          at(x + w * 0.72, y + h * 0.1),
        )
        .closeSubpath(),
    );
    return this.block(x, 0.9, h * 0.22, y + h * 0.96);
  }
  arch(x, w, h, y = 0, pointed = false, layer = "hole") {
    if (pointed) {
      const spring = y + h * 0.55;
      return this.curve(layer, (p, at) =>
        p
          .move(at(x - w / 2, y))
          .addLine(at(x - w / 2, spring))
          .addQuadCurve(at(x, y + h), at(x - w / 2, y + h * 0.9))
          .addQuadCurve(at(x + w / 2, spring), at(x + w / 2, y + h * 0.9))
          .addLine(at(x + w / 2, y))
          .closeSubpath(),
      );
    }
    this.block(x, w, Math.max(0, h - w / 2), y, layer);
    return this.dome(x, w, y + Math.max(0, h - w / 2), w / 2, layer);
  }
  minaret(x, h, style = "arab") {
    if (style === "arab") {
      this.block(x, 3.2, h * 0.6)
        .block(x, 5.8, 1.6, h * 0.6)
        .block(x, 2.6, h * 0.2, h * 0.6)
        .block(x, 4.6, 1.4, h * 0.8)
        .block(x, 2, h * 0.08, h * 0.8)
        .spire(x, 2.8, h * 0.88, h)
        .disc(x, h * 0.6 + 3.4, 0.9, "light")
        .disc(x, h * 0.8 + 2.8, 0.8, "light");
    } else if (style === "ottoman") {
      this.block(x, 2.6, h * 0.8)
        .block(x, 4.8, 1.3, h * 0.46)
        .block(x, 4.4, 1.3, h * 0.64)
        .block(x, 3.6, 1.2, h * 0.79)
        .spire(x, 3, h * 0.8, h)
        .disc(x, h * 0.46 + 2.8, 0.8, "light")
        .disc(x, h * 0.64 + 2.8, 0.8, "light");
    } else {
      this.shape([
        [x - 2.2, 0],
        [x + 2.2, 0],
        [x + 1.6, h * 0.82],
        [x - 1.6, h * 0.82],
      ])
        .block(x, 5.2, 1.4, h * 0.82)
        .block(x, 3.4, h * 0.06, h * 0.82)
        .onion(x, 4.8, h * 0.88, h * 0.12)
        .disc(x, h * 0.82 + 2.6, 0.8, "light");
    }
    return this;
  }
  hue(seconds, offset = 0) {
    const h = (((this.time / seconds + offset) % 1) + 1) % 1,
      s = 0.55,
      k = (n) => (n + h * 6) % 6,
      f = (n) => 1 - s * Math.max(0, Math.min(k(n), 4 - k(n), 1));
    return [f(5), f(3), f(1), 1];
  }
  apply(matrix) {
    for (const group of ["solids", "holes", "lights"])
      this[group] = this[group].map((p) => p.applying(matrix));
    this.tints = this.tints.map((t) => ({
      ...t,
      path: t.path.applying(matrix),
    }));
    const [a, b, c, d, tx, ty] = matrix;
    this.beacons = this.beacons.map((p) => ({
      x: a * p.x + c * p.y + tx,
      y: b * p.x + d * p.y + ty,
    }));
    return this;
  }
  merge(other) {
    for (const group of ["solids", "holes", "lights", "tints", "beacons"])
      this[group].push(...other[group]);
    return this;
  }
  moveToLeftMargin() {
    const paths = [
      ...this.solids,
      ...this.holes,
      ...this.lights,
      ...this.tints.map((t) => t.path),
    ];
    if (paths.length)
      this.apply([
        1,
        0,
        0,
        1,
        8 - Math.min(...paths.map((p) => p.boundingRect.x)),
        0,
      ]);
    return this;
  }
  occludeLights(foreground) {
    const b = foreground.boundingRect,
      intersects = (p) => {
        const a = p.boundingRect;
        return (
          a.x < b.x + b.width &&
          a.x + a.width > b.x &&
          a.y < b.y + b.height &&
          a.y + a.height > b.y
        );
      };
    this.lights = this.lights.filter((p) => !intersects(p));
    this.tints = this.tints.filter((t) => !t.nightOnly || !intersects(t.path));
    return this;
  }
  toGeometry(options = {}) {
    const paths = [],
      lookup = new Map(),
      intern = (p) => {
        const d = p.description;
        if (!lookup.has(d)) {
          lookup.set(d, paths.length);
          paths.push(d);
        }
        return lookup.get(d);
      };
    const frame = {
      solids: this.solids.map(intern),
      holes: this.holes.map(intern),
      lights: this.lights.map(intern),
      tints: this.tints.map((t) => ({
        ...t,
        path: intern(t.path),
        bounds: Object.values(t.path.boundingRect),
      })),
      beacons: this.beacons.map((p) => [p.x, p.y]),
    };
    return {
      version: 1,
      width: this.width,
      horizon: this.horizon,
      paths,
      day: frame,
      night: frame,
      backdrop: "open",
      wild: true,
      ownMoon: false,
      illustrated: this.illustrated,
      ...options,
    };
  }
}
