import SwiftUI
import SceneWeaver

/// A scene for each group of duas, and for each dua: a place or an object
/// that belongs to it, standing under Home's sky like the surah scenes.
enum DuaScenes {
    /// The scene for a group of duas, by its id (`morning`, `travel`, `sleep`, ...).
    static func scene(forCategory id: String) -> Cityscape { byCategory[id] ?? Cityscape.oasis }

    /// The scene for one dua: its own where it has one, otherwise its group's.
    static func scene(forDua id: Int, category: String) -> Cityscape { byDua[id] ?? scene(forCategory: category) }

    /// A dua scene: a surah scene in every way, its id marked as a dua's.
    static func make(_ id: String, backdrop: CityBackdrop = .hills, ownMoon: Bool = false, rtlPlacement: SceneRTLPlacement = .leftMargin,
                     _ draw: @escaping (inout SkylinePen) -> Void) -> Cityscape {
        SurahScenes.make("dua-" + id, backdrop: backdrop, ownMoon: ownMoon, rtlPlacement: rtlPlacement, draw)
    }

    static let byCategory: [String: Cityscape] = [
        // The oasis mosque, light growing on the horizon, mist in the low ground.
        "morning": make("morning") { p in
            Cityscape.oasis.draw(&p)
            p.horizonLight(-176, spread: 190)
            p.mist(from: p.leftEdge, to: 100)
        },
        // The same oasis, lamps being lit along the way to its wall.
        "evening": make("evening") { p in
            Cityscape.oasis.draw(&p)
            // Keep the whole approach visible on narrow phones as well.
            p.lampLine(from: max(-250, p.leftEdge + 12), to: -160, count: 4)
            p.hangingLantern(-20, from: 13, drop: 0.5, scale: 0.6); p.hangingLantern(24, from: 13, drop: 0.5, scale: 0.6)
            p.stars([(-150, 150), (-96, 172), (-40, 130), (86, 150)], size: 1.3)
        },
        // A quiet house, one window lit, a crescent and stars over it.
        "sleep": make("sleep", ownMoon: true) { p in
            p.at(110)
            home(&p, 4, 1.4)
            p.tree(-74, 56); p.palm(74, 70)
            p.crescent(-34, 150, 11)
            p.stars([(-150, 158), (-104, 182), (-70, 128), (10, 178), (44, 140), (84, 168)], size: 1.4)
            p.mist(from: p.leftEdge, to: 110)
        },
        // A prayer niche with its lamp in a still valley, light coming down through the night.
        "night_prayer": make("night-prayer") { p in
            p.at(110)
            p.peak(-150, 150, 62); p.peak(84, 96, 74, lean: -3)
            p.prayerNiche(-12, scale: 1.75)
            p.mist(from: p.leftEdge, to: 110)
            p.descendingLight(over: -12, spread: 150)
            p.stars([(-160, 150), (-110, 176), (-70, 140), (60, 172), (92, 138)], size: 1.3)
        },
        // The niche and the mat, a courtyard wall running off to either side.
        "prayer": make("prayer") { p in
            p.at(110)
            p.block(-10, 250, 13)
            for x in stride(from: CGFloat(-130), through: 100, by: 10) { p.block(x, 4, 2.6, from: 13) }
            p.prayerNiche(6, scale: 1.9)
            p.palm(-74, 58); p.palm(-100, 42); p.palm(88, 46)
        },
        // The mosque's arcade, a lantern hung in its arches, the dome and minaret behind.
        "after_prayer": make("after-prayer") { p in
            p.at(110)
            hall(&p, -28, bays: 7, bay: 20, height: 44)
            p.dome(-28, 52, on: 45.8, rise: 28); p.finial(-28, from: 73, height: 10, gilt: true)
            minaret(&p, 66, 118)
            p.palm(-124, 50)
        },
        // The mosque with its gate open and the road running up to it.
        "masjid": make("masjid") { p in
            p.at(110)
            p.road(to: -104, from: -150, width: 34)
            p.mosque(26, scale: 1.6)
            p.block(-58, 44, 17); p.block(-152, 40, 17)
            p.gate(-104, 58)
            p.palm(-176, 44); p.palm(90, 40)
        },
        // A spring and a well among palms.
        "wudu": make("wudu") { p in
            p.at(110)
            p.palm(-150, 62); p.palm(86, 70); p.palm(2, 50)
            lampPost(&p, -118, 54, arm: 9)
            p.spring(-52, scale: 3.0)
            p.well(46, scale: 2.5)
            p.flowers(from: -106, to: -4)
        },
        // Open pages on their stand, a lamp hung beside them.
        "quran_recitation": make("quran-recitation") { p in
            p.at(110)
            p.pages(4, scale: 2.4)
            lampPost(&p, 84, 78, arm: -12)
            p.palm(-96, 56)
            p.stars([(-150, 150), (-100, 176), (-50, 150), (40, 180)], size: 1.3)
        },
        // The pen standing in its inkwell beside a sheet, a lamp to write by.
        "knowledge": make("knowledge") { p in
            p.at(110)
            p.penAndInkwell(4, scale: 1.55)
            lampPost(&p, -72, 70, arm: 12)
            p.stars([(-150, 150), (-104, 178), (-50, 160), (60, 184), (90, 150)], size: 1.3)
            p.shootingStars(over: -60)
        },
        // A straight road running towards light on the horizon.
        "guidance": make("guidance") { p in
            p.at(110)
            p.peak(max(-206, 185 - p.width), 150, 46); p.peak(66, 120, 62, lean: 5)
            p.road(to: -40, from: -96, width: 40)
            p.horizonLight(-40, spread: 220)
            p.palm(-96, 40); p.palm(6, 50)
            p.stars([(-150, 150), (-90, 176), (-30, 150), (50, 176)], size: 1.3)
        },
        // A storm drawing off, the sun after it, the land turning green.
        "forgiveness": make("forgiveness") { p in
            p.at(110)
            p.greenField(from: p.leftEdge, to: 110)
            p.stormCloud(44, 156, 140, lightning: false)
            p.sun(-64, 150, 16)
            p.bareTree(72, 52)
            p.house(-130, 30, 18)
            p.tree(-26, 68); p.tree(-84, 40)
            p.flowers(from: -150, to: 20)
            p.rain(from: 0, to: 150, height: 152)
        },
        // Ripe grain, vines heavy on their trellis, a fig tree: a garden.
        "gratitude": make("gratitude") { p in
            p.at(110)
            p.house(-152, 30, 18)
            p.hearthSmoke(-158, 20)
            p.fig(42, 70)
            p.vines(-64, bays: 3)
            p.palm(-112, 54)
            p.grain(from: p.leftEdge, to: -112)
            p.flowers(from: -20, to: 100)
        },
        // A ship in heavy waves under a storm, light on the horizon.
        "distress": make("distress", backdrop: .open, rtlPlacement: .preserve) { p in
            p.at(p.width / 2)
            p.horizonLight(-120, spread: 210)
            p.waves(from: -p.width / 2, to: p.width / 2, height: 12)
            p.at(110)
            p.stormCloud(0, 152, 170)
            p.ship(0, scale: 1.3)
        },
        // A bare tree on a quiet slope, mist lying under it.
        "grief": make("grief") { p in
            p.at(110)
            p.hills(seed: 4, height: 30)
            p.bareTree(22, 96)
            p.house(-128, 20, 12)
            p.mist(from: p.leftEdge, to: 110, at: 10)
            p.stars([(-150, 150), (-90, 172), (-40, 140), (70, 170)], size: 1.3)
        },
        // A house under an olive tree, a spring rising beside it.
        "illness": make("illness") { p in
            p.at(110)
            p.olive(40, 96)
            home(&p, -52, 1.1)
            p.spring(-136, scale: 2.2)
        },
        // A stronghold's wall and towers, lamps burning at its gate.
        "protection": make("protection") { p in
            p.at(110)
            p.fortress(0, 150, 54)
            p.lampLine(from: -24, to: 14, count: 2)
            p.palm(-108, 52); p.palm(-132, 38)
            p.stars([(-150, 150), (-90, 176), (-30, 150), (40, 178), (90, 150)], size: 1.3)
        },
        // A house with smoke rising from its hearth, a palm and a well beside it.
        "home": make("home") { p in
            p.at(110)
            home(&p, -4, 1.45)
            p.hearthSmoke(22, 54)
            p.palm(-74, 74); p.tree(-118, 42)
            p.well(76, scale: 1.9)
        },
        // A great tree sheltering a house.
        "parents": make("parents") { p in
            p.at(110)
            p.greatTree(14, 106)
            home(&p, -72, 0.8)
            p.hearthSmoke(-60, 31)
            p.flowers(from: -40, to: 90)
        },
        // Young trees and flowers by a home.
        "children": make("children") { p in
            p.at(110)
            home(&p, 46, 1.15)
            p.tree(-32, 36); p.tree(-68, 26); p.tree(-104, 40)
            p.flowers(from: -136, to: 0)
            p.hearthSmoke(66, 43)
        },
        // A home among palms, lanterns strung to it and banners out.
        "marriage": make("marriage") { p in
            p.at(110)
            home(&p, 10, 1.25)
            p.palm(-66, 78); p.palm(80, 70); p.palm(-96, 52)
            lanternString(&p, from: (-64, 62), to: (-30, 46), count: 2, scale: 0.8)
            p.banner(-124, 46, p.shade(0.18, 0.50, 0.38)); p.banner(-150, 36, p.shade(0.86, 0.84, 0.78))
        },
        // A table spread before a house, steam rising from the dishes.
        "food": make("food") { p in
            p.at(110)
            p.table(-22, scale: 2.4)
            home(&p, 72, 0.8)
            p.palm(-106, 60)
            p.stars([(-150, 150), (-90, 176), (40, 170)], size: 1.3)
        },
        // Market stalls and the scales, the town behind them.
        "business": make("business") { p in
            p.at(110)
            p.town(-156, houses: 4, scale: 0.85)
            p.scales(48, 92)
            p.market(-64, stalls: 3)
            p.sceneTraveler(5, scale: 0.9)
        },
        // A road through the dunes, tents pitched beside it, a campfire.
        "travel": make("travel") { p in
            p.at(p.width / 2)
            p.dunes([(-150, 90, 18), (0, 120, 20), (170, 80, 12)])
            p.road(to: -40, from: -110)
            p.driftingSand(from: -p.width / 2, to: p.width / 2)
            p.at(110)
            p.tent(4, 64, 42); p.tent(54, 40, 26)
            p.campfire(-46, 0, scale: 1.2)
            p.palm(88, 66)
            p.desertCamel(-144, scale: 0.85)
            p.sceneTraveler(-112, scale: 0.9)
        },
        // The Kaaba among Makkah's mountains, the tents of Mina beside it.
        "hajj": make("hajj") { p in
            p.at(110)
            p.peak(-150, 170, 56); p.peak(88, 110, 84, lean: 4)
            p.kaaba(-4, 1.75)
            p.tentCamp(-112, count: 9)
            p.mist(from: p.leftEdge, to: 110)
            p.stars([(-150, 150), (-60, 172), (20, 150)], size: 1.3)
        },
        // A storm cloud, rain and wind over a house and its trees.
        "weather": make("weather") { p in
            p.at(110)
            p.stormCloud(4, 150, 190)
            p.windStreaks(from: p.leftEdge, to: 110, at: 96)
            home(&p, 14, 1.0)
            p.tree(78, 58); p.bareTree(-64, 50)
            p.rain(from: p.leftEdge, to: 140)
        },
        // A still night in the open desert under the great figures of the stars.
        "dhikr": make("dhikr", backdrop: .open) { p in
            p.at(p.width / 2)
            p.dunes([(-150, 110, 20), (40, 130, 26), (190, 90, 16)])
            p.at(110)
            p.palm(60, 78); p.palm(84, 56); p.palm(34, 50)
            p.tent(-34, 46, 30)
            p.constellations(over: -50, height: 182)
            p.mist(from: p.leftEdge, to: 110)
        }
    ]
}

// MARK: What the dua scenes share

extension DuaScenes {
    /// The oasis mosque of the Duas tab at any size: its hall of arches, the
    /// green dome and the minaret. `closed` fills the arches in, for when
    /// something stands in front of them.
    static func oasisMosque(_ p: inout SkylinePen, _ x: CGFloat, _ s: CGFloat = 1, closed: Bool = false) {
        p.block(x, 96 * s, 22 * s)
        for step in stride(from: CGFloat(-36), through: 36, by: 14.4) {
            if closed { p.tint(p.archPath(x + step * s, 8 * s, 14 * s), Color.black.opacity(0.34)) } else { p.arch(x + step * s, 8 * s, 14 * s, pointed: true) }
            p.disc(x + step * s, 9 * s, 1.3 * s, .light)
        }
        p.block(x, 102 * s, 2.2 * s, from: 22 * s)
        p.block(x - 8 * s, 34 * s, 8 * s, from: 24 * s)
        p.dome(x - 8 * s, 32 * s, on: 32 * s, rise: 22 * s)
        p.finial(x - 8 * s, from: 53 * s, height: 10 * s)
        p.tint(p.domePath(x - 8 * s, 32 * s, on: 32 * s, rise: 22 * s), Color(red: 0.14, green: 0.42, blue: 0.40))
        p.detail(p.domePath(x - 11 * s, 16 * s, on: 32 * s, rise: 15 * s), strength: 0.7)
        p.dome(x - 38 * s, 13 * s, on: 24 * s, rise: 7 * s)
        p.dome(x + 22 * s, 13 * s, on: 24 * s, rise: 7 * s)
        p.detail(p.blockPath(x, 92 * s, 0.8 * s, from: 19 * s), strength: 0.8)
        p.minaret(x + 46 * s, 92 * s)
    }

    /// A family house: flat-roofed, a small dome over one room, a tall window
    /// lit after dark. `open` stands its door open with the lamp-light in it.
    static func home(_ p: inout SkylinePen, _ x: CGFloat, _ s: CGFloat = 1, open: Bool = false) {
        let w = 64 * s, h = 36 * s
        p.house(x, w, h)
        p.dome(x - 15 * s, 22 * s, on: h + 1.4, rise: 9 * s)
        p.tint(p.archPath(x, 10 * s, 19 * s, pointed: false), Color.black.opacity(0.40))
        p.window(x + w * 0.27, 8 * s, 13 * s, from: 12 * s, pointed: false)
        if open {
            p.tint(p.archPath(x, 7.6 * s, 17 * s, pointed: false), SkylinePen.lampLight.opacity(0.30 + 0.5 * p.night))
            p.add(p.archPath(x, 7.6 * s, 17 * s, pointed: false), .light)
            p.glow(x, 9 * s, 20 * s, SkylinePen.lampLight, 0.22, nightOnly: true)
        }
    }

    /// A lantern hung from a post by a curved arm; `arm` is how far, and to which side, it reaches.
    static func lampPost(_ p: inout SkylinePen, _ x: CGFloat, _ h: CGFloat, arm: CGFloat = 10, scale s: CGFloat = 1) {
        p.shape([(x - 2.2, 0), (x + 2.2, 0), (x + 0.9, 3), (x + 0.8, h), (x - 0.8, h), (x - 0.9, 3)])
        p.line([(x, h - 1.5), (x + arm * 0.35, h + 4), (x + arm, h + 3)], 1.2, smooth: true)
        p.hangingLantern(x + arm, from: h + 3, drop: 12 * s, scale: s)
    }

    /// Lanterns hung along a line slung between two points.
    static func lanternString(_ p: inout SkylinePen, from a: (CGFloat, CGFloat), to b: (CGFloat, CGFloat), count: Int, scale s: CGFloat = 0.7) {
        let sag = abs(b.0 - a.0) * 0.10
        p.line([a, ((a.0 + b.0) / 2, (a.1 + b.1) / 2 - sag), b], 0.6, smooth: true)
        for index in 0..<count {
            let t = (CGFloat(index) + 1) / CGFloat(count + 1)
            let y = a.1 + (b.1 - a.1) * t - sag * 4 * t * (1 - t) * 0.9
            p.hangingLantern(a.0 + (b.0 - a.0) * t, from: y, drop: 9 * s, scale: s)
        }
    }

    /// The mosque's arcade, with a lantern hung in every other arch.
    static func hall(_ p: inout SkylinePen, _ x: CGFloat, bays: Int, bay: CGFloat, height h: CGFloat) {
        p.arcade(x, bays: bays, bay: bay, height: h)
        let left = x - (CGFloat(bays) * bay + 4) / 2 + 2, size = (bay - 5) / 15
        for index in stride(from: 0, to: bays, by: 2) {
            p.hangingLantern(left + bay * (CGFloat(index) + 0.5), from: h - 6.5, drop: 10 * size, scale: size)
        }
    }

    /// A minaret on a square foot.
    static func minaret(_ p: inout SkylinePen, _ x: CGFloat, _ h: CGFloat) {
        p.block(x, 12, 10)
        p.detail(p.blockPath(x, 11, 0.7, from: 8.4), strength: 0.7)
        p.tallMinaret(x, h, width: 7.4)
    }

    /// Washed cloths drying on a line between two posts, lifting in the wind.
    static func washing(_ p: inout SkylinePen, from left: CGFloat, to right: CGFloat, height h: CGFloat) {
        for x in [left, right] { p.shape([(x - 1.6, 0), (x + 1.6, 0), (x + 0.7, h + 2), (x - 0.7, h + 2)]) }
        let span = right - left
        func line(_ t: CGFloat) -> CGFloat { h - 20 * t * (1 - t) }
        var cord: [(CGFloat, CGFloat)] = []
        for step in 0...8 { let t = CGFloat(step) / 8; cord.append((left + span * t, line(t))) }
        p.line(cord, 0.6, smooth: true)
        let cloths: [(CGFloat, CGFloat, CGFloat, (Double, Double, Double))] = [
            (0.16, 0.20, 26, (0.90, 0.88, 0.80)), (0.42, 0.16, 34, (0.24, 0.36, 0.56)), (0.64, 0.14, 22, (0.78, 0.56, 0.30)), (0.84, 0.12, 30, (0.86, 0.84, 0.78))
        ]
        for (index, cloth) in cloths.enumerated() {
            let a = cloth.0 - cloth.1 / 2, b = cloth.0 + cloth.1 / 2
            let sway = CGFloat(sin(p.time * 1.3 + Double(index) * 1.7)) * 2.4
            let top: [(CGFloat, CGFloat)] = [(left + span * a, line(a) + 0.4), (left + span * b, line(b) + 0.4)]
            let foot: [(CGFloat, CGFloat)] = [(left + span * b + sway, line(b) - cloth.2), (left + span * a + sway * 1.2, line(a) - cloth.2 + 1.2)]
            p.tint(p.polygon(top + foot), p.shade(cloth.3.0, cloth.3.1, cloth.3.2, 0.92))
            p.tint(p.polygon([top[0], (top[0].0 + span * cloth.1 * 0.3, top[0].1), (foot[1].0 + span * cloth.1 * 0.3, foot[1].1), foot[1]]), Color.black.opacity(0.10))
        }
    }
}
