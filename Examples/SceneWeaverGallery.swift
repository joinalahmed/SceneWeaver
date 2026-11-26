import SwiftUI
import SceneWeaver

/// Drop this view into an iOS or macOS SwiftUI app with SceneWeaver installed.
public struct SceneWeaverGallery: View {
    @State private var hour = 18.5
    @State private var style = 0
    @State private var weather = SceneWeather.clear
    public init() {}

    private var start: Date { Calendar.current.startOfDay(for: .now) }
    private func date(_ hour: Double) -> Date { start.addingTimeInterval(hour * 3600) }
    private var schedule: DaylightSchedule {
        DaylightSchedule(dawn: date(5), sunrise: date(6), noon: date(12),
                         afternoon: date(15), sunset: date(18), night: date(19.5))
    }
    public var body: some View {
        VStack(spacing: 20) {
            SceneView(schedule: schedule, now: date(hour), weather: weather,
                      scene: style == 0 ? coast : layered, ground: 36)
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
        // Symbols make this example self contained. Replace them with transparent
        // artwork from your own bundle; keep every plate's authored aspect ratio.
        let artwork = LayeredArtwork(layers: [
            .image(ArtworkLayer(image: Image(systemName: "mountain.2.fill"), depth: 0.5)),
            .canvas(depth: 1) { context, rect, frame in
                let x = rect.midX + CGFloat(sin(frame.time * 0.15)) * rect.width * 0.08
                let boat = Path { path in
                    path.move(to: CGPoint(x: x-20, y: rect.maxY-35))
                    path.addLine(to: CGPoint(x: x+20, y: rect.maxY-35))
                    path.addLine(to: CGPoint(x: x+12, y: rect.maxY-24))
                    path.addLine(to: CGPoint(x: x-12, y: rect.maxY-24))
                    path.closeSubpath()
                }
                context.fill(boat, with: .color(.orange))
            },
            .image(ArtworkLayer(image: Image(systemName: "building.2.fill"), depth: 2,
                               floodlights: [ArtworkLight(x: 0.5, y: 0.7)])),
            .canvas(depth: 2) { context, rect, frame in
                SceneLamp(x: 0.5, y: 0.65).draw(in: &context, rect: rect, frame: frame)
            }
        ])
        return SceneDefinition(render: { context, frame in artwork.draw(in: &context, frame: frame) })
    }
}

#Preview { SceneWeaverGallery().frame(maxWidth: 660) }
