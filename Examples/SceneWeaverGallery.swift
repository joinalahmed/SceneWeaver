import SwiftUI
import SceneWeaver

/// Drop this view into an iOS or macOS SwiftUI app with SceneWeaver installed.
@MainActor
public struct SceneWeaverGallery: View {
    @State private var hour = 18.5
    @State private var style = 0
    @State private var weather = SceneWeather.clear
    public init(hour: Double = 18.5, layered: Bool = false, weather: SceneWeather = .clear) {
        _hour = State(initialValue: min(23.99, max(0, hour)))
        _style = State(initialValue: layered ? 1 : 0)
        _weather = State(initialValue: weather)
    }

    public var body: some View {
        VStack(spacing: 20) {
            SceneWeaverScene(hour: hour, layered: style == 1, weather: weather)
                .frame(height: 340).clipShape(RoundedRectangle(cornerRadius: 24))
            Picker("Composition", selection: $style) {
                Text("Coastal town").tag(0)
                Text("Three layers").tag(1)
            }.pickerStyle(.segmented)
            HStack {
                Text("Hour: \(hour, specifier: "%.1f")").monospacedDigit()
                Slider(value: $hour, in: 0...23.99)
            }
            Picker("Weather", selection: $weather) {
                Text("Clear").tag(SceneWeather.clear)
                Text("Rain").tag(SceneWeather.rain)
                Text("Snow").tag(SceneWeather.snow)
                Text("Storm").tag(SceneWeather.thunderstorm)
            }
            Text("Enable Reduce Motion in system settings to freeze ambient animation.")
                .font(.caption).foregroundStyle(.secondary)
        }.padding(24)
    }

}

/// The example scene without gallery controls, also used for runtime screenshots.
@MainActor
public struct SceneWeaverScene: View {
    public var hour: Double
    public var usesLayers: Bool
    public var weather: SceneWeather
    public init(hour: Double = 18.5, layered: Bool = false, weather: SceneWeather = .clear) {
        self.hour = hour; self.usesLayers = layered; self.weather = weather
    }

    private var start: Date { Calendar.current.startOfDay(for: .now) }
    private func date(_ hour: Double) -> Date { start.addingTimeInterval(hour * 3600) }
    private var schedule: DaylightSchedule {
        DaylightSchedule(dawn: date(5), sunrise: date(6), noon: date(12),
                         afternoon: date(15), sunset: date(18), night: date(19.5))
    }
    public var body: some View {
        SceneView(schedule: schedule, now: date(hour), weather: weather,
                  scene: usesLayers ? layered : coast, ground: 36)
    }

    private var coast: SceneDefinition {
        SceneDefinition(backdrop: .hills, wild: false, draw: { pen in
            pen.at(pen.width * 0.70)
            // Lighthouse, pier and a warm beacon: no bundled scene assets.
            pen.shape([(-12, 0), (12, 0), (7, 90), (-7, 90)])
            pen.block(0, 26, 4, from: 76)
            pen.block(0, 21, 13, from: 80)
            pen.shape([(-14, 93), (14, 93), (0, 106)])
            pen.block(0, 13, 8, from: 82, .light)
            pen.beacon(0, 106)
            for x: CGFloat in [-56, -30, 30, 56] { pen.block(x, 3, 12) }
            pen.block(0, 132, 3, from: 10)
        })
    }

    private var layered: SceneDefinition {
        // Transparent plates share a 900 × 600 canvas. They are rendered and
        // cached once; the boat and lamp stay live between and above them.
        let artwork = LayeredArtwork(layers: [
            .image(ArtworkLayer(image: Self.distantPlate, depth: 0.5)),
            .canvas(depth: 1) { context, rect, frame in
                let x = rect.midX + CGFloat(sin(frame.time * 0.15)) * rect.width * 0.08
                let boat = Path { path in
                    path.move(to: CGPoint(x: x-20, y: rect.minY + rect.height * 0.83))
                    path.addLine(to: CGPoint(x: x+20, y: rect.minY + rect.height * 0.83))
                    path.addLine(to: CGPoint(x: x+12, y: rect.minY + rect.height * 0.85))
                    path.addLine(to: CGPoint(x: x-12, y: rect.minY + rect.height * 0.85))
                    path.closeSubpath()
                }
                context.fill(boat, with: .color(.orange))
            },
            .image(ArtworkLayer(image: Self.nearPlate, depth: 2,
                               floodlights: [ArtworkLight(x: 0.755, y: 0.74)])),
            .canvas(depth: 2) { context, rect, frame in
                SceneLamp(x: 0.755, y: 0.74).draw(in: &context, rect: rect, frame: frame)
            }
        ])
        return SceneDefinition(render: { context, frame in artwork.draw(in: &context, frame: frame) })
    }

    private static let distantPlate = plate { context, size in
        func polygon(_ points: [(CGFloat, CGFloat)]) -> Path {
            Path { path in
                for (index, p) in points.enumerated() {
                    let point = CGPoint(x: p.0 * size.width, y: p.1 * size.height)
                    if index == 0 { path.move(to: point) } else { path.addLine(to: point) }
                }
                path.closeSubpath()
            }
        }
        let far = polygon([(0,0.66),(0.13,0.39),(0.24,0.55),(0.41,0.24),
                           (0.58,0.53),(0.73,0.34),(1,0.68),(1,1),(0,1)])
        context.fill(far, with: .linearGradient(
            Gradient(colors: [Color(red: 0.40, green: 0.50, blue: 0.59), Color(red: 0.15, green: 0.27, blue: 0.34)]),
            startPoint: .zero, endPoint: CGPoint(x: 0, y: size.height)))
        let ridge = polygon([(0,0.72),(0.18,0.58),(0.34,0.73),(0.55,0.57),
                             (0.79,0.70),(1,0.54),(1,1),(0,1)])
        context.fill(ridge, with: .color(Color(red: 0.13, green: 0.26, blue: 0.29)))
        let water = CGRect(x: 0, y: size.height * 0.74, width: size.width, height: size.height * 0.26)
        context.fill(Path(water), with: .linearGradient(
            Gradient(colors: [Color(red: 0.17, green: 0.34, blue: 0.39), Color(red: 0.08, green: 0.19, blue: 0.24)]),
            startPoint: CGPoint(x: 0, y: water.minY), endPoint: CGPoint(x: 0, y: water.maxY)))
        for i in 0..<12 {
            let line = CGRect(x: CGFloat((i * 73) % 780), y: water.minY + CGFloat(i) * 11,
                              width: CGFloat(32 + i % 4 * 12), height: 1)
            context.fill(Path(line), with: .color(.white.opacity(0.10)))
        }
    }

    private static let nearPlate = plate { context, size in
        let w = size.width, h = size.height
        var bank = Path()
        bank.move(to: CGPoint(x: 0, y: h * 0.92))
        bank.addQuadCurve(to: CGPoint(x: w, y: h * 0.88), control: CGPoint(x: w * 0.5, y: h * 0.98))
        bank.addLine(to: CGPoint(x: w, y: h)); bank.addLine(to: CGPoint(x: 0, y: h)); bank.closeSubpath()
        context.fill(bank, with: .color(Color(red: 0.08, green: 0.15, blue: 0.16)))
        for (x, height) in [(0.07,0.51),(0.16,0.36),(0.91,0.48),(0.98,0.62)] {
            let base = h * 0.96, top = base - h * height
            var tree = Path()
            for tier in 0..<4 {
                let y = top + h * height * Double(tier) * 0.19
                let half = w * (0.018 + Double(tier) * 0.012)
                tree.move(to: CGPoint(x: w * x, y: y))
                tree.addLine(to: CGPoint(x: w * x + half, y: y + h * height * 0.39))
                tree.addLine(to: CGPoint(x: w * x - half, y: y + h * height * 0.39)); tree.closeSubpath()
            }
            context.fill(tree, with: .color(Color(red: 0.06, green: 0.13, blue: 0.14)))
        }
        let cabin = CGRect(x: w * 0.68, y: h * 0.70, width: w * 0.16, height: h * 0.21)
        context.fill(Path(cabin), with: .color(Color(red: 0.43, green: 0.29, blue: 0.19)))
        for i in 1..<8 {
            context.fill(Path(CGRect(x: cabin.minX, y: cabin.minY + CGFloat(i) * h * 0.025,
                                     width: cabin.width, height: 1)), with: .color(.black.opacity(0.25)))
        }
        var roof = Path()
        roof.move(to: CGPoint(x: w * 0.66, y: h * 0.71))
        roof.addLine(to: CGPoint(x: w * 0.76, y: h * 0.57))
        roof.addLine(to: CGPoint(x: w * 0.86, y: h * 0.71)); roof.closeSubpath()
        context.fill(roof, with: .color(Color(red: 0.16, green: 0.14, blue: 0.15)))
        context.fill(Path(CGRect(x: w * 0.73, y: h * 0.76, width: w * 0.05, height: h * 0.07)),
                     with: .color(Color(red: 0.14, green: 0.16, blue: 0.16)))
    }

    private static func plate(_ draw: @escaping (inout GraphicsContext, CGSize) -> Void) -> Image {
        let renderer = ImageRenderer(content: Canvas(renderer: draw).frame(width: 900, height: 600))
        if let image = renderer.cgImage { return Image(decorative: image, scale: 1) }
        return Image(systemName: "photo")
    }

}

#Preview { SceneWeaverGallery().frame(maxWidth: 660) }
