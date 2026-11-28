import SwiftUI

/// A live scene. Pass a fixed `now` to preview a date, or omit it to keep the
/// displayed sky current. Ambient motion respects the system Reduce Motion setting.
public struct SceneView: View {
    private let schedule: DaylightSchedule
    private let now: Date?
    private let weather: SceneWeather?
    private let scene: SceneDefinition?
    private let showsSunPath: Bool
    private let ground: CGFloat
    private let paused: Bool
    private let depthShift: CGFloat
    public static let arc: CGFloat = 128
    public static let dip: CGFloat = 24

    public init(schedule: DaylightSchedule, now: Date? = nil, weather: SceneWeather? = nil,
                scene: SceneDefinition? = nil, showsSunPath: Bool = true, ground: CGFloat = 30, paused: Bool = false,
                depthShift: CGFloat = 0) {
        self.schedule = schedule; self.now = now; self.weather = weather; self.scene = scene
        self.showsSunPath = showsSunPath; self.ground = ground; self.paused = paused; self.depthShift = depthShift
    }

    public var body: some View {
        TimelineView(.periodic(from: .now, by: 60)) { clock in
            SceneCanvas(schedule: schedule, now: now ?? clock.date, weather: weather,
                        scene: scene, showsSunPath: showsSunPath, ground: ground, paused: paused, depthShift: depthShift)
        }
    }
}

private struct SceneCanvas: View {
    let schedule: DaylightSchedule
    let now: Date
    let weather: SceneWeather?
    /// The skyline of the place, when the app has one for it.
    var city: SceneDefinition?
    /// Off where the scene is only a backdrop, as behind the Qibla compass.
    var showsSunPath = true
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.layoutDirection) private var layoutDirection

    /// How much dark ground lies under the horizon, including the spacing above
    /// any labels laid over the scene.
    var paused = false
    /// Sideways displacement of the nearest layer, in points; farther layers
    /// move in proportion to their depth. The host drives it, e.g. from tilt.
    var depthShift: CGFloat = 0
    @State private var animationClock = SceneAnimationClock()
    var ground: CGFloat = 30

    public static let arc: CGFloat = 128
    public static let dip: CGFloat = 24

    public init(schedule: DaylightSchedule, now: Date = .now, weather: SceneWeather? = nil,
                scene: SceneDefinition? = nil, showsSunPath: Bool = true, ground: CGFloat = 30, paused: Bool = false,
                depthShift: CGFloat = 0) {
        self.schedule = schedule; self.now = now; self.weather = weather; self.city = scene
        self.showsSunPath = showsSunPath; self.ground = ground; self.paused = paused; self.depthShift = depthShift
    }

    public var body: some View {
        let moment = sky()
        TimelineView(.animation(minimumInterval: 1.0 / max(1, city?.framesPerSecond ?? 24), paused: reduceMotion || paused)) { timeline in
            Canvas { context, size in
                draw(&context, size, time: animationClock.time(at: timeline.date, playing: !paused && !reduceMotion, reduced: reduceMotion), moment: moment)
            }
        }
        .accessibilityHidden(true)
    }

    // MARK: Palette

    private typealias RGB = (Double, Double, Double)
    private static func color(_ value: RGB, _ opacity: Double = 1) -> Color {
        Color(red: value.0, green: value.1, blue: value.2).opacity(opacity)
    }
    private static func mix(_ a: RGB, _ b: RGB, _ amount: Double) -> RGB {
        (a.0 + (b.0 - a.0) * amount, a.1 + (b.1 - a.1) * amount, a.2 + (b.2 - a.2) * amount)
    }
    /// 0 below `low`, 1 above `high`, a straight line between.
    private static func ramp(_ value: Double, _ low: Double, _ high: Double) -> Double {
        min(1, max(0, (value - low) / (high - low)))
    }

    /// Facades share their light with the ground, so the horizon can fade
    /// naturally without a separate contrasting band in changing weather.
    private func cityPalette(skyLow: RGB, darkness: Double, glow: Double) -> (landmark: RGB, foreground: RGB, daylight: Double) {
        // Lift only the host's unlit facades; illustrated and compass backdrops
        // retain their original ground and night contrast.
        let dark: RGB = showsSunPath && city?.illustrated != true ? (0.07, 0.07, 0.08) : (0.02, 0.03, 0.06)
        let daylight = 1 - Self.ramp(darkness, 0.12, 0.85)
        let clear = Self.mix((0.16, 0.23, 0.31), (0.36, 0.24, 0.21), min(1, max(0, glow)) * 0.8)
        let weather = Self.mix(clear, skyLow, 0.12 + 0.16 * overcast)
        return (Self.mix(dark, weather, daylight), Self.mix(dark, weather, daylight * 0.75), daylight)
    }

    /// A separate foreground for the detailed illustrations. Warm daylight and
    /// soft moonlit stone stay distinct from the blue sky and distant hills;
    /// the sky, black ground blend and city palettes remain unchanged.
    private func illustrationPalette(skyLow: RGB, darkness: Double, glow: Double) -> (landmark: RGB, foreground: RGB, daylight: Double) {
        let daylight = 1 - Self.ramp(darkness, 0.12, 0.85)
        let noon: RGB = (0.43, 0.34, 0.26)
        let golden: RGB = (0.48, 0.32, 0.23)
        let moonlit: RGB = (0.24, 0.25, 0.27)
        let sunlit = Self.mix(noon, golden, min(1, max(0, glow)) * 0.55)
        let weather = Self.mix(sunlit, skyLow, overcast * 0.06)
        let landmark = Self.mix(moonlit, weather, daylight)
        let foreground = Self.mix((0.02, 0.03, 0.06), landmark, 0.70)
        return (landmark, foreground, daylight)
    }

    private var condition: SceneWeather { weather ?? .clear }
    private var animated: Bool { !reduceMotion }

    /// How far the weather greys the sky: 0 for clear, towards 1 for a storm.
    private var overcast: Double {
        switch condition {
        case .clear: 0
        case .partlyCloudy: 0.18
        case .cloudy, .drizzle, .snow: 0.55
        case .fog: 0.62
        case .rain: 0.68
        case .thunderstorm: 0.82
        }
    }

    /// The clear sky at one moment.
    private struct Sky {
        var top: RGB
        var horizon: RGB
        /// 0 in full daylight, 1 in the middle of the night.
        var darkness: Double
        /// How strongly the horizon glows where the sun rises or sets.
        var glow: Double
        /// Whether that glow belongs to the sunrise side.
        var morning = true
    }

    /// The sky now: the two set moments either side of this minute, blended.
    private func sky() -> Sky {
        let night = Sky(top: (0.02, 0.03, 0.09), horizon: (0.07, 0.10, 0.23), darkness: 1, glow: 0)
        let dates = schedule.dates
        guard dates.count == 6, dates[1] > dates[0], dates[2] > dates[1], dates[3] > dates[2],
              dates[4] > dates[3], dates[5] > dates[4] else { return night }
        let dawn = dates[0], sunrise = dates[1], noon = dates[2], afternoon = dates[3], sunset = dates[4], nightfall = dates[5]
        func between(_ a: Date, _ b: Date, _ part: Double) -> Date { a.addingTimeInterval(b.timeIntervalSince(a) * part) }
        let morning = min(sunrise.addingTimeInterval(2700), between(sunrise, noon, 0.5))
        let golden = max(sunset.addingTimeInterval(-3300), between(afternoon, sunset, 0.35))
        let moments: [(Date, Sky)] = [
            (dawn.addingTimeInterval(-2400), night),
            (dawn, Sky(top: (0.03, 0.05, 0.15), horizon: (0.14, 0.17, 0.36), darkness: 0.92, glow: 0.12)),                          // first light
            (between(dawn, sunrise, 0.55), Sky(top: (0.08, 0.10, 0.28), horizon: (0.50, 0.32, 0.40), darkness: 0.62, glow: 0.60)),  // dawn
            (sunrise, Sky(top: (0.13, 0.22, 0.47), horizon: (0.93, 0.60, 0.40), darkness: 0.28, glow: 1.0)),                        // sunrise
            (morning, Sky(top: (0.09, 0.27, 0.56), horizon: (0.56, 0.71, 0.88), darkness: 0, glow: 0.22)),                          // morning
            (noon, Sky(top: (0.05, 0.18, 0.43), horizon: (0.21, 0.45, 0.74), darkness: 0, glow: 0)),                               // midday
            (afternoon, Sky(top: (0.06, 0.17, 0.40), horizon: (0.30, 0.46, 0.67), darkness: 0, glow: 0)),                                 // afternoon
            (golden, Sky(top: (0.09, 0.17, 0.40), horizon: (0.66, 0.54, 0.46), darkness: 0.05, glow: 0.45)),                        // golden hour
            (sunset, Sky(top: (0.13, 0.11, 0.32), horizon: (0.93, 0.44, 0.27), darkness: 0.35, glow: 1.0)),                        // sunset
            (between(sunset, nightfall, 0.45), Sky(top: (0.07, 0.07, 0.24), horizon: (0.54, 0.26, 0.32), darkness: 0.66, glow: 0.55)),  // dusk
            (nightfall, Sky(top: (0.03, 0.04, 0.14), horizon: (0.11, 0.14, 0.33), darkness: 0.92, glow: 0.08)),                          // blue hour
            (nightfall.addingTimeInterval(2400), night)
        ]
        guard let index = moments.lastIndex(where: { $0.0 <= now }), index + 1 < moments.count else { return night }
        let (from, a) = moments[index], (to, b) = moments[index + 1]
        let part = now.timeIntervalSince(from) / max(to.timeIntervalSince(from), 1)
        return Sky(top: Self.mix(a.top, b.top, part), horizon: Self.mix(a.horizon, b.horizon, part),
                   darkness: a.darkness + (b.darkness - a.darkness) * part, glow: a.glow + (b.glow - a.glow) * part,
                   morning: now < between(sunrise, sunset, 0.5))
    }

    /// A repeatable pseudo-random number in 0..<1, so nothing needs stored state.
    private static func unit(_ index: Int, _ salt: Int) -> Double {
        let value = sin(Double(index) * 12.9898 + Double(salt) * 78.233) * 43758.5453
        return value - floor(value)
    }

    // MARK: Drawing

    private func draw(_ context: inout GraphicsContext, _ size: CGSize, time: Double, moment: Sky) {
        let horizon = size.height - ground
        let top = horizon - (city?.reservedHeight != nil ? (city?.reservedHeight?(size.width) ?? Self.arc) + 4 : Self.arc)
        let dark = moment.darkness
        // Bad weather greys the sky, by day and by night.
        let grey = Self.mix((0.17, 0.19, 0.23), (0.06, 0.07, 0.09), dark)
        let skyTop = Self.mix(moment.top, grey, overcast), skyLow = Self.mix(moment.horizon, grey, overcast)
        // How far the town's lights have come on.
        let lights = Self.ramp(dark, 0.30, 0.72)
        // Keep the sky underneath the entire transition, including the ground.
        // The dark overlay below will bring it to the app's black background.
        let skyBottom = size.height

        context.fill(Path(CGRect(x: 0, y: 0, width: size.width, height: skyBottom)), with: .linearGradient(
            Gradient(colors: [Self.color(skyTop), Self.color(skyLow)]),
            startPoint: CGPoint(x: 0, y: max(0, top - 120)), endPoint: CGPoint(x: 0, y: horizon)))

        let path = showsSunPath ? sunPath(size: size, horizon: horizon, top: top) : nil

        // The sky warms where the sun meets the horizon, most at sunrise and sunset.
        if let path, moment.glow > 0.02, overcast < 0.8 {
            let centre = CGPoint(x: path.point(moment.morning ? path.dates[1] : path.dates[4]).x, y: horizon)
            context.fill(Path(CGRect(x: 0, y: 0, width: size.width, height: skyBottom)), with: .radialGradient(
                Gradient(colors: [Self.color((1.0, 0.60, 0.28), 0.72 * moment.glow * (1 - overcast)), Self.color((1.0, 0.45, 0.30), 0)]),
                center: centre, startRadius: 0, endRadius: 250))
        }

        stars(&context, size, horizon, time, strength: Self.ramp(dark, 0.55, 0.95) * (1 - overcast))
        if animated, dark > 0.9, overcast < 0.3 { shootingStar(&context, size, top: top, time: time) }
        if city?.ownMoon != true {
            // the host's header controls occupy the upper corners. Place the moon
            // below them and on the side opposite the overlaid text; other
            // backdrop scenes retain their authored placement.
            let position = showsSunPath && city?.illustrated != true
                ? CGPoint(x: size.width * (layoutDirection == .rightToLeft ? 0.18 : 0.82), y: horizon - (city?.reservedHeight != nil ? (city?.reservedHeight?(size.width) ?? Self.arc) - 10 : 96))
                : CGPoint(x: size.width * 0.80, y: top - 12)
            moon(&context, CGPoint(x: position.x + depthShift * Self.moonDepth, y: position.y), opacity: Self.ramp(dark, 0.70, 0.92))
        }

        // Let the sun itself show the day's progress. Its position comes from
        // today's sunrise and sunset; no decorative line crosses the clock or
        // suggests that the evenly spaced labels are a time scale.
        if let path {
            if path.sunIsUp { sun(&context, at: path.point(path.travelled), horizon: horizon, time: time) }
        }

        if city?.wild != true, city?.showsAircraft != false { aircraft(&context, size, horizon: horizon, time: time, moment: moment) }
        var cloudLayer = context
        cloudLayer.translateBy(x: depthShift * Self.cloudDepth, y: 0)
        clouds(&cloudLayer, size, top: top, time: time, moment: moment)
        if city?.wild != true, city?.showsBirds != false { birds(&context, size, top: top, time: time, moment: moment) }

        // Blend the sky into a city-coloured ground *behind* the skyline, then
        // take that ground to black below the horizon. Drawing the landmarks
        // afterwards keeps their facades and lights clear down to the baseline.
        let start = max(0, horizon - 32)
        let span = max(1, size.height - start)
        let groundStart = min(1, max(0, (horizon - start) / span))
        let ground = cityPalette(skyLow: skyLow, darkness: dark, glow: moment.glow).foreground
        let fade = Gradient(stops: [
            .init(color: .clear, location: 0),
            .init(color: Self.color(ground), location: groundStart),
            .init(color: .black, location: 1)
        ])
        context.fill(Path(CGRect(x: 0, y: start, width: size.width, height: size.height - start)), with: .linearGradient(
            fade, startPoint: CGPoint(x: 0, y: start), endPoint: CGPoint(x: 0, y: size.height)))
        let sunAt: CGPoint? = path.flatMap { $0.sunIsUp ? $0.point($0.travelled) : nil }
        city(&context, size, horizon: horizon, skyLow: skyLow, sun: sunAt, darkness: dark,
             glow: moment.glow, lights: lights, time: time)
        if let overlay = city?.overlay {
            overlay(&context, SceneFrame(size: size, horizon: horizon, time: time, date: now,
                                         darkness: dark, glow: moment.glow, motionEnabled: animated,
                                         contentColor: Self.color(Self.mix(cityPalette(skyLow: skyLow, darkness: dark, glow: moment.glow).landmark, skyLow, 0.16)),
                                         layoutDirection: layoutDirection, weather: condition, depthShift: depthShift))
        }
        if animated, lights > 0.3, city?.wild != true, city?.showsTraffic != false {
            var road = context
            road.translateBy(x: depthShift * Self.rooftopDepth, y: 0)
            traffic(&road, size, horizon: horizon, time: time, strength: lights)
        }
        precipitation(&context, size, horizon: horizon, time: time)
        if animated, condition == .thunderstorm { lightning(&context, size, horizon: horizon, time: time) }
    }

    // MARK: The sun's position

    private struct SunCurve {
        let dates: [Date]
        let travelled: Date
        let sunIsUp: Bool
        let point: (Date) -> CGPoint
    }

    private func sunPath(size: CGSize, horizon: CGFloat, top: CGFloat) -> SunCurve? {
        let dates = schedule.dates
        guard schedule.isValid, let start = dates.first, let end = dates.last, end > start else { return nil }
        let sunrise = dates[1], sunset = dates[4]
        guard sunset > sunrise else { return nil }
        let inset: CGFloat = 18, depth = Double(Self.dip - 3)
        let span = end.timeIntervalSince(start)
        // One smooth wave, the way the sun's height really changes through a day:
        // highest midway between sunrise and sunset, crossing the horizon at both
        // without a corner, and flattening out below it.
        let noon = sunrise.addingTimeInterval(sunset.timeIntervalSince(sunrise) / 2)
        let halfDay = 43_200.0
        let level = cos(.pi * sunset.timeIntervalSince(sunrise) / 2 / halfDay)
        let scale = Double(horizon - top - 14) / max(1 - level, 0.05)
        let point: (Date) -> CGPoint = { date in
            let x = inset + CGFloat(date.timeIntervalSince(start) / span) * (size.width - inset * 2)
            let height = (cos(.pi * date.timeIntervalSince(noon) / halfDay) - level) * scale
            let y = height >= 0 ? Double(horizon) - height : Double(horizon) + depth * (1 - exp(height / depth))
            return CGPoint(x: x, y: CGFloat(y))
        }
        // How far the day has come.
        let travelled = min(max(now, start), end)
        return SunCurve(dates: dates, travelled: travelled,
                        sunIsUp: now >= sunrise && now <= sunset && travelled >= sunrise, point: point)
    }

    /// The sun: a glow that breathes, rays that turn slowly, and a disc that
    /// reddens as it nears the horizon.
    private func sun(_ context: inout GraphicsContext, at centre: CGPoint, horizon: CGFloat, time: Double) {
        let low = 1 - Self.ramp(Double(horizon - centre.y), 4, 70)
        // Dense overcast obscures the sun as well as its glow; previously the
        // fully opaque disc remained visible through a thunderstorm.
        let visibility = 1 - Self.ramp(overcast, 0.2, 0.82)
        guard visibility > 0.01 else { return }
        let clear = (1 - overcast * 0.7) * visibility
        let warm = Self.mix((1.0, 0.72, 0.30), (1.0, 0.46, 0.20), low)
        let reach = 40 + 8 * low + (animated ? 3 * sin(time * 0.9) : 0)
        context.fill(Path(ellipseIn: CGRect(origin: centre, size: .zero).insetBy(dx: -reach, dy: -reach)), with: .radialGradient(
            Gradient(colors: [Self.color(warm, 0.55 * clear), Self.color(warm, 0)]), center: centre, startRadius: 0, endRadius: reach))
        if overcast < 0.4 {
            var rays = Path()
            let turn = animated ? time * 0.10 : 0
            for ray in 0..<12 {
                let angle = Double(ray) * .pi / 6 + turn
                let inner = 12.5, outer = ray % 2 == 0 ? 18.0 : 15.5
                rays.move(to: CGPoint(x: centre.x + CGFloat(cos(angle) * inner), y: centre.y + CGFloat(sin(angle) * inner)))
                rays.addLine(to: CGPoint(x: centre.x + CGFloat(cos(angle) * outer), y: centre.y + CGFloat(sin(angle) * outer)))
            }
            context.stroke(rays, with: .color(Self.color(warm, 0.45 * (1 - overcast * 2))), style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
        }
        let radius = 8 + 1.5 * low
        context.fill(Path(ellipseIn: CGRect(origin: centre, size: .zero).insetBy(dx: -radius, dy: -radius)),
                     with: .color(Self.color(Self.mix(Self.mix((1.0, 0.80, 0.38), (1.0, 0.52, 0.24), low), (0.82, 0.82, 0.80), overcast * 0.7), visibility)))
    }

    // MARK: Sky

    private func stars(_ context: inout GraphicsContext, _ size: CGSize, _ horizon: CGFloat, _ time: Double, strength: Double) {
        guard strength > 0.03 else { return }
        for star in 0..<80 {
            let y = CGFloat(Self.unit(star, 2)) * (horizon - 40)
            let twinkle = 0.55 + 0.45 * sin(time * (0.5 + Self.unit(star, 4)) + Self.unit(star, 5) * 6.28)
            let radius = 0.6 + Self.unit(star, 3) * 0.9
            let rect = CGRect(x: CGFloat(Self.unit(star, 1)) * size.width - radius, y: y - radius, width: radius * 2, height: radius * 2)
            context.fill(Path(ellipseIn: rect), with: .color(.white.opacity((0.3 + Self.unit(star, 6) * 0.6) * twinkle * strength)))
        }
    }

    /// Now and then at night, a short bright streak.
    private func shootingStar(_ context: inout GraphicsContext, _ size: CGSize, top: CGFloat, time: Double) {
        let every = 17.0, lasts = 0.9
        let turn = floor(time / every)
        let part = (time - turn * every) / lasts
        guard part < 1 else { return }
        let index = Int(turn.truncatingRemainder(dividingBy: 100_000))
        let start = CGPoint(x: size.width * CGFloat(0.25 + Self.unit(index, 81) * 0.6), y: max(20, top - 150) + CGFloat(Self.unit(index, 82)) * 120)
        let slope: CGFloat = Self.unit(index, 83) > 0.5 ? 1 : -1
        let head = CGPoint(x: start.x + slope * CGFloat(part) * 110, y: start.y + CGFloat(part) * 46)
        let tail = CGPoint(x: head.x - slope * 34, y: head.y - 14)
        var streak = Path()
        streak.move(to: tail); streak.addLine(to: head)
        context.stroke(streak, with: .linearGradient(Gradient(colors: [.white.opacity(0), .white.opacity(0.85 * sin(.pi * part))]),
                                                     startPoint: tail, endPoint: head),
                       style: StrokeStyle(lineWidth: 1.4, lineCap: .round))
    }

    /// A crescent: a bright disc with part of it cut away.
    private func moon(_ context: inout GraphicsContext, _ centre: CGPoint, opacity: Double) {
        let visibility = 1 - Self.ramp(overcast, 0.30, 0.80)
        guard opacity * visibility > 0.02 else { return }
        var faded = context
        faded.opacity = opacity * visibility
        let glow = CGRect(origin: centre, size: .zero).insetBy(dx: -46, dy: -46)
        faded.fill(Path(ellipseIn: glow), with: .radialGradient(
            Gradient(colors: [Color.white.opacity(0.16 * (1 - overcast)), Color.white.opacity(0)]),
            center: centre, startRadius: 0, endRadius: 46))
        faded.drawLayer { layer in
            layer.fill(Path(ellipseIn: CGRect(origin: centre, size: .zero).insetBy(dx: -15, dy: -15)),
                       with: .color(Self.color((0.96, 0.95, 0.88), 1 - overcast * 0.5)))
            layer.blendMode = .destinationOut
            layer.fill(Path(ellipseIn: CGRect(origin: CGPoint(x: centre.x + 9, y: centre.y - 5), size: .zero).insetBy(dx: -14, dy: -14)),
                       with: .color(.black))
        }
    }

    /// Soft, varied cloud banks drift in layers. Weather controls their amount,
    /// and the same sky palette used by the rest of the scene colours them.
    private func clouds(_ context: inout GraphicsContext, _ size: CGSize, top: CGFloat, time: Double, moment: Sky) {
        let count: Int
        switch condition {
        case .clear: count = 2
        case .partlyCloudy: count = 4
        case .fog: count = 2
        case .cloudy, .drizzle, .rain, .snow: count = 6
        case .thunderstorm: count = 7
        }
        // Bright in fair weather by day, grey under rain, dim at night, warm at
        // either end of the day; translucent so the time stays readable.
        let fair = Self.mix((1, 1, 1), (0.70, 0.73, 0.78), overcast)
        let lit = Self.mix(fair, (1.0, 0.74, 0.58), moment.glow * 0.55 * (1 - overcast))
        let tone = Self.mix(lit, (0.55, 0.60, 0.72), Self.ramp(moment.darkness, 0.5, 0.95))
        let strength = (0.30 - overcast * 0.08) * (1 - 0.35 * moment.darkness) * (condition == .clear ? 0.5 : 1)
        for cloud in 0..<count {
            let scale = condition == .clear ? 0.72 : 1.0
            let width = (88 + Self.unit(cloud, 11) * 86) * scale
            let height = width * (0.16 + Self.unit(cloud, 15) * 0.08)
            // The entire bank clears the screen before wrapping. Independent
            // speeds and a small vertical drift make the layers feel less rigid.
            let travel = Double(size.width) + width * 2.8
            let x = (Self.unit(cloud, 12) * travel + time * (1.4 + Self.unit(cloud, 13) * 2.2))
                .truncatingRemainder(dividingBy: travel) - width * 1.4
            let y = Double(top) - 34 + Self.unit(cloud, 14) * Double(Self.arc) * 0.62
                + sin(time * 0.035 + Double(cloud) * 2.1) * 2
            let opacity = strength * (0.55 + Self.unit(cloud, 16) * 0.35)
            let variation = Self.unit(cloud, 17)

            // A wider, faint layer gives each bank a soft edge without a blur
            // filter on every animated frame.
            let haze = cloudShape(x: x - width * 0.12, y: y + height * 0.10,
                                  width: width * 1.24, height: height * 0.85, variation: variation)
            context.fill(haze, with: .color(Self.color(tone, opacity * 0.30)))

            let body = cloudShape(x: x, y: y, width: width, height: height, variation: variation)
            let underside = Self.mix(tone, moment.horizon, 0.32)
            context.fill(body, with: .linearGradient(
                Gradient(colors: [Self.color(tone, opacity), Self.color(underside, opacity * 0.55)]),
                startPoint: CGPoint(x: x, y: y - height), endPoint: CGPoint(x: x, y: y + height * 0.3)))
        }
        if condition == .fog {
            context.drawLayer { layer in
                layer.addFilter(.blur(radius: 22))
                for band in 0..<5 {
                    let x = (Self.unit(band, 21) * size.width + time * (3 + Self.unit(band, 22) * 4)).truncatingRemainder(dividingBy: size.width) - size.width * 0.8
                    let rect = CGRect(x: x, y: top + Self.arc * (0.30 + Double(band) * 0.15), width: size.width * 1.6, height: 30)
                    layer.fill(Path(ellipseIn: rect), with: .color(.white.opacity(0.12)))
                }
            }
        }
    }

    /// A gently uneven silhouette, with a different crest for each cloud.
    private func cloudShape(x: Double, y: Double, width: Double, height: Double, variation: Double) -> Path {
        func point(_ px: Double, _ py: Double) -> CGPoint { CGPoint(x: x + px * width, y: y + py * height) }
        var path = Path()
        path.move(to: point(0, 0.12))
        path.addCurve(to: point(0.25, -0.48), control1: point(0.02, -0.16), control2: point(0.12, -0.55))
        path.addCurve(to: point(0.52, -0.88 - variation * 0.18), control1: point(0.29, -0.78), control2: point(0.38, -1.04))
        path.addCurve(to: point(0.76, -0.43), control1: point(0.65, -1.03), control2: point(0.69, -0.65))
        path.addCurve(to: point(1, 0.10), control1: point(0.90, -0.55), control2: point(0.99, -0.19))
        path.addCurve(to: point(0, 0.12), control1: point(0.84, 0.33), control2: point(0.16, 0.35))
        path.closeSubpath()
        return path
    }

    /// An occasional aircraft crosses behind the clouds and the city. The long
    /// quiet intervals leave room for the scene to remain the focus.
    private func aircraft(_ context: inout GraphicsContext, _ size: CGSize, horizon: CGFloat, time: Double, moment: Sky) {
        guard animated, showsSunPath else { return }
        switch condition {
        case .rain, .thunderstorm, .snow, .fog: return
        default: break
        }

        let cycle = floor(time / 120)
        let phase = time - cycle * 120
        var helicopter: Bool
        var progress: Double
        if phase < 23 {
            helicopter = false
            progress = phase / 23
        } else if phase >= 65 && phase < 94 {
            helicopter = true
            progress = (phase - 65) / 29
        } else {
            helicopter = false
            progress = -1
        }
        guard progress >= 0 else { return }

        let direction = Int(cycle.truncatingRemainder(dividingBy: 2)) == 0 ? 1.0 : -1.0
        let x = direction > 0 ? -30 + progress * (Double(size.width) + 60)
                              : Double(size.width) + 30 - progress * (Double(size.width) + 60)
        let y = Double(horizon) - (helicopter ? 62 : 82)
            + (helicopter ? sin(time * 0.8) * 1.5 : sin(time * 0.16) * 0.8)
        // Clock labels occupy the leading side of the host. Fade the aircraft
        // smoothly as it approaches that side instead of crossing the text.
        let fromClock = layoutDirection == .rightToLeft ? Double(size.width) - x : x
        let visibility = showsSunPath && city?.illustrated != true
            ? Self.ramp(fromClock / max(Double(size.width), 1), 0.64, 0.75) : 1
        guard visibility > 0.01 else { return }
        let ink = Self.color(Self.mix((0.08, 0.10, 0.15), (0.72, 0.76, 0.83), moment.darkness), 0.75)
        var craft = context
        craft.opacity = visibility
        craft.translateBy(x: x, y: y)
        craft.scaleBy(x: direction, y: 1)

        if helicopter {
            var body = Path()
            body.move(to: CGPoint(x: -19, y: -1))
            body.addLine(to: CGPoint(x: -7, y: 0))
            body.addCurve(to: CGPoint(x: 10, y: 3), control1: CGPoint(x: -2, y: -7), control2: CGPoint(x: 7, y: -6))
            body.addCurve(to: CGPoint(x: -5, y: 5), control1: CGPoint(x: 10, y: 7), control2: CGPoint(x: -1, y: 7))
            body.addLine(to: CGPoint(x: -9, y: 2))
            body.addLine(to: CGPoint(x: -20, y: 2))
            body.closeSubpath()
            craft.fill(body, with: .color(ink))
            var rotor = Path()
            let reach = 7 + abs(sin(time * 12)) * 6
            rotor.move(to: CGPoint(x: -2 - reach, y: -8))
            rotor.addLine(to: CGPoint(x: -2 + reach, y: -8))
            rotor.move(to: CGPoint(x: -2, y: -8))
            rotor.addLine(to: CGPoint(x: -2, y: -5))
            rotor.move(to: CGPoint(x: -7, y: 8))
            rotor.addLine(to: CGPoint(x: 7, y: 8))
            rotor.move(to: CGPoint(x: -4, y: 5))
            rotor.addLine(to: CGPoint(x: -5, y: 8))
            rotor.move(to: CGPoint(x: 5, y: 5))
            rotor.addLine(to: CGPoint(x: 4, y: 8))
            craft.stroke(rotor, with: .color(ink), style: StrokeStyle(lineWidth: 1, lineCap: .round))
        } else {
            var body = Path()
            body.move(to: CGPoint(x: -20, y: -1))
            body.addLine(to: CGPoint(x: -23, y: -6))
            body.addLine(to: CGPoint(x: -19, y: -6))
            body.addLine(to: CGPoint(x: -14, y: -2))
            body.addLine(to: CGPoint(x: 15, y: -2))
            body.addQuadCurve(to: CGPoint(x: 21, y: 1), control: CGPoint(x: 21, y: -1))
            body.addQuadCurve(to: CGPoint(x: 14, y: 3), control: CGPoint(x: 19, y: 3))
            body.addLine(to: CGPoint(x: 3, y: 3))
            body.addLine(to: CGPoint(x: -4, y: 7))
            body.addLine(to: CGPoint(x: -9, y: 7))
            body.addLine(to: CGPoint(x: -5, y: 3))
            body.addLine(to: CGPoint(x: -17, y: 3))
            body.closeSubpath()
            craft.fill(body, with: .color(ink))
        }
        if moment.darkness > 0.5 && time.truncatingRemainder(dividingBy: 2.4) < 0.25 {
            craft.fill(Path(ellipseIn: CGRect(x: -13, y: -2, width: 2, height: 2)),
                       with: .color(.red.opacity(0.85)))
        }
    }

    /// By day, in fair weather, a flock or two crossing the sky: each bird two
    /// small strokes that beat.
    private func birds(_ context: inout GraphicsContext, _ size: CGSize, top: CGFloat, time: Double, moment: Sky) {
        guard animated, moment.darkness < 0.6 else { return }
        switch condition {
        case .rain, .thunderstorm, .snow, .fog: return
        default: break
        }
        let ink = Self.color((0.03, 0.05, 0.10), 0.70 * (1 - moment.darkness))
        for flock in 0..<2 {
            let crossing = 44 + Self.unit(flock, 61) * 26
            let shifted = time + Self.unit(flock, 62) * crossing
            let lap = floor(shifted / crossing)
            let part = shifted / crossing - lap
            let seed = flock * 1000 + Int(lap.truncatingRemainder(dividingBy: 900))
            let direction: Double = Self.unit(seed, 63) > 0.5 ? 1 : -1
            let span = Double(size.width) + 140
            let leadX = direction > 0 ? -70 + part * span : Double(size.width) + 70 - part * span
            let leadY = Double(top) - 60 + Self.unit(seed, 64) * Double(Self.arc) * 0.6 + sin(time * 0.35 + Double(flock)) * 6
            let count = 3 + Int(Self.unit(seed, 65) * 4)
            for bird in 0..<count {
                // A loose V behind the leader.
                let row = Double((bird + 1) / 2), side: Double = bird % 2 == 0 ? 1 : -1
                let x = leadX - direction * row * 11 + sin(time * 0.7 + Double(bird)) * 1.5
                let y = leadY + side * row * 6 + cos(time * 0.9 + Double(bird) * 1.7) * 1.5
                let lift = 1.0 + sin(time * 7 + Double(bird) * 1.3 + Double(flock)) * 2.4
                let wing = 4.4
                var wings = Path()
                wings.move(to: CGPoint(x: x - wing, y: y - lift))
                wings.addQuadCurve(to: CGPoint(x: x, y: y), control: CGPoint(x: x - wing * 0.5, y: y - lift * 1.3 - 0.6))
                wings.addQuadCurve(to: CGPoint(x: x + wing, y: y - lift), control: CGPoint(x: x + wing * 0.5, y: y - lift * 1.3 - 0.6))
                context.stroke(wings, with: .color(ink), style: StrokeStyle(lineWidth: 1.2, lineCap: .round, lineJoin: .round))
            }
        }
    }

    private func precipitation(_ context: inout GraphicsContext, _ size: CGSize, horizon: CGFloat, time: Double) {
        let fall = horizon + ground
        // The labels sit under the skyline. Fade falling weather away
        // through that transition instead of painting streaks over the text.
        func visibility(_ y: CGFloat) -> Double {
            1 - Self.ramp(Double(y), Double(horizon), Double(horizon + max(1, min(ground, 24))))
        }
        let drops: Int
        switch condition {
        case .drizzle: drops = 40
        case .rain: drops = 90
        case .thunderstorm: drops = 130
        default: drops = 0
        }
        for drop in 0..<drops {
            let speed = 0.6 + Self.unit(drop, 32) * 0.5
            let y = CGFloat((Self.unit(drop, 33) + time * speed).truncatingRemainder(dividingBy: 1)) * fall
            let x = CGFloat(Self.unit(drop, 31)) * (size.width + 30) - 15
            let length = 10 + Self.unit(drop, 34) * 10
            var streak = Path()
            streak.move(to: CGPoint(x: x, y: y))
            streak.addLine(to: CGPoint(x: x - length * 0.18, y: y + length))
            context.stroke(streak, with: .color(.white.opacity((0.20 + Self.unit(drop, 35) * 0.18) * visibility(y))), lineWidth: 1)
        }
        if condition == .snow {
            for flake in 0..<70 {
                let speed = 0.04 + Self.unit(flake, 42) * 0.05
                let y = CGFloat((Self.unit(flake, 43) + time * speed).truncatingRemainder(dividingBy: 1)) * fall
                let x = CGFloat(Self.unit(flake, 41)) * size.width + CGFloat(sin(time * 0.6 + Self.unit(flake, 44) * 6.28)) * 8
                let radius = 1 + Self.unit(flake, 45) * 1.5
                context.fill(Path(ellipseIn: CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2)),
                             with: .color(.white.opacity((0.45 + Self.unit(flake, 46) * 0.4) * visibility(y))))
            }
        }
    }

    /// In a storm, a bolt and a flash that lights the whole sky for a moment.
    private func lightning(_ context: inout GraphicsContext, _ size: CGSize, horizon: CGFloat, time: Double) {
        let every = 7.5
        let turn = floor(time / every)
        let since = time - turn * every
        guard since < 0.5 else { return }
        // Two quick pulses, the second weaker.
        let pulse = since < 0.18 ? 1 - since / 0.18 : since > 0.26 ? max(0, 1 - (since - 0.26) / 0.24) * 0.6 : 0
        guard pulse > 0 else { return }
        let index = Int(turn.truncatingRemainder(dividingBy: 100_000))
        var bolt = Path()
        var point = CGPoint(x: size.width * CGFloat(0.2 + Self.unit(index, 71) * 0.6), y: horizon - Self.arc - 90)
        bolt.move(to: point)
        for step in 0..<7 {
            point = CGPoint(x: point.x + CGFloat(Self.unit(index * 7 + step, 72) - 0.5) * 34, y: point.y + 22 + CGFloat(Self.unit(index * 7 + step, 73)) * 12)
            bolt.addLine(to: point)
        }
        context.fill(Path(CGRect(x: 0, y: 0, width: size.width, height: horizon)), with: .color(.white.opacity(0.22 * pulse)))
        context.stroke(bolt, with: .color(.white.opacity(0.9 * pulse)), style: StrokeStyle(lineWidth: 1.6, lineCap: .round, lineJoin: .round))
    }

    // MARK: The city

    /// Two rows on the horizon. The far one is tall blocks, a low roofline or
    /// hills, as suits the place. The near one carries the city's landmarks, or a
    /// roofline where the host supplies no landmarks. As it gets dark the
    /// windows come on a few at a time and keep changing, the landmarks light up
    /// and red lights blink on the tallest of them.
    private func city(_ context: inout GraphicsContext, _ size: CGSize, horizon: CGFloat, skyLow: RGB, sun: CGPoint? = nil,
                      darkness: Double, glow: Double, lights: Double, time: Double) {
        if let render = city?.render {
            render(&context, SceneFrame(size: size, horizon: horizon, time: time, date: now,
                                        darkness: darkness, glow: glow, motionEnabled: animated, layoutDirection: layoutDirection,
                                        weather: condition, depthShift: depthShift,
                                        horizonRGB: SIMD3(skyLow.0, skyLow.1, skyLow.2), sunPosition: sun))
            return
        }
        let dark: RGB = (0.02, 0.03, 0.06)
        let palette = city?.illustrated == true
            ? illustrationPalette(skyLow: skyLow, darkness: darkness, glow: glow)
            : cityPalette(skyLow: skyLow, darkness: darkness, glow: glow)
        var back = Path()
        var distantBuildings: [CGRect] = []
        switch city?.backdrop ?? .towers {
        case .towers:
            // A little lower behind a city's own landmarks, which should stand clear of it.
            distantBuildings = Self.buildings(width: size.width, seed: 50, low: city?.distantBuildingHeights.lowerBound ?? 22, high: city?.distantBuildingHeights.upperBound ?? 58)
            for rect in distantBuildings {
                back.addRect(CGRect(x: rect.minX, y: horizon - rect.height, width: rect.width, height: rect.height))
            }
        case .low:
            distantBuildings = Self.buildings(width: size.width, seed: 50, low: 10, high: 28)
            for rect in distantBuildings {
                back.addRect(CGRect(x: rect.minX, y: horizon - rect.height, width: rect.width, height: rect.height))
            }
        case .hills:
            back = Self.hills(width: size.width, horizon: horizon)
        case .open:
            break
        }
        // The far row stands deep in the scene and moves least.
        let backShift = depthShift * Self.backdropDepth
        if backShift != 0 {
            distantBuildings = Self.displaced(distantBuildings, by: backShift)
            back = Path()
            if city?.backdrop == .hills {
                back = Self.hills(width: size.width, horizon: horizon).offsetBy(dx: backShift, dy: 0)
            } else {
                for rect in distantBuildings {
                    back.addRect(CGRect(x: rect.minX, y: horizon - rect.height, width: rect.width, height: rect.height))
                }
            }
        }
        // The detailed artwork has more foreground detail than a city skyline.
        // Keep its distant hills recessed so they do not merge into that detail.
        let backdropShade = city?.illustrated == true ? 0.76 : 0.62 - palette.daylight * 0.08
        context.fill(back, with: .color(Self.color(Self.mix(skyLow, dark, backdropShade))))

        // Fine facade edges and a few distant windows add depth without
        // competing with the landmarks in front. Foreground silhouettes still
        // cover these details naturally as the sky and lighting change.
        for (index, rect) in distantBuildings.enumerated() where rect.height > 15 {
            let x = rect.minX + rect.width * 0.22
            let top = horizon - rect.height
            let edge = CGRect(x: x, y: top + 2, width: 0.7, height: max(0, rect.height - 4))
            context.fill(Path(edge), with: .color(Self.color(skyLow, 0.11)))
            guard lights > 0.02 else { continue }
            for row in 0..<Int(rect.height / 11) {
                let id = index * 31 + row
                let turn = Int((time / 28 + Self.unit(id, 111)).truncatingRemainder(dividingBy: 5000))
                guard Self.unit(id + turn * 7919, 112) > 0.66 else { continue }
                let glass = CGRect(x: rect.minX + 3 + CGFloat(Self.unit(id, 113)) * max(0, rect.width - 7),
                                   y: top + 5 + CGFloat(row) * 10, width: 1.1, height: 1.5)
                context.fill(Path(glass), with: .color(Self.color((1.0, 0.82, 0.56), 0.38 * lights)))
            }
        }

        // Kept low where a city's own landmarks stand, so they are not lost among it.
        let near = city?.wild == true ? [] : Self.displaced(
            Self.buildings(width: size.width, seed: 70, low: city?.nearBuildingHeights.lowerBound ?? 10, high: city?.nearBuildingHeights.upperBound ?? 36),
            by: depthShift * Self.rooftopDepth)
        var front = Path()
        for (index, rect) in near.enumerated() {
            let body = CGRect(x: rect.minX, y: horizon - rect.height, width: rect.width, height: rect.height)
            front.addRect(body)
            if Self.unit(index, 73) > 0.74 {
                front.addRect(CGRect(x: body.midX - 0.75, y: body.minY - 9, width: 1.5, height: 9))
            } else if Self.unit(index, 73) < 0.24 {
                front.addRect(CGRect(x: body.minX + body.width * 0.2, y: body.minY - 5, width: body.width * 0.6, height: 5))
            }
        }
        var pen = ScenePen(width: size.width, horizon: horizon, time: time, night: lights, clockDate: now,
                             illustrated: city?.illustrated == true)
        if let city {
            city.draw(&pen)
            if layoutDirection == .rightToLeft && city.movesForRTL { pen.moveToLeftMargin() }
            // The landmarks stand in front of the rooftops: they move furthest. The margin is
            // found first, from the scene at rest, so the tilt still shows once it has moved across.
            if depthShift != 0 { pen.apply(CGAffineTransform(translationX: depthShift * Self.landmarkDepth, y: 0)) }
        }
        context.drawLayer { layer in
            layer.fill(front, with: .color(Self.color(palette.foreground)))
            for path in pen.solids { layer.fill(path, with: .color(Self.color(palette.landmark))) }
            // Arches and windows are cut through everything in this row.
            layer.blendMode = .destinationOut
            for path in pen.holes { layer.fill(path, with: .color(.black)) }
        }
        for tint in pen.tints where !tint.nightOnly {
            if let lower = tint.lowerColor {
                let bounds = tint.path.boundingRect
                context.fill(tint.path, with: .linearGradient(Gradient(colors: [tint.color, lower]),
                    startPoint: CGPoint(x: bounds.midX, y: bounds.minY),
                    endPoint: CGPoint(x: bounds.midX, y: bounds.maxY)))
            } else {
                context.fill(tint.path, with: .color(tint.color))
            }
        }

        guard lights > 0.02 else { return }
        var glowing = context
        glowing.opacity = lights
        for tint in pen.tints where tint.nightOnly { glowing.fill(tint.path, with: .color(tint.color)) }

        // Windows: more of them as the evening goes on, each on its own slow
        // clock, so a few change every few seconds.
        let covered = (pen.solids + pen.holes).map { ($0.boundingRect, $0) }
        for (index, rect) in near.enumerated() where rect.height > 16 {
            for window in 0..<Int(rect.height / 9) {
                let id = index * 31 + window
                let stays = 14 + Self.unit(id, 79) * 34
                let turn = Int(((time + Self.unit(id, 80) * stays) / stays).truncatingRemainder(dividingBy: 5000))
                guard Self.unit(id + turn * 7919, 77) > 1 - 0.5 * lights else { continue }
                let x = rect.minX + 3 + CGFloat(Self.unit(id, 78)) * max(0, rect.width - 8)
                let glass = CGRect(x: x, y: horizon - rect.height + 5 + CGFloat(window) * 9, width: 2, height: 3)
                // Not where a landmark stands in front of this building.
                let centre = CGPoint(x: glass.midX, y: glass.midY)
                if covered.contains(where: { $0.0.contains(centre) && $0.1.contains(centre) }) { continue }
                context.fill(Path(glass), with: .color(Self.color((1.0, 0.84, 0.52), 0.75)))
            }
        }
        for path in pen.lights { glowing.fill(path, with: .color(Self.color((1.0, 0.86, 0.56), 0.92))) }

        // Red lights on the tallest towers, each blinking in its own time.
        guard lights > 0.5 else { return }
        for (index, tip) in pen.beacons.enumerated() {
            let phase = (time / 1.9 + Self.unit(index, 95)).truncatingRemainder(dividingBy: 1)
            guard !animated || phase < 0.38 else { continue }
            context.fill(Path(ellipseIn: CGRect(origin: tip, size: .zero).insetBy(dx: -4.5, dy: -4.5)), with: .radialGradient(
                Gradient(colors: [Self.color((1.0, 0.25, 0.20), 0.45), Self.color((1.0, 0.25, 0.20), 0)]), center: tip, startRadius: 0, endRadius: 4.5))
            context.fill(Path(ellipseIn: CGRect(origin: tip, size: .zero).insetBy(dx: -1.3, dy: -1.3)), with: .color(Self.color((1.0, 0.32, 0.26))))
        }
    }

    /// After dark, headlights and tail lights passing along the foot of the city.
    private func traffic(_ context: inout GraphicsContext, _ size: CGSize, horizon: CGFloat, time: Double, strength: Double) {
        for car in 0..<9 {
            let forward = car % 2 == 0
            let speed = 9 + Self.unit(car, 91) * 12
            let run = Double(size.width) + 40
            let along = (Self.unit(car, 92) * run + time * speed).truncatingRemainder(dividingBy: run)
            let x = CGFloat(forward ? along - 20 : run - along - 20)
            let y = horizon + (forward ? 1.6 : 3.4)
            let tone: RGB = forward ? (1.0, 0.95, 0.80) : (1.0, 0.30, 0.25)
            context.fill(Path(ellipseIn: CGRect(x: x - 1, y: y - 1, width: 2, height: 2)), with: .color(Self.color(tone, 0.8 * strength)))
            context.fill(Path(ellipseIn: CGRect(x: x - (forward ? -2.6 : 2.6) - 1, y: y - 1, width: 2, height: 2)),
                         with: .color(Self.color(tone, 0.8 * strength)))
        }
    }

    // MARK: Depth

    /// How near each built-in layer stands, as a share of `depthShift`.
    static let moonDepth: CGFloat = 0.05
    static let cloudDepth: CGFloat = 0.12
    static let backdropDepth: CGFloat = 0.22
    static let rooftopDepth: CGFloat = 0.48
    static let landmarkDepth: CGFloat = 0.7

    /// A row of buildings moved sideways. A spare building is added past each
    /// end, after the others so that their windows keep their places, and the
    /// row still reaches both edges of the view.
    private static func displaced(_ row: [CGRect], by shift: CGFloat) -> [CGRect] {
        guard shift != 0, let first = row.first, let last = row.last else { return row }
        let spare: CGFloat = 28
        let ends = [CGRect(x: first.minX - spare, y: 0, width: spare, height: first.height),
                    CGRect(x: last.maxX, y: 0, width: spare, height: last.height)]
        return (row + ends).map { $0.offsetBy(dx: shift, dy: 0) }
    }

    /// A soft ridge for places that sit among hills.
    private static func hills(width: CGFloat, horizon: CGFloat) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: -8, y: horizon))
        var x: CGFloat = -8
        while x <= width + 8 {
            let t = Double(x)
            let height = 30 + 16 * sin(t * 0.018 + 1.3) + 9 * sin(t * 0.047 + 0.4) + 4 * sin(t * 0.11 + 2.1)
            path.addLine(to: CGPoint(x: x, y: horizon - CGFloat(max(height, 6))))
            x += 6
        }
        path.addLine(to: CGPoint(x: width + 8, y: horizon))
        path.closeSubpath()
        return path
    }

    /// Building footprints as (x, width, height); `minX`/`width`/`height` are read back.
    private static func buildings(width: CGFloat, seed: Int, low: CGFloat, high: CGFloat) -> [CGRect] {
        var result: [CGRect] = []
        var x: CGFloat = -6
        var index = 0
        while x < width + 6 {
            let w = 14 + CGFloat(unit(index, seed)) * 24
            let h = low + CGFloat(unit(index, seed + 1)) * (high - low)
            result.append(CGRect(x: x, y: 0, width: w, height: h))
            x += w + (unit(index, seed + 2) > 0.8 ? 4 : 0)
            index += 1
        }
        return result
    }

}
