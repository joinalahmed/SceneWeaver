import { validateProject } from "./model.mjs?v=library-5";
const number = (x) => Number(x.toFixed(5)).toString();
const literal = (x) =>
  '"' +
  x
    .replaceAll("\\", "\\\\")
    .replaceAll('"', '\\"')
    .replaceAll("\n", "\\n")
    .replaceAll("\r", "\\r")
    .replaceAll("\t", "\\t") +
  '"';
const color = (hex) =>
  `Color(red: ${number(parseInt(hex.slice(1, 3), 16) / 255)}, green: ${number(parseInt(hex.slice(3, 5), 16) / 255)}, blue: ${number(parseInt(hex.slice(5, 7), 16) / 255)})`;
const waterHelper = `    private func drawWater(in context: inout GraphicsContext, rect: CGRect, frame: SceneFrame, bounds: CGRect, opacity: Double) {
        func unit(_ index: Int, _ salt: Int) -> Double {
            let value = sin(Double(index) * 12.9898 + Double(salt) * 78.233) * 43758.5453
            return value - floor(value)
        }
        let area = CGRect(x: rect.minX + bounds.minX * rect.width, y: rect.minY + bounds.minY * rect.height,
                          width: bounds.width * rect.width, height: bounds.height * rect.height)
        var surface = context
        surface.clip(to: Path(area))
        for i in 0..<32 {
            let phase = frame.time * 1.3 + Double(i) * 0.9
            let x = area.minX + CGFloat(unit(i, 91)) * area.width + CGFloat(sin(phase * 0.6)) * rect.width * 0.012
            let y = area.minY + CGFloat(unit(i, 92)) * area.height
            let length = rect.width * CGFloat((0.012 + unit(i, 93) * 0.032) * (1 + sin(phase) * 0.25))
            let alpha = opacity * (0.35 + 0.65 * (0.5 + 0.5 * sin(phase))) * (1 - frame.darkness * 0.45)
            var ripple = Path()
            ripple.move(to: CGPoint(x: x - length / 2, y: y))
            ripple.addLine(to: CGPoint(x: x + length / 2, y: y))
            surface.stroke(ripple, with: .color(Color(red: 0.75, green: 0.86, blue: 0.88).opacity(alpha)),
                           style: StrokeStyle(lineWidth: max(0.5, rect.width * 0.001), lineCap: .round))
        }
    }

`;

export function generateSwift(input) {
  const p = validateProject(input),
    s = p.settings;
  const layers = p.layers
    .filter((l) => l.visible)
    .flatMap((l) => {
      const floods = l.lights
        .filter((x) => x.type === "flood")
        .map(
          (x) =>
            `ArtworkLight(x: ${number(x.x)}, y: ${number(x.y)}, radius: ${number(x.radius)}, intensity: ${number(x.intensity)}, color: ${color(x.color)})`,
        );
      const lines = [
        `            .image(ArtworkLayer(image: Image(${literal(l.asset.name)}), depth: ${number(l.depth)}, ambientDimming: ${number(l.dim)}, floodlights: [${floods.join(", ")}]))`,
      ];
      const fixture = (x) =>
        `SceneFixtureLight(x: ${number(x.x)}, y: ${number(x.y)}, radius: ${number(x.radius)}, near: ${x.near ? "true" : "false"}, reflection: ${number(x.reflection ?? 0)}, phase: ${number((x.phaseIndex ?? 0) * 1.3)}, color: ${color(x.color)})`;
      if (l.clock || l.crowd) {
        const actors = [];
        if (l.clock)
          actors.push(
            `                SceneClock(x: ${number(l.clock.x)}, y: ${number(l.clock.y)}, radius: ${number(l.clock.radius)}).draw(in: &context, rect: rect, frame: frame)`,
          );
        if (l.crowd) {
          actors.push(
            `                SceneCrowd(pattern: .${l.crowd}${l.crowd === "orbit" ? ", exclusions: [CGRect(x: 0.60, y: 0.75, width: 0.13, height: 0.09), CGRect(x: 0.59, y: 0.86, width: 0.08, height: 0.08)]" : ""}).draw(in: &context, rect: rect, frame: frame)`,
          );
          for (const x of p.layers.flatMap((layer) =>
            layer.lights.filter((x) => x.fixture && x.reflection > 0),
          ))
            actors.push(
              `                ${fixture(x)}.drawReflection(in: &context, rect: rect, frame: frame, floor: ${number(l.crowd === "orbit" ? Math.max(0.82, x.y + 0.1) : 0.88)})`,
            );
        }
        lines.push(`            .canvas(depth: ${number(l.depth)}) { context, rect, frame in
${actors.join("\n")}
            }`);
      }
      if (l.boat) {
        const b = l.boat;
        lines.push(`            .canvas(depth: ${number(l.depth)}) { context, rect, frame in
                SceneBoat(x: ${number(b.x)}, y: ${number(b.y)}, amplitude: ${number(b.amplitude)}, frequency: ${number(b.frequency)}, width: ${number(b.width)}, height: ${number(b.height)}, color: ${color(b.color)}).draw(in: &context, rect: rect, frame: frame)
            }`);
      }
      if (l.water) {
        const w = l.water;
        lines.push(`            .canvas(depth: ${number(l.depth)}) { context, rect, frame in
                drawWater(in: &context, rect: rect, frame: frame, bounds: CGRect(x: ${number(w.x)}, y: ${number(w.y)}, width: ${number(w.width)}, height: ${number(w.height)}), opacity: ${number(w.opacity)})
            }`);
      }
      const lamps = l.lights.filter((x) => x.type === "lamp");
      if (lamps.length)
        lines.push(
          `            .canvas(depth: ${number(l.depth)}) { context, rect, frame in\n${lamps.map((x) => (x.fixture ? `                ${fixture(x)}.draw(in: &context, rect: rect, frame: frame)` : `                SceneLamp(x: ${number(x.x)}, y: ${number(x.y)}, radius: ${number(x.radius)}, color: ${color(x.color)}).draw(in: &context, rect: rect, frame: frame)`)).join("\n")}\n            }`,
        );
      return lines;
    });
  if (p.layers.some(l => l.visible && l.crowd)) layers.push(`            .canvas(depth: 0) { context, _, frame in
                context.fill(Path(CGRect(x: 0, y: frame.horizon - 13, width: frame.size.width, height: 14)), with: .linearGradient(Gradient(colors: [.clear, .black.opacity(0.9)]), startPoint: CGPoint(x: 0, y: frame.horizon - 13), endPoint: CGPoint(x: 0, y: frame.horizon + 1)))
            }`);
  return `// Generated by SceneWeaver Studio. Add the accompanying Assets.xcassets to your app.\n// Browser previews approximate SwiftUI; verify framing and lighting on your target device.\nimport SwiftUI\nimport SceneWeaver\n${p.nativeScene ? "import SceneWeaverCatalog\n" : ""}\nstruct ComposedScene: View {\n    // Pass nil for a live clock, or a date to preview a fixed hour.\n    var previewDate: Date? = nil\n\n    private func schedule(for date: Date) -> DaylightSchedule {\n        let start = Calendar.current.startOfDay(for: date)\n        func at(_ hour: Double) -> Date { start.addingTimeInterval(hour * 3600) }\n        return DaylightSchedule(dawn: at(${number(s.schedule[0])}), sunrise: at(${number(s.schedule[1])}), noon: at(${number(s.schedule[2])}),\n                                afternoon: at(${number(s.schedule[3])}), sunset: at(${number(s.schedule[4])}), night: at(${number(s.schedule[5])}))\n    }\n\n    private var scene: SceneDefinition {\n        let artwork = LayeredArtwork(layers: [\n${layers.join(",\n")}\n        ], aspectRatio: ${number(s.aspectRatio)}, overscan: ${number(s.overscan)})\n${
    p.nativeScene
      ? `        var definition = SceneCatalog.scene(id: ${literal(p.nativeScene.id)})!.definition
        let originalOverlay = definition.overlay
        definition.overlay = { context, frame in
            originalOverlay?(&context, frame)
            artwork.draw(in: &context, frame: frame)
        }
        ${s.reservedHeight ? `        definition.reservedHeight = { width in width * ${number(s.reservedHeight.widthFactor)} + ${number(s.reservedHeight.offset)} }\n` : ""}        return definition`
      : `        return SceneDefinition(${s.reservedHeight ? `reservedHeight: { width in width * ${number(s.reservedHeight.widthFactor)} + ${number(s.reservedHeight.offset)} }, ` : ""}render: { context, frame in
            artwork.draw(in: &context, frame: frame)
        })`
  }\n    }\n\n${p.layers.some((l) => l.visible && l.water) ? waterHelper : ""}    var body: some View {\n        TimelineView(.periodic(from: .now, by: 60)) { clock in\n            SceneView(schedule: schedule(for: previewDate ?? clock.date), now: previewDate ?? clock.date, weather: .${s.weather}, scene: scene, showsSunPath: ${s.showsSunPath ?? true}, ground: ${number(s.ground)})\n            .aspectRatio(${number(s.viewport)}, contentMode: .fit)\n            .clipped()\n        }\n    }\n}\n`;
}
// Minimal STORE-only ZIP, requiring no remote library or build step.
const encoder = new TextEncoder();
const table = Array.from({ length: 256 }, (_, n) => {
  for (let k = 0; k < 8; k++) n = n & 1 ? 0xedb88320 ^ (n >>> 1) : n >>> 1;
  return n >>> 0;
});
const crc32 = (bytes) => {
  let n = 0xffffffff;
  for (const b of bytes) n = table[(n ^ b) & 255] ^ (n >>> 8);
  return (n ^ 0xffffffff) >>> 0;
};
export function zipFiles(files) {
  const entries = [],
    central = [];
  let offset = 0;
  const record = (size, values) => {
    const b = new Uint8Array(size),
      v = new DataView(b.buffer);
    for (const [at, value, len] of values)
      len === 2 ? v.setUint16(at, value, true) : v.setUint32(at, value, true);
    return b;
  };
  for (const { name, data } of files) {
    const n = encoder.encode(name),
      bytes = typeof data === "string" ? encoder.encode(data) : data,
      crc = crc32(bytes);
    const head = record(30, [
      [0, 0x04034b50, 4],
      [4, 20, 2],
      [6, 0x0800, 2],
      [14, crc, 4],
      [18, bytes.length, 4],
      [22, bytes.length, 4],
      [26, n.length, 2],
    ]);
    entries.push(head, n, bytes);
    central.push(
      record(46, [
        [0, 0x02014b50, 4],
        [4, 20, 2],
        [6, 20, 2],
        [8, 0x0800, 2],
        [16, crc, 4],
        [20, bytes.length, 4],
        [24, bytes.length, 4],
        [28, n.length, 2],
        [42, offset, 4],
      ]),
      n,
    );
    offset += head.length + n.length + bytes.length;
  }
  const centralSize = central.reduce((n, x) => n + x.length, 0);
  return new Blob(
    [
      ...entries,
      ...central,
      record(22, [
        [0, 0x06054b50, 4],
        [8, files.length, 2],
        [10, files.length, 2],
        [12, centralSize, 4],
        [16, offset, 4],
      ]),
    ],
    { type: "application/zip" },
  );
}
