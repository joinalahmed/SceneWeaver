import SwiftUI
import SceneWeaver

/// The pieces the surah scenes are put together from. Each is drawn onto the
/// horizon with the skyline pen, in points across from the pen's centre and up
/// from the ground, so it takes the colour of the hour like everything else in
/// Home's scene. Pieces that move read the pen's clock; with motion off it
/// stands at zero and they keep still. No person and no animal is drawn.
extension SkylinePen {
    /// A colour of a piece's own, dimmed as it gets dark.
    func shade(_ red: Double, _ green: Double, _ blue: Double, _ opacity: Double = 1) -> Color {
        let light = 1 - (quranScene ? 0.48 : 0.68) * night
        return Color(red: red * light, green: green * light, blue: blue * light).opacity(opacity)
    }

    // MARK: Land and water

    /// A rocky mountain: a shoulder, a broken head, a longer far slope.
    mutating func peak(_ x: CGFloat, _ w: CGFloat, _ h: CGFloat, lean: CGFloat = 0) {
        curve { path, at in
            path.move(to: at(x - w * 0.5, 0))
            path.addQuadCurve(to: at(x - w * 0.34, h * 0.22), control: at(x - w * 0.42, h * 0.05))
            path.addLine(to: at(x - w * 0.27, h * 0.42)); path.addLine(to: at(x - w * 0.235, h * 0.445))
            path.addLine(to: at(x - w * 0.19, h * 0.62)); path.addLine(to: at(x - w * 0.15, h * 0.66))
            path.addLine(to: at(x - w * 0.09 + lean * 0.6, h * 0.86)); path.addLine(to: at(x - w * 0.05 + lean * 0.9, h * 0.90))
            path.addQuadCurve(to: at(x + lean, h), control: at(x - w * 0.02 + lean, h * 0.99))
            path.addLine(to: at(x + w * 0.022 + lean, h * 0.965))
            path.addLine(to: at(x + w * 0.07 + lean * 0.8, h * 0.82)); path.addLine(to: at(x + w * 0.105 + lean * 0.7, h * 0.855))
            path.addLine(to: at(x + w * 0.15 + lean * 0.5, h * 0.74)); path.addLine(to: at(x + w * 0.20, h * 0.665))
            path.addLine(to: at(x + w * 0.235, h * 0.64)); path.addLine(to: at(x + w * 0.30, h * 0.44))
            path.addLine(to: at(x + w * 0.36, h * 0.30))
            path.addQuadCurve(to: at(x + w * 0.5, 0), control: at(x + w * 0.44, h * 0.09))
            path.closeSubpath()
        }
        // The ridge coming down from the summit, a gully, and ledges on the shoulder: thin, and high up.
        var rock = Path()
        rock.addPath(polygon([(x + lean, h), (x + lean + w * 0.008, h * 0.985), (x + w * 0.030 + lean * 0.6, h * 0.74), (x + w * 0.024 + lean * 0.6, h * 0.74)]))
        rock.addPath(polygon([(x + w * 0.07 + lean * 0.8, h * 0.82), (x + w * 0.078 + lean * 0.8, h * 0.82), (x + w * 0.115 + lean * 0.4, h * 0.58), (x + w * 0.107 + lean * 0.4, h * 0.58)]))
        detail(rock, strength: 0.48)
        var ledges = Path()
        ledges.addPath(polygon([(x - w * 0.27, h * 0.42), (x - w * 0.15, h * 0.50), (x - w * 0.15, h * 0.512), (x - w * 0.27, h * 0.432)]))
        ledges.addPath(polygon([(x - w * 0.15, h * 0.66), (x - w * 0.06, h * 0.72), (x - w * 0.06, h * 0.732), (x - w * 0.15, h * 0.672)]))
        detail(ledges, strength: 0.4)
        // Broken strata and narrow gullies follow the slopes, so the mountain
        // reads as rock rather than a single flat triangular silhouette.
        var strata = Path()
        for (a, b, c, d) in [(-0.32, 0.25, -0.21, 0.31), (-0.23, 0.39, -0.14, 0.45),
                              (-0.13, 0.58, -0.06, 0.63), (0.16, 0.58, 0.24, 0.49),
                              (0.24, 0.39, 0.34, 0.29)] as [(CGFloat, CGFloat, CGFloat, CGFloat)] {
            strata.addPath(strokePath([(x + w * a, h * b), (x + w * c, h * d)], max(0.32, w * 0.003)))
        }
        strata.addPath(strokePath([(x + lean - w * 0.015, h * 0.91), (x - w * 0.055, h * 0.66),
                                   (x - w * 0.11, h * 0.47)], max(0.35, w * 0.003), smooth: true))
        detail(strata, strength: 0.53)
    }

    /// A flat-topped cliff, as cut by wind and water.
    mutating func cliff(_ x: CGFloat, _ w: CGFloat, _ h: CGFloat) {
        let outline: [Spot] = [(-0.56, 0), (-0.525, 0.10), (-0.488, 0.30), (-0.472, 0.52), (-0.455, 0.54), (-0.442, 0.80), (-0.425, 0.83), (-0.40, 1.0),
                               (-0.21, 1.0), (-0.19, 0.985), (0.09, 0.985), (0.11, 1.0), (0.38, 1.0), (0.398, 0.90), (0.424, 0.88), (0.44, 0.62),
                               (0.468, 0.60), (0.488, 0.30), (0.525, 0.12), (0.56, 0)]
        shape(outline.map { (x + $0.0 * w, $0.1 * h) })
        // Scree at its foot.
        add(smoothPath([(x - w * 0.62, 0), (x - w * 0.60, h * 0.05), (x - w * 0.56, h * 0.085), (x - w * 0.52, h * 0.05), (x - w * 0.50, 0)]))
        add(smoothPath([(x + w * 0.50, 0), (x + w * 0.53, h * 0.07), (x + w * 0.575, h * 0.10), (x + w * 0.61, h * 0.045), (x + w * 0.63, 0)]))
        // Its beds of rock: one under the rim, the lower ones showing only at the ends; and cracks down from the rim.
        var beds = Path()
        beds.addPath(blockPath(x - w * 0.01, w * 0.78, 0.9, from: h * 0.86))
        for side in [-1.0, 1.0] as [CGFloat] {
            beds.addPath(blockPath(x + side * w * 0.385, w * 0.13, 0.8, from: h * 0.55))
            beds.addPath(blockPath(x + side * w * 0.43, w * 0.09, 0.8, from: h * 0.30))
        }
        detail(beds, strength: 0.65)
        var cracks = Path()
        for (place, long) in [(-0.29, 0.13), (0.02, 0.09), (0.25, 0.14)] as [(CGFloat, CGFloat)] {
            cracks.addPath(polygon([(x + place * w - 0.5, h * 0.985), (x + place * w + 0.5, h * 0.985), (x + place * w + w * 0.012, h * (0.985 - long))]))
        }
        detail(cracks, strength: 0.6)
        var grain = Path()
        for index in 0..<9 {
            let y = h * (0.14 + CGFloat(index) * 0.075)
            let span = w * (0.31 + CGFloat(index % 3) * 0.028)
            let start = x - span + CGFloat(index % 2) * w * 0.025
            grain.addPath(strokePath([(start, y), (start + span * 0.55, y + h * 0.01),
                                      (x + span, y + h * 0.004)], max(0.3, h * 0.004), smooth: true))
        }
        detail(grain, strength: 0.34)
    }

    /// Sand dunes: each a long windward slope and a short steep face.
    mutating func dunes(_ crests: [(CGFloat, CGFloat, CGFloat)]) {
        for (x, reach, h) in crests {
            curve { path, at in
                path.move(to: at(x - reach, 0))
                path.addCurve(to: at(x + reach * 0.25, h), control1: at(x - reach * 0.42, h * 0.10), control2: at(x - reach * 0.08, h * 1.0))
                path.addCurve(to: at(x + reach, 0), control1: at(x + reach * 0.37, h * 0.70), control2: at(x + reach * 0.62, h * 0.08))
                path.closeSubpath()
            }
            // Light along the edge of the slip face, and ripples under the crest.
            detail(polygon([(x + reach * 0.25, h), (x + reach * 0.60, h * 0.30), (x + reach * 0.64, h * 0.30), (x + reach * 0.27, h - 0.6)]), strength: 0.6)
            var ripples = Path()
            for sunk in [h * 0.10 + 1.2, h * 0.22 + 2.4] {
                // Along the windward slope, a little under its surface.
                var upper: [Spot] = []
                for step in 0...8 {
                    let t = 0.52 + 0.40 * CGFloat(step) / 8, u = 1 - t
                    let px = u * u * u * (x - reach) + 3 * u * u * t * (x - reach * 0.42) + 3 * u * t * t * (x - reach * 0.08) + t * t * t * (x + reach * 0.25)
                    let py = 3 * u * u * t * h * 0.10 + 3 * u * t * t * h + t * t * t * h
                    upper.append((px, py - sunk * (0.6 + 0.4 * t)))
                }
                let lower = upper.dropFirst().dropLast().reversed().map { ($0.0, $0.1 - 0.8) }
                ripples.addPath(polygon(upper + lower))
            }
            detail(ripples, strength: 0.42)
            var windLines = Path()
            for line in 0..<4 {
                let t = CGFloat(line) / 4
                let y = h * (0.08 + t * 0.10)
                let start = x - reach * (0.62 - t * 0.10)
                windLines.addPath(strokePath([(start, y), (start + reach * 0.22, y + h * 0.055),
                                             (start + reach * 0.38, y + h * 0.085)], max(0.3, h * 0.012), smooth: true))
            }
            detail(windLines, strength: 0.38)
        }
    }

    /// Water lying in front of the land, with light moving on it.
    mutating func water(from left: CGFloat, to right: CGFloat, depth: CGFloat = 32) {
        tint(polygon([(left, 0.6), (right, 0.6), (right, -depth), (left, -depth)]), shade(0.13, 0.38, 0.52, 0.88))
        // Paler where it meets the sky, deeper towards the reader.
        tint(polygon([(left, 0.6), (right, 0.6), (right, -depth * 0.20), (left, -depth * 0.20)]), shade(0.46, 0.70, 0.82, 0.20))
        tint(polygon([(left, 0.6), (right, 0.6), (right, -0.3), (left, -0.3)]), shade(0.74, 0.90, 0.96, 0.30))
        tint(polygon([(left, -depth * 0.62), (right, -depth * 0.62), (right, -depth), (left, -depth)]), Color.black.opacity(0.10))
        // Near ripples are broader than distant ones; their drift shares the
        // water's existing clock and therefore also stops with Reduce Motion.
        var ripples = Path()
        for index in 0..<12 {
            let fraction = CGFloat(Self.noise(index, 127))
            let y = -2 - fraction * max(0, depth - 4)
            let x = left + (right - left) * CGFloat(Self.noise(index, 131))
                + CGFloat(sin(time * 0.35 + Double(index))) * 2
            let length = 3 + fraction * 11
            ripples.addPath(strokePath([(x, y), (x + length * 0.5, y + 0.3), (x + length, y)], 0.35 + fraction * 0.35, smooth: true))
        }
        tint(ripples, shade(0.75, 0.87, 0.88, 0.22))
        for index in 0..<18 {
            let across = left + (right - left) * CGFloat(Self.noise(index, 31)) + CGFloat(sin(time * 0.45 + Double(index))) * 4
            let sunk = CGFloat(Self.noise(index, 37))
            let down = -2.5 - sunk * (depth - 8)
            let length = (6 + CGFloat(Self.noise(index, 41)) * 10) * (0.7 + sunk * 0.8), thick = 0.45 + sunk * 0.5
            tint(polygon([(across, down), (across + length * 0.5, down + thick), (across + length, down), (across + length * 0.5, down - thick)]),
                 Color.white.opacity((0.15 + 0.09 * sin(time * 0.9 + Double(index) * 1.3)) * (1 - 0.5 * night)))
        }
    }

    /// A road running away over the ground to a point on the horizon.
    mutating func road(to x: CGFloat, from near: CGFloat, width w: CGFloat = 26, depth: CGFloat = 46) {
        tint(polygon([(x - 1, 0), (x + 1, 0), (near + w / 2, -depth), (near - w / 2, -depth)]), shade(0.74, 0.62, 0.44, 0.50))
        // Where feet and wheels have worn it.
        tint(polygon([(x - 0.3, -1), (x + 0.1, -1), (near - w * 0.16, -depth), (near - w * 0.24, -depth)]), shade(0.90, 0.80, 0.62, 0.20))
        tint(polygon([(x - 0.1, -1), (x + 0.3, -1), (near + w * 0.24, -depth), (near + w * 0.16, -depth)]), shade(0.90, 0.80, 0.62, 0.20))
        tint(polygon([(x - 1, 0), (x - 0.6, 0), (near - w / 2 + 1.2, -depth), (near - w / 2, -depth)]), Color.black.opacity(0.10))
        var stones = Path()
        for index in 0..<9 {
            let distance = CGFloat(index + 1) / 10
            let center = x + (near - x) * distance
            let side = (CGFloat(Self.noise(index, 137)) - 0.5) * w * distance * 0.65
            let radius = 0.25 + distance * 0.65
            stones.addPath(discPath(center + side, -depth * distance, radius))
        }
        tint(stones, shade(0.40, 0.34, 0.27, 0.30))
    }

    // MARK: What grows

    /// A date palm: a leaning trunk and a crown that stirs in the wind.
    mutating func palm(_ x: CGFloat, _ height: CGFloat) {
        let lean: CGFloat = Self.noise(Int(x), 7) > 0.5 ? 3 : -3
        let sway = CGFloat(sin(time * 0.8 + Double(x) * 0.3)) * 1.4
        let crown: Spot = (x + lean + sway * 0.4, height)
        let foot = 1.3 + height * 0.012, neck = 0.75 + height * 0.004
        // The trunk, ringed where old fronds were cut: each ring a little wider at its top.
        let rings = max(5, Int(height / 4.5))
        func axis(_ part: CGFloat) -> Spot {
            let u = 1 - part, cx = x + lean * 0.2, cy = height * 0.6
            return (u * u * x + 2 * u * part * cx + part * part * crown.0, 2 * u * part * cy + part * part * height)
        }
        var near: [Spot] = [(x - foot - 1.0, 0)], far: [Spot] = [(x + foot + 1.0, 0)]
        for ring in 0..<rings {
            let low = axis(CGFloat(ring) / CGFloat(rings)), high = axis(CGFloat(ring + 1) / CGFloat(rings))
            let wide = foot + (neck - foot) * CGFloat(ring) / CGFloat(rings)
            near.append((low.0 - wide, low.1)); near.append((high.0 - wide - 0.4, high.1))
            far.append((low.0 + wide, low.1)); far.append((high.0 + wide + 0.4, high.1))
        }
        shape(near + far.reversed())
        var bark = Path()
        for ring in 1..<rings {
            let part = CGFloat(ring) / CGFloat(rings), center = axis(part)
            let wide = foot + (neck - foot) * part
            bark.addPath(strokePath([(center.0 - wide * 0.72, center.1 + 0.25),
                                     (center.0 + wide * 0.58, center.1 + 0.7)], 0.34))
        }
        detail(bark, strength: 0.58)
        // The crown: fronds arching up and out, the oldest hanging down beside the trunk.
        let reach = 11.5 + height * 0.14
        let fan: [(Double, CGFloat, CGFloat)] = [(-1.22, 0.62, 1.0), (-0.52, 0.92, 4.2), (-0.12, 1.0, 5.2), (0.28, 1.0, 5.2), (0.68, 0.96, 4.4), (1.05, 0.90, 3.4),
                                                 (1.5708, 0.80, 0.4), (2.09, 0.90, 3.4), (2.46, 0.96, 4.4), (2.86, 1.0, 5.2), (3.26, 1.0, 5.2), (3.66, 0.92, 4.2), (4.36, 0.62, 1.0)]
        var fronds = Path()
        for (index, frond) in fan.enumerated() {
            let stir = sway * (0.6 + 0.4 * CGFloat(Self.noise(index, Int(x)))) + CGFloat(sin(time * 1.3 + Double(index) * 1.1 + Double(x))) * 0.5
            let far = reach * frond.1
            let tip: Spot = (crown.0 + CGFloat(cos(frond.0)) * far + stir, crown.1 + CGFloat(sin(frond.0)) * far * 0.78 - (frond.2 > 4 ? reach * 0.20 : 0))
            fronds.addPath(frondPath(from: (crown.0, crown.1 - 0.4), to: tip, arch: frond.2 * reach / 14, leaf: 1.5 + reach * 0.085))
        }
        add(fronds)
        // The shared foreground gives trunks a warm, readable silhouette; a
        // Quran scene's living palm leaves keep their own muted foliage color.
        if quranScene { tint(fronds, shade(0.18, 0.34, 0.21, 0.95)) }
        disc(crown.0, crown.1 - 0.6, 1.2 + height * 0.012)
        // Dates hanging under the crown of a grown tree.
        if height >= 30 {
            var dates = Path()
            for side in [-1.0, 1.0] as [CGFloat] {
                let hx = crown.0 + side * (2.0 + height * 0.016) + sway * 0.3, hy = crown.1 - 2.4 - height * 0.03
                dates.addPath(smoothPath([(hx - 1.0, hy + 1.2), (hx + 1.0, hy + 1.2), (hx + 1.2, hy - 0.9), (hx, hy - 2.4 - height * 0.008), (hx - 1.2, hy - 0.9)]))
            }
            tint(dates, shade(0.74, 0.46, 0.20, 0.85))
        }
    }

    /// A broad-crowned tree, as an olive or a fig.
    mutating func tree(_ x: CGFloat, _ h: CGFloat, spread: CGFloat? = nil) {
        let s = spread ?? h * 0.62
        let sway = CGFloat(sin(time * 0.7 + Double(x) * 0.2)) * 0.9
        let seed = Int(x.rounded()) + 71
        // The trunk and the two limbs it parts into.
        add(trunkPath(x, to: (x + h * 0.01, h * 0.56), width: h * 0.075 + 0.9, taper: 0.6, flare: 0.5))
        line([(x, h * 0.36), (x + s * 0.24, h * 0.52), (x + s * 0.36, h * 0.64)], max(0.8, h * 0.035), smooth: true)
        line([(x, h * 0.42), (x - s * 0.22, h * 0.55), (x - s * 0.34, h * 0.63)], max(0.8, h * 0.035), smooth: true)
        // The crown: a few rounded masses of leaf, lit on the side of the sky.
        let clumps: [(CGFloat, CGFloat, CGFloat)] = [(-0.42, 0.66, 0.38), (0.40, 0.68, 0.36), (0.0, 0.84, 0.44), (-0.14, 0.60, 0.28), (0.20, 0.58, 0.28)]
        for (index, clump) in clumps.enumerated() {
            let crown = crownPath(x + clump.0 * s + sway * (0.8 + CGFloat(index) * 0.15), h * clump.1, clump.2 * s * 1.04, clump.2 * s * 0.86,
                                  lobes: 7, depth: 0.17, seed: seed + index, flat: 0.25)
            add(crown)
            if quranScene { tint(crown, shade(0.21, 0.35, 0.22, 0.95)) }
        }
        for (index, clump) in clumps.prefix(3).enumerated() {
            tint(crownPath(x + (clump.0 - 0.08) * s + sway * (1.1 + CGFloat(index) * 0.15), h * clump.1 + clump.2 * s * 0.22, clump.2 * s * 0.60, clump.2 * s * 0.44,
                           lobes: 6, depth: 0.22, seed: seed + index + 20, flat: 0.3), shade(0.30, 0.48, 0.28, 0.36))
        }
        // Smaller leaf clusters give the crown texture without changing its silhouette.
        var leafLight = Path()
        for (index, clump) in clumps.enumerated() {
            let cx = x + clump.0 * s + sway * (0.8 + CGFloat(index) * 0.15)
            let cy = h * clump.1 + clump.2 * s * 0.14
            for mark in 0..<3 {
                let dx = (CGFloat(Self.noise(seed + index * 7 + mark, 141)) - 0.5) * clump.2 * s
                leafLight.addPath(discPath(cx + dx, cy + CGFloat(mark - 1) * h * 0.025, max(0.5, h * 0.012)))
            }
        }
        tint(leafLight, shade(0.51, 0.62, 0.38, 0.34))
    }

    // MARK: What is built

    /// The Kaaba: its cloth, the gold band round it and its door.
    mutating func kaaba(_ x: CGFloat, _ s: CGFloat = 1) {
        let gold = Color(red: 0.86, green: 0.69, blue: 0.36), corner = x + 9 * s
        // Two of its walls: the one with the door, and the one that turns away.
        shape([(x - 17 * s, 0), (corner, 0), (corner, 34 * s), (x - 17 * s, 34 * s)])
        let side: [Spot] = [(corner, 0), (x + 17 * s, 1.5 * s), (x + 17 * s, 33 * s), (corner, 34 * s)]
        shape(side)
        tint(polygon(side), Color.black.opacity(0.22))
        // The marble at its foot.
        tint(polygon([(x - 17 * s, 0), (corner, 0), (corner, 2.2 * s), (x - 17 * s, 2.2 * s)]), shade(0.82, 0.80, 0.74, 0.55))
        tint(polygon([(corner, 0), (x + 17 * s, 1.5 * s), (x + 17 * s, 3.5 * s), (corner, 2.2 * s)]), shade(0.82, 0.80, 0.74, 0.34))
        // The band, and the gold worked into the cloth under it.
        tint(polygon([(x - 17 * s, 23.5 * s), (corner, 23.5 * s), (corner, 26.5 * s), (x - 17 * s, 26.5 * s)]), gold.opacity(0.92))
        tint(polygon([(corner, 23.5 * s), (x + 17 * s, 23.3 * s), (x + 17 * s, 26.0 * s), (corner, 26.5 * s)]), Color(red: 0.66, green: 0.52, blue: 0.26).opacity(0.92))
        var worked = Path()
        for step in [-13.0, -6.5, 0.0, 6.0] as [CGFloat] {
            worked.addPath(polygon([(x + step * s, 21.6 * s), (x + (step + 1.3) * s, 20.2 * s), (x + step * s, 18.8 * s), (x + (step - 1.3) * s, 20.2 * s)]))
        }
        worked.addPath(polygon([(x + 13 * s, 21.4 * s), (x + 14 * s, 20.1 * s), (x + 13 * s, 18.8 * s), (x + 12 * s, 20.1 * s)]))
        tint(worked, gold.opacity(0.62))
        tint(blockPath(x - 4 * s, 26 * s, 0.5 * s, from: 22.4 * s), gold.opacity(0.45))
        tint(blockPath(x - 4 * s, 26 * s, 0.5 * s, from: 27.2 * s), gold.opacity(0.45))
        // Subtle stitched cloth panels and the border of the embroidered band.
        var clothSeams = Path()
        for seam in [-13.0, -7.0, -1.0, 5.0] as [CGFloat] {
            clothSeams.addPath(blockPath(x + seam * s, 0.25 * s, 13.6 * s, from: 4.0 * s))
        }
        tint(clothSeams, Color.white.opacity(0.08))
        var bandBorders = Path()
        for y in [24.0, 26.0] as [CGFloat] {
            bandBorders.addPath(blockPath(x - 4 * s, 25.0 * s, 0.18 * s, from: y * s))
        }
        tint(bandBorders, Color.black.opacity(0.28))
        // The door, raised above the ground, and its threshold.
        tint(blockPath(x + 3.2 * s, 7.6 * s, 13 * s, from: 3.2 * s), Color(red: 0.62, green: 0.46, blue: 0.20).opacity(0.9))
        tint(blockPath(x + 3.2 * s, 6 * s, 11.6 * s, from: 3.9 * s), Color(red: 0.90, green: 0.72, blue: 0.36).opacity(0.92))
        tint(blockPath(x + 3.2 * s, 0.5 * s, 11.6 * s, from: 3.9 * s), Color.black.opacity(0.30))
        tint(blockPath(x + 3.2 * s, 4.6 * s, 0.45 * s, from: 13.4 * s), Color.black.opacity(0.18))
        var panels = Path()
        for side in [-1.0, 1.0] as [CGFloat] {
            for level in [6.2, 10.1] as [CGFloat] {
                panels.addPath(blockPath(x + (3.2 + side * 1.45) * s, 1.7 * s, 2.4 * s, from: level * s)
                    .strokedPath(StrokeStyle(lineWidth: 0.22 * s)))
            }
        }
        tint(panels, Color.black.opacity(0.28))
        // The edge of the roof, the spout on it, and the corner between the walls.
        detail(blockPath(x - 4 * s, 26 * s, 0.7 * s, from: 33.3 * s), strength: 0.9)
        detail(blockPath(corner, 0.7 * s, 33 * s, from: 0.5 * s), strength: 0.8)
        tint(blockPath(x - 18.4 * s, 3 * s, 0.8 * s, from: 32.6 * s), gold.opacity(0.85))
    }

    /// A tent on its pole, lamplit after dark.
    mutating func tent(_ x: CGFloat, _ w: CGFloat, _ h: CGFloat) {
        var cloth = Path()
        cloth.move(to: point(x - w / 2, 0))
        cloth.addQuadCurve(to: point(x - w * 0.05, h * 0.93), control: point(x - w * 0.22, h * 0.44))
        cloth.addLine(to: point(x, h)); cloth.addLine(to: point(x + w * 0.05, h * 0.93))
        cloth.addQuadCurve(to: point(x + w / 2, 0), control: point(x + w * 0.22, h * 0.44))
        cloth.closeSubpath()
        add(cloth)
        spire(x, 1, from: h - 1, to: h + 4)
        disc(x, h + 4, 0.8)
        // Its ropes and pegs.
        for side in [-1.0, 1.0] as [CGFloat] {
            line([(x + side * w * 0.27, h * 0.50), (x + side * (w * 0.5 + w * 0.17), 0.4)], 0.5)
            line([(x + side * w * 0.38, h * 0.26), (x + side * (w * 0.5 + w * 0.08), 0.4)], 0.5)
            shape([(x + side * (w * 0.67 + 0.8), 0), (x + side * (w * 0.67 - 0.6), 0), (x + side * (w * 0.67 + 0.4), 2.2)])
        }
        // A woven band round it, and the flap of the door thrown back.
        detail(polygon([(x - w * 0.40, h * 0.15), (x - w * 0.10, h * 0.21), (x + w * 0.10, h * 0.21), (x + w * 0.40, h * 0.15),
                        (x + w * 0.41, h * 0.12), (x + w * 0.10, h * 0.18), (x - w * 0.10, h * 0.18), (x - w * 0.41, h * 0.12)]), strength: 0.55)
        var seams = Path()
        for side in [-1.0, 1.0] as [CGFloat] {
            seams.addPath(strokePath([(x + side * w * 0.04, h * 0.87), (x + side * w * 0.18, h * 0.50),
                                      (x + side * w * 0.32, h * 0.10)], max(0.35, w * 0.009), smooth: true))
        }
        detail(seams, strength: 0.42)
        tint(polygon([(x - w * 0.115, 0), (x, h * 0.52), (x + w * 0.115, 0)]), Color.black.opacity(0.36))
        tint(polygon([(x + w * 0.115, 0), (x, h * 0.52), (x + w * 0.02, h * 0.34), (x + w * 0.17, 0)]), Color.white.opacity(0.07))
        tint(cloth, Self.lampLight.opacity(0.09), nightOnly: true)
        shape([(x - w * 0.085, 0), (x, h * 0.44), (x + w * 0.085, 0)], .light)
    }

    /// A flat-roofed house with one window.
    mutating func house(_ x: CGFloat, _ w: CGFloat, _ h: CGFloat) {
        // Mud-brick walls leaning in a little, a parapet with raised corners, a spout to drain the roof.
        shape([(x - w / 2 - 0.5, 0), (x + w / 2 + 0.5, 0), (x + w / 2, h), (x - w / 2, h)])
        block(x, w + 2, 1.4, from: h)
        block(x - w / 2 + 1.2, 2.6, 1.5, from: h + 1.4); block(x + w / 2 - 1.2, 2.6, 1.5, from: h + 1.4)
        block(x + w / 2 + 1.6, 2.4, 0.7, from: h - 1.6)
        // The ends of the roof beams, and the light on the wall's near edge.
        var beams = Path()
        let count = max(2, Int(w / 5))
        for beam in 0..<count where h > 7 {
            beams.addPath(blockPath(x - w / 2 + w * (CGFloat(beam) + 0.5) / CGFloat(count), 0.9, 0.9, from: h - 2.6))
        }
        detail(beams, strength: 0.9)
        detail(blockPath(x - w / 2 + 0.7, 0.9, max(0, h - 1.6), from: 0.8), strength: 0.7)
        var brick = Path()
        for row in 1..<4 {
            let y = h * CGFloat(row) / 5
            brick.addPath(blockPath(x - w * 0.29, w * 0.28, 0.35, from: y))
            brick.addPath(blockPath(x + w * 0.31, w * 0.25, 0.35, from: y + h * 0.02))
        }
        detail(brick, strength: 0.35)
        // The door, the window with its lamp, and a smaller one on a wide wall.
        let doorW = min(6, max(2.6, w * 0.17)), doorH = min(h * 0.56, doorW * 2.1)
        tint(archPath(x, doorW, doorH, pointed: false), Color.black.opacity(0.38))
        detail(blockPath(x, doorW + 1.6, 0.6, from: doorH + 0.5), strength: 0.8)
        let paneW = max(2.2, min(4, w * 0.09)), paneH = paneW * 1.3
        tint(blockPath(x + w * 0.27, paneW + 1.2, paneH + 1.2, from: h * 0.50 - 0.6), Color.black.opacity(0.32))
        block(x + w * 0.27, paneW, paneH, from: h * 0.50, .light)
        if w >= 24 {
            tint(blockPath(x - w * 0.30, paneW + 0.4, paneH + 0.4, from: h * 0.56 - 0.2), Color.black.opacity(0.32))
            block(x - w * 0.30, paneW * 0.7, paneH * 0.74, from: h * 0.56, .light)
        }
    }

    /// Standing columns of a ruined hall, some still carrying a beam.
    mutating func columns(_ x: CGFloat, heights: [CGFloat], gap: CGFloat = 13) {
        let tallest = heights.max() ?? 0
        var flutes = Path(), drums = Path()
        for (index, h) in heights.enumerated() {
            let cx = x + CGFloat(index) * gap
            let carries = (index + 1 < heights.count && abs(heights[index + 1] - h) < 1) || (index > 0 && abs(heights[index - 1] - h) < 1)
            let broken = !carries && h < tallest * 0.8
            block(cx, 6.4, 1.5); block(cx, 4.8, 1.2, from: 1.5)
            shape([(cx - 1.85, 2.7), (cx + 1.85, 2.7), (cx + 1.5, h - 2.4), (cx - 1.5, h - 2.4)])
            if broken {
                // Snapped: a ragged head, and a drum of it lying at its foot.
                shape([(cx - 1.5, h - 2.6), (cx - 1.1, h + 0.4), (cx - 0.3, h - 1.4), (cx + 0.7, h - 0.2), (cx + 1.5, h - 2.6)])
                add(smoothPath([(cx + 4.2, 0.4), (cx + 3.9, 2.4), (cx + 4.6, 4.0), (cx + 8.6, 4.0), (cx + 9.3, 2.4), (cx + 9.0, 0.4)]))
            } else {
                block(cx, 3.9, 1.0, from: h - 2.4)
                shape([(cx - 1.9, h - 1.4), (cx + 1.9, h - 1.4), (cx + 3.3, h), (cx - 3.3, h)])
                block(cx, 7, 1.6, from: h)
            }
            if index + 1 < heights.count, abs(heights[index + 1] - h) < 1 {
                block(cx + gap / 2, gap + 7, 3.0, from: h + 1.6)
                block(cx + gap / 2, gap + 8.6, 1.0, from: h + 4.6)
                drums.addPath(blockPath(cx + gap / 2, gap + 5, 0.6, from: h + 2.9))
            }
            flutes.addPath(blockPath(cx - 0.55, 0.5, max(0, h - 7), from: 3.6))
            for part in [0.36, 0.68] as [CGFloat] where h * part < h - 5 { drums.addPath(blockPath(cx, 3.0, 0.5, from: h * part)) }
        }
        detail(flutes, strength: 0.8)
        detail(drums, strength: 0.55)
        var edges = Path()
        for (index, h) in heights.enumerated() where h > 12 {
            let cx = x + CGFloat(index) * gap
            edges.addPath(blockPath(cx + 1.0, 0.35, max(0, h - 7.5), from: 3.4))
            edges.addPath(blockPath(cx, 4.4, 0.35, from: 1.8))
        }
        detail(edges, strength: 0.38)
    }

    /// A well: its stone ring, the frame over it, and a bucket swinging on its rope.
    mutating func well(_ x: CGFloat, scale s: CGFloat = 1, abandoned: Bool = false) {
        if abandoned {
            // A neglected version of the same stone well: the rim is uneven,
            // the timber has fallen, and no active bucket implies recent use.
            block(x, 24 * s, 1.2 * s)
            shape([(x - 9.6 * s, 1.2 * s), (x + 9.6 * s, 1.2 * s),
                   (x + 9 * s, 6.8 * s), (x + 5.0 * s, 7.8 * s),
                   (x + 2.2 * s, 6.4 * s), (x - 1.0 * s, 7.4 * s),
                   (x - 4.4 * s, 6.4 * s), (x - 8.8 * s, 7.4 * s)])
            var masonry = Path(), cracks = Path()
            for level in [3.0, 5.0] as [CGFloat] {
                masonry.addPath(blockPath(x, 17.6 * s, 0.45 * s, from: level * s))
            }
            for (joint, level) in [(-6.0, 1.4), (0.5, 1.4), (6.4, 1.4), (-3.0, 3.2), (3.6, 3.2)] as [(CGFloat, CGFloat)] {
                masonry.addPath(blockPath(x + joint * s, 0.45 * s, 1.7 * s, from: level * s))
            }
            cracks.addPath(strokePath([(x - 3.0 * s, 7.0 * s), (x - 3.6 * s, 5.8 * s),
                                       (x - 2.8 * s, 4.9 * s), (x - 3.4 * s, 3.8 * s)], 0.28 * s))
            cracks.addPath(strokePath([(x + 5.5 * s, 6.8 * s), (x + 4.8 * s, 5.8 * s),
                                       (x + 5.2 * s, 4.7 * s)], 0.24 * s))
            detail(masonry, strength: 0.65)
            tint(cracks, Color.black.opacity(0.30))
            // The fallen beam and scattered stones still belong to the well.
            shape([(x - 9.0 * s, 7.0 * s), (x - 7.0 * s, 7.4 * s),
                   (x - 6.8 * s, 11.6 * s), (x - 8.6 * s, 10.8 * s)])
            shape([(x + 7.0 * s, 6.8 * s), (x + 8.7 * s, 6.8 * s),
                   (x + 8.6 * s, 9.1 * s), (x + 6.9 * s, 9.7 * s)])
            shape([(x - 7.3 * s, 10.5 * s), (x + 5.9 * s, 7.3 * s),
                   (x + 6.2 * s, 8.4 * s), (x - 7.0 * s, 11.7 * s)])
            add(smoothPath([(x - 13.3 * s, 0), (x - 13.1 * s, 1.1 * s), (x - 11.6 * s, 1.8 * s),
                            (x - 10.4 * s, 1.1 * s), (x - 10.4 * s, 0)]))
            add(smoothPath([(x + 10.8 * s, 0), (x + 11.0 * s, 1.4 * s), (x + 12.7 * s, 1.7 * s),
                            (x + 14.0 * s, 0.9 * s), (x + 13.9 * s, 0)]))
            return
        }
        // The ring of fitted stone on its step.
        block(x, 24 * s, 1.2 * s)
        shape([(x - 9.6 * s, 1.2 * s), (x + 9.6 * s, 1.2 * s), (x + 9 * s, 7 * s), (x - 9 * s, 7 * s)])
        block(x, 20.6 * s, 1.5 * s, from: 7 * s)
        var stones = Path()
        stones.addPath(blockPath(x, 18 * s, 0.45 * s, from: 3.0 * s)); stones.addPath(blockPath(x, 17.6 * s, 0.45 * s, from: 5.0 * s))
        for (joint, level) in [(-6.0, 1.4), (0.5, 1.4), (6.4, 1.4), (-3.0, 3.2), (3.6, 3.2), (-6.4, 5.2), (0.0, 5.2), (5.8, 5.2)] as [(CGFloat, CGFloat)] {
            stones.addPath(blockPath(x + joint * s, 0.45 * s, 1.7 * s, from: level * s))
        }
        detail(stones, strength: 0.7)
        var chisel = Path()
        for i in 0..<6 {
            let px = x + (-7.5 + CGFloat(i) * 2.8) * s
            chisel.addPath(strokePath([(px, 1.8 * s), (px + 0.65 * s, 2.15 * s)], 0.24 * s))
            chisel.addPath(strokePath([(px + 1.1 * s, 5.6 * s), (px + 1.7 * s, 6.0 * s)], 0.24 * s))
        }
        detail(chisel, strength: 0.5)
        // Two forked posts and the beam across them, a wheel for the rope.
        for side in [-1.0, 1.0] as [CGFloat] {
            let px = x + side * 7.6 * s
            shape([(px - 1.0 * s, 8.5 * s), (px + 1.0 * s, 8.5 * s), (px + 0.8 * s, 19 * s), (px - 0.8 * s, 19 * s)])
            shape([(px - 0.8 * s, 18.6 * s), (px - 1.8 * s, 22.4 * s), (px - 0.9 * s, 22.4 * s), (px, 20.2 * s), (px + 0.9 * s, 22.4 * s), (px + 1.8 * s, 22.4 * s), (px + 0.8 * s, 18.6 * s)])
        }
        block(x, 21 * s, 1.5 * s, from: 19.6 * s)
        disc(x, 18.6 * s, 1.7 * s)
        disc(x, 18.6 * s, 0.6 * s, .hole)
        // The rope, and the bucket on it.
        let swing = CGFloat(sin(time * 1.1)) * 0.16
        let bucket = (x + sin(swing) * 8 * s, (17.6 - cos(swing) * 7) * s)
        tint(polygon([(x - 0.3, 17.6 * s), (x + 0.3, 17.6 * s), (bucket.0 + 0.3, bucket.1 + 2.2 * s), (bucket.0 - 0.3, bucket.1 + 2.2 * s)]), shade(0.74, 0.64, 0.46, 0.95))
        tint(strokePath([(bucket.0 - 1.9 * s, bucket.1), (bucket.0, bucket.1 + 2.4 * s), (bucket.0 + 1.9 * s, bucket.1)], 0.4 * s, smooth: true), shade(0.74, 0.64, 0.46, 0.95))
        shape([(bucket.0 - 2.1 * s, bucket.1), (bucket.0 + 2.1 * s, bucket.1), (bucket.0 + 1.5 * s, bucket.1 - 3.6 * s), (bucket.0 - 1.5 * s, bucket.1 - 3.6 * s)])
        detail(blockPath(bucket.0, 3.6 * s, 0.4 * s, from: bucket.1 - 1.4 * s), strength: 1.0)
        detail(blockPath(bucket.0, 3.0 * s, 0.25 * s, from: bucket.1 - 2.8 * s), strength: 0.65)
    }

    /// A cave mouth in whatever stands behind it.
    mutating func cave(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat, lit: Bool = false) {
        // The mouth is not even: higher on one side, as rock breaks.
        var mouth = Path()
        mouth.move(to: point(x - w / 2, y))
        mouth.addCurve(to: point(x + w / 2, y), control1: point(x - w * 0.44, y + h * 1.12),
                       control2: point(x + w * 0.22, y + h * 1.50))
        mouth.closeSubpath()
        add(mouth, .hole)
        // A cave recedes into rock, not into the bright sky behind the cliff.
        tint(mouth, shade(0.12, 0.10, 0.09, 0.94))
        // Weathered facets frame the opening without filling its dark mouth.
        var facets = Path()
        facets.addPath(strokePath([(x - w * 0.52, y + h * 0.08), (x - w * 0.42, y + h * 0.43),
                                  (x - w * 0.31, y + h * 0.66)], max(0.35, w * 0.012), smooth: true))
        facets.addPath(strokePath([(x + w * 0.43, y + h * 0.48), (x + w * 0.52, y + h * 0.24),
                                  (x + w * 0.56, y + h * 0.04)], max(0.35, w * 0.012), smooth: true))
        detail(facets, strength: 0.55)
        if lit {
            var inner = Path()
            inner.move(to: point(x - w * 0.34, y + 0.5))
            inner.addCurve(to: point(x + w * 0.34, y + 0.5), control1: point(x - w * 0.28, y + h * 0.80), control2: point(x + w * 0.16, y + h * 1.06))
            inner.closeSubpath()
            glow(x, y + h * 0.3, w * 0.8, Self.lampLight, 0.18, nightOnly: true)
            tint(inner, Self.lampLight.opacity(0.20))
            add(inner, .light)
        }
    }

    /// A vessel on the water, rocking: a deep hull, and a house on its deck.
    mutating func ark(_ x: CGFloat, scale s: CGFloat = 1) {
        let roll = sin(time * 0.75) * 0.045, rise = CGFloat(sin(time * 0.9)) * 1.3
        func turned(_ px: CGFloat, _ py: CGFloat) -> (CGFloat, CGFloat) {
            let dx = Double(px * s), dy = Double(py * s)
            return (x + CGFloat(dx * cos(roll) - dy * sin(roll)), CGFloat(dx * sin(roll) + dy * cos(roll)) + rise)
        }
        func spot(_ px: CGFloat, _ py: CGFloat) -> CGPoint { let place = turned(px, py); return point(place.0, place.1) }
        // The hull: round-bellied, its stem and stern posts rising high at either end.
        var hull = Path()
        hull.move(to: spot(-47, 16.5))
        hull.addQuadCurve(to: spot(-35, 8.6), control: spot(-41.5, 9.4))
        hull.addQuadCurve(to: spot(34, 8.6), control: spot(0, 6.6))
        hull.addQuadCurve(to: spot(50, 18.5), control: spot(44, 9.8))
        hull.addLine(to: spot(51.6, 17))
        hull.addQuadCurve(to: spot(33, -5), control: spot(46, -0.5))
        hull.addLine(to: spot(-31, -5))
        hull.addQuadCurve(to: spot(-48.6, 15), control: spot(-45, -3.5))
        hull.closeSubpath()
        add(hull)
        let head = turned(50.6, 18.4), tail = turned(-47.6, 16.4)
        disc(head.0, head.1, 1.5 * s); disc(tail.0, tail.1, 1.5 * s)
        // The steering oar at the stern.
        line([turned(-43, 13), turned(-53, -5)], 1.1 * s)
        shape([turned(-50.6, 0), turned(-52.6, -6), turned(-55.4, -5), turned(-52.4, 0.6)])
        // The long house on the deck under its rounded roof, and a smaller one above it.
        shape([turned(-25, 8), turned(25, 8), turned(24, 19), turned(-24, 19)])
        var roof = Path()
        roof.move(to: spot(-27.5, 18.6)); roof.addQuadCurve(to: spot(27.5, 18.6), control: spot(0, 28)); roof.closeSubpath()
        add(roof)
        shape([turned(-11, 22), turned(12, 22), turned(11.4, 27.4), turned(-10.4, 27.4)])
        var loft = Path()
        loft.move(to: spot(-13.4, 27)); loft.addQuadCurve(to: spot(14.4, 27), control: spot(0.5, 33.4)); loft.closeSubpath()
        add(loft)
        for window in [-18.0, -9.0, 0.0, 9.0, 18.0] as [CGFloat] {
            tint(polygon([(window - 2.1, 11.6), (window + 2.1, 11.6), (window + 2.1, 16.4), (window - 2.1, 16.4)].map { turned($0.0, $0.1) }), Color.black.opacity(0.30))
            shape([(window - 1.4, 12.2), (window + 1.4, 12.2), (window + 1.4, 15.8), (window - 1.4, 15.8)].map { turned($0.0, $0.1) }, .light)
        }
        for window in [-4.6, 5.6] as [CGFloat] {
            shape([(window - 1.1, 23.4), (window + 1.1, 23.4), (window + 1.1, 25.8), (window - 1.1, 25.8)].map { turned($0.0, $0.1) }, .light)
        }
        // Her planking, and the boards of the house.
        detail(strokePath([turned(-45, 11), turned(-30, 3.8), turned(0, 1.8), turned(30, 3.8), turned(48, 12.6)], 0.7 * s, smooth: true), strength: 0.6)
        detail(strokePath([turned(-41, 4.4), turned(-28, -0.4), turned(0, -1.8), turned(30, -0.4), turned(43, 5.6)], 0.6 * s, smooth: true), strength: 0.35)
        detail(polygon([turned(-24.6, 9.6), turned(24.6, 9.6), turned(24.6, 10.3), turned(-24.6, 10.3)]), strength: 0.7)
        detail(polygon([turned(-26, 18.6), turned(26, 18.6), turned(26, 19.3), turned(-26, 19.3)]), strength: 0.9)
        // Narrow seams follow the rocking hull, and small ties along the
        // gunwale suggest construction without changing the ship's motion.
        var planks = Path()
        for board in [-30.0, -15.0, 0.0, 15.0, 30.0] as [CGFloat] {
            planks.addPath(strokePath([turned(board, 2.6), turned(board + 0.6, 8.3)], 0.35 * s))
        }
        for peg in stride(from: CGFloat(-35), through: 35, by: 7) {
            let place = turned(peg, 8.7)
            planks.addPath(discPath(place.0, place.1, 0.28 * s))
        }
        detail(planks, strength: 0.52)
        // The water breaking along her side.
        let wash = 0.5 + 0.5 * sin(time * 1.1)
        tint(polygon([(x - 40 * s, 0.4), (x - 10 * s, 1.5 + CGFloat(wash) * 0.6 * s), (x + 22 * s, 0.4), (x - 10 * s, -0.9)]), Color.white.opacity((0.14 + 0.10 * wash) * (1 - 0.4 * night)))
        tint(polygon([(x + 26 * s, 0.4), (x + 37 * s, 2.0 + CGFloat(1 - wash) * 0.8 * s), (x + 47 * s, 0.4), (x + 37 * s, -0.9)]), Color.white.opacity((0.22 + 0.12 * (1 - wash)) * (1 - 0.4 * night)))
    }

    /// A wall with a pointed niche, and in the niche a lamp in its glass. The
    /// flame never goes out: it wavers by day and lights the wall by night.
    mutating func lampNiche(_ x: CGFloat) {
        block(x, 70, 2.4)
        block(x, 66, 84)
        block(x, 74, 3, from: 84)
        block(x, 70, 1.4, from: 87)
        for step in [-30.0, -15, 0, 15, 30] as [CGFloat] {
            shape([(x + step - 3.4, 88.4), (x + step + 3.4, 88.4), (x + step + 3.4, 90.4), (x + step + 1.8, 90.4), (x + step + 1.8, 92.4),
                   (x + step - 1.8, 92.4), (x + step - 1.8, 90.4), (x + step - 3.4, 90.4)])
        }
        let flame = 0.80 + 0.12 * sin(time * 4.3) + 0.06 * sin(time * 9.1)
        let warm = Color(red: 1.0, green: 0.84, blue: 0.50)
        // The niche: a deep recess, its back lit by the lamp; a frame, slender columns, a sill.
        let niche = archPath(x, 30, 54, from: 14, pointed: true)
        tint(niche, Color.black.opacity(0.34))
        tint(archPath(x, 22, 46, from: 14, pointed: true), warm.opacity((0.05 + 0.10 * night) * flame))
        detail(niche.strokedPath(StrokeStyle(lineWidth: 0.9)), strength: 1.0)
        block(x, 38, 1.8, from: 12.2)
        detail(blockPath(x, 58, 0.9, from: 76), strength: 0.8)
        detail(blockPath(x, 40, 0.9, from: 9.4), strength: 0.8)
        for side in [-1.0, 1.0] as [CGFloat] {
            detail(blockPath(x + side * 18, 1.8, 30, from: 14), strength: 0.9)
            detail(blockPath(x + side * 18, 3.2, 1.2, from: 44), strength: 1.0)
            detail(blockPath(x + side * 23, 0.8, 62, from: 14), strength: 0.7)
            detail(archPath(x + side * 27.5, 5.5, 11, from: 58, pointed: true), strength: 0.45)
        }
        detail(blockPath(x, 46.8, 0.8, from: 71.6), strength: 0.7)
        var stonework = Path()
        for level in [20.0, 32.0, 44.0, 56.0] as [CGFloat] {
            for side in [-1.0, 1.0] as [CGFloat] {
                stonework.addPath(blockPath(x + side * 27.5, 8.0, 0.45, from: level))
            }
        }
        detail(stonework, strength: 0.48)
        // The lamp: hung on its chains, a glass swelling under a flared neck.
        var chains = Path()
        for hook in [-3.0, 0.0, 3.0] as [CGFloat] { chains.addPath(strokePath([(x, 67), (x + hook, 53)], 0.5)) }
        tint(chains, shade(0.80, 0.66, 0.40, 0.9))
        glow(x, 44, 19, warm, 0.52 * flame)
        tint(smoothPath([(x - 3.6, 53), (x + 3.6, 53), (x + 2.2, 49.4), (x + 5.8, 45), (x + 4.4, 39.4), (x + 2.2, 37.4), (x - 2.2, 37.4), (x - 4.4, 39.4), (x - 5.8, 45), (x - 2.2, 49.4)]),
             warm.opacity(0.55 + 0.4 * flame))
        tint(blockPath(x, 7.6, 1.3, from: 52.4), shade(0.74, 0.58, 0.30))
        tint(blockPath(x, 5.6, 1.3, from: 35.8), shade(0.74, 0.58, 0.30))
        tint(blockPath(x, 3.0, 0.9, from: 34.9), shade(0.74, 0.58, 0.30))
        disc(x, 44, 2.0, .light)
    }

    // MARK: What is in the sky

    /// Stars of the scene's own, each twinkling in its own time. Night only.
    mutating func stars(_ places: [(CGFloat, CGFloat)], size: CGFloat = 1.5) {
        for (index, place) in places.enumerated() {
            let twinkle = 0.70 + 0.30 * sin(time * (1.3 + Self.noise(index, 3)) + Double(index) * 2.1)
            tint(discPath(place.0, place.1, size * 2.6), Color.white.opacity(0.12 * twinkle), nightOnly: true)
            tint(sparklePath(place.0, place.1, size * 3.4, waist: 0.13), Color.white.opacity(0.42 * twinkle), nightOnly: true)
            tint(discPath(place.0, place.1, size), Color(red: 1.0, green: 0.96, blue: 0.84).opacity(twinkle), nightOnly: true)
            tint(discPath(place.0 - size * 0.16, place.1 + size * 0.16, size * 0.30), Color.white.opacity(0.7 * twinkle), nightOnly: true)
        }
    }

    /// Rain falling across the scene, slanted by the wind.
    mutating func rain(from left: CGFloat, to right: CGFloat, height: CGFloat = 210) {
        for index in 0..<46 {
            let fall = (Self.noise(index, 51) + time * (0.9 + Self.noise(index, 53) * 0.5)).truncatingRemainder(dividingBy: 1)
            let x = left + (right - left) * CGFloat(Self.noise(index, 57)) - CGFloat(fall) * 22
            let y = height - CGFloat(fall) * (height + 26)
            let long = 9 + CGFloat(Self.noise(index, 55)) * 6
            tint(polygon([(x, y), (x + 0.7, y), (x - long * 0.24, y - long), (x - long * 0.30, y - long)]),
                 Color.white.opacity((0.15 + 0.12 * Self.noise(index, 59)) * (1 - 0.4 * night)))
            if index % 5 == 0 {
                tint(strokePath([(x + 0.2, y - long * 0.15), (x - long * 0.18, y - long * 0.78)], 0.25),
                     Color.white.opacity(0.20 * (1 - 0.4 * night)))
            }
        }
        // Where it strikes the ground: rings opening and fading.
        for index in 0..<9 {
            let open = (Self.noise(index, 43) + time * 1.1).truncatingRemainder(dividingBy: 1)
            let x = left + (right - left) * CGFloat(Self.noise(index + Int(time * 1.1 + Self.noise(index, 43)) * 13, 45))
            let y = -4 - CGFloat(Self.noise(index, 47)) * 22, wide = 2 + CGFloat(open) * 7
            tint(Path(ellipseIn: CGRect(x: point(x - wide / 2, 0).x, y: point(0, y + wide * 0.12).y, width: wide, height: wide * 0.24)).strokedPath(StrokeStyle(lineWidth: 0.5)),
                 Color.white.opacity(0.30 * (1 - open) * (1 - 0.4 * night)))
        }
    }

    /// Stones of baked clay falling from the sky, one after another.
    mutating func fallingStones(over x: CGFloat, spread: CGFloat, height: CGFloat = 170) {
        for index in 0..<13 {
            let fall = (Self.noise(index, 61) + time * (0.22 + Self.noise(index, 63) * 0.16)).truncatingRemainder(dividingBy: 1)
            let px = x + (CGFloat(Self.noise(index, 67)) - 0.5) * spread + CGFloat(fall) * 14
            let py = height - CGFloat(fall * fall) * (height - 34)
            let size = 1.3 + CGFloat(Self.noise(index, 65)) * 0.9
            tint(polygon([(px - size * 0.5, py), (px + size * 0.5, py), (px - 4.4, py + 15)]), shade(0.90, 0.52, 0.30, 0.20))
            tint(polygon([(px - size * 0.3, py), (px + size * 0.3, py), (px - 2.4, py + 8)]), shade(0.96, 0.62, 0.36, 0.34))
            tint(polygon([(px - size, py + size * 0.2), (px - size * 0.3, py + size), (px + size * 0.8, py + size * 0.5), (px + size, py - size * 0.4), (px + size * 0.1, py - size), (px - size * 0.8, py - size * 0.6)]),
                 shade(0.74, 0.36, 0.22))
            tint(polygon([(px - size * 0.7, py + size * 0.2), (px - size * 0.2, py + size * 0.8), (px + size * 0.3, py + size * 0.4), (px - size * 0.2, py)]), shade(0.92, 0.56, 0.36, 0.7))
            tint(polygon([(px - size * 0.2, py), (px + size * 0.75, py + size * 0.3),
                          (px + size * 0.55, py - size * 0.5), (px + size * 0.1, py - size * 0.8)]),
                 shade(0.50, 0.23, 0.16, 0.38))
        }
    }

    /// Light coming down through the night, and motes descending in it. Night only.
    mutating func descendingLight(over x: CGFloat, spread: CGFloat, height: CGFloat = 190) {
        let glow = Color(red: 0.86, green: 0.92, blue: 1.0)
        // Each shaft is several thin ones laid over each other, so it has no hard edge.
        for (index, offset) in [-0.40, -0.22, -0.06, 0.10, 0.26, 0.42].enumerated() {
            let cx = x + spread * CGFloat(offset)
            let breath = 0.5 + 0.5 * sin(time * 0.35 + Double(index) * 1.7)
            for (half, strength) in [(9.0, 0.010), (6, 0.014), (3.5, 0.018), (1.6, 0.024)] as [(CGFloat, Double)] {
                tint(polygon([(cx - half * 0.4, height), (cx + half * 0.4, height), (cx + half, 4), (cx - half, 4)]),
                     glow.opacity(strength * (0.5 + breath)), nightOnly: true)
            }
            tint(polygon([(cx - 2.0, 4), (cx, 5.2), (cx + 2.0, 4), (cx, 3.6)]),
                 glow.opacity(0.045 * (0.5 + breath)), nightOnly: true)
        }
        for index in 0..<18 {
            let fall = (Self.noise(index, 71) + time * (0.035 + Self.noise(index, 73) * 0.03)).truncatingRemainder(dividingBy: 1)
            let px = x + (CGFloat(Self.noise(index, 77)) - 0.5) * spread + CGFloat(sin(time * 0.4 + Double(index))) * 1.5
            let py = height - CGFloat(fall) * (height - 10), size = 1.0 + CGFloat(Self.noise(index, 79))
            tint(discPath(px, py, size * 2.0), glow.opacity(0.09 * sin(fall * .pi)), nightOnly: true)
            tint(discPath(px, py, size), glow.opacity(0.75 * sin(fall * .pi)), nightOnly: true)
        }
    }

    // MARK: What moves

    /// Sand lifted by the wind, streaming low across the ground.
    mutating func driftingSand(from left: CGFloat, to right: CGFloat, height: CGFloat = 26) {
        for index in 0..<22 {
            let run = (Self.noise(index, 81) + time * (0.05 + Self.noise(index, 83) * 0.05)).truncatingRemainder(dividingBy: 1)
            let x = left + (right - left) * CGFloat(run)
            let y = 1 + CGFloat(Self.noise(index, 87)) * height + CGFloat(sin(time * 1.3 + Double(index))) * 1.2
            let length = 12 + CGFloat(Self.noise(index, 89)) * 22, lift = 0.6 + CGFloat(Self.noise(index, 85)) * 1.0
            var streak = Path()
            streak.move(to: point(x, y))
            streak.addQuadCurve(to: point(x + length, y + lift), control: point(x + length * 0.5, y + lift * 0.9 + 0.55))
            streak.addQuadCurve(to: point(x, y), control: point(x + length * 0.5, y + lift * 0.5 - 0.35))
            streak.closeSubpath()
            tint(streak, shade(0.90, 0.76, 0.54, 0.26 * sin(run * .pi)))
            if index % 4 == 0 {
                tint(strokePath([(x + length * 0.18, y + lift * 0.25),
                                 (x + length * 0.52, y + lift * 0.72),
                                 (x + length * 0.85, y + lift * 0.88)], 0.3, smooth: true),
                     shade(0.96, 0.86, 0.66, 0.20 * sin(run * .pi)))
            }
        }
    }

    /// Smoke from a hearth, rising and thinning as it leans with the wind.
    mutating func hearthSmoke(_ x: CGFloat, _ y: CGFloat) {
        for index in 0..<7 {
            let rise = (Double(index) / 7 + time * 0.07).truncatingRemainder(dividingBy: 1)
            let px = x + CGFloat(rise) * 9 + CGFloat(sin(time * 0.6 + rise * 5)) * 1.8
            let size = 1.6 + CGFloat(rise) * 4.2
            let py = y + CGFloat(rise) * 30
            tint(crownPath(px, py, size, size * 0.82, lobes: 6, depth: 0.14, seed: index + 77), shade(0.80, 0.80, 0.82, 0.20 * (1 - rise)))
            tint(crownPath(px + size * 0.5, py + size * 0.4, size * 0.66, size * 0.54, lobes: 5, depth: 0.14, seed: index + 91), shade(0.84, 0.84, 0.86, 0.13 * (1 - rise)))
        }
    }

    /// A fire on the ground: flames leaping, sparks rising, a glow round it.
    mutating func campfire(_ x: CGFloat, _ y: CGFloat = 0, scale s: CGFloat = 1) {
        let leap = CGFloat(sin(time * 7.3)) * 1.2 * s, lick = CGFloat(sin(time * 5.1 + 1)) * 1.4 * s
        glow(x, y + 4 * s, 14 * s, Color(red: 1.0, green: 0.62, blue: 0.25), 0.22 + 0.06 * sin(time * 6.1))
        glow(x, y + 4 * s, 24 * s, Color(red: 1.0, green: 0.62, blue: 0.25), 0.12, nightOnly: true)
        // The wood it burns: two logs crossed, stones set round them.
        line([(x - 5.6 * s, y + 0.8 * s), (x + 5.0 * s, y + 2.6 * s)], 1.5 * s)
        line([(x + 5.6 * s, y + 0.8 * s), (x - 5.0 * s, y + 2.6 * s)], 1.5 * s)
        tint(strokePath([(x - 4.6 * s, y + 1.3 * s), (x + 4.2 * s, y + 2.8 * s)], 0.28 * s), shade(0.95, 0.70, 0.37, 0.45))
        disc(x - 7.2 * s, y + 0.5 * s, 1.3 * s); disc(x + 7.4 * s, y + 0.4 * s, 1.1 * s)
        // The flames: a tall tongue, a lesser one beside it, the bright heart.
        let fire = Color(red: 1.0, green: 0.52, blue: 0.15)
        tint(flamePath(x - 2.6 * s, y + 0.6 * s, width: 4.6 * s, height: 6.4 * s - leap * 0.5, lean: -lick * 0.6), fire.opacity(0.88))
        tint(flamePath(x + 2.8 * s, y + 0.6 * s, width: 4.0 * s, height: 5.0 * s + leap * 0.4, lean: lick * 0.3), fire.opacity(0.88))
        tint(flamePath(x, y + 0.6 * s, width: 7.6 * s, height: 10.4 * s + leap, lean: lick), fire.opacity(0.94))
        tint(flamePath(x + 0.2 * s, y + 0.6 * s, width: 4.4 * s, height: 6.2 * s + leap * 0.6, lean: lick * 0.5), Color(red: 1.0, green: 0.86, blue: 0.45))
        tint(flamePath(x + 0.1 * s, y + 1.0 * s, width: 1.8 * s, height: 3.2 * s + leap * 0.25, lean: lick * 0.18), Color(red: 1.0, green: 0.96, blue: 0.72).opacity(0.70))
        tint(polygon([(x - 4.2 * s, y + 0.8 * s), (x, y + 1.8 * s), (x + 4.2 * s, y + 0.8 * s), (x, y + 0.2 * s)]), Color(red: 1.0, green: 0.72, blue: 0.30).opacity(0.8))
        for index in 0..<6 {
            let rise = (Self.noise(index, 91) + time * 0.5).truncatingRemainder(dividingBy: 1)
            tint(discPath(x + (CGFloat(Self.noise(index, 93)) - 0.5) * 10 * s + CGFloat(rise) * 3 + CGFloat(sin(time * 2 + Double(index))) * 0.8, y + 8 * s + CGFloat(rise) * 22 * s, 0.7),
                 Color(red: 1.0, green: 0.74, blue: 0.36).opacity(0.9 * (1 - rise)))
        }
    }

    /// A star falling across the sky now and then. Night only.
    mutating func shootingStars(over x: CGFloat, height: CGFloat = 170) {
        let cycle = time / 9, part = cycle - floor(cycle)
        guard part < 0.12 else { return }
        let seed = Int(floor(cycle)), along = CGFloat(part / 0.12)
        let hx = x + (CGFloat(Self.noise(seed, 97)) - 0.5) * 160 - along * 70
        let hy = height - CGFloat(Self.noise(seed, 99)) * 50 - along * 30
        let bright = Double(sin(along * .pi))
        tint(polygon([(hx, hy - 0.5), (hx + 30, hy + 13), (hx, hy + 0.9)]), Color.white.opacity(0.55 * bright), nightOnly: true)
        tint(polygon([(hx, hy - 0.2), (hx + 13, hy + 5.8), (hx, hy + 0.7)]), Color.white.opacity(0.6 * bright), nightOnly: true)
        tint(strokePath([(hx + 1.0, hy + 0.2), (hx + 18, hy + 7.9)], 0.35), Color.white.opacity(0.52 * bright), nightOnly: true)
        tint(discPath(hx, hy + 0.2, 3.2), Color.white.opacity(0.16 * bright), nightOnly: true)
        tint(discPath(hx, hy + 0.2, 1.1), Color.white.opacity(0.95 * bright), nightOnly: true)
    }

    /// Mist lying in the low ground, drifting.
    mutating func mist(from left: CGFloat, to right: CGFloat, at y: CGFloat = 6) {
        for index in 0..<6 {
            let drift = Self.noise(index, 101) + time * 0.008 * (index % 2 == 0 ? 1 : -1)
            let run = drift - floor(drift)
            let wide = 70 + CGFloat(Self.noise(index, 103)) * 60
            let centre = point(left + (right - left) * CGFloat(run), y + CGFloat(index % 3) * 4)
            tint(Path(ellipseIn: CGRect(x: centre.x - wide / 2, y: centre.y - 5, width: wide, height: 10)), Color.white.opacity(0.06 * (1 - 0.3 * night)))
            tint(Path(ellipseIn: CGRect(x: centre.x - wide * 0.3, y: centre.y - 2.6, width: wide * 0.6, height: 5.2)), Color.white.opacity(0.04 * (1 - 0.3 * night)))
            if index.isMultiple(of: 2) {
                tint(Path(ellipseIn: CGRect(x: centre.x - wide * 0.18, y: centre.y - 1.2, width: wide * 0.36, height: 2.4)), Color.white.opacity(0.025 * (1 - 0.3 * night)))
            }
        }
    }

    /// River courses share the same source and mouth, while their banks and
    /// reflections follow the chosen path between those points.
    enum RiverCourse {
        case gentle, bendLeft, bendRight, meander
    }

    /// A stream running out of the scene towards the reader, light moving down it.
    mutating func river(from x: CGFloat, to near: CGFloat, width w: CGFloat = 110, depth: CGFloat = 46,
                        naturalBanks: Bool = false, course: RiverCourse = .gentle) {
        if naturalBanks {
            // One continuous channel, with banks that blend progressively into
            // the adjoining fields. Its curve is fixed in the landscape; only
            // the reflections move, using the same clock as the rest of the scene.
            let width = max(4, abs(w)), reach = max(1, abs(depth))
            func center(_ t: CGFloat) -> CGFloat {
                let bend: CGFloat
                switch course {
                case .gentle: bend = sin(t * .pi) * 0.12
                case .bendLeft: bend = -sin(t * .pi) * 0.34
                case .bendRight: bend = sin(t * .pi) * 0.34
                case .meander: bend = sin(t * .pi * 2) * 0.28
                }
                return x + (near - x) * t + bend * width
            }
            func halfWidth(_ t: CGFloat) -> CGFloat { 5 + (width / 2 - 5) * t }
            func channel(extra: CGFloat) -> Path {
                let samples = (0...16).map { CGFloat($0) / 16 }
                let left = samples.map { t -> Spot in
                    (center(t) - halfWidth(t) - extra * (0.2 + 0.8 * t), -reach * t)
                }
                let right = samples.reversed().map { t -> Spot in
                    (center(t) + halfWidth(t) + extra * (0.2 + 0.8 * t), -reach * t)
                }
                return polygon(left + right)
            }
            // The translucent bands overlap the earth instead of placing a
            // hard outlined wedge against it. Narrower bands lead into water.
            for (extensionAmount, opacity) in [(0.20, 0.08), (0.16, 0.10), (0.12, 0.12),
                                                (0.08, 0.14), (0.04, 0.16)] as [(CGFloat, Double)] {
                tint(channel(extra: width * extensionAmount), shade(0.29, 0.38, 0.25, opacity))
            }
            tint(channel(extra: 0), shade(0.14, 0.40, 0.50, 0.78))
            tint(channel(extra: -width * 0.018), shade(0.27, 0.52, 0.57, 0.20))

            // Fine irregular strands on both banks break up the edge without
            // introducing a separate foreground object or moving the crop.
            var edges = Path()
            for side in [-1.0, 1.0] as [CGFloat] {
                for strand in 1...8 {
                    let t = CGFloat(strand) / 10
                    let h = halfWidth(t), bank = center(t) + side * (h + 1.0 + t * 2.5)
                    let y = -reach * t
                    let length = 1.0 + t * 2.4
                    edges.addPath(strokePath([(bank, y - 0.6), (bank + side * 0.5, y + length)],
                                             0.30 + t * 0.20, smooth: true))
                }
            }
            tint(edges, shade(0.52, 0.56, 0.33, 0.30))

            var reflections = Path()
            for index in 0..<10 {
                let run = (Double(index) / 10 + time * 0.12).truncatingRemainder(dividingBy: 1)
                let t = CGFloat(run), side = CGFloat(Self.noise(index, 107)) - 0.5
                let half = halfWidth(t), cx = center(t) + side * half * 0.65
                let y = -reach * t, length = half * 0.34, thick = 0.3 + t * 0.5
                reflections.addPath(polygon([(cx - length, y), (cx, y + thick),
                                             (cx + length, y), (cx, y - thick)]))
            }
            tint(reflections, Color.white.opacity(0.14 * (1 - 0.5 * night)))
            return
        }
        tint(polygon([(x - 5, 0.5), (x + 5, 0.5), (near + w / 2, -depth), (near - w / 2, -depth)]), shade(0.14, 0.40, 0.54, 0.9))
        // Paler far off; its banks catching the light.
        tint(polygon([(x - 5, 0.5), (x + 5, 0.5), (x + 5 + (near + w / 2 - x - 5) * 0.22, -depth * 0.22), (x - 5 + (near - w / 2 - x + 5) * 0.22, -depth * 0.22)]), shade(0.56, 0.78, 0.88, 0.26))
        tint(polygon([(x - 5, 0.5), (x - 4.4, 0.5), (near - w / 2 + 2.2, -depth), (near - w / 2, -depth)]), Color.white.opacity(0.13 * (1 - 0.5 * night)))
        tint(polygon([(x + 5, 0.5), (x + 4.4, 0.5), (near + w / 2 - 2.2, -depth), (near + w / 2, -depth)]), Color.black.opacity(0.14))
        for index in 0..<10 {
            let run = (Double(index) / 10 + time * 0.12).truncatingRemainder(dividingBy: 1)
            let side = CGFloat(Self.noise(index, 107)) - 0.5
            let half = (5 + (w / 2 - 5) * CGFloat(run))
            let cx = x + (near - x) * CGFloat(run) + side * half * 0.9, y = -depth * CGFloat(run), long = half * 0.5, thick = 0.4 + 0.7 * CGFloat(run)
            tint(polygon([(cx - long, y), (cx, y + thick), (cx + long, y), (cx, y - thick)]),
                 Color.white.opacity(0.20 * sin(run * .pi) * (1 - 0.5 * night)))
            if index.isMultiple(of: 3) {
                tint(polygon([(cx - long * 0.48, y), (cx, y + thick * 0.35), (cx + long * 0.48, y), (cx, y - thick * 0.35)]),
                     Color.white.opacity(0.14 * sin(run * .pi) * (1 - 0.5 * night)))
            }
        }
    }

    /// A lantern hung on its chain: it sways, and burns after dark.
    mutating func hangingLantern(_ x: CGFloat, from top: CGFloat, drop: CGFloat, scale s: CGFloat = 1) {
        let swing = sin(time * 0.6 + Double(x) * 0.1) * 0.06
        let lx = x + CGFloat(sin(swing)) * drop, ly = top - CGFloat(cos(swing)) * drop
        let flame = 0.8 + 0.2 * sin(time * 4.7 + Double(x))
        tint(polygon([(x - 0.3, top), (x + 0.3, top), (lx + 0.3, ly + 8.6 * s), (lx - 0.3, ly + 8.6 * s)]), shade(0.74, 0.60, 0.36, 0.9))
        glow(lx, ly, 14 * s, Color(red: 1.0, green: 0.76, blue: 0.40), 0.34 * flame, nightOnly: true)
        // A ring, a cap, six-sided glass wide at the shoulder, a foot and a drop under it.
        disc(lx, ly + 8.6 * s, 1.2 * s)
        add(smoothPath([(lx - 4.8 * s, ly + 4.2 * s), (lx - 3.6 * s, ly + 5.6 * s), (lx - 1.4 * s, ly + 7.6 * s), (lx, ly + 8.4 * s), (lx + 1.4 * s, ly + 7.6 * s), (lx + 3.6 * s, ly + 5.6 * s), (lx + 4.8 * s, ly + 4.2 * s)], closed: false))
        shape([(lx - 5 * s, ly + 4.4 * s), (lx + 5 * s, ly + 4.4 * s), (lx + 5 * s, ly + 3.6 * s), (lx - 5 * s, ly + 3.6 * s)])
        shape([(lx - 4.2 * s, ly + 3.8 * s), (lx + 4.2 * s, ly + 3.8 * s), (lx + 4.8 * s, ly + 2.0 * s), (lx + 3 * s, ly - 5.2 * s), (lx - 3 * s, ly - 5.2 * s), (lx - 4.8 * s, ly + 2.0 * s)])
        shape([(lx - 3.5 * s, ly - 5.2 * s), (lx + 3.5 * s, ly - 5.2 * s), (lx + 1.1 * s, ly - 7.2 * s), (lx, ly - 9.6 * s), (lx - 1.1 * s, ly - 7.2 * s)])
        tint(polygon([(lx - 3.5 * s, ly + 3.2 * s), (lx + 3.5 * s, ly + 3.2 * s), (lx + 4.0 * s, ly + 1.9 * s), (lx + 2.4 * s, ly - 4.6 * s), (lx - 2.4 * s, ly - 4.6 * s), (lx - 4.0 * s, ly + 1.9 * s)]),
             Color(red: 1.0, green: 0.80, blue: 0.42).opacity(0.22 + 0.72 * night * flame))
        var bars = Path()
        bars.addPath(polygon([(lx - 1.5 * s, ly + 3.2 * s), (lx - 1.1 * s, ly + 3.2 * s), (lx - 0.7 * s, ly - 4.6 * s), (lx - 1.1 * s, ly - 4.6 * s)]))
        bars.addPath(polygon([(lx + 1.5 * s, ly + 3.2 * s), (lx + 1.1 * s, ly + 3.2 * s), (lx + 0.7 * s, ly - 4.6 * s), (lx + 1.1 * s, ly - 4.6 * s)]))
        bars.addPath(polygon([(lx - 4.0 * s, ly + 2.1 * s), (lx + 4.0 * s, ly + 2.1 * s), (lx + 3.9 * s, ly + 1.7 * s), (lx - 3.9 * s, ly + 1.7 * s)]))
        tint(bars, Color.black.opacity(0.42))
        tint(strokePath([(lx - 2.7 * s, ly + 2.7 * s), (lx - 3.0 * s, ly + 0.5 * s),
                         (lx - 2.0 * s, ly - 3.6 * s)], 0.3 * s, smooth: true),
             Color.white.opacity(0.18 + 0.12 * night))
        tint(blockPath(lx, 5.6 * s, 0.25 * s, from: ly - 5.7 * s), shade(0.85, 0.70, 0.43, 0.7))
    }

    /// A small boat with one sail, riding the water.
    mutating func boat(_ x: CGFloat, scale s: CGFloat = 1) {
        let rise = CGFloat(sin(time * 1.0 + Double(x))) * 1.0, tip = CGFloat(sin(time * 0.8 + Double(x))) * 1.2
        // The hull: low amidships, lifting at bow and stern.
        var hull = Path()
        hull.move(to: point(x - 14.6 * s, 5.0 * s + rise))
        hull.addQuadCurve(to: point(x + 15.4 * s, 5.6 * s + rise), control: point(x, 0.8 * s + rise))
        hull.addLine(to: point(x + 16 * s, 4.6 * s + rise))
        hull.addQuadCurve(to: point(x + 8 * s, -2.2 * s + rise), control: point(x + 13.4 * s, -1.0 * s + rise))
        hull.addLine(to: point(x - 8 * s, -2.2 * s + rise))
        hull.addQuadCurve(to: point(x - 14.6 * s, 5.0 * s + rise), control: point(x - 13.6 * s, -1.4 * s + rise))
        hull.closeSubpath()
        add(hull)
        shape([(x - 0.7 * s, 2 * s + rise), (x + 0.7 * s, 2 * s + rise), (x + 0.35 * s + tip, 27 * s + rise), (x - 0.35 * s + tip, 27 * s + rise)])
        detail(strokePath([(x - 12.6 * s, 2.6 * s + rise), (x, 0.2 * s + rise), (x + 13.4 * s, 3.0 * s + rise)], 0.6 * s, smooth: true), strength: 0.9)
        // The sail, bellying, and a smaller one aft of the mast.
        let belly = 1.6 * s + tip * 0.8
        var sail = Path()
        sail.move(to: point(x + 1.3 * s, 5 * s + rise))
        sail.addQuadCurve(to: point(x + 1.2 * s + tip, 26 * s + rise), control: point(x + 1.0 * s + tip * 0.5, 15 * s + rise))
        sail.addQuadCurve(to: point(x + 13.4 * s, 6.4 * s + rise), control: point(x + 10 * s + tip + belly, 17.5 * s + rise))
        sail.addQuadCurve(to: point(x + 1.3 * s, 5 * s + rise), control: point(x + 7 * s, 4.2 * s + rise))
        sail.closeSubpath()
        var aft = Path()
        aft.move(to: point(x - 1.3 * s, 6 * s + rise))
        aft.addLine(to: point(x - 1.0 * s + tip * 0.8, 21 * s + rise))
        aft.addQuadCurve(to: point(x - 9.6 * s, 6.8 * s + rise), control: point(x - 5.0 * s + tip * 0.6 - belly * 0.3, 14 * s + rise))
        aft.closeSubpath()
        tint(aft, shade(0.84, 0.82, 0.74, 0.9))
        tint(sail, shade(0.93, 0.90, 0.80, 0.94))
        tint(strokePath([(x + 1.2 * s + tip, 26 * s + rise), (x + 9.4 * s + belly * 0.5, 5.8 * s + rise)], 0.4 * s), Color.black.opacity(0.12))
        tint(strokePath([(x + 1.2 * s + tip, 26 * s + rise), (x + 5.4 * s + belly * 0.3, 5.2 * s + rise)], 0.4 * s), Color.black.opacity(0.12))
        var seams = Path()
        for level in [9.0, 13.0, 17.0] as [CGFloat] {
            let part = (level - 5) / 21
            seams.addPath(strokePath([(x + (1.4 + part * 0.2) * s + tip * part, level * s + rise),
                                      (x + (7.2 - part * 4.0) * s + tip * part, level * s + rise + 0.4 * s)], 0.22 * s))
        }
        tint(seams, Color.black.opacity(0.13))
        tint(polygon([(x + tip, 27 * s + rise), (x + tip, 29 * s + rise), (x - 4.6 * s + tip, 28.2 * s + rise + CGFloat(sin(time * 2.4 + Double(x))) * 0.5 * s)]), shade(0.76, 0.26, 0.22))
        // Its shadow on the water.
        tint(polygon([(x - 13 * s, -2.4 * s), (x, -1.6 * s), (x + 14 * s, -2.4 * s), (x, -4.4 * s - rise * 0.4)]), Color.black.opacity(0.15))
    }

    /// A walled stronghold: curtain wall, towers, battlements, a lit slit in each tower.
    mutating func fortress(_ x: CGFloat, _ w: CGFloat, _ h: CGFloat) {
        block(x, w, h)
        var merlons = Path()
        for step in stride(from: -w / 2 + 3, through: w / 2 - 3, by: 7) { merlons.addPath(blockPath(x + step, 3.6, 3, from: h)) }
        add(merlons)
        // The towers at its ends, wider at the foot, their heads stepped out over the wall.
        for side in [-1.0, 1.0] as [CGFloat] {
            let tx = x + side * w / 2
            shape([(tx - 7.2, 0), (tx + 7.2, 0), (tx + 6, h + 11), (tx - 6, h + 11)])
            shape([(tx - 6, h + 10), (tx + 6, h + 10), (tx + 7.4, h + 12), (tx - 7.4, h + 12)])
            block(tx, 14.8, 1.2, from: h + 12)
            for step in [-5.4, 0, 5.4] as [CGFloat] { block(tx + step, 3.2, 3, from: h + 13.2) }
            tint(blockPath(tx, 3, 5.6, from: h + 1.2), Color.black.opacity(0.32))
            block(tx, 2, 4, from: h + 2, .light)
            tint(blockPath(tx, 1.6, 4.4, from: h * 0.42), Color.black.opacity(0.34))
            detail(blockPath(tx - 4.6, 1.0, h + 6, from: 2), strength: 0.75)
            detail(blockPath(tx, 12, 0.7, from: h + 8.4), strength: 0.8)
        }
        // The gatehouse standing forward of the wall, and its gate with the grille down.
        block(x, 21, h + 5)
        block(x, 23.4, 1.2, from: h + 5)
        for step in [-9.0, -3.0, 3.0, 9.0] as [CGFloat] { block(x + step, 3.4, 2.8, from: h + 6.2) }
        arch(x, 9, h * 0.55, pointed: true)
        var grille = Path()
        for bar in [-2.6, 0.0, 2.6] as [CGFloat] { grille.addPath(blockPath(x + bar, 0.6, h * (bar == 0 ? 0.53 : 0.44), from: 0)) }
        for level in [0.12, 0.26] as [CGFloat] { grille.addPath(blockPath(x, 9, 0.6, from: h * level)) }
        tint(grille, Color.black.opacity(0.55))
        detail(archPath(x, 12.4, h * 0.55 + 2.4, pointed: true).strokedPath(StrokeStyle(lineWidth: 0.8)), strength: 0.9)
        // A string course along the wall, and slits in it.
        var course = Path()
        for side in [-1.0, 1.0] as [CGFloat] {
            course.addPath(blockPath(x + side * (w / 4 + 2.4), w / 2 - 18, 0.7, from: h * 0.72))
            for slit in stride(from: CGFloat(18), to: w / 2 - 10, by: 13) {
                tint(blockPath(x + side * slit, 1.3, 4, from: h * 0.38), Color.black.opacity(0.34))
            }
        }
        detail(course, strength: 0.8)
        var stoneCourses = Path()
        for level in [0.18, 0.32, 0.48, 0.60] as [CGFloat] {
            for side in [-1.0, 1.0] as [CGFloat] {
                let span = max(0, w / 2 - 20)
                stoneCourses.addPath(blockPath(x + side * (w / 4 + 6), span, 0.35, from: h * level))
            }
        }
        detail(stoneCourses, strength: 0.38)
    }

    /// A row of open arches under a flat roof.
    mutating func arcade(_ x: CGFloat, bays: Int, bay: CGFloat = 13, height h: CGFloat = 20) {
        let w = CGFloat(bays) * bay + 4
        block(x, w, h); block(x, w + 4, 1.8, from: h)
        var carved = Path()
        for index in 0..<bays {
            let ax = x - w / 2 + 2 + bay * (CGFloat(index) + 0.5)
            arch(ax, bay - 5, h - 6, pointed: true)
            // A lamp hung in each arch.
            block(ax, 0.4, (h - 6) * 0.20, from: (h - 6) * 0.78, .light)
            disc(ax, (h - 6) * 0.72, 1.0, .light)
            glow(ax, (h - 6) * 0.72, 5, Self.lampLight, 0.24, nightOnly: true)
        }
        // The piers between: a shaft, a capital where the arch springs, a roundel over each.
        for index in 0...bays {
            let px = x - w / 2 + 2 + bay * CGFloat(index)
            carved.addPath(blockPath(px, 1.2, (h - 6) * 0.50, from: 0.8))
            carved.addPath(blockPath(px, 3.6, 0.9, from: (h - 6) * 0.53))
            if index > 0, index < bays { carved.addPath(discPath(px, h - 3.6, 1.0)) }
        }
        carved.addPath(blockPath(x, w - 1.5, 0.7, from: h - 1.5))
        detail(carved, strength: 0.9)
        var masonry = Path()
        for index in 0..<bays {
            let ax = x - w / 2 + 2 + bay * (CGFloat(index) + 0.5)
            masonry.addPath(blockPath(ax, max(1, bay - 4), 0.3, from: h - 2.8))
        }
        detail(masonry, strength: 0.55)
    }

    /// A banner on a pole, streaming in the wind.
    mutating func banner(_ x: CGFloat, _ h: CGFloat, _ color: Color) {
        block(x, 1.2, h)
        shape([(x - 1.0, h), (x + 1.0, h), (x, h + 3.4)])
        // The cloth: a wave travelling down its length, a forked tail.
        var top: [Spot] = [], foot: [Spot] = []
        for step in 0...8 {
            let part = CGFloat(step) / 8
            let wave = CGFloat(sin(time * 3.2 + Double(x) - Double(step) * 0.55)) * 1.7 * part
            top.append((x + 0.6 + 17.4 * part, h - 0.6 - part * 0.9 + wave))
            foot.append((x + 0.6 + 17.4 * part, h - 7.6 - part * 0.9 + wave * 1.1))
        }
        let end = top[8], low = foot[8]
        tint(polygon(top + [(end.0 - 3.6, (end.1 + low.1) / 2)] + foot.reversed()), color)
        tint(polygon([top[3], top[5], foot[5], foot[3]]), Color.black.opacity(0.12))
        tint(polygon([top[6], top[7], foot[7], foot[6]]), Color.white.opacity(0.08))
        tint(strokePath([top[0], top[2], top[4], top[6], top[8]], 0.35, smooth: true), Color.white.opacity(0.22))
    }

    /// Water rising from a spring and falling back into its basin.
    mutating func spring(_ x: CGFloat, scale s: CGFloat = 1, outflow: Bool = true) {
        // The stones it rises among, and the pool between them.
        add(smoothPath([(x - 9.6 * s, 0), (x - 10.2 * s, 2.6 * s), (x - 7.4 * s, 4.6 * s), (x - 4.8 * s, 3.2 * s), (x - 4.2 * s, 0)]))
        add(smoothPath([(x + 4.0 * s, 0), (x + 4.6 * s, 3.4 * s), (x + 7.6 * s, 5.0 * s), (x + 10.4 * s, 2.6 * s), (x + 9.6 * s, 0)]))
        block(x, 13 * s, 2.3 * s)
        add(smoothPath([(x + 10.4 * s, 0), (x + 11 * s, 1.6 * s), (x + 13 * s, 2.2 * s), (x + 14.6 * s, 0)]))
        tint(polygon([(x - 6.4 * s, 2.6 * s), (x, 3.5 * s), (x + 6 * s, 2.6 * s), (x, 1.9 * s)]), shade(0.30, 0.62, 0.74, 0.92))
        detail(strokePath([(x - 8.6 * s, 2.4 * s), (x - 6.6 * s, 3.2 * s), (x - 5.3 * s, 2.8 * s)], 0.35 * s, smooth: true), strength: 0.55)
        detail(strokePath([(x + 5.2 * s, 2.7 * s), (x + 7.5 * s, 3.5 * s), (x + 9 * s, 2.7 * s)], 0.35 * s, smooth: true), strength: 0.55)
        // The small overflow is omitted when a separate river carries the
        // spring's water, so the two courses don't overlap as detached lines.
        if outflow {
            tint(polygon([(x - 4.4 * s, 0.4 * s), (x - 3.0 * s, 0.4 * s), (x - 8.4 * s, -8 * s), (x - 12.4 * s, -8 * s)]), shade(0.22, 0.52, 0.66, 0.50))
            let run = CGFloat((time * 0.4).truncatingRemainder(dividingBy: 1))
            tint(polygon([(x - 4.6 * s - run * 6 * s, -0.4 * s - run * 7.6 * s), (x - 3.4 * s - run * 6 * s, -0.6 * s - run * 7.6 * s), (x - 5.4 * s - run * 6 * s, -2 * s - run * 7.6 * s)]),
                 Color.white.opacity(0.4 * sin(Double(run) * .pi) * (1 - 0.4 * night)))
        }
        // The water welling up in the middle, and the drops it throws.
        let well = CGFloat(0.5 + 0.5 * sin(time * 2.2))
        tint(domePath(x, 4.6 * s, on: 2.8 * s, rise: (2.2 + 1.6 * well) * s), Color.white.opacity(0.55 * (1 - 0.4 * night)))
        tint(domePath(x, 2.2 * s, on: 2.8 * s, rise: (3.6 + 2.4 * well) * s), Color.white.opacity(0.5 * (1 - 0.4 * night)))
        for index in 0..<9 {
            let run = (Double(index) / 9 + time * 0.7).truncatingRemainder(dividingBy: 1)
            let side: CGFloat = index % 2 == 0 ? 1 : -1
            tint(discPath(x + side * CGFloat(run) * 7 * s, 3 * s + CGFloat(4 * run * (1 - run)) * 16 * s, (0.75 - 0.3 * CGFloat(run)) * s),
                 Color.white.opacity(0.6 * (1 - 0.4 * night)))
        }
        // Grass where the ground is wet.
        var blades = Path()
        for (bx, tall, lean) in [(-11.6, 5.0, -1.6), (-12.6, 3.6, -2.4), (12.0, 4.6, 1.4), (15.4, 4.0, 2.2), (14.2, 5.6, 0.6)] as [(CGFloat, CGFloat, CGFloat)] {
            let stir = CGFloat(sin(time * 1.1 + Double(bx))) * 0.5
            blades.addPath(polygon([(x + (bx - 0.4) * s, 0), (x + (bx + 0.4) * s, 0), (x + (bx + lean + stir) * s, tall * s)]))
        }
        add(blades)
    }

    /// Reeds at the water's edge, bending together.
    mutating func reeds(_ x: CGFloat, count: Int = 9) {
        var stalks = Path(), highlights = Path()
        for index in 0..<count {
            let rx = x + CGFloat(index) * 2.6, h = 9 + CGFloat(Self.noise(index, Int(x))) * 10
            let bend = CGFloat(sin(time * 1.1 + Double(index) * 0.4)) * 1.6
            var stalk = Path()
            stalk.move(to: point(rx - 0.55, 0))
            stalk.addQuadCurve(to: point(rx + bend - 0.2, h), control: point(rx - 0.5 + bend * 0.2, h * 0.6))
            stalk.addLine(to: point(rx + bend + 0.2, h))
            stalk.addQuadCurve(to: point(rx + 0.55, 0), control: point(rx + 0.5 + bend * 0.2, h * 0.6))
            stalk.closeSubpath()
            stalks.addPath(stalk)
            highlights.addPath(strokePath([(rx, 1), (rx + bend * 0.55, h * 0.60)], 0.25))
            if index % 3 == 0 {
                // A seed head: thick, with a thin spike above it.
                let low = h * 0.70, top = h * 0.94
                stalks.addPath(smoothPath([(rx + bend * 0.62 - 0.3, low), (rx + bend * 0.72 - 1.1, (low + top) / 2), (rx + bend * 0.92 - 0.3, top),
                                           (rx + bend * 0.92 + 0.5, top), (rx + bend * 0.72 + 1.3, (low + top) / 2), (rx + bend * 0.62 + 0.5, low)]))
            } else if index % 3 == 1 {
                // A long leaf arcing away from the stalk.
                let way: CGFloat = index % 2 == 0 ? 1 : -1
                var leaf = Path()
                leaf.move(to: point(rx, h * 0.18))
                leaf.addQuadCurve(to: point(rx + way * (4.4 + h * 0.14) + bend * 0.8, h * 0.62), control: point(rx + way * 1.2 + bend * 0.3, h * 0.66))
                leaf.addQuadCurve(to: point(rx + way * 0.7, h * 0.14), control: point(rx + way * 2.4 + bend * 0.3, h * 0.50))
                leaf.closeSubpath()
                stalks.addPath(leaf)
            }
        }
        add(stalks)
        tint(highlights, shade(0.66, 0.69, 0.40, 0.42))
    }

    /// Standing grain, with the wind passing through it in waves.
    mutating func grain(from left: CGFloat, to right: CGFloat) {
        var stalks = Path(), ears = Path(), glints = Path()
        var x = left
        while x < right {
            let h = 6 + CGFloat(Self.noise(Int(x * 3), 109)) * 3
            let bend = CGFloat(sin(time * 1.4 - Double(x) * 0.09)) * 1.5
            stalks.addPath(polygon([(x - 0.45, 0), (x + 0.45, 0), (x + bend + 0.3, h), (x + bend - 0.3, h)]))
            stalks.addPath(polygon([(x - 0.3, h * 0.2), (x + 0.2, h * 0.2), (x - 1.8 + bend * 0.5, h * 0.62)]))
            // The ear: heavy, leaning with the wind, its beard above it.
            ears.addPath(polygon([(x + bend - 0.3, h - 0.6), (x + bend - 0.9 + bend * 0.2, h + 1.2), (x + bend + bend * 0.4, h + 3.2), (x + bend + 0.9 + bend * 0.2, h + 1.2), (x + bend + 0.3, h - 0.6)]))
            ears.addPath(polygon([(x + bend + bend * 0.4 - 0.2, h + 3), (x + bend + bend * 0.4 + 0.2, h + 3), (x + bend + bend * 0.7, h + 5)]))
            glints.addPath(strokePath([(x + bend - 0.35, h + 0.4), (x + bend + 0.35, h + 1.1)], 0.22))
            x += 2.8
        }
        add(stalks)
        tint(ears, shade(0.90, 0.74, 0.36, 0.92))
        tint(glints, shade(0.98, 0.88, 0.62, 0.48))
    }
}

/// The scenes of the surahs: each a place, an object or a sign taken from the
/// surah, standing under Home's sky, so that it passes through the day's light
/// and keeps moving like every scene in the app. A short surah has one scene. A
/// longer one has several, each for a portion of it: a scene begins at an ayah
/// and holds until the next begins (see `SurahScenesPortions.swift`), and the
/// one shown is that of the portion where reading stopped. A surah whose own
/// scene is not drawn yet stands where it was revealed: by the Mountain of Light
/// or among Madinah's palms.
enum SurahScenes {
    /// A stretch of a surah and its scene: from this ayah until the next portion begins.
    struct Portion {
        let from: Int
        let scene: Cityscape
    }

    /// The surahs revealed at Madinah, as marked in the Madinah mushaf.
    static let madinan: Set<Int> = [2, 3, 4, 5, 8, 9, 13, 22, 24, 33, 47, 48, 49, 55, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 76, 98, 99, 110]

    /// The scene of the portion of a surah that holds this ayah.
    static func scene(for surah: Int, ayah: Int = 1) -> Cityscape {
        let parts = portions(of: surah)
        return (parts.last { $0.from <= ayah } ?? parts[0]).scene
    }

    /// A surah's scenes in the order of its ayahs. The first begins at ayah 1;
    /// a surah with one scene has one portion.
    static func portions(of surah: Int) -> [Portion] {
        if let parts = placed[surah], !parts.isEmpty { return parts }
        let only = own[surah]?.first { !unused.contains($0.id) } ?? (madinan.contains(surah) ? Cityscape.oasis : Cityscape.mountainOfLight)
        return [Portion(from: 1, scene: only)]
    }

    /// How many surahs have a scene drawn for them alone.
    static var drawn: Int { own.count }

    /// A scene of the app's own: never a city, so without rooftops, traffic, aircraft or birds.
    /// `ownMoon` is for a scene that draws a moon itself (a crescent, the phases, the sun and moon).
    static func make(_ id: String, backdrop: CityBackdrop = .hills, ownMoon: Bool = false, rtlPlacement: SceneRTLPlacement = .leftMargin,
                     _ draw: @escaping (inout SkylinePen) -> Void) -> Cityscape {
        Cityscape(id: id, name: "", latitude: 0, longitude: 0, backdrop: backdrop, wild: true, ownMoon: ownMoon, quranScene: true, rtlPlacement: rtlPlacement, draw: draw)
    }

    /// The scenes drawn surah by surah: the first ten, then the four parts.
    private static let own: [Int: [Cityscape]] = [first, partA, partB, partC, partD].reduce(into: [:]) { all, part in
        all.merge(part) { kept, _ in kept }
    }

    /// Every scene by its id: those drawn surah by surah, and those drawn for further portions.
    static let byID: [String: Cityscape] = (own.values.flatMap { $0 } + further).reduce(into: [:]) { all, scene in all[scene.id] = scene }

    /// `plan` with each id turned into its scene.
    private static let placed: [Int: [Portion]] = plan.mapValues { rows in
        rows.compactMap { row in byID[row.scene].map { Portion(from: row.from, scene: $0) } }
    }

    private static let first: [Int: [Cityscape]] = [
        // Yusuf: the well by the caravan road, with the eleven stars of his dream;
        // or the storehouses of Egypt beside the river.
        12: [
            make("yusuf-well", rtlPlacement: .preserve) { p in
                p.at(p.width / 2)
                p.dunes([(-150, 90, 22), (10, 120, 30), (150, 100, 20)])
                p.road(to: 40, from: -30)
                p.driftingSand(from: -p.width / 2, to: p.width / 2)
                p.at(96)
                p.well(0, scale: 2.1)
                p.palm(-44, 62); p.palm(40, 48)
                p.stars([(-50, 150), (-34, 164), (-16, 172), (4, 174), (24, 170), (42, 160), (56, 146), (-6, 150), (14, 152), (-26, 140), (34, 138)], size: 1.3)
            },
            make("yusuf-egypt", backdrop: .open) { p in
                p.at(p.width / 2)
                p.water(from: -p.width / 2, to: p.width / 2, depth: 46)
                p.at(104)
                // Storehouses: tall, domed, each with a door high in its side.
                for (x, h) in [(-46.0, 40.0), (-20, 50), (8, 44), (34, 38)] as [(CGFloat, CGFloat)] {
                    p.block(x, 20, h * 0.62); p.dome(x, 20, on: h * 0.62, rise: h * 0.38)
                    p.block(x, 3, 4, from: h * 0.48, .light)
                }
                p.block(0, 124, 5)
                p.palm(-78, 44); p.palm(64, 36); p.palm(80, 48)
                p.boat(-150, scale: 1.2); p.reeds(96); p.reeds(-110, count: 7)
            }
        ],
        // Al-Kahf: the cave in the hillside; or the two gardens with a river between them.
        18: [
            make("kahf-cave") { p in
                p.at(120)
                p.cliff(0, 190, 96)
                p.peak(-70, 120, 70)
                p.cave(6, 30, 34, 22, lit: true)
                p.campfire(6, 30, scale: 0.8)
                p.mist(from: -230, to: 130)
                p.detail(p.polygon([(-12, 26), (26, 26), (30, 28), (-16, 28)]), strength: 0.9)
                p.tree(-58, 26); p.tree(66, 22)
            },
            make("kahf-gardens", backdrop: .open) { p in
                p.at(p.width / 2)
                p.peak(-150, 150, 30); p.peak(170, 130, 24)
                p.river(from: 31, to: 38, naturalBanks: true)
                p.at(176)
                for x in stride(from: CGFloat(-66), through: 0, by: 22) { p.tree(x, 40 + CGFloat(SkylinePen.noise(Int(x), 3)) * 12) }
                p.palm(-88, 62); p.palm(14, 54)
                p.at(60)
                for x in stride(from: CGFloat(-22), through: 44, by: 22) { p.tree(x, 38 + CGFloat(SkylinePen.noise(Int(x), 5)) * 14) }
                p.palm(-40, 64); p.palm(54, 52)
            }
        ],
        // An-Nur: the lamp in its niche.
        24: [
            make("nur-niche") { p in
                p.at(104)
                p.block(-70, 70, 30); p.block(64, 50, 30)
                for x in [-88.0, -70, -52, 54, 72] as [CGFloat] { p.arch(x, 8, 16, pointed: true) }
                p.lampNiche(0)
                p.palm(-112, 44)
                p.shootingStars(over: -90)
            }
        ],
        // At-Tur: Mount Sinai, olives at its foot.
        52: [
            make("tur-sinai") { p in
                p.at(126)
                p.peak(-96, 130, 62, lean: -6)
                p.peak(0, 210, 126, lean: 8)
                p.peak(88, 110, 54)
                p.tree(-74, 22); p.tree(-104, 18); p.tree(72, 20)
                p.mist(from: -240, to: 130, at: 8)
                p.shootingStars(over: -70)
            }
        ],
        // Nuh: the ark on the flood, in rain.
        71: [
            make("nuh-ark", backdrop: .open) { p in
                p.at(p.width / 2)
                p.peak(-150, 130, 34); p.peak(160, 120, 26)
                p.water(from: -p.width / 2, to: p.width / 2, depth: 46)
                p.rain(from: -p.width / 2, to: p.width / 2 + 30)
                p.at(112)
                p.ark(0, scale: 1.7)
            }
        ],
        // Al-Fajr: the tall columns of Iram; or the homes Thamud cut into the rock.
        89: [
            make("fajr-iram") { p in
                p.at(p.width / 2)
                p.dunes([(-140, 110, 20), (120, 130, 16)])
                p.driftingSand(from: -p.width / 2, to: p.width / 2)
                p.at(150)
                p.campfire(-64, 5, scale: 1.1)
                p.columns(-30, heights: [70, 70, 52, 82, 82, 82, 40, 64], gap: 15)
                p.block(34, 150, 4)
                p.shape([(96, 4), (120, 4), (114, 12), (100, 10)])
            },
            make("fajr-thamud") { p in
                p.at(118)
                p.cliff(0, 200, 92)
                p.driftingSand(from: -260, to: 130, height: 18)
                for (x, h) in [(-50.0, 40.0), (-8, 52), (38, 42)] as [(CGFloat, CGFloat)] {
                    p.detail(p.blockPath(x, 30, 1, from: h + 6), strength: 0.9)
                    p.detail(p.polygon([(x - 15, h + 7), (x + 15, h + 7), (x, h + 15)]), strength: 0.6)
                    p.arch(x, 9, h * 0.5, pointed: false)
                    for column in [-10.0, 10] as [CGFloat] { p.detail(p.blockPath(x + column, 1.6, h + 4, from: 2), strength: 0.9) }
                }
            }
        ],
        // Al-Layl: two roads, one made easy and one hard, as night covers them.
        92: [
            make("layl-roads") { p in
                p.at(p.width / 2)
                p.road(to: -40, from: -90, width: 30)
                p.at(108)
                p.peak(10, 180, 104, lean: 6)
                // The steep way, climbing the mountain in turns.
                for (a, b) in [((-58.0, 6.0), (-10.0, 26.0)), ((-10, 26), (-40, 46)), ((-40, 46), (4, 64)), ((4, 64), (-14, 82)), ((-14, 82), (14, 100))] as [((CGFloat, CGFloat), (CGFloat, CGFloat))] {
                    p.tint(p.polygon([a, b, (b.0, b.1 + 1.4), (a.0, a.1 + 1.4)]), p.shade(0.78, 0.66, 0.48, 0.55))
                }
                p.house(-104, 16, 10); p.house(-126, 13, 8)
                p.palm(-144, 30)
                p.hearthSmoke(-104, 12)
                p.shootingStars(over: -60)
            }
        ],
        // Ad-Duha: shelter and enough: a house with its lamp, a well, palms.
        93: [
            make("duha-shelter") { p in
                p.at(p.width / 2)
                p.road(to: 60, from: 10)
                p.at(100)
                p.house(-8, 64, 36)
                p.block(-8, 11, 20, .hole)
                p.block(-8, 5, 6, from: 3, .light)
                p.dome(22, 22, on: 37, rise: 11)
                p.well(62, scale: 1.5)
                p.palm(-58, 64); p.palm(-78, 46); p.palm(96, 56)
                p.tree(-108, 34)
                p.hearthSmoke(-30, 38)
                // The pen is anchored 100 points from the right edge: the
                // former 108...150 range was entirely beyond the screen.
                p.grain(from: -166, to: -112)
            }
        ],
        // Al-Qadr: a still valley, and light coming down through the night until dawn.
        97: [
            make("qadr-night") { p in
                p.at(118)
                p.peak(-100, 140, 58); p.peak(84, 150, 72, lean: -6)
                p.block(-8, 34, 14); p.dome(-8, 20, on: 14, rise: 12); p.spire(-8, 1.2, from: 25, to: 32)
                p.arch(-8, 6, 9, pointed: true)
                p.block(-8, 2, 3, from: 3, .light)
                p.palm(-40, 30); p.palm(26, 26)
                p.descendingLight(over: -8, spread: 150)
                p.mist(from: -230, to: 130)
            }
        ],
        // Al-Fil: the Kaaba, and the stones that fell on the army.
        105: [
            make("fil-kaaba") { p in
                p.at(118)
                p.peak(-104, 130, 54); p.peak(96, 150, 66)
                p.kaaba(0, 1.25)
                p.house(-44, 16, 10); p.house(-62, 13, 8); p.house(46, 15, 9)
                p.fallingStones(over: -70, spread: 150)
                p.hearthSmoke(-44, 11)
            }
        ]
    ]
}
