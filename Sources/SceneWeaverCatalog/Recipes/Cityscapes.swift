import SwiftUI
import SceneWeaver

/// What stands behind a city's landmarks: tall blocks, a low roofline, or hills.
/// `open` is nothing at all: a sea, or a plain running to the horizon.
enum CityBackdrop { case towers, low, hills, open }

/// Shared framing for the layered architectural plates. Overscan keeps their
/// edges outside the viewport even at the extremes of the subtle depth motion.
enum HolyCourtyardLayout {
    static func artworkRect(width: CGFloat, horizon: CGFloat, motion: CGFloat = 0, foreground: Bool = false) -> CGRect {
        ArtworkLayout.rect(width: width, horizon: horizon, motion: motion, depth: foreground ? 2 : 1)
    }

    static func reservedHeight(width: CGFloat) -> CGFloat {
        artworkRect(width: width, horizon: 0).height + 28
    }
}

/// Whether RTL should move a scene's landmarks or preserve an authored landscape.
enum SceneRTLPlacement { case leftMargin, preserve }

/// One city's skyline for Home's scene: its landmarks as flat silhouettes, drawn
/// in code like the rest of the scene. A place within reach of one of these gets
/// it; everywhere else gets the scene's own skyline.
struct Cityscape: Identifiable {
    let id: String
    let name: String
    var aliases: [String] = []
    let latitude: Double
    let longitude: Double
    var backdrop: CityBackdrop = .towers
    /// A place without a town: no rooftops, traffic, aircraft or birds.
    var wild = false
    /// The scene draws a moon of its own, so the sky leaves its moon out.
    var ownMoon = false
    /// A full-width courtyard with dedicated room below Home’s countdown.
    var courtyard = false
    /// Maximum illustrated rise in points after courtyard scaling.
    var courtyardRise: CGFloat = 224
    /// Quran illustrations have their own foreground lighting; city skylines
    /// and the general oasis continue to use the Home palette.
    var quranScene = false
    /// Most landmarks move away from right-aligned text; full-width scenes can
    /// retain their composition instead of translating outside the canvas.
    var rtlPlacement: SceneRTLPlacement = .leftMargin
    /// Draws the landmarks onto the horizon.
    let draw: (inout SkylinePen) -> Void

    func placeForRTL(_ pen: inout SkylinePen) {
        if rtlPlacement == .leftMargin { pen.moveToLeftMargin() }
    }

    static func find(_ id: String) -> Cityscape? { all.first { $0.id == id } }

    /// The city a place name refers to, for results saved before coordinates were matched.
    static func named(_ place: String) -> Cityscape? {
        let wanted = place.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return all.first { $0.name.lowercased() == wanted || $0.aliases.contains(wanted) }
    }

    /// The nearest city with a skyline of its own, when one is within reach.
    static func nearest(latitude: Double, longitude: Double, within kilometres: Double = 60) -> Cityscape? {
        func distance(_ city: Cityscape) -> Double {
            let radians = Double.pi / 180
            let a = latitude * radians, b = city.latitude * radians
            let dLat = b - a, dLon = (city.longitude - longitude) * radians
            let h = sin(dLat / 2) * sin(dLat / 2) + cos(a) * cos(b) * sin(dLon / 2) * sin(dLon / 2)
            return 6371 * 2 * atan2(sqrt(h), sqrt(1 - h))
        }
        guard let best = all.min(by: { distance($0) < distance($1) }), distance(best) <= kilometres else { return nil }
        return best
    }
}

typealias SkylinePen = ScenePen

extension ScenePen {
    var quranScene: Bool { illustrated }
    init(width: CGFloat, horizon: CGFloat, time: Double = 0, night: Double = 0,
         clockDate: Date? = nil, quranScene: Bool) {
        self.init(width: width, horizon: horizon, time: time, night: night,
                  clockDate: clockDate, illustrated: quranScene)
    }
    mutating func occludeCourtyardLights(behind foreground: Path) { occludeLights(behind: foreground) }
    mutating func raisedCourtyard(by lift: CGFloat, draw: (inout SkylinePen) -> Void) {
        var raised = SkylinePen(width: width, horizon: horizon - lift, time: time, night: night,
                                clockDate: clockDate, illustrated: illustrated)
        raised.at(108)
        draw(&raised)
        merge(raised)
    }
    mutating func expandCourtyard() {
        let sx = (width - 24) / 198, sy = min(sx, 1.95)
        apply(CGAffineTransform(a: sx, b: 0, c: 0, d: sy,
                               tx: 12 - (width - 207) * sx, ty: horizon * (1 - sy)))
    }
}

// MARK: The cities

extension Cityscape {
    // MARK: Places of the app's own

    /// Not cities, and so not in `all`: nobody's Home ever shows them. The
    /// Quran and Duas tabs each stand under Home's sky in front of one, which
    /// keeps the three pages apart wherever the reader lives.

    /// The Quran tab: the Mountain of Light, where the first words came down.
    /// Its cave shows as a small lit opening under the summit; a few houses
    /// and palms stand at its foot.
    static let mountainOfLight = Cityscape(id: "mountain-of-light", name: "", latitude: 21.4575, longitude: 39.8583, backdrop: .hills, wild: true) { p in
        p.at(118)
        // The mountain: a broad shoulder, a steep rocky head, a long far slope.
        p.curve { path, at in
            path.move(to: at(-150, 0))
            path.addQuadCurve(to: at(-74, 40), control: at(-112, 14))
            path.addQuadCurve(to: at(-40, 78), control: at(-60, 46))
            path.addLine(to: at(-30, 84)); path.addLine(to: at(-22, 100))
            path.addQuadCurve(to: at(0, 118), control: at(-14, 114))
            path.addQuadCurve(to: at(18, 104), control: at(10, 116))
            path.addLine(to: at(26, 92)); path.addLine(to: at(38, 84))
            path.addQuadCurve(to: at(78, 34), control: at(52, 58))
            path.addQuadCurve(to: at(130, 0), control: at(102, 12))
            path.closeSubpath()
        }
        // The cave, a little under the summit, and the lamp-light in it.
        p.curve(.hole) { path, at in
            path.move(to: at(-6, 92)); path.addQuadCurve(to: at(5, 92), control: at(-1, 106)); path.closeSubpath()
        }
        p.curve(.light) { path, at in
            path.move(to: at(-4, 92.5)); path.addQuadCurve(to: at(3.4, 92.5), control: at(-0.5, 101)); path.closeSubpath()
        }
        // Ledges of rock, and the path worn up the shoulder.
        p.detail(p.polygon([(-30, 84), (-22, 100), (-21, 99), (-28.5, 84)]), strength: 0.9)
        p.detail(p.polygon([(26, 92), (38, 84), (39, 85), (27, 93.5)]), strength: 0.8)
        p.detail(p.polygon([(-96, 22), (-60, 44), (-42, 72), (-43.5, 72), (-61, 45.5), (-96, 23.2)]), strength: 0.7)
        p.detail(p.polygon([(40, 60), (70, 30), (71, 31), (41, 61.5)]), strength: 0.6)
        // Houses at the foot, with a lit window each.
        for (x, w, h) in [(-128.0, 15.0, 9.0), (-110, 12, 12), (-96, 14, 8), (64, 13, 10), (79, 16, 8)] as [(CGFloat, CGFloat, CGFloat)] {
            p.block(x, w, h)
            p.block(x + 2, 2.4, 3, from: h - 5.5, .light)
        }
        for (x, h) in [(-140.0, 22.0), (-84, 19), (94, 23), (52, 17)] as [(CGFloat, CGFloat)] { p.palm(x, h) }
        // Hearth smoke over the houses, mist in the valley, a falling star now and then.
        p.hearthSmoke(-110, 13); p.hearthSmoke(64, 11)
        p.mist(from: -250, to: 130)
        p.shootingStars(over: -30)
    }

    /// The Duas tab: a small mosque by an oasis, one dome and one minaret
    /// among date palms, with an arcade open to the evening.
    static let oasis = Cityscape(id: "oasis", name: "", latitude: 0, longitude: 0, backdrop: .hills, wild: true) { p in
        p.at(104)
        // The prayer hall and its arcade.
        p.block(0, 96, 22)
        for x in stride(from: CGFloat(-36), through: 36, by: 14.4) { p.arch(x, 8, 14, pointed: true) }
        p.block(0, 102, 2.2, from: 22)
        // The dome on its drum, with a crescent finial.
        p.block(-8, 34, 8, from: 24)
        p.dome(-8, 32, on: 32, rise: 22)
        p.spire(-8, 1.4, from: 53, to: 62)
        p.disc(-8, 64, 2.2)
        p.disc(-6.9, 64.4, 1.9, .hole)
        p.tint(p.domePath(-8, 32, on: 32, rise: 22), Color(red: 0.14, green: 0.42, blue: 0.40))
        // Smaller domes over the corners, and the minaret beside the hall.
        p.dome(-38, 13, on: 24, rise: 7)
        p.dome(22, 13, on: 24, rise: 7)
        p.minaret(46, 92)
        // Lamps under the arches after dark.
        for x in stride(from: CGFloat(-36), through: 36, by: 14.4) { p.disc(x, 9, 1.3, .light) }
        // The courtyard wall running off to both sides.
        p.block(-78, 60, 9)
        p.block(84, 44, 9)
        for x in stride(from: CGFloat(-102), through: -54, by: 8) { p.block(x, 3, 2.4, from: 9) }
        for x in stride(from: CGFloat(68), through: 100, by: 8) { p.block(x, 3, 2.4, from: 9) }
        p.detail(p.blockPath(0, 92, 0.8, from: 19), strength: 0.8)
        p.detail(p.domePath(-11, 16, on: 32, rise: 15), strength: 0.7)
        for (x, h) in [(-64.0, 46.0), (-84, 34), (-104, 52), (72, 40), (96, 50), (-48, 30)] as [(CGFloat, CGFloat)] { p.palm(x, h) }
        // The spring the oasis lives by, and lanterns along the courtyard wall.
        p.spring(-134, scale: 1.2)
        p.hangingLantern(-92, from: 9, drop: 0.5, scale: 0.7); p.hangingLantern(84, from: 9, drop: 0.5, scale: 0.7)
    }

    /// Courtyard views, selected only by a confirmed location inside the mosque
    /// grounds. They are deliberately outside `all`, so a city name or a
    /// nearby-location lookup cannot select them.
    static let masjidAlHaram = Cityscape(id: "masjid-al-haram", name: "Makkah", latitude: 21.4225, longitude: 39.8262,
                                        backdrop: .open, wild: true, courtyard: true, courtyardRise: 298, rtlPlacement: .preserve) { p in
        p.at(108)
        p.haramAerialCourtyard()
        p.expandCourtyard()
    }

    static let masjidAnNabawi = Cityscape(id: "masjid-an-nabawi", name: "Madinah", latitude: 24.4684, longitude: 39.6108,
                                         backdrop: .open, wild: true, courtyard: true, courtyardRise: 260, rtlPlacement: .preserve) { p in
        p.at(108)
        p.holyDeepPlaza()
        p.raisedCourtyard(by: 18) { p in
            p.holyMinaret(-20, height: 89)
            p.holyMinaret(44, height: 89)
            p.holyArcade(0, width: 184, base: 18, height: 28, bays: 15)
            for x in [-76.0, -60, -44, 43, 59, 75] as [CGFloat] {
                p.tint(p.domePath(x, 13, on: 48, rise: 6), p.holyStone)
            }
            p.holyMinaret(-48, height: 114)
            p.holyMinaret(73, height: 114)
            // A tall, carved entrance supports the larger emerald dome.
            p.occludeCourtyardLights(behind: p.domePath(-20, 21, on: 48, rise: 15))
            p.holyPortal(12, base: 18)
            p.tint(p.domePath(-20, 21, on: 48, rise: 15), p.holyTone(0.76, 0.83, 0.82))
            p.tint(p.blockPath(13, 35, 9, from: 46), p.holyStone)
            p.tint(p.blockPath(13, 38, 1.4, from: 55), p.holyGold)
            let dome = p.bulbPath(13, 38, on: 56.4, rise: 27)
            p.add(dome)
            p.wash(dome, top: p.holyTone(0.15, 0.57, 0.35), bottom: p.holyTone(0.035, 0.28, 0.20))
            p.tint(p.bulbPath(7, 14, on: 58, rise: 22), p.holyTone(0.40, 0.74, 0.48, 0.25))
            for dx in [-14.0, -9, -4, 4, 9, 14] as [CGFloat] {
                p.tint(p.strokePath([(13 + dx, 57), (13 + dx * 0.88, 68), (13 + dx * 0.40, 79), (13, 83)], 0.4, smooth: true),
                       p.holyTone(0.64, 0.81, 0.55, 0.40))
            }
            for dx in [-13.0, -6.5, 0, 6.5, 13] as [CGFloat] {
                p.tint(p.archPath(13 + dx, 2.5, 4.5, from: 48), p.holyGold)
            }
            p.finial(13, from: 83, height: 7, gilt: true)
        }
        // Large foreground canopies frame the eye-level view, while smaller
        // ones and walkers lead toward the entrance across reflective marble.
        for x in [-48.0, 49] as [CGFloat] {
            p.holyPlazaParasol(x, base: 24, scale: 0.92)
        }
        for x in [-56.0, 56] as [CGFloat] {
            p.holyPlazaParasol(x, base: 7, scale: 1.65)
        }
        p.holyWalkers()
        p.holyParasol(-77, height: 79)
        p.holyParasol(77, height: 82)
        p.holyLantern(-34, height: 28)
        p.holyLantern(43, height: 28)
        p.expandCourtyard()
    }

    static let all: [Cityscape] = [
        riyadh, makkah, madinah, jeddah, dubai, abuDhabi, doha, kuwait, istanbul, cairo, kualaLumpur, jakarta,
        delhi, mumbai, hyderabad, lahore, karachi, islamabad, dhaka, london, newYork, paris, toronto
    ]

    private static let gold = Color(red: 1.0, green: 0.80, blue: 0.42)

    /// Kingdom Centre, Al Faisaliah, the PIF tower and the television tower.
    private static let riyadh = Cityscape(id: "riyadh", name: "Riyadh", latitude: 24.7136, longitude: 46.6753) { p in
        p.at(66)
        p.shape([(-11, 0), (11, 0), (10.5, 88), (8.5, 93), (-8.5, 93), (-10.5, 88)])
        p.curve(.hole) { path, at in
            path.move(to: at(-7.5, 88)); path.addQuadCurve(to: at(7.5, 88), control: at(0, 24)); path.closeSubpath()
        }
        p.tint(p.blockPath(0, 15, 1.6, from: 89.2), p.hue(every: 24), nightOnly: true)
        p.at(120)
        p.shape([(-10, 0), (10, 0), (1.3, 66), (-1.3, 66)])
        p.disc(0, 52, 4.6)
        p.spire(0, 1.8, from: 66, to: 84)
        p.disc(0, 52, 3.2, .light)
        p.beacon(0, 84)
        p.at(24)
        p.shape([(-8, 0), (8, 0), (8, 68), (2, 84), (-8, 72)])
        p.beacon(2, 84)
        p.at(152)
        p.block(0, 2.8, 46)
        p.shape([(-7, 38), (0, 32), (7, 38), (7, 44), (0, 50), (-7, 44)])
        p.spire(0, 1.6, from: 48, to: 62)
        p.beacon(0, 62)
        // The Kingdom Centre's vertical edges and the PIF tower's glazed face.
        // Stop below the opening so the sky still shows through it.
        p.at(66)
        for x in [CGFloat(-8.7), 8.7] { p.detail(p.blockPath(x, 0.8, 78, from: 5)) }
        for y in [CGFloat(12), 24, 34] { p.detail(p.blockPath(0, 14, 0.7, from: y), strength: 0.75) }
        p.at(24)
        p.detail(p.blockPath(-4.6, 1, 56, from: 5))
        p.detail(p.blockPath(3, 0.8, 52, from: 5), strength: 0.7)
        // Broad glazing planes and repeated floors make the tower volumes legible.
        // The centre glazing stops below the Kingdom Centre opening.
        p.at(66)
        p.detail(p.polygon([(-7, 3), (7, 3), (7, 50), (-7, 50)]), strength: 0.55)
        for y in stride(from: CGFloat(8), through: 48, by: 6) {
            p.detail(p.blockPath(0, 14, 1.1, from: y), strength: 1.2)
        }
        p.at(24)
        p.detail(p.polygon([(-7, 3), (-1, 3), (-1, 67), (-7, 67)]), strength: 0.8)
        for y in stride(from: CGFloat(10), through: 62, by: 8) {
            p.detail(p.blockPath(0, 12, 1.1, from: y), strength: 1.05)
        }
        p.at(120)
        p.detail(p.polygon([(-8, 3), (-5.4, 3), (-1.3, 45), (-3.8, 45)]), strength: 1.1)
    }

    /// The clock tower over the Haram, with the mosque's minarets before it.
    private static let makkah = Cityscape(id: "makkah", name: "Makkah", aliases: ["mecca", "makkah al mukarramah", "mecca al-mukarramah"],
                                          latitude: 21.4225, longitude: 39.8262, backdrop: .hills) { p in
        p.at(84)
        p.block(0, 96, 14)
        for (x, h) in [(-38.0, 38.0), (-21, 50), (21, 50), (38, 38)] as [(CGFloat, CGFloat)] {
            p.block(x, 15, h)
            p.block(x, 9, 4, from: h)
            p.spire(x, 3, from: h + 4, to: h + 10)
        }
        p.block(0, 19, 64)
        p.block(0, 23, 16, from: 62)
        p.shape([(-9, 78), (9, 78), (4, 87), (-4, 87)])
        p.spire(0, 4.4, from: 87, to: 104)
        p.disc(0, 105.5, 1.9)
        p.tint(p.discPath(0, 105.5, 1.9), .white, nightOnly: true)
        p.tint(p.discPath(0, 70, 6), Color(red: 0.80, green: 1.0, blue: 0.88), nightOnly: true)
        p.minaret(-74, 52); p.minaret(-60, 52); p.minaret(66, 52)
        // Clock tower's stepped shoulders and ribs below the clock face.
        p.detail(p.blockPath(-5, 0.8, 48, from: 6))
        p.detail(p.blockPath(5, 0.8, 48, from: 6))
        for y in [CGFloat(18), 30, 42, 54] { p.detail(p.blockPath(0, 14, 0.7, from: y), strength: 0.8) }
        // The clock face is visible in daylight too; the existing night tint
        // still lights it independently. The low wings carry tiered windows.
        p.detail(p.blockPath(-4, 5, 49, from: 6), strength: 0.65)
        p.tint(p.discPath(0, 70, 5.4), Color(red: 0.68, green: 0.72, blue: 0.72).opacity(0.75))
        let clockParts = Calendar.current.dateComponents([.hour, .minute], from: p.clockDate ?? Date())
        let minute = Double(clockParts.minute ?? 0)
        let hour = Double((clockParts.hour ?? 0) % 12) + minute / 60
        var hands = Path()
        for (angle, length) in [(minute * Double.pi / 30, CGFloat(3.6)), (hour * Double.pi / 6, CGFloat(2.5))] {
            hands.move(to: p.point(0, 70))
            hands.addLine(to: p.point(CGFloat(sin(angle)) * length, 70 + CGFloat(cos(angle)) * length))
        }
        let handStrokes = hands.strokedPath(StrokeStyle(lineWidth: 0.8, lineCap: .round))
        p.tint(handStrokes, Color.black.opacity(0.65))
        // Night-only tints draw after the daytime face, so repeat the hands
        // above the illuminated disc as the evening lights fade in.
        p.tint(handStrokes, Color.black.opacity(0.65), nightOnly: true)
        for x in [CGFloat(-38), -21, 21, 38] {
            p.detail(p.blockPath(x - 3.5, 3, 25, from: 5), strength: 0.75)
            for y in [CGFloat(9), 17, 25, 33] { p.detail(p.blockPath(x, 10, 1.1, from: y)) }
        }
    }

    /// The Prophet's Mosque: the green dome among its tall minarets.
    private static let madinah = Cityscape(id: "madinah", name: "Madinah", aliases: ["medina", "al madinah", "al madinah al munawwarah"],
                                           latitude: 24.4672, longitude: 39.6111, backdrop: .hills) { p in
        p.at(94)
        p.block(0, 152, 15)
        for x in stride(from: CGFloat(-66), through: 66, by: 12) { p.arch(x, 5, 9, pointed: true) }
        p.block(8, 19, 7, from: 15)
        p.dome(8, 19, on: 22, rise: 12)
        p.spire(8, 1.4, from: 33, to: 41)
        p.tint(p.domePath(8, 19, on: 22, rise: 12), Color(red: 0.16, green: 0.46, blue: 0.33))
        p.dome(-18, 9, on: 15, rise: 5)
        for (x, h) in [(-70.0, 76.0), (-40, 62), (36, 62), (70, 76), (-8, 50)] as [(CGFloat, CGFloat)] { p.minaret(x, h) }
        // A cornice over the courtyard arcade, above its open arches.
        p.detail(p.blockPath(0, 145, 0.8, from: 13), strength: 0.8)
        // Columns between the open arches, plus a curved highlight on the dome.
        for x in stride(from: CGFloat(-60), through: 60, by: 12) {
            p.detail(p.blockPath(x, 2, 8, from: 1), strength: 1.05)
        }
        p.detail(p.domePath(5, 10, on: 22, rise: 8), strength: 0.75)
        for (x, h) in [(-70.0, 76.0), (-40, 62), (36, 62), (70, 76), (-8, 50)] as [(CGFloat, CGFloat)] {
            p.detail(p.blockPath(x, 1.3, h * 0.42, from: 11), strength: 0.85)
            for fraction in [CGFloat(0.60), 0.80] {
                p.detail(p.blockPath(x, 4.0, 1.2, from: h * fraction), strength: 1.0)
            }
        }
    }

    /// King Fahd's Fountain off the corniche, a seaside mosque and a tower.
    private static let jeddah = Cityscape(id: "jeddah", name: "Jeddah", aliases: ["jiddah", "jedda"],
                                          latitude: 21.5433, longitude: 39.1728, backdrop: .low) { p in
        p.at(72)
        let surge = CGFloat(sin(p.time * 1.1)) * 2.5, drift = CGFloat(sin(p.time * 0.45)) * 5
        var mist = Path()
        mist.move(to: p.point(0, 101 + surge))
        mist.addCurve(to: p.point(20 + drift, 50), control1: p.point(14 + drift, 104 + surge), control2: p.point(24 + drift, 78))
        mist.addCurve(to: p.point(1.5, 66), control1: p.point(14 + drift, 52), control2: p.point(6, 58))
        mist.closeSubpath()
        p.tint(mist, .white.opacity(0.11 + 0.05 * p.night))
        var jet = Path()
        jet.move(to: p.point(-0.9, 0))
        jet.addQuadCurve(to: p.point(-2.4, 84 + surge), control: p.point(-1.2, 50))
        jet.addQuadCurve(to: p.point(0.4, 102 + surge), control: p.point(-2.6, 98 + surge))
        jet.addQuadCurve(to: p.point(3.2, 84 + surge), control: p.point(3.6, 98 + surge))
        jet.addQuadCurve(to: p.point(0.9, 0), control: p.point(1.6, 50))
        jet.closeSubpath()
        p.tint(jet, .white.opacity(0.62 + 0.2 * p.night))
        p.at(128)
        p.block(0, 36, 10)
        p.dome(0, 20, on: 10, rise: 11)
        p.dome(-13, 7, on: 10); p.dome(13, 7, on: 10)
        p.spire(0, 1.2, from: 21, to: 27)
        p.minaret(22, 46)
        p.at(22)
        p.block(0, 17, 60)
        p.block(0, 8, 10, from: 34, .hole)
        p.block(-2, 7, 8, from: 12, .hole)
        // Facade edges around, never over, the tower's openings.
        p.detail(p.blockPath(-6.8, 0.9, 48, from: 5))
        p.detail(p.blockPath(6.8, 0.9, 48, from: 5))
        // Lit sides and setbacks, leaving both cut-through windows untouched.
        for x in [CGFloat(-7), 7] { p.detail(p.blockPath(x, 2, 48, from: 5), strength: 0.85) }
        for y in [CGFloat(5), 24, 29, 48, 54] {
            p.detail(p.blockPath(0, 13, 1.1, from: y), strength: 0.95)
        }
        p.at(128)
        p.detail(p.domePath(-2, 11, on: 10, rise: 7), strength: 0.65)
        for x in [CGFloat(-14), -7, 0, 7, 14] {
            p.detail(p.blockPath(x, 2, 5, from: 2), strength: 0.85)
        }
    }

    /// Burj Khalifa, Burj Al Arab and the Emirates Towers.
    private static let dubai = Cityscape(id: "dubai", name: "Dubai", latitude: 25.2048, longitude: 55.2708) { p in
        p.at(86)
        p.shape([(-9, 0), (9, 0), (9, 18), (7.2, 18), (7.2, 34), (5.6, 34), (5.6, 50), (4.2, 50), (4.2, 64), (3, 64), (3, 76),
                 (1.9, 76), (1.9, 88), (1, 88), (1, 98), (0.4, 98), (0, 112), (-0.4, 101), (-1.2, 101), (-1.2, 91), (-2.2, 91),
                 (-2.2, 81), (-3.4, 81), (-3.4, 69), (-4.8, 69), (-4.8, 56), (-6.2, 56), (-6.2, 40), (-7.6, 40), (-7.6, 24), (-9, 24)])
        p.beacon(0, 112)
        // A light climbing the tower, as in its evening shows.
        p.tint(p.blockPath(0, 1.6, 7, from: CGFloat((p.time * 16).truncatingRemainder(dividingBy: 100))), .white.opacity(0.85), nightOnly: true)
        p.at(28)
        var sail = Path()
        sail.move(to: p.point(7, 0)); sail.addLine(to: p.point(7, 50))
        sail.addQuadCurve(to: p.point(-13, 0), control: p.point(-16, 42)); sail.closeSubpath()
        p.curve { path, _ in path.addPath(sail) }
        p.tint(sail, p.hue(every: 36).opacity(0.38), nightOnly: true)
        p.block(7, 1.6, 12, from: 50)
        p.block(-9.5, 6.5, 1.3, from: 38)
        p.at(142)
        p.shape([(-12, 0), (-4, 0), (-4, 58), (-12, 44)])
        p.spire(-4.6, 1.4, from: 56, to: 68)
        p.shape([(2, 0), (10, 0), (10, 48), (2, 36)])
        p.spire(9.4, 1.4, from: 46, to: 56)
        // The Khalifa's narrow central spine echoes its stepped setbacks.
        p.at(86)
        p.detail(p.blockPath(0, 0.8, 75, from: 7))
        for (y, width) in [(CGFloat(22), CGFloat(12)), (38, 9), (54, 7), (68, 5)] {
            p.detail(p.blockPath(0, width, 0.7, from: y), strength: 0.8)
        }
        // Stepped metal bands and glass wings trace the Burj's taper.
        p.detail(p.polygon([(-6, 2), (-3, 2), (-2, 50), (-4.5, 50)]), strength: 0.9)
        for (y, width) in [(CGFloat(8), CGFloat(14)), (16, 14), (28, 11), (44, 9), (58, 6), (72, 4)] {
            p.detail(p.blockPath(0, width, 1.1, from: y), strength: 1.1)
        }
        p.at(28)
        p.detail(p.polygon([(-10, 3), (4, 3), (4, 42), (-4, 34)]), strength: 0.7)
        for y in [CGFloat(8), 16, 24, 32] { p.detail(p.blockPath(0, 6, 1, from: y), strength: 1.1) }
        p.at(142)
        p.detail(p.polygon([(-11, 2), (-7, 2), (-7, 40), (-11, 40)]), strength: 0.95)
        p.detail(p.polygon([(3, 2), (7, 2), (7, 42), (3, 36)]), strength: 0.95)
    }

    /// The Sheikh Zayed Grand Mosque.
    private static let abuDhabi = Cityscape(id: "abu-dhabi", name: "Abu Dhabi", aliases: ["abu zaby", "abudhabi"],
                                            latitude: 24.4539, longitude: 54.3773, backdrop: .low) { p in
        p.at(90)
        p.block(0, 136, 14)
        for x in stride(from: CGFloat(-56), through: 56, by: 14) { p.arch(x, 7, 10, pointed: true) }
        p.onion(0, 28, on: 14, 24)
        p.onion(-30, 18, on: 14, 15); p.onion(30, 18, on: 14, 15)
        p.onion(-52, 11, on: 14, 9); p.onion(52, 11, on: 14, 9)
        for (x, h) in [(-78.0, 54.0), (-66, 64), (66, 64), (78, 54)] as [(CGFloat, CGFloat)] { p.minaret(x, h) }
        p.detail(p.blockPath(0, 128, 0.8, from: 12), strength: 0.8)
        // Arcade piers sit between the pointed openings; domes retain their
        // separate silhouettes and the minarets keep their own lighting.
        for x in stride(from: CGFloat(-49), through: 49, by: 14) {
            p.detail(p.blockPath(x, 2.5, 9, from: 1), strength: 1.05)
        }
        p.detail(p.domePath(0, 14, on: 14, rise: 11), strength: 0.65)
        for (x, h) in [(-78.0, 54.0), (-66, 64), (66, 64), (78, 54)] as [(CGFloat, CGFloat)] {
            p.detail(p.blockPath(x, 1.4, h * 0.55, from: 2), strength: 0.9)
        }
    }

    /// West Bay: Doha Tower, the Tornado Tower and the Torch.
    private static let doha = Cityscape(id: "doha", name: "Doha", aliases: ["ad dawhah"], latitude: 25.2854, longitude: 51.5310) { p in
        p.at(122)
        p.block(0, 15, 58)
        p.dome(0, 15, on: 58, rise: 12)
        p.spire(0, 1.6, from: 69, to: 88)
        p.beacon(0, 88)
        p.at(84)
        p.curve { path, at in
            path.move(to: at(-9.5, 0)); path.addQuadCurve(to: at(-8.5, 66), control: at(-3, 33))
            path.addLine(to: at(8.5, 66)); path.addQuadCurve(to: at(9.5, 0), control: at(3, 33)); path.closeSubpath()
        }
        p.at(30)
        p.shape([(-3, 0), (3, 0), (2.2, 70), (6.5, 84), (6.5, 90), (-6.5, 90), (-6.5, 84), (-2.2, 70)])
        p.spire(0, 1.6, from: 90, to: 104)
        p.tint(p.blockPath(0, 13, 6, from: 84), gold.opacity(0.55 + 0.35 * sin(p.time * 5)), nightOnly: true)
        p.beacon(0, 104)
        p.at(160)
        p.block(0, 30, 10); p.block(0, 20, 8, from: 10); p.block(0, 11, 8, from: 18)
        // The Tornado Tower's narrow central glazing follows its curved sides.
        p.at(84)
        p.detail(p.blockPath(0, 1, 54, from: 5))
        for y in [CGFloat(14), 27, 40, 53] { p.detail(p.blockPath(0, 5, 0.7, from: y), strength: 0.8) }
        // Contrasting glass planes and floor bands on West Bay's towers.
        p.detail(p.blockPath(-2, 4, 55, from: 4), strength: 0.75)
        for y in stride(from: CGFloat(8), through: 56, by: 8) {
            p.detail(p.blockPath(0, 9, 1.1, from: y), strength: 1.1)
        }
        p.at(122)
        p.detail(p.blockPath(-3.5, 4, 53, from: 3), strength: 0.8)
        for y in stride(from: CGFloat(10), through: 50, by: 8) {
            p.detail(p.blockPath(0, 12, 1, from: y), strength: 1.0)
        }
        p.at(30)
        p.detail(p.polygon([(-2.2, 4), (-0.2, 4), (-0.2, 68), (-1.5, 68)]), strength: 1.0)
    }

    /// The Kuwait Towers, the Liberation Tower and Al Hamra.
    private static let kuwait = Cityscape(id: "kuwait", name: "Kuwait City", aliases: ["kuwait", "al kuwayt"],
                                          latitude: 29.3759, longitude: 47.9774, backdrop: .low) { p in
        p.at(92)
        p.spire(0, 7, from: 0, to: 88)
        p.curve { path, at in path.addEllipse(in: CGRect(origin: at(0, 44), size: .zero).insetBy(dx: -10.5, dy: -8.5)) }
        p.curve { path, at in path.addEllipse(in: CGRect(origin: at(0, 62), size: .zero).insetBy(dx: -6.5, dy: -5.5)) }
        p.spire(-26, 6, from: 0, to: 66)
        p.curve { path, at in path.addEllipse(in: CGRect(origin: at(-26, 36), size: .zero).insetBy(dx: -9.5, dy: -8) ) }
        p.spire(20, 3.6, from: 0, to: 54)
        for x in [CGFloat(-6), -2, 2, 6] { p.disc(x, 44, 0.8, .light) }
        for x in [CGFloat(-30), -26, -22] { p.disc(x, 36, 0.8, .light) }
        p.disc(-2.4, 62, 0.8, .light); p.disc(2.4, 62, 0.8, .light)
        p.beacon(0, 88); p.beacon(-26, 66)
        p.at(26)
        p.block(0, 4.6, 66)
        p.shape([(-8, 60), (8, 60), (6.5, 70), (-6.5, 70)])
        p.spire(0, 2.6, from: 70, to: 100)
        p.beacon(0, 100)
        p.at(150)
        p.shape([(-8, 0), (8, 0), (8, 60), (-2, 80), (-8, 70)])
        p.detail(p.blockPath(-4, 0.8, 58, from: 5))
        p.detail(p.blockPath(4, 0.8, 54, from: 5), strength: 0.8)
        // The spherical reservoirs get curved-toned centers and bands; the
        // existing independently lit windows remain above these muted faces.
        p.at(92)
        p.detail(p.discPath(0, 44, 5.3), strength: 0.65)
        p.detail(p.discPath(-26, 36, 4.9), strength: 0.65)
        p.detail(p.discPath(0, 62, 3.5), strength: 0.65)
        for (x, y, width) in [(CGFloat(0), CGFloat(41), CGFloat(15)), (0, 47, 15), (-26, 33, 13), (-26, 39, 13)] {
            p.detail(p.blockPath(x, width, 1.2, from: y), strength: 1.1)
        }
        p.at(150)
        p.detail(p.blockPath(-3, 5, 58, from: 3), strength: 0.7)
        for y in stride(from: CGFloat(10), through: 58, by: 9) {
            p.detail(p.blockPath(0, 12, 1, from: y), strength: 1.0)
        }
    }

    /// The Blue Mosque with its six minarets, and the Galata Tower.
    private static let istanbul = Cityscape(id: "istanbul", name: "Istanbul", aliases: ["i̇stanbul"],
                                            latitude: 41.0082, longitude: 28.9784, backdrop: .low) { p in
        p.at(78)
        p.block(0, 66, 16)
        p.dome(-21, 22, on: 16, rise: 9); p.dome(21, 22, on: 16, rise: 9)
        p.block(0, 34, 8, from: 16)
        p.dome(-11, 14, on: 24, rise: 6); p.dome(11, 14, on: 24, rise: 6)
        p.block(0, 24, 5, from: 24)
        p.dome(0, 26, on: 29, rise: 13)
        p.spire(0, 1.4, from: 41, to: 49)
        for (x, h) in [(-38.0, 74.0), (38, 74), (-50, 64), (50, 64), (-72, 52), (-86, 52)] as [(CGFloat, CGFloat)] {
            p.minaret(x, h, .ottoman)
        }
        p.block(-79, 14, 10)
        p.at(196)
        p.block(0, 9, 20)
        p.block(0, 11.5, 1.8, from: 20)
        p.block(0, 7.5, 4, from: 21.8)
        p.spire(0, 9.5, from: 25.8, to: 37)
        p.block(0, 5, 1.2, from: 22.8, .light)
        // The Galata Tower's small masonry courses.
        for y in [CGFloat(6), 11, 16] { p.detail(p.blockPath(0, 7, 0.7, from: y), strength: 0.85) }
        // Leaded dome and a row of facade windows anchor the mosque's mass.
        p.at(78)
        p.detail(p.domePath(-3, 12, on: 29, rise: 8), strength: 0.7)
        p.detail(p.domePath(-23, 10, on: 16, rise: 6), strength: 0.65)
        p.detail(p.domePath(19, 10, on: 16, rise: 6), strength: 0.65)
        for x in stride(from: CGFloat(-27), through: 27, by: 9) {
            p.detail(p.blockPath(x, 3.5, 7, from: 3), strength: 1.05)
        }
        p.at(196)
        p.detail(p.blockPath(-2.5, 3, 17, from: 2), strength: 0.8)
    }

    /// The pyramids of Giza and the Cairo Tower.
    private static let cairo = Cityscape(id: "cairo", name: "Cairo", aliases: ["al qahirah", "giza"],
                                         latitude: 30.0444, longitude: 31.2357, backdrop: .low) { p in
        // After dark the pyramids are lit, faintly, from below.
        p.at(112); p.shape([(-33, 0), (0, 42), (33, 0)]); p.tint(p.polygon([(-33, 0), (0, 42), (33, 0)]), gold.opacity(0.10), nightOnly: true)
        p.at(60); p.shape([(-36, 0), (0, 46), (36, 0)]); p.tint(p.polygon([(-36, 0), (0, 46), (36, 0)]), gold.opacity(0.13), nightOnly: true)
        p.at(18); p.shape([(-17, 0), (0, 21), (17, 0)]); p.tint(p.polygon([(-17, 0), (0, 21), (17, 0)]), gold.opacity(0.10), nightOnly: true)
        p.at(160)
        p.shape([(-3.2, 0), (3.2, 0), (2.4, 60), (-2.4, 60)])
        p.shape([(-2.4, 58), (2.4, 58), (5.5, 67), (-5.5, 67)])
        p.block(0, 6.5, 4, from: 67)
        p.spire(0, 1.6, from: 71, to: 84)
        p.beacon(0, 84)
        p.at(204)
        p.block(0, 22, 12)
        p.dome(-3, 13, on: 12, rise: 8)
        p.minaret(9, 36)
        p.at(160)
        // Observation deck and slim shaft of Cairo Tower.
        p.detail(p.blockPath(0, 4, 0.9, from: 63))
        p.detail(p.blockPath(0, 0.8, 46, from: 8), strength: 0.8)
        // Distinct illuminated faces give the pyramids volume at both times
        // of day; their existing warm nighttime wash remains independent.
        p.at(112)
        p.detail(p.polygon([(-30, 1), (0, 40), (0, 1)]), strength: 0.75)
        p.at(60)
        p.detail(p.polygon([(-31, 1), (0, 44), (0, 1)]), strength: 0.8)
        p.at(18)
        p.detail(p.polygon([(-14, 1), (0, 20), (0, 1)]), strength: 0.7)
        p.at(160)
        p.detail(p.blockPath(-1.1, 1.6, 54, from: 3), strength: 1.1)
        for y in [CGFloat(13), 23, 33, 43, 53] { p.detail(p.blockPath(0, 4, 1, from: y)) }
    }

    /// The Petronas Towers, the KL Tower and Merdeka 118.
    private static let kualaLumpur = Cityscape(id: "kuala-lumpur", name: "Kuala Lumpur", aliases: ["kl"],
                                               latitude: 3.1390, longitude: 101.6869) { p in
        p.at(98)
        for dx in [CGFloat(-12), 12] {
            p.shape([(dx - 6.5, 0), (dx + 6.5, 0), (dx + 6.5, 50), (dx + 5.4, 50), (dx + 5.4, 62), (dx + 4.2, 62), (dx + 4.2, 70),
                     (dx + 3, 70), (dx + 3, 76), (dx + 1.6, 76), (dx + 1.6, 81), (dx - 1.6, 81), (dx - 1.6, 76), (dx - 3, 76),
                     (dx - 3, 70), (dx - 4.2, 70), (dx - 4.2, 62), (dx - 5.4, 62), (dx - 5.4, 50), (dx - 6.5, 50)])
            p.spire(dx, 1.6, from: 81, to: 99)
            p.beacon(dx, 99)
        }
        p.block(0, 12, 2.2, from: 38)
        p.block(0, 11, 0.9, from: 38.7, .light)
        p.shape([(-0.7, 38), (0.7, 38), (-4.8, 27), (-6, 27)])
        p.shape([(-0.7, 38), (0.7, 38), (6, 27), (4.8, 27)])
        p.at(30)
        p.shape([(-3, 0), (3, 0), (2, 62), (-2, 62)])
        p.shape([(-2, 62), (2, 62), (7, 68), (7, 72), (4, 76), (-4, 76), (-7, 72), (-7, 68)])
        p.spire(0, 2.4, from: 76, to: 104)
        p.beacon(0, 104)
        p.at(150)
        p.shape([(-9, 0), (9, 0), (8, 42), (4.5, 76), (1.2, 92), (0.4, 112), (-0.4, 112), (-1.6, 90), (-5, 72), (-8, 46)])
        p.beacon(0, 112)
        // Facade bands make the twin Petronas towers read at a glance.
        p.at(98)
        for x in [CGFloat(-12), 12] {
            for y in [CGFloat(12), 20, 28, 46, 54, 64] { p.detail(p.blockPath(x, 7, 0.7, from: y), strength: 0.8) }
        }
        // Wider alternating floors and vertical glazing reveal the Petronas
        // setbacks while the existing illuminated bridge remains in front.
        for x in [CGFloat(-12), 12] {
            p.detail(p.blockPath(x - 2, 3, 47, from: 3), strength: 0.75)
            for (y, width) in [(CGFloat(8), CGFloat(11)), (16, 11), (24, 11), (32, 11), (46, 11), (54, 9), (62, 8), (70, 5)] {
                p.detail(p.blockPath(x, width, 1.1, from: y), strength: 1.05)
            }
        }
        p.at(150)
        p.detail(p.polygon([(-7, 3), (-2, 3), (0, 84), (-3, 70), (-6, 44)]), strength: 0.75)
    }

    /// The National Monument and the Istiqlal Mosque.
    private static let jakarta = Cityscape(id: "jakarta", name: "Jakarta", latitude: -6.2088, longitude: 106.8456) { p in
        p.at(100)
        p.shape([(-17, 0), (17, 0), (11, 7), (-11, 7)])
        p.shape([(-3.2, 7), (3.2, 7), (1.8, 64), (-1.8, 64)])
        p.block(0, 8.5, 2.4, from: 64)
        let tip = 79 + CGFloat(sin(p.time * 6) + sin(p.time * 9.7)) * 0.9 * CGFloat(p.night)
        var flame = Path()
        flame.move(to: p.point(0, tip))
        flame.addQuadCurve(to: p.point(-3.2, 70), control: p.point(-3.8, 75))
        flame.addQuadCurve(to: p.point(3.2, 70), control: p.point(0, 65))
        flame.addQuadCurve(to: p.point(0, tip), control: p.point(3.8, 75))
        p.curve { path, _ in path.addPath(flame) }
        p.tint(flame, gold)
        p.at(40)
        p.block(0, 48, 20)
        p.dome(0, 28, on: 20, rise: 13)
        p.spire(0, 1.4, from: 32, to: 40)
        p.block(-30, 2.8, 58)
        p.spire(-30, 2.8, from: 58, to: 70)
        p.at(152)
        p.shape([(-7, 0), (7, 0), (7, 56), (3, 68), (0.4, 82), (-3, 62), (-7, 56)])
        p.beacon(0.4, 82)
        p.detail(p.blockPath(-3, 0.9, 48, from: 6))
        // Monument pedestal, a fine shaft highlight and the mosque's pillars.
        p.at(100)
        p.detail(p.polygon([(-14, 1), (0, 1), (0, 6), (-10, 6)]), strength: 0.8)
        p.detail(p.blockPath(-1, 1.5, 52, from: 9), strength: 1.0)
        p.at(40)
        p.detail(p.domePath(-3, 13, on: 20, rise: 8), strength: 0.7)
        for x in stride(from: CGFloat(-20), through: 20, by: 8) {
            p.detail(p.blockPath(x, 2.4, 14, from: 2), strength: 0.95)
        }
        p.at(152)
        p.detail(p.blockPath(-3, 3, 46, from: 5), strength: 0.7)
        for y in stride(from: CGFloat(10), through: 50, by: 8) {
            p.detail(p.blockPath(0, 11, 1, from: y), strength: 1.0)
        }
    }

    /// The Qutub Minar, India Gate and the Jama Masjid.
    private static let delhi = Cityscape(id: "delhi", name: "Delhi", aliases: ["new delhi"],
                                         latitude: 28.6139, longitude: 77.2090, backdrop: .low) { p in
        p.at(138)
        p.shape([(-6.5, 0), (6.5, 0), (3, 74), (-3, 74)])
        p.block(0, 12.5, 1.8, from: 24); p.block(0, 10.5, 1.8, from: 42)
        p.block(0, 8.5, 1.6, from: 56); p.block(0, 7.2, 1.4, from: 66)
        p.block(0, 4, 3, from: 74)
        p.at(88)
        p.block(0, 28, 34)
        p.block(0, 31, 3, from: 34); p.block(0, 22, 4, from: 37); p.block(0, 14, 3, from: 41)
        p.dome(0, 10, on: 44, rise: 3)
        p.arch(0, 11, 26)
        p.disc(0, 2.4, 1.3, .light)
        p.at(36)
        p.block(0, 46, 12)
        p.arch(0, 7, 9, pointed: true)
        p.onion(0, 17, on: 12, 16)
        p.onion(-15, 11, on: 12, 10); p.onion(15, 11, on: 12, 10)
        p.minaret(-26, 46, .mughal); p.minaret(26, 46, .mughal)
        // Distinctive horizontal balconies on the Qutub Minar.
        p.at(138)
        for (y, width) in [(CGFloat(24), CGFloat(10)), (42, 8), (56, 6)] {
            p.detail(p.blockPath(0, width, 0.8, from: y))
        }
        // Qutub Minar's fluted stone shaft and projecting balcony bands.
        p.at(138)
        p.detail(p.blockPath(-2.3, 2.0, 47, from: 8), strength: 1.0)
        for (y, width) in [(CGFloat(24), CGFloat(11)), (42, 9), (56, 7), (66, 6)] {
            p.detail(p.blockPath(0, width, 1.5, from: y), strength: 1.2)
        }
        // India Gate's recessed piers and broad entablature, clear of the arch.
        p.at(88)
        for x in [CGFloat(-10), 10] { p.detail(p.blockPath(x, 3.0, 23, from: 3), strength: 0.85) }
        p.detail(p.blockPath(0, 25, 2.0, from: 30), strength: 1.1)
        p.at(36)
        for x in [CGFloat(-13), 13] { p.arch(x, 3.5, 6.5, from: 2, pointed: true) }

    }

    /// The Gateway of India, the Taj Mahal Palace and the towers behind them.
    private static let mumbai = Cityscape(id: "mumbai", name: "Mumbai", aliases: ["bombay"], latitude: 19.0760, longitude: 72.8777) { p in
        p.at(92)
        p.block(0, 44, 24)
        p.block(0, 22, 8, from: 24)
        p.dome(0, 14, on: 32, rise: 6)
        for x in [CGFloat(-20), 20] { p.block(x, 5, 34); p.dome(x, 5.6, on: 34, rise: 3.4) }
        for x in [CGFloat(-11.5), 11.5] { p.block(x, 3.4, 36); p.dome(x, 4, on: 36, rise: 2.6) }
        p.arch(0, 12, 19, pointed: true)
        p.arch(-15, 5, 12, pointed: true); p.arch(15, 5, 12, pointed: true)
        p.at(34)
        p.block(0, 52, 24)
        p.block(0, 15, 8, from: 24)
        p.onion(0, 17, on: 32, 19)
        for x in [CGFloat(-23), 23] { p.block(x, 6, 30); p.onion(x, 7.5, on: 30, 8) }
        p.at(146)
        p.shape([(-11, 0), (-3, 0), (-3, 62), (-7, 74), (-11, 62)])
        p.shape([(3, 0), (11, 0), (11, 62), (7, 74), (3, 62)])
        p.spire(-7, 1.2, from: 73, to: 84); p.spire(7, 1.2, from: 73, to: 84)
        p.beacon(-7, 84); p.beacon(7, 84)
        // A slim cornice on the Gateway, safely above its three arches.
        p.at(92)
        p.detail(p.blockPath(0, 38, 0.8, from: 22))
        // Layered stone piers and the upper frieze frame the Gateway's arches.
        p.at(92)
        for x in [CGFloat(-8.5), 8.5] { p.detail(p.blockPath(x, 2.1, 15, from: 3), strength: 0.95) }
        p.detail(p.blockPath(0, 22, 1.7, from: 25), strength: 1.15)
        for x in [CGFloat(-20), 20] { p.detail(p.blockPath(x, 4, 1.7, from: 25), strength: 1.15) }
        p.detail(p.blockPath(0, 19, 1.3, from: 29), strength: 0.95)
        // The palace facade is punctuated by two storeys of arched windows.
        p.at(34)
        for x in [CGFloat(-18), -12, -6, 0, 6, 12, 18] {
            p.arch(x, 2.4, 4.1, from: 4)
            p.arch(x, 2.4, 4.1, from: 13)
        }
        p.detail(p.blockPath(0, 42, 1.5, from: 20), strength: 1.0)

    }

    /// The Charminar.
    private static let hyderabad = Cityscape(id: "hyderabad", name: "Hyderabad", latitude: 17.3850, longitude: 78.4867, backdrop: .low) { p in
        p.at(92)
        p.block(0, 32, 26)
        p.block(0, 35, 1.8, from: 26)
        p.block(0, 30, 10, from: 27.8)
        p.block(0, 33, 1.6, from: 37.8)
        p.arch(0, 15, 21, pointed: true)
        for x in [CGFloat(-9), 0, 9] { p.arch(x, 4, 6.5, from: 29, pointed: true) }
        for x in [CGFloat(-19), 19] {
            p.block(x, 5.2, 58)
            for y in [CGFloat(36), 46, 56] { p.block(x, 8, 1.6, from: y); p.disc(x, y + 3.2, 0.8, .light) }
            p.onion(x, 7.5, on: 58, 11)
        }
        p.at(26)
        p.block(0, 30, 10)
        p.onion(0, 13, on: 10, 12)
        p.minaret(-17, 34, .mughal); p.minaret(17, 34, .mughal)
        p.at(92)
        p.detail(p.blockPath(0, 28, 0.8, from: 24))
        p.detail(p.blockPath(0, 28, 0.8, from: 37.8), strength: 0.75)
        // Charminar's heavy piers, upper gallery and ringed minarets.
        p.at(92)
        for x in [CGFloat(-12), 12] { p.detail(p.blockPath(x, 3, 18, from: 3), strength: 0.9) }
        p.detail(p.blockPath(0, 31, 1.8, from: 26), strength: 1.1)
        for x in [CGFloat(-19), 19] {
            p.detail(p.blockPath(x, 2.2, 32, from: 3), strength: 0.9)
            for y in [CGFloat(36), 46, 56] { p.detail(p.blockPath(x, 7, 1.4, from: y), strength: 1.2) }
        }

    }

    /// The Badshahi Mosque and the Minar-e-Pakistan.
    private static let lahore = Cityscape(id: "lahore", name: "Lahore", latitude: 31.5204, longitude: 74.3587, backdrop: .low) { p in
        p.at(102)
        p.block(0, 66, 14)
        p.onion(0, 23, on: 16, 24)
        p.onion(-23, 15, on: 14, 15); p.onion(23, 15, on: 14, 15)
        p.block(0, 18, 22)
        p.arch(0, 9, 16, pointed: true)
        p.minaret(-42, 60, .mughal); p.minaret(42, 60, .mughal)
        p.minaret(-33, 24, .mughal); p.minaret(33, 24, .mughal)
        p.at(24)
        p.shape([(-13, 0), (13, 0), (9, 6), (-9, 6)])
        p.shape([(-9, 6), (9, 6), (6, 11), (-6, 11)])
        p.shape([(-4.2, 11), (4.2, 11), (2.6, 66), (-2.6, 66)])
        p.block(0, 8, 1.4, from: 30); p.block(0, 7, 1.4, from: 48)
        p.dome(0, 5.4, on: 66, rise: 4)
        p.spire(0, 1.2, from: 69, to: 77)
        p.disc(0, 64, 1.1, .light)
        p.detail(p.blockPath(0, 6, 0.8, from: 30))
        p.detail(p.blockPath(0, 5, 0.8, from: 48))
        // The Badshahi Mosque's recessed side arcades and broad roof cornice.
        p.at(102)
        for x in [CGFloat(-25), -17, 17, 25] { p.arch(x, 3.5, 7, from: 2, pointed: true) }
        for x in [CGFloat(-18), 18] { p.detail(p.blockPath(x, 26, 1.6, from: 12), strength: 1.05) }
        for x in [CGFloat(-6.5), 6.5] { p.detail(p.blockPath(x, 2, 12, from: 3), strength: 0.85) }
        // Stacked platforms and the Minar's tapered central shaft.
        p.at(24)
        p.detail(p.blockPath(0, 17, 1.5, from: 5), strength: 1.0)
        p.detail(p.blockPath(-1.5, 1.5, 40, from: 14), strength: 0.9)
        p.detail(p.blockPath(0, 6, 1.5, from: 48), strength: 1.1)

    }

    /// The Mazar-e-Quaid and the towers of Clifton.
    private static let karachi = Cityscape(id: "karachi", name: "Karachi", latitude: 24.8607, longitude: 67.0011) { p in
        p.at(96)
        p.block(0, 56, 4)
        p.shape([(-17, 4), (17, 4), (15, 30), (-15, 30)])
        p.arch(0, 9, 19, from: 4, pointed: true)
        p.dome(0, 27, on: 30, rise: 15)
        p.spire(0, 1.2, from: 44, to: 51)
        p.at(26)
        p.shape([(-7, 0), (7, 0), (7, 72), (-1, 90), (-7, 80)])
        p.beacon(-1, 90)
        p.at(152)
        p.block(0, 13, 54)
        p.block(0, 7, 4, from: 54)
        p.detail(p.blockPath(-4, 0.8, 45, from: 4))
        p.detail(p.blockPath(4, 0.8, 45, from: 4), strength: 0.8)
        // The mausoleum's recessed side piers and projecting marble base.
        p.at(96)
        for x in [CGFloat(-11), 11] { p.detail(p.blockPath(x, 3.3, 18, from: 6), strength: 0.95) }
        p.detail(p.blockPath(0, 29, 1.6, from: 27), strength: 1.05)
        p.detail(p.blockPath(0, 52, 1.5, from: 1), strength: 1.1)
        p.at(26)
        p.detail(p.blockPath(-3.5, 2.0, 57, from: 5), strength: 0.95)
        for y in [CGFloat(19), 36, 53, 68] { p.detail(p.blockPath(0, 10, 1.1, from: y), strength: 0.8) }

    }

    /// The Faisal Mosque under the Margalla Hills.
    private static let islamabad = Cityscape(id: "islamabad", name: "Islamabad", aliases: ["rawalpindi"],
                                             latitude: 33.6844, longitude: 73.0479, backdrop: .hills) { p in
        p.at(96)
        p.shape([(-34, 0), (34, 0), (34, 6), (14, 22), (9, 18), (0, 38), (-9, 18), (-14, 22), (-34, 6)])
        for (x, h) in [(-42.0, 80.0), (42, 80), (-26, 66), (26, 66)] as [(CGFloat, CGFloat)] {
            p.shape([(x - 1.9, 0), (x + 1.9, 0), (x + 1.3, h * 0.84), (x - 1.3, h * 0.84)])
            p.spire(x, 2.6, from: h * 0.84, to: h)
            p.disc(x, h * 0.84 - 2, 0.8, .light)
        }
        // A seam along the mosque's folded central roof.
        p.detail(p.polygon([(-0.6, 3), (0.6, 3), (0.4, 30), (0, 36), (-0.4, 30)]))
        // The mosque's folded concrete planes make its tent-like roof legible.
        p.detail(p.polygon([(-31, 3), (-14, 19), (-10, 16), (-23, 3)]), strength: 0.85)
        p.detail(p.polygon([(3, 3), (9, 16), (13, 20), (26, 3)]), strength: 0.7)
        p.detail(p.polygon([(-8, 3), (-1.4, 29), (-1.4, 4)]), strength: 0.9)
        for x in [CGFloat(-42), 42] { p.detail(p.blockPath(x, 1.5, 52, from: 5), strength: 0.9) }

    }

    /// The National Parliament House and Ahsan Manzil.
    private static let dhaka = Cityscape(id: "dhaka", name: "Dhaka", aliases: ["dacca"], latitude: 23.8103, longitude: 90.4125, backdrop: .low) { p in
        p.at(104)
        p.block(0, 30, 30)
        p.block(0, 20, 3, from: 30)
        p.block(-24, 17, 24); p.block(24, 17, 24)
        p.block(-41, 15, 18); p.block(41, 15, 18)
        p.disc(-24, 13, 5.5, .hole)
        p.shape([(17.5, 6), (30.5, 6), (24, 20)], .hole)
        p.block(-41, 5, 10, from: 4, .hole); p.block(41, 5, 10, from: 4, .hole)
        p.block(0, 4, 18, from: 6, .hole)
        p.block(0, 2, 14, from: 8, .light)
        p.at(28)
        p.block(0, 46, 16)
        p.block(0, 15, 8, from: 16)
        p.dome(0, 17, on: 24, rise: 12)
        p.spire(0, 1.2, from: 35, to: 42)
        p.arch(-13, 5, 9); p.arch(13, 5, 9)
        p.at(104)
        // Parliament's upper beam, clear of its geometric openings.
        p.detail(p.blockPath(0, 26, 0.8, from: 27))
        // Broad concrete planes and recessed details on the parliament.
        p.at(104)
        for x in [CGFloat(-12), 12] { p.detail(p.blockPath(x, 3, 18, from: 5), strength: 0.8) }
        p.detail(p.blockPath(0, 27, 1.7, from: 27), strength: 1.1)
        for x in [CGFloat(-47), -35, 35, 47] { p.detail(p.blockPath(x, 2.5, 10, from: 5), strength: 0.75) }
        // Palace windows and a visible cornice around its central dome.
        p.at(28)
        for x in [CGFloat(-18), -6, 6, 18] { p.arch(x, 2.8, 5.5, from: 3) }
        p.detail(p.blockPath(0, 40, 1.5, from: 14), strength: 1.0)

    }

    /// The Elizabeth Tower and Parliament, the London Eye and the Shard.
    private static let london = Cityscape(id: "london", name: "London", latitude: 51.5074, longitude: -0.1278, backdrop: .low) { p in
        p.at(132)
        p.block(0, 9, 52)
        p.block(0, 11.5, 11, from: 52)
        p.block(0, 9.5, 5, from: 63)
        p.shape([(-5.5, 68), (5.5, 68), (2.4, 78), (-2.4, 78)])
        p.block(0, 3.4, 3, from: 78)
        p.spire(0, 3, from: 81, to: 93)
        p.disc(0, 57.5, 3.6, .light)
        // The Elizabeth Tower's clock remains visible in daylight and follows
        // the scene's displayed time, as does the Makkah clock tower.
        p.tint(p.discPath(0, 57.5, 3.3), Color(red: 0.82, green: 0.80, blue: 0.72).opacity(0.85))
        let londonTime = Calendar.current.dateComponents([.hour, .minute], from: p.clockDate ?? Date())
        let minute = Double(londonTime.minute ?? 0)
        let hour = Double((londonTime.hour ?? 0) % 12) + minute / 60
        var clockHands = Path()
        for (angle, length) in [(minute * Double.pi / 30, CGFloat(2.4)), (hour * Double.pi / 6, CGFloat(1.7))] {
            clockHands.move(to: p.point(0, 57.5))
            clockHands.addLine(to: p.point(CGFloat(sin(angle)) * length, 57.5 + CGFloat(cos(angle)) * length))
        }
        let hands = clockHands.strokedPath(StrokeStyle(lineWidth: 0.55, lineCap: .round))
        p.tint(hands, Color.black.opacity(0.75))
        p.tint(hands, Color.black.opacity(0.75), nightOnly: true)
        p.block(-26, 40, 15)
        for x in stride(from: CGFloat(-44), through: -8, by: 6) { p.spire(x, 2, from: 15, to: 21) }
        p.block(-50, 9, 27)
        for x in [CGFloat(-53.5), -46.5] { p.spire(x, 2, from: 27, to: 33) }
        p.at(76)
        p.shape([(-0.9, 27), (0.9, 27), (-9, 0), (-11.5, 0)])
        p.shape([(-0.9, 27), (0.9, 27), (11.5, 0), (9, 0)])
        let turn = p.time * 0.06
        p.tint(Path(ellipseIn: CGRect(origin: p.point(0, 27), size: .zero).insetBy(dx: -22, dy: -22)).strokedPath(StrokeStyle(lineWidth: 1.4)),
               Color(red: 0.55, green: 0.75, blue: 1.0).opacity(0.85), nightOnly: true)
        p.curve { path, at in
            let rim = Path(ellipseIn: CGRect(origin: at(0, 27), size: .zero).insetBy(dx: -22, dy: -22))
            path.addPath(rim.strokedPath(StrokeStyle(lineWidth: 2)))
            for step in 0..<8 {
                let angle = Double(step) * .pi / 8 + turn
                let dx = CGFloat(cos(angle)) * 22, dy = CGFloat(sin(angle)) * 22
                var spoke = Path()
                spoke.move(to: at(-dx, 27 - dy)); spoke.addLine(to: at(dx, 27 + dy))
                path.addPath(spoke.strokedPath(StrokeStyle(lineWidth: 0.8)))
            }
        }
        p.disc(0, 27, 2.6)
        p.at(24)
        p.shape([(-10, 0), (10, 0), (2.2, 90), (1.2, 100), (0.3, 91), (-1.5, 96), (-2.6, 88)])
        p.beacon(1.2, 100)
        p.detail(p.blockPath(0, 0.8, 66, from: 8))
        // Elizabeth Tower's stone piers, tiered clock surround and roof ledge.
        p.at(132)
        for x in [CGFloat(-3), 3] { p.detail(p.blockPath(x, 1.5, 44, from: 4), strength: 0.95) }
        for y in [CGFloat(17), 34, 49, 63] { p.detail(p.blockPath(0, 8, 1.4, from: y), strength: 1.0) }
        p.detail(p.blockPath(0, 10, 1.4, from: 67), strength: 1.1)
        // Palace of Westminster's closely spaced windows and parapet.
        for x in stride(from: CGFloat(-42), through: -10, by: 5) { p.arch(x, 1.8, 6, from: 3, pointed: true) }
        p.detail(p.blockPath(-26, 38, 1.5, from: 13), strength: 1.0)

    }

    /// The Empire State Building, One World Trade Center and the Chrysler Building.
    private static let newYork = Cityscape(id: "new-york", name: "New York", aliases: ["new york city", "nyc", "manhattan", "brooklyn"],
                                           latitude: 40.7128, longitude: -74.0060) { p in
        p.at(94)
        p.block(0, 24, 16); p.block(0, 19, 34, from: 16); p.block(0, 14, 16, from: 50)
        p.block(0, 9, 8, from: 66); p.block(0, 5, 5, from: 74)
        p.spire(0, 3, from: 79, to: 104)
        p.tint(p.blockPath(0, 9, 8, from: 66), p.hue(every: 40).opacity(0.9), nightOnly: true)
        p.tint(p.blockPath(0, 5, 5, from: 74), p.hue(every: 40).opacity(0.9), nightOnly: true)
        p.beacon(0, 104)
        p.at(34)
        p.shape([(-9, 0), (9, 0), (9, 14), (5.5, 80), (-5.5, 80), (-9, 14)])
        p.block(0, 7, 2, from: 80)
        p.spire(0, 1.8, from: 82, to: 108)
        p.beacon(0, 108)
        p.at(146)
        p.block(0, 13, 54)
        p.shape([(-6.5, 54), (6.5, 54), (5.4, 60), (4.2, 65), (3, 69.5), (1.8, 73), (0.8, 76),
                 (-0.8, 76), (-1.8, 73), (-3, 69.5), (-4.2, 65), (-5.4, 60)])
        p.spire(0, 1.6, from: 76, to: 93)
        for (x, y) in [(-3.4, 59.0), (3.4, 59), (-2.2, 65), (2.2, 65), (0, 71)] as [(CGFloat, CGFloat)] { p.disc(x, y, 0.8, .light) }
        p.at(94)
        // The Empire State Building's Art Deco setbacks and vertical ribs.
        for x in [CGFloat(-6), 0, 6] { p.detail(p.blockPath(x, 0.8, 28, from: 18)) }
        for y in [CGFloat(18), 34, 50] { p.detail(p.blockPath(0, 14, 0.7, from: y), strength: 0.8) }
        // Art Deco setbacks, glazed panels and a few illuminated office floors.
        p.at(94)
        for x in [CGFloat(-7), -3, 3, 7] { p.detail(p.blockPath(x, 1.5, 30, from: 18), strength: 0.85) }
        for y in [CGFloat(16), 32, 48, 64] { p.detail(p.blockPath(0, 14, 1.4, from: y), strength: 1.05) }
        p.at(34)
        p.detail(p.polygon([(-6, 7), (-3.5, 7), (-2.3, 76), (-4.3, 76)]), strength: 0.9)
        for y in [CGFloat(19), 36, 53, 70] { p.detail(p.blockPath(0, 9, 1.2, from: y), strength: 0.8) }
        // Chrysler Building's terraced crown beneath its lit triangular windows.
        p.at(146)
        for (y, width) in [(CGFloat(55), CGFloat(11)), (61, 9), (67, 6)] {
            p.detail(p.blockPath(0, width, 1.2, from: y), strength: 1.05)
        }

    }

    /// The Eiffel Tower, the Arc de Triomphe and Sacré-Cœur.
    private static let paris = Cityscape(id: "paris", name: "Paris", latitude: 48.8566, longitude: 2.3522, backdrop: .low) { p in
        p.at(94)
        var tower = Path()
        tower.move(to: p.point(-25, 0))
        tower.addCurve(to: p.point(-3.2, 62), control1: p.point(-13, 18), control2: p.point(-5.5, 40))
        tower.addLine(to: p.point(-1.2, 96)); tower.addLine(to: p.point(1.2, 96)); tower.addLine(to: p.point(3.2, 62))
        tower.addCurve(to: p.point(25, 0), control1: p.point(5.5, 40), control2: p.point(13, 18))
        tower.addLine(to: p.point(16, 0))
        tower.addQuadCurve(to: p.point(-16, 0), control: p.point(0, 32))
        tower.closeSubpath()
        p.curve { path, _ in path.addPath(tower) }
        p.curve(.hole) { path, at in
            path.move(to: at(-16, 0)); path.addQuadCurve(to: at(16, 0), control: at(0, 32)); path.closeSubpath()
        }
        p.tint(tower, gold.opacity(0.30), nightOnly: true)
        // Its lights sparkle: a few come on and go off many times a second.
        let beat = Int(p.time * 5)
        for spark in 0..<26 where SkylinePen.noise(spark, beat) > 0.6 {
            let y = CGFloat(SkylinePen.noise(spark, 3)) * 94
            let half = y < 62 ? 2.6 + 20 * pow(1 - y / 62, 2.2) : 1.4
            let x = (CGFloat(SkylinePen.noise(spark, 5)) * 2 - 1) * half
            if y > 16 || abs(x) > 15 { p.disc(x, y, 0.75, .light) }
        }
        p.beacon(0, 108)
        p.block(0, 22, 2.2, from: 19); p.block(0, 11, 1.8, from: 40); p.block(0, 4.4, 2.4, from: 88)
        p.spire(0, 1.4, from: 96, to: 108)
        p.at(26)
        p.block(0, 27, 26)
        p.block(0, 29, 2, from: 19)
        p.arch(0, 10, 17)
        p.at(160)
        p.block(0, 30, 14)
        p.block(0, 11, 7, from: 14)
        p.dome(0, 11, on: 21, rise: 13)
        p.dome(-10, 6, on: 14, rise: 6); p.dome(10, 6, on: 14, rise: 6)
        p.spire(0, 1.2, from: 33, to: 39)
        // The Arc de Triomphe's frieze sits above the open central arch.
        p.at(26)
        p.detail(p.blockPath(0, 24, 0.8, from: 21))
        // Horizontal lattice decks make the Eiffel Tower read at phone size.
        // They start above the open base, leaving the arch and sparkle intact.
        p.at(94)
        for (y, width) in [(CGFloat(21), CGFloat(17)), (28, 13), (35, 10), (44, 7), (53, 5)] {
            p.detail(p.blockPath(0, width, 1.3, from: y), strength: 1.15)
        }
        p.detail(p.polygon([(-7, 23), (-5.5, 23), (3.5, 38), (2.2, 38)]), strength: 0.9)
        p.detail(p.polygon([(5.5, 23), (7, 23), (-2.2, 38), (-3.5, 38)]), strength: 0.9)
        p.at(26)
        for x in [CGFloat(-10), 10] { p.detail(p.blockPath(x, 3, 13, from: 3), strength: 0.9) }
        p.detail(p.blockPath(0, 25, 1.6, from: 21), strength: 1.1)

    }

    /// The CN Tower and the stadium dome beside it.
    private static let toronto = Cityscape(id: "toronto", name: "Toronto", latitude: 43.6532, longitude: -79.3832) { p in
        p.at(92)
        p.shape([(-3.8, 0), (3.8, 0), (1.6, 66), (-1.6, 66)])
        p.shape([(-7.5, 64), (7.5, 64), (6.2, 71), (-6.2, 71)])
        p.dome(0, 10, on: 71, rise: 3.4)
        p.block(0, 2.6, 14, from: 71)
        p.spire(0, 1.8, from: 85, to: 113)
        p.tint(p.polygon([(-7.5, 64), (7.5, 64), (6.2, 71), (-6.2, 71)]), p.hue(every: 30, offset: 0.55).opacity(0.85), nightOnly: true)
        p.beacon(0, 113)
        p.at(42)
        p.block(0, 46, 6)
        p.dome(0, 46, on: 6, rise: 15)
        p.at(140)
        p.shape([(-7, 0), (7, 0), (7, 50), (-7, 58)])
        p.at(160)
        p.block(0, 12, 44)
        // The CN Tower's observation deck and the stadium's curved roof remain
        // separate from its animated colour-changing night illumination.
        p.at(140)
        p.detail(p.blockPath(-4, 0.8, 39, from: 5))
        p.detail(p.blockPath(4, 0.8, 39, from: 5), strength: 0.8)
        // The CN Tower's observation deck and the stadium roof's broad ribs.
        p.at(92)
        p.detail(p.polygon([(-6.3, 65), (6.3, 65), (5.9, 67), (-6.0, 67)]), strength: 1.1)
        p.detail(p.blockPath(-1.6, 1.5, 45, from: 9), strength: 0.9)
        p.at(42)
        p.detail(p.polygon([(-19, 7), (-14, 7), (-8, 17), (-9, 17)]), strength: 0.75)
        p.detail(p.polygon([(14, 7), (19, 7), (9, 17), (8, 17)]), strength: 0.75)
        p.detail(p.blockPath(0, 2.2, 13, from: 7), strength: 0.8)

    }
}

// MARK: The two sacred courtyards

private extension SkylinePen {
    // Both courtyards are floodlit after sunset; retain their material colours.
    func holyTone(_ r: Double, _ g: Double, _ b: Double, _ opacity: Double = 1) -> Color {
        let light = 1 - 0.30 * night
        return Color(red: r * light, green: g * light, blue: b * light).opacity(opacity)
    }

    var holyStone: Color { holyTone(0.94, 0.87, 0.72) }
    var holyGold: Color { holyTone(0.80, 0.60, 0.28) }

    /// The dense Makkah skyline from the reference, drawn behind the Haram.
    /// The clock face uses the same displayed date as the other city clocks.
    mutating func haramCityAboveCourtyard() {
        let mountains = polygon([(-99, 97), (-99, 124), (-85, 132), (-70, 122), (-56, 129),
                                 (-37, 118), (-12, 124), (9, 115), (35, 128), (60, 119),
                                 (84, 135), (99, 125), (99, 97)])
        wash(mountains, top: holyTone(0.68, 0.65, 0.58, 0.6), bottom: holyTone(0.40, 0.45, 0.45, 0.18))
        var windows = Path(), floors = Path()
        for index in 0..<17 {
            let x = CGFloat(-93 + index * 11)
            let height = CGFloat(13 + Int(Self.noise(index, 906) * 27))
            let base: CGFloat = 94
            let width: CGFloat = index % 3 == 0 ? 11 : 9
            wash(blockPath(x, width, height, from: base), top: holyTone(0.73, 0.65, 0.53), bottom: holyTone(0.42, 0.43, 0.38))
            tint(polygon([(x + width / 2, base), (x + width / 2 + 2, base + 2),
                          (x + width / 2 + 2, base + height + 1.5), (x + width / 2, base + height)]), holyTone(0.34, 0.34, 0.29))
            tint(blockPath(x, width + 0.7, 1, from: base + height), holyStone)
            for y in stride(from: CGFloat(98), through: base + height - 3, by: 3) {
                floors.addPath(blockPath(x, width - 1, 0.18, from: y))
                for dx in [-2.5, 0, 2.5] as [CGFloat] {
                    windows.addPath(blockPath(x + dx, 0.7, 1.3, from: y + 0.6))
                }
            }
        }
        tint(floors, holyTone(0.96, 0.89, 0.75, 0.35))
        tint(windows, holyTone(0.17, 0.23, 0.23, 0.65))
        tint(windows, Self.lampLight.opacity(0.28), nightOnly: true)
        // Stepped massing and flanking towers of Abraj al-Bait.
        for (x, height) in [(39.0, 31.0), (75, 35), (47, 41), (67, 43)] as [(CGFloat, CGFloat)] {
            wash(blockPath(x, 10, height, from: 95), top: holyTone(0.67, 0.61, 0.46), bottom: holyTone(0.30, 0.33, 0.28))
            for y in stride(from: CGFloat(99), through: 94 + height, by: 2.5) {
                tint(blockPath(x, 8, 0.25, from: y), holyTone(0.94, 0.85, 0.62, 0.5))
            }
        }
        wash(blockPath(57, 17, 38, from: 95), top: holyTone(0.70, 0.65, 0.49), bottom: holyTone(0.34, 0.37, 0.31))
        for x in [CGFloat(51), 54, 57, 60, 63] {
            tint(blockPath(x, 0.8, 33, from: 97), holyTone(0.91, 0.82, 0.59, 0.55))
        }
        wash(blockPath(57, 19, 13, from: 133), top: holyStone, bottom: holyTone(0.55, 0.56, 0.42))
        tint(blockPath(57, 20, 1.5, from: 132), holyGold)
        tint(discPath(57, 139.5, 5), holyTone(0.12, 0.25, 0.22))
        tint(discPath(57, 139.5, 4.4).strokedPath(StrokeStyle(lineWidth: 0.5)), holyGold)
        let parts = Calendar.current.dateComponents([.hour, .minute], from: clockDate ?? Date(timeIntervalSince1970: 0))
        let minute = Double(parts.minute ?? 0), hour = Double((parts.hour ?? 0) % 12) + minute / 60
        for (angle, reach) in [(hour / 12 * Double.pi * 2, 2.2), (minute / 60 * Double.pi * 2, 3.4)] {
            tint(strokePath([(57, 139.5), (57 + CGFloat(sin(angle) * reach), 139.5 + CGFloat(cos(angle) * reach))], 0.45), holyStone)
        }
        tint(polygon([(47.5, 146), (57, 150), (66.5, 146)]), holyTone(0.30, 0.37, 0.30))
        // Small crescent, drawn as a stroked arc rather than invented lettering.
        tint(strokePath([(57.7, 152), (56.8, 151.2), (55.9, 151.8), (56, 153)], 0.5, smooth: true), holyGold)
        tint(blockPath(57, 0.5, 2, from: 149.5), holyGold)
    }

    mutating func holyDeepPlaza() {
        wash(polygon([(-99, 0), (99, 0), (85, 37), (-85, 37)]), top: holyTone(0.75, 0.81, 0.77), bottom: holyTone(0.98, 0.95, 0.84))
        for y in [2.0, 7, 13, 19, 24, 28, 32, 35] as [CGFloat] {
            tint(blockPath(0, 198 - y * 28 / 37, 0.25, from: y), holyTone(0.36, 0.49, 0.46, 0.27))
        }
        for x in stride(from: CGFloat(-90), through: 90, by: 15) {
            tint(strokePath([(x, 0.4), (x * 0.60, 36.5)], 0.25), holyTone(0.36, 0.49, 0.46, 0.27))
        }
        // Glazed marble catches broken gold and green reflections.
        for i in 0..<16 {
            let x = CGFloat(-76 + i * 10)
            let h = CGFloat(3 + Self.noise(i, 203) * 8)
            tint(polygon([(x - 1, 4), (x + 2, 4), (x + 1, h + 9), (x, h + 10)]), holyTone(0.66, 0.59, 0.36, 0.09))
        }
    }

    mutating func holyWalkers() {
        // Anonymous figures, with perspective and a gentle, continuous walk.
        // No faces or historical individuals are represented.
        var robes = Path(), dark = Path(), heads = Path(), shadows = Path()
        for index in 0..<26 {
            let lane = index % 3
            let progress = (Self.noise(index, 701) + time * (index % 2 == 0 ? 0.0014 : -0.0011)).truncatingRemainder(dividingBy: 1)
            let wrapped = progress < 0 ? progress + 1 : progress
            let x = CGFloat(-72 + wrapped * 144)
            let y = CGFloat(4 + lane * 10) + CGFloat(Self.noise(index, 707)) * 3
            let h = CGFloat(5.5 - Double(lane) * 1.1)
            let body = polygon([(x - h * 0.2, y), (x + h * 0.2, y), (x + h * 0.13, y + h * 0.68),
                                (x, y + h * 0.82), (x - h * 0.13, y + h * 0.68)])
            if index % 4 == 0 { dark.addPath(body) } else { robes.addPath(body) }
            heads.addPath(discPath(x, y + h * 0.91, h * 0.09))
            shadows.addPath(strokePath([(x - h * 0.12, y - 0.3), (x + h * 0.40, y - h * 0.4)], h * 0.18))
        }
        tint(shadows, holyTone(0.24, 0.34, 0.32, 0.16))
        wash(robes, top: holyTone(0.98, 0.97, 0.89), bottom: holyTone(0.67, 0.73, 0.69))
        tint(dark, holyTone(0.24, 0.30, 0.29))
        tint(heads, holyTone(0.48, 0.42, 0.31))
    }

    /// An elevated, illustrative view into the Mataf, with the roof of the
    /// Kaaba visible and the galleries enclosing the marble on three sides.
    mutating func haramAerialCourtyard() {
        haramCityAboveCourtyard()
        holyArcade(0, width: 190, base: 69, height: 17, bays: 21)
        holyArcade(0, width: 188, base: 86, height: 10, bays: 24)
        for x in stride(from: CGFloat(-87), through: 87, by: 14.5) {
            tint(domePath(x, 11, on: 98, rise: 3.5), holyStone)
        }
        holyMinaret(-70, height: 114)
        holyMinaret(70, height: 114)
        occludeCourtyardLights(behind: polygon([(-99, 0), (99, 0), (83, 68), (-83, 68)]))
        // The marble trapezoid widens toward the observer, rather than reading
        // as a flat strip beneath an eye-level facade.
        wash(polygon([(-99, 0), (99, 0), (83, 68), (-83, 68)]),
             top: holyTone(0.84, 0.87, 0.83), bottom: holyTone(0.98, 0.97, 0.90))
        for y in stride(from: CGFloat(5), through: 65, by: 6) {
            let half = 99 - y * 16 / 68
            tint(blockPath(0, half * 2, 0.25, from: y), holyTone(0.59, 0.68, 0.66, 0.20))
        }
        for x in stride(from: CGFloat(-90), through: 90, by: 12) {
            tint(strokePath([(x, 0.5), (x * 0.69, 67)], 0.25), holyTone(0.59, 0.68, 0.66, 0.20))
        }
        for radius in [CGFloat(29), 41, 53, 66, 78] {
            let ring = Path(ellipseIn: CGRect(x: point(-radius, 34).x, y: point(0, 34 + radius * 0.36).y,
                                             width: radius * 2, height: radius * 0.72))
            tint(ring.strokedPath(StrokeStyle(lineWidth: radius == 78 ? 0.8 : 0.30)), holyTone(0.61, 0.69, 0.65, 0.30))
        }
        // Tiny, abstract pilgrims follow the counter-clockwise circulation.
        // Grouped paths keep the animation economical and freeze at time zero
        // when Reduce Motion is enabled by the scene renderer.
        var white = Path(), dark = Path(), shadows = Path()
        for index in 0..<270 {
            let row = index % 5
            let angle = Double(index) * 2.399963 + time * 0.018
            let radius = CGFloat(30 + row * 10) + CGFloat(Self.noise(index, 49)) * 6
            let x = CGFloat(cos(angle)) * radius
            let y = 34 + CGFloat(sin(angle)) * radius * 0.36
            let size = 0.33 + CGFloat(Self.noise(index, 22)) * 0.20
            shadows.addPath(discPath(x + 0.2, y - 0.4, size * 1.1))
            let mark = discPath(x, y, size)
            if index % 4 == 0 { dark.addPath(mark) } else { white.addPath(mark) }
        }
        tint(shadows, holyTone(0.31, 0.38, 0.37, 0.22))
        tint(dark, holyTone(0.27, 0.34, 0.33, 0.8))
        tint(white, holyTone(1, 1, 0.98))
        // Receding side galleries: a visible roof plane and progressively
        // smaller openings establish the height of the viewpoint.
        for side in [-1.0, 1.0] as [CGFloat] {
            tint(polygon([(side * 99, 1), (side * 82, 68), (side * 82, 84), (side * 99, 34)]), holyTone(0.84, 0.77, 0.61))
            tint(polygon([(side * 99, 34), (side * 82, 84), (side * 88, 88), (side * 99, 49)]), holyStone)
            tint(strokePath([(side * 99, 34), (side * 82, 84)], 1.2), holyGold)
            for bay in 0..<8 {
                let t = (CGFloat(bay) + 0.5) / 8
                let x = side * (98 - t * 15)
                let y = 7 + t * 60
                tint(archPath(x, 3.6 - t, 16 - t * 7, from: y), holyTone(0.18, 0.31, 0.31))
                disc(x, y + 7 - t * 3, 0.5, .light)
                tint(domePath(side * (98 - t * 10), 5 - t, on: 47 + t * 39, rise: 2), holyStone)
            }
        }
        // The low curved wall of Hijr Ismail, seen beside the Kaaba.
        let hijr = strokePath([(-19, 45), (-27, 47), (-33, 44), (-34, 40), (-29, 36), (-23, 36)], 2, smooth: true)
        tint(hijr, holyTone(0.69, 0.70, 0.62))
        tint(strokePath([(-19, 46), (-27, 48), (-33, 45), (-34, 41), (-29, 37), (-23, 37)], 1.3, smooth: true), holyTone(1, 0.97, 0.85))
        // Three visible planes of the kiswah: the roof establishes the bird's
        // eye angle, with the gold belt following both receding faces.
        let roof = polygon([(-19, 52), (-3, 61), (19, 52), (3, 42)])
        let left = polygon([(-19, 52), (3, 42), (3, 19), (-19, 29)])
        let right = polygon([(3, 42), (19, 52), (19, 29), (3, 19)])
        for face in [roof, left, right] { occludeCourtyardLights(behind: face) }
        tint(polygon([(-17, 28), (5, 17), (30, 22), (13, 34)]), holyTone(0.37, 0.43, 0.41, 0.26))
        tint(left, holyTone(0.055, 0.06, 0.065))
        tint(right, holyTone(0.11, 0.12, 0.12))
        wash(roof, top: holyTone(0.22, 0.23, 0.23), bottom: holyTone(0.095, 0.10, 0.105))
        tint(roof.strokedPath(StrokeStyle(lineWidth: 0.4)), holyTone(0.31, 0.32, 0.29))
        tint(polygon([(-19, 47), (3, 37), (3, 34), (-19, 44)]), holyGold)
        tint(polygon([(3, 37), (19, 47), (19, 44), (3, 34)]), holyTone(0.89, 0.72, 0.37))
        tint(polygon([(9, 25), (14, 28.1), (14, 38), (9, 34.9)]), holyTone(0.92, 0.73, 0.32))
        for x in [-15.0, -10, -5, 0] as [CGFloat] {
            let y = 38 - (x + 15) * 10 / 22
            tint(polygon([(x, y + 1), (x + 0.7, y), (x, y - 1), (x - 0.7, y)]), holyGold)
        }
        // Fine embroidery follows the perspective of the belt and doorway.
        for x in stride(from: CGFloat(-17), through: 1, by: 2.0) {
            let y = 45.5 - (x + 19) * 10 / 22
            tint(strokePath([(x - 0.45, y), (x, y + 0.5), (x + 0.45, y - 0.4)], 0.16), holyTone(0.98, 0.85, 0.49))
        }
        for y in [26.6, 30.0, 33.4] as [CGFloat] {
            tint(polygon([(9.7, y), (13.3, y + 2.2), (13.3, y + 4.1), (9.7, y + 1.9)])
                .strokedPath(StrokeStyle(lineWidth: 0.22)), holyTone(0.50, 0.36, 0.13))
        }
        // Maqam Ibrahim: a small gold-and-glass enclosure in the open plaza.
        tint(blockPath(30, 5, 5.5, from: 28), holyGold)
        tint(blockPath(30, 2.8, 4, from: 29), holyTone(0.35, 0.53, 0.48))
        tint(domePath(30, 6, on: 33.5, rise: 3), holyGold)
        disc(30, 36.8, 0.5, .light)
        holyMinaret(-91, height: 78)
        holyMinaret(91, height: 78)
        holyLantern(-78, height: 22)
        holyLantern(78, height: 22)
    }

    mutating func holyPlazaParasol(_ x: CGFloat, base: CGFloat, scale s: CGFloat) {
        let h = base + 16 * s
        tint(polygon([(x - 6 * s, base), (x + 8 * s, base), (x + 13 * s, base + 1.5 * s),
                      (x + 2 * s, base + 2.5 * s)]), holyTone(0.35, 0.46, 0.43, 0.18))
        wash(blockPath(x, 0.9 * s, 15 * s, from: base), top: holyStone, bottom: holyTone(0.66, 0.64, 0.50))
        tint(blockPath(x, 2.5 * s, 0.7 * s, from: base), holyGold)
        let canopy = polygon([(x - 12 * s, h), (x - 5 * s, h + 2 * s), (x, h + 5 * s),
                              (x + 5 * s, h + 2 * s), (x + 12 * s, h), (x + 6 * s, h - 1.2 * s),
                              (x, h), (x - 6 * s, h - 1.2 * s)])
        wash(canopy, top: holyTone(1, 0.96, 0.83), bottom: holyTone(0.80, 0.72, 0.53))
        for dx in [-11.0, -5, 5, 11] as [CGFloat] {
            tint(strokePath([(x, h + 4.5 * s), (x + dx * s * 0.55, h + 1.2 * s), (x + dx * s, h)], 0.25, smooth: true), holyGold)
        }
        disc(x, h - 2 * s, 0.4, .light)
    }

    mutating func holyCourtyard() {
        wash(polygon([(-99, 0), (99, 0), (84, 18), (-84, 18)]), top: holyTone(0.76, 0.83, 0.81), bottom: holyTone(0.96, 0.96, 0.89))
        // Perspective joints widen toward the viewer; a dark inlaid border
        // and a restrained rosette give the marble a sense of scale.
        for y in [1.0, 4, 8, 12, 15, 17] as [CGFloat] {
            let edge = 99 - y * 15 / 18
            tint(blockPath(0, edge * 2, 0.3, from: y), holyTone(0.48, 0.64, 0.65, 0.50))
        }
        for x in stride(from: CGFloat(-90), through: 90, by: 15) {
            tint(strokePath([(x, 0.4), (x * 0.64, 17.6)], 0.3), holyTone(0.48, 0.64, 0.65, 0.50))
        }
        for side in [-1.0, 1.0] as [CGFloat] {
            tint(polygon([(side * 90, 0.3), (side * 93, 0.3), (side * 79, 17.5), (side * 77, 17.5)]), holyTone(0.28, 0.43, 0.44))
            let x = side * 55
            tint(polygon([(x - 7, 5), (x - 2, 6.2), (x, 8.5), (x + 2, 6.2), (x + 7, 5),
                          (x + 2, 3.8), (x, 1.5), (x - 2, 3.8)]), holyTone(0.57, 0.66, 0.61, 0.7))
        }
    }

    mutating func holyPortal(_ x: CGFloat, base: CGFloat) {
        tint(blockPath(x, 28, 29, from: base), holyStone)
        tint(blockPath(x, 31, 1.6, from: base + 29), holyGold)
        for width in [23.0, 19.0] as [CGFloat] {
            tint(archPath(x, width, 25, from: base).strokedPath(StrokeStyle(lineWidth: 0.7)), holyGold)
        }
        tint(archPath(x, 15, 21, from: base), holyTone(0.12, 0.30, 0.27))
        tint(archPath(x, 11, 17, from: base), holyTone(0.69, 0.52, 0.23))
        for dx in [-3.0, 3.0] as [CGFloat] {
            for y in [3.0, 8.0, 13.0] as [CGFloat] {
                tint(blockPath(x + dx, 4, 3.5, from: base + y).strokedPath(StrokeStyle(lineWidth: 0.35)), holyStone)
            }
        }
        tint(blockPath(x, 0.5, 16, from: base), holyGold)
        glow(x, base + 12, 14, Self.lampLight, 0.16, nightOnly: true)
    }

    mutating func holyArcade(_ x: CGFloat, width: CGFloat, base: CGFloat, height: CGFloat, bays: Int) {
        block(x, width, height, from: base)
        wash(blockPath(x, width, height, from: base), top: holyTone(0.99, 0.94, 0.81), bottom: holyTone(0.79, 0.76, 0.62))
        tint(blockPath(x, width + 1, 1.4, from: base + height), holyGold)
        tint(blockPath(x, width, 1, from: base), holyTone(0.60, 0.69, 0.68))
        tint(blockPath(x, width, 1.2, from: base + height - 2), holyTone(0.70, 0.68, 0.55))
        tint(blockPath(x, width, 0.5, from: base + height - 3.2), holyGold)
        let step = width / CGFloat(bays)
        for i in 0..<bays {
            let cx = x - width / 2 + step * (CGFloat(i) + 0.5)
            let opening = archPath(cx, step * 0.62, height * 0.74, from: base, pointed: true)
            tint(opening, holyTone(0.20, 0.34, 0.35))
            tint(opening.strokedPath(StrokeStyle(lineWidth: 0.65)), holyGold)
            tint(archPath(cx + 0.65, step * 0.43, height * 0.65, from: base), holyTone(0.11, 0.22, 0.24))
            tint(blockPath(cx - step * 0.38, 0.7, height * 0.62, from: base), holyTone(1, 0.96, 0.83))
            tint(blockPath(cx - step * 0.38, 2, 0.9, from: base + height * 0.59), holyGold)
            tint(blockPath(cx, 1.5, 1.2, from: base + height * 0.80), holyGold)
            tint(archPath(cx, step * 0.38, height * 0.60, from: base), Self.lampLight.opacity(0.24), nightOnly: true)
            disc(cx, base + height * 0.48, 0.65, .light)
        }
    }

    mutating func holyMinaret(_ x: CGFloat, height h: CGFloat) {
        // Colour the same stepped outline as the shared architectural piece;
        // applying its tints last preserves balcony and shaft details.
        let first = solids.count
        tallMinaret(x, h, width: 5.6)
        for outline in solids.dropFirst(first) { tint(outline, holyStone) }
        tint(blockPath(x + 1.8, 1.4, h * 0.29), holyTone(0.65, 0.65, 0.54))
        tint(blockPath(x + 1.3, 1, h * 0.26, from: h * 0.31), holyTone(0.65, 0.65, 0.54))
        for level in [0.30, 0.58, 0.78, 0.875] {
            tint(blockPath(x, level < 0.4 ? 8.4 : 6.2, 1.2, from: h * level), holyGold)
        }
        tint(blockPath(x - 1, 0.7, h * 0.20, from: h * 0.06), holyTone(0.62, 0.72, 0.72))
        for level in [0.34, 0.62, 0.82] {
            tint(blockPath(x, 1.2, 3, from: h * level), holyTone(0.16, 0.41, 0.35))
            tint(blockPath(x, 1.2, 3, from: h * level), Self.lampLight.opacity(0.9), nightOnly: true)
        }
    }

    mutating func holyParasol(_ x: CGFloat, height h: CGFloat) {
        tint(blockPath(x, 2, h - 7, from: 3), holyStone)
        tint(blockPath(x, 5, 1.4, from: 3), holyGold)
        let canopy = polygon([(x - 20, h - 6), (x - 12, h - 2), (x - 3, h), (x, h + 3),
                              (x + 3, h), (x + 12, h - 2), (x + 20, h - 6), (x + 12, h - 8),
                              (x, h - 6), (x - 12, h - 8)])
        tint(canopy, holyTone(0.96, 0.89, 0.72))
        for dx in [-18.0, -9, 9, 18] as [CGFloat] {
            tint(strokePath([(x, h + 1), (x + dx * 0.6, h - 3), (x + dx, h - 6)], 0.45, smooth: true), holyGold)
        }
        tint(strokePath([(x - 18, h - 6), (x, h - 5), (x + 18, h - 6)], 0.7, smooth: true), holyGold)
        disc(x, h - 10, 0.9, .light)
    }

    mutating func holyLantern(_ x: CGFloat, height h: CGFloat) {
        tint(blockPath(x, 1, h, from: 2), holyGold)
        tint(blockPath(x, 3.5, 4.0, from: h - 3), holyStone)
        disc(x, h - 1, 1, .light)
        let breath = 0.15 + 0.035 * sin(time * 0.7 + Double(x))
        glow(x, h - 1, 7, Self.lampLight, breath, nightOnly: true)
        tint(blockPath(x, 2.6, 0.6, from: 2), Self.lampLight.opacity(0.3), nightOnly: true)
    }
}
