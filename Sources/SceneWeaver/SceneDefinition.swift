import SwiftUI

public enum SceneBackdrop: String { case towers, low, hills, open }
public enum SceneWeather: String { case clear, partlyCloudy, cloudy, fog, drizzle, rain, snow, thunderstorm }

/// Six ordered transitions control the sky. Supply local dates from your own
/// astronomy service, simulation or creative timeline; the engine never fetches them.
public struct DaylightSchedule {
    public let dates: [Date]
    public var isValid: Bool {
        dates.count == 6 && zip(dates, dates.dropFirst()).allSatisfy { $0 < $1 }
    }
    public init(dawn: Date, sunrise: Date, noon: Date, afternoon: Date, sunset: Date, night: Date) {
        dates = [dawn, sunrise, noon, afternoon, sunset, night]
    }
    /// Invalid or incomplete schedules render a stable night sky.
    public init(orderedDates: [Date]) { dates = orderedDates }
}

/// Values passed to custom Canvas layers on every rendered frame.
public struct SceneFrame {
    public let size: CGSize
    public let horizon: CGFloat
    /// Animation seconds; frozen at zero when Reduce Motion is enabled.
    public let time: Double
    /// Displayed wall-clock date, independent of animation seconds.
    public let date: Date
    public let darkness: Double
    public let glow: Double
    public let motionEnabled: Bool
    public var contentColor: Color
    public var weather: SceneWeather
    public var layoutDirection: LayoutDirection
    /// How far a part at depth 1 is displaced sideways in this frame, in points.
    public var depthShift: CGFloat = 0
    /// The sky's colour where it meets the ground, as sRGB components in 0...1,
    /// for a custom renderer that mixes its own haze. Set for `render` only.
    public var horizonRGB: SIMD3<Double> = .zero
    /// Where the sun is drawn, when it is up and the scene shows its path.
    public var sunPosition: CGPoint?
    public init(size: CGSize, horizon: CGFloat, time: Double, date: Date, darkness: Double,
                glow: Double, motionEnabled: Bool, contentColor: Color = .primary,
                layoutDirection: LayoutDirection = .leftToRight, weather: SceneWeather = .clear,
                depthShift: CGFloat = 0, horizonRGB: SIMD3<Double> = .zero, sunPosition: CGPoint? = nil) {
        self.size = size; self.horizon = horizon; self.time = time; self.date = date
        self.darkness = darkness; self.glow = glow; self.motionEnabled = motionEnabled
        self.contentColor = contentColor; self.layoutDirection = layoutDirection; self.weather = weather
        self.depthShift = depthShift; self.horizonRGB = horizonRGB; self.sunPosition = sunPosition
    }
}

/// A reusable composition. All content is provided by the host; the package
/// contains no bundled landmarks, images, fonts, GPS or network clients.
public struct SceneDefinition {
    public typealias Renderer = (inout GraphicsContext, SceneFrame) -> Void
    public var distantBuildingHeights: ClosedRange<CGFloat> = 16...42
    public var nearBuildingHeights: ClosedRange<CGFloat> = 7...22
    public var backdrop: SceneBackdrop
    /// Suppresses incidental buildings, aircraft, birds and traffic.
    public var wild: Bool
    public var ownMoon: Bool
    public var illustrated: Bool
    public var movesForRTL: Bool
    /// Optional height above the horizon, calculated from viewport width.
    public var reservedHeight: ((CGFloat) -> CGFloat)?
    public var draw: (inout ScenePen) -> Void
    /// Replaces the built-in geometry renderer; ideal for layered artwork.
    public var render: Renderer?
    /// Draws above the scene, before weather effects.
    public var overlay: Renderer?
    /// The built-in car lights along the horizon. Turn off where `render` draws its own roads.
    public var showsTraffic = true
    /// The built-in aircraft and birds. Turn off where `render` draws its own.
    public var showsAircraft = true
    public var showsBirds = true
    /// How often the scene is drawn again while it moves. Raise it where the host moves the scene itself, as with tilt.
    public var framesPerSecond: Double = 24

    public init(backdrop: SceneBackdrop = .open, wild: Bool = true,
                ownMoon: Bool = false, illustrated: Bool = false, movesForRTL: Bool = false,
                reservedHeight: ((CGFloat) -> CGFloat)? = nil,
                draw: @escaping (inout ScenePen) -> Void = { _ in },
                render: Renderer? = nil, overlay: Renderer? = nil) {
        self.backdrop = backdrop; self.wild = wild; self.ownMoon = ownMoon
        self.illustrated = illustrated; self.movesForRTL = movesForRTL
        self.reservedHeight = reservedHeight; self.draw = draw
        self.render = render; self.overlay = overlay
    }
}
