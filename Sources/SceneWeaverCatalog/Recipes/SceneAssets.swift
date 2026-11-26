import SwiftUI
import SceneWeaver

/// The wider bank of pieces for the surah scenes. Each is drawn with the
/// skyline pen in points across from the pen's centre (`at`) and up from the
/// ground. See the first pieces and their conventions in `SurahScenes.swift`.
/// Figures and animals are used sparingly in generic, non-historical scenes.
///
/// A piece's own colours are tints, and tints lie over every silhouette in the
/// scene whatever the order of the calls. So the landforms that stand behind
/// other things keep their colour high up or leave it out, and what is meant
/// to stand in front of a coloured piece should be placed clear of it.

// MARK: The hand

/// What the pieces are drawn with: rounded outlines, lines of a given weight,
/// leaf masses, flames, arches and the like.
extension SkylinePen {
    typealias Spot = (CGFloat, CGFloat)

    /// The scene's own edges, measured from the pen's centre.
    var leftEdge: CGFloat { -point(0, 0).x }
    var rightEdge: CGFloat { width - point(0, 0).x }

    static let lampLight = Color(red: 1.0, green: 0.82, blue: 0.48)

    func shade(_ tone: (Double, Double, Double), _ opacity: Double = 1) -> Color {
        shade(tone.0, tone.1, tone.2, opacity)
    }

    /// A line through the spots with every corner rounded; closed, it is an outline.
    func smoothPath(_ spots: [Spot], closed: Bool = true) -> Path {
        var path = Path()
        guard let first = spots.first, let last = spots.last else { return path }
        func mid(_ a: Spot, _ b: Spot) -> CGPoint { point((a.0 + b.0) / 2, (a.1 + b.1) / 2) }
        if spots.count < 3 {
            path.move(to: point(first.0, first.1))
            for spot in spots.dropFirst() { path.addLine(to: point(spot.0, spot.1)) }
        } else if closed {
            path.move(to: mid(last, first))
            for index in spots.indices {
                path.addQuadCurve(to: mid(spots[index], spots[(index + 1) % spots.count]), control: point(spots[index].0, spots[index].1))
            }
            path.closeSubpath()
        } else {
            path.move(to: point(first.0, first.1))
            for index in 1..<(spots.count - 1) {
                path.addQuadCurve(to: mid(spots[index], spots[index + 1]), control: point(spots[index].0, spots[index].1))
            }
            path.addLine(to: point(last.0, last.1))
        }
        return path
    }

    /// A rounded crest standing on a level base: hills, mounds, drifts.
    func ridgePath(_ spots: [Spot], base: CGFloat = 0) -> Path {
        var path = smoothPath(spots, closed: false)
        guard let first = spots.first, let last = spots.last else { return path }
        path.addLine(to: point(last.0, base)); path.addLine(to: point(first.0, base)); path.closeSubpath()
        return path
    }

    /// A line of a given weight, as an outline that can be filled.
    func strokePath(_ spots: [Spot], _ weight: CGFloat, smooth: Bool = false) -> Path {
        var path = Path()
        if smooth {
            path = smoothPath(spots, closed: false)
        } else {
            for (index, spot) in spots.enumerated() {
                if index == 0 { path.move(to: point(spot.0, spot.1)) } else { path.addLine(to: point(spot.0, spot.1)) }
            }
        }
        return path.strokedPath(StrokeStyle(lineWidth: weight, lineCap: .round, lineJoin: .round))
    }

    mutating func add(_ path: Path, _ layer: Layer = .solid) {
        curve(layer) { outline, _ in outline.addPath(path) }
    }

    mutating func line(_ spots: [Spot], _ weight: CGFloat, _ layer: Layer = .solid, smooth: Bool = false) {
        add(strokePath(spots, weight, smooth: smooth), layer)
    }

    /// A spot turned about another, counter-clockwise.
    func turn(_ spot: Spot, about centre: Spot, by angle: Double) -> Spot {
        let dx = Double(spot.0 - centre.0), dy = Double(spot.1 - centre.1)
        return (centre.0 + CGFloat(dx * cos(angle) - dy * sin(angle)), centre.1 + CGFloat(dx * sin(angle) + dy * cos(angle)))
    }

    /// A mass of leaves, a cloud, a rock: a round whose edge swells out in
    /// lobes, no two quite alike. `flat` presses its underside in.
    func crownPath(_ cx: CGFloat, _ cy: CGFloat, _ rx: CGFloat, _ ry: CGFloat, lobes: Int = 7, depth: CGFloat = 0.16,
                   seed: Int = 0, flat: CGFloat = 0) -> Path {
        var spots: [Spot] = []
        let count = max(3, lobes), start = Self.noise(seed, 5) * 2 * Double.pi
        for lobe in 0..<count {
            let swell = depth * (0.9 + 0.8 * CGFloat(Self.noise(seed * 31 + lobe, 9)))
            for step in 0..<4 {
                let angle = start + (Double(lobe) + Double(step) / 4) / Double(count) * 2 * Double.pi
                let reach = 1 - depth * 0.6 + swell * CGFloat(sin(Double(step) / 4 * Double.pi))
                var py = CGFloat(sin(angle)) * ry * reach
                if py < 0 { py *= 1 - flat }
                spots.append((cx + CGFloat(cos(angle)) * rx * reach, cy + py))
            }
        }
        return smoothPath(spots)
    }

    /// A soft light: rings laid one inside another, so that it has no edge.
    mutating func glow(_ x: CGFloat, _ y: CGFloat, _ r: CGFloat, _ color: Color, _ strength: Double, tall: CGFloat = 1, nightOnly: Bool = false) {
        let centre = point(x, y)
        for ring in 0..<10 {
            let half = r * (1 - CGFloat(ring) * 0.095)
            tint(Path(ellipseIn: CGRect(x: centre.x - half, y: centre.y - half * tall, width: half * 2, height: half * tall * 2)),
                 color.opacity(strength / 10), nightOnly: nightOnly)
        }
    }

    /// One tongue of flame, its tip leaning by `lean`.
    func flamePath(_ x: CGFloat, _ y: CGFloat, width w: CGFloat, height h: CGFloat, lean: CGFloat = 0) -> Path {
        var path = Path()
        path.move(to: point(x - w / 2, y))
        path.addCurve(to: point(x + lean, y + h), control1: point(x - w * 0.64, y + h * 0.36), control2: point(x - w * 0.06 + lean * 0.4, y + h * 0.62))
        path.addCurve(to: point(x + w / 2, y), control1: point(x + w * 0.22 + lean * 0.5, y + h * 0.56), control2: point(x + w * 0.66, y + h * 0.30))
        path.closeSubpath()
        return path
    }

    /// The outline of an opening, as `arch` cuts it.
    func archPath(_ x: CGFloat, _ w: CGFloat, _ h: CGFloat, from y: CGFloat = 0, pointed: Bool = true) -> Path {
        var path = Path()
        if pointed {
            let spring = y + h * 0.55
            path.move(to: point(x - w / 2, y)); path.addLine(to: point(x - w / 2, spring))
            path.addQuadCurve(to: point(x, y + h), control: point(x - w / 2, y + h * 0.90))
            path.addQuadCurve(to: point(x + w / 2, spring), control: point(x + w / 2, y + h * 0.90))
            path.addLine(to: point(x + w / 2, y)); path.closeSubpath()
        } else {
            path.addPath(blockPath(x, w, max(0, h - w / 2), from: y))
            path.addPath(domePath(x, w, on: y + max(0, h - w / 2)))
        }
        return path
    }

    /// A dome that swells a little over its base and closes in a soft point.
    func bulbPath(_ x: CGFloat, _ w: CGFloat, on y: CGFloat, rise: CGFloat) -> Path {
        let a = w / 2
        var path = Path()
        path.move(to: point(x - a, y))
        path.addCurve(to: point(x, y + rise), control1: point(x - a * 1.14, y + rise * 0.52), control2: point(x - a * 0.40, y + rise * 0.84))
        path.addCurve(to: point(x + a, y), control1: point(x + a * 0.40, y + rise * 0.84), control2: point(x + a * 1.14, y + rise * 0.52))
        path.closeSubpath()
        return path
    }

    /// A crescent of radius `r`. Untilted, its lit limb is to the right;
    /// `fill` is how far the dark eats into it (1 leaves nothing, 0 a half moon).
    func crescentPath(_ x: CGFloat, _ y: CGFloat, _ r: CGFloat, tilt: Double = 0, fill: CGFloat = 0.6) -> Path {
        var spots: [Spot] = []
        for step in 0...14 {
            let angle = -Double.pi / 2 + Double.pi * Double(step) / 14
            spots.append((x + r * CGFloat(cos(angle)), y + r * CGFloat(sin(angle))))
        }
        for step in stride(from: 13, through: 1, by: -1) {
            let angle = -Double.pi / 2 + Double.pi * Double(step) / 14
            spots.append((x + r * fill * CGFloat(cos(angle)), y + r * CGFloat(sin(angle))))
        }
        return polygon(spots.map { turn($0, about: (x, y), by: tilt) })
    }

    /// The finial of a dome or a minaret: a stem, a bead, and a crescent open to the sky.
    mutating func finial(_ x: CGFloat, from y: CGFloat, height h: CGFloat, gilt: Bool = false) {
        let r = max(1.1, h * 0.24)
        block(x, max(0.7, h * 0.09), h - r * 1.5, from: y)
        disc(x, y + h * 0.30, max(0.8, h * 0.11))
        let moon = crescentPath(x, y + h - r, r, tilt: -Double.pi / 2, fill: 0.5)
        add(moon)
        if gilt { tint(moon, shade(0.92, 0.74, 0.36)) }
        detail(blockPath(x, max(0.3, h * 0.035), max(0, h - r * 1.9), from: y + r * 0.3), strength: 0.6)
    }

    /// One palm frond from its base to its tip, arching by `arch`, with
    /// leaflets `leaf` long hanging from its rib.
    func frondPath(from base: Spot, to tip: Spot, arch: CGFloat, leaf: CGFloat) -> Path {
        let control: Spot = ((base.0 + tip.0) / 2, (base.1 + tip.1) / 2 + arch)
        func on(_ t: CGFloat) -> Spot {
            let u = 1 - t
            return (u * u * base.0 + 2 * u * t * control.0 + t * t * tip.0, u * u * base.1 + 2 * u * t * control.1 + t * t * tip.1)
        }
        // Leaflets stand off the rib: fully below it, and above it too on a frond that stands up.
        let dx = tip.0 - base.0, dy = tip.1 - base.1, length = max(0.01, (dx * dx + dy * dy).squareRoot())
        var nx = -dy / length, ny = dx / length
        if ny > 0 || (ny == 0 && nx > 0) { nx = -nx; ny = -ny }
        let upper = 0.25 + 0.75 * min(1, abs(dy) / length)
        let steps = 7
        var path = Path()
        path.move(to: point(base.0, base.1))
        for step in 1..<steps {
            let t = CGFloat(step) / CGFloat(steps), spot = on(t), notch = on(t - 0.5 / CGFloat(steps))
            let reach = leaf * CGFloat(sin(Double(t) * Double.pi)) * upper * 0.8
            path.addLine(to: point(notch.0 - nx * reach * 0.3, notch.1 - ny * reach * 0.3))
            path.addLine(to: point(spot.0 - nx * reach, spot.1 - ny * reach))
        }
        path.addLine(to: point(tip.0, tip.1))
        for step in stride(from: steps - 1, through: 1, by: -1) {
            let t = CGFloat(step) / CGFloat(steps), spot = on(t), notch = on(t - 0.5 / CGFloat(steps))
            let reach = leaf * (0.35 + 0.65 * CGFloat(sin(Double(t) * Double.pi)))
            path.addLine(to: point(spot.0 + nx * reach, spot.1 + ny * reach))
            path.addLine(to: point(notch.0 + nx * reach * 0.3, notch.1 + ny * reach * 0.3))
        }
        path.closeSubpath()
        return path
    }

    /// A trunk from the ground at `x` to `top`: flared at the root, narrowing as it climbs.
    func trunkPath(_ x: CGFloat, to top: Spot, width w: CGFloat, taper: CGFloat = 0.5, flare: CGFloat = 0.6) -> Path {
        var path = Path()
        let half = w / 2, crown = half * taper
        path.move(to: point(x - half - w * flare, 0))
        path.addQuadCurve(to: point(x - half * 0.9 + (top.0 - x) * 0.3, top.1 * 0.34), control: point(x - half, top.1 * 0.06))
        path.addQuadCurve(to: point(top.0 - crown, top.1), control: point(x - half * 0.8 + (top.0 - x) * 0.55, top.1 * 0.66))
        path.addLine(to: point(top.0 + crown, top.1))
        path.addQuadCurve(to: point(x + half * 0.9 + (top.0 - x) * 0.3, top.1 * 0.34), control: point(x + half * 0.8 + (top.0 - x) * 0.55, top.1 * 0.66))
        path.addQuadCurve(to: point(x + half + w * flare, 0), control: point(x + half, top.1 * 0.06))
        path.closeSubpath()
        return path
    }

    /// A small lantern hung from `top`: cap, glass and foot. It burns after
    /// dark, and its glass shows pale by day.
    mutating func smallLantern(_ x: CGFloat, top: CGFloat, scale s: CGFloat = 1, flame: Double) {
        shape([(x - 0.5 * s, top), (x + 0.5 * s, top), (x + 2.2 * s, top - 1.8 * s), (x - 2.2 * s, top - 1.8 * s)])
        shape([(x - 1.9 * s, top - 1.8 * s), (x + 1.9 * s, top - 1.8 * s), (x + 1.3 * s, top - 6.2 * s), (x - 1.3 * s, top - 6.2 * s)])
        block(x, 3.4 * s, 0.8 * s, from: top - 7 * s)
        glow(x, top - 4 * s, 10 * s, Self.lampLight, 0.34 * flame, nightOnly: true)
        tint(polygon([(x - 1.4 * s, top - 2.2 * s), (x + 1.4 * s, top - 2.2 * s), (x + 0.9 * s, top - 5.8 * s), (x - 0.9 * s, top - 5.8 * s)]),
             Self.lampLight.opacity(0.20 + 0.75 * night * flame))
        tint(strokePath([(x, top - 2.2 * s), (x, top - 5.8 * s)], 0.2 * s), Color.black.opacity(0.32))
        tint(blockPath(x, 2.0 * s, 0.18 * s, from: top - 3.0 * s), Color.white.opacity(0.22))
    }

    /// How steadily a flame burns just now: near 1, wavering a little.
    func flicker(_ seed: Double = 0) -> Double {
        0.84 + 0.10 * sin(time * 4.3 + seed) + 0.06 * sin(time * 8.7 + seed * 2.3)
    }
}

// MARK: The pieces

extension SkylinePen {
    // MARK: Land and water

    /// A low rolling ridge across the whole width, nearer than the backdrop.
    mutating func hills(seed: Int = 0, height: CGFloat = 26) {
        let left = leftEdge - 12, right = rightEdge + 12
        let a = Self.noise(seed, 211) * 6.28, b = Self.noise(seed, 213) * 6.28, c = Self.noise(seed, 217) * 6.28
        func rise(_ px: CGFloat) -> CGFloat {
            let t = Double(px - left)
            let level = 0.56 + 0.26 * sin(t * 0.017 + a) + 0.13 * sin(t * 0.041 + b) + 0.05 * sin(t * 0.097 + c)
            return height * CGFloat(max(level, 0.14))
        }
        var crest: [Spot] = []
        var px = left
        while px <= right + 0.1 { crest.append((px, rise(px))); px += 9 }
        add(ridgePath(crest))
        // Scrub along the skyline, and a rock or two breaking it.
        var bushes = Path(), scrub = Path()
        var index = 0
        px = left + 20 + CGFloat(Self.noise(seed, 219)) * 30
        while px < right - 10 {
            let chance = Self.noise(seed * 17 + index, 221), size = 1.8 + CGFloat(Self.noise(seed * 17 + index, 223)) * 2.2
            if chance > 0.72 {
                bushes.addPath(polygon([(px - size * 1.3, rise(px - size * 1.3) - 1), (px - size * 0.5, rise(px) + size * 0.9),
                                        (px + size * 0.6, rise(px) + size * 0.6), (px + size * 1.5, rise(px + size * 1.5) - 1)]))
            } else {
                let crown = crownPath(px, rise(px) + size * 0.2, size * 1.25, size * 0.8, lobes: 5, depth: 0.2, seed: seed + index)
                bushes.addPath(crown)
                if quranScene { scrub.addPath(crown) }
                if chance < 0.4 {
                    let smaller = crownPath(px + size * 1.5, rise(px + size * 1.5), size * 0.8, size * 0.55, lobes: 4, depth: 0.2, seed: seed + index + 7)
                    bushes.addPath(smaller)
                    if quranScene { scrub.addPath(smaller) }
                }
            }
            px += 26 + CGFloat(Self.noise(seed * 17 + index, 227)) * 44
            index += 1
        }
        add(bushes)
        if quranScene { tint(scrub, shade(0.31, 0.39, 0.25, 0.90)) }
        // Broken bands follow the lie of the slopes, rather than a repeating
        // texture across the sky. Their spacing varies with the land itself.
        var strata = Path(), stones = Path()
        for band in 0..<3 {
            let fraction = CGFloat(0.24 + Double(band) * 0.21)
            var marks: [Spot] = []
            var xx = left + 7
            while xx <= right {
                marks.append((xx, rise(xx) * fraction))
                xx += 12
            }
            strata.addPath(strokePath(marks, 0.45 + CGFloat(band) * 0.12, smooth: true))
        }
        for rock in 0..<14 {
            let xx = left + (right - left) * CGFloat(Self.noise(seed * 37 + rock, 229))
            let yy = rise(xx) * (0.08 + 0.35 * CGFloat(Self.noise(seed * 37 + rock, 231)))
            let wide = 1.2 + CGFloat(Self.noise(seed * 37 + rock, 233)) * 2.5
            stones.addPath(polygon([(xx - wide, yy), (xx - wide * 0.2, yy + 0.9), (xx + wide, yy), (xx, yy - 0.4)]))
        }
        tint(strata, shade(0.72, 0.63, 0.50, 0.17))
        tint(stones, shade(0.83, 0.73, 0.59, 0.26))
    }

    /// An island or a far shore rising from water.
    mutating func island(_ x: CGFloat, _ w: CGFloat, _ h: CGFloat) {
        let profile: [Spot] = [(-0.50, 0), (-0.42, 0.07), (-0.33, 0.24), (-0.25, 0.62), (-0.17, 0.92), (-0.10, 1.0), (-0.03, 0.86),
                               (0.04, 0.56), (0.11, 0.50), (0.18, 0.58), (0.25, 0.44), (0.33, 0.20), (0.42, 0.06), (0.50, 0)]
        let crest = profile.map { (x + $0.0 * w, $0.1 * h) }
        add(ridgePath(crest))
        // Scrub on its back, the rock of its head, a pale strand, and its shadow on the water.
        let scrub = [crownPath(x + w * 0.06, h * 0.52, w * 0.04, h * 0.07, lobes: 5, depth: 0.2, seed: Int(x)),
                     crownPath(x + w * 0.19, h * 0.555, w * 0.035, h * 0.06, lobes: 5, depth: 0.2, seed: Int(x) + 3),
                     crownPath(x + w * 0.30, h * 0.27, w * 0.028, h * 0.045, lobes: 4, depth: 0.2, seed: Int(x) + 5)]
        var green = Path()
        for crown in scrub {
            add(crown)
            if quranScene { green.addPath(crown) }
        }
        if quranScene { tint(green, shade(0.31, 0.40, 0.26, 0.90)) }
        detail(polygon([(x - w * 0.25, h * 0.60), (x - w * 0.10, h * 0.98), (x - w * 0.08, h * 0.90), (x - w * 0.19, h * 0.50)]), strength: 0.5)
        detail(polygon([(x + w * 0.04, h * 0.52), (x + w * 0.11, h * 0.48), (x + w * 0.14, h * 0.30), (x + w * 0.10, h * 0.30)]), strength: 0.4)
        tint(ridgePath(crest.map { ($0.0, -$0.1 * 0.30) }), Color.black.opacity(0.16))
        var strand = Path()
        strand.move(to: point(x - w * 0.52, 0.4))
        strand.addQuadCurve(to: point(x + w * 0.52, 0.4), control: point(x, 2.8))
        strand.addQuadCurve(to: point(x - w * 0.52, 0.4), control: point(x, -1.2))
        tint(strand, shade(0.86, 0.78, 0.60, 0.42))
        // Broken shelves in the exposed rock and a fine edge to the beach.
        var shelves = Path()
        for band in 0..<3 {
            let yy = h * (0.15 + CGFloat(band) * 0.12)
            let reach = w * (0.30 - CGFloat(band) * 0.045)
            shelves.addPath(strokePath([(x - reach, yy), (x - reach * 0.36, yy + h * 0.035),
                                        (x + reach * 0.12, yy - h * 0.01), (x + reach * 0.68, yy + h * 0.02)],
                                       max(0.4, h * 0.012), smooth: true))
        }
        tint(shelves, shade(0.78, 0.70, 0.57, 0.30))
        tint(strokePath([(x - w * 0.44, 0.1), (x - w * 0.12, 0.5), (x + w * 0.22, 0.2), (x + w * 0.44, 0.1)],
                        max(0.35, h * 0.012), smooth: true), Color.white.opacity(0.25 * (1 - 0.4 * night)))
    }

    /// A heavy swell: crests rolling across open water. Moves.
    mutating func waves(from left: CGFloat, to right: CGFloat, height: CGFloat = 8) {
        let clock = time, dark = night
        let rows: [(CGFloat, CGFloat, Double, Double, CGFloat)] = [(1.2, 0.45, 46, 0.52, 9), (-5, 0.74, 64, 0.42, 13), (-14, 1.0, 88, 0.34, 18)]
        let tones: [(Double, Double, Double)] = [(0.22, 0.49, 0.62), (0.16, 0.42, 0.56), (0.11, 0.34, 0.49)]
        for (index, row) in rows.enumerated() {
            let base = row.0, swell = height * row.1, k = 2 * Double.pi / row.2
            let shift = clock * row.3 + Double(index) * 1.9
            func level(_ px: CGFloat) -> CGFloat {
                // Crests are sharper than troughs, and a longer swell runs under them.
                let lift = 0.5 + 0.5 * sin(Double(px) * k - shift)
                return base + swell * CGFloat(pow(lift, 1.7)) + swell * 0.20 * CGFloat(sin(Double(px) * k * 0.37 + shift * 0.6))
            }
            var sea = Path()
            sea.move(to: point(left, base - row.4))
            var px = left
            while px < right { sea.addLine(to: point(px, level(px))); px += 3 }
            sea.addLine(to: point(right, level(right))); sea.addLine(to: point(right, base - row.4)); sea.closeSubpath()
            tint(sea, shade(tones[index], 0.94))
            // Foam breaking along each crest.
            var foam = Path()
            let first = Int(floor((Double(left) * k - shift) / (2 * Double.pi))) - 1
            let last = Int(ceil((Double(right) * k - shift) / (2 * Double.pi))) + 1
            for crest in first...max(first, last) {
                let cx = CGFloat((Double.pi / 2 + shift + 2 * Double.pi * Double(crest)) / k), reach = CGFloat(row.2) * 0.17
                guard cx - reach > left, cx + reach < right else { continue }
                foam.move(to: point(cx - reach, level(cx - reach)))
                foam.addQuadCurve(to: point(cx + reach * 0.7, level(cx + reach * 0.7)), control: point(cx, level(cx) + 1.5))
                foam.addQuadCurve(to: point(cx - reach, level(cx - reach)), control: point(cx - reach * 0.1, level(cx) - 1.6))
                foam.closeSubpath()
            }
            tint(foam, Color.white.opacity((0.20 + 0.09 * Double(index)) * (1 - 0.5 * dark)))
            // Short broken reflections sit below the moving crest. Keep them
            // in one path per row so animation stays cheap on the phone.
            var glints = Path()
            for mark in 0..<14 {
                let phase = Self.noise(mark + index * 23, 243)
                let cx = left + (right - left) * CGFloat(phase)
                let yy = base - 2 - CGFloat(Self.noise(mark + index * 23, 245)) * (row.4 - 3)
                let span = (2.5 + CGFloat(Self.noise(mark + index * 23, 247)) * 5) * (0.7 + CGFloat(index) * 0.25)
                glints.addPath(polygon([(cx - span, yy), (cx, yy + 0.38), (cx + span, yy), (cx, yy - 0.38)]))
            }
            tint(glints, Color.white.opacity((0.12 + Double(index) * 0.035) * (1 - dark * 0.55)))
        }
    }

    /// The sea standing in two walls with a dry path between. Moves.
    mutating func partedSea(_ x: CGFloat, gap: CGFloat = 44, height: CGFloat = 70) {
        let near = gap * 1.3
        // The dry path, widening towards the reader, the sea's ripples left in its sand.
        tint(polygon([(x - gap / 2, 0.6), (x + gap / 2, 0.6), (x + near, -46), (x - near, -46)]), shade(0.72, 0.62, 0.45, 0.60))
        var ripples = Path()
        for row in 0..<5 {
            let part = CGFloat(row + 1) / 6, y = -46 * part, half = (gap / 2 + (near - gap / 2) * part) * 0.62
            ripples.addPath(polygon([(x - half, y), (x - half * 0.2, y + 0.9), (x + half * 0.7, y), (x - half * 0.1, y - 0.5)]))
        }
        tint(ripples, Color.black.opacity(0.13))
        for side in [-1.0, 1.0] as [CGFloat] {
            let edge = x + side * gap / 2, far = side < 0 ? leftEdge - 8 : rightEdge + 8
            let heave = CGFloat(sin(time * 0.5 + Double(side) * 1.2)) * 1.6, top = height + heave
            tint(polygon([(edge, 0.6), (far, 0.6), (far, -46), (x + side * near, -46)]), shade(0.10, 0.33, 0.48, 0.92))
            // The wall: a sheer face, a lip curling over the path, and a long back falling away to the open sea.
            var crest: [Spot] = [(edge, 0), (edge + side * 2.6, top * 0.30), (edge + side * 1.8, top * 0.62), (edge - side * 2, top * 0.86),
                                 (edge - side * 7.5, top * 0.96), (edge - side * 4, top * 1.035), (edge + side * 7, top * 1.02)]
            let back: [(CGFloat, CGFloat)] = [(24, 0.90), (48, 0.71), (78, 0.50), (112, 0.29), (150, 0.12), (192, 0)]
            for (index, spot) in back.enumerated() {
                let roll = index == back.count - 1 ? 0 : CGFloat(sin(time * 0.6 + Double(index) * 1.4 + Double(side))) * 1.3
                crest.append((edge + side * spot.0, top * spot.1 + roll))
            }
            var wall = smoothPath(crest, closed: false)
            wall.closeSubpath()
            tint(wall, shade(0.10, 0.34, 0.50, 0.95))
            // Light in the face of the wall, and water still running down it.
            tint(smoothPath([(edge + side * 1.2, 1), (edge + side * 2.6, top * 0.30), (edge + side * 1.8, top * 0.62), (edge - side * 2.4, top * 0.88),
                             (edge + side * 2.6, top * 0.84), (edge + side * 6, top * 0.6), (edge + side * 6.8, top * 0.3), (edge + side * 5.4, 1)]),
                 shade(0.32, 0.64, 0.74, 0.36))
            tint(smoothPath([(edge + side * 8, top * 0.90), (edge + side * 30, top * 0.80), (edge + side * 70, top * 0.50), (edge + side * 120, top * 0.22),
                             (edge + side * 70, top * 0.40), (edge + side * 30, top * 0.66)]), shade(0.20, 0.50, 0.64, 0.30))
            for streak in 0..<7 {
                let id = streak + (side < 0 ? 0 : 20)
                let out = 3 + CGFloat(Self.noise(id, 251)) * 60
                let tall = top * CGFloat(pow(Double(max(0, 1 - out / 192)), 1.5))
                let run = (Self.noise(id, 253) + time * (0.05 + 0.04 * Self.noise(id, 255))).truncatingRemainder(dividingBy: 1)
                let y = tall * (0.82 - 0.7 * CGFloat(run))
                tint(polygon([(edge + side * out, y), (edge + side * (out + 0.8), y), (edge + side * (out + 0.8), y - 8), (edge + side * out, y - 8)]),
                     Color.white.opacity(0.20 * sin(run * Double.pi) * (1 - 0.4 * night)))
            }
            // Curving layers inside the wall give the water depth while the
            // existing moving streaks and heaving crest remain visible.
            var layers = Path(), bubbles = Path()
            for band in 0..<4 {
                let inset = CGFloat(band) * 5 + 10
                let y = top * (0.16 + CGFloat(band) * 0.15)
                let wave = CGFloat(sin(time * 0.45 + Double(band) + Double(side))) * 0.8
                layers.addPath(strokePath([(edge + side * inset, y), (edge + side * (inset + 9), y + 1 + wave),
                                           (edge + side * (inset + 20), y + 2), (edge + side * (inset + 28), y + 1 - wave)],
                                          0.65, smooth: true))
            }
            for bubble in 0..<12 {
                let out = 6 + CGFloat(Self.noise(bubble + (side < 0 ? 0 : 20), 257)) * 46
                let yy = top * (0.12 + 0.58 * CGFloat(Self.noise(bubble, 259)))
                bubbles.addPath(discPath(edge + side * out, yy, 0.5 + CGFloat(bubble % 3) * 0.18))
            }
            tint(layers, shade(0.48, 0.76, 0.82, 0.24))
            tint(bubbles, Color.white.opacity(0.18 * (1 - 0.4 * night)))
            // Foam on the lip and at the wall's foot.
            tint(strokePath([(edge - side * 7.5, top * 0.96), (edge - side * 4, top * 1.035), (edge + side * 7, top * 1.02), (edge + side * 24, top * 0.90)], 1.5, smooth: true),
                 Color.white.opacity(0.50 * (1 - 0.35 * night)))
            for drop in 0..<4 {
                let toss = (Self.noise(drop, 257) + time * 0.22).truncatingRemainder(dividingBy: 1)
                tint(discPath(edge - side * (7 + CGFloat(toss) * 5 + CGFloat(drop)), top * 0.97 - CGFloat(toss * toss) * 12, 0.8),
                     Color.white.opacity(0.5 * (1 - toss) * (1 - 0.35 * night)))
            }
            tint(polygon([(edge - side * 1.5, 0.4), (edge + side * 4, 1.8), (edge + side * 12, 0.4), (edge + side * 3, -0.8)]),
                 Color.white.opacity(0.32 * (1 - 0.35 * night)))
        }
    }

    /// Two waters of different colour meeting along a line that does not blur. Moves.
    mutating func twoSeas(meetAt x: CGFloat, depth: CGFloat = 46) {
        let left = leftEdge - 6, right = rightEdge + 6
        // Where they meet: from the horizon towards the reader, swaying with the swell, never mixing.
        var seam: [Spot] = []
        for step in 0...8 {
            let part = CGFloat(step) / 8
            let sway = CGFloat(sin(time * 0.5 + Double(step) * 0.9)) * (0.4 + 2.2 * part)
            seam.append((x + part * 34 + CGFloat(sin(Double(step) * 1.3)) * 3 * part + sway, 0.6 - part * (depth + 0.6)))
        }
        // Reflections follow the same moving boundary as the water itself,
        // rather than crossing its curved edge as the swell changes.
        func seamPosition(at y: CGFloat) -> CGFloat {
            let progress = min(1, max(0, (0.6 - y) / max(0.6 + depth, 0.01))) * 8
            let index = min(7, max(0, Int(progress))), fraction = progress - CGFloat(index)
            return seam[index].0 + (seam[index + 1].0 - seam[index].0) * fraction
        }
        tint(polygon([(left, 0.6)] + seam + [(left, -depth)]), shade(0.08, 0.25, 0.50, 0.94))
        tint(polygon([(right, 0.6)] + seam + [(right, -depth)]), shade(0.14, 0.52, 0.50, 0.92))
        // A band of lighter water on the far side of each, under the horizon.
        tint(polygon([(left, 0.6), (seam[0].0, 0.6), (seam[1].0, seam[1].1), (left, seam[1].1)]), shade(0.30, 0.50, 0.72, 0.30))
        tint(polygon([(right, 0.6), (seam[0].0, 0.6), (seam[1].0, seam[1].1), (right, seam[1].1)]), shade(0.46, 0.78, 0.70, 0.30))
        for index in 0..<18 {
            let across = left + (right - left) * CGFloat(Self.noise(index, 261)) + CGFloat(sin(time * 0.45 + Double(index))) * 4
            let down = -3 - CGFloat(Self.noise(index, 263)) * (depth - 9)
            let seamX = seamPosition(at: down), length = 7 + CGFloat(Self.noise(index, 265)) * 12
            guard across + length < seamX - 5 || across > seamX + 5 else { continue }
            let glint = (0.14 + 0.09 * sin(time * 0.9 + Double(index) * 1.3)) * (1 - 0.5 * night)
            tint(polygon([(across, down), (across + length * 0.5, down + 0.5), (across + length, down), (across + length * 0.5, down - 0.5)]),
                 (across < seamX ? Color(red: 0.80, green: 0.88, blue: 1.0) : Color(red: 0.84, green: 1.0, blue: 0.90)).opacity(glint))
        }
        tint(strokePath(seam, 1.1, smooth: true), Color.white.opacity(0.42 * (1 - 0.4 * night)))
        // Flecks track each side of the meeting line without crossing it.
        var flecks = Path()
        for mark in 1..<9 {
            let fraction = CGFloat(mark) / 10
            let yy = -fraction * depth
            let sx = seamPosition(at: yy)
            for side in [-1.0, 1.0] as [CGFloat] {
                let span = 2.5 + fraction * 4
                let cx = sx + side * (6 + fraction * 4)
                flecks.addPath(polygon([(cx - span, yy), (cx, yy + 0.45), (cx + span, yy), (cx, yy - 0.45)]))
            }
        }
        tint(flecks, Color.white.opacity(0.13 * (1 - 0.5 * night)))
    }

    /// Ground split by fissures, trembling. Moves.
    mutating func crackedGround(from left: CGFloat, to right: CGFloat) {
        let mid = (left + right) / 2, span = max(1, right - left)
        let count = max(3, Int(span / 58))
        var dark = Path(), lip = Path()
        func fissure(_ spots: [Spot], _ widths: [CGFloat]) {
            var near: [Spot] = [], far: [Spot] = [], edge: [Spot] = []
            for (index, spot) in spots.enumerated() {
                near.append((spot.0 - widths[index], spot.1)); far.append((spot.0 + widths[index], spot.1))
                edge.append((spot.0 + widths[index] + 0.9, spot.1))
            }
            dark.addPath(polygon(near + far.reversed()))
            lip.addPath(polygon(far + edge.reversed()))
        }
        for crack in 0..<count {
            let tremble = CGFloat(sin(time * 5.2 + Double(crack) * 1.7)) * 0.45
            var px = left + span * (CGFloat(crack) + 0.2 + 0.6 * CGFloat(Self.noise(crack, 301))) / CGFloat(count)
            var py: CGFloat = 1
            var spots: [Spot] = [(px, py)], widths: [CGFloat] = [0.3]
            for step in 1...5 {
                px += (px - mid) / span * 16 + (CGFloat(Self.noise(crack * 13 + step, 303)) - 0.5) * (9 + CGFloat(step) * 3) + tremble * CGFloat(step) * 0.4
                py -= 4 + CGFloat(step) * 1.1
                spots.append((px, py)); widths.append(0.5 + CGFloat(step) * 0.42)
                if step == 2 || step == 4 {
                    // A side crack running off.
                    let way: CGFloat = Self.noise(crack * 7 + step, 305) > 0.5 ? 1 : -1
                    let reach = 7 + CGFloat(step) * 2.5
                    fissure([(px, py), (px + way * reach * 0.55, py - 1.5 - tremble), (px + way * reach, py - 5), (px + way * reach * 1.5, py - 6)],
                            [0.3 + CGFloat(step) * 0.2, 0.5, 0.35, 0.1])
                }
            }
            fissure(spots, widths)
        }
        tint(dark, Color.black.opacity(0.66))
        detail(lip, strength: 1.2)
        // Smaller faults and chips connect the larger fractures into plates.
        var scratches = Path(), chips = Path()
        for mark in 0..<(count * 5) {
            let px = left + span * CGFloat(Self.noise(mark, 313))
            let py = -2 - CGFloat(Self.noise(mark, 315)) * 20
            let reach = 2 + CGFloat(Self.noise(mark, 317)) * 4
            scratches.addPath(strokePath([(px, py), (px + reach * 0.42, py - 1.2), (px + reach, py - 0.5)], 0.45))
            if mark % 3 == 0 {
                chips.addPath(polygon([(px - 1.3, py), (px, py + 0.8), (px + 1.6, py + 0.15), (px + 0.5, py - 0.6)]))
            }
        }
        tint(scratches, Color.black.opacity(0.22))
        tint(chips, shade(0.80, 0.70, 0.56, 0.25))
        // Slabs of the ground's crust heaved up along the horizon.
        for slab in 0...count {
            let shake = CGFloat(sin(time * 4.6 + Double(slab) * 2.1)) * 0.4
            let sx = left + span * (CGFloat(slab) + 0.15 * CGFloat(Self.noise(slab, 307))) / CGFloat(count)
            let w = 16 + CGFloat(Self.noise(slab, 309)) * 16, high = 4 + CGFloat(Self.noise(slab, 311)) * 6
            let tipped: CGFloat = slab % 2 == 0 ? 1 : -1
            shape([(sx - w / 2, 0), (sx - w / 2 + 1.5, high * (tipped > 0 ? 1 : 0.25) + shake), (sx + w / 2 - 2, high * (tipped > 0 ? 0.3 : 1) + shake), (sx + w / 2, 0)])
            if slab % 3 == 1 {
                shape([(sx + w * 0.6, 0), (sx + w * 0.66, high * 0.5 - shake), (sx + w * 0.78, 0)])
            }
        }
    }

    /// Low crops in rows, green at 0, dry stubble at 1, stirred by wind. Moves.
    mutating func greenField(from left: CGFloat, to right: CGFloat, ripeness: Double = 0, bankFade: CGFloat = 0,
                             leftFade: CGFloat = 0, perspectiveOrigin: CGFloat? = nil, stripped: Bool = false) {
        let ripe = min(1, max(0, ripeness)), mid = (left + right) / 2, span = max(1, right - left)
        let fade = min(max(0, bankFade), span * 0.4)
        let leading = min(max(0, leftFade), max(0, span - fade) * 0.4)
        func tone(_ green: (Double, Double, Double), _ dry: (Double, Double, Double), _ opacity: Double) -> Color {
            shade(green.0 + (dry.0 - green.0) * ripe, green.1 + (dry.1 - green.1) * ripe, green.2 + (dry.2 - green.2) * ripe, opacity)
        }
        func spread(_ px: CGFloat, _ y: CGFloat) -> CGFloat {
            let origin = perspectiveOrigin ?? mid
            return origin + (px - origin) * (1 - y / 80)
        }
        if stripped {
            // A damaged version of the same cultivated plot. Bare earth and
            // scattered remaining stems make it distinct from neat, harvested
            // stubble without suggesting how the damage happened.
            let inner = right - fade, innerLeft = left + leading
            tint(polygon([(innerLeft, 0.6), (inner, 0.6), (spread(inner, -42), -42), (spread(innerLeft, -42), -42)]),
                 shade(0.38, 0.31, 0.24, 0.70))
            if fade > 0 {
                for band in 0..<6 {
                    let start = inner + fade * CGFloat(band) / 6, end = inner + fade * CGFloat(band + 1) / 6
                    let alpha = 0.70 * (1 - (Double(band) + 0.5) / 6)
                    tint(polygon([(start, 0.6), (end, 0.6), (spread(end, -42), -42), (spread(start, -42), -42)]),
                         shade(0.38, 0.31, 0.24, alpha))
                }
            }
            if leading > 0 {
                for band in 0..<6 {
                    let start = left + leading * CGFloat(band) / 6, end = left + leading * CGFloat(band + 1) / 6
                    let alpha = 0.70 * ((Double(band) + 0.5) / 6)
                    tint(polygon([(start, 0.6), (end, 0.6), (spread(end, -42), -42), (spread(start, -42), -42)]),
                         shade(0.38, 0.31, 0.24, alpha))
                }
            }
            var ruts = Path(), remnants = Path(), stones = Path()
            for mark in 0..<36 {
                let y = -CGFloat(Self.noise(mark, 411)) * 35
                let rawX = left + span * CGFloat(Self.noise(mark, 413))
                if fade > 0 && rawX > inner && CGFloat(Self.noise(mark, 415)) > max(0, (right - rawX) / fade) { continue }
                if leading > 0 && rawX < innerLeft && CGFloat(Self.noise(mark, 423)) > max(0, (rawX - left) / leading) { continue }
                let px = spread(rawX, y), perspective = 1 - y / 80
                let shift = CGFloat(sin(time * 0.7 + Double(mark))) * 0.25 * perspective
                let h = (1.2 + CGFloat(Self.noise(mark, 417)) * 2.2) * perspective
                remnants.addPath(strokePath([(px, y), (px + shift, y + h)], 0.45 * perspective))
                if mark.isMultiple(of: 3) {
                    let reach = (1.5 + CGFloat(Self.noise(mark, 419)) * 3) * perspective
                    ruts.addPath(strokePath([(px - reach, y - 1), (px, y - 0.6), (px + reach, y - 1.1)],
                                            0.28 * perspective, smooth: true))
                }
                if mark.isMultiple(of: 4) { stones.addPath(discPath(px + 1.5 * perspective, y - 0.5, 0.45 * perspective)) }
            }
            tint(ruts, Color.black.opacity(0.21))
            tint(remnants, shade(0.65, 0.58, 0.42, 0.78))
            tint(stones, shade(0.67, 0.60, 0.49, 0.30))
            return
        }
        if fade == 0 && leading == 0 {
            tint(polygon([(left, 0.6), (right, 0.6), (spread(right, -42), -42), (spread(left, -42), -42)]),
                 tone((0.18, 0.40, 0.19), (0.60, 0.50, 0.29), 0.66))
        } else {
            // A cultivated plot meets the natural bank gradually, rather than
            // ending at a hard rectangular edge. The bands share the same
            // perspective as the field and retain the existing daylight tint.
            let inner = right - fade, innerLeft = left + leading
            tint(polygon([(innerLeft, 0.6), (inner, 0.6), (spread(inner, -42), -42), (spread(innerLeft, -42), -42)]),
                 tone((0.18, 0.40, 0.19), (0.60, 0.50, 0.29), 0.66))
            if fade > 0 {
                for band in 0..<6 {
                    let start = inner + fade * CGFloat(band) / 6
                    let end = inner + fade * CGFloat(band + 1) / 6
                    let opacity = 0.66 * (1 - (Double(band) + 0.5) / 6)
                    tint(polygon([(start, 0.6), (end, 0.6), (spread(end, -42), -42), (spread(start, -42), -42)]),
                         tone((0.18, 0.40, 0.19), (0.60, 0.50, 0.29), opacity))
                }
            }
            if leading > 0 {
                for band in 0..<6 {
                    let start = left + leading * CGFloat(band) / 6
                    let end = left + leading * CGFloat(band + 1) / 6
                    let opacity = 0.66 * ((Double(band) + 0.5) / 6)
                    tint(polygon([(start, 0.6), (end, 0.6), (spread(end, -42), -42), (spread(start, -42), -42)]),
                         tone((0.18, 0.40, 0.19), (0.60, 0.50, 0.29), opacity))
                }
            }
        }
        // Furrows running to the horizon.
        var furrows = Path()
        let rows = max(4, Int(span / 13))
        for row in 0...rows {
            let fx = left + span * CGFloat(row) / CGFloat(rows), near = spread(fx, -42)
            furrows.addPath(polygon([(fx - 0.2, 0.4), (fx + 0.2, 0.4), (near + 1.1, -42), (near - 1.1, -42)]))
        }
        tint(furrows, Color.black.opacity(0.16))
        // Fine transverse beds make the converging furrows read as a worked
        // field, especially in the larger scene, without obscuring the crop.
        var beds = Path()
        for row in 1...7 {
            let y = -CGFloat(row) * 5.5
            let thickness = 0.18 + CGFloat(row) * 0.06
            beds.addPath(polygon([(spread(left, y), y), (spread(right, y), y),
                                  (spread(right, y - thickness), y - thickness), (spread(left, y - thickness), y - thickness)]))
        }
        tint(beds, tone((0.58, 0.65, 0.37), (0.92, 0.78, 0.54), 0.16))
        // The wind passing over it in lighter bands.
        for band in 0..<4 {
            let run = (Self.noise(band, 321) + time * 0.045).truncatingRemainder(dividingBy: 1)
            let y = -7 - CGFloat(band) * 8, wide = 44 + CGFloat(band) * 16
            let cx = spread(left, y) + (spread(right, y) - spread(left, y)) * CGFloat(run)
            tint(polygon([(cx - wide / 2, y), (cx, y + 1.3 + CGFloat(band) * 0.4), (cx + wide / 2, y), (cx, y - 1.3 - CGFloat(band) * 0.4)]),
                 Color.white.opacity(0.09 * sin(run * Double.pi) * (1 - 0.5 * night)))
        }
        // The crop itself: a far row against the sky and two nearer ones.
        let lines: [(CGFloat, CGFloat, CGFloat)] = [(0, 3.4, 1.0), (-11, 6.0, 1.45), (-25, 9.5, 2.0)]
        for (index, row) in lines.enumerated() {
            var blades = Path()
            let from = spread(left, row.0), to = spread(right, row.0)
            var px = from + CGFloat(Self.noise(index, 323)) * row.1, blade = 0
            while px < to {
                let chance = CGFloat(Self.noise(blade + index * 500, 325))
                let h = (4.6 + 3.2 * chance) * row.2 * CGFloat(1 - 0.5 * ripe)
                let bend = CGFloat(sin(time * 1.3 - Double(px) * 0.07 + Double(index))) * CGFloat(1.7 - 1.2 * ripe) * row.2
                let half = 0.55 * row.2
                // Thin out the crop at the riverbank; the same deterministic
                // positions and wind motion are retained for normal fields.
                let nearBank = fade > 0 ? max(0, min(1, (to - px) / (fade * (1 - row.0 / 80)))) : 1
                let nearLeft = leading > 0 ? max(0, min(1, (px - from) / (leading * (1 - row.0 / 80)))) : 1
                if chance > min(nearBank, nearLeft) { px += row.1 * (0.8 + 0.4 * chance); blade += 1; continue }
                if ripe > 0.6 {
                    // Stubble: short, stiff, cut square.
                    blades.addPath(polygon([(px - half * 0.7, row.0), (px + half * 0.7, row.0), (px + half * 0.6 + bend * 0.3, row.0 + h), (px - half * 0.6 + bend * 0.3, row.0 + h)]))
                } else {
                    blades.addPath(polygon([(px - half, row.0), (px + half, row.0), (px + bend, row.0 + h)]))
                    blades.addPath(polygon([(px - half, row.0), (px + half * 0.4, row.0), (px - 1.8 * row.2 + bend * 0.7, row.0 + h * 0.62)]))
                    blades.addPath(polygon([(px - half * 0.4, row.0), (px + half, row.0), (px + 1.9 * row.2 + bend * 0.8, row.0 + h * 0.70)]))
                }
                px += row.1 * (0.8 + 0.4 * chance); blade += 1
            }
            tint(blades, tone((0.25 + 0.05 * Double(index), 0.52 + 0.04 * Double(index), 0.24), (0.80, 0.68, 0.40), 0.96))
        }
    }

    // MARK: What grows

    /// Small blossom low on the ground, nodding. Moves.
    mutating func flowers(from left: CGFloat, to right: CGFloat) {
        var stems = Path(), leaves = Path(), hearts = Path(), grass = Path(), highlights = Path()
        var petals = [Path(), Path(), Path(), Path()]
        var px = left + 3, index = 0
        while px < right - 2 {
            let h = 5 + CGFloat(Self.noise(index, 331)) * 7
            let nod = CGFloat(sin(time * 1.1 + Double(index) * 0.9)) * (0.5 + h * 0.10)
            let head: Spot = (px + nod, h)
            stems.addPath(strokePath([(px, 0), (px + nod * 0.25, h * 0.55), head], 0.7, smooth: true))
            let side: CGFloat = index % 2 == 0 ? 1 : -1
            leaves.addPath(polygon([(px, h * 0.18), (px + side * 2.0, h * 0.50), (px + side * 3.6 + nod * 0.3, h * 0.56), (px + side * 1.8, h * 0.30)]))
            let kind = Int(Self.noise(index, 337) * 4) % 4, r = 1.5 + CGFloat(Self.noise(index, 335)) * 0.8
            for petal in 0..<5 {
                let angle = Double(petal) * 2 * Double.pi / 5 + Double.pi / 2 + Double(nod) * 0.1
                let cx = head.0 + CGFloat(cos(angle)) * r * 0.78, cy = head.1 + CGFloat(sin(angle)) * r * 0.78
                petals[kind].addEllipse(in: CGRect(x: point(cx, cy).x - r * 0.62, y: point(cx, cy).y - r * 0.62, width: r * 1.24, height: r * 1.24))
            }
            hearts.addPath(discPath(head.0, head.1, r * 0.42))
            highlights.addPath(discPath(head.0 - r * 0.18, head.1 + r * 0.18, r * 0.16))
            // Grass between the flowers.
            let gx = px + 2.6, lean = CGFloat(sin(time * 1.2 + Double(index) * 0.5)) * 0.8
            grass.addPath(polygon([(gx - 0.5, 0), (gx + 0.5, 0), (gx + lean - 1.2, 3.4 + CGFloat(Self.noise(index, 341)) * 2)]))
            grass.addPath(polygon([(gx, 0), (gx + 0.9, 0), (gx + lean + 1.6, 2.6 + CGFloat(Self.noise(index, 343)) * 2)]))
            px += 5 + CGFloat(Self.noise(index, 339)) * 6; index += 1
        }
        add(grass)
        if quranScene { tint(grass, shade(0.28, 0.45, 0.24, 0.90)) }
        tint(stems, shade(0.28, 0.48, 0.27))
        tint(leaves, shade(0.30, 0.52, 0.28))
        let colours: [(Double, Double, Double)] = [(0.97, 0.95, 0.90), (0.93, 0.56, 0.64), (0.97, 0.80, 0.36), (0.68, 0.58, 0.88)]
        for (kind, colour) in colours.enumerated() { tint(petals[kind], shade(colour)) }
        tint(hearts, shade(0.96, 0.72, 0.26))
        // Catch a little light on each flower's centre as it nods.
        tint(highlights, Color.white.opacity(0.18 * (1 - night * 0.45)))
    }

    /// An olive tree: twisted trunk, silver-green crown. Moves.
    mutating func olive(_ x: CGFloat, _ h: CGFloat) {
        let sway = CGFloat(sin(time * 0.6 + Double(x) * 0.17)) * h * 0.014
        let seed = Int(x.rounded())
        // The trunk: thick and gnarled, twisting as it climbs, parting in two limbs.
        curve { path, at in
            path.move(to: at(x - h * 0.15, 0))
            path.addQuadCurve(to: at(x - h * 0.055, h * 0.19), control: at(x - h * 0.05, h * 0.03))
            path.addQuadCurve(to: at(x - h * 0.10, h * 0.40), control: at(x - h * 0.13, h * 0.30))
            path.addQuadCurve(to: at(x - h * 0.27, h * 0.63), control: at(x - h * 0.13, h * 0.53))
            path.addLine(to: at(x - h * 0.21, h * 0.66))
            path.addQuadCurve(to: at(x - h * 0.02, h * 0.45), control: at(x - h * 0.06, h * 0.57))
            path.addQuadCurve(to: at(x + h * 0.17, h * 0.68), control: at(x + h * 0.04, h * 0.59))
            path.addLine(to: at(x + h * 0.23, h * 0.64))
            path.addQuadCurve(to: at(x + h * 0.075, h * 0.30), control: at(x + h * 0.15, h * 0.48))
            path.addQuadCurve(to: at(x + h * 0.06, h * 0.14), control: at(x + h * 0.02, h * 0.22))
            path.addQuadCurve(to: at(x + h * 0.17, 0), control: at(x + h * 0.07, h * 0.03))
            path.closeSubpath()
        }
        // The grain of the old wood, and a hollow in it.
        detail(strokePath([(x - h * 0.06, h * 0.04), (x - h * 0.01, h * 0.20), (x - h * 0.055, h * 0.36), (x - h * 0.02, h * 0.44)], max(0.6, h * 0.014), smooth: true), strength: 0.42)
        tint(Path(ellipseIn: CGRect(x: point(x + h * 0.01, 0).x - h * 0.022, y: point(0, h * 0.25).y - h * 0.04, width: h * 0.044, height: h * 0.08)),
             Color.black.opacity(0.30))
        // The crown: wide, broken into clumps, lighter where the leaves turn their silver side.
        let clumps: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [(-0.27, 0.74, 0.30, 0.20), (0.24, 0.76, 0.30, 0.19), (-0.02, 0.86, 0.32, 0.16), (0.03, 0.68, 0.22, 0.12)]
        var canopy = Path()
        for (index, clump) in clumps.enumerated() {
            let crown = crownPath(x + clump.0 * h + sway * (1 + CGFloat(index) * 0.3), clump.1 * h, clump.2 * h, clump.3 * h, lobes: 7, depth: 0.20, seed: seed + index, flat: 0.25)
            add(crown)
            if quranScene { canopy.addPath(crown) }
        }
        if quranScene { tint(canopy, shade(0.30, 0.40, 0.27, 0.92)) }
        for (index, clump) in clumps.prefix(3).enumerated() {
            tint(crownPath(x + (clump.0 - 0.05) * h + sway * (1.4 + CGFloat(index) * 0.3), (clump.1 + 0.035) * h, clump.2 * h * 0.62, clump.3 * h * 0.56,
                           lobes: 6, depth: 0.24, seed: seed + index + 40, flat: 0.3), shade(0.56, 0.66, 0.56, 0.36))
        }
        var leaves = Path()
        for leaf in 0..<12 {
            let lx = x + (CGFloat(Self.noise(seed + leaf, 345)) - 0.5) * h * 0.76 + sway * 1.8
            let ly = h * (0.72 + 0.16 * CGFloat(Self.noise(seed + leaf, 347)))
            let slant: CGFloat = leaf % 2 == 0 ? 1 : -1
            leaves.addPath(polygon([(lx, ly), (lx + h * 0.022 * slant, ly + h * 0.03), (lx + h * 0.05 * slant, ly + h * 0.034), (lx + h * 0.026 * slant, ly + h * 0.006)]))
        }
        tint(leaves, shade(0.74, 0.80, 0.72, 0.5))
        var bark = Path(), olives = Path()
        for groove in 0..<4 {
            let offset = (CGFloat(groove) - 1.5) * h * 0.035
            bark.addPath(strokePath([(x + offset, h * 0.05), (x + offset * 0.7, h * 0.19),
                                     (x + offset - h * 0.025, h * 0.31), (x + offset * 0.4, h * 0.40)],
                                    max(0.45, h * 0.007), smooth: true))
        }
        for fruit in 0..<9 {
            let fx = x + (CGFloat(Self.noise(seed + fruit, 349)) - 0.5) * h * 0.65 + sway * 1.5
            let fy = h * (0.64 + 0.18 * CGFloat(Self.noise(seed + fruit, 351)))
            olives.addPath(discPath(fx, fy, max(0.4, h * 0.012)))
        }
        tint(bark, shade(0.83, 0.75, 0.61, 0.32))
        tint(olives, shade(0.28, 0.33, 0.22, 0.65))
    }

    /// A fig tree: low, wide, broad-leaved. Moves.
    mutating func fig(_ x: CGFloat, _ h: CGFloat) {
        let sway = CGFloat(sin(time * 0.55 + Double(x) * 0.21)) * h * 0.016
        let seed = Int(x.rounded()) + 11
        // A short smooth trunk forking low into three spreading limbs.
        add(trunkPath(x, to: (x, h * 0.34), width: h * 0.11, taper: 0.8, flare: 0.5))
        line([(x - h * 0.01, h * 0.26), (x - h * 0.24, h * 0.44), (x - h * 0.44, h * 0.50)], h * 0.05, smooth: true)
        line([(x + h * 0.01, h * 0.26), (x + h * 0.26, h * 0.42), (x + h * 0.48, h * 0.52)], h * 0.05, smooth: true)
        line([(x, h * 0.30), (x + h * 0.03, h * 0.50), (x - h * 0.04, h * 0.66)], h * 0.045, smooth: true)
        // The crown: broad and domed, its edge cut by big leaves.
        let clumps: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [(-0.42, 0.60, 0.34, 0.21), (0.44, 0.61, 0.34, 0.21), (-0.12, 0.76, 0.36, 0.22), (0.18, 0.78, 0.34, 0.20), (0.0, 0.58, 0.30, 0.14)]
        var canopy = Path()
        for (index, clump) in clumps.enumerated() {
            let crown = crownPath(x + clump.0 * h + sway * (0.8 + CGFloat(index) * 0.25), clump.1 * h, clump.2 * h, clump.3 * h, lobes: 5, depth: 0.30, seed: seed + index, flat: 0.3)
            add(crown)
            if quranScene { canopy.addPath(crown) }
        }
        if quranScene { tint(canopy, shade(0.24, 0.40, 0.21, 0.94)) }
        for (index, clump) in clumps.prefix(4).enumerated() {
            tint(crownPath(x + (clump.0 - 0.05) * h + sway * (1.2 + CGFloat(index) * 0.25), (clump.1 + 0.04) * h, clump.2 * h * 0.60, clump.3 * h * 0.56,
                           lobes: 5, depth: 0.28, seed: seed + index + 60, flat: 0.3), shade(0.30, 0.50, 0.26, 0.40))
        }
        // The fruit, dark among the leaves.
        var figs = Path()
        for spot in [(-0.34, 0.44), (0.10, 0.46), (0.40, 0.44), (-0.08, 0.52)] as [Spot] {
            let fx = x + spot.0 * h + sway * 0.8, fy = spot.1 * h, r = max(0.9, h * 0.028)
            figs.addPath(smoothPath([(fx, fy + r * 1.5), (fx + r, fy), (fx + r * 0.7, fy - r), (fx - r * 0.7, fy - r), (fx - r, fy)]))
        }
        tint(figs, shade(0.46, 0.26, 0.42))
        // Light catches individual leaf lobes above the dense crown.
        var leaves = Path(), fruitLight = Path()
        for leaf in 0..<12 {
            let lx = x + (CGFloat(Self.noise(seed + leaf, 367)) - 0.5) * h * 0.8 + sway * 1.4
            let ly = h * (0.62 + 0.18 * CGFloat(Self.noise(seed + leaf, 369)))
            let r = max(0.8, h * 0.028)
            leaves.addPath(polygon([(lx, ly - r), (lx - r, ly), (lx - r * 0.7, ly + r),
                                    (lx, ly + r * 0.45), (lx + r * 0.7, ly + r), (lx + r, ly)]))
            if leaf % 3 == 0 { fruitLight.addPath(discPath(lx, ly - r * 2.4, max(0.35, h * 0.009))) }
        }
        tint(leaves, shade(0.53, 0.67, 0.38, 0.42))
        tint(fruitLight, shade(0.78, 0.50, 0.62, 0.48))
    }

    /// Vines on a trellis with hanging clusters. Moves.
    mutating func vines(_ x: CGFloat, bays: Int = 4) {
        let count = max(1, bays), bay: CGFloat = 22, top: CGFloat = 27, w = CGFloat(count) * bay, left = x - w / 2
        // The trellis: posts, a rail, and slats laid across it.
        for post in 0...count {
            let px = left + CGFloat(post) * bay
            shape([(px - 1.2, 0), (px + 1.2, 0), (px + 0.8, top), (px - 0.8, top)])
            if post < count { line([(px + 0.6, top - 6), (px + 5.5, top)], 0.9) }
            if post > 0 { line([(px - 0.6, top - 6), (px - 5.5, top)], 0.9) }
        }
        block(x, w + 9, 1.5, from: top)
        var slats = Path()
        for slat in stride(from: left - 2, through: left + w + 2, by: 5.5) { slats.addPath(blockPath(slat, 1.1, 1.5, from: top + 1.5)) }
        add(slats)
        // The vine's old stem winding up a post and along the rail.
        line([(left + 2.5, 0), (left - 1, top * 0.22), (left + 2.2, top * 0.45), (left - 0.8, top * 0.70), (left + 2, top + 1.5)], 1.5, smooth: true)
        line([(left + w - 2.5, 0), (left + w + 1, top * 0.3), (left + w - 2, top * 0.6), (left + w + 0.5, top + 1.5)], 1.3, smooth: true)
        // Leaves heaped along the top and spilling under the rail.
        var foliage = Path(), sunlit = Path(), grapes = Path(), bloom = Path(), stalks = Path()
        for clump in 0..<(count * 2 + 1) {
            let sway = CGFloat(sin(time * 0.8 + Double(clump) * 1.1)) * 0.7
            let cx = left + w * CGFloat(clump) / CGFloat(count * 2) + sway
            let big = 7.5 + CGFloat(Self.noise(clump, 371)) * 3
            foliage.addPath(crownPath(cx, top + 4.2 + CGFloat(Self.noise(clump, 373)) * 1.8, big, 4.6, lobes: 6, depth: 0.26, seed: clump + 5, flat: 0.4))
            sunlit.addPath(crownPath(cx - 1.4, top + 5.4, big * 0.56, 2.3, lobes: 5, depth: 0.28, seed: clump + 80, flat: 0.3))
            if clump % 2 == 1 {
                foliage.addPath(crownPath(cx + 3 - sway * 0.5, top - 2.2, 4.4, 2.8, lobes: 5, depth: 0.3, seed: clump + 30))
            }
        }
        add(foliage)
        if quranScene { tint(foliage, shade(0.27, 0.43, 0.22, 0.94)) }
        tint(sunlit, shade(0.34, 0.54, 0.28, 0.44))
        // The clusters, each swinging on its stalk.
        for cluster in 0..<(count * 2) {
            let hangs = left + (CGFloat(cluster) + 0.5) * bay / 2 + (CGFloat(Self.noise(cluster, 375)) - 0.5) * 4
            let drop = 3.5 + CGFloat(Self.noise(cluster, 377)) * 3.5
            let swing = sin(time * 0.9 + Double(cluster) * 1.7) * 0.10
            func hung(_ dx: CGFloat, _ dy: CGFloat) -> Spot { turn((hangs + dx, top - dy), about: (hangs, top), by: swing) }
            stalks.addPath(strokePath([(hangs, top), hung(0, drop)], 0.6))
            let size: CGFloat = 1.25
            for (row, berries) in [3, 3, 2, 1].enumerated() {
                for berry in 0..<berries {
                    let spot = hung((CGFloat(berry) - CGFloat(berries - 1) / 2) * size * 1.7, drop + size * 0.8 + CGFloat(row) * size * 1.55)
                    grapes.addPath(discPath(spot.0, spot.1, size))
                    if (row + berry) % 2 == 0 { bloom.addPath(discPath(spot.0 - 0.35, spot.1 + 0.35, size * 0.42)) }
                }
            }
        }
        add(stalks)
        tint(grapes, shade(0.42, 0.24, 0.50))
        tint(bloom, shade(0.72, 0.56, 0.80, 0.75))
        var grain = Path(), tendrils = Path()
        for post in 0...count {
            let px = left + CGFloat(post) * bay
            grain.addPath(strokePath([(px - 0.35, 2), (px + 0.15, top * 0.4), (px - 0.15, top - 2)], 0.35, smooth: true))
            if post < count {
                let tx = px + bay * 0.55
                tendrils.addPath(strokePath([(tx, top + 1), (tx + 1.2, top - 2), (tx + 2.1, top - 1.5), (tx + 1.6, top - 0.5)], 0.45, smooth: true))
            }
        }
        tint(grain, shade(0.78, 0.65, 0.45, 0.34))
        tint(tendrils, shade(0.48, 0.62, 0.32, 0.55))
    }

    /// A leafless tree, branches only.
    mutating func bareTree(_ x: CGFloat, _ h: CGFloat) {
        let seed = Int(x.rounded()) * 7 + Int(h.rounded())
        let lean = (CGFloat(Self.noise(seed, 351)) - 0.5) * h * 0.12
        let fork: Spot = (x + lean, h * 0.40)
        add(trunkPath(x, to: fork, width: h * 0.07 + 1, taper: 0.62, flare: 0.55))
        // Roots showing at the foot, and the stub of a dead limb.
        line([(x - h * 0.03, 1), (x - h * 0.10, 0.3)], max(0.8, h * 0.02))
        line([(x + h * 0.03, 1), (x + h * 0.11, 0.3)], max(0.8, h * 0.02))
        line([(x + lean * 0.5, h * 0.22), (x + lean * 0.5 + h * 0.07, h * 0.29), (x + lean * 0.5 + h * 0.09, h * 0.27)], max(0.7, h * 0.016))
        // Each limb forks, and forks again, thinner each time.
        var limbs: [[[Spot]]] = [[], [], [], []]
        func grow(_ from: Spot, _ angle: Double, _ length: CGFloat, _ depth: Int, _ id: Int) {
            guard depth < 4 else { return }
            let kink = (Self.noise(id, 353) - 0.5) * 0.5
            let mid: Spot = (from.0 + CGFloat(cos(angle + kink)) * length * 0.5, from.1 + CGFloat(sin(angle + kink)) * length * 0.5)
            let end: Spot = (from.0 + CGFloat(cos(angle)) * length, from.1 + CGFloat(sin(angle)) * length)
            limbs[depth].append([from, mid, end])
            let wide = 0.34 + Self.noise(id, 355) * 0.34, narrow = 0.26 + Self.noise(id, 357) * 0.36
            grow(end, angle + wide, length * CGFloat(0.62 + 0.14 * Self.noise(id, 359)), depth + 1, id * 2 + 1)
            grow(end, angle - narrow, length * CGFloat(0.60 + 0.16 * Self.noise(id, 361)), depth + 1, id * 2 + 2)
            if depth > 0, Self.noise(id, 363) > 0.45 {
                let way: Double = Self.noise(id, 365) > 0.5 ? 1 : -1
                grow(mid, angle + way * 0.8, length * 0.42, max(depth + 1, 2), id * 2 + 77)
            }
        }
        let up = Double.pi / 2 - Double(lean / h) * 1.2
        grow(fork, up + 0.62, h * 0.25, 0, seed + 1)
        grow(fork, up - 0.05, h * 0.27, 0, seed + 2)
        grow(fork, up - 0.66, h * 0.24, 0, seed + 3)
        let weights: [CGFloat] = [h * 0.034 + 0.5, h * 0.021 + 0.4, h * 0.012 + 0.35, max(0.5, h * 0.008)]
        for depth in 0..<4 {
            var all = Path()
            for limb in limbs[depth] { all.addPath(strokePath(limb, weights[depth], smooth: true)) }
            add(all)
        }
        var bark = Path()
        for groove in 0..<4 {
            let offset = (CGFloat(groove) - 1.5) * h * 0.018
            bark.addPath(strokePath([(x + offset, h * 0.03), (x + offset + lean * 0.3, h * 0.18),
                                     (x + offset + lean * 0.6, h * 0.31)], max(0.35, h * 0.006), smooth: true))
        }
        tint(bark, shade(0.76, 0.68, 0.57, 0.28))
    }

    /// Palm trunks torn up and lying hollow, fronds blowing. Moves.
    mutating func fallenPalms(_ x: CGFloat, count: Int = 3) {
        let total = max(1, count)
        for index in 0..<total {
            let bx = x + (CGFloat(index) - CGFloat(total - 1) / 2) * 66
            switch index % 3 {
            case 0:
                // Flat on the ground, its crown thrown forward.
                fallenPalm(root: (bx - 29, 8.4), way: 1, length: 52, slope: -0.07, snapped: false, id: index)
            case 1:
                // Fallen across the stump of another, its crown still off the ground.
                palmStump(bx + 9, 14.4)
                fallenPalm(root: (bx - 22, 8.2), way: 1, length: 52, slope: 0.30, snapped: false, id: index)
            default:
                // Snapped in two: the stump standing, the rest lying hollow.
                palmStump(bx - 23, 12)
                fallenPalm(root: (bx + 25, 8.2), way: -1, length: 38, slope: -0.06, snapped: true, id: index)
            }
        }
    }

    /// What is left standing of a broken palm.
    mutating func palmStump(_ x: CGFloat, _ h: CGFloat) {
        let stump: [Spot] = [(x - 4.4, 0), (x + 4.4, 0), (x + 3.4, h - 2), (x + 1.6, h - 4.4), (x + 0.4, h), (x - 1.4, h - 3.6), (x - 3.4, h - 1)]
        shape(stump)
        tint(polygon(stump), shade(0.56, 0.45, 0.31, 0.60))
        var rings = Path()
        for level in stride(from: CGFloat(2.6), to: h - 4, by: 3.2) { rings.addPath(blockPath(x, 6.6, 0.6, from: level)) }
        tint(rings, Color.black.opacity(0.26))
        tint(polygon([(x - 4.2, 0.6), (x - 3.3, 0.6), (x - 2.9, h - 1.6), (x - 3.5, h - 1.4)]), shade(0.96, 0.86, 0.66, 0.50))
        var fibres = Path()
        for fibre in 0..<5 {
            let dx = CGFloat(fibre - 2) * 1.2
            fibres.addPath(strokePath([(x + dx, h - 4.1), (x + dx * 0.8, h - 2.4),
                                       (x + dx * 0.65 + 0.3, h - 0.8)], 0.45))
        }
        tint(fibres, shade(0.91, 0.75, 0.53, 0.55))
    }

    /// One uprooted palm: its root plate at `root`, its trunk running `length`
    /// to the left or right (`way`) and rising by `slope`.
    mutating func fallenPalm(root: Spot, way: CGFloat, length: CGFloat, slope: Double, snapped: Bool, id: Int) {
        let ux = way * CGFloat(cos(slope)), uy = CGFloat(sin(slope)), nx = -way * CGFloat(sin(slope)), ny = CGFloat(cos(slope))
        func along(_ a: CGFloat, _ b: CGFloat) -> Spot { (root.0 + ux * a + nx * b, root.1 + uy * a + ny * b) }
        let thick: CGFloat = 4.3, thin: CGFloat = 3.3
        func girth(_ a: CGFloat) -> CGFloat { thick + (thin - thick) * a / length }
        // The trunk: stout, its bark paler than the ground it lies on, light along its upper side.
        let trunk = [along(0, -thick), along(length, -thin), along(length, thin), along(0, thick)]
        shape(trunk)
        tint(polygon(trunk), shade(0.56, 0.45, 0.31, 0.62))
        tint(polygon([along(1, thick - 1.3), along(length, thin - 1.1), along(length, thin), along(1, thick)]), shade(0.98, 0.88, 0.66, 0.50))
        tint(polygon([along(1, -thick), along(length, -thin), along(length, -thin + 1.3), along(1, -thick + 1.5)]), Color.black.opacity(0.22))
        var rings = Path()
        for ring in stride(from: CGFloat(8), to: length - 3, by: 5.5) {
            let g = girth(ring)
            rings.addPath(polygon([along(ring, -g), along(ring + 0.9, -g), along(ring + 2.2, g), along(ring + 1.3, g)]))
        }
        tint(rings, Color.black.opacity(0.28))
        var bark = Path()
        for fibre in 0..<4 {
            let across = -thick * 0.65 + CGFloat(fibre) * thick * 0.4
            bark.addPath(strokePath([along(3, across), along(length * 0.40, across * 0.95 + 0.4),
                                     along(length * 0.75, across * 0.85 - 0.3), along(length - 3, across * 0.75)], 0.45, smooth: true))
        }
        tint(bark, shade(0.91, 0.78, 0.58, 0.26))
        // The plate of roots and earth that came up with it.
        let plate = crownPath(root.0 - ux * 1.5, root.1 + 0.4, 6.6, 8.2, lobes: 6, depth: 0.26, seed: id + 3)
        add(plate)
        tint(plate, shade(0.42, 0.33, 0.24, 0.55))
        var roots = Path()
        for stub in 0..<6 {
            let angle = Double.pi / 2 + Double(way) * (0.35 + Double(stub) * 0.46), far = 10.5 + CGFloat(Self.noise(id * 9 + stub, 383)) * 4.5
            let tip: Spot = (root.0 + CGFloat(cos(angle)) * far, max(0.3, root.1 + 0.4 + CGFloat(sin(angle)) * far))
            roots.addPath(strokePath([(root.0, root.1 + 0.4), ((root.0 + tip.0) / 2 - way * 1.4, (root.1 + tip.1) / 2 + 1.2), tip], 1.0, smooth: true))
        }
        add(roots)
        // A hollow under it where it lies clear of the ground.
        if abs(slope) < 0.12 {
            tint(polygon([along(6, -thick), along(length - 2, -thin), (along(length - 2, -thin).0, 0.3), (along(6, -thick).0, 0.3)]), Color.black.opacity(0.16))
        }
        if snapped {
            // Broken off short, and hollow at the break.
            let mouth = along(length, 0)
            let splinters = [along(length - 1, -thin), along(length + 3.2, -thin * 0.5), along(length + 1.0, 0.3), along(length + 4.2, thin * 0.9), along(length - 1, thin)]
            shape(splinters)
            tint(polygon(splinters), shade(0.56, 0.45, 0.31, 0.62))
            let hollow = Path(ellipseIn: CGRect(x: point(mouth.0, mouth.1).x - 2.0, y: point(mouth.0, mouth.1).y - thin * 0.74, width: 4, height: thin * 1.48))
            tint(hollow, Color.black.opacity(0.72))
            tint(hollow.strokedPath(StrokeStyle(lineWidth: 0.7)), shade(0.98, 0.88, 0.66, 0.70))
        } else {
            // The crown: fronds splayed where it struck, the upper ones lifting in the wind.
            let crown = along(length, 0)
            var fronds = Path()
            let fan: [(Double, CGFloat)] = [(-1.25, 14), (-0.60, 18), (-0.10, 22), (0.40, 23), (0.85, 22), (1.30, 19), (1.80, 15)]
            for (frond, spread) in fan.enumerated() {
                let gust = CGFloat(sin(time * 1.4 + Double(frond) * 0.9 + Double(id) * 2)) * (0.5 + CGFloat(frond) * 0.3)
                let dx = ux * CGFloat(cos(spread.0)) + nx * CGFloat(sin(spread.0)), dy = uy * CGFloat(cos(spread.0)) + ny * CGFloat(sin(spread.0))
                let tip: Spot = (crown.0 + dx * spread.1 + gust * 0.6, max(0.8, crown.1 + dy * spread.1 - spread.1 * 0.16 + gust))
                fronds.addPath(frondPath(from: crown, to: tip, arch: 3.8 + gust * 0.4, leaf: 3.4))
            }
            add(fronds)
            tint(fronds, shade(0.52, 0.50, 0.28, 0.36))
            disc(crown.0, crown.1, 3.8)
            tint(discPath(crown.0, crown.1, 3.8), shade(0.56, 0.45, 0.31, 0.62))
        }
    }

    /// One great spreading tree, firmly rooted, leaves stirring. Moves.
    mutating func greatTree(_ x: CGFloat, _ h: CGFloat) {
        let seed = Int(x.rounded()) + 23
        let stir = CGFloat(sin(time * 0.5 + Double(x) * 0.1)) * h * 0.008
        // Roots gripping the ground on both sides.
        for (reach, lift) in [(-0.30, 0.05), (-0.19, 0.08), (0.21, 0.08), (0.33, 0.05)] as [(CGFloat, CGFloat)] {
            curve { path, at in
                path.move(to: at(x + reach * h, 0))
                path.addQuadCurve(to: at(x + reach * h * 0.12, h * (lift + 0.08)), control: at(x + reach * h * 0.5, h * lift))
                path.addLine(to: at(x + reach * h * 0.04, h * 0.02))
                path.addLine(to: at(x + reach * h * 0.7, 0))
                path.closeSubpath()
            }
        }
        // A massive trunk, and the limbs it divides into.
        add(trunkPath(x, to: (x + h * 0.01, h * 0.40), width: h * 0.15, taper: 0.74, flare: 0.5))
        let limbs: [([Spot], CGFloat)] = [
            ([(x - h * 0.03, h * 0.34), (x - h * 0.22, h * 0.50), (x - h * 0.46, h * 0.58)], 0.060),
            ([(x + h * 0.03, h * 0.34), (x + h * 0.24, h * 0.48), (x + h * 0.50, h * 0.60)], 0.060),
            ([(x - h * 0.01, h * 0.38), (x - h * 0.10, h * 0.58), (x - h * 0.20, h * 0.76)], 0.050),
            ([(x + h * 0.02, h * 0.38), (x + h * 0.08, h * 0.60), (x + h * 0.18, h * 0.80)], 0.050),
            ([(x - h * 0.30, h * 0.52), (x - h * 0.44, h * 0.48), (x - h * 0.60, h * 0.50)], 0.030),
            ([(x + h * 0.32, h * 0.52), (x + h * 0.48, h * 0.50), (x + h * 0.62, h * 0.52)], 0.030)
        ]
        for limb in limbs { line(limb.0, h * limb.1, smooth: true) }
        // The crown in layers, with sky between its lower boughs.
        let clumps: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
            (-0.50, 0.62, 0.24, 0.13), (0.52, 0.64, 0.25, 0.13), (-0.30, 0.76, 0.28, 0.15), (0.30, 0.78, 0.28, 0.15),
            (0.0, 0.88, 0.32, 0.14), (-0.02, 0.70, 0.20, 0.10), (-0.62, 0.50, 0.12, 0.06), (0.66, 0.52, 0.12, 0.06)
        ]
        var canopy = Path()
        for (index, clump) in clumps.enumerated() {
            let crown = crownPath(x + clump.0 * h + stir * (1 + CGFloat(index % 4) * 0.5), clump.1 * h, clump.2 * h, clump.3 * h, lobes: 8, depth: 0.17, seed: seed + index, flat: 0.35)
            add(crown)
            if quranScene { canopy.addPath(crown) }
        }
        if quranScene { tint(canopy, shade(0.23, 0.37, 0.22, 0.94)) }
        for (index, clump) in clumps.prefix(5).enumerated() {
            tint(crownPath(x + (clump.0 - 0.04) * h + stir * (1.6 + CGFloat(index % 4) * 0.5), (clump.1 + 0.035) * h, clump.2 * h * 0.62, clump.3 * h * 0.50,
                           lobes: 7, depth: 0.22, seed: seed + index + 50, flat: 0.3), shade(0.28, 0.48, 0.28, 0.38))
        }
        detail(strokePath([(x - h * 0.03, h * 0.04), (x - h * 0.015, h * 0.20), (x - h * 0.03, h * 0.34)], max(0.6, h * 0.012), smooth: true), strength: 0.4)
        detail(strokePath([(x + h * 0.025, h * 0.06), (x + h * 0.03, h * 0.22)], max(0.6, h * 0.010), smooth: true), strength: 0.3)
        // Fine bark and scattered leaf clusters add texture while keeping the
        // large branch silhouette visible through the lower canopy.
        var bark = Path(), leaves = Path()
        for groove in 0..<5 {
            let dx = (CGFloat(groove) - 2) * h * 0.018
            bark.addPath(strokePath([(x + dx, h * 0.04), (x + dx * 0.8 + h * 0.006, h * 0.18),
                                     (x + dx * 0.7 - h * 0.004, h * 0.31)], max(0.35, h * 0.006), smooth: true))
        }
        for leaf in 0..<18 {
            let lx = x + (CGFloat(Self.noise(seed + leaf, 389)) - 0.5) * h * 1.02 + stir
            let ly = h * (0.67 + 0.21 * CGFloat(Self.noise(seed + leaf, 391)))
            let r = max(0.5, h * 0.012)
            leaves.addPath(polygon([(lx - r, ly), (lx, ly + r * 0.9), (lx + r * 1.5, ly), (lx, ly - r * 0.6)]))
        }
        tint(bark, shade(0.77, 0.66, 0.52, 0.27))
        tint(leaves, shade(0.53, 0.66, 0.41, 0.32))
    }
}

extension SkylinePen {
    // MARK: What is built

    /// A slim minaret as Madinah builds them: a square foot, shafts stepping in
    /// at each balcony, a lantern, a cap and a crescent.
    mutating func tallMinaret(_ x: CGFloat, _ h: CGFloat, width w: CGFloat = 5.2, gilt: Bool = true) {
        block(x, w, h * 0.30)
        shape([(x - w * 0.50, h * 0.30 - 1.2), (x + w * 0.50, h * 0.30 - 1.2), (x + w * 0.76, h * 0.30 + 0.6), (x - w * 0.76, h * 0.30 + 0.6)])
        block(x, w * 1.52, 1.5, from: h * 0.30 + 0.6)
        block(x, w * 0.80, h * 0.28, from: h * 0.30)
        shape([(x - w * 0.40, h * 0.58 - 1.0), (x + w * 0.40, h * 0.58 - 1.0), (x + w * 0.62, h * 0.58 + 0.5), (x - w * 0.62, h * 0.58 + 0.5)])
        block(x, w * 1.24, 1.3, from: h * 0.58 + 0.5)
        block(x, w * 0.60, h * 0.20, from: h * 0.58)
        block(x, w * 0.98, 1.2, from: h * 0.78)
        block(x, w * 0.44, h * 0.10, from: h * 0.78)
        block(x, w * 0.74, 0.9, from: h * 0.875)
        add(bulbPath(x, w * 0.66, on: h * 0.88, rise: h * 0.05))
        finial(x, from: h * 0.925, height: h * 0.075, gilt: gilt)
        disc(x, h * 0.30 + 4.2, 0.9, .light); disc(x, h * 0.58 + 3.8, 0.8, .light); disc(x, h * 0.82, 0.7, .light)
        detail(blockPath(x - w * 0.22, w * 0.20, h * 0.20, from: h * 0.07), strength: 0.6)
        detail(blockPath(x - w * 0.16, w * 0.16, h * 0.20, from: h * 0.34), strength: 0.5)
        detail(blockPath(x, w * 1.3, 0.7, from: h * 0.30 + 1.0), strength: 0.9)
        detail(blockPath(x, w * 1.05, 0.6, from: h * 0.58 + 0.8), strength: 0.9)
        // Recessed shaft panels and the small corbels under each balcony.
        var panels = Path(), corbels = Path()
        for (base, height, wide) in [(0.05, 0.22, 0.62), (0.34, 0.20, 0.48), (0.62, 0.13, 0.34)] {
            let y = h * CGFloat(base), panelHeight = h * CGFloat(height), panelWidth = w * CGFloat(wide)
            panels.addPath(blockPath(x + panelWidth * 0.29, max(w * 0.04, 0.18), panelHeight, from: y))
            panels.addPath(blockPath(x, panelWidth, max(h * 0.006, 0.22), from: y))
            panels.addPath(blockPath(x, panelWidth, max(h * 0.006, 0.22), from: y + panelHeight))
        }
        for (level, width) in [(0.30, 1.1), (0.58, 0.90)] {
            for offset in [-0.33, -0.11, 0.11, 0.33] {
                let cx = x + w * CGFloat(offset) * CGFloat(width)
                corbels.addPath(polygon([(cx - w * 0.035, h * CGFloat(level) - 1.1),
                                         (cx + w * 0.035, h * CGFloat(level) - 1.1),
                                         (cx + w * 0.06, h * CGFloat(level) + 0.2),
                                         (cx - w * 0.06, h * CGFloat(level) + 0.2)]))
            }
        }
        detail(panels, strength: 0.65)
        detail(corbels, strength: 0.8)
    }

    /// A window that is a dark recess by day and lit from within at night.
    mutating func window(_ x: CGFloat, _ w: CGFloat, _ h: CGFloat, from y: CGFloat, pointed: Bool = true) {
        tint(archPath(x, w, h, from: y, pointed: pointed), Color.black.opacity(0.30))
        add(archPath(x, w * 0.62, h * 0.74, from: y + h * 0.10, pointed: pointed), .light)
        // Fine stone reveal and the mullion stay inside the existing opening.
        let reveal = archPath(x, w * 0.92, h * 0.94, from: y + h * 0.02, pointed: pointed)
        detail(reveal.strokedPath(StrokeStyle(lineWidth: max(0.20, w * 0.055))), strength: 0.75)
        detail(blockPath(x, max(0.16, w * 0.07), h * 0.56, from: y + h * 0.10), strength: 0.55)
    }

    /// A small mosque: hall, dome, one minaret, lamps at night.
    mutating func mosque(_ x: CGFloat, scale s: CGFloat = 1) {
        let hx = x - 7 * s
        // The hall on its plinth, a cornice and a row of merlons along its roof.
        block(hx, 62 * s, 1.6 * s)
        block(hx, 56 * s, 19 * s, from: 1.6 * s)
        block(hx, 59 * s, 1.5 * s, from: 20.6 * s)
        var merlons = Path()
        for step in stride(from: CGFloat(-26), through: 26, by: 4) where abs(step) > 9 {
            merlons.addPath(polygon([(hx + (step - 1.4) * s, 22.1 * s), (hx + (step + 1.4) * s, 22.1 * s), (hx + step * s, 24.8 * s)]))
        }
        add(merlons)
        // The portal, rising through the roofline, and its doorway with a lamp in it.
        block(hx, 15 * s, 25.6 * s)
        block(hx, 17 * s, 1.4 * s, from: 25.6 * s)
        tint(archPath(hx, 8.4 * s, 16 * s, from: 1.6 * s), Color.black.opacity(0.36))
        detail(archPath(hx, 11.4 * s, 18.6 * s, from: 1.6 * s).strokedPath(StrokeStyle(lineWidth: 0.7 * s)), strength: 0.9)
        detail(blockPath(hx, 12 * s, 0.7 * s, from: 22.4 * s), strength: 0.9)
        glow(hx, 11 * s, 11 * s, Self.lampLight, 0.22, nightOnly: true)
        tint(archPath(hx, 6.6 * s, 13.6 * s, from: 1.8 * s), Self.lampLight.opacity(0.30), nightOnly: true)
        block(hx, 0.5 * s, 3.4 * s, from: 13.6 * s, .light)
        add(smoothPath([(hx, 13.8 * s), (hx + 1.5 * s, 12.2 * s), (hx + 1.0 * s, 10.2 * s), (hx - 1.0 * s, 10.2 * s), (hx - 1.5 * s, 12.2 * s)]), .light)
        // Windows either side.
        for step in [-22.0, -13.5, 13.5, 22.0] as [CGFloat] {
            window(hx + step * s, 4.4 * s, 9.4 * s, from: 6.6 * s)
            detail(blockPath(hx + step * s, 6 * s, 0.7 * s, from: 5.6 * s), strength: 0.8)
        }
        detail(blockPath(hx, 55 * s, 0.7 * s, from: 18.8 * s), strength: 0.7)
        // Short masonry joints, set between the windows and below the cornice.
        var stonework = Path()
        for side in [-1.0, 1.0] as [CGFloat] {
            for level in [3.6, 17.4] as [CGFloat] {
                stonework.addPath(blockPath(hx + side * 18.5 * s, 17 * s, 0.42 * s, from: level * s))
                for step in [12.0, 17.5, 23.0] as [CGFloat] {
                    stonework.addPath(blockPath(hx + side * step * s, 0.38 * s, 1.4 * s, from: level * s))
                }
            }
        }
        detail(stonework, strength: 0.64)
        // The dome on its drum, a lesser dome beside it.
        block(hx, 25 * s, 5 * s, from: 22.1 * s)
        block(hx, 27 * s, 0.9 * s, from: 27.1 * s)
        add(bulbPath(hx, 27 * s, on: 27.6 * s, rise: 17 * s))
        finial(hx, from: 43.8 * s, height: 9 * s, gilt: true)
        detail(bulbPath(hx - 4 * s, 12 * s, on: 29 * s, rise: 11 * s), strength: 0.6)
        var domeRibs = Path()
        for side in [-1.0, 1.0] as [CGFloat] {
            domeRibs.addPath(strokePath([(hx + side * 8.2 * s, 28.1 * s),
                                         (hx + side * 7.2 * s, 34.4 * s),
                                         (hx + side * 3.7 * s, 40.2 * s), (hx, 44 * s)], 0.38 * s, smooth: true))
        }
        detail(domeRibs, strength: 0.65)
        for step in [-9.5, -3.2, 3.2, 9.5] as [CGFloat] { block(hx + step * s, 1.3 * s, 2.4 * s, from: 23.6 * s, .light) }
        dome(hx - 21.5 * s, 11 * s, on: 22.1 * s, rise: 5.6 * s)
        block(hx - 21.5 * s, 0.7 * s, 2.6 * s, from: 27.4 * s)
        // The minaret, joined to the hall by a low wall.
        block(x + 25 * s, 9 * s, 9 * s)
        detail(blockPath(x + 25 * s, 8 * s, 0.6 * s, from: 7.6 * s), strength: 0.7)
        tallMinaret(x + 31 * s, 70 * s, width: 5.4 * s)
    }

    /// Al-Aqsa: its arcade and grey dome, the gold Dome of the Rock beside it.
    mutating func aqsa(_ x: CGFloat, scale s: CGFloat = 1) {
        // The ground of the sanctuary they both stand on.
        block(x - 4 * s, 196 * s, 1.8 * s)
        // Al-Aqsa's hall: seven arches along its front, the middle one tallest under a gable.
        let ax = x - 52 * s
        block(ax, 80 * s, 19 * s, from: 1.8 * s)
        block(ax, 83 * s, 1.4 * s, from: 20.8 * s)
        block(ax, 16 * s, 5 * s, from: 20.8 * s)
        shape([(ax - 9 * s, 25.8 * s), (ax + 9 * s, 25.8 * s), (ax, 29.6 * s)])
        for bay in -3...3 {
            let bx = ax + CGFloat(bay) * 10.6 * s
            arch(bx, (bay == 0 ? 8.4 : 7.0) * s, (bay == 0 ? 16.4 : 13.4) * s, from: 1.8 * s, pointed: true)
            disc(bx, (bay == 0 ? 13.2 : 10.6) * s, 0.9 * s, .light)
        }
        for pier in stride(from: CGFloat(-31.8), through: 31.8, by: 10.6) {
            detail(blockPath(ax + pier * s, 1.6 * s, 9.4 * s, from: 2.2 * s), strength: 0.9)
        }
        detail(blockPath(ax, 78 * s, 0.7 * s, from: 18.6 * s), strength: 0.8)
        var crest = Path()
        for step in stride(from: CGFloat(-38), through: 38, by: 4.6) where abs(step) > 10 {
            crest.addPath(blockPath(ax + step * s, 2.2 * s, 1.5 * s, from: 22.2 * s))
        }
        add(crest)
        // Its dome of grey lead, set back over the far end of the hall.
        let gx = ax + 18 * s
        block(gx, 19 * s, 6 * s, from: 22.2 * s)
        add(bulbPath(gx, 20 * s, on: 28.2 * s, rise: 12.6 * s))
        tint(bulbPath(gx, 20 * s, on: 28.2 * s, rise: 12.6 * s), shade(0.50, 0.55, 0.60, 0.92))
        tint(bulbPath(gx - 3 * s, 9 * s, on: 29.4 * s, rise: 8.4 * s), Color.white.opacity(0.10))
        finial(gx, from: 40 * s, height: 6 * s)
        for step in [-6.0, -2.0, 2.0, 6.0] as [CGFloat] { block(gx + step * s, 1.1 * s, 2.6 * s, from: 23.8 * s, .light) }

        // The Dome of the Rock: eight walls, of which three face us, a drum and the gold dome.
        let rx = x + 50 * s
        shape([(rx - 29 * s, 1.8 * s), (rx + 29 * s, 1.8 * s), (rx + 29 * s, 19 * s), (rx - 29 * s, 19 * s)])
        block(rx, 60.5 * s, 1.5 * s, from: 19 * s)
        // Marble below, a band of blue tile above; the two outer walls turn away and are darker.
        tint(blockPath(rx, 58 * s, 8.4 * s, from: 10.4 * s), shade(0.16, 0.42, 0.58, 0.62))
        tint(blockPath(rx, 58 * s, 8.4 * s, from: 2 * s), shade(0.72, 0.70, 0.66, 0.16))
        for side in [-1.0, 1.0] as [CGFloat] {
            tint(blockPath(rx + side * 22 * s, 14 * s, 17 * s, from: 2 * s), Color.black.opacity(0.20))
            detail(blockPath(rx + side * 15 * s, 0.7 * s, 17 * s, from: 2 * s), strength: 1.0)
        }
        for step in [-23.5, -19.5, -9.0, -4.5, 4.5, 9.0, 19.5, 23.5] as [CGFloat] {
            window(rx + step * s, 2.6 * s, 5.6 * s, from: 11.4 * s)
        }
        // Tile borders and small geometric insets run between the openings;
        // the pale lower courses suggest the joints in the marble facing.
        var tilework = Path(), marble = Path()
        for side in [-1.0, 1.0] as [CGFloat] {
            for y in [10.8, 18.0] as [CGFloat] {
                tilework.addPath(blockPath(rx + side * 14.5 * s, 27.5 * s, 0.35 * s, from: y * s))
            }
            for step in [6.7, 12.0, 16.8, 21.6, 26.0] as [CGFloat] {
                let px = rx + side * step * s
                tilework.addPath(polygon([(px, 11.1 * s), (px + 0.55 * s, 11.8 * s),
                                          (px, 12.5 * s), (px - 0.55 * s, 11.8 * s)]))
                marble.addPath(blockPath(px, 0.36 * s, 2.2 * s, from: 4.0 * s))
            }
            marble.addPath(blockPath(rx + side * 14.5 * s, 27.5 * s, 0.35 * s, from: 6.2 * s))
        }
        tint(tilework, shade(0.67, 0.82, 0.80, 0.46))
        detail(marble, strength: 0.48)
        // The door under its porch.
        tint(archPath(rx, 5.6 * s, 9.6 * s, from: 1.8 * s, pointed: false), Color.black.opacity(0.42))
        detail(archPath(rx, 8 * s, 11.4 * s, from: 1.8 * s, pointed: false).strokedPath(StrokeStyle(lineWidth: 0.7 * s)), strength: 0.9)
        block(rx, 1.6 * s, 2.4 * s, from: 4 * s, .light)
        // The drum, tiled, with its ring of windows.
        block(rx, 31 * s, 11 * s, from: 20.5 * s)
        block(rx, 33 * s, 1.2 * s, from: 31.5 * s)
        tint(blockPath(rx, 31 * s, 10.4 * s, from: 20.8 * s), shade(0.18, 0.44, 0.58, 0.58))
        for step in stride(from: CGFloat(-12), through: 12, by: 4.8) { window(rx + step * s, 2.2 * s, 5.4 * s, from: 23.6 * s) }
        // The dome, gilded, lit from below after dark.
        let gold = bulbPath(rx, 33 * s, on: 32.7 * s, rise: 24.5 * s)
        add(gold)
        tint(gold, shade(0.88, 0.67, 0.26))
        tint(bulbPath(rx - 5 * s, 14 * s, on: 34.4 * s, rise: 17 * s), Color(red: 1.0, green: 0.92, blue: 0.62).opacity(0.22))
        tint(gold, Color(red: 1.0, green: 0.78, blue: 0.36).opacity(0.30), nightOnly: true)
        var gildedRibs = Path()
        for side in [-1.0, 1.0] as [CGFloat] {
            for offset in [5.0, 10.5] as [CGFloat] {
                gildedRibs.addPath(strokePath([(rx + side * offset * s, 33.4 * s),
                                               (rx + side * offset * 0.86 * s, 42.0 * s),
                                               (rx + side * offset * 0.42 * s, 51.4 * s),
                                               (rx, 56.6 * s)], 0.34 * s, smooth: true))
            }
        }
        tint(gildedRibs, shade(1.0, 0.87, 0.52, 0.34))
        finial(rx, from: 56.6 * s, height: 13 * s, gilt: true)
        // Cypresses in the court between them.
        for (cx, tall) in [(-7.0, 30.0), (2.0, 24.0), (9.0, 33.0), (87.0, 28.0), (-96.0, 26.0)] as [(CGFloat, CGFloat)] {
            let px = x + cx * s
            add(smoothPath([(px - 0.6 * s, 1.5 * s), (px - 2.6 * s, tall * 0.34 * s), (px - 1.9 * s, tall * 0.72 * s), (px, (tall + 1.5) * s),
                            (px + 1.9 * s, tall * 0.72 * s), (px + 2.6 * s, tall * 0.34 * s), (px + 0.6 * s, 1.5 * s)]))
        }
    }

    /// The Prophet's Mosque: the green dome among its minarets.
    mutating func greenDome(_ x: CGFloat, scale s: CGFloat = 1) {
        // The long front: an arcade with a lamp in every arch, a storey set back above it.
        block(x, 150 * s, 16 * s)
        block(x, 153 * s, 1.5 * s, from: 16 * s)
        for step in stride(from: CGFloat(-66), through: 66, by: 11) {
            arch(x + step * s, 5.6 * s, 10.4 * s, pointed: true)
            disc(x + step * s, 7.6 * s, 0.9 * s, .light)
        }
        for step in stride(from: CGFloat(-60.5), through: 60.5, by: 11) {
            detail(blockPath(x + step * s, 1.6 * s, 7 * s, from: 0.8 * s), strength: 0.9)
        }
        detail(blockPath(x, 146 * s, 0.7 * s, from: 13.6 * s), strength: 0.8)
        block(x, 104 * s, 6 * s, from: 17.5 * s)
        var crest = Path()
        for step in stride(from: CGFloat(-72), through: 72, by: 4.8) where abs(step) > 53 {
            crest.addPath(polygon([(x + (step - 1.3) * s, 17.5 * s), (x + (step + 1.3) * s, 17.5 * s), (x + step * s, 20 * s)]))
        }
        add(crest)
        for step in stride(from: CGFloat(-45), through: 45, by: 6) where abs(step - 8) > 12 {
            block(x + step * s, 1.4 * s, 2.8 * s, from: 19 * s, .light)
        }
        // The roof's small domes, and the silver dome over the mihrab.
        for step in [-40.0, -27.0, 30.0, 42.0] as [CGFloat] { dome(x + step * s, 9 * s, on: 23.5 * s, rise: 4.4 * s) }
        dome(x - 13 * s, 11 * s, on: 23.5 * s, rise: 6.4 * s)
        tint(domePath(x - 13 * s, 11 * s, on: 23.5 * s, rise: 6.4 * s), shade(0.58, 0.62, 0.66, 0.85))
        block(x - 13 * s, 0.7 * s, 3 * s, from: 29.6 * s)
        // The green dome on its drum.
        block(x + 8 * s, 21 * s, 6.4 * s, from: 23.5 * s)
        block(x + 8 * s, 23 * s, 1.0 * s, from: 29.9 * s)
        let green = bulbPath(x + 8 * s, 22 * s, on: 30.9 * s, rise: 14 * s)
        add(green)
        tint(green, shade(0.15, 0.47, 0.33))
        tint(bulbPath(x + 4.6 * s, 9 * s, on: 32 * s, rise: 9.6 * s), Color.white.opacity(0.13))
        var domeRibs = Path(), drumPanels = Path()
        for side in [-1.0, 1.0] as [CGFloat] {
            domeRibs.addPath(strokePath([(x + (8 + side * 6.5) * s, 31.5 * s),
                                         (x + (8 + side * 5.4) * s, 37.0 * s),
                                         (x + (8 + side * 2.5) * s, 42.0 * s), (x + 8 * s, 44.4 * s)], 0.35 * s, smooth: true))
            drumPanels.addPath(blockPath(x + (8 + side * 9.2) * s, 0.45 * s, 4.2 * s, from: 24.1 * s))
        }
        tint(domeRibs, shade(0.57, 0.76, 0.60, 0.42))
        detail(drumPanels, strength: 0.75)
        for step in [-6.6, -2.2, 2.2, 6.6] as [CGFloat] { block(x + (8 + step) * s, 1.2 * s, 2.8 * s, from: 25.4 * s, .light) }
        finial(x + 8 * s, from: 44.4 * s, height: 8.5 * s, gilt: true)
        // Its minarets: the two tallest at the ends, two more nearer the dome.
        tallMinaret(x - 62 * s, 80 * s, width: 5.4 * s)
        tallMinaret(x + 64 * s, 80 * s, width: 5.4 * s)
        tallMinaret(x - 30 * s, 64 * s, width: 4.8 * s)
        tallMinaret(x + 37 * s, 64 * s, width: 4.8 * s)
    }

    /// Mount Uhud: one long red-brown massif with many heads. Its colour lies
    /// on its upper slopes only, so that what stands at its foot keeps clear of it.
    mutating func uhud(_ x: CGFloat, scale s: CGFloat = 1) {
        let w = 260 * s, h = 90 * s
        let heads: [Spot] = [
            (-0.50, 0), (-0.475, 0.09), (-0.44, 0.14), (-0.41, 0.28), (-0.385, 0.31), (-0.355, 0.47), (-0.335, 0.50), (-0.31, 0.44),
            (-0.29, 0.55), (-0.262, 0.67), (-0.24, 0.64), (-0.222, 0.58), (-0.205, 0.66), (-0.18, 0.81), (-0.16, 0.79), (-0.142, 0.71),
            (-0.118, 0.78), (-0.092, 0.91), (-0.07, 0.86), (-0.05, 0.90), (-0.022, 0.985), (0.0, 1.0), (0.022, 0.94), (0.04, 0.90),
            (0.062, 0.95), (0.082, 0.88), (0.10, 0.80), (0.122, 0.87), (0.14, 0.84), (0.158, 0.73), (0.18, 0.68), (0.205, 0.77),
            (0.226, 0.72), (0.245, 0.60), (0.268, 0.56), (0.292, 0.65), (0.312, 0.60), (0.335, 0.46), (0.36, 0.41), (0.385, 0.46),
            (0.405, 0.36), (0.428, 0.25), (0.452, 0.16), (0.478, 0.07), (0.50, 0)
        ]
        let crest = heads.map { (x + $0.0 * w, $0.1 * h) }
        shape(crest)
        // The red of its rock, on the upper slopes, breaking off raggedly lower down.
        var upper: [Spot] = crest.filter { $0.1 > h * 0.44 }
        let hem: [Spot] = [(0.33, 0.44), (0.27, 0.50), (0.21, 0.45), (0.15, 0.54), (0.09, 0.47), (0.03, 0.56), (-0.03, 0.48),
                           (-0.09, 0.55), (-0.15, 0.46), (-0.21, 0.52), (-0.27, 0.45), (-0.33, 0.47)]
        upper += hem.map { (x + $0.0 * w, $0.1 * h) }
        tint(polygon(upper), shade(0.56, 0.28, 0.18, 0.46))
        // Each head's face towards the light, and the gullies between the heads.
        var faces = Path(), gullies = Path()
        for peak in [5, 9, 13, 17, 21, 24, 27, 31, 35] {
            let top = crest[peak]
            faces.addPath(polygon([top, (top.0 - 0.034 * w, top.1 - 0.17 * h), (top.0 - 0.012 * w, top.1 - 0.24 * h), (top.0 + 0.004 * w, top.1 - 0.10 * h)]))
        }
        for notch in [7, 11, 15, 18, 23, 26, 30, 33, 37] {
            let low = crest[notch]
            gullies.addPath(polygon([(low.0 - 0.5 * s, low.1), (low.0 + 0.5 * s, low.1), (low.0 + 0.016 * w, low.1 - 0.20 * h), (low.0 + 0.010 * w, low.1 - 0.20 * h)]))
        }
        tint(faces, shade(0.80, 0.46, 0.30, 0.30))
        tint(gullies, Color.black.opacity(0.16))
        // Short slanted strata catch the light without filling the valleys or
        // extending beyond the irregular upper rock silhouette.
        var strata = Path()
        for peak in [9, 13, 17, 21, 24, 27, 31] {
            let top = crest[peak]
            for band in 1...3 {
                let drop = CGFloat(band) * h * 0.032
                strata.addPath(strokePath([(top.0 - 0.010 * w, top.1 - drop - 0.015 * h),
                                           (top.0 + 0.006 * w, top.1 - drop - 0.03 * h)], 0.45 * s))
            }
        }
        tint(strata, shade(0.90, 0.65, 0.48, 0.28))
    }

    /// A cluster of mud-brick houses: doors, a dome or two, windows lit at night.
    mutating func town(_ x: CGFloat, houses: Int = 5, scale s: CGFloat = 1) {
        let count = max(1, houses)
        var dark = Path(), lit = Path(), edges = Path(), beams = Path(), plaster = Path()
        for index in 0..<count {
            let slot = CGFloat(index) - CGFloat(count - 1) / 2
            let middle = 1 - abs(slot) / (CGFloat(count) / 2 + 0.5)
            let w = (15 + CGFloat(Self.noise(index, 401)) * 8) * s
            let h = (11 + CGFloat(Self.noise(index, 403)) * 7 + middle * 9) * s
            let cx = x + slot * 13.5 * s + (CGFloat(Self.noise(index, 405)) - 0.5) * 4 * s
            // Walls leaning in a little, as mud brick is built; a parapet with raised corners.
            shape([(cx - w / 2 - 0.6 * s, 0), (cx + w / 2 + 0.6 * s, 0), (cx + w / 2, h), (cx - w / 2, h)])
            block(cx, w + 1.4 * s, 1.1 * s, from: h)
            block(cx - w / 2 + 1.1 * s, 2.2 * s, 1.5 * s, from: h + 1.1 * s)
            block(cx + w / 2 - 1.1 * s, 2.2 * s, 1.5 * s, from: h + 1.1 * s)
            edges.addPath(blockPath(cx - w / 2 + 0.6 * s, 0.9 * s, h - 1.5 * s, from: 0.8 * s))
            // Broken plaster and irregular brick courses are confined to the
            // narrow band just under the roof, above the window openings.
            plaster.addPath(blockPath(cx, w - 2.2 * s, 0.35 * s, from: h - 3.8 * s))
            for joint in [-0.28, 0.05, 0.32] as [CGFloat] {
                plaster.addPath(blockPath(cx + joint * w, 0.35 * s, 1.1 * s, from: h - 4.6 * s))
            }
            for beam in stride(from: -w / 2 + 3 * s, through: w / 2 - 3 * s, by: 3.4 * s) {
                beams.addPath(blockPath(cx + beam, 0.9 * s, 0.9 * s, from: h - 2.6 * s))
            }
            switch index % 5 {
            case 1:
                // A dome over the room below.
                dome(cx - w * 0.08, w * 0.56, on: h + 1.1 * s, rise: w * 0.30)
                block(cx - w * 0.08, 0.6 * s, 2 * s, from: h + 1.1 * s + w * 0.29)
                edges.addPath(domePath(cx - w * 0.16, w * 0.26, on: h + 1.6 * s, rise: w * 0.19))
            case 2:
                // An upper room on one side of the roof.
                block(cx + w * 0.20, w * 0.52, 6.4 * s, from: h + 1.1 * s)
                block(cx + w * 0.20, w * 0.52 + 1.2 * s, 0.9 * s, from: h + 7.5 * s)
                dark.addPath(blockPath(cx + w * 0.20, 1.7 * s, 2.5 * s, from: h + 3.2 * s))
                lit.addPath(blockPath(cx + w * 0.20, 1.1 * s, 1.8 * s, from: h + 3.5 * s))
            case 3:
                // Steps up the outside wall to the roof.
                shape([(cx + w / 2, 0), (cx + w / 2 + 6 * s, 0), (cx + w / 2 + 6 * s, 2.2 * s), (cx + w / 2 + 4 * s, 2.2 * s), (cx + w / 2 + 4 * s, 4.4 * s),
                       (cx + w / 2 + 2 * s, 4.4 * s), (cx + w / 2 + 2 * s, 6.6 * s), (cx + w / 2, 6.6 * s)])
            case 4:
                // A wind tower.
                block(cx - w * 0.22, 3.6 * s, 7.5 * s, from: h + 1.1 * s)
                block(cx - w * 0.22, 4.8 * s, 0.9 * s, from: h + 8.6 * s)
                dark.addPath(blockPath(cx - w * 0.22 - 0.8 * s, 0.7 * s, 3.4 * s, from: h + 4.4 * s))
                dark.addPath(blockPath(cx - w * 0.22 + 0.8 * s, 0.7 * s, 3.4 * s, from: h + 4.4 * s))
            default:
                // A shade of poles on the roof.
                block(cx - w * 0.26, 0.6 * s, 4.6 * s, from: h + 1.1 * s); block(cx + w * 0.22, 0.6 * s, 4.6 * s, from: h + 1.1 * s)
                block(cx - w * 0.02, w * 0.62, 0.7 * s, from: h + 5.2 * s)
            }
            // A door in every other house, and small deep windows.
            if index % 2 == 0 {
                dark.addPath(archPath(cx - w * 0.14, 3.4 * s, 6.6 * s, pointed: false))
                edges.addPath(blockPath(cx - w * 0.14, 5 * s, 0.6 * s, from: 7.2 * s))
            }
            let rows = h > 17 * s ? 2 : 1
            for row in 0..<rows {
                for column in 0..<2 where Self.noise(index * 7 + row * 3 + column, 407) > 0.28 {
                    let wx = cx + (column == 0 ? -0.26 : 0.24) * w + (index % 2 == 0 && column == 0 && row == 0 ? w * 0.42 : 0)
                    let wy = (row == 0 ? (index % 2 == 0 ? 9.6 * s : 5.6 * s) : h - 6.8 * s)
                    guard abs(wx - cx) < w / 2 - 1.6 * s, wy + 3 * s < h - 2.8 * s else { continue }
                    dark.addPath(blockPath(wx, 2.0 * s, 2.9 * s, from: wy))
                    lit.addPath(blockPath(wx, 1.3 * s, 2.1 * s, from: wy + 0.4 * s))
                }
            }
        }
        tint(dark, Color.black.opacity(0.34))
        detail(edges, strength: 0.75)
        detail(beams, strength: 0.9)
        detail(plaster, strength: 0.60)
        add(lit, .light)
    }

    /// Market stalls under awnings that flap. Moves.
    mutating func market(_ x: CGFloat, stalls: Int = 3) {
        let count = max(1, stalls), pitch: CGFloat = 38
        let cloths: [(Double, Double, Double)] = [(0.72, 0.30, 0.24), (0.90, 0.82, 0.62), (0.20, 0.46, 0.50), (0.82, 0.60, 0.26)]
        let wares: [(Double, Double, Double)] = [(0.92, 0.56, 0.20), (0.44, 0.60, 0.30), (0.76, 0.26, 0.22), (0.90, 0.78, 0.40)]
        for index in 0..<count {
            let cx = x + (CGFloat(index) - CGFloat(count - 1) / 2) * pitch
            let tall: CGFloat = 27 + CGFloat(index % 2) * 3, front = tall - 8.5
            // Posts, the counter, and what stands on the ground beside it.
            block(cx - 15.5, 1.3, front + 1); block(cx + 15.5, 1.3, front + 1)
            block(cx - 12, 1.1, tall); block(cx + 12, 1.1, tall)
            block(cx, 29, 8.4)
            block(cx, 31, 1.2, from: 8.4)
            detail(blockPath(cx, 27, 0.7, from: 5.6), strength: 0.7)
            for board in [-9.0, 0.0, 9.0] as [CGFloat] { detail(blockPath(cx + board, 0.6, 7.6, from: 0.4), strength: 0.5) }
            // Baskets heaped with fruit, sacks, a jar.
            for (slot, dx) in [-9.5, 0.0, 9.5].enumerated() {
                let bx = cx + CGFloat(dx)
                shape([(bx - 3.6, 9.6), (bx + 3.6, 9.6), (bx + 4.2, 12.6), (bx - 4.2, 12.6)])
                tint(domePath(bx, 7.4, on: 12.6, rise: 2.6 + CGFloat((slot + index) % 2)), shade(wares[(slot + index) % wares.count], 0.95))
                detail(blockPath(bx, 7.6, 0.6, from: 11.2), strength: 0.8)
                var weave = Path()
                for offset in [-2.4, 0.0, 2.4] as [CGFloat] {
                    weave.addPath(strokePath([(bx + offset - 0.5, 10.0), (bx + offset + 0.5, 12.3)], 0.4))
                }
                tint(weave, shade(0.95, 0.79, 0.50, 0.48))
                for fruit in 0..<3 {
                    let fx = bx + CGFloat(fruit - 1) * 2.0
                    tint(discPath(fx, 13.6 + CGFloat((fruit + slot) % 2) * 0.6, 0.5), Color.white.opacity(0.26))
                }
            }
            let jx = cx + 19.5
            if index == count - 1 || index % 2 == 0 {
                add(smoothPath([(jx - 1.4, 0), (jx - 3.2, 4), (jx - 2.6, 8), (jx - 1.0, 9.6), (jx - 1.4, 11.4), (jx + 1.4, 11.4), (jx + 1.0, 9.6), (jx + 2.6, 8), (jx + 3.2, 4), (jx + 1.4, 0)]))
            } else {
                add(smoothPath([(jx - 4, 0), (jx - 4.6, 4.4), (jx - 2, 7.6), (jx - 0.6, 9.4), (jx + 0.8, 7.6), (jx + 4.2, 5), (jx + 4, 0)]))
            }
            // The awning: its front edge hangs lower, scalloped, and lifts in the wind.
            let billow = CGFloat(sin(time * 1.3 + Double(index) * 1.9)) * 1.2
            var hem: [Spot] = []
            let scallops = 6
            for scallop in 0...scallops {
                let part = CGFloat(scallop) / CGFloat(scallops), hx = cx - 18 + 36 * part
                let lift = billow * CGFloat(sin(Double(part) * Double.pi))
                hem.append((hx, front + lift))
                if scallop < scallops {
                    let flap = CGFloat(sin(time * 2.6 + Double(scallop) * 0.9 + Double(index))) * 0.9
                    hem.append((hx + 3 + flap * 0.4, front - 3.2 + lift + flap))
                }
            }
            let cloth = cloths[index % cloths.count]
            tint(polygon([(cx - 13.5, tall + 0.6), (cx + 13.5, tall + 0.6)] + hem.reversed()), shade(cloth, 0.96))
            var stripes = Path()
            for stripe in [-0.34, 0.0, 0.34] {
                let at = CGFloat(stripe)
                stripes.addPath(polygon([(cx + at * 27 - 1.7, tall + 0.6), (cx + at * 27 + 1.7, tall + 0.6),
                                         (cx + at * 36 + 2.3, front + billow * CGFloat(cos(stripe * 3)) * 0.8), (cx + at * 36 - 2.3, front + billow * CGFloat(cos(stripe * 3)) * 0.8)]))
            }
            tint(stripes, Color.black.opacity(0.14))
            tint(polygon([(cx - 13.5, tall + 0.6), (cx + 13.5, tall + 0.6), (cx + 14, tall - 0.4), (cx - 14, tall - 0.4)]), Color.white.opacity(0.16))
            var seams = Path()
            for seam in [-0.50, 0.0, 0.50] as [CGFloat] {
                seams.addPath(strokePath([(cx + seam * 13.5, tall + 0.15),
                                          (cx + seam * 18, front + billow * (1 - abs(seam)))], 0.38))
            }
            tint(seams, shade(1.0, 0.91, 0.74, 0.28))
            // A lamp under the middle of each awning.
            smallLantern(cx + 5, top: tall - 1, scale: 0.8, flame: flicker(Double(index) * 1.7))
            block(cx + 5, 0.5, 1.4, from: tall - 1)
        }
    }

    /// A tall brick tower; unfinished, it ends in scaffolding.
    mutating func tower(_ x: CGFloat, _ h: CGFloat, unfinished: Bool = false) {
        let base = max(14, h * 0.27), body = unfinished ? h * 0.78 : h * 0.84
        // Three stages, each stepping in, each with a ledge at its foot.
        let stages: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [(0, 0.40, 1.0, 0.90), (0.40, 0.70, 0.80, 0.74), (0.70, body / h, 0.62, 0.58)]
        var courses = Path(), masonryJoints = Path()
        for (index, stage) in stages.enumerated() {
            let low = stage.0 * h, high = stage.1 * h, wide = base * stage.2, narrow = base * stage.3
            shape([(x - wide / 2, low), (x + wide / 2, low), (x + narrow / 2, high), (x - narrow / 2, high)])
            if index > 0 { block(x, wide + 2.4, 1.5, from: low - 0.4) }
            var y = low + 4.5
            while y < high - 2 {
                let part = (y - low) / (high - low), across = wide + (narrow - wide) * part
                courses.addPath(blockPath(x, across - 1.6, 0.6, from: y))
                let joints = max(2, Int(across / 6.5))
                for joint in 1..<joints {
                    let px = x - across / 2 + across * CGFloat(joint) / CGFloat(joints)
                    masonryJoints.addPath(blockPath(px, 0.35, min(2.5, high - y - 1), from: y + 0.6))
                }
                y += 5
            }
            // A lit slit in each stage.
            let slit = low + (high - low) * 0.58
            tint(blockPath(x + (index == 1 ? -1.6 : 1.2), 1.6, 5, from: slit), Color.black.opacity(0.30))
            block(x + (index == 1 ? -1.6 : 1.2), 0.9, 3.8, from: slit + 0.6, .light)
        }
        detail(courses, strength: 0.55)
        detail(masonryJoints, strength: 0.44)
        detail(polygon([(x - base / 2 + 0.6, 1), (x - base / 2 + 2.0, 1), (x - base * 0.45 + 1.8, h * 0.39), (x - base * 0.45 + 0.6, h * 0.39)]), strength: 0.7)
        // The doorway at its foot.
        tint(archPath(x, base * 0.24, base * 0.52, pointed: true), Color.black.opacity(0.40))
        detail(archPath(x, base * 0.34, base * 0.62, pointed: true).strokedPath(StrokeStyle(lineWidth: 0.7)), strength: 0.9)
        let top = base * 0.58
        if !unfinished {
            // A crown of merlons, a turret, a spire.
            block(x, top + 3.4, 1.6, from: body)
            var merlons = Path()
            for step in stride(from: -top / 2 - 0.6, through: top / 2 + 0.6, by: (top + 1.2) / 4) {
                merlons.addPath(blockPath(x + step, 1.8, 2.6, from: body + 1.6))
            }
            add(merlons)
            block(x, top * 0.46, h * 0.08, from: body + 1.6)
            block(x, top * 0.46 + 1.6, 1.0, from: body + 1.6 + h * 0.08)
            spire(x, top * 0.44, from: body + 2.6 + h * 0.08, to: h)
            disc(x, body + 1.6 + h * 0.045, 0.9, .light)
        } else {
            // Left ragged, course by course, with the builders' scaffold still standing round it.
            shape([(x - top / 2, body - 0.5), (x - top / 2, body + 5), (x - top * 0.28, body + 5), (x - top * 0.28, body + 2.6),
                   (x - top * 0.04, body + 2.6), (x - top * 0.04, body + 4), (x + top * 0.20, body + 4), (x + top * 0.20, body + 1.4), (x + top / 2, body + 1.4), (x + top / 2, body - 0.5)])
            var poles = Path()
            let foot = h * 0.56, reach = top / 2 + 3.4
            for side in [-1.0, 1.0] as [CGFloat] {
                poles.addPath(strokePath([(x + side * reach, foot), (x + side * reach, h - (side > 0 ? 0 : 3))], 0.8))
                poles.addPath(strokePath([(x + side * (reach - 3.6), h * 0.74), (x + side * (reach - 3.6), h - 5)], 0.7))
            }
            for level in [0.60, 0.70, 0.80, 0.895] {
                poles.addPath(strokePath([(x - reach - 2, h * CGFloat(level)), (x + reach + 2, h * CGFloat(level))], 0.7))
            }
            poles.addPath(strokePath([(x - reach, h * 0.60), (x + reach, h * 0.70)], 0.6))
            poles.addPath(strokePath([(x + reach, h * 0.70), (x - reach, h * 0.80)], 0.6))
            poles.addPath(strokePath([(x - reach, h * 0.80), (x + reach, h * 0.895)], 0.6))
            // A hoist with its load, and a ladder at the foot.
            poles.addPath(strokePath([(x + reach - 2, h * 0.94), (x + reach + 9, h * 0.985)], 0.9))
            poles.addPath(strokePath([(x + reach + 8, h * 0.98), (x + reach + 8, h * 0.72)], 0.45))
            poles.addPath(blockPath(x + reach + 8, 4.4, 3, from: h * 0.72 - 3))
            let lx = x - base / 2 - 7
            poles.addPath(strokePath([(lx - 2, 0), (lx + 5.2, h * 0.30)], 0.7))
            poles.addPath(strokePath([(lx + 1.4, 0), (lx + 8.6, h * 0.30)], 0.7))
            for rung in stride(from: CGFloat(0.04), through: 0.27, by: 0.038) {
                poles.addPath(strokePath([(lx - 2 + 7.2 * rung / 0.30, h * rung), (lx + 1.4 + 7.2 * rung / 0.30, h * rung)], 0.6))
            }
            add(poles)
            // Bricks stacked ready at the foot.
            block(x + base / 2 + 6, 8, 2.4); block(x + base / 2 + 5.4, 5.4, 2, from: 2.4)
            detail(blockPath(x + base / 2 + 6, 7, 0.5, from: 1.1), strength: 0.7)
        }
    }

    /// A great dam holding water, with sluices running. Moves.
    mutating func dam(_ x: CGFloat, _ w: CGFloat, _ h: CGFloat) {
        // The rock it is built between.
        add(ridgePath([(x - w / 2 - 34, 0), (x - w / 2 - 26, h * 0.60), (x - w / 2 - 15, h * 1.10), (x - w / 2 - 4, h * 1.24), (x - w / 2 + 6, h * 1.06), (x - w / 2 + 10, 0)]))
        add(ridgePath([(x + w / 2 - 9, 0), (x + w / 2 - 5, h * 1.02), (x + w / 2 + 6, h * 1.16), (x + w / 2 + 17, h * 0.96), (x + w / 2 + 27, h * 0.50), (x + w / 2 + 36, 0)]))
        // The wall, leaning back as it rises, and the water standing at its lip.
        shape([(x - w / 2, 0), (x + w / 2, 0), (x + w / 2 - 2.5, h), (x - w / 2 + 2.5, h)])
        tint(blockPath(x, w - 9, 2.2, from: h - 0.2), shade(0.20, 0.50, 0.64, 0.92))
        for index in 0..<5 {
            let across = (Self.noise(index, 411) + time * 0.02).truncatingRemainder(dividingBy: 1)
            tint(blockPath(x - w * 0.42 + w * 0.84 * CGFloat(across), 7, 0.7, from: h + 0.9), Color.white.opacity(0.30 * sin(across * Double.pi) * (1 - 0.4 * night)))
        }
        // Courses of stone, and the buttresses standing out from the face.
        var stone = Path(), joints = Path()
        for level in stride(from: CGFloat(0.16), through: 0.86, by: 0.14) {
            stone.addPath(blockPath(x, w - 8, 0.6, from: h * level))
            // Short staggered joints on the upper courses keep the sluices clear.
            if level > 0.55 {
                let columns = max(2, Int((w - 12) / 11))
                for column in 0..<columns {
                    let stagger: CGFloat = Int(level * 100).isMultiple(of: 2) ? 0.5 : 0
                    let cx = x - (w - 12) / 2 + (w - 12) * (CGFloat(column) + 0.5 + stagger) / CGFloat(columns)
                    guard cx < x + (w - 12) / 2 else { continue }
                    joints.addPath(blockPath(cx, 0.36, h * 0.09, from: h * level + 0.4))
                }
            }
        }
        detail(stone, strength: 0.5)
        detail(joints, strength: 0.5)
        let sluices = max(2, Int(w / 46))
        for index in 0...sluices {
            let bx = x - w / 2 + w * CGFloat(index) / CGFloat(sluices)
            let lean: CGFloat = index == 0 ? 2 : index == sluices ? -2 : 0
            detail(polygon([(bx - 2.6 + lean, 0.5), (bx + 2.6 + lean, 0.5), (bx + 1.5 + lean * 1.6, h * 0.94), (bx - 1.5 + lean * 1.6, h * 0.94)]), strength: 0.4)
        }
        // The sluices, and the water they let go.
        tint(Path(ellipseIn: CGRect(x: point(x - w * 0.47, 0).x, y: point(0, 1.2).y, width: w * 0.94, height: 19)), shade(0.12, 0.38, 0.52, 0.90))
        for index in 0..<sluices {
            let sx = x - w / 2 + w * (CGFloat(index) + 0.5) / CGFloat(sluices), sill = h * 0.26
            tint(archPath(sx, 7.6, 9, from: sill, pointed: false), Color.black.opacity(0.46))
            detail(archPath(sx, 10, 10.6, from: sill - 0.4, pointed: false).strokedPath(StrokeStyle(lineWidth: 0.7)), strength: 0.9)
            var chute = Path()
            chute.move(to: point(sx - 3.2, sill + 2.6)); chute.addLine(to: point(sx + 3.2, sill + 2.6))
            chute.addQuadCurve(to: point(sx + 6.4, -2), control: point(sx + 5.2, sill * 0.7))
            chute.addLine(to: point(sx - 6.4, -2))
            chute.addQuadCurve(to: point(sx - 3.2, sill + 2.6), control: point(sx - 5.2, sill * 0.7))
            chute.closeSubpath()
            tint(chute, Color(red: 0.80, green: 0.92, blue: 0.98).opacity(0.52 * (1 - 0.35 * night)))
            for streak in 0..<4 {
                let fall = (Self.noise(index * 5 + streak, 413) + time * 0.55).truncatingRemainder(dividingBy: 1)
                let y = sill + 2 - CGFloat(fall * fall) * (sill + 3), wide = 2.4 + CGFloat(fall) * 3.2
                tint(blockPath(sx + (CGFloat(streak) - 1.5) * wide * 0.55, 0.8, 4.5, from: y - 4.5), Color.white.opacity(0.55 * (1 - fall * 0.5) * (1 - 0.35 * night)))
            }
            for puff in 0..<3 {
                let swell = 0.5 + 0.5 * sin(time * 1.6 + Double(puff) * 2.1 + Double(index))
                tint(discPath(sx + (CGFloat(puff) - 1) * 5.4, -1.6 + CGFloat(swell) * 1.4, 2.8 + CGFloat(swell) * 1.4), Color.white.opacity(0.26 * (1 - 0.35 * night)))
            }
        }
        for index in 0..<6 {
            let out = (Self.noise(index, 415) + time * 0.07).truncatingRemainder(dividingBy: 1)
            let y = -5 - CGFloat(out) * 11, half = w * (0.10 + 0.20 * CGFloat(out))
            let cx = x + (CGFloat(Self.noise(index, 417)) - 0.5) * w * 0.4
            tint(polygon([(cx - half, y), (cx, y + 0.5), (cx + half, y), (cx, y - 0.5)]), Color.white.opacity(0.20 * sin(out * Double.pi) * (1 - 0.4 * night)))
        }
    }

    /// A monumental gateway; gilded, its doors and crest shine.
    mutating func gate(_ x: CGFloat, _ h: CGFloat, gilded: Bool = false) {
        let w = h * 0.94, gold = shade(0.88, 0.68, 0.28)
        // Two towers leaning in as they rise, and the wall that carries the arch between them.
        for side in [-1.0, 1.0] as [CGFloat] {
            let tx = x + side * w * 0.37
            shape([(tx - w * 0.135, 0), (tx + w * 0.135, 0), (tx + w * 0.115, h * 0.88), (tx - w * 0.115, h * 0.88)])
            block(tx, w * 0.27, h * 0.03, from: h * 0.88)
            var merlons = Path()
            for step in [-0.105, -0.035, 0.035, 0.105] {
                merlons.addPath(polygon([(tx + (CGFloat(step) - 0.026) * w, h * 0.91), (tx + (CGFloat(step) + 0.026) * w, h * 0.91),
                                         (tx + (CGFloat(step) + 0.026) * w, h * 0.96), (tx + CGFloat(step) * w, h), (tx + (CGFloat(step) - 0.026) * w, h * 0.96)]))
            }
            add(merlons)
            if gilded { tint(merlons, gold.opacity(0.85)) }
            detail(blockPath(tx - w * 0.085, w * 0.03, h * 0.80, from: h * 0.04), strength: 0.8)
            detail(blockPath(tx, w * 0.24, h * 0.012, from: h * 0.62), strength: 0.9)
            detail(blockPath(tx, w * 0.25, h * 0.012, from: h * 0.30), strength: 0.8)
            var mortar = Path()
            for level in [0.14, 0.24, 0.52, 0.82] as [CGFloat] {
                mortar.addPath(blockPath(tx, w * 0.20, max(0.3, h * 0.006), from: h * level))
                for offset in [-0.065, 0.03] as [CGFloat] {
                    mortar.addPath(blockPath(tx + offset * w, max(0.25, w * 0.006), h * 0.035, from: h * level))
                }
            }
            detail(mortar, strength: 0.60)
            tint(blockPath(tx, w * 0.034, h * 0.09, from: h * 0.70), Color.black.opacity(0.32))
            block(tx, w * 0.020, h * 0.07, from: h * 0.71, .light)
            tint(blockPath(tx, w * 0.034, h * 0.09, from: h * 0.40), Color.black.opacity(0.32))
            block(tx, w * 0.020, h * 0.07, from: h * 0.41, .light)
        }
        block(x, w * 0.52, h * 0.76)
        block(x, w * 0.56, h * 0.028, from: h * 0.76)
        // The crest over the arch: stepped, with a boss at its head.
        let crest: [Spot] = [(x - w * 0.20, h * 0.788), (x + w * 0.20, h * 0.788), (x + w * 0.20, h * 0.83), (x + w * 0.12, h * 0.83), (x + w * 0.12, h * 0.87),
                             (x + w * 0.05, h * 0.87), (x, h * 0.93), (x - w * 0.05, h * 0.87), (x - w * 0.12, h * 0.87), (x - w * 0.12, h * 0.83), (x - w * 0.20, h * 0.83)]
        shape(crest)
        // The frame round the arch, and a band of small niches above it.
        let opening = archPath(x, w * 0.30, h * 0.58, pointed: true)
        detail(blockPath(x, w * 0.42, h * 0.012, from: h * 0.66), strength: 1.0)
        detail(blockPath(x - w * 0.20, w * 0.012, h * 0.64, from: h * 0.02), strength: 0.9)
        detail(blockPath(x + w * 0.20, w * 0.012, h * 0.64, from: h * 0.02), strength: 0.9)
        detail(archPath(x, w * 0.36, h * 0.625, pointed: true).strokedPath(StrokeStyle(lineWidth: max(0.7, h * 0.012))), strength: 0.9)
        var niches = Path()
        for step in stride(from: CGFloat(-0.16), through: 0.16, by: 0.064) { niches.addPath(archPath(x + step * w, w * 0.034, h * 0.05, from: h * 0.69, pointed: true)) }
        detail(niches, strength: 1.0)
        if gilded {
            // Closed doors of gold: panels, studs, and light sliding over them.
            add(opening)
            tint(opening, gold)
            var marks = Path(), studs = Path()
            marks.addPath(blockPath(x, max(0.6, w * 0.010), h * 0.57, from: 0))
            for level in [0.12, 0.27, 0.40] { marks.addPath(blockPath(x, w * 0.29, max(0.5, h * 0.008), from: h * CGFloat(level))) }
            for level in [0.06, 0.195, 0.335] {
                for column in [-0.105, -0.045, 0.045, 0.105] { studs.addPath(discPath(x + CGFloat(column) * w, h * CGFloat(level), max(0.6, h * 0.011))) }
            }
            tint(marks, Color.black.opacity(0.30))
            tint(studs, Color(red: 1.0, green: 0.90, blue: 0.60).opacity(0.85))
            let sheen = CGFloat((time * 0.12).truncatingRemainder(dividingBy: 1))
            let sx = x - w * 0.13 + w * 0.26 * sheen
            tint(polygon([(sx - w * 0.02, h * 0.02), (sx + w * 0.02, h * 0.02), (sx + w * 0.05, h * 0.38), (sx + w * 0.01, h * 0.38)]),
                 Color.white.opacity(0.20 * sin(Double(sheen) * Double.pi)))
            tint(polygon(crest), gold.opacity(0.9))
            tint(discPath(x, h * 0.845, h * 0.022), Color(red: 1.0, green: 0.92, blue: 0.66).opacity(0.9))
            tint(opening, Color(red: 1.0, green: 0.80, blue: 0.40).opacity(0.22), nightOnly: true)
            glow(x, h * 0.30, h * 0.46, Color(red: 1.0, green: 0.80, blue: 0.40), 0.16, nightOnly: true)
        } else {
            // Standing open: the way through, and the leaves of the door folded back inside it.
            add(opening, .hole)
            tint(polygon([(x - w * 0.15, 0), (x - w * 0.105, 0), (x - w * 0.105, h * 0.44), (x - w * 0.15, h * 0.40)]), Color.black.opacity(0.42))
            tint(polygon([(x + w * 0.15, 0), (x + w * 0.105, 0), (x + w * 0.105, h * 0.44), (x + w * 0.15, h * 0.40)]), Color.black.opacity(0.42))
            detail(discPath(x, h * 0.845, h * 0.022), strength: 1.2)
        }
    }

    /// A wall of fitted stone, course on course.
    mutating func stoneWall(_ x: CGFloat, _ w: CGFloat, _ h: CGFloat) {
        let rows = max(2, Int((h / 6.2).rounded())), rise = h / CGFloat(rows)
        let left = x - w / 2, seed = Int(x.rounded()) + Int(w)
        // The wall leans in a little; its top course is unfinished at one end.
        shape([(left - 1.6, 0), (left + w + 1.6, 0), (left + w, h - rise), (left + w - w * 0.16, h - rise), (left + w - w * 0.16, h), (left, h)])
        var joints = Path(), faces = Path(), caps = Path(), weather = Path()
        for row in 0..<rows {
            let y = CGFloat(row) * rise
            let inset = 1.6 * (1 - (y + rise / 2) / h)
            let end = left + w - (row == rows - 1 ? w * 0.16 : 0) + inset * 0
            if row > 0 { joints.addPath(blockPath((left + end) / 2, end - left - 1.5, 0.55, from: y - 0.28)) }
            var px = left + CGFloat(Self.noise(seed + row, 421)) * 8 + 3, stone = 0
            while px < end - 3 {
                joints.addPath(blockPath(px, 0.55, rise - 0.5, from: y + 0.25))
                let long = 7 + CGFloat(Self.noise(seed + row * 31 + stone, 423)) * 8
                if Self.noise(seed + row * 31 + stone, 425) > 0.74, px + long < end - 1 {
                    faces.addPath(blockPath(px + long / 2, long - 1.2, rise - 1.3, from: y + 0.65))
                }
                if Self.noise(seed + row * 31 + stone, 426) > 0.6, px + long < end - 1 {
                    weather.addPath(strokePath([(px + 1.4, y + rise * 0.58),
                                                (px + min(long - 1.4, 4.2), y + rise * 0.50)], 0.32))
                }
                px += long; stone += 1
            }
        }
        // Capstones standing a little proud along the top.
        var px = left + 2, stone = 0
        while px < left + w - w * 0.16 - 6 {
            let long = 8 + CGFloat(Self.noise(seed + stone, 427)) * 7
            if stone % 2 == 0 { caps.addPath(blockPath(px + long / 2, long - 1, 1.3, from: h)) }
            px += long; stone += 1
        }
        add(caps)
        detail(joints, strength: 0.46)
        detail(faces, strength: 0.32)
        tint(weather, Color.black.opacity(0.19))
    }

    /// A defensive ditch dug across the ground, earth heaped on its near side.
    mutating func trench(from left: CGFloat, to right: CGFloat) {
        let span = max(1, right - left)
        func bend(_ part: CGFloat) -> CGFloat { CGFloat(sin(Double(part) * 5.2 + Double(left) * 0.01)) * 1.6 }
        // The cut: deep and dark, its far wall and lip catching the light; it bends as it was dug in lengths.
        var far: [Spot] = [], near: [Spot] = [], wall: [Spot] = [], lip: [Spot] = []
        let steps = max(4, Int(span / 22))
        for step in 0...steps {
            let part = CGFloat(step) / CGFloat(steps), px = left + span * part
            far.append((px, -3.5 + bend(part))); near.append((px, -15 + bend(part) * 1.3))
            wall.append((px, -7.5 + bend(part) * 1.05)); lip.append((px, -2.3 + bend(part)))
        }
        tint(polygon(far + near.reversed()), Color.black.opacity(0.78))
        tint(polygon(far + wall.reversed()), shade(0.62, 0.52, 0.38, 0.62))
        tint(polygon(lip + far.reversed()), shade(0.94, 0.84, 0.64, 0.60))
        var cutMarks = Path()
        for step in 0..<steps {
            let part = (CGFloat(step) + 0.45) / CGFloat(steps), px = left + span * part
            cutMarks.addPath(strokePath([(px - 1.6, -4.3 + bend(part)),
                                         (px + 1.2, -6.5 + bend(part))], 0.55))
        }
        tint(cutMarks, shade(0.36, 0.29, 0.22, 0.40))
        // The spoil thrown up along the near side: heap after heap of pale earth, light on each one's shoulder.
        var heaps = Path(), light = Path(), brows = Path(), stones = Path()
        var px = left - 4, index = 0
        while px < right + 4 {
            let wide = 17 + CGFloat(Self.noise(index, 431)) * 14, high = 8.5 + CGFloat(Self.noise(index, 433)) * 6
            let part = min(1, max(0, (px + wide / 2 - left) / span))
            let foot = -15 + bend(part) * 1.3 - 5
            let crest: [Spot] = [(px - 2, foot), (px + wide * 0.22, foot + high * 0.74), (px + wide * 0.46, foot + high), (px + wide * 0.72, foot + high * 0.66), (px + wide + 2, foot)]
            heaps.addPath(ridgePath(crest, base: foot - 3))
            light.addPath(polygon([(px + wide * 0.08, foot + high * 0.30), (px + wide * 0.44, foot + high * 0.97), (px + wide * 0.52, foot + high * 0.78), (px + wide * 0.24, foot + high * 0.24)]))
            brows.addPath(strokePath(Array(crest[1...3]), 0.8, smooth: true))
            if index % 2 == 0 { stones.addPath(discPath(px + wide * 0.84, foot + 0.8, 1.3)); stones.addPath(discPath(px + wide * 0.60, foot - 1.4, 0.9)) }
            px += wide * 0.72; index += 1
        }
        tint(heaps, shade(0.64, 0.52, 0.36, 0.97))
        tint(light, shade(0.90, 0.78, 0.56, 0.58))
        tint(brows, shade(1.0, 0.92, 0.74, 0.55))
        tint(stones, shade(0.40, 0.34, 0.27, 0.9))
        // A pick and a spade left standing in the spoil.
        let tx = left + span * 0.62
        tint(strokePath([(tx, -14), (tx + 3.6, 2)], 1.0), shade(0.46, 0.36, 0.24))
        tint(polygon([(tx + 2.2, 0.4), (tx + 5.8, 0.8), (tx + 5.2, 5.4), (tx + 2.8, 4.6)]), shade(0.62, 0.63, 0.66))
        tint(strokePath([(tx + 12.6, -15), (tx + 9.6, 1)], 1.0), shade(0.46, 0.36, 0.24))
        tint(strokePath([(tx + 5.0, -0.6), (tx + 9.6, 1.4), (tx + 14.4, -1.2)], 1.2, smooth: true), shade(0.62, 0.63, 0.66))
    }

    /// Steps climbing out of the scene into the sky, light moving up them. Moves.
    mutating func stairway(_ x: CGFloat, steps: Int = 14, rise: CGFloat = 150) {
        let count = max(3, steps)
        block(x, 74, 2.2)
        tint(discPath(x, rise + 4, 22), Color.white.opacity(0.05))
        tint(discPath(x, rise + 4, 11), Color.white.opacity(0.09))
        let pulse = (time * 0.085).truncatingRemainder(dividingBy: 1) * Double(count + 5) - 2.5
        let second = (time * 0.085 + 0.5).truncatingRemainder(dividingBy: 1) * Double(count + 5) - 2.5
        for step in 0..<count {
            // Far steps are narrower and closer together, and fade into the sky.
            let part = CGFloat(step) / CGFloat(count - 1)
            let y = 2.2 + (rise - 2.2) * (1 - CGFloat(pow(Double(1 - part), 1.55)))
            let wide = 6 + 60 * CGFloat(pow(Double(1 - part), 1.25)), thick = 1.0 + 4.4 * (1 - part)
            let seen = 0.96 - 0.72 * Double(part)
            tint(blockPath(x, wide, thick, from: y), shade(0.60, 0.56, 0.50, seen))
            tint(blockPath(x, wide, thick * 0.34, from: y + thick * 0.66), shade(0.90, 0.86, 0.74, seen))
            tint(polygon([(x - wide / 2, y), (x - wide / 2, y + thick), (x - wide / 2 + thick * 0.5, y + thick)]), Color.black.opacity(0.18 * seen))
            // A small lip on the tread retains the perspective of each step.
            tint(blockPath(x, max(1, wide - 2), max(0.20, thick * 0.10), from: y + thick * 0.48),
                 Color.white.opacity(0.12 * seen))
            let lit = exp(-pow(Double(step) - pulse, 2) / 3.2) + exp(-pow(Double(step) - second, 2) / 3.2)
            if lit > 0.02 {
                tint(blockPath(x, wide, thick, from: y), Color(red: 1.0, green: 0.94, blue: 0.74).opacity(min(1, lit) * (0.55 + 0.25 * Double(part))))
                tint(Path(ellipseIn: CGRect(x: point(x - wide * 0.7, 0).x, y: point(0, y + thick + 3).y, width: wide * 1.4, height: thick + 6)),
                     Color(red: 1.0, green: 0.94, blue: 0.74).opacity(min(1, lit) * 0.10))
            }
        }
    }

    /// Rows of white pilgrim tents, lamplit after dark.
    mutating func tentCamp(_ x: CGFloat, count: Int = 9) {
        let total = max(1, count), far = total / 2, near = total - far
        let rows: [(Int, CGFloat, CGFloat, CGFloat, (Double, Double, Double))] = [
            (far, 0, 0.80, 17.5, (0.80, 0.81, 0.80)), (near, -5.5, 1.0, 21.5, (0.95, 0.93, 0.87))
        ]
        for row in rows where row.0 > 0 {
            var cloth = Path(), shadow = Path(), doors = Path(), glow = Path(), seams = Path(), knobs = Path(), folds = Path()
            for index in 0..<row.0 {
                let cx = x + (CGFloat(index) - CGFloat(row.0 - 1) / 2) * row.3
                let w = 17 * row.2, h = 15.5 * row.2, wall = h * 0.40, base = row.1
                var tent = Path()
                tent.move(to: point(cx - w / 2, base)); tent.addLine(to: point(cx - w / 2, base + wall))
                tent.addQuadCurve(to: point(cx, base + h), control: point(cx - w * 0.16, base + wall + (h - wall) * 0.34))
                tent.addQuadCurve(to: point(cx + w / 2, base + wall), control: point(cx + w * 0.16, base + wall + (h - wall) * 0.34))
                tent.addLine(to: point(cx + w / 2, base)); tent.closeSubpath()
                cloth.addPath(tent); glow.addPath(tent)
                var side = Path()
                side.move(to: point(cx + w * 0.16, base)); side.addLine(to: point(cx + w * 0.16, base + wall))
                side.addQuadCurve(to: point(cx, base + h), control: point(cx + w * 0.07, base + wall + (h - wall) * 0.4))
                side.addQuadCurve(to: point(cx + w / 2, base + wall), control: point(cx + w * 0.16, base + wall + (h - wall) * 0.34))
                side.addLine(to: point(cx + w / 2, base)); side.closeSubpath()
                shadow.addPath(side)
                seams.addPath(blockPath(cx - w * 0.17, w * 0.66, 0.5, from: base + wall - 0.2))
                folds.addPath(strokePath([(cx - w * 0.28, base + wall + 0.6), (cx - w * 0.12, base + h * 0.72),
                                           (cx, base + h - 0.8)], 0.32 * row.2, smooth: true))
                folds.addPath(strokePath([(cx + w * 0.30, base + wall + 0.6), (cx + w * 0.12, base + h * 0.72),
                                           (cx, base + h - 0.8)], 0.32 * row.2, smooth: true))
                doors.addPath(polygon([(cx - w * 0.30, base), (cx - w * 0.10, base), (cx - w * 0.17, base + wall * 0.84), (cx - w * 0.23, base + wall * 0.84)]))
                knobs.addPath(discPath(cx, base + h + 0.7, 0.9 * row.2))
            }
            tint(cloth, shade(row.4))
            tint(shadow, Color.black.opacity(0.13))
            tint(seams, Color.black.opacity(0.16))
            tint(folds, Color.black.opacity(0.12))
            tint(knobs, shade(row.4))
            tint(doors, Color.black.opacity(0.40))
            tint(glow, Self.lampLight.opacity(0.26), nightOnly: true)
            tint(doors, Self.lampLight.opacity(0.9), nightOnly: true)
        }
    }

    /// Lamps on posts along a road, flickering, lit at night. Moves.
    mutating func lampLine(from left: CGFloat, to right: CGFloat, count: Int = 7) {
        let total = max(1, count), h: CGFloat = 25
        for index in 0..<total {
            let px = total > 1 ? left + (right - left) * CGFloat(index) / CGFloat(total - 1) : (left + right) / 2
            // The post, its foot and collar, and the arm the lantern hangs from.
            shape([(px - 1.7, 0), (px + 1.7, 0), (px + 1.0, 2.2), (px + 0.6, h - 6), (px - 0.6, h - 6), (px - 1.0, 2.2)])
            block(px, 2.4, 0.9, from: h * 0.40)
            detail(blockPath(px - 0.3, 0.35, h * 0.48, from: 2.2), strength: 0.55)
            detail(blockPath(px, 2.5, 0.4, from: 2.4), strength: 0.8)
            line([(px, h - 6.5), (px + 0.4, h - 0.6), (px + 3.2, h + 1.2), (px + 5.6, h - 0.8)], 0.9, smooth: true)
            line([(px, h - 7), (px - 0.2, h - 2.6), (px - 2.4, h - 1.8)], 0.7, smooth: true)
            smallLantern(px + 5.6, top: h - 1, scale: 1, flame: flicker(Double(index) * 1.9))
        }
    }

    /// A furnace and its chimney: glow, smoke and sparks. Moves.
    mutating func forge(_ x: CGFloat) {
        let burn = flicker(0.7)
        // The hearth, its hood and the chimney.
        shape([(x - 20, 0), (x + 16, 0), (x + 14, 20), (x - 18, 20)])
        block(x - 2, 35, 1.8, from: 20)
        shape([(x - 16, 21.8), (x + 12, 21.8), (x + 1, 32), (x - 9.5, 32)])
        shape([(x - 9.2, 32), (x + 0.8, 32), (x - 1.0, 59), (x - 7.4, 59)])
        block(x - 4.2, 9, 1.6, from: 59)
        block(x - 4.2, 6.6, 1.4, from: 60.6)
        var bricks = Path()
        for level in [5.0, 10.0, 15.0] as [CGFloat] { bricks.addPath(blockPath(x - 2, 33 - level * 0.1, 0.55, from: level)) }
        for level in stride(from: CGFloat(37), through: 55, by: 6) { bricks.addPath(blockPath(x - 4.2, 7.6 - (level - 37) * 0.07, 0.55, from: level)) }
        detail(bricks, strength: 0.6)
        var joints = Path()
        for level in [5.0, 10.0, 15.0] as [CGFloat] {
            for side in [-1.0, 1.0] as [CGFloat] {
                // Work around the central furnace mouth, not across it.
                joints.addPath(blockPath(x - 2 + side * 13, 0.42, 3.2, from: level + 0.4))
            }
        }
        detail(joints, strength: 0.52)
        detail(polygon([(x - 15, 22.4), (x - 12.6, 22.4), (x - 7.4, 31.4), (x - 8.6, 31.4)]), strength: 0.7)
        // The fire in its mouth.
        let mouth = archPath(x - 2, 14, 13, from: 3, pointed: false)
        tint(mouth, Color(red: 0.42, green: 0.10, blue: 0.04))
        glow(x - 2, 9, 20, Color(red: 1.0, green: 0.56, blue: 0.20), 0.16 * burn)
        glow(x - 2, 9, 34, Color(red: 1.0, green: 0.56, blue: 0.20), 0.14 * burn, nightOnly: true)
        let lick = CGFloat(sin(time * 5.1)) * 1.2
        tint(flamePath(x - 4.4, 3.4, width: 6.4, height: 9.4 + lick * 0.6, lean: lick * 0.5), Color(red: 1.0, green: 0.48, blue: 0.14).opacity(0.95))
        tint(flamePath(x + 1.2, 3.4, width: 6.4, height: 8.2 - lick * 0.5, lean: -lick * 0.5), Color(red: 1.0, green: 0.48, blue: 0.14).opacity(0.95))
        tint(flamePath(x - 1.8, 3.4, width: 5.4, height: 6.8 + lick * 0.4, lean: lick * 0.3), Color(red: 1.0, green: 0.80, blue: 0.38))
        tint(blockPath(x - 2, 12.6, 1.4, from: 3), Color(red: 1.0, green: 0.66, blue: 0.26).opacity(0.9 * burn))
        detail(archPath(x - 2, 16.6, 14.6, from: 2.6, pointed: false).strokedPath(StrokeStyle(lineWidth: 0.8)), strength: 1.0)
        // The anvil on its block, a bar of iron glowing across it, and the quenching trough.
        let ax: CGFloat = x + 31
        block(ax, 8, 6.4)
        shape([(ax - 3, 6.4), (ax + 3, 6.4), (ax + 2, 9.6), (ax - 2, 9.6)])
        shape([(ax - 6, 9.6), (ax + 5, 9.6), (ax + 11.5, 11.6), (ax + 5, 12.8), (ax - 6, 12.8)])
        tint(polygon([(ax - 4, 12.8), (ax + 7, 12.8), (ax + 7, 13.7), (ax - 4, 13.7)]), Color(red: 1.0, green: 0.56, blue: 0.20).opacity(0.75 + 0.2 * burn))
        shape([(x - 34, 0), (x - 24, 0), (x - 24.6, 5.4), (x - 33.4, 5.4)])
        tint(blockPath(x - 29, 7.6, 0.9, from: 4.4), shade(0.24, 0.50, 0.62, 0.8))
        // Sparks from the mouth, and smoke leaning away from the chimney.
        for index in 0..<8 {
            let rise = (Self.noise(index, 441) + time * 0.42).truncatingRemainder(dividingBy: 1)
            tint(discPath(x - 2 + (CGFloat(Self.noise(index, 443)) - 0.5) * 12 + CGFloat(rise) * 6, 12 + CGFloat(rise) * 26, 0.7),
                 Color(red: 1.0, green: 0.74, blue: 0.36).opacity(0.9 * (1 - rise)))
        }
        for index in 0..<8 {
            let rise = (Double(index) / 8 + time * 0.06).truncatingRemainder(dividingBy: 1)
            let px = x - 4.2 + CGFloat(rise) * 16 + CGFloat(sin(time * 0.6 + rise * 5)) * 2
            tint(discPath(px, 63 + CGFloat(rise) * 34, 2.4 + CGFloat(rise) * 6), Color(red: 0.42, green: 0.41, blue: 0.44).opacity(0.26 * (1 - rise)))
        }
    }

    /// Low rounded headstones on a slope.
    mutating func graves(from left: CGFloat, to right: CGFloat, count: Int = 9) {
        let span = max(1, right - left), total = max(1, count)
        func ground(_ px: CGFloat) -> CGFloat {
            let part = min(1.15, max(-0.1, (px - left) / span))
            return 2 + 15 * part * part * (3 - 2 * min(1, part)) * (part > 1 ? max(0, 1 - (part - 1) * 5) : 1)
        }
        var slope: [Spot] = [(left - 22, 0)]
        for step in 0...12 { let px = left - 8 + (span + 16) * CGFloat(step) / 12; slope.append((px, ground(px))) }
        slope.append((right + 30, 0))
        add(ridgePath(slope))
        // The slope's pale earth, lightest along its brow.
        tint(ridgePath(slope), shade(0.56, 0.50, 0.40, 0.30))
        tint(strokePath(Array(slope.dropFirst().dropLast()), 1.0, smooth: true), shade(0.92, 0.86, 0.72, 0.42))
        var stones = Path(), faces = Path(), rims = Path(), mounds = Path(), tufts = Path(), weathering = Path()
        for index in 0..<total {
            let px = left + span * (CGFloat(index) + 0.5 + (CGFloat(Self.noise(index, 451)) - 0.5) * 0.5) / CGFloat(total)
            let foot = ground(px) - 1.2
            let lean = (Self.noise(index, 453) - 0.5) * 0.22
            if index % 4 == 2 {
                // An unshaped stone, set on end.
                let rough: [Spot] = [(px - 3.0, foot), (px - 3.6, foot + 4.4), (px - 0.8, foot + 8.6), (px + 2.6, foot + 7.0), (px + 3.4, foot + 2.4), (px + 2.8, foot)]
                stones.addPath(smoothPath(rough))
                faces.addPath(smoothPath(rough))
                rims.addPath(strokePath([(px - 3.2, foot + 1.5), (px - 3.3, foot + 4.4), (px - 0.9, foot + 8.0)], 0.7, smooth: true))
                continue
            }
            let w = 5.6 + CGFloat(Self.noise(index, 455)) * 2.4, h = 11 + CGFloat(Self.noise(index, 457)) * 6
            var slab: [Spot] = [(px - w / 2, foot)]
            for step in 0...8 {
                let angle = Double.pi - Double(step) / 8 * Double.pi
                slab.append((px + CGFloat(cos(angle)) * w / 2, foot + h - w / 2 + CGFloat(sin(angle)) * w / 2))
            }
            slab.append((px + w / 2, foot))
            let standing = slab.map { turn($0, about: (px, foot), by: lean) }
            stones.addPath(polygon(standing))
            faces.addPath(polygon(standing))
            let marks = [(px - w * 0.16, foot + h * 0.48), (px + w * 0.08, foot + h * 0.43)]
                .map { turn($0, about: (px, foot), by: lean) }
            weathering.addPath(strokePath(marks, 0.4))
            // Light on the stone's near edge and over its rounded head.
            rims.addPath(strokePath(Array(standing.prefix(7)), 0.8))
            // The low mound of the grave before it, and grass at its foot.
            mounds.addPath(ridgePath([(px + 1.5, foot + 0.6), (px + 5.5, foot + 3.6), (px + 11, foot + 3.2), (px + 14, foot + 0.4)], base: foot - 1))
            if index % 2 == 0 {
                tufts.addPath(polygon([(px - w / 2 - 1.6, foot + 0.6), (px - w / 2 - 0.8, foot + 0.6), (px - w / 2 - 2.8, foot + 4.2)]))
                tufts.addPath(polygon([(px - w / 2 - 1.2, foot + 0.6), (px - w / 2 - 0.4, foot + 0.6), (px - w / 2 - 0.4, foot + 5.0)]))
            }
        }
        add(stones)
        add(mounds)
        add(tufts)
        tint(mounds, shade(0.62, 0.54, 0.42, 0.50))
        tint(faces, shade(0.70, 0.69, 0.66, 0.46))
        tint(rims, shade(0.96, 0.94, 0.88, 0.62))
        tint(weathering, Color.black.opacity(0.18))
    }

    /// A wall with one closed arched door, a lamp beside it.
    mutating func door(_ x: CGFloat, _ h: CGFloat = 34) {
        let wide = h * 2.2, tall = h * 1.42, u = h / 34
        // The wall, its coping, and a course line under it.
        block(x, wide, tall)
        block(x, wide + 3 * u, 1.6 * u, from: tall)
        block(x, wide - 6 * u, 1.2 * u, from: tall + 1.6 * u)
        detail(blockPath(x, wide - 3 * u, 0.7 * u, from: tall - 3.4 * u), strength: 0.7)
        detail(blockPath(x, wide - 3 * u, 0.7 * u, from: 3 * u), strength: 0.5)
        // Masonry courses flank the doorway without crossing its frame.
        var wallCourses = Path()
        for side in [-1.0, 1.0] as [CGFloat] {
            for level in [0.20, 0.42, 0.64, 0.86, 1.16] as [CGFloat] {
                let center = x + side * h * 0.78
                wallCourses.addPath(blockPath(center, h * 0.55, 0.4 * u, from: h * level))
                let shifted: CGFloat = level < 1 ? (Int(level * 100).isMultiple(of: 4) ? 0.68 : 0.88) : 0.78
                wallCourses.addPath(blockPath(x + side * h * shifted, 0.35 * u, h * 0.08, from: h * level))
            }
        }
        detail(wallCourses, strength: 0.45)
        block(x, h * 0.92, 1.5 * u)
        // The door in its stone frame: boards, iron bands, studs and a ring.
        let leaf = archPath(x, h * 0.58, h, from: 1.5 * u, pointed: true)
        detail(archPath(x, h * 0.74, h * 1.09, from: 1.5 * u, pointed: true).strokedPath(StrokeStyle(lineWidth: 1.6 * u)), strength: 1.0)
        tint(leaf, shade(0.36, 0.23, 0.13))
        var boards = Path(), bands = Path(), studs = Path()
        for board in [-0.19, -0.095, 0.0, 0.095, 0.19] { boards.addPath(blockPath(x + CGFloat(board) * h, 0.5 * u, h * 0.86, from: 1.5 * u)) }
        for level in [0.20, 0.52] {
            bands.addPath(blockPath(x, h * 0.57, 1.5 * u, from: h * CGFloat(level)))
            for stud in [-0.22, -0.11, 0.11, 0.22] { studs.addPath(discPath(x + CGFloat(stud) * h, h * CGFloat(level) + 0.75 * u, 0.6 * u)) }
        }
        tint(boards, Color.black.opacity(0.30))
        tint(bands, Color.black.opacity(0.38))
        tint(studs, shade(0.78, 0.66, 0.44))
        tint(discPath(x + h * 0.06, h * 0.40, 1.5 * u).strokedPath(StrokeStyle(lineWidth: 0.6 * u)), shade(0.80, 0.68, 0.44))
        // The lamp on its bracket, and its light on the door after dark.
        let lx = x + h * 0.62, ly = h * 0.98, burn = flicker(Double(x) * 0.1)
        line([(lx + 4 * u, ly + 0.5 * u), (lx + 2.8 * u, ly + 3.4 * u), (lx, ly + 2.2 * u), (lx, ly)], 0.9 * u, smooth: true)
        glow(lx, ly - 5 * u, 24 * u, Self.lampLight, 0.16 * burn, nightOnly: true)
        tint(leaf, Self.lampLight.opacity(0.12 * burn), nightOnly: true)
        smallLantern(lx, top: ly, scale: 1.25 * u, flame: burn)
    }

    /// A small prayer place: a mihrab wall with a lamp and a mat. Flame moves.
    mutating func prayerNiche(_ x: CGFloat, scale s: CGFloat = 1) {
        // The wall, raised over the niche and crowned with three merlons.
        block(x, 48 * s, 43 * s)
        block(x, 51 * s, 1.5 * s, from: 43 * s)
        block(x, 27 * s, 5 * s, from: 44.5 * s)
        block(x, 29 * s, 1.2 * s, from: 49.5 * s)
        for step in [-9.0, 0.0, 9.0] as [CGFloat] {
            shape([(x + (step - 2.6) * s, 50.7 * s), (x + (step + 2.6) * s, 50.7 * s), (x + (step + 2.6) * s, 52.6 * s), (x + step * s, 55 * s), (x + (step - 2.6) * s, 52.6 * s)])
        }
        // The niche: a deeper arch within an arch, slender columns at its sides, a frame about it.
        tint(archPath(x, 21 * s, 35 * s, from: 2 * s, pointed: true), Color.black.opacity(0.30))
        tint(archPath(x, 14.5 * s, 28 * s, from: 2 * s, pointed: true), Color.black.opacity(0.26))
        detail(archPath(x, 21 * s, 35 * s, from: 2 * s, pointed: true).strokedPath(StrokeStyle(lineWidth: 0.8 * s)), strength: 1.0)
        for side in [-1.0, 1.0] as [CGFloat] {
            detail(blockPath(x + side * 12.6 * s, 1.5 * s, 19 * s, from: 2 * s), strength: 1.0)
            detail(blockPath(x + side * 12.6 * s, 2.6 * s, 1.0 * s, from: 21 * s), strength: 1.1)
            detail(blockPath(x + side * 17 * s, 0.7 * s, 38 * s, from: 2 * s), strength: 0.7)
        }
        detail(blockPath(x, 34.7 * s, 0.7 * s, from: 40 * s), strength: 0.7)
        var border = Path()
        for side in [-1.0, 1.0] as [CGFloat] {
            for level in stride(from: CGFloat(4), through: 37, by: 4.4) {
                let px = x + side * 19.5 * s
                border.addPath(polygon([(px, level * s), (px + 0.8 * s, (level + 1.2) * s),
                                        (px, (level + 2.4) * s), (px - 0.8 * s, (level + 1.2) * s)]))
            }
        }
        tint(border, shade(0.83, 0.72, 0.50, 0.43))
        block(x, 52 * s, 1.6 * s)
        // The lamp hung in it, alight at every hour.
        let burn = flicker(Double(x) * 0.07)
        tint(blockPath(x, 0.5 * s, 9 * s, from: 26 * s), shade(0.80, 0.66, 0.40, 0.9))
        glow(x, 21.5 * s, 16 * s, Self.lampLight, 0.42 * burn * (0.55 + 0.45 * night))
        tint(smoothPath([(x - 1.6 * s, 26 * s), (x + 1.6 * s, 26 * s), (x + 3.4 * s, 22 * s), (x + 2.0 * s, 18.4 * s), (x - 2.0 * s, 18.4 * s), (x - 3.4 * s, 22 * s)]),
             Self.lampLight.opacity(0.50 + 0.45 * burn))
        tint(blockPath(x, 4.2 * s, 0.9 * s, from: 25.8 * s), shade(0.74, 0.58, 0.30))
        tint(blockPath(x, 3.4 * s, 0.9 * s, from: 17.6 * s), shade(0.74, 0.58, 0.30))
        disc(x, 21.6 * s, 1.3 * s, .light)
        // The mat laid before it.
        let rug: [Spot] = [(x - 9.5 * s, -3 * s), (x + 9.5 * s, -3 * s), (x + 13.5 * s, -18 * s), (x - 13.5 * s, -18 * s)]
        tint(polygon(rug), shade(0.50, 0.17, 0.16, 0.95))
        tint(polygon([(x - 8.2 * s, -4.4 * s), (x + 8.2 * s, -4.4 * s), (x + 11.6 * s, -16.4 * s), (x - 11.6 * s, -16.4 * s)])
            .strokedPath(StrokeStyle(lineWidth: 0.7 * s)), shade(0.86, 0.70, 0.40, 0.8))
        var motif = Path()
        motif.move(to: point(x - 5.2 * s, -15 * s)); motif.addLine(to: point(x - 4.2 * s, -8.6 * s))
        motif.addQuadCurve(to: point(x, -5.4 * s), control: point(x - 3.8 * s, -6.2 * s))
        motif.addQuadCurve(to: point(x + 4.2 * s, -8.6 * s), control: point(x + 3.8 * s, -6.2 * s))
        motif.addLine(to: point(x + 5.2 * s, -15 * s)); motif.closeSubpath()
        tint(motif, shade(0.66, 0.30, 0.22, 0.9))
        var fringe = Path()
        for tassel in stride(from: CGFloat(-13), through: 13, by: 2) { fringe.addPath(blockPath(x + tassel * s, 0.5 * s, 1.6 * s, from: -19.6 * s)) }
        tint(fringe, shade(0.86, 0.78, 0.60, 0.8))
    }

    /// Broken walls and a fallen arch, sand against them.
    mutating func ruins(_ x: CGFloat, scale s: CGFloat = 1) {
        func at(_ dx: CGFloat, _ dy: CGFloat) -> Spot { (x + dx * s, dy * s) }
        // A corner of wall still standing to its full height, stepping down where the rest fell.
        shape([at(-56, 0), at(-55, 50), at(-51, 50), at(-51, 46), at(-46.5, 46), at(-46.5, 39), at(-42, 39), at(-42, 31), at(-37, 31), at(-37, 26),
               at(-33, 26), at(-33, 17), at(-27, 17), at(-27, 11), at(-22, 11), at(-22, 0)])
        arch(x - 48.6 * s, 4.4 * s, 9.5 * s, from: 26 * s, pointed: true)
        tint(archPath(x - 40 * s, 4 * s, 8 * s, from: 12 * s, pointed: true), Color.black.opacity(0.30))
        var courses = Path()
        for (level, wide, centre) in [(7.0, 30.0, -39.0), (14.0, 24.0, -43.0), (21.0, 17.0, -46.0), (34.0, 9.0, -49.5), (42.0, 6.0, -51.0)] as [(CGFloat, CGFloat, CGFloat)] {
            courses.addPath(blockPath(x + centre * s, wide * s, 0.6 * s, from: level * s))
        }
        // A pier, and half of the arch that sprang from it: the rest lies on the ground.
        shape([at(-9, 0), at(-8, 26), at(-1, 26), at(0, 0)])
        block(x - 4.5 * s, 10 * s, 1.8 * s, from: 26 * s)
        var half: [Spot] = [], inner: [Spot] = []
        for step in 0...7 {
            let angle = Double.pi - Double(step) / 7 * 1.62
            half.append(at(18 + 23 * CGFloat(cos(angle)), 27.8 + 23 * CGFloat(sin(angle))))
            inner.append(at(18 + 17.2 * CGFloat(cos(angle)), 27.8 + 17.2 * CGFloat(sin(angle))))
        }
        shape(half + [at(22.5, 49.4), at(20.4, 46.6), at(21.8, 44.2)] + inner.reversed())
        var joints = Path()
        for step in 1...5 {
            let angle = Double.pi - Double(step) / 7 * 1.62 - 0.11
            joints.addPath(strokePath([at(18 + 17.6 * CGFloat(cos(angle)), 27.8 + 17.6 * CGFloat(sin(angle))), at(18 + 22.6 * CGFloat(cos(angle)), 27.8 + 22.6 * CGFloat(sin(angle)))], 0.6 * s))
        }
        courses.addPath(blockPath(x - 4.5 * s, 7 * s, 0.6 * s, from: 9 * s)); courses.addPath(blockPath(x - 4.5 * s, 7 * s, 0.6 * s, from: 18 * s))
        // Its stones where they fell, and a drum of a column on its side.
        shape([at(12, 0), at(10.6, 4.6), at(15.2, 6.4), at(17.4, 1.2)])
        shape([at(19, 0), at(20.2, 5.2), at(25.6, 4.4), at(25, 0)])
        shape([at(27.4, 0), at(26.8, 3.4), at(31, 5.0), at(33, 0.6)])
        shape([at(15.6, 5.0), at(18, 9.4), at(22.4, 7.6), at(20.6, 4.4)])
        add(smoothPath([at(-20, 0.6), at(-20.6, 4.2), at(-19.4, 7.2), at(-10.6, 7.2), at(-9.4, 4.2), at(-10, 0.6)]))
        detail(Path(ellipseIn: CGRect(x: point(x - 11.6 * s, 0).x, y: point(0, 6.8 * s).y, width: 2.2 * s, height: 6.0 * s)), strength: 1.0)
        // A low wall on the far side, one doorway left in it.
        shape([at(36, 0), at(36, 13), at(40, 13), at(40, 17), at(46, 17), at(46, 21), at(51.5, 21), at(51.5, 14), at(55, 14), at(55, 9), at(58.5, 9), at(59, 0)])
        arch(x + 46 * s, 4.6 * s, 10 * s, from: 2.4 * s, pointed: false)
        courses.addPath(blockPath(x + 47 * s, 21 * s, 0.6 * s, from: 6.6 * s)); courses.addPath(blockPath(x + 44.6 * s, 14 * s, 0.6 * s, from: 12.6 * s))
        var weathering = Path()
        for (px, y, length) in [(-53.0, 29.0, 6.0), (-49.0, 16.0, 7.0), (-44.0, 5.0, 4.5),
                                (-5.0, 13.0, 6.0), (40.0, 5.0, 3.0), (53.0, 4.0, 3.2)] as [(CGFloat, CGFloat, CGFloat)] {
            weathering.addPath(strokePath([at(px, y), at(px + 0.9, y + length * 0.42),
                                            at(px - 0.4, y + length)], 0.35 * s))
        }
        detail(courses, strength: 0.5)
        detail(joints, strength: 0.5)
        tint(weathering, Color.black.opacity(0.24))
        // Sand drifted against all of it.
        var sand = Path()
        sand.addPath(ridgePath([at(-66, 0), at(-58, 2.4), at(-52, 6.6), at(-47, 4.0), at(-40, 1.6), at(-30, 0)], base: -1.5 * s))
        sand.addPath(ridgePath([at(-24, 0), at(-18, 2.2), at(-10, 5.6), at(-5, 3.4), at(4, 1.2), at(12, 0)], base: -1.5 * s))
        sand.addPath(ridgePath([at(26, 0), at(33, 2.4), at(38, 6.8), at(43, 4.0), at(50, 5.6), at(57, 3.0), at(68, 0)], base: -1.5 * s))
        tint(sand, shade(0.72, 0.60, 0.42, 0.72))
    }
}

extension SkylinePen {
    /// A four-pointed glint.
    func sparklePath(_ x: CGFloat, _ y: CGFloat, _ r: CGFloat, turn angle: Double = 0, waist: CGFloat = 0.2) -> Path {
        var spots: [Spot] = []
        for index in 0..<8 {
            let around = angle + Double(index) * Double.pi / 4
            let reach = index % 2 == 0 ? r : r * waist
            spots.append((x + CGFloat(sin(around)) * reach, y + CGFloat(cos(around)) * reach))
        }
        return polygon(spots)
    }

    // MARK: What is made and used

    /// A great sailing ship, tall as a hill, riding the swell. Moves.
    mutating func ship(_ x: CGFloat, scale s: CGFloat = 1, variant: Int = 0) {
        // Related vessels can have their own canvas and motion rather than
        // looking like scaled copies. The original stays the default.
        let alternate = variant == 1, phase = alternate ? 1.1 : 0.0
        let roll = sin(time * 0.55 + phase) * 0.035, heave = CGFloat(sin(time * 0.7 + phase)) * 1.2 * s
        func at(_ px: CGFloat, _ py: CGFloat) -> Spot {
            let dx = Double(px * s), dy = Double((py - 4) * s)
            return (x + CGFloat(dx * cos(roll) - dy * sin(roll)), 4 * s + CGFloat(dx * sin(roll) + dy * cos(roll)) + heave)
        }
        func spot(_ px: CGFloat, _ py: CGFloat) -> CGPoint { let place = at(px, py); return point(place.0, place.1) }
        // The hull: a high stern, a low waist, the stem raking far forward.
        var hull = Path()
        hull.move(to: spot(-43, 23)); hull.addLine(to: spot(-21, 21.5)); hull.addLine(to: spot(-21, 13))
        hull.addQuadCurve(to: spot(22, 12), control: spot(0, 10))
        hull.addQuadCurve(to: spot(49, 21), control: spot(38, 13))
        hull.addLine(to: spot(51, 19))
        hull.addQuadCurve(to: spot(27, -4), control: spot(41, 4))
        hull.addLine(to: spot(-31, -4))
        hull.addQuadCurve(to: spot(-42, 3), control: spot(-39, -4))
        hull.addQuadCurve(to: spot(-43, 23), control: spot(-45.5, 13))
        hull.closeSubpath()
        add(hull)
        shape([at(-43, 7), at(-47, 6), at(-47.6, -4), at(-43, -4)])
        line([at(48, 19.5), at(61, 26)], 1.1 * s)
        // The rail of the poop, the masts and their long yards.
        var spars = Path()
        for post in [-41.0, -36.0, -31.0, -26.0, -21.6] as [CGFloat] {
            spars.addPath(strokePath([at(post, 22), at(post, 26)], 0.6 * s))
        }
        spars.addPath(strokePath([at(-43.4, 26.4), at(-21, 25)], 0.7 * s))
        spars.addPath(polygon([at(1, 11), at(3.4, 11), at(5.2, 77), at(4.2, 77)]))
        spars.addPath(polygon([at(-28.2, 21), at(-26.2, 21), at(-25, 57), at(-25.8, 57)]))
        spars.addPath(strokePath([at(33.5, 23), at(-12.5, 80)], 1.2 * s))
        spars.addPath(strokePath([at(-10.6, 27), at(-37.5, 60.5)], 1.0 * s))
        // Stays and shrouds.
        spars.addPath(strokePath([at(4.7, 76), at(61, 26)], 0.45 * s))
        spars.addPath(strokePath([at(4.7, 76), at(-25.4, 57)], 0.4 * s))
        spars.addPath(strokePath([at(4.4, 62), at(13, 12.4)], 0.4 * s))
        spars.addPath(strokePath([at(4.2, 62), at(-6, 11.4)], 0.4 * s))
        spars.addPath(strokePath([at(-25.4, 56), at(-43, 24)], 0.4 * s))
        add(spars)
        // The sails, full of wind.
        let belly = (alternate ? 1.55 : 2.4) + CGFloat(sin(time * 0.7 + phase)) * (alternate ? 1.0 : 1.4)
        var main = Path()
        main.move(to: spot(31.5, 24.5)); main.addLine(to: spot(-11.5, 78.4))
        main.addQuadCurve(to: spot(-15.5, 17.5), control: spot(-20 - belly, 46))
        main.addQuadCurve(to: spot(31.5, 24.5), control: spot(8, 14.5 - belly * 0.5))
        main.closeSubpath()
        var mizzen = Path()
        mizzen.move(to: spot(-11.4, 28)); mizzen.addLine(to: spot(-36.8, 59.6))
        mizzen.addQuadCurve(to: spot(-41, 27.5), control: spot(-43 - belly * 0.7, 43))
        mizzen.addQuadCurve(to: spot(-11.4, 28), control: spot(-26, 24 - belly * 0.4))
        mizzen.closeSubpath()
        let canvas = alternate ? shade(0.82, 0.79, 0.70, 0.96) : shade(0.93, 0.89, 0.78, 0.96)
        tint(mizzen, canvas); tint(main, canvas)
        var seams = Path()
        for cloth in [0.26, 0.50, 0.74] {
            let along = CGFloat(cloth)
            seams.addPath(strokePath([at(-11.5 + 43 * along, 78.4 - 53.9 * along), at(-16 + 46 * along - belly * (1 - along), 18 + 6 * along)], 0.4 * s))
            seams.addPath(strokePath([at(-36.8 + 25.4 * along, 59.6 - 31.6 * along), at(-41 + 29 * along - belly * 0.5 * (1 - along), 27.6)], 0.35 * s))
        }
        tint(seams, Color.black.opacity(0.13))
        var lee = Path()
        lee.move(to: spot(-11.5, 78.4))
        lee.addQuadCurve(to: spot(-15.5, 17.5), control: spot(-20 - belly, 46))
        lee.addQuadCurve(to: spot(-11.5, 78.4), control: spot(-10, 46))
        lee.closeSubpath()
        tint(lee, Color.black.opacity(0.10))
        // A pennant at the masthead.
        let near = CGFloat(sin(time * 2.6 + phase)) * 0.9, far = CGFloat(sin(time * 2.6 + 1.3 + phase)) * 1.2
        tint(polygon([at(4.7, 77), at(4.7, 80), at(-1.5, 79.4 + near), at(-8, 78.6 + far), at(-1.5, 77.6 + near)]), shade(0.74, 0.24, 0.20))
        // Windows in the stern, a lantern over it, the wales along her side.
        for pane in [-37.0, -30.5] as [CGFloat] {
            tint(polygon([at(pane - 1.6, 14.4), at(pane + 1.6, 14.2), at(pane + 1.6, 18.2), at(pane - 1.6, 18.4)]), Color.black.opacity(0.30))
            shape([at(pane - 1.0, 15), at(pane + 1.0, 14.9), at(pane + 1.0, 17.7), at(pane - 1.0, 17.8)], .light)
        }
        let lamp = at(-44.4, 29)
        line([at(-43.2, 23), at(-44.4, 27.6)], 0.6 * s)
        disc(lamp.0, lamp.1, 1.3 * s)
        disc(lamp.0, lamp.1, 0.9 * s, .light)
        glow(lamp.0, lamp.1, 9 * s, Self.lampLight, 0.30, nightOnly: true)
        detail(strokePath([at(-43, 17.5), at(-21, 9.6), at(0, 6.6), at(22, 8.4), at(46, 16)], 0.8 * s, smooth: true), strength: 0.9)
        detail(strokePath([at(-42, 9.5), at(-20, 4), at(0, 2), at(22, 3.2), at(40, 8.4)], 0.7 * s, smooth: true), strength: 0.55)
        detail(strokePath([at(-21, 13.4), at(-21, 21)], 0.7 * s), strength: 0.8)
        // Fine planking follows the hull as it rolls, with short treenails and
        // a restrained warm edge catching the sky on the stern rail.
        var plankSeams = Path(), fastenings = Path()
        for row in 0..<3 {
            let level = CGFloat(row) * 2.1
            plankSeams.addPath(strokePath([at(-39, 3 + level), at(-19, 0.7 + level),
                                           at(4, -0.3 + level), at(24, 1.2 + level),
                                           at(36, 4.2 + level)], 0.25 * s, smooth: true))
            for column in 0..<7 {
                let px = -29 + CGFloat(column) * 9
                let py = 1.4 + level + abs(px) * 0.055
                fastenings.addPath(discPath(at(px, py).0, at(px, py).1, 0.22 * s))
            }
        }
        tint(plankSeams, Color.black.opacity(0.20))
        tint(fastenings, shade(0.91, 0.76, 0.50, 0.32))
        tint(strokePath([at(-42.5, 25.8), at(-21.6, 24.7)], 0.3 * s), shade(0.95, 0.80, 0.57, 0.55))
        // The water she throws aside at the bow, and her wake.
        let wash = 0.5 + 0.5 * sin(time * 1.2)
        tint(polygon([(x + 22 * s, 0.4), (x + 31 * s, 2.2 + CGFloat(wash) * s), (x + 41 * s, 0.4), (x + 31 * s, -1.2)]), Color.white.opacity((0.30 + 0.15 * wash) * (1 - 0.4 * night)))
        tint(polygon([(x - 62 * s, 0.2), (x - 50 * s, 1.2), (x - 40 * s, 0.2), (x - 50 * s, -0.8)]), Color.white.opacity((0.20 + 0.10 * (1 - wash)) * (1 - 0.4 * night)))
    }

    /// A low spread table with dishes and a jug, steam rising. Moves.
    mutating func table(_ x: CGFloat, scale s: CGFloat = 1) {
        func at(_ dx: CGFloat, _ dy: CGFloat) -> Spot { (x + dx * s, dy * s) }
        // The table: a thick top on short turned legs.
        block(x, 49 * s, 1.9 * s, from: 6.6 * s)
        block(x, 45 * s, 1.0 * s, from: 5.6 * s)
        for side in [-1.0, 1.0] as [CGFloat] {
            let lx = side * 19.5
            shape([at(lx - 2.2, 5.6), at(lx + 2.2, 5.6), at(lx + 1.1, 3.2), at(lx + 2.1, 1.2), at(lx + 1.5, 0), at(lx - 1.5, 0), at(lx - 2.1, 1.2), at(lx - 1.1, 3.2)])
        }
        block(x, 37 * s, 0.9 * s, from: 2.0 * s)
        detail(blockPath(x, 47 * s, 0.6 * s, from: 7.2 * s), strength: 0.9)
        // A cloth laid across it, hanging in a point at the front.
        tint(polygon([at(-9, 8.5), at(9, 8.5), at(9, 3.6), at(0, 0.9), at(-9, 3.6)]), shade(0.56, 0.20, 0.18, 0.96))
        tint(polygon([at(-9, 4.6), at(0, 1.9), at(9, 4.6), at(9, 3.9), at(0, 1.2), at(-9, 3.9)]), shade(0.88, 0.72, 0.40, 0.9))
        var woven = Path()
        for fold in [-6.0, -3.0, 0.0, 3.0, 6.0] as [CGFloat] {
            woven.addPath(strokePath([at(fold, 7.8), at(fold * 0.90, 4.9), at(fold * 0.50, 3.0)], 0.24 * s, smooth: true))
        }
        tint(woven, shade(0.98, 0.83, 0.55, 0.32))
        // The jug: belly, neck, lip, spout and handle.
        add(smoothPath([at(-18.2, 8.9), at(-21.4, 12.4), at(-19.8, 16.4), at(-17.3, 18.4), at(-17.5, 22.2), at(-18.6, 24.2),
                        at(-13.4, 24.2), at(-14.5, 22.2), at(-14.7, 18.4), at(-12.2, 16.4), at(-10.6, 12.4), at(-13.8, 8.9)]))
        block(x - 16 * s, 5.4 * s, 0.9 * s, from: 8.4 * s)
        line([at(-11.4, 14), at(-8.4, 17.6), at(-7.6, 21.4)], 1.1 * s, smooth: true)
        line([at(-18.2, 23), at(-22.8, 21.2), at(-22.6, 16), at(-20.4, 13.6)], 0.9 * s, smooth: true)
        dome(x - 16 * s, 4 * s, on: 24.2 * s, rise: 1.9 * s)
        disc(x - 16 * s, 26.8 * s, 0.85 * s)
        detail(polygon([at(-19.4, 12), at(-18.6, 12), at(-18, 16), at(-18.8, 16)]), strength: 1.0)
        // A covered dish in the middle, a bowl, a plate of bread and a cup.
        shape([at(-7.2, 8.5), at(7.2, 8.5), at(8.6, 11.2), at(-8.6, 11.2)])
        dome(x, 15.4 * s, on: 11.2 * s, rise: 6.2 * s)
        disc(x, 18.2 * s, 1.0 * s)
        detail(blockPath(x, 14.4 * s, 0.6 * s, from: 12.3 * s), strength: 0.9)
        detail(domePath(x - 2.6 * s, 6 * s, on: 12.9 * s, rise: 3.4 * s), strength: 0.6)
        var dishEngraving = Path()
        for bead in -3...3 {
            let px = CGFloat(bead) * 1.6
            dishEngraving.addPath(discPath(x + px * s, 12.8 * s, 0.24 * s))
        }
        tint(dishEngraving, shade(0.97, 0.81, 0.53, 0.60))
        shape([at(8.4, 8.5), at(18.4, 8.5), at(19.6, 9.5), at(7.2, 9.5)])
        var bread = Path()
        for (level, wide) in [(9.5, 10.0), (10.7, 9.0), (11.8, 7.4)] as [(CGFloat, CGFloat)] {
            bread.addPath(smoothPath([at(13.4 - wide / 2, level), at(13.4 - wide * 0.3, level + 1.5), at(13.4 + wide * 0.3, level + 1.5), at(13.4 + wide / 2, level), at(13.4, level - 0.2)]))
        }
        tint(bread, shade(0.86, 0.68, 0.40))
        tint(strokePath([at(10.6, 10.6), at(16.2, 10.6)], 0.4 * s), Color.black.opacity(0.22))
        tint(strokePath([at(11, 11.8), at(15.8, 11.8)], 0.4 * s), Color.black.opacity(0.22))
        shape([at(19.4, 8.5), at(22.6, 8.5), at(21.5, 9.2), at(21.5, 10.6), at(23.2, 12), at(23.6, 14.4), at(18.4, 14.4), at(18.8, 12), at(20.5, 10.6), at(20.5, 9.2)])
        // Steam off the dish.
        for wisp in 0..<3 {
            var curl: [Spot] = []
            let from: Spot = at([-2.6, 1.4, 4.6][wisp], 19.4)
            for step in 0...6 {
                let drift = CGFloat(sin(Double(step) * 1.15 - time * 1.1 + Double(wisp) * 2.1)) * (0.5 + CGFloat(step) * 0.42) * s
                curl.append((from.0 + drift + CGFloat(step) * 0.5 * s, from.1 + CGFloat(step) * 2.9 * s))
            }
            let breath = 0.75 + 0.25 * sin(time * 0.8 + Double(wisp))
            tint(strokePath(curl, 0.9 * s, smooth: true), Color.white.opacity(0.09 * breath * (1 - 0.3 * night)))
            tint(strokePath(Array(curl.prefix(4)), 0.9 * s, smooth: true), Color.white.opacity(0.10 * breath * (1 - 0.3 * night)))
        }
    }

    /// A balance on its post, the pans swaying. Moves.
    mutating func scales(_ x: CGFloat, _ h: CGFloat = 40) {
        let u = h / 40, brass = shade(0.84, 0.68, 0.36)
        // The foot, the post with its collar, the head the beam turns on.
        block(x, 17 * u, 1.5 * u); block(x, 11 * u, 1.4 * u, from: 1.5 * u)
        dome(x, 7 * u, on: 2.9 * u, rise: 2.4 * u)
        shape([(x - 1.2 * u, 4.6 * u), (x + 1.2 * u, 4.6 * u), (x + 0.75 * u, h - 5 * u), (x - 0.75 * u, h - 5 * u)])
        disc(x, h * 0.42, 1.7 * u)
        block(x, 3.2 * u, 0.8 * u, from: h * 0.42 - 2.6 * u); block(x, 3.2 * u, 0.8 * u, from: h * 0.42 + 1.8 * u)
        shape([(x - 2 * u, h - 6 * u), (x + 2 * u, h - 6 * u), (x, h - 2.6 * u)])
        disc(x, h - 1.6 * u, 1.6 * u)
        disc(x, h - 1.6 * u, 0.7 * u, .hole)
        // The beam, tilting slowly one way and then the other.
        let pivot: Spot = (x, h - 5.4 * u), tilt = sin(time * 0.55) * 0.085, half = 17.5 * u
        func arm(_ along: CGFloat, _ up: CGFloat) -> Spot { turn((pivot.0 + along, pivot.1 + up), about: pivot, by: tilt) }
        shape([arm(-half, -0.4 * u), arm(-half * 0.4, -0.9 * u), arm(0, -1.2 * u), arm(half * 0.4, -0.9 * u), arm(half, -0.4 * u),
               arm(half, 0.5 * u), arm(half * 0.4, 0.9 * u), arm(0, 1.4 * u), arm(-half * 0.4, 0.9 * u), arm(-half, 0.5 * u)])
        for side in [-1.0, 1.0] as [CGFloat] {
            let end = arm(side * half, 0)
            disc(end.0, end.1, 1.1 * u)
            // Each pan hangs straight down from its end of the beam, lagging a little.
            let lag = CGFloat(sin(time * 0.55 - 0.7)) * 0.9 * u * side
            let pan: Spot = (end.0 + lag, end.1 - 15.5 * u)
            var chains = Path()
            for hook in [-5.6, 0.0, 5.6] as [CGFloat] { chains.addPath(strokePath([end, (pan.0 + hook * u, pan.1)], 0.45 * u)) }
            add(chains)
            var bowl = Path()
            bowl.move(to: point(pan.0 - 6.4 * u, pan.1 + 0.4 * u)); bowl.addLine(to: point(pan.0 + 6.4 * u, pan.1 + 0.4 * u))
            bowl.addQuadCurve(to: point(pan.0 - 6.4 * u, pan.1 + 0.4 * u), control: point(pan.0, pan.1 - 6.2 * u))
            bowl.closeSubpath()
            add(bowl)
            tint(bowl, brass.opacity(0.9))
            tint(polygon([(pan.0 - 6.4 * u, pan.1 + 0.4 * u), (pan.0 + 6.4 * u, pan.1 + 0.4 * u), (pan.0 + 6.0 * u, pan.1 - 0.5 * u), (pan.0 - 6.0 * u, pan.1 - 0.5 * u)]),
                 Color.white.opacity(0.22))
            tint(strokePath([(pan.0 - 4.5 * u, pan.1 - 1.0 * u), (pan.0, pan.1 - 2.5 * u),
                             (pan.0 + 4.5 * u, pan.1 - 1.0 * u)], 0.35 * u, smooth: true),
                 Color.black.opacity(0.18))
            tint(discPath(end.0, end.1, 0.42 * u), shade(1.0, 0.88, 0.58, 0.8))
        }
        tint(discPath(x, h - 1.6 * u, 1.6 * u).strokedPath(StrokeStyle(lineWidth: 0.5 * u)), brass)
        detail(blockPath(x - 0.5 * u, 0.5 * u, h - 12 * u, from: 5.4 * u), strength: 0.9)
        detail(blockPath(x, 15 * u, 0.5 * u, from: 0.9 * u), strength: 0.7)
    }

    /// A reed pen standing in its inkwell beside a sheet, large in the foreground.
    mutating func penAndInkwell(_ x: CGFloat, scale s: CGFloat = 1) {
        func at(_ dx: CGFloat, _ dy: CGFloat) -> Spot { (x + dx * s, dy * s) }
        // The sheet, lying by it with its far end still rolled.
        tint(polygon([at(8, -3), at(44, -3), at(52, -19), at(10, -19)]), shade(0.93, 0.89, 0.78, 0.95))
        tint(polygon([at(8, -3), at(44, -3), at(44.6, -4.2), at(8.2, -4.2)]), Color.black.opacity(0.10))
        tint(smoothPath([at(7, -1.4), at(7.6, -3.4), at(44.4, -3.4), at(45.2, -1.4), at(44.4, 0.4), at(7.6, 0.4)]), shade(0.86, 0.80, 0.66))
        tint(Path(ellipseIn: CGRect(x: point(x + 43.4 * s, 0).x, y: point(0, 0.2 * s).y, width: 1.8 * s, height: 3.4 * s)), shade(0.62, 0.56, 0.44))
        tint(polygon([at(52, -19), at(46.4, -19), at(47.6, -15.4)]), shade(0.80, 0.74, 0.60))
        // The inkwell on its tray: a round pot, a neck, a rim, a band about its belly.
        block(x - 6 * s, 40 * s, 1.6 * s)
        block(x - 6 * s, 34 * s, 0.9 * s, from: 1.6 * s)
        let cx: CGFloat = -8
        add(smoothPath([at(cx - 9, 2.5), at(cx - 15.5, 5), at(cx - 16, 12), at(cx - 12, 18), at(cx - 6, 20.5), at(cx + 6, 20.5), at(cx + 12, 18), at(cx + 16, 12), at(cx + 15.5, 5), at(cx + 9, 2.5)]))
        block(x + cx * s, 12 * s, 3.4 * s, from: 19.6 * s)
        add(smoothPath([at(cx - 8, 23), at(cx - 8.6, 24.4), at(cx - 8, 25.8), at(cx + 8, 25.8), at(cx + 8.6, 24.4), at(cx + 8, 23)]))
        tint(polygon([at(cx - 14.6, 9.4), at(cx + 14.6, 9.4), at(cx + 14.9, 12.2), at(cx - 14.9, 12.2)]), shade(0.86, 0.68, 0.34, 0.92))
        var studs = Path()
        for stud in stride(from: CGFloat(-11), through: 11, by: 5.5) {
            studs.addPath(polygon([at(cx + stud, 9.9), at(cx + stud + 1.2, 10.8), at(cx + stud, 11.7), at(cx + stud - 1.2, 10.8)]))
        }
        tint(studs, Color.black.opacity(0.30))
        detail(smoothPath([at(cx - 12.6, 6), at(cx - 13.4, 12), at(cx - 10.4, 16.6), at(cx - 9.6, 12), at(cx - 10.6, 7)]), strength: 0.9)
        detail(blockPath(x + cx * s, 10.6 * s, 0.6 * s, from: 21 * s), strength: 0.8)
        tint(Path(ellipseIn: CGRect(x: point(x + (cx - 5.6) * s, 0).x, y: point(0, 26 * s).y, width: 11.2 * s, height: 1.7 * s)), Color.black.opacity(0.55))
        // The pen: a reed cut to a nib, leaning in the pot, its joints showing.
        let reed = polygon([at(cx - 1.6, 21), at(cx + 1.4, 20.4), at(cx + 23.4, 68), at(cx + 21.6, 70.4), at(cx + 19.8, 68.6)])
        add(reed)
        tint(reed, shade(0.82, 0.66, 0.38))
        tint(polygon([at(cx + 0.9, 21.6), at(cx + 1.6, 21.3), at(cx + 22.6, 67.2), at(cx + 21.9, 68)]), Color.white.opacity(0.22))
        var joints = Path()
        for along in [0.34, 0.62, 0.86] {
            let part = CGFloat(along)
            joints.addPath(strokePath([at(cx - 1.4 + 21.4 * part, 21 + 47.6 * part), at(cx + 1.6 + 21.6 * part, 20.2 + 47.6 * part)], 0.7 * s))
        }
        tint(joints, Color.black.opacity(0.34))
        // A fine chased border on the tray and facets on the pot give the
        // small inkwell a readable material even at the scene's usual scale.
        tint(strokePath([at(-24.5, 0.5), at(12.5, 0.5)], 0.34 * s), shade(0.93, 0.80, 0.53, 0.55))
        tint(strokePath([at(cx - 10.6, 4.2), at(cx - 5.2, 3.4), at(cx + 5.2, 3.4), at(cx + 10.6, 4.2)],
                        0.34 * s, smooth: true), Color.black.opacity(0.20))
    }

    /// Open pages on a stand, a leaf lifting in the air. Moves.
    mutating func pages(_ x: CGFloat, scale s: CGFloat = 1) {
        func at(_ dx: CGFloat, _ dy: CGFloat) -> Spot { (x + dx * s, dy * s) }
        func spot(_ dx: CGFloat, _ dy: CGFloat) -> CGPoint { point(x + dx * s, dy * s) }
        // The stand: two boards crossed, their feet on the ground.
        line([at(-13, 0.8), at(11.5, 21.5)], 3.2 * s)
        line([at(13, 0.8), at(-11.5, 21.5)], 3.2 * s)
        block(x - 13.4 * s, 7 * s, 1.3 * s); block(x + 13.4 * s, 7 * s, 1.3 * s)
        detail(strokePath([at(-11.4, 2.6), at(-2.6, 10)], 0.6 * s), strength: 0.9)
        detail(strokePath([at(11.4, 2.6), at(2.6, 10)], 0.6 * s), strength: 0.9)
        // Pin and carved grooves remain fixed to the two boards while the
        // leaf above them continues to move independently.
        tint(discPath(x, 11.6 * s, 0.95 * s), shade(0.90, 0.75, 0.47, 0.75))
        tint(strokePath([at(-11, 1.8), at(-3.5, 8.1)], 0.32 * s), Color.black.opacity(0.28))
        tint(strokePath([at(11, 1.8), at(3.5, 8.1)], 0.32 * s), Color.black.opacity(0.28))
        // The book's boards, and the block of its leaves lying open on them.
        shape([at(0, 14.6), at(22.6, 23.4), at(19.8, 33), at(0, 24.6), at(-19.8, 33), at(-22.6, 23.4)])
        let paper = shade(0.96, 0.92, 0.80)
        for side in [-1.0, 1.0] as [CGFloat] {
            var edge = Path()
            edge.move(to: spot(0, 15.6)); edge.addQuadCurve(to: spot(side * 21, 23.4), control: spot(side * 11, 22.6))
            edge.addLine(to: spot(side * 20.6, 24.8)); edge.addQuadCurve(to: spot(0, 17), control: spot(side * 11, 24))
            edge.closeSubpath()
            tint(edge, shade(0.78, 0.72, 0.58))
            var leaf = Path()
            leaf.move(to: spot(0, 17)); leaf.addQuadCurve(to: spot(side * 20.6, 24.8), control: spot(side * 11, 24))
            leaf.addLine(to: spot(side * 18.2, 32.6)); leaf.addQuadCurve(to: spot(0, 25), control: spot(side * 10, 31.8))
            leaf.closeSubpath()
            tint(leaf, paper)
            if side < 0 { tint(leaf, Color.black.opacity(0.07)) }
        }
        tint(strokePath([at(0, 17), at(0, 25)], 0.6 * s), Color.black.opacity(0.26))
        // Layered paper edges and quiet margins, without inventing writing.
        for side in [-1.0, 1.0] as [CGFloat] {
            for layer in 0..<3 {
                let lift = CGFloat(layer) * 0.38
                tint(strokePath([at(side * 1.5, 16.2 + lift), at(side * 10, 19.1 + lift),
                                 at(side * 19.6, 23.3 + lift)], 0.22 * s, smooth: true),
                     Color.black.opacity(0.14))
            }
        }
        // One leaf standing up from the spine, lifting and settling as the air takes it.
        let lift = 0.62 + 0.40 * sin(time * 0.55), angle = 0.36 + lift
        let reach = 17 * s, bow = -2.4 * s * CGFloat(cos(time * 0.55))
        let low = at(0, 17.2), high = at(0, 25.2)
        let away = (CGFloat(cos(angle)), CGFloat(sin(angle))), across = (-away.1, away.0)
        let lowTip: Spot = (low.0 + away.0 * reach, low.1 + away.1 * reach)
        let highTip: Spot = (high.0 + away.0 * reach * 0.94, high.1 + away.1 * reach * 0.94 + 0.6 * s)
        var turning = Path()
        turning.move(to: point(low.0, low.1))
        turning.addQuadCurve(to: point(lowTip.0, lowTip.1), control: point((low.0 + lowTip.0) / 2 + across.0 * bow, (low.1 + lowTip.1) / 2 + across.1 * bow))
        turning.addLine(to: point(highTip.0, highTip.1))
        turning.addQuadCurve(to: point(high.0, high.1), control: point((high.0 + highTip.0) / 2 + across.0 * bow, (high.1 + highTip.1) / 2 + across.1 * bow))
        turning.closeSubpath()
        tint(turning, shade(0.99, 0.97, 0.88, 0.96))
        tint(strokePath([lowTip, highTip], 0.5 * s), Color.black.opacity(0.16))
    }

    /// A silver jug and cups on a low stand, glinting. Moves.
    mutating func vessels(_ x: CGFloat, scale s: CGFloat = 1) {
        let k = 1.25 * s, silver = shade(0.78, 0.83, 0.90)
        func at(_ dx: CGFloat, _ dy: CGFloat) -> Spot { (x + dx * k, dy * k) }
        // The stand: a tray with a raised rim on three turned legs.
        block(x, 48 * k, 1.6 * k, from: 8.6 * k)
        block(x - 23.4 * k, 1.2 * k, 1.6 * k, from: 10.2 * k); block(x + 23.4 * k, 1.2 * k, 1.6 * k, from: 10.2 * k)
        for leg in [-18.0, 0.0, 18.0] as [CGFloat] {
            shape([at(leg - 2.2, 8.6), at(leg + 2.2, 8.6), at(leg + 1.0, 5.4), at(leg + 2.2, 2.6), at(leg + 1.5, 0), at(leg - 1.5, 0), at(leg - 2.2, 2.6), at(leg - 1.0, 5.4)])
        }
        var scallops = Path()
        for step in stride(from: CGFloat(-21), through: 21, by: 6) { scallops.addPath(discPath(x + step * k, 8.6 * k, 2.4 * k)) }
        add(scallops)
        detail(blockPath(x, 46 * k, 0.6 * k, from: 9.2 * k), strength: 0.9)
        // The ewer: foot, belly, slender neck, lid, a long curved spout and a handle.
        let c: CGFloat = -9
        var ewer = Path()
        ewer.addPath(polygon([at(c - 2.8, 10.2), at(c + 2.8, 10.2), at(c + 1.2, 12.2), at(c - 1.2, 12.2)]))
        ewer.addPath(smoothPath([at(c, 11.6), at(c + 5.8, 14.4), at(c + 6.4, 19), at(c + 3.4, 23), at(c + 1.3, 25), at(c + 1.1, 30), at(c + 2.6, 32.4),
                                 at(c - 2.6, 32.4), at(c - 1.1, 30), at(c - 1.3, 25), at(c - 3.4, 23), at(c - 6.4, 19), at(c - 5.8, 14.4)]))
        ewer.addPath(domePath(x + c * k, 4 * k, on: 32.2 * k, rise: 2.2 * k))
        ewer.addPath(discPath(x + c * k, 35.3 * k, 0.9 * k))
        ewer.addPath(strokePath([at(c + 5.2, 16.6), at(c + 9.8, 19.6), at(c + 9.4, 25.4), at(c + 11.6, 29)], 1.3 * k, smooth: true))
        ewer.addPath(strokePath([at(c - 1.6, 30.8), at(c - 7.8, 29.2), at(c - 8.6, 22), at(c - 5.6, 17.6)], 1.1 * k, smooth: true))
        add(ewer)
        tint(ewer, silver)
        tint(smoothPath([at(c + 2, 12.6), at(c + 5.6, 14.6), at(c + 6.2, 19), at(c + 3.4, 22.8), at(c + 3.6, 18.6)]), Color.black.opacity(0.16))
        tint(smoothPath([at(c - 3.6, 14.6), at(c - 4.6, 18.8), at(c - 3.0, 22), at(c - 3.2, 18.6)]), Color.white.opacity(0.38))
        tint(blockPath(x + c * k, 12 * k, 0.5 * k, from: 18.4 * k), Color.black.opacity(0.20))
        tint(blockPath(x + c * k, 2.6 * k, 0.5 * k, from: 27.4 * k), Color.black.opacity(0.20))
        var etchedBand = Path()
        for mark in -3...3 {
            let dx = CGFloat(mark) * 1.35
            etchedBand.addPath(polygon([at(c + dx, 19.0), at(c + dx + 0.45, 19.5),
                                        at(c + dx, 20.0), at(c + dx - 0.45, 19.5)]))
        }
        tint(etchedBand, Color.white.opacity(0.28))
        // Three cups, the middle one a little taller.
        var cups = Path(), shadows = Path(), lights = Path()
        for (index, dx) in ([7.0, 14.0, 21.4] as [CGFloat]).enumerated() {
            let tall: CGFloat = index == 1 ? 1.0 : 0
            cups.addPath(polygon([at(dx - 2.1, 10.2), at(dx + 2.1, 10.2), at(dx + 0.5, 11.3), at(dx - 0.5, 11.3)]))
            cups.addPath(blockPath(x + dx * k, 0.9 * k, (2.2 + tall) * k, from: 11.2 * k))
            cups.addPath(smoothPath([at(dx - 2.9, 18.6 + tall), at(dx + 2.9, 18.6 + tall), at(dx + 2.6, 15 + tall), at(dx + 0.9, 13.2 + tall), at(dx - 0.9, 13.2 + tall), at(dx - 2.6, 15 + tall)]))
            shadows.addPath(polygon([at(dx + 0.8, 13.8 + tall), at(dx + 2.4, 15.2 + tall), at(dx + 2.4, 17.8 + tall), at(dx + 1.2, 17.8 + tall)]))
            lights.addPath(blockPath(x + (dx - 1.5) * k, 0.6 * k, 2.6 * k, from: (14.8 + tall) * k))
        }
        add(cups)
        tint(cups, silver)
        tint(shadows, Color.black.opacity(0.16))
        tint(lights, Color.white.opacity(0.40))
        // Light catching on them, now here, now there.
        let places: [Spot] = [at(c - 3.4, 20.6), at(c + 11.4, 28.8), at(5.2, 18.2), at(15.8, 19.2), at(c + 0.4, 33.6)]
        for (index, place) in places.enumerated() {
            let wave = max(0, sin(time * 1.1 + Double(index) * 1.7)), glint = wave * wave
            tint(sparklePath(place.0, place.1, (2.0 + 2.2 * CGFloat(glint)) * k), Color.white.opacity(0.20 + 0.75 * glint))
        }
    }

    /// Domed hives set on a ledge (no bees).
    mutating func hives(_ x: CGFloat, _ y: CGFloat, count: Int = 5) {
        let total = max(1, count), pitch: CGFloat = 13
        // The ledge, and the stones it rests on.
        block(x, CGFloat(total) * pitch + 9, 1.8, from: y - 1.8)
        shape([(x - CGFloat(total) * pitch / 2 + 2, y - 1.8), (x - CGFloat(total) * pitch / 2 + 9, y - 1.8), (x - CGFloat(total) * pitch / 2 + 5, y - 5.4)])
        shape([(x + CGFloat(total) * pitch / 2 - 2, y - 1.8), (x + CGFloat(total) * pitch / 2 - 9, y - 1.8), (x + CGFloat(total) * pitch / 2 - 5, y - 5.4)])
        var straw = Path(), coils = Path(), mouths = Path(), sunlit = Path(), binding = Path()
        for index in 0..<total {
            let cx = x + (CGFloat(index) - CGFloat(total - 1) / 2) * pitch
            let w = 9.4 + CGFloat(Self.noise(index, 461)) * 2.2, h = 10.5 + CGFloat(Self.noise(index, 463)) * 3.2
            var hive = Path()
            hive.move(to: point(cx - w / 2, y))
            hive.addCurve(to: point(cx, y + h), control1: point(cx - w * 0.58, y + h * 0.62), control2: point(cx - w * 0.30, y + h))
            hive.addCurve(to: point(cx + w / 2, y), control1: point(cx + w * 0.30, y + h), control2: point(cx + w * 0.58, y + h * 0.62))
            hive.closeSubpath()
            straw.addPath(hive)
            straw.addPath(discPath(cx, y + h + 0.4, 0.9))
            // The coils of straw it is wound from, and the small door at its foot.
            for coil in 1...4 {
                let level = h * CGFloat(coil) / 5.2
                let half = w * 0.5 * CGFloat(sqrt(max(0.05, 1 - pow(Double(level / h), 2.2)))) * 1.02
                coils.addPath(polygon([(cx - half, y + level), (cx, y + level - 0.6), (cx + half, y + level), (cx, y + level - 1.1)]))
                for stitch in -2...2 {
                    let sx = cx + CGFloat(stitch) * half * 0.34
                    let dip = abs(CGFloat(stitch)) * 0.18
                    binding.addPath(strokePath([(sx - 0.25, y + level - 0.9 + dip),
                                                (sx + 0.25, y + level - 0.2 + dip)], 0.25))
                }
            }
            mouths.addPath(archPath(cx, 2.2, 2.4, from: y, pointed: false))
            sunlit.addPath(polygon([(cx - w * 0.36, y + h * 0.20), (cx - w * 0.22, y + h * 0.20), (cx - w * 0.10, y + h * 0.84), (cx - w * 0.22, y + h * 0.70)]))
        }
        add(straw)
        tint(straw, shade(0.82, 0.66, 0.36))
        tint(coils, Color.black.opacity(0.20))
        tint(binding, shade(0.98, 0.84, 0.55, 0.50))
        tint(sunlit, Color.white.opacity(0.16))
        tint(mouths, Color.black.opacity(0.62))
    }

    /// A spider's web between two stems, dew glinting along it (no spider). Moves.
    mutating func web(_ x: CGFloat, _ y: CGFloat, radius r: CGFloat = 26) {
        let breeze = CGFloat(sin(time * 0.7 + Double(x) * 0.1)), reach = r + 6, tall = y + r + 12
        func stem(_ side: CGFloat, _ at: CGFloat) -> CGFloat {
            let part = at / tall
            return x + side * reach + side * CGFloat(sin(Double(part) * Double.pi)) * 3 + breeze * 1.4 * part * part
        }
        // The two stems, a leaf or two on each, a seed head at the top.
        for side in [-1.0, 1.0] as [CGFloat] {
            let top = tall * (side > 0 ? 1 : 0.9)
            var near: [Spot] = [], far: [Spot] = []
            for step in 0...8 {
                let at = top * CGFloat(step) / 8, half = 1.1 - 0.8 * CGFloat(step) / 8
                near.append((stem(side, at) - half, at)); far.append((stem(side, at) + half, at))
            }
            shape(near + far.reversed())
            for (at, long) in [(top * 0.22, 9.0), (top * 0.50, 7.0)] as [(CGFloat, CGFloat)] {
                let sx = stem(side, at)
                add(smoothPath([(sx, at), (sx + side * long * 0.45, at + long * 0.5 + breeze * 0.4), (sx + side * long, at + long * 0.42 + breeze * 0.8), (sx + side * long * 0.5, at + long * 0.16)]))
                tint(strokePath([(sx, at), (sx + side * long * 0.44, at + long * 0.28 + breeze * 0.35),
                                 (sx + side * long * 0.83, at + long * 0.40 + breeze * 0.7)], 0.30, smooth: true),
                     shade(0.80, 0.86, 0.62, 0.42))
            }
            add(smoothPath([(stem(side, top) - 1.3, top - 1), (stem(side, top) - 1.5, top + 3), (stem(side, top), top + 6.4), (stem(side, top) + 1.5, top + 3), (stem(side, top) + 1.3, top - 1)]))
        }
        // The web: spokes from its centre, the turns of the spiral, and the threads that hold it to the stems.
        let centre: Spot = (x + breeze * 0.9, y + CGFloat(sin(time * 0.9)) * 0.4)
        var ends: [Spot] = []
        for spoke in 0..<14 {
            let angle = Double(spoke) / 14 * 2 * Double.pi + 0.2
            let far = r * (0.88 + 0.12 * CGFloat(Self.noise(spoke, 473)))
            ends.append((centre.0 + CGFloat(cos(angle)) * far, centre.1 + CGFloat(sin(angle)) * far * 0.97))
        }
        var threads = Path()
        func place(_ spot: Spot) -> CGPoint { point(spot.0, spot.1) }
        for (index, end) in ends.enumerated() {
            threads.move(to: place(centre)); threads.addLine(to: place(end))
            threads.move(to: place(end)); threads.addLine(to: place(ends[(index + 1) % ends.count]))
        }
        let holds: [(Int, CGFloat, CGFloat)] = [(0, 1, 0.06), (1, 1, 0.80), (5, -1, 0.92), (7, -1, 0.02), (8, -1, -0.70), (12, 1, -0.78)]
        for hold in holds {
            let height = y + r * hold.2
            threads.move(to: place(ends[hold.0])); threads.addLine(to: point(stem(hold.1, height), height))
        }
        threads.move(to: point(stem(-1, y + r * 0.92), y + r * 0.92))
        threads.addQuadCurve(to: point(stem(1, y + r * 0.80), y + r * 0.80), control: point(x, y + r * 1.02))
        var nodes: [Spot] = []
        for ring in 1...7 {
            let part = CGFloat(ring) / 8.4 + 0.03
            for (index, end) in ends.enumerated() {
                let next = ends[(index + 1) % ends.count]
                let a: Spot = (centre.0 + (end.0 - centre.0) * part, centre.1 + (end.1 - centre.1) * part)
                let b: Spot = (centre.0 + (next.0 - centre.0) * part, centre.1 + (next.1 - centre.1) * part)
                let sag: Spot = ((a.0 + b.0) / 2 + (centre.0 - (a.0 + b.0) / 2) * 0.12, (a.1 + b.1) / 2 + (centre.1 - (a.1 + b.1) / 2) * 0.12)
                threads.move(to: place(a)); threads.addQuadCurve(to: place(b), control: place(sag))
                if (ring * 5 + index * 3) % 9 < 2 { nodes.append(a) }
            }
        }
        tint(threads.strokedPath(StrokeStyle(lineWidth: 0.45, lineCap: .round)), Color.white.opacity(0.46 - 0.10 * night))
        // Dew along it, each drop catching the light in its turn.
        for (index, node) in nodes.enumerated() {
            let wave = 0.5 + 0.5 * sin(time * (0.9 + Self.noise(index, 471)) + Double(index) * 1.9)
            tint(discPath(node.0, node.1, 0.7 + 0.5 * CGFloat(wave)), Color.white.opacity(0.35 + 0.6 * wave))
            if index % 4 == 0 { tint(sparklePath(node.0, node.1, 1.6 + 1.8 * CGFloat(wave)), Color.white.opacity(0.5 * wave)) }
        }
    }

    /// A bundle of firewood bound with palm-fibre rope, a fire beside it. Moves.
    mutating func firewood(_ x: CGFloat) {
        let bx = x - 13
        // The sticks, laid one on another, their ends uneven.
        let sticks: [(CGFloat, CGFloat, CGFloat, CGFloat, Double)] = [
            (0, 1.9, 46, 3.3, 0.0), (-2, 4.9, 40, 3.0, 0.03), (3, 7.6, 48, 2.8, -0.025), (-1, 10.2, 38, 2.6, 0.045), (2, 12.4, 42, 2.2, -0.012), (-3, 14.3, 30, 1.8, 0.06)
        ]
        var ends = Path(), edges = Path(), grain = Path()
        for (index, stick) in sticks.enumerated() {
            let cx = bx + stick.0, half = stick.2 / 2, t = stick.3 / 2
            let centre: Spot = (cx, stick.1)
            let outline: [Spot] = [(cx - half, stick.1 - t * 0.8), (cx - half * 0.3, stick.1 - t), (cx + half, stick.1 - t), (cx + half, stick.1 + t),
                                   (cx + half * 0.2, stick.1 + t), (cx + half * 0.1, stick.1 + t + 1.5), (cx + half * 0.02, stick.1 + t), (cx - half, stick.1 + t * 0.7)]
            shape(outline.map { turn($0, about: centre, by: stick.4) })
            edges.addPath(polygon([(cx - half, stick.1 + t * 0.7), (cx + half, stick.1 + t), (cx + half, stick.1 + t - 0.55), (cx - half, stick.1 + t * 0.7 - 0.55)]
                .map { turn($0, about: centre, by: stick.4) }))
            let cut = turn((cx + half - 0.2, stick.1), about: centre, by: stick.4)
            ends.addPath(Path(ellipseIn: CGRect(x: point(cut.0, cut.1).x - 0.8, y: point(cut.0, cut.1).y - t * 0.8, width: 1.6, height: t * 1.6)))
            grain.addPath(strokePath([(cx - half * 0.82, stick.1 - t * 0.22), (cx - half * 0.3, stick.1 - t * 0.12),
                                      (cx + half * 0.38, stick.1 - t * 0.32), (cx + half * 0.82, stick.1 - t * 0.15)]
                .map { turn($0, about: centre, by: stick.4) }, 0.35, smooth: true))
            if index % 2 == 0 {
                let twig = turn((cx - half * 0.5, stick.1 + t), about: centre, by: stick.4)
                line([twig, (twig.0 - 3.4, twig.1 + 2.6)], 0.8)
            }
        }
        detail(edges, strength: 0.7)
        detail(ends, strength: 1.5)
        tint(grain, Color.black.opacity(0.26))
        // The rope: two turns round the bundle, twisted, knotted on top, a loop to carry it by.
        let rope = shade(0.84, 0.72, 0.46)
        var twists = Path()
        for band in [-10.0, 11.0] as [CGFloat] {
            let rx = bx + band
            tint(polygon([(rx - 1.5, 0.3), (rx + 1.5, 0.3), (rx + 1.7, 14.8 + (band > 0 ? -0.8 : 1.0)), (rx - 1.1, 15.2 + (band > 0 ? -0.8 : 1.0))]), rope)
            for twist in stride(from: CGFloat(1.4), through: 13.4, by: 2.4) {
                twists.addPath(strokePath([(rx - 1.4, twist), (rx + 1.5, twist + 1.3)], 0.45))
            }
        }
        tint(twists, Color.black.opacity(0.30))
        tint(strokePath([(bx - 10, 15.6), (bx - 5, 21.4), (bx + 5, 21.8), (bx + 11, 14.6)], 1.1, smooth: true), rope)
        tint(discPath(bx - 10, 16.2, 1.5), rope)
        tint(strokePath([(bx - 10, 16.2), (bx - 14.4, 18.4), (bx - 16, 16.4)], 0.8, smooth: true), rope)
        tint(strokePath([(bx - 10, 16.2), (bx - 12.6, 13.6), (bx - 15.4, 13.4)], 0.8, smooth: true), rope)
        campfire(x + 33, 0, scale: 1.15)
    }

    /// Small mounds across a valley floor (no ants).
    mutating func anthills(from left: CGFloat, to right: CGFloat) {
        let span = max(1, right - left), count = max(3, Int(span / 30))
        let earth = shade(0.70, 0.58, 0.40, 0.92), lit = shade(0.96, 0.86, 0.64, 0.50)
        // Those on the skyline: steep little cones of spoil, a hollow at the top of each.
        var far = Path(), farLight = Path(), farHoles = Path()
        for index in 0..<count {
            let px = left + span * (CGFloat(index) + 0.2 + 0.6 * CGFloat(Self.noise(index, 481))) / CGFloat(count)
            let h = 6 + CGFloat(Self.noise(index, 483)) * 6.5, w = h * (2.0 + 0.8 * CGFloat(Self.noise(index, 485)))
            var cone = Path()
            cone.move(to: point(px - w / 2, 0))
            cone.addQuadCurve(to: point(px - 1.5, h), control: point(px - w * 0.15, h * 0.20))
            cone.addQuadCurve(to: point(px + 1.5, h), control: point(px, h - 1.7))
            cone.addQuadCurve(to: point(px + w / 2, 0), control: point(px + w * 0.15, h * 0.20))
            cone.closeSubpath()
            far.addPath(cone)
            farLight.addPath(polygon([(px - w * 0.36, h * 0.06), (px - 1.6, h * 0.94), (px - 0.5, h * 0.70), (px - w * 0.14, h * 0.06)]))
            farHoles.addEllipse(in: CGRect(x: point(px - 1.3, 0).x, y: point(0, h - 0.4).y, width: 2.6, height: 1.2))
        }
        add(far)
        tint(far, earth)
        tint(farLight, lit)
        tint(farHoles, Color.black.opacity(0.60))
        // Those on the valley floor, larger as they come nearer: each a cone with its hole, lit on one side, grains spilt round it.
        var cones = Path(), shadows = Path(), lights = Path(), holes = Path(), grains = Path(), ridges = Path()
        for index in 0..<(count + 3) {
            let down = 5 + CGFloat(Self.noise(index, 487)) * 22, size = 0.9 + down / 14
            let px = left + span * CGFloat(Self.noise(index, 489)), py = -down
            let h = 4.6 * size, w = 10.5 * size
            var cone = Path()
            cone.move(to: point(px - w / 2, py))
            cone.addQuadCurve(to: point(px - w * 0.10, py + h), control: point(px - w * 0.20, py + h * 0.25))
            cone.addLine(to: point(px + w * 0.10, py + h))
            cone.addQuadCurve(to: point(px + w / 2, py), control: point(px + w * 0.20, py + h * 0.25))
            cone.addQuadCurve(to: point(px - w / 2, py), control: point(px, py - h * 0.36))
            cone.closeSubpath()
            cones.addPath(cone)
            shadows.addPath(polygon([(px + w * 0.02, py + h), (px + w * 0.10, py + h), (px + w / 2, py), (px + w * 0.10, py - h * 0.14)]))
            lights.addPath(polygon([(px - w * 0.40, py + h * 0.10), (px - w * 0.10, py + h * 0.96), (px - w * 0.03, py + h * 0.74), (px - w * 0.20, py + h * 0.08)]))
            holes.addEllipse(in: CGRect(x: point(px - w * 0.085, 0).x, y: point(0, py + h + 0.5 * size).y, width: w * 0.17, height: size * 1.1))
            for ridge in 1...2 {
                let fraction = CGFloat(ridge) / 3
                ridges.addPath(strokePath([(px - w * 0.28 * fraction, py + h * (1 - fraction * 0.75)),
                                           (px - w * 0.14 * fraction, py + h * (1 - fraction * 0.82)),
                                           (px + w * 0.28 * fraction, py + h * (1 - fraction * 0.75))],
                                          0.20 * size, smooth: true))
            }
            for grain in 0..<3 {
                grains.addPath(discPath(px + (CGFloat(Self.noise(index * 5 + grain, 491)) - 0.5) * w * 1.5, py - 0.4 - CGFloat(Self.noise(index * 5 + grain, 493)) * 2.4, 0.5 * size))
            }
        }
        tint(cones, shade(0.74, 0.62, 0.43, 0.95))
        tint(shadows, Color.black.opacity(0.24))
        tint(lights, lit)
        tint(ridges, Color.black.opacity(0.20))
        tint(grains, shade(0.80, 0.68, 0.48, 0.8))
        tint(holes, Color.black.opacity(0.70))
    }

    // MARK: Life in the landscape

    /// A small, faceless pedestrian for Home's distant skyline. Returns the
    /// outline without assigning a color so Home can match its changing light.
    /// The feet sit on the horizon and the walking pose follows scene time;
    /// Reduce Motion supplies a fixed time, leaving a stable pose.
    func homePedestrian(_ x: CGFloat, scale s: CGFloat = 1) -> Path {
        let step = CGFloat(sin(time * 1.4 + Double(x) * 0.035)) * 0.9 * s
        var person = Path()
        person.addPath(discPath(x, 10.0 * s, 1.25 * s))
        person.addPath(smoothPath([(x - 1.45 * s, 8.3 * s), (x + 1.45 * s, 8.3 * s),
                                   (x + 1.25 * s, 4.0 * s), (x - 1.25 * s, 4.0 * s)]))
        person.addPath(strokePath([(x - 0.65 * s, 4.3 * s), (x - 0.9 * s - step, 0)],
                                  max(0.35, 0.8 * s)))
        person.addPath(strokePath([(x + 0.65 * s, 4.3 * s), (x + 0.9 * s + step, 0)],
                                  max(0.35, 0.8 * s)))
        person.addPath(strokePath([(x - 1.1 * s, 7.6 * s), (x - 2.0 * s + step * 0.3, 4.5 * s)],
                                  max(0.35, 0.65 * s)))
        person.addPath(strokePath([(x + 1.1 * s, 7.6 * s), (x + 2.0 * s - step * 0.3, 4.5 * s)],
                                  max(0.35, 0.65 * s)))
        return person
    }

    /// An anonymous traveler in a loose robe, seen at a distance without facial features.
    mutating func sceneTraveler(_ x: CGFloat, scale s: CGFloat = 1) {
        let sway = CGFloat(sin(time * 0.7 + Double(x) * 0.03)) * 0.35 * s
        let robe = smoothPath([(x - 2.1 * s, 0), (x - 1.8 * s + sway, 7.8 * s),
                               (x - 1.4 * s, 10.5 * s), (x + 1.4 * s, 10.5 * s),
                               (x + 1.8 * s + sway, 7.8 * s), (x + 2.3 * s, 0)])
        tint(robe, shade(0.70, 0.62, 0.50, 0.96))
        tint(discPath(x, 12.2 * s, 1.8 * s), shade(0.63, 0.52, 0.40, 0.98))
        tint(strokePath([(x - 1.8 * s, 9.4 * s), (x - 2.7 * s, 6 * s)], 0.65 * s),
             shade(0.55, 0.46, 0.36, 0.9))
        tint(strokePath([(x + 0.3 * s, 8 * s), (x + 0.5 * s + sway, 1.3 * s)], 0.30 * s),
             Color.black.opacity(0.14))
    }

    /// A small grazing sheep, the fleece and legs kept readable at banner size.
    mutating func grazingSheep(_ x: CGFloat, scale s: CGFloat = 1) {
        let bob = CGFloat(sin(time * 0.55 + Double(x) * 0.03)) * 0.3 * s
        let wool = smoothPath([(x - 5.8 * s, 3.4 * s), (x - 6.0 * s, 7.3 * s),
                               (x - 3.4 * s, 9.0 * s), (x, 8.5 * s), (x + 3.8 * s, 8.8 * s),
                               (x + 6.0 * s, 6.7 * s), (x + 5.2 * s, 3.5 * s)])
        var legs = Path()
        for offset in [-3.9, -1.6, 2.0, 4.1] as [CGFloat] {
            legs.addPath(strokePath([(x + offset * s, 4 * s), (x + offset * s, 0)], 0.9 * s))
        }
        tint(legs, shade(0.48, 0.41, 0.33))
        tint(wool, shade(0.81, 0.77, 0.68, 0.96))
        tint(smoothPath([(x + 4.7 * s, 6.3 * s), (x + 7.5 * s, 5.8 * s + bob),
                         (x + 8.2 * s, 4.2 * s + bob), (x + 5.6 * s, 3.8 * s)]),
             shade(0.58, 0.53, 0.46))
        tint(strokePath([(x - 3.8 * s, 6.8 * s), (x, 7.5 * s), (x + 3 * s, 6.8 * s)], 0.4 * s, smooth: true),
             Color.white.opacity(0.18))
    }

    /// A distant camel in profile, resting its feet on the scene's ground.
    mutating func desertCamel(_ x: CGFloat, scale s: CGFloat = 1) {
        let body = smoothPath([(x - 9 * s, 6 * s), (x - 10 * s, 10 * s), (x - 7 * s, 12 * s),
                               (x - 3 * s, 12 * s), (x - 1 * s, 15 * s), (x + 2 * s, 12 * s),
                               (x + 7 * s, 11 * s), (x + 8 * s, 6 * s)])
        var legs = Path()
        for offset in [-6.2, -3.6, 3.6, 6.0] as [CGFloat] {
            legs.addPath(strokePath([(x + offset * s, 7 * s), (x + (offset + 0.4) * s, 0)], 1.2 * s))
        }
        let neck = smoothPath([(x + 5.3 * s, 8.4 * s), (x + 8.2 * s, 14 * s),
                               (x + 9.3 * s, 19 * s), (x + 13 * s, 19 * s),
                               (x + 15 * s, 17.1 * s), (x + 11.4 * s, 16 * s),
                               (x + 10 * s, 9.2 * s), (x + 7 * s, 6.4 * s)])
        let sand = shade(0.65, 0.51, 0.36, 0.98)
        tint(legs, sand); tint(body, sand); tint(neck, sand)
        tint(strokePath([(x - 6 * s, 8 * s), (x + 4 * s, 8 * s)], 0.45 * s), Color.black.opacity(0.12))
    }

    /// A handful of bees flying close to existing hives and flowers.
    mutating func sceneBees(over x: CGFloat, height: CGFloat, count: Int = 4) {
        var wings = Path(), bodies = Path()
        for index in 0..<max(0, count) {
            let phase = time * 0.8 + Double(index) * 1.9
            let bx = x + (CGFloat(index) - CGFloat(count - 1) / 2) * 8 + CGFloat(sin(phase)) * 2
            let by = height + CGFloat(cos(phase * 0.8)) * 2
            bodies.addPath(discPath(bx, by, 1.1))
            wings.addPath(discPath(bx - 1, by + 1, 0.7))
            wings.addPath(discPath(bx + 1, by + 1, 0.7))
        }
        let daylight = max(0, 1 - night)
        tint(wings, Color.white.opacity(0.58 * daylight))
        tint(bodies, shade(0.78, 0.57, 0.20, 0.90 * daylight))
    }

    // MARK: What is in the sky

    /// A thin new moon. Night only.
    mutating func crescent(_ x: CGFloat, _ y: CGFloat, _ r: CGFloat = 9) {
        glow(x, y, r * 2.8, Color.white, 0.16, nightOnly: true)
        tint(discPath(x, y, r * 0.97), Color.white.opacity(0.06), nightOnly: true)
        tint(crescentPath(x, y, r, tilt: -0.62, fill: 0.70), Color(red: 1.0, green: 0.97, blue: 0.86), nightOnly: true)
        tint(crescentPath(x, y, r * 0.94, tilt: -0.62, fill: 0.78),
             Color(red: 0.80, green: 0.78, blue: 0.71).opacity(0.22), nightOnly: true)
    }

    /// The moon from new to full and back, in a row across the sky. Night only.
    mutating func moonPhases(from left: CGFloat, to right: CGFloat, at y: CGFloat = 150) {
        let lit: [CGFloat] = [0.07, 0.27, 0.50, 0.78, 1, 0.78, 0.50, 0.27, 0.07]
        let pale = Color(red: 0.98, green: 0.96, blue: 0.88)
        for (index, part) in lit.enumerated() {
            // They ride a shallow arc, the full moon highest and a little the largest.
            let along = CGFloat(index) / CGFloat(lit.count - 1), swell = CGFloat(sin(Double(along) * Double.pi))
            let cx = left + (right - left) * along, cy = y - 12 + 12 * swell, r = 5.2 + 1.8 * swell
            tint(discPath(cx, cy, r), Color.white.opacity(0.08), nightOnly: true)
            if part >= 1 {
                glow(cx, cy, r * 2.6, Color.white, 0.20, nightOnly: true)
                tint(discPath(cx, cy, r), pale, nightOnly: true)
                tint(discPath(cx - r * 0.28, cy + r * 0.22, r * 0.24), Color.black.opacity(0.07), nightOnly: true)
                tint(discPath(cx + r * 0.30, cy - r * 0.18, r * 0.18), Color.black.opacity(0.06), nightOnly: true)
                tint(discPath(cx + r * 0.02, cy + r * 0.46, r * 0.09), Color.black.opacity(0.05), nightOnly: true)
                tint(discPath(cx - r * 0.48, cy - r * 0.28, r * 0.08), Color.black.opacity(0.05), nightOnly: true)
            } else {
                // Waxing, the light is on the right; waning, on the left.
                tint(crescentPath(cx, cy, r, tilt: index < 4 ? -0.12 : Double.pi + 0.12, fill: 1 - 2 * part), pale, nightOnly: true)
            }
        }
    }

    /// Great figures of stars joined by faint lines, twinkling. Night only. Moves.
    mutating func constellations(over x: CGFloat, height: CGFloat = 170) {
        let figures: [([Spot], [(Int, Int)])] = [
            ([(-106, 0.60), (-91, 0.69), (-76, 0.71), (-62, 0.80), (-50, 0.95), (-33, 0.91), (-40, 0.76)], [(0, 1), (1, 2), (2, 3), (3, 4), (4, 5), (5, 6), (6, 3)]),
            ([(-10, 0.97), (3, 0.81), (18, 0.92), (30, 0.77), (45, 0.91)], [(0, 1), (1, 2), (2, 3), (3, 4)]),
            ([(72, 0.58), (85, 0.73), (101, 0.69), (93, 0.88), (112, 0.95), (77, 0.47)], [(0, 1), (1, 2), (1, 3), (3, 4), (0, 5)]),
            ([(-22, 0.50), (-3, 0.60), (-12, 0.42), (16, 0.47)], [(0, 1), (1, 2), (2, 0), (1, 3)])
        ]
        for (index, figure) in figures.enumerated() {
            let stars = figure.0.map { (x + $0.0, $0.1 * height) }
            var links = Path()
            for link in figure.1 {
                // The lines stop short of the stars they join.
                let a = stars[link.0], b = stars[link.1]
                links.addPath(strokePath([(a.0 + (b.0 - a.0) * 0.16, a.1 + (b.1 - a.1) * 0.16), (a.0 + (b.0 - a.0) * 0.84, a.1 + (b.1 - a.1) * 0.84)], 0.55))
            }
            tint(links, Color.white.opacity(0.20 + 0.08 * sin(time * 0.4 + Double(index) * 1.6)), nightOnly: true)
            for (star, place) in stars.enumerated() {
                let id = index * 10 + star
                let twinkle = 0.70 + 0.30 * sin(time * (1.1 + Self.noise(id, 501)) + Double(id) * 2.1)
                let size = 1.1 + CGFloat(Self.noise(id, 503)) * 1.0
                tint(discPath(place.0, place.1, size * 2.8), Color.white.opacity(0.10 * twinkle), nightOnly: true)
                if size > 1.6 { tint(sparklePath(place.0, place.1, size * 3.2, waist: 0.14), Color.white.opacity(0.5 * twinkle), nightOnly: true) }
                tint(discPath(place.0, place.1, size), Color(red: 1.0, green: 0.96, blue: 0.84).opacity(twinkle), nightOnly: true)
                tint(discPath(place.0 - size * 0.2, place.1 + size * 0.2, size * 0.32), Color.white.opacity(0.75 * twinkle), nightOnly: true)
            }
        }
    }

    /// One piercing star with rays that turn. Night only. Moves.
    mutating func brightStar(_ x: CGFloat, _ y: CGFloat) {
        let pulse = 0.86 + 0.14 * sin(time * 1.7), around = time * 0.12
        glow(x, y, 20, Color(red: 0.86, green: 0.92, blue: 1.0), 0.34 * pulse, nightOnly: true)
        tint(sparklePath(x, y, 9, turn: around + Double.pi / 4, waist: 0.10), Color.white.opacity(0.45 * pulse), nightOnly: true)
        tint(sparklePath(x, y, 19 * CGFloat(pulse), turn: around, waist: 0.055), Color.white.opacity(0.85), nightOnly: true)
        tint(discPath(x, y, 2.3), .white, nightOnly: true)
        tint(discPath(x, y, 0.9), Color(red: 0.90, green: 0.96, blue: 1.0), nightOnly: true)
    }

    /// The sun with slowly turning rays; fades out at night. Moves.
    mutating func sun(_ x: CGFloat, _ y: CGFloat, _ r: CGFloat = 14) {
        let day = 1 - night
        guard day > 0.02 else { return }
        let breath = 0.92 + 0.08 * sin(time * 0.9), warm = Color(red: 1.0, green: 0.74, blue: 0.32)
        glow(x, y, r * 3.2, warm, 0.34 * day * breath)
        var rays = Path()
        for ray in 0..<12 {
            let angle = Double(ray) * Double.pi / 6 + time * 0.08
            let far = r * (ray % 2 == 0 ? 1.80 : 1.52), near = r * 1.20, half = 0.085
            rays.addPath(polygon([(x + near * CGFloat(cos(angle - half)), y + near * CGFloat(sin(angle - half))),
                                  (x + far * CGFloat(cos(angle)), y + far * CGFloat(sin(angle))),
                                  (x + near * CGFloat(cos(angle + half)), y + near * CGFloat(sin(angle + half)))]))
        }
        tint(rays, warm.opacity(0.75 * day))
        tint(discPath(x, y, r), Color(red: 1.0, green: 0.80, blue: 0.38).opacity(day))
        tint(discPath(x - r * 0.10, y + r * 0.10, r * 0.72), Color(red: 1.0, green: 0.90, blue: 0.60).opacity(0.5 * day))
        tint(discPath(x - r * 0.18, y + r * 0.18, r * 0.38), Color(red: 1.0, green: 0.96, blue: 0.75).opacity(0.20 * day))
    }

    /// The sun and the moon brought together in one place.
    mutating func sunAndMoon(_ x: CGFloat, _ y: CGFloat) {
        let breath = 0.90 + 0.10 * sin(time * 0.5)
        let ember = Color(red: 1.0, green: 0.60, blue: 0.26)
        // One light about them both.
        glow(x, y, 36, ember, 0.26 * breath)
        // The sun, its rays short on the side the moon has not reached.
        var rays = Path()
        for ray in 0..<9 {
            let angle = Double.pi * (0.56 + Double(ray) * 0.11)
            let far: CGFloat = ray % 2 == 0 ? 19.5 : 17.2
            rays.addPath(polygon([(x - 8 + 14.6 * CGFloat(cos(angle - 0.07)), y + 14.6 * CGFloat(sin(angle - 0.07))),
                                  (x - 8 + far * CGFloat(cos(angle)), y + far * CGFloat(sin(angle))),
                                  (x - 8 + 14.6 * CGFloat(cos(angle + 0.07)), y + 14.6 * CGFloat(sin(angle + 0.07)))]))
        }
        tint(rays, ember.opacity(0.7))
        tint(discPath(x - 8, y, 12.5), Color(red: 1.0, green: 0.66, blue: 0.28))
        tint(discPath(x - 9, y + 1, 8.6), Color(red: 1.0, green: 0.80, blue: 0.46).opacity(0.5))
        // The moon over it, its own light gone: grey, with the sun's edge showing round it.
        tint(discPath(x + 8.5, y + 1.5, 12.2), Color(red: 1.0, green: 0.86, blue: 0.60).opacity(0.75))
        tint(discPath(x + 8.5, y + 1.5, 11.4), Color(red: 0.50, green: 0.52, blue: 0.60))
        tint(crescentPath(x + 8.5, y + 1.5, 11.4, tilt: 0.3, fill: 0.72), Color(red: 0.74, green: 0.76, blue: 0.82))
        tint(discPath(x + 5.4, y + 4.6, 2.4), Color.black.opacity(0.10))
        tint(discPath(x + 10.6, y - 3.2, 1.7), Color.black.opacity(0.09))
        tint(discPath(x + 6.6, y - 4.4, 1.1), Color.black.opacity(0.08))
        tint(discPath(x + 11.8, y + 5.2, 0.8), Color.black.opacity(0.10))
        tint(discPath(x + 3.8, y - 0.6, 0.65), Color.white.opacity(0.16))
    }

    /// Smoke drawn in a long band across the sky, drifting. Moves.
    mutating func smokeBand(at y: CGFloat = 120) {
        let left = leftEdge, span = rightEdge - left
        let grey = Color(red: 0.45 + 0.08 * night, green: 0.42 + 0.08 * night, blue: 0.41 + 0.10 * night)
        for index in 0..<13 {
            let run = (Self.noise(index, 601) + time * (0.006 + 0.005 * Self.noise(index, 603))).truncatingRemainder(dividingBy: 1)
            let wide = 96 + CGFloat(Self.noise(index, 605)) * 96, tall = 9 + CGFloat(Self.noise(index, 607)) * 11
            let cx = left - wide / 2 + (span + wide) * CGFloat(run)
            let cy = y + (CGFloat(Self.noise(index, 609)) - 0.5) * 17 + CGFloat(sin(time * 0.2 + Double(index))) * 1.5
            tint(crownPath(cx, cy, wide / 2, tall / 2, lobes: 7, depth: 0.22, seed: index + 9, flat: 0.5), grey.opacity(0.13 + 0.04 * Self.noise(index, 611)))
            if index % 2 == 0 {
                tint(crownPath(cx - wide * 0.12, cy + tall * 0.16, wide * 0.18, tall * 0.16,
                               lobes: 5, depth: 0.18, seed: index + 23), Color.white.opacity(0.028))
            }
            if index % 3 == 0 {
                // A darker heart to the band here and there.
                tint(crownPath(cx + wide * 0.08, cy - 1, wide * 0.28, tall * 0.26, lobes: 6, depth: 0.22, seed: index + 49), grey.opacity(0.12))
            }
        }
    }

    /// A dark cloud bank that drifts, lightning forking from it now and then. Moves.
    mutating func stormCloud(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat = 120, lightning: Bool = true) {
        let cx = x + CGFloat(sin(time * 0.11 + Double(x) * 0.01)) * 9, h = w * 0.32
        func bank(_ bx: CGFloat, _ by: CGFloat, _ bw: CGFloat, _ bh: CGFloat, _ seed: Int) -> Path {
            // A flat dark base and a heaped top.
            var spots: [Spot] = [(bx - bw * 0.50, by + bh * 0.06), (bx - bw * 0.47, by + bh * 0.30)]
            let heaps = 6
            for heap in 0..<heaps {
                let part = (CGFloat(heap) + 0.5) / CGFloat(heaps)
                let tall = bh * (0.52 + 0.48 * CGFloat(sin(Double(part) * Double.pi))) * (0.82 + 0.3 * CGFloat(Self.noise(seed + heap, 613)))
                spots.append((bx - bw * 0.42 + bw * 0.84 * part - bw * 0.05, by + tall * 0.74))
                spots.append((bx - bw * 0.42 + bw * 0.84 * part, by + tall))
            }
            spots += [(bx + bw * 0.47, by + bh * 0.30), (bx + bw * 0.50, by + bh * 0.06), (bx + bw * 0.30, by - bh * 0.06), (bx, by - bh * 0.02), (bx - bw * 0.30, by - bh * 0.07)]
            return smoothPath(spots)
        }
        let back = bank(cx + w * 0.13, y + h * 0.16, w * 0.82, h * 0.96, 3), front = bank(cx, y, w, h, 11)
        let lift = 0.05 * night
        tint(back, Color(red: 0.36 - 0.14 * night, green: 0.38 - 0.14 * night, blue: 0.46 - 0.14 * night).opacity(0.90))
        tint(front, Color(red: 0.21 - 0.08 * night + lift, green: 0.23 - 0.08 * night + lift, blue: 0.29 - 0.07 * night + lift).opacity(0.96))
        tint(smoothPath([(cx - w * 0.46, y + h * 0.10), (cx - w * 0.2, y + h * 0.22), (cx + w * 0.2, y + h * 0.20), (cx + w * 0.46, y + h * 0.10), (cx + w * 0.28, y - h * 0.05), (cx - w * 0.28, y - h * 0.06)]),
             Color.black.opacity(0.13))
        tint(bank(cx - w * 0.10, y + h * 0.34, w * 0.5, h * 0.52, 17), Color.white.opacity(0.05))
        // Soft, irregular light on the lifted cloud edges, carried with the
        // same drift as the bank rather than fixed to the sky.
        var cloudRims = Path()
        for puff in 0..<5 {
            let px = cx - w * 0.32 + CGFloat(puff) * w * 0.16
            let py = y + h * (0.42 + CGFloat(Self.noise(puff, 617)) * 0.18)
            cloudRims.addPath(strokePath([(px - w * 0.05, py), (px, py + h * 0.08),
                                          (px + w * 0.055, py + h * 0.02)], max(0.35, w * 0.003), smooth: true))
        }
        tint(cloudRims, Color.white.opacity(0.10 - 0.035 * night))
        // Now and then a fork of lightning, and the cloud lit from inside.
        guard lightning, time != 0 else { return }
        let every = 6.5, cycle = time / every + Double(x) * 0.013
        let turn = floor(cycle), since = (cycle - turn) * every
        guard since < 0.6 else { return }
        let flash = since < 0.2 ? sin(since / 0.2 * Double.pi) : since > 0.28 ? sin((since - 0.28) / 0.32 * Double.pi) * 0.6 : 0
        guard flash > 0.01 else { return }
        let seed = Int(turn.truncatingRemainder(dividingBy: 10_000))
        var px = cx + (CGFloat(Self.noise(seed, 615)) - 0.5) * w * 0.5, py = y - h * 0.02
        var bolt: [Spot] = [(px, py)], fork: [Spot] = []
        let drop = max(6, (py - 3) / 7)
        for step in 0..<7 {
            px += (CGFloat(Self.noise(seed * 7 + step, 617)) - 0.5) * 16
            py -= drop * (0.8 + 0.4 * CGFloat(Self.noise(seed * 7 + step, 619)))
            bolt.append((px, max(1, py)))
            if step == 2 { fork = [(px, py), (px + 9, py - drop * 0.8), (px + 12, py - drop * 1.9), (px + 19, py - drop * 2.5)] }
        }
        tint(front, Color.white.opacity(0.26 * flash))
        tint(strokePath(bolt, 4.5), Color.white.opacity(0.10 * flash))
        tint(strokePath(bolt, 1.3), Color.white.opacity(0.92 * flash))
        tint(strokePath(fork, 0.8), Color.white.opacity(0.75 * flash))
    }

    /// Seven faint arcs of sky, one above another, with stars. Moves.
    mutating func sevenHeavens(over x: CGFloat) {
        for level in 0..<7 {
            let r = 64 + CGFloat(level) * 21, rise = CGFloat(level) / 6
            // Light passes up through them, one after another.
            let breath = 0.5 + 0.5 * sin(time * 0.3 - Double(level) * 0.7)
            let tone = Color(red: 0.62 + 0.38 * Double(rise), green: 0.78 + 0.14 * Double(rise), blue: 1.0 - 0.26 * Double(rise))
            var whole: [Spot] = []
            for step in 0...28 {
                let angle = Double.pi * (0.13 + 0.74 * Double(step) / 28)
                whole.append((x + r * CGFloat(cos(angle)), -16 + r * CGFloat(sin(angle))))
            }
            let crown = Array(whole[5...23])
            tint(strokePath(whole, 5.5), tone.opacity(0.022 + 0.018 * breath))
            tint(strokePath(whole, 0.9), tone.opacity(0.09 + 0.07 * breath))
            tint(strokePath(crown, 1.1), tone.opacity(0.12 + 0.12 * breath))
            tint(strokePath(Array(whole[9...19]), 0.35), Color.white.opacity(0.08 + 0.04 * breath))
            // Stars travelling along each of them.
            for star in 0..<3 {
                let id = level * 3 + star
                let drift = Self.noise(id, 621) + time * 0.004 * (level % 2 == 0 ? 1 : -1)
                let angle = Double.pi * (0.20 + 0.60 * (drift - floor(drift)))
                let twinkle = 0.65 + 0.35 * sin(time * (1.0 + Self.noise(id, 623)) + Double(id) * 1.7)
                let sx = x + r * CGFloat(cos(angle)), sy = -16 + r * CGFloat(sin(angle))
                tint(discPath(sx, sy, 3.4), Color.white.opacity(0.12 * twinkle), nightOnly: true)
                tint(discPath(sx, sy, 1.2), Color.white.opacity((0.30 + 0.65 * night) * twinkle))
            }
        }
    }

    /// The sky torn open in a bright rift, light spilling. Moves.
    mutating func riftInSky(_ x: CGFloat) {
        let top: CGFloat = 200, bottom: CGFloat = 62, breath = CGFloat(0.90 + 0.10 * sin(time * 0.6))
        let light = Color(red: 1.0, green: 0.93, blue: 0.74)
        // The seam: all but upright, parting slowly from the top, gaping widest below its middle,
        // closing again in a point. Its two edges are ragged, each in its own way, as torn cloth is.
        var seam: [(CGFloat, CGFloat, CGFloat, CGFloat)] = []
        let steps = 18
        for step in 0...steps {
            let part = Double(step) / Double(steps)
            let lean = CGFloat(sin(part * 2.6 + 0.4)) * 3
            let open = part < 0.62 ? pow(part / 0.62, 1.5) : pow(max(0, (1 - part) / 0.38), 0.8)
            let gape = step == 0 || step == steps ? 0 : 13.5 * CGFloat(open) * breath
            seam.append((x + lean, top - (top - bottom) * CGFloat(part),
                         gape * (0.84 + 0.32 * CGFloat(Self.noise(step, 633))), gape * (0.84 + 0.32 * CGFloat(Self.noise(step, 635)))))
        }
        func tear(_ wide: CGFloat, _ more: CGFloat) -> Path {
            let near = seam.map { ($0.0 - $0.2 * wide - more * min(1, $0.2 / 4), $0.1) }
            let far = seam.reversed().map { ($0.0 + $0.3 * wide + more * min(1, $0.3 / 4), $0.1) }
            return polygon(near + far)
        }
        let widest = seam[11], low = seam[15]
        // What comes through it: a soft brightness about the seam, and light falling from it, widening to the ground.
        glow(x, widest.1 + 14, 70, light, 0.09 * Double(breath), tall: 1.25)
        for (index, reach) in [118.0, 88.0, 60.0, 36.0, 17.0].enumerated() {
            let shimmer = 0.75 + 0.25 * sin(time * 0.5 + Double(index) * 1.3)
            let from = index < 2 ? widest : low, half = max(2, (from.2 + from.3) / 2 * (index < 2 ? 0.9 : 0.6))
            tint(polygon([(from.0 - half, from.1), (from.0 + half, from.1), (x + CGFloat(reach), 2), (x - CGFloat(reach), 2)]),
                 light.opacity((0.026 + 0.012 * Double(index)) * shimmer))
        }
        // The crack running on above the opening and below it, where the tear has only begun.
        tint(strokePath([(seam[0].0, top), (x - 1.5, top + 16), (x + 1, top + 34)], 0.9, smooth: true), light.opacity(0.55))
        tint(strokePath([(seam[steps].0, bottom), (seam[steps].0 + 1.2, bottom - 8), (seam[steps].0 - 0.6, bottom - 15)], 0.7, smooth: true), light.opacity(0.40))
        // The opening itself, brightest at its heart.
        tint(tear(3.0, 5), light.opacity(0.05))
        tint(tear(2.1, 3), light.opacity(0.10))
        tint(tear(1.45, 1.4), light.opacity(0.22))
        tint(tear(1.0, 0), Color(red: 1.0, green: 0.96, blue: 0.84).opacity(0.97))
        tint(tear(0.5, 0), Color.white.opacity(0.85))
        // The torn edges of the sky, curling back from it.
        var shreds = Path()
        for step in [4, 7, 10, 13, 15] {
            let from = seam[step], to = seam[step + 1]
            shreds.addPath(polygon([(from.0 - from.2, from.1), (from.0 - from.2 - 3.5 - from.2 * 0.28, from.1 - 2.6), (to.0 - to.2, to.1)]))
        }
        for step in [5, 8, 11, 14, 16] {
            let from = seam[step], to = seam[step + 1]
            shreds.addPath(polygon([(from.0 + from.3, from.1), (from.0 + from.3 + 3.5 + from.3 * 0.28, from.1 - 2.6), (to.0 + to.3, to.1)]))
        }
        tint(shreds, light.opacity(0.34))
        var innerEdges = Path()
        for step in 1..<steps {
            let a = seam[step], b = seam[step + 1]
            innerEdges.addPath(strokePath([(a.0 - a.2, a.1), (b.0 - b.2, b.1)], 0.35))
            innerEdges.addPath(strokePath([(a.0 + a.3, a.1), (b.0 + b.3, b.1)], 0.35))
        }
        tint(innerEdges, Color.white.opacity(0.38))
        // Motes of light drifting down out of it.
        for index in 0..<14 {
            let fall = (Self.noise(index, 637) + time * (0.03 + 0.03 * Self.noise(index, 639))).truncatingRemainder(dividingBy: 1)
            let from = seam[8 + index % 8]
            let px = from.0 + (CGFloat(Self.noise(index, 641)) - 0.5) * (10 + 150 * CGFloat(fall))
            tint(discPath(px, from.1 - CGFloat(fall) * (from.1 - 8), 0.8 + CGFloat(Self.noise(index, 643))), light.opacity(0.7 * sin(fall * Double.pi)))
        }
    }

    /// Many stars dropping out of the sky. Night only. Moves.
    mutating func fallingStars(over x: CGFloat, spread: CGFloat = 220) {
        let top: CGFloat = 198
        for index in 0..<15 {
            let fall = (Self.noise(index, 651) + time * (0.035 + 0.035 * Self.noise(index, 653))).truncatingRemainder(dividingBy: 1)
            let px = x + (CGFloat(Self.noise(index, 655)) - 0.5) * spread + CGFloat(fall) * 18
            let py = top - CGFloat(fall * (0.45 + 0.55 * fall)) * (top - 18)
            let strength = sin(fall * Double.pi), tail = 9 + 24 * CGFloat(fall), size = 1.1 + CGFloat(Self.noise(index, 657)) * 0.9
            tint(polygon([(px - size * 0.7, py), (px + size * 0.7, py), (px - tail * 0.10, py + tail)]), Color.white.opacity(0.30 * strength), nightOnly: true)
            tint(strokePath([(px, py + size), (px - tail * 0.07, py + tail * 0.65)], 0.45),
                 Color.white.opacity(0.42 * strength), nightOnly: true)
            tint(discPath(px, py, size * 3), Color.white.opacity(0.12 * strength), nightOnly: true)
            tint(discPath(px, py, size), Color(red: 1.0, green: 0.96, blue: 0.84).opacity(strength), nightOnly: true)
        }
        // Where some have already gone out: faint marks left in the sky.
        for index in 0..<6 {
            let fade = 0.5 + 0.5 * sin(time * 0.3 + Double(index) * 1.9)
            tint(discPath(x + (CGFloat(Self.noise(index, 659)) - 0.5) * spread, 110 + CGFloat(Self.noise(index, 661)) * 80, 0.9), Color.white.opacity(0.25 * fade), nightOnly: true)
        }
    }

    /// Long streaks of wind racing across the sky. Moves.
    mutating func windStreaks(from left: CGFloat, to right: CGFloat, at y: CGFloat = 60) {
        for index in 0..<10 {
            let run = (Self.noise(index, 671) + time * (0.07 + 0.05 * Self.noise(index, 673))).truncatingRemainder(dividingBy: 1)
            let length = 48 + CGFloat(Self.noise(index, 675)) * 64
            let head = left - 10 + (right - left + length + 20) * CGFloat(run)
            let cy = y + (CGFloat(Self.noise(index, 677)) - 0.5) * 58
            let strength = sin(run * Double.pi) * (1 - 0.3 * night)
            var streak: [Spot] = []
            for step in 0...8 {
                let part = CGFloat(step) / 8
                streak.append((head - length * (1 - part), cy + CGFloat(sin(Double(part) * 3.0 + Double(index) + time * 0.8)) * 2.4 * part))
            }
            if index % 3 == 0 {
                // Some curl over at the head.
                let end = streak[8]
                for step in 1...6 {
                    let angle = Double(step) / 6 * 1.6 * Double.pi
                    streak.append((end.0 + 4.6 * CGFloat(sin(angle)), end.1 + 4.6 * (1 - CGFloat(cos(angle)))))
                }
            }
            tint(strokePath(streak, 0.7, smooth: true), Color.white.opacity(0.13 * strength))
            tint(strokePath(Array(streak.suffix(streak.count - 4)), 1.2, smooth: true), Color.white.opacity(0.15 * strength))
            if index % 3 == 1 {
                let wisp = streak[2...6].map { ($0.0, $0.1 - 2.2) }
                tint(strokePath(wisp, 0.35, smooth: true), Color.white.opacity(0.08 * strength))
            }
        }
    }

    /// Tall columns with fire rising behind them. Moves.
    mutating func fireColumns(_ x: CGFloat, count: Int = 4, height: CGFloat = 90) {
        let total = max(1, count), pitch: CGFloat = 26, wide: CGFloat = 7
        let left = x - CGFloat(total - 1) * pitch / 2
        // The fire, seen between the columns and at either end of the row.
        glow(x, height * 0.36, CGFloat(total + 1) * pitch * 0.62, Color(red: 1.0, green: 0.50, blue: 0.16), 0.20 + 0.04 * sin(time * 3.1),
             tall: height * 0.9 / (CGFloat(total + 1) * pitch * 0.62))
        let tongues: [(CGFloat, CGFloat, Double, (Double, Double, Double), Double)] = [
            (1.0, 0.82, 2.1, (0.92, 0.30, 0.10), 0.80), (0.72, 0.60, 2.9, (1.0, 0.54, 0.16), 0.90), (0.40, 0.36, 3.7, (1.0, 0.84, 0.42), 0.95)
        ]
        for gap in 0...total {
            let gx = left + (CGFloat(gap) - 0.5) * pitch
            for (layer, tongue) in tongues.enumerated() {
                let leap = 0.86 + 0.14 * sin(time * tongue.2 + Double(gap) * 1.9 + Double(layer))
                let lean = CGFloat(sin(time * 1.6 + Double(gap) * 1.1 + Double(layer) * 0.7)) * 3.2
                let reach = height * tongue.1 * CGFloat(leap) * (gap == 0 || gap == total ? 0.74 : 1)
                tint(flamePath(gx, 0, width: (pitch - wide - 2.5) * tongue.0, height: reach, lean: lean * tongue.0), Color(red: tongue.3.0, green: tongue.3.1, blue: tongue.3.2).opacity(tongue.4))
            }
        }
        // The columns: base, a shaft narrowing upward, and a spreading capital.
        var flutes = Path(), rims = Path(), joints = Path()
        for index in 0..<total {
            let cx = left + CGFloat(index) * pitch
            block(cx, wide + 4.4, 2); block(cx, wide + 2.2, 1.6, from: 2)
            shape([(cx - wide / 2, 3.6), (cx + wide / 2, 3.6), (cx + wide * 0.42, height - 5.2), (cx - wide * 0.42, height - 5.2)])
            block(cx, wide + 1.2, 1.4, from: height - 5.2)
            shape([(cx - wide * 0.5, height - 3.8), (cx + wide * 0.5, height - 3.8), (cx + wide * 0.5 + 2.4, height - 1.6), (cx - wide * 0.5 - 2.4, height - 1.6)])
            block(cx, wide + 5.6, 1.6, from: height - 1.6)
            flutes.addPath(blockPath(cx - 1.2, 0.6, height - 12, from: 5)); flutes.addPath(blockPath(cx + 1.2, 0.6, height - 12, from: 5))
            rims.addPath(polygon([(cx - wide / 2, 3.6), (cx - wide / 2 + 0.9, 3.6), (cx - wide * 0.42 + 0.9, height - 5.2), (cx - wide * 0.42, height - 5.2)]))
            rims.addPath(polygon([(cx + wide / 2, 3.6), (cx + wide / 2 - 0.9, 3.6), (cx + wide * 0.42 - 0.9, height - 5.2), (cx + wide * 0.42, height - 5.2)]))
            joints.addPath(strokePath([(cx - wide * 0.42, height - 4.2), (cx + wide * 0.42, height - 4.2)], 0.4))
            joints.addPath(strokePath([(cx - wide * 0.45, 4.2), (cx + wide * 0.45, 4.2)], 0.4))
        }
        detail(flutes, strength: 0.5)
        tint(joints, Color.black.opacity(0.28))
        tint(rims, Color(red: 1.0, green: 0.60, blue: 0.24).opacity(0.34 + 0.08 * sin(time * 3.4)))
        for index in 0..<12 {
            let rise = (Self.noise(index, 681) + time * (0.20 + 0.14 * Self.noise(index, 683))).truncatingRemainder(dividingBy: 1)
            let px = left - pitch / 2 + CGFloat(total) * pitch * CGFloat(Self.noise(index, 685)) + CGFloat(sin(time * 0.9 + Double(index))) * 3
            tint(discPath(px, height * (0.25 + 0.9 * CGFloat(rise)), 0.8), Color(red: 1.0, green: 0.74, blue: 0.36).opacity(0.9 * (1 - rise)))
        }
    }

    /// A glow of light growing on the horizon, pulsing slowly. Moves.
    mutating func horizonLight(_ x: CGFloat, spread: CGFloat = 160) {
        let pulse = 0.5 + 0.5 * sin(time * 0.35), grow = CGFloat(0.86 + 0.14 * pulse)
        let light = Color(red: 1.0, green: 0.90, blue: 0.66)
        // Faint rays standing up out of it.
        for ray in 0..<7 {
            let angle = Double.pi * (0.14 + 0.12 * Double(ray)), far = spread * 0.52 * grow
            let shimmer = 0.5 + 0.5 * sin(time * 0.45 + Double(ray) * 1.9)
            for (half, strength) in [(0.10, 0.008), (0.06, 0.010), (0.025, 0.012)] as [(Double, Double)] {
                tint(polygon([(x - 2, 0), (x + 2, 0), (x + far * CGFloat(cos(angle + half)), far * CGFloat(sin(angle + half)) * 0.62),
                              (x + far * CGFloat(cos(angle - half)), far * CGFloat(sin(angle - half)) * 0.62)]), light.opacity(strength * (0.5 + shimmer)))
            }
        }
        for step in 0..<12 {
            let part = CGFloat(step) / 11, wide = 1 - 0.90 * part, tall = 36 * CGFloat(pow(Double(1 - part), 1.25)) + 3
            tint(domePath(x, spread * wide * grow, on: 0, rise: tall * grow), light.opacity((0.028 + 0.030 * Double(part)) * (0.72 + 0.28 * pulse)))
        }
        tint(domePath(x, spread * 0.30 * grow, on: 0, rise: 9 * grow), light.opacity(0.07 * (0.72 + 0.28 * pulse)))
        tint(polygon([(x - spread * 0.46 * grow, 0.2), (x, 1.7), (x + spread * 0.46 * grow, 0.2), (x, -0.7)]), Color.white.opacity(0.40 + 0.25 * pulse))
    }

    /// A road that forks into two, parting towards the horizon.
    mutating func twoPaths(from x: CGFloat) {
        let sand = shade(0.78, 0.66, 0.47, 0.76), worn = shade(0.96, 0.86, 0.66, 0.30), verge = Color.black.opacity(0.24)
        // The one road, broad at the reader's feet, running out to where it divides.
        tint(polygon([(x - 26, -46), (x + 22, -46), (x + 9, -20), (x - 8, -20)]), sand)
        // Two ways from there, each straight to its own place on the horizon: the left the longer.
        tint(polygon([(x - 8, -20), (x + 0.5, -20), (x - 43.2, 0.4), (x - 46.2, 0.4)]), sand)
        tint(polygon([(x + 0.5, -20), (x + 9, -20), (x + 33.2, 0.4), (x + 30.6, 0.4)]), sand)
        // The edges of the road, and the corner of ground the two ways leave between them.
        tint(polygon([(x - 26, -46), (x - 24, -46), (x - 7.2, -20), (x - 8, -20)]), verge)
        tint(polygon([(x + 22, -46), (x + 20, -46), (x + 8.2, -20), (x + 9, -20)]), verge)
        tint(polygon([(x + 0.5, -20), (x - 2.6, -17.4), (x + 3.2, -17.4)]), verge)
        // Ruts worn along it, one pair turning into each way.
        tint(polygon([(x - 12.4, -46), (x - 9.6, -46), (x - 3.4, -20.4), (x - 4.4, -20.4)]), worn)
        tint(polygon([(x + 6.4, -46), (x + 9.2, -46), (x + 5.2, -20.4), (x + 4.2, -20.4)]), worn)
        tint(polygon([(x - 4.4, -20.4), (x - 3.2, -20.4), (x - 44.4, 0.3), (x - 45, 0.3)]), worn)
        tint(polygon([(x + 4.2, -20.4), (x + 5.4, -20.4), (x + 32.2, 0.3), (x + 31.6, 0.3)]), worn)
        // Stones along its edges, smaller as they go.
        var stones = Path()
        for step in 0..<4 {
            let part = CGFloat(step) / 4, y = -43 + 22 * part, size = 1.6 - 0.8 * part
            stones.addPath(discPath(x - 26.4 + 17.6 * part - size, y, size))
            stones.addPath(discPath(x + 22.4 - 12.8 * part + size, y + 2.4 * (1 - part), size * 0.9))
        }
        for step in 1..<4 {
            let part = CGFloat(step) / 4, size = 0.9 - 0.15 * CGFloat(step)
            stones.addPath(discPath(x - 8 - 38.2 * part - 1.2, -20 + 20.4 * part, size))
            stones.addPath(discPath(x + 9 + 24.2 * part + 1.2, -20 + 20.4 * part, size))
        }
        tint(stones, shade(0.60, 0.56, 0.52, 0.9))
        var wear = Path()
        for step in 0..<5 {
            let part = CGFloat(step) / 5, y = -42 + part * 20
            let centre = x + (CGFloat(Self.noise(step, 719)) - 0.5) * (18 - part * 9)
            let length = 1.8 - part * 0.9
            wear.addPath(strokePath([(centre - length, y), (centre, y + 0.35), (centre + length, y)], 0.32, smooth: true))
        }
        tint(wear, shade(0.53, 0.45, 0.36, 0.30))
    }
}
