import SwiftUI

/// A vector drawing pen with separate silhouettes, openings, materials and lights.
public struct ScenePen {
    public enum Layer { case solid, hole, light }
    public enum Minaret { case arab, ottoman, mughal }
    public struct Tint { public let path: Path; public let color: Color; public let nightOnly: Bool; public var lowerColor: Color? = nil }

    public let width: CGFloat
    public let horizon: CGFloat
    /// The buildings themselves. Each outline is filled on its own, so parts
    /// that overlap never cancel each other out.
    public private(set) var solids: [Path] = []
    /// Openings cut through them: arches, windows.
    public private(set) var holes: [Path] = []
    /// Small parts that glow after dark.
    public private(set) var lights: [Path] = []
    /// Parts with a colour of their own, such as a green dome.
    public private(set) var tints: [Tint] = []
    /// The tips of tall towers, where a red light blinks after dark.
    public private(set) var beacons: [CGPoint] = []
    /// Seconds, for the parts of a skyline that move; 0 when motion is off.
    public let time: Double
    /// 0 by day, 1 at night, for parts that change once they are lit.
    public let night: Double
    /// The scene's displayed time, used by landmarks with a clock face.
    public let clockDate: Date?
    /// Uses a warm material palette for detailed illustrations.
    public let illustrated: Bool
    /// How far a part at depth 1 is displaced sideways, in points. The host
    /// drives it, for instance from the device's tilt; 0 draws a flat scene.
    public let shift: CGFloat
    /// How near the parts drawn next stand: 0 is the horizon and never moves,
    /// 1 moves by the whole `shift`, and more than 1 is a foreground that moves
    /// further. Set it before each landmark, drawing the farthest first.
    public var depth: CGFloat = ScenePen.landmarkDepth
    /// Where landmarks stand when a scene does not say.
    public static let landmarkDepth: CGFloat = 0.7
    private var centre: CGFloat = 0
    /// The centre line as drawn, displaced for the current depth.
    private var origin: CGFloat { centre + shift * depth }

    public init(width: CGFloat, horizon: CGFloat, time: Double = 0, night: Double = 0, clockDate: Date? = nil,
                illustrated: Bool = false, shift: CGFloat = 0) {
        self.width = width; self.horizon = horizon; self.time = time; self.night = night; self.clockDate = clockDate
        self.illustrated = illustrated; self.shift = shift
    }

    /// A repeatable number in 0..<1 for a pair of whole numbers.
    public static func noise(_ a: Int, _ b: Int) -> Double {
        let value = sin(Double(a) * 12.9898 + Double(b) * 78.233) * 43758.5453
        return value - floor(value)
    }

    /// A colour that drifts round the wheel, for towers whose lights change.
    public func hue(every seconds: Double, offset: Double = 0) -> Color {
        Color(hue: (time / seconds + offset).truncatingRemainder(dividingBy: 1), saturation: 0.55, brightness: 1)
    }

    public mutating func beacon(_ x: CGFloat, _ y: CGFloat) { beacons.append(point(x, y)) }

    /// Moves to a landmark whose centre line is this far from the right edge.
    public mutating func at(_ fromRight: CGFloat) { centre = width - fromRight }

    public func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: origin + x, y: horizon - y) }

    /// Reposition the finished skyline without reflecting landmarks or clock faces.
    public mutating func moveToLeftMargin() {
        guard let offset = leftMarginOffset else { return }
        move(by: offset)
    }

    /// How far the skyline must travel for its leftmost part to stand at the left margin.
    public var leftMarginOffset: CGFloat? {
        let paths = solids + holes + lights + tints.map(\.path)
        return paths.map({ $0.boundingRect.minX }).min().map { 8 - $0 }
    }

    /// Slides the finished skyline sideways.
    public mutating func move(by offset: CGFloat) {
        let transform = CGAffineTransform(translationX: offset, y: 0)
        solids = solids.map { $0.applying(transform) }
        holes = holes.map { $0.applying(transform) }
        lights = lights.map { $0.applying(transform) }
        tints = tints.map { Tint(path: $0.path.applying(transform), color: $0.color, nightOnly: $0.nightOnly, lowerColor: $0.lowerColor) }
        beacons = beacons.map { $0.applying(transform) }
    }

    /// Transform all geometry and lights together without mirroring the artwork.
    public mutating func apply(_ transform: CGAffineTransform) {
        solids = solids.map { $0.applying(transform) }
        holes = holes.map { $0.applying(transform) }
        lights = lights.map { $0.applying(transform) }
        tints = tints.map { Tint(path: $0.path.applying(transform), color: $0.color, nightOnly: $0.nightOnly, lowerColor: $0.lowerColor) }
        beacons = beacons.map { $0.applying(transform) }
    }

    /// Composite independently authored geometry, preserving gradients and beacons.
    public mutating func merge(_ other: ScenePen) {
        solids += other.solids; holes += other.holes; lights += other.lights
        tints += other.tints; beacons += other.beacons
    }

    public mutating func occludeLights(behind foreground: Path) {
        let bounds = foreground.boundingRect
        lights.removeAll { $0.boundingRect.intersects(bounds) }
        tints.removeAll { $0.nightOnly && $0.path.boundingRect.intersects(bounds) }
    }

    private mutating func put(_ path: Path, _ layer: Layer) {
        switch layer {
        case .solid: solids.append(path)
        case .hole: holes.append(path)
        case .light: lights.append(path)
        }
    }

    // MARK: Outlines

    public func blockPath(_ x: CGFloat, _ w: CGFloat, _ h: CGFloat, from y: CGFloat = 0) -> Path {
        Path(CGRect(x: origin + x - w / 2, y: horizon - y - h, width: w, height: h))
    }

    public func discPath(_ x: CGFloat, _ y: CGFloat, _ r: CGFloat) -> Path {
        Path(ellipseIn: CGRect(x: origin + x - r, y: horizon - y - r, width: r * 2, height: r * 2))
    }

    /// Half an ellipse standing on `y`.
    public func domePath(_ x: CGFloat, _ w: CGFloat, on y: CGFloat, rise: CGFloat? = nil) -> Path {
        let a = w / 2, b = rise ?? w / 2, k: CGFloat = 0.5523
        var path = Path()
        path.move(to: point(x - a, y))
        path.addCurve(to: point(x, y + b), control1: point(x - a, y + b * k), control2: point(x - a * k, y + b))
        path.addCurve(to: point(x + a, y), control1: point(x + a * k, y + b), control2: point(x + a, y + b * k))
        path.closeSubpath()
        return path
    }

    public func polygon(_ points: [(CGFloat, CGFloat)]) -> Path {
        var path = Path()
        for (index, item) in points.enumerated() {
            if index == 0 { path.move(to: point(item.0, item.1)) } else { path.addLine(to: point(item.0, item.1)) }
        }
        path.closeSubpath()
        return path
    }

    // MARK: Shapes

    /// A rectangle centred on `x`, `w` wide, rising `h` from `y`.
    public mutating func block(_ x: CGFloat, _ w: CGFloat, _ h: CGFloat, from y: CGFloat = 0, _ layer: Layer = .solid) {
        put(blockPath(x, w, h, from: y), layer)
    }

    public mutating func disc(_ x: CGFloat, _ y: CGFloat, _ r: CGFloat, _ layer: Layer = .solid) {
        put(discPath(x, y, r), layer)
    }

    public mutating func dome(_ x: CGFloat, _ w: CGFloat, on y: CGFloat, rise: CGFloat? = nil, _ layer: Layer = .solid) {
        put(domePath(x, w, on: y, rise: rise), layer)
    }

    public mutating func shape(_ points: [(CGFloat, CGFloat)], _ layer: Layer = .solid) {
        put(polygon(points), layer)
    }

    /// A free outline; the closure is given the pen's own point function.
    public mutating func curve(_ layer: Layer = .solid, _ build: (inout Path, (CGFloat, CGFloat) -> CGPoint) -> Void) {
        var path = Path()
        build(&path, point)
        put(path, layer)
    }

    /// Material shading follows the transformed outline, including courtyard scaling.
    public mutating func wash(_ path: Path, top: Color, bottom: Color) {
        tints.append(Tint(path: path, color: top, nightOnly: false, lowerColor: bottom))
    }

    public mutating func tint(_ path: Path, _ color: Color, nightOnly: Bool = false) {
        tints.append(Tint(path: path, color: color, nightOnly: nightOnly))
    }

    /// A quiet architectural line placed inside a solid face. Callers keep it
    /// clear of cut-outs; unlike holes, tints are drawn above the silhouette.
    public mutating func detail(_ path: Path, strength: Double = 1) {
        if illustrated {
            tint(path, Color(red: 0.88, green: 0.82, blue: 0.71).opacity((0.28 + night * 0.08) * strength))
        } else {
            tint(path, Color(red: 0.72, green: 0.76, blue: 0.80).opacity((0.18 + night * 0.12) * strength))
        }
    }

    /// A thin point: `w` wide at `y`, closing at `top`.
    public mutating func spire(_ x: CGFloat, _ w: CGFloat, from y: CGFloat, to top: CGFloat) {
        shape([(x - w / 2, y), (x + w / 2, y), (x, top)])
    }

    /// A dome that swells past its base and closes in a point, with a finial.
    public mutating func onion(_ x: CGFloat, _ w: CGFloat, on y: CGFloat, _ h: CGFloat) {
        curve { path, at in
            path.move(to: at(x - w * 0.30, y))
            path.addCurve(to: at(x - w * 0.20, y + h * 0.72), control1: at(x - w * 0.72, y + h * 0.10), control2: at(x - w * 0.62, y + h * 0.58))
            path.addQuadCurve(to: at(x, y + h), control: at(x - w * 0.04, y + h * 0.84))
            path.addQuadCurve(to: at(x + w * 0.20, y + h * 0.72), control: at(x + w * 0.04, y + h * 0.84))
            path.addCurve(to: at(x + w * 0.30, y), control1: at(x + w * 0.62, y + h * 0.58), control2: at(x + w * 0.72, y + h * 0.10))
            path.closeSubpath()
        }
        block(x, 0.9, h * 0.22, from: y + h * 0.96)
    }

    /// An opening `w` wide and `h` high, round-headed or pointed.
    public mutating func arch(_ x: CGFloat, _ w: CGFloat, _ h: CGFloat, from y: CGFloat = 0, pointed: Bool = false, _ layer: Layer = .hole) {
        if pointed {
            let spring = y + h * 0.55
            curve(layer) { path, at in
                path.move(to: at(x - w / 2, y))
                path.addLine(to: at(x - w / 2, spring))
                path.addQuadCurve(to: at(x, y + h), control: at(x - w / 2, y + h * 0.90))
                path.addQuadCurve(to: at(x + w / 2, spring), control: at(x + w / 2, y + h * 0.90))
                path.addLine(to: at(x + w / 2, y))
                path.closeSubpath()
            }
        } else {
            block(x, w, max(0, h - w / 2), from: y, layer)
            dome(x, w, on: y + max(0, h - w / 2), layer)
        }
    }

    public mutating func minaret(_ x: CGFloat, _ h: CGFloat, _ style: Minaret = .arab) {
        switch style {
        case .arab:
            block(x, 3.2, h * 0.60)
            block(x, 5.8, 1.6, from: h * 0.60)
            block(x, 2.6, h * 0.20, from: h * 0.60)
            block(x, 4.6, 1.4, from: h * 0.80)
            block(x, 2.0, h * 0.08, from: h * 0.80)
            spire(x, 2.8, from: h * 0.88, to: h)
            disc(x, h * 0.60 + 3.4, 0.9, .light); disc(x, h * 0.80 + 2.8, 0.8, .light)
        case .ottoman:
            block(x, 2.6, h * 0.80)
            block(x, 4.8, 1.3, from: h * 0.46)
            block(x, 4.4, 1.3, from: h * 0.64)
            block(x, 3.6, 1.2, from: h * 0.79)
            spire(x, 3.0, from: h * 0.80, to: h)
            disc(x, h * 0.46 + 2.8, 0.8, .light); disc(x, h * 0.64 + 2.8, 0.8, .light)
        case .mughal:
            shape([(x - 2.2, 0), (x + 2.2, 0), (x + 1.6, h * 0.82), (x - 1.6, h * 0.82)])
            block(x, 5.2, 1.4, from: h * 0.82)
            block(x, 3.4, h * 0.06, from: h * 0.82)
            onion(x, 4.8, on: h * 0.88, h * 0.12)
            disc(x, h * 0.82 + 2.6, 0.8, .light)
        }
    }
}
