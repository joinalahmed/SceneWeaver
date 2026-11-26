import SwiftUI
import SceneWeaver

/// The surahs by portion. A surah under 40 ayahs has one scene. One of 40 to
/// 100 has two or three, and a longer one four to six: each scene begins at an
/// ayah and holds until the next begins, and the Quran tab shows the scene of
/// the portion where reading stopped. The scenes drawn surah by surah come
/// first, each at the ayah it is taken from; the further ones are drawn in
/// `further`, each from a place, an object or a sign in its own portion.
/// docs/surah-scene-portions.md gives the ayahs behind every one.
extension SurahScenes {
    /// For each surah with more than one scene: the ayah each begins at, and the scene's id.
    static let plan: [Int: [(from: Int, scene: String)]] = [
        2: [(1, "p02-fire-and-storm"), (40, "p02-twelve-springs"), (124, "p02-qibla"), (183, "a02-oasis-crescent"),
            (246, "p02-river"), (261, "a02-garden-on-height")],
        3: [(1, "p03-tilled-land"), (33, "a03-mihrab"), (96, "p03-first-house"), (121, "a03-uhud"), (190, "p03-night-and-day")],
        4: [(1, "a04-homes"), (58, "p04-justice"), (71, "p04-towers"), (97, "p04-emigrants-road"), (153, "p04-mount-and-gate")],
        5: [(1, "p05-washing"), (20, "p05-holy-land-gate"), (44, "p05-guidance-and-light"), (94, "p05-sacred-house"), (109, "a05-table")],
        6: [(1, "p06-darkness-and-light"), (59, "p06-falling-leaf"), (74, "a06-pasture-signs"), (95, "p06-clustered-dates"),
            (151, "p06-straight-path")],
        7: [(1, "p07-garden-tree"), (44, "a07-heights"), (59, "p07-towns-left-empty"), (103, "p07-pharaoh-works"), (142, "p07-forty-nights")],
        8: [(1, "a08-badr"), (41, "a08-two-banks")],
        9: [(1, "p09-sacred-mosque"), (38, "p09-cave"), (42, "a09-tabuk-road"), (107, "a09-quba")],
        10: [(1, "p10-sun-and-moon"), (11, "a10-ship"), (24, "p10-adorned-earth"), (75, "p10-houses-in-egypt")],
        11: [(1, "p11-ark-building"), (40, "a11-judi"), (50, "p11-empty-homes"), (69, "p11-stones-at-dawn"), (84, "p11-madyan-measure")],
        12: [(1, "yusuf-well"), (21, "yusuf-egypt"), (58, "p12-caravan-road"), (99, "p12-dream-fulfilled")],
        13: [(1, "a13-tracts"), (12, "a13-thunder")],
        14: [(1, "p14-ashes-in-wind"), (24, "a14-valley-tree")],
        15: [(1, "p15-sky-and-winds"), (51, "p15-night-road"), (80, "a15-hijr")],
        16: [(1, "p16-waymarks-and-stars"), (65, "a16-hives"), (80, "p16-homes-and-tents"), (112, "p16-secure-town")],
        17: [(1, "a17-aqsa"), (22, "p17-straight-balance"), (66, "p17-ship-in-gale"), (78, "p17-dawn-prayer"), (90, "p17-things-demanded")],
        18: [(1, "kahf-cave"), (32, "kahf-gardens"), (60, "p18-ship-and-wall"), (83, "p18-barrier")],
        19: [(1, "p19-mihrab"), (16, "a19-palm-stream"), (59, "p19-gardens-of-eden")],
        20: [(1, "a20-tuwa-fire"), (56, "p20-festival-day"), (77, "p20-dry-path"), (99, "p20-level-plain"), (115, "p20-garden")],
        21: [(1, "a21-lamps"), (30, "p21-orbits"), (51, "p21-fire-made-cool"), (78, "p21-mountains-and-wind")],
        22: [(1, "a22-kaaba-mina"), (42, "a22-abandoned-well")],
        23: [(1, "a23-olive-sinai"), (23, "p23-blessed-landing"), (45, "p23-high-ground"), (78, "p23-seven-heavens")],
        24: [(1, "p24-doors"), (35, "nur-niche"), (39, "p24-dark-sea")],
        25: [(1, "p25-markets"), (45, "a25-two-seas")],
        26: [(1, "a26-parted-sea"), (69, "p26-garden-brought-near"), (105, "p26-laden-ark"), (123, "a26-heights"),
             (141, "p26-thamud-gardens"), (176, "p26-thicket-balance")],
        27: [(1, "a27-valley-ants"), (20, "a27-glass-court"), (59, "p27-mountains-like-clouds")],
        28: [(1, "p28-river-city"), (22, "a28-madyan-well"), (76, "p28-qarun")],
        29: [(1, "p29-dwellings"), (41, "a29-web")],
        30: [(1, "b30-rum-fortress"), (17, "p30-winds-and-ships")],
        33: [(1, "b33-ahzab-wind"), (10, "b33-ahzab-trench"), (28, "p33-prophets-houses")],
        34: [(1, "b34-saba-dam"), (18, "b34-saba-road")],
        35: [(1, "p35-two-waters"), (27, "b35-fatir-streaks")],
        36: [(1, "b36-yasin-moon"), (33, "b36-yasin-revived")],
        37: [(1, "b37-saffat-stars"), (40, "p37-cup-and-spring"), (75, "p37-ruins-passed"), (139, "p37-gourd-shore")],
        38: [(1, "b38-sad-mountains"), (41, "b38-sad-spring")],
        39: [(1, "b39-zumar-springs"), (68, "p39-gates-opened")],
        40: [(1, "b40-ghafir-tower"), (56, "p40-night-for-rest")],
        41: [(1, "p41-lamps-of-heaven"), (37, "b41-fussilat-revived")],
        42: [(1, "p42-harvest"), (32, "b42-shura-ships")],
        43: [(1, "b43-zukhruf-gate"), (46, "p43-rivers-of-egypt")],
        44: [(1, "b44-dukhan-smoke"), (17, "b44-dukhan-left-behind")],
        50: [(1, "b50-qaf-palms"), (36, "p50-before-sunrise")],
        51: [(1, "b51-dhariyat-winds"), (15, "p51-gardens-at-dawn")],
        52: [(1, "tur-sinai"), (29, "p52-setting-stars")],
        53: [(1, "b53-najm-star"), (33, "p53-overturned-towns")],
        54: [(1, "b54-qamar-moon"), (18, "b54-qamar-wind")],
        55: [(1, "b55-rahman-balance"), (19, "b55-rahman-seas")],
        56: [(1, "p56-shade-and-water"), (57, "b56-waqia-signs")],
        68: [(1, "c68-qalam-pen"), (17, "c68-qalam-garden")],
        69: [(1, "c69-haqqa-ruins"), (19, "p69-lofty-garden")],
        70: [(1, "c70-maarij-stairway"), (36, "p70-east-and-west")],
        74: [(1, "c74-muddaththir-dawn"), (38, "p74-open-scrolls")],
        75: [(1, "c75-qiyama-sun-moon"), (16, "p75-recital")],
        77: [(1, "c77-mursalat-winds"), (29, "c77-mursalat-smoke")],
        78: [(1, "c78-naba-signs"), (31, "p78-gardens-and-vines")],
        79: [(1, "c79-naziat-tuwa"), (27, "p79-earth-spread")],
        80: [(1, "c80-abasa-pages"), (24, "c80-abasa-harvest")]
    ]

    /// Second scenes of surahs under 40 ayahs. Such a surah keeps one scene, its
    /// first; these stay drawn in the part files but are shown nowhere.
    static let unused: Set<String> = [
        "b31-luqman-ink", "b57-hadid-wall", "c59-hashr-mountain", "c61-saff-light", "c67-mulk-water", "c73-muzzammil-prayer",
        "c76-insan-table", "c86-tariq-rain", "d88-garden", "fajr-thamud", "d90-feeding", "d95-city", "d96-pen", "d98-gardens",
        "d102-rivalry", "d110-gate"
    ]

    /// The scenes drawn for further portions of the longer surahs.
    static let further: [Cityscape] = furtherLong + furtherMiddle
}

private extension SkylinePen {
    /// Draws pieces as they would stand this far from the right edge, then moves
    /// them about their foot: lifted by `rise` as onto a ledge, leaned by `lean`
    /// (a turn to the left), made larger or smaller by `scale`. `still` holds
    /// them motionless: a thing come to rest.
    mutating func set(_ fromRight: CGFloat, rise: CGFloat = 0, lean: Double = 0, scale: CGFloat = 1, still: Bool = false,
                      _ draw: (inout SkylinePen) -> Void) {
        // A lifted or tilted piece must use the same scene lighting as its
        // surroundings, including the Quran foreground and night colors.
        var part = SkylinePen(width: width, horizon: horizon, time: still ? 0 : time, night: night,
                              clockDate: clockDate, quranScene: quranScene)
        part.at(fromRight)
        draw(&part)
        let foot = CGPoint(x: width - fromRight, y: horizon)
        let move = CGAffineTransform(translationX: foot.x, y: foot.y - rise).rotated(by: -lean).scaledBy(x: scale, y: scale)
            .translatedBy(x: -foot.x, y: -foot.y)
        for path in part.solids { add(path.applying(move)) }
        for path in part.holes { add(path.applying(move), .hole) }
        for path in part.lights { add(path.applying(move), .light) }
        for item in part.tints { tint(item.path.applying(move), item.color, nightOnly: item.nightOnly) }
    }

    /// Something light carried off on the wind from a spot on the ground: puffs
    /// that climb, widen and thin as they go. `reach` is how far, and which way.
    mutating func plume(from x: CGFloat, _ y: CGFloat = 4, reach: CGFloat, rise: CGFloat = 30, _ tone: (Double, Double, Double), strength: Double = 0.17) {
        for index in 0..<8 {
            let part = CGFloat(index) / 7
            let drift = CGFloat(sin(time * 0.3 + Double(index) * 1.3)) * 3
            let puff = crownPath(x + reach * part + drift, y + rise * part, 8 + 20 * part, 4 + 9 * part, lobes: 6, depth: 0.24, seed: index + 3, flat: 0.4)
            tint(puff, shade(tone, strength - strength * 0.5 * Double(part)))
        }
    }

    /// A doorway hewn in a rock face, a stepped lintel cut over it: dark, or lit from within.
    mutating func hewnDoor(_ x: CGFloat, _ w: CGFloat, _ h: CGFloat, lit: Bool = false) {
        if lit { window(x, w, h, from: 0, pointed: false) } else { tint(archPath(x, w, h, pointed: false), Color.black.opacity(0.36)) }
        detail(blockPath(x, w + 8, 1.2, from: h + 3), strength: 0.9)
        detail(blockPath(x, w + 4, 1.2, from: h + 5.6), strength: 0.7)
    }
}

// MARK: Surahs over 100 ayahs

extension SurahScenes {
    static let furtherLong: [Cityscape] = [
        // Al-Baqara 1-39: a fire kindled that lights what is round it (2:17), and a cloudburst
        // from the sky with darkness, thunder and lightning in it (2:19-20).
        make("p02-fire-and-storm") { p in
            p.at(p.width / 2)
            p.hills(seed: 2, height: 18)
            // The fire and the cloudburst are two separate parables in the
            // passage. Set them apart so the animated rain does not fall on
            // the fire: the water drifts left as it falls, so leave a gap.
            p.stormCloud(p.width * 0.26, 146, min(150, p.width * 0.42))
            p.rain(from: p.width * 0.15, to: p.width / 2 + 16, height: 144)
            p.bareTree(p.width * 0.34, 70)
            p.tent(-p.width * 0.28, 48, 31)
            p.campfire(-p.width * 0.13, 0, scale: 1.8)
            p.palm(-p.width * 0.40, 48)
        },
        // Al-Baqara 40-123: the rock struck, and twelve springs gushing from it, each tribe
        // knowing its drinking place (2:60).
        make("p02-twelve-springs") { p in
            p.at(126)
            p.peak(-160, 150, 52, lean: -4)
            p.cliff(0, 84, 56)
            // Twelve small channels wind through earth, each keeping its own
            // source while the banks soften into the surrounding ground.
            p.tint(p.polygon([(p.leftEdge, 0), (p.rightEdge, 0), (p.rightEdge, -46), (p.leftEdge, -46)]),
                   p.shade(0.35, 0.30, 0.24, 0.52))
            for index in 0..<12 {
                let across = CGFloat(index) - 5.5, far = across * 6.6, near = across * 27
                func centre(_ t: CGFloat) -> CGFloat {
                    far + (near - far) * t + sin(t * .pi) * CGFloat(sin(Double(index) * 1.7)) * 3.5
                }
                func channel(_ extra: CGFloat) -> Path {
                    let samples = (0...10).map { CGFloat($0) / 10 }
                    let left = samples.map { t -> SkylinePen.Spot in
                        (centre(t) - (0.7 + 2.3 * t + extra * t), -46 * t)
                    }
                    let right = samples.reversed().map { t -> SkylinePen.Spot in
                        (centre(t) + (0.7 + 2.3 * t + extra * t), -46 * t)
                    }
                    return p.polygon(left + right)
                }
                p.tint(channel(2.5), p.shade(0.40, 0.39, 0.29, 0.35))
                p.tint(channel(0), p.shade(0.19, 0.43, 0.49, 0.78))
                let run = CGFloat((Double(index) * 0.37 + p.time * 0.16).truncatingRemainder(dividingBy: 1))
                let cx = centre(run), half = 0.7 + 2 * run
                p.tint(p.polygon([(cx - half, -46 * run), (cx, -46 * run + 0.5 + run), (cx + half, -46 * run), (cx, -46 * run - 0.5 - run)]),
                       Color.white.opacity(0.34 * sin(Double(run) * Double.pi) * (1 - 0.5 * p.night)))
            }
            p.tint(p.polygon([(-40, 0.6), (40, 0.6), (38, -1.6), (-38, -1.6)]), p.shade(0.30, 0.62, 0.74, 0.8))
            p.tent(-98, 30, 20); p.tent(-128, 22, 15); p.tent(86, 26, 17)
            p.palm(-66, 42)
            p.stars([(-150, 130), (-110, 156), (-70, 136), (-30, 166), (60, 150), (96, 128)], size: 1.3)
        },
        // Al-Baqara 124-182: the House whose foundations Ibrahim raised (2:125-127), and
        // Madinah's mosque turned to face it (2:144-150).
        make("p02-qibla") { p in
            p.at(96)
            p.peak(46, 130, 76, lean: 4); p.peak(-64, 110, 46)
            p.kaaba(-4, 1.9)
            p.lampLine(from: -146, to: -62, count: 4)
            // Keep the mosque and its palms on-screen on a narrow phone.
            p.at(min(310, p.width - 84))
            p.mosque(8, scale: 1.1)
            p.palm(-52, 58); p.palm(58, 46); p.palm(-72, 40)
            p.stars([(40, 140), (80, 164), (120, 142), (160, 170), (200, 146), (240, 172)], size: 1.3)
        },
        // Al-Baqara 246-260: the river the army was tried with on its march (2:249).
        make("p02-river", backdrop: .open) { p in
            p.at(p.width / 2)
            p.hills(seed: 9, height: 22)
            p.water(from: -p.width / 2, to: p.width / 2, depth: 26)
            p.at(112)
            p.tent(2, 72, 48); p.tent(-62, 48, 32); p.tent(64, 44, 29); p.tent(-112, 34, 22)
            p.banner(-30, 84, p.shade(0.92, 0.90, 0.84))
            p.campfire(-156, 0, scale: 1.3)
            p.reeds(-196, count: 9); p.reeds(84, count: 5)
        },
        // Aal-Imran 1-32: tilled land and its harvest, the enjoyment of this life (3:14); and
        // better than that, gardens under which rivers run (3:15).
        make("p03-tilled-land") { p in
            p.at(p.width / 2)
            p.greenField(from: -p.width / 2, to: 30, ripeness: 0.35, bankFade: 18)
            p.river(from: 38, to: 65, width: 76, naturalBanks: true)
            p.house(-118, 38, 21)
            p.hearthSmoke(-124, 23)
            p.grain(from: -84, to: 36)
            p.at(100)
            p.palm(-54, 72); p.palm(48, 88); p.tree(-84, 46); p.olive(74, 42)
            p.flowers(from: 34, to: 92)
        },
        // Aal-Imran 96-120: the first House set up for people, at Bakka, and the
        // standing-place of Ibrahim beside it (3:96-97).
        make("p03-first-house") { p in
            p.at(116)
            p.peak(-126, 150, 66, lean: -6); p.peak(84, 130, 86, lean: 5)
            p.kaaba(4, 1.75)
            // The standing-place: a small domed case with a lamp in it.
            p.block(-54, 16, 18); p.block(-54, 19, 1.6, from: 18); p.dome(-54, 14, on: 19.6, rise: 8.4); p.spire(-54, 1.4, from: 27, to: 33)
            p.window(-54, 6.4, 10.5, from: 3.6)
            p.lampLine(from: -160, to: -86, count: 4)
            p.stars([(-150, 132), (-110, 158), (-70, 138), (-34, 168), (40, 150)], size: 1.3)
        },
        // Aal-Imran 190-200: the heavens and the earth, the night and the day following
        // each other: signs for those who remember Him standing, sitting and lying down (3:190-191).
        make("p03-night-and-day", backdrop: .open) { p in
            p.at(p.width / 2)
            p.hills(seed: 3, height: 24)
            p.horizonLight(-70, spread: 190)
            p.at(108)
            p.constellations(over: -24, height: 184)
            p.tent(0, 76, 50); p.tent(-62, 44, 29)
            p.palm(64, 70); p.palm(-112, 52)
            p.campfire(-150, 0, scale: 1.1)
            p.mist(from: -294, to: 108, at: 6)
        },
        // An-Nisa 58-70: trusts given back to those they belong to, and judgement between
        // people with justice (4:58).
        make("p04-justice") { p in
            p.at(112)
            p.arcade(-112, bays: 5, bay: 15, height: 30)
            p.scales(8, 102)
            p.palm(86, 54); p.palm(-176, 46)
            p.stars([(-150, 134), (-110, 160), (-70, 140), (-40, 170), (70, 150)], size: 1.3)
        },
        // An-Nisa 71-96: wherever you are, death will reach you, though you were in towers
        // built high (4:78).
        make("p04-towers") { p in
            p.at(108)
            p.tower(-36, 100); p.tower(38, 122)
            p.fortress(0, 104, 34)
            p.graves(from: -200, to: -84, count: 7)
            p.bareTree(-150, 44)
            p.mist(from: -294, to: 108, at: 7)
        },
        // An-Nisa 97-152: the earth wide enough to leave home in: whoever emigrates finds
        // many a place of refuge, and plenty (4:97-100).
        make("p04-emigrants-road", backdrop: .open) { p in
            p.at(p.width / 2)
            p.dunes([(-150, 110, 22), (176, 80, 14)])
            p.road(to: 70, from: -70, width: 40)
            p.driftingSand(from: -p.width / 2, to: p.width / 2, height: 14)
            p.town(-146, houses: 4, scale: 0.9)
            p.at(98)
            p.palm(-28, 78); p.palm(-6, 58); p.palm(36, 86); p.palm(60, 54)
            p.spring(-64, scale: 1.7)
            p.tent(12, 32, 21)
        },
        // An-Nisa 153-176: the Mount raised over them for their covenant, and the gate they
        // were told to go in by, bowing (4:154).
        make("p04-mount-and-gate") { p in
            p.at(118)
            p.peak(-8, 236, 126, lean: 10)
            p.stoneWall(-104, 116, 28); p.stoneWall(72, 60, 28)
            p.gate(0, 68)
            p.olive(-176, 34)
            p.mist(from: -284, to: 118, at: 7)
            p.shootingStars(over: -90)
        },
        // Al-Ma'ida 1-19: water to wash with before the prayer, and clean earth where there
        // is none (5:6).
        make("p05-washing") { p in
            p.at(104)
            p.mosque(18, scale: 1.25)
            p.spring(-76, scale: 2.5)
            p.vessels(-136)
            p.palm(-176, 54); p.palm(84, 44)
            p.stars([(-150, 136), (-112, 160), (-74, 142), (-36, 170), (-180, 168)], size: 1.3)
        },
        // Al-Ma'ida 20-43: the holy land written for them, and its gate: go in by it and you
        // will prevail (5:21-23); the camp that would not, left to the wilderness (5:26).
        make("p05-holy-land-gate", backdrop: .open) { p in
            p.at(p.width / 2)
            p.dunes([(-150, 110, 24)])
            p.driftingSand(from: -p.width / 2, to: p.width / 2, height: 18)
            p.at(104)
            p.olive(-44, 66); p.palm(40, 78); p.palm(-8, 60)
            p.fortress(0, 124, 38)
            p.tent(-150, 30, 20); p.tent(-180, 22, 15)
            p.campfire(-118, 0, scale: 0.9)
        },
        // Al-Ma'ida 44-93: the Torah, then the Gospel, then this Book: in each of them
        // guidance and light (5:44-48).
        make("p05-guidance-and-light") { p in
            p.at(96)
            p.arcade(0, bays: 3, bay: 36, height: 82)
            p.pages(-110, scale: 1.7)
            p.palm(-170, 56); p.palm(76, 40)
            p.descendingLight(over: -110, spread: 90)
            p.stars([(-150, 150), (-190, 128), (-70, 160), (-40, 136)], size: 1.3)
        },
        // Al-Ma'ida 94-108: the Kaaba, the Sacred House, set up as a standing for people;
        // and the sacred month (5:97).
        make("p05-sacred-house", ownMoon: true) { p in
            p.at(112)
            p.peak(90, 130, 64)
            p.arcade(-112, bays: 6, bay: 14, height: 22); p.arcade(78, bays: 3, bay: 14, height: 22)
            p.kaaba(0, 1.8)
            p.crescent(-56, 150, 10)
            p.hearthSmoke(-150, 24)
            p.stars([(-150, 130), (-110, 162), (-20, 172), (50, 140)], size: 1.3)
        },
        // Al-An'am 1-58: the darknesses and the light (6:1); and the generations before,
        // settled in the land with rivers running beneath them, then gone (6:6).
        make("p06-darkness-and-light", backdrop: .open) { p in
            p.at(p.width / 2)
            p.hills(seed: 61, height: 20)
            p.horizonLight(-40, spread: 230)
            p.river(from: -50, to: -96, width: 90, naturalBanks: true, course: .bendLeft)
            p.at(100)
            p.ruins(0, scale: 1.15)
            p.reeds(-128, count: 6)
            p.bareTree(-96, 40)
        },
        // Al-An'am 59-73: not a leaf falls but He knows it, nor a grain in the darknesses
        // of the earth, nor anything green or dry (6:59).
        make("p06-falling-leaf") { p in
            p.at(p.width / 2)
            p.grain(from: -p.width / 2, to: 70)
            p.at(106)
            p.greatTree(0, 106)
            // Leaves coming down from it, one after another, turning as they fall.
            for index in 0..<9 {
                let fall = (SkylinePen.noise(index, 13) + p.time * 0.045).truncatingRemainder(dividingBy: 1)
                let x = -78 + 150 * CGFloat(SkylinePen.noise(index, 17)) + CGFloat(sin(p.time * 0.9 + Double(index) * 1.7)) * 6
                let y = 68 - CGFloat(fall) * 66, tip = CGFloat(sin(p.time * 1.4 + Double(index))) * 2
                p.tint(p.polygon([(x - 3.6, y - tip), (x, y + 1.8), (x + 3.6, y + tip), (x, y - 1.8)]),
                       p.shade(0.80, 0.74, 0.34, min(1, 1.6 * sin(fall * Double.pi))))
            }
            p.house(-146, 28, 16)
            p.hearthSmoke(-150, 18)
        },
        // Al-An'am 95-150: the grain and the date-stone split open (6:95); rain, and by it
        // green shoots, date clusters hanging low, gardens of vines and olives (6:99, 6:141).
        make("p06-clustered-dates") { p in
            p.at(108)
            p.stormCloud(-40, 152, 130)
            p.rain(from: -120, to: 20, height: 150)
            p.palm(40, 98); p.palm(72, 72); p.palm(8, 64)
            p.vines(-66, bays: 3)
            p.olive(-134, 46)
            p.house(-184, 24, 14)
            p.grain(from: -240, to: -202)
        },
        // Al-An'am 151-165: this is My path, straight, so follow it; and not the other ways,
        // which would part you from it (6:153).
        make("p06-straight-path", backdrop: .open) { p in
            p.at(p.width / 2)
            p.dunes([(-150, 100, 18), (184, 70, 12)])
            p.horizonLight(64, spread: 190)
            // The by-ways that leave it and wander off.
            p.road(to: -128, from: 40, width: 13); p.road(to: 196, from: 86, width: 13); p.road(to: -24, from: 52, width: 11)
            p.road(to: 64, from: 64, width: 52)
            p.at(p.width / 2 - 64)
            p.palm(40, 70); p.palm(58, 48); p.palm(-42, 52)
            p.tent(-84, 30, 20)
            p.stars([(-70, 150), (-30, 174), (10, 156), (50, 178), (84, 150)], size: 1.3)
        },
        // Al-A'raf 1-43: the Garden, where they might eat from wherever they wished, and
        // the one tree they were not to go near (7:19-22).
        make("p07-garden-tree") { p in
            p.at(p.width / 2)
            p.river(from: -66, to: -120, width: 84, naturalBanks: true, course: .bendRight)
            p.flowers(from: -196, to: -110); p.flowers(from: -30, to: 40)
            p.at(98)
            p.greatTree(6, 108)
            p.at(min(312, p.width - 84))
            p.palm(-52, 56); p.fig(-16, 32); p.olive(62, 40)
            p.stars([(150, 170), (190, 148), (232, 176), (270, 150)], size: 1.3)
        },
        // Al-A'raf 59-102: the towns whose stories are told (7:101): palaces on the plain and
        // houses hewn in the mountains (7:74), left as though no one had lived there (7:92).
        make("p07-towns-left-empty") { p in
            p.at(108)
            p.cliff(26, 150, 90)
            p.hewnDoor(-14, 11, 26); p.hewnDoor(26, 13, 36); p.hewnDoor(66, 11, 28)
            p.ruins(-130, scale: 0.95)
            p.bareTree(-212, 36)
            p.driftingSand(from: -294, to: 108, height: 22)
            p.stars([(-160, 130), (-120, 156), (-80, 138), (-50, 168), (-190, 164)], size: 1.3)
        },
        // Al-A'raf 103-141: what Pharaoh and his people had built and raised up, brought to
        // ruin (7:137).
        make("p07-pharaoh-works", backdrop: .open) { p in
            p.at(p.width / 2)
            p.water(from: -p.width / 2, to: p.width / 2, depth: 42)
            p.at(132)
            p.block(0, 250, 4)
            p.columns(-52, heights: [86, 86, 44, 98, 98, 30, 72], gap: 17)
            p.palm(-96, 50); p.palm(102, 58)
            p.reeds(-200, count: 8); p.reeds(74, count: 6)
            p.stars([(-150, 136), (-110, 164), (-70, 146), (90, 150), (110, 176)], size: 1.3)
        },
        // Al-A'raf 142-206: Mount Sinai, and the thirty nights made full with ten: forty
        // nights (7:142-143).
        make("p07-forty-nights", ownMoon: true) { p in
            p.at(112)
            p.peak(34, 200, 116, lean: -6)
            p.peak(-150, 130, 48)
            p.moonPhases(from: -160, to: 96, at: 164)
            p.tentCamp(-104, count: 7)
            p.campfire(-176, 0, scale: 1.0)
            p.mist(from: -290, to: 112, at: 7)
        },
        // At-Tawba 1-37: the Sacred Mosque, the tending of it and the giving of water to
        // the pilgrims (9:17-19).
        make("p09-sacred-mosque") { p in
            p.at(104)
            p.peak(-160, 140, 56, lean: -4); p.peak(84, 110, 72)
            p.kaaba(10, 1.7)
            p.well(-62, scale: 1.7)
            p.lampLine(from: -180, to: -110, count: 3)
            p.stars([(-150, 134), (-110, 160), (-70, 142), (-30, 170), (40, 150)], size: 1.3)
        },
        // At-Tawba 38-41: the two in the cave: "do not grieve, Allah is with us" (9:40).
        make("p09-cave") { p in
            p.at(116)
            p.peak(-124, 130, 56, lean: -4)
            p.peak(4, 200, 118, lean: 6)
            // The mouth of the cave high on its side, dark, and the track up to it.
            p.tint(p.archPath(-12, 15, 12, from: 62, pointed: false), Color.black.opacity(0.5))
            p.detail(p.polygon([(-26, 61), (2, 61), (6, 63), (-30, 63)]), strength: 0.9)
            p.detail(p.strokePath([(-74, 4), (-50, 24), (-58, 40), (-30, 52), (-22, 61)], 1.2, smooth: true), strength: 0.7)
            p.bareTree(-96, 30)
            p.mist(from: -286, to: 116, at: 8)
            p.stars([(-150, 136), (-110, 162), (-70, 144), (60, 160), (90, 132)], size: 1.3)
            p.shootingStars(over: -80)
        },
        // Yunus 1-10: the sun made a radiance and the moon a light, its stages measured out
        // so that the years can be counted (10:5-6).
        make("p10-sun-and-moon", backdrop: .open, ownMoon: true) { p in
            p.at(p.width / 2)
            p.hills(seed: 10, height: 20)
            p.moonPhases(from: -40, to: 186, at: 166)
            p.sun(120, 118, 16)
            p.grain(from: -p.width / 2, to: -20)
            p.at(124)
            p.house(-30, 46, 27); p.palm(26, 78); p.palm(50, 54); p.tree(-92, 50)
            p.hearthSmoke(-38, 29)
        },
        // Yunus 24-74: this life is like rain mingling with the earth's growth until the
        // land has put on its finery; then it is reaped, as if it had not flourished the
        // day before (10:24).
        make("p10-adorned-earth") { p in
            p.at(p.width / 2)
            // Both tracts recede towards the same horizon. Their softened
            // shared edge keeps the change in growth distinct without a seam.
            p.greenField(from: -p.width / 2, to: -64, ripeness: 1, bankFade: 14, perspectiveOrigin: 0)
            p.greenField(from: -76, to: p.width / 2, leftFade: 14, perspectiveOrigin: 0)
            p.bareTree(-150, 44)
            p.house(-104, 28, 16)
            p.flowers(from: -60, to: 196)
            p.at(96)
            p.tree(-10, 76); p.fig(-74, 34); p.palm(52, 64)
            p.stars([(-150, 150), (-110, 172), (-60, 156), (-10, 178), (60, 160)], size: 1.3)
        },
        // Yunus 75-109: houses for their people in Egypt, made places of prayer (10:87).
        make("p10-houses-in-egypt", backdrop: .open) { p in
            p.at(p.width / 2)
            p.water(from: -p.width / 2, to: p.width / 2, depth: 40)
            p.at(108)
            p.block(-30, 260, 4)
            p.town(0, houses: 8, scale: 1.4)
            p.palm(-96, 62); p.palm(92, 50); p.palm(-122, 44)
            p.reeds(-190, count: 8); p.reeds(-150, count: 5)
            p.boat(-226, scale: 1.1)
            p.hearthSmoke(-10, 40)
        },
        // Hud 1-39: the ark built on dry land, at His command (11:37-38).
        make("p11-ark-building", backdrop: .open) { p in
            p.at(p.width / 2)
            p.dunes([(-150, 110, 22), (176, 80, 16)])
            p.driftingSand(from: -p.width / 2, to: p.width / 2, height: 14)
            p.at(124)
            // On the stocks: props under her hull, the poles of a scaffold, timber stacked ready.
            for x in [-46, -18, 14, 44] as [CGFloat] { p.shape([(x - 3.4, 0), (x + 3.4, 0), (x + 1.4, 9), (x - 1.4, 9)]) }
            p.set(124, rise: 14, still: true) { q in q.ark(0, scale: 1.35) }
            p.block(-80, 1.8, 54); p.block(84, 1.8, 48)
            p.line([(-80, 40), (-62, 30)], 1.2); p.line([(84, 36), (68, 28)], 1.2)
            for (row, wide) in [(0, 40), (1, 32), (2, 24)] as [(CGFloat, CGFloat)] { p.block(-132, wide, 2.6, from: row * 3.2) }
            p.campfire(-176, 0, scale: 1.0)
            p.palm(104, 50)
        },
        // Hud 50-68: morning found them fallen in their homes, as though they had never
        // lived there (11:67-68; 11:60 of 'Ad).
        make("p11-empty-homes") { p in
            p.at(110)
            // Houses left standing, no lamp in any of them.
            for (x, w, h) in [(-6, 62, 40), (-70, 44, 26), (58, 40, 30), (-118, 34, 20), (-158, 28, 15)] as [(CGFloat, CGFloat, CGFloat)] {
                p.shape([(x - w / 2 - 0.6, 0), (x + w / 2 + 0.6, 0), (x + w / 2, h), (x - w / 2, h)])
                p.block(x, w + 2.4, 1.5, from: h)
                p.block(x - w / 2 + 1.4, 3, 1.6, from: h + 1.5); p.block(x + w / 2 - 1.4, 3, 1.6, from: h + 1.5)
                p.tint(p.archPath(x - w * 0.12, w * 0.16, h * 0.5, pointed: false), Color.black.opacity(0.4))
                p.tint(p.blockPath(x + w * 0.26, w * 0.1, h * 0.16, from: h * 0.52), Color.black.opacity(0.36))
            }
            p.bareTree(-36, 58)
            p.palmStump(92, 14)
            p.windStreaks(from: -292, to: 110, at: 96)
            p.driftingSand(from: -292, to: 110, height: 26)
            p.stars([(-150, 136), (-110, 160), (-60, 146), (-20, 172), (40, 150), (86, 174)], size: 1.3)
        },
        // Hud 69-83: "their appointed time is the morning: is the morning not near?" The town
        // overturned, and stones of baked clay rained on it (11:81-82).
        make("p11-stones-at-dawn", backdrop: .open) { p in
            p.at(p.width / 2)
            p.hills(seed: 11, height: 16)
            p.horizonLight(-56, spread: 200)
            p.crackedGround(from: -p.width / 2, to: p.width / 2)
            p.at(108)
            p.ruins(0, scale: 1.2)
            p.palmStump(-104, 14)
            p.fallingStones(over: -30, spread: 230)
        },
        // Hud 84-123: Madyan: "give full measure and full weight, in justice" (11:84-85).
        make("p11-madyan-measure") { p in
            p.at(108)
            p.town(-190, houses: 4, scale: 0.9)
            p.market(-98, stalls: 2)
            p.scales(18, 100)
            // The grain to be measured, heaped beside the balance.
            let heaps = [p.ridgePath([(-48, 0), (-42, 6), (-34, 10), (-26, 6), (-20, 0)]), p.ridgePath([(-30, 0), (-24, 5), (-18, 7), (-12, 5), (-6, 0)])]
            for heap in heaps { p.add(heap); p.tint(heap, p.shade(0.88, 0.72, 0.36, 0.85)) }
            p.palm(86, 52)
            p.hearthSmoke(-190, 22)
        },
        // Yusuf 58-98: the caravan road between Kan'an and Egypt, the city's several gates
        // ahead (12:67), the loads of grain measured out (12:65).
        make("p12-caravan-road", backdrop: .open) { p in
            p.at(p.width / 2)
            p.dunes([(-156, 100, 24)])
            p.road(to: 104, from: -10, width: 46)
            p.driftingSand(from: -p.width / 2, to: p.width / 2, height: 16)
            p.at(98)
            p.stoneWall(0, 180, 22)
            p.gate(-58, 40); p.gate(0, 50); p.gate(58, 40)
            p.palm(-108, 44); p.palm(88, 38)
            p.at(min(290, p.width - 90))
            p.tent(0, 44, 29); p.tent(-42, 30, 20)
            p.campfire(40, 0, scale: 1.0)
            // Sacks of grain set down beside the tents.
            for x in [-74, -64, -69] as [CGFloat] { p.add(p.crownPath(x, x == -69 ? 9 : 3.4, 5.4, 4.2, lobes: 5, depth: 0.1, seed: Int(x), flat: 0.5)) }
        },
        // Yusuf 99-111: "enter Egypt, if Allah wills, in safety" (12:99); and the dream come
        // true: the sun, the moon and eleven stars (12:100, 12:4).
        make("p12-dream-fulfilled", backdrop: .open, ownMoon: true) { p in
            p.at(p.width / 2)
            p.water(from: -p.width / 2, to: p.width / 2, depth: 34)
            p.at(108)
            p.block(-40, 300, 4)
            p.stoneWall(-106, 130, 30); p.stoneWall(82, 70, 30)
            p.gate(0, 90, gilded: true)
            p.palm(-70, 62); p.palm(70, 54); p.palm(-150, 48)
            p.sun(-58, 144, 12); p.crescent(58, 146, 9)
            p.stars([(-40, 168), (-30, 182), (-18, 192), (-6, 198), (6, 198), (18, 192), (30, 182), (40, 168), (-14, 172), (14, 172), (0, 180)], size: 1.3)
            p.reeds(max(-230, 128 - p.width), count: 7)
        },
        // An-Nahl 1-64: mountains set firm, rivers and roads to find the way by, waymarks,
        // and the stars they steer by (16:15-16).
        make("p16-waymarks-and-stars") { p in
            p.at(p.width / 2)
            p.peak(140, 190, 108, lean: -6); p.peak(-176, 150, 50)
            p.river(from: -40, to: -110, width: 76, naturalBanks: true, course: .meander)
            p.road(to: 30, from: 80, width: 30)
            // Waymarks: stones piled beside the road.
            for (x, y, s) in [(46, 0, 1.6), (70, -13, 2.4), (112, -31, 3.4)] as [(CGFloat, CGFloat, CGFloat)] {
                p.shape([(x - 3.4 * s, y), (x + 3.4 * s, y), (x + 2.2 * s, y + 2.4 * s), (x - 2.2 * s, y + 2.4 * s)])
                p.shape([(x - 2.2 * s, y + 2.4 * s), (x + 2.0 * s, y + 2.4 * s), (x + 1.1 * s, y + 4.6 * s), (x - 1.3 * s, y + 4.6 * s)])
                p.shape([(x - 1.1 * s, y + 4.6 * s), (x + 1.0 * s, y + 4.6 * s), (x, y + 6.4 * s)])
            }
            p.constellations(over: 10, height: 182)
            p.tent(-14, 42, 28)
            p.palm(-52, 44)
            p.reeds(-96, count: 6)
        },
        // An-Nahl 80-111: houses to rest in, tents light to carry on the day you travel and
        // the day you camp, shade, and shelters in the mountains (16:80-81).
        make("p16-homes-and-tents") { p in
            p.at(104)
            p.peak(40, 170, 106, lean: 4)
            p.window(20, 15, 12, from: 24, pointed: false); p.window(58, 11, 9, from: 40, pointed: false)
            p.detail(p.blockPath(20, 22, 1.2, from: 22.4), strength: 0.8); p.detail(p.blockPath(58, 17, 1.2, from: 38.4), strength: 0.8)
            p.house(-66, 40, 24)
            p.hearthSmoke(-72, 26)
            p.tree(-18, 58)
            p.tent(-128, 40, 26); p.tent(-170, 28, 18)
            p.stars([(-150, 136), (-110, 160), (-70, 142), (-180, 168)], size: 1.3)
        },
        // An-Nahl 112-128: a town secure and at ease, its provision coming to it in plenty
        // from every side (16:112).
        make("p16-secure-town") { p in
            p.at(p.width / 2)
            p.road(to: 60, from: -110, width: 30); p.road(to: 116, from: 190, width: 30)
            p.grain(from: -p.width / 2, to: -84)
            p.at(112)
            p.town(0, houses: 8, scale: 1.5)
            p.market(-108, stalls: 2)
            p.palm(88, 64); p.palm(-66, 56)
            p.hearthSmoke(-6, 44); p.hearthSmoke(30, 38)
        },
        // Al-Isra 22-65: full measure when you measure, and weighing with the straight
        // balance (17:35), among the commands of 17:22-39.
        make("p17-straight-balance") { p in
            p.at(p.width / 2)
            p.grain(from: -p.width / 2, to: -30)
            p.at(116)
            p.house(-126, 44, 26)
            p.hearthSmoke(-134, 28)
            p.scales(0, 100)
            p.palm(-76, 60); p.palm(84, 50)
            p.shootingStars(over: -70)
        },
        // Al-Isra 66-77: your Lord drives the ship on for you through the sea; and when harm
        // reaches you there, all you call on are lost but Him (17:66-69).
        make("p17-ship-in-gale", backdrop: .open) { p in
            p.at(p.width / 2)
            p.water(from: -p.width / 2, to: p.width / 2, depth: 46)
            p.stormCloud(116, 160, 150)
            p.windStreaks(from: -p.width / 2, to: p.width / 2, at: 112)
            p.at(130)
            p.ship(0, scale: 1.15)
            p.at(p.width / 2)
            p.waves(from: -p.width / 2, to: p.width / 2, height: 14)
        },
        // Al-Isra 78-89: prayer from the sun's decline to the dark of night, and the recital
        // of dawn, which is witnessed; and rising in the night (17:78-79).
        make("p17-dawn-prayer", backdrop: .open) { p in
            p.at(p.width / 2)
            p.hills(seed: 17, height: 18)
            p.horizonLight(20, spread: 230)
            p.at(108)
            p.mosque(4, scale: 1.4)
            p.palm(-72, 60); p.palm(-92, 42); p.palm(74, 48)
            p.descendingLight(over: 0, spread: 150)
            p.mist(from: -294, to: 108, at: 6)
        },
        // Al-Isra 90-111: what they demanded before they would believe: a spring made to gush
        // from the ground, a garden of palms and vines, a house of gold (17:90-93).
        make("p17-things-demanded") { p in
            p.at(104)
            p.gate(22, 82, gilded: true)
            p.spring(-52, scale: 2.5)
            p.vines(-136, bays: 3)
            p.palm(-92, 64); p.palm(78, 52); p.palm(-184, 46)
            p.stars([(-150, 140), (-110, 164), (-70, 146), (-36, 172)], size: 1.3)
        },
        // Al-Kahf 60-82: where the two seas meet (18:60); the ship (18:71, 18:79); and in the
        // town, the wall on the point of falling (18:77, 18:82).
        make("p18-ship-and-wall", backdrop: .open) { p in
            p.at(p.width / 2)
            p.twoSeas(meetAt: -96)
            p.boat(-120, scale: 2.0)
            p.at(84)
            p.block(0, 190, 4)
            p.town(26, houses: 4, scale: 1.25)
            p.palm(-20, 60)
            p.set(156, lean: 0.20) { q in q.stoneWall(0, 40, 42) }
            p.line([(-102, 0), (-84, 30)], 2.0)
        },
        // Al-Kahf 83-110: the barrier raised between the two mountain-sides: blocks of iron,
        // the bellows blown till it glowed, molten copper poured over it (18:93-97).
        make("p18-barrier") { p in
            p.at(110)
            p.cliff(-80, 104, 104); p.cliff(82, 96, 114)
            p.stoneWall(2, 66, 78)
            p.tint(p.blockPath(2, 60, 77), p.shade(0.66, 0.38, 0.22, 0.34))
            p.tint(p.blockPath(2, 60, 9, from: 68), p.shade(0.86, 0.52, 0.26, 0.5))
            p.glow(2, 40, 44, Color(red: 1.0, green: 0.56, blue: 0.22), 0.16, nightOnly: true)
            p.forge(-176)
            p.driftingSand(from: -292, to: 110, height: 14)
        },
        // Ta-Ha 56-76: the meeting set for the Day of Adornment, the people gathered at
        // mid-morning (20:58-59).
        make("p20-festival-day", backdrop: .open) { p in
            p.at(108)
            p.sun(-84, 152, 13)
            p.arcade(-108, bays: 5, bay: 15, height: 28)
            p.gate(8, 90)
            p.banner(-150, 52, p.shade(0.72, 0.26, 0.22)); p.banner(-104, 60, p.shade(0.90, 0.74, 0.34)); p.banner(-58, 52, p.shade(0.20, 0.46, 0.50))
            p.banner(64, 62, p.shade(0.90, 0.74, 0.34))
            p.palm(-190, 46)
        },
        // Ta-Ha 77-98: "travel by night with My servants, and strike for them a dry path
        // through the sea" (20:77-78).
        make("p20-dry-path", backdrop: .open) { p in
            p.at(128)
            p.partedSea(0, gap: 58, height: 72)
            p.stars([(-160, 150), (-130, 176), (-96, 158), (-60, 182), (-24, 164), (10, 186), (44, 166), (80, 184), (110, 160)], size: 1.5)
            p.shootingStars(over: -40, height: 180)
        },
        // Ta-Ha 99-114: the mountains scattered as dust, the earth left a level plain with
        // no dip or rise in it (20:105-107).
        make("p20-level-plain", backdrop: .open) { p in
            p.at(p.width / 2)
            // What is left of the mountains: low heaps, their dust streaming off on the wind.
            let heaps: [(CGFloat, CGFloat, CGFloat)] = [(-124, 150, 9), (36, 190, 13), (166, 110, 7)]
            for heap in heaps {
                p.add(p.ridgePath([(heap.0 - heap.1 / 2, 0), (heap.0 - heap.1 * 0.28, heap.2 * 0.7), (heap.0 - heap.1 * 0.05, heap.2),
                                   (heap.0 + heap.1 * 0.22, heap.2 * 0.62), (heap.0 + heap.1 / 2, 0)]))
                p.plume(from: heap.0, heap.2 * 0.8, reach: -96, rise: 48, (0.86, 0.76, 0.58), strength: 0.17)
            }
            p.windStreaks(from: -p.width / 2, to: p.width / 2, at: 74)
            p.driftingSand(from: -p.width / 2, to: p.width / 2, height: 48)
            p.stars([(-40, 150), (0, 176), (40, 156), (84, 180), (130, 150), (170, 172)], size: 1.4)
        },
        // Ta-Ha 115-135: the Garden where there is no hunger and no thirst and no heat of the
        // sun, and the tree he was led to (20:115-120).
        make("p20-garden") { p in
            p.at(108)
            p.tree(26, 106, spread: 88)
            p.spring(-64, scale: 2.6)
            p.fig(-128, 36); p.palm(-170, 60)
            p.flowers(from: -112, to: -84); p.flowers(from: -30, to: 96)
            p.stars([(-150, 140), (-110, 166), (-70, 148), (-40, 174)], size: 1.3)
        },
        // Al-Anbiya 30-50: firm mountains and broad passes through them for roads, the sky a
        // roof well guarded, the sun and the moon each floating in its orbit (21:31-33).
        make("p21-orbits", backdrop: .open, ownMoon: true) { p in
            p.at(p.width / 2)
            p.hills(seed: 21, height: 22)
            p.cliff(-150, 110, 44); p.peak(150, 200, 104, lean: 6)
            p.road(to: 14, from: -36, width: 38)
            // The two orbits, and what floats in each.
            for (rx, ry, lift) in [(170, 150, 20), (128, 112, 30)] as [(CGFloat, CGFloat, CGFloat)] {
                var arc: [(CGFloat, CGFloat)] = []
                for step in 0...24 {
                    let angle = Double.pi * (0.08 + 0.84 * Double(step) / 24)
                    arc.append((30 + rx * CGFloat(cos(angle)), lift + ry * CGFloat(sin(angle))))
                }
                p.tint(p.strokePath(arc, 0.7, smooth: true), Color.white.opacity(0.13))
            }
            p.sun(113, 151, 12); p.crescent(-46, 114, 9)
            p.tent(50, 38, 25); p.palm(-40, 50)
            p.mist(from: -p.width / 2, to: p.width / 2, at: 6)
        },
        // Al-Anbiya 51-77: the fire they built, and the word spoken to it: "be coolness and
        // safety" (21:68-69).
        make("p21-fire-made-cool") { p in
            p.at(112)
            p.town(-150, houses: 4, scale: 1.0)
            // The wood heaped for it, on either side.
            for (x, rows) in [(-58, 4), (58, 3)] as [(CGFloat, Int)] {
                for row in 0..<rows { p.block(x, CGFloat(34 - row * 5), 3, from: CGFloat(row) * 3.4) }
            }
            p.campfire(0, 0, scale: 3.6)
            p.hearthSmoke(0, 42)
            p.mist(from: -292, to: 112, at: 5)
            p.stars([(-150, 136), (-110, 160), (-70, 144), (60, 150), (90, 130)], size: 1.3)
        },
        // Al-Anbiya 78-112: the mountains made to give praise with Dawud (21:79), and for
        // Sulayman the strong wind, running at his command to the land that was blessed (21:81).
        make("p21-mountains-and-wind") { p in
            p.at(p.width / 2)
            p.peak(-10, 150, 62, lean: -5); p.peak(76, 160, 92, lean: 4); p.peak(160, 150, 120, lean: 6)
            p.windStreaks(from: -p.width / 2, to: p.width / 2, at: 100)
            p.olive(-96, 52); p.olive(-52, 38); p.fig(-140, 30)
            p.house(-174, 28, 16)
            p.flowers(from: -130, to: -30)
            p.stars([(-40, 150), (0, 174), (40, 154), (100, 176)], size: 1.3)
        },
        // Al-Mu'minun 23-44: the ark made under His eyes (23:27), and the prayer: "set me
        // down at a blessed landing-place" (23:29).
        make("p23-blessed-landing", backdrop: .open) { p in
            p.at(p.width / 2)
            p.horizonLight(-80, spread: 190)
            p.water(from: -p.width / 2, to: p.width / 2, depth: 46)
            p.island(128, 200, 26)
            p.set(74, rise: 13) { q in q.olive(-34, 44); q.palm(6, 60); q.palm(30, 40) }
            p.at(230)
            p.ark(0, scale: 1.35)
        },
        // Al-Mu'minun 45-77: the son of Maryam and his mother given shelter on high ground,
        // a place of rest with a spring running (23:50).
        make("p23-high-ground") { p in
            p.at(112)
            p.add(p.ridgePath([(-176, 0), (-120, 16), (-60, 38), (-10, 46), (50, 46), (96, 34), (112, 28)]))
            p.set(112, rise: 44) { q in q.spring(8, scale: 2.2); q.olive(62, 48); q.palm(-36, 46) }
            // The stream it sends down the slope.
            p.tint(p.strokePath([(-6, 44), (-44, 36), (-84, 22), (-126, 8), (-170, -8), (-206, -30)], 3.4, smooth: true), p.shade(0.22, 0.52, 0.66, 0.62))
            p.flowers(from: -240, to: -180)
            p.stars([(-150, 136), (-110, 162), (-70, 146), (-180, 170)], size: 1.3)
        },
        // Al-Mu'minun 78-118: seven ways made above you (23:17): "who is Lord of the seven
        // heavens?" (23:86).
        make("p23-seven-heavens", backdrop: .open) { p in
            p.at(p.width / 2)
            p.dunes([(-150, 110, 18), (160, 100, 22)])
            p.at(116)
            p.sevenHeavens(over: -20)
            p.tent(-28, 44, 29); p.tent(18, 30, 20)
            p.campfire(-74, 0, scale: 1.1)
            p.palm(52, 54)
        },
        // Ash-Shu'ara 69-104: the Garden brought near to those who were mindful (26:90).
        make("p26-garden-brought-near", backdrop: .open) { p in
            p.at(p.width / 2)
            p.river(from: -20, to: -56, width: 120, naturalBanks: true, course: .meander)
            p.flowers(from: -196, to: -120); p.flowers(from: 30, to: 110)
            p.arcade(-150, bays: 4, bay: 15, height: 26)
            p.palm(-88, 52)
            p.at(96)
            p.greatTree(10, 100)
            p.hangingLantern(-36, from: 56, drop: 18, scale: 1.1)
            p.palm(-70, 64)
        },
        // Ash-Shu'ara 105-122: saved, with those beside him, in the laden ark (26:119).
        make("p26-laden-ark", backdrop: .open) { p in
            p.at(p.width / 2)
            p.island(-150, 120, 30)
            p.water(from: -p.width / 2, to: p.width / 2, depth: 46)
            p.waves(from: -p.width / 2, to: p.width / 2, height: 10)
            p.at(124)
            p.ark(0, scale: 1.55)
            p.stars([(-150, 140), (-100, 168), (-50, 150), (0, 176), (50, 156), (96, 178)], size: 1.4)
        },
        // Ash-Shu'ara 141-175: gardens and springs, crops, palms heavy with fruit, and houses
        // hewn from the mountains with great skill (26:146-149).
        make("p26-thamud-gardens") { p in
            p.at(108)
            p.cliff(30, 150, 92)
            p.hewnDoor(-10, 11, 26, lit: true); p.hewnDoor(30, 13, 36); p.hewnDoor(70, 11, 28, lit: true)
            p.palm(-66, 70); p.palm(-90, 50); p.palm(-176, 58)
            p.spring(-128, scale: 2.0)
            p.grain(from: -250, to: -196)
            p.flowers(from: -156, to: -146)
        },
        // Ash-Shu'ara 176-227: the people of the Thicket, told to give full measure and to
        // weigh with the straight balance (26:176-183).
        make("p26-thicket-balance") { p in
            p.at(104)
            for (x, h) in [(-196, 44), (-170, 58), (-142, 48), (-116, 62), (-90, 46)] as [(CGFloat, CGFloat)] { p.tree(x, h) }
            p.fig(-64, 26)
            p.scales(16, 100)
            p.house(80, 32, 19)
            p.shootingStars(over: -60)
        },
        // As-Saffat 40-74: a provision made known: fruits, and a cup from a running spring
        // passed round among them (37:41-47).
        make("p37-cup-and-spring") { p in
            p.at(104)
            p.palm(60, 92); p.palm(84, 66)
            p.spring(0, scale: 3.0)
            p.vessels(-78, scale: 1.2)
            p.fig(-150, 36)
            p.vines(-216, bays: 2)
            p.flowers(from: -120, to: -40)
            p.stars([(-150, 140), (-110, 166), (-70, 148), (-30, 174), (20, 150)], size: 1.3)
        },
        // As-Saffat 75-138: the peoples the messengers were sent to, and what is left of
        // them: "you pass by them in the morning, and at night" (37:137-138).
        make("p37-ruins-passed", backdrop: .open) { p in
            p.at(p.width / 2)
            p.dunes([(-156, 100, 16)])
            p.horizonLight(-96, spread: 160)
            p.road(to: -96, from: -170, width: 40)
            p.driftingSand(from: -p.width / 2, to: p.width / 2, height: 18)
            p.at(108)
            p.ruins(6, scale: 1.25)
            p.stars([(-150, 150), (-110, 172), (-60, 156), (-10, 178), (40, 160), (84, 176)], size: 1.3)
        },
        // As-Saffat 139-182: the laden ship he fled to (37:140); the bare shore he was cast
        // on, and the gourd plant made to grow over him (37:145-146).
        make("p37-gourd-shore", backdrop: .open) { p in
            p.at(p.width / 2)
            p.water(from: -p.width / 2, to: p.width / 2, depth: 46)
            p.ship(-110, scale: 0.6)
            p.at(96)
            // The bare shore, and the plant on it: broad leaves on a trailing stem, gourds among them.
            p.add(p.ridgePath([(-150, 0), (-110, 5), (-50, 9), (40, 9), (96, 7)]))
            p.tint(p.strokePath([(-150, 0.6), (-110, 5.4), (-50, 9.4), (40, 9.4)], 1.0, smooth: true), Color.white.opacity(0.22))
            let sway = CGFloat(sin(p.time * 0.8)) * 1.2
            p.line([(-52, 9), (-30, 20), (-6, 30), (20, 34), (44, 26), (60, 12)], 1.6, smooth: true)
            let leaves: [(CGFloat, CGFloat, CGFloat)] = [(-40, 20, 11), (-18, 32, 14), (8, 40, 15), (32, 36, 13), (52, 24, 11), (-4, 24, 12), (26, 22, 11)]
            for (index, leaf) in leaves.enumerated() {
                let path = p.crownPath(leaf.0 + sway * (0.5 + 0.1 * CGFloat(index)), leaf.1, leaf.2, leaf.2 * 0.66, lobes: 5, depth: 0.2, seed: 90 + index, flat: 0.2)
                p.add(path)
                p.tint(path, p.shade(0.30, 0.50, 0.28, 0.42))
            }
            for (x, y, r) in [(-24, 15, 4.6), (14, 15, 5.4), (44, 14, 4.2)] as [(CGFloat, CGFloat, CGFloat)] {
                p.tint(p.crownPath(x, y, r * 0.8, r, lobes: 4, depth: 0.06, seed: Int(x)), p.shade(0.80, 0.76, 0.44, 0.95))
            }
            p.stars([(-150, 150), (-110, 172), (-60, 156), (-10, 178), (40, 160), (84, 176)], size: 1.3)
        }
    ]
}

// MARK: Surahs of 40 to 100 ayahs

extension SurahScenes {
    static let furtherMiddle: [Cityscape] = [
        // Ibrahim 1-23: deeds like ashes that the wind blows hard on, on a stormy day (14:18).
        make("p14-ashes-in-wind", backdrop: .open) { p in
            p.at(p.width / 2)
            p.hills(seed: 14, height: 16)
            p.stormCloud(112, 156, 150)
            p.windStreaks(from: -p.width / 2, to: p.width / 2, at: 86)
            p.at(104)
            p.bareTree(52, 80)
            p.tent(-150, 36, 23)
            // A hearth gone cold: its stones, the charred logs, the heap of ash, and the ash streaming away.
            p.line([(-30, 2), (20, 11)], 4.4); p.line([(28, 2), (-22, 11)], 4.4)
            p.disc(-40, 2.2, 4.2); p.disc(38, 1.8, 3.6); p.disc(-12, 1.4, 2.6); p.disc(12, 1.2, 2.2)
            let ash = p.ridgePath([(-24, 3), (-15, 12), (-2, 18), (12, 13), (24, 3)])
            p.add(ash); p.tint(ash, p.shade(0.76, 0.76, 0.78, 0.85))
            p.plume(from: -8, 15, reach: -170, rise: 50, (0.80, 0.80, 0.82), strength: 0.30)
        },
        // Al-Hijr 1-50: great stars set in the sky and made fair to see (15:16); the earth spread
        // out and mountains cast on it (15:19); the winds sent to make the clouds bear, and rain (15:22).
        make("p15-sky-and-winds") { p in
            p.at(p.width / 2)
            p.greenField(from: -p.width / 2, to: p.width / 2)
            p.peak(-146, 160, 58, lean: -5)
            p.windStreaks(from: -p.width / 2, to: p.width / 2, at: 104)
            p.stormCloud(128, 158, 130)
            p.rain(from: 76, to: 204, height: 154)
            p.at(118)
            p.constellations(over: -44, height: 186)
            p.tree(4, 70); p.tent(-66, 40, 26)
        },
        // Al-Hijr 51-79: "set out with your family in the dead of night, and let none of you look
        // back" (15:65); the town gone by sunrise under stones of baked clay (15:73-74), on a road
        // that is still there (15:76).
        make("p15-night-road", backdrop: .open) { p in
            p.at(p.width / 2)
            p.dunes([(160, 100, 22)])
            p.horizonLight(-104, spread: 160)
            p.road(to: 60, from: 130, width: 46)
            p.at(min(306, p.width - 92))
            p.town(0, houses: 7, scale: 1.25)
            p.palm(-70, 46); p.palm(76, 52)
            p.fallingStones(over: 0, spread: 150, height: 120)
            p.at(70)
            p.palm(-10, 66); p.palm(14, 46)
            p.stars([(-100, 150), (-60, 172), (-20, 154), (20, 178), (48, 150)], size: 1.3)
        },
        // Maryam 1-15: the sanctuary Zakariyya prayed in, and came out of to his people, signing
        // to them to give praise morning and evening (19:11).
        make("p19-mihrab") { p in
            p.at(108)
            p.arcade(-112, bays: 5, bay: 15, height: 28)
            p.prayerNiche(0, scale: 1.8)
            p.fig(78, 34); p.palm(-190, 54)
            p.tree(-64, 50)
            p.stars([(-150, 136), (-110, 160), (-70, 142), (-36, 170), (70, 150)], size: 1.3)
            p.shootingStars(over: -90)
        },
        // Maryam 59-98: gardens of lasting stay, promised unseen: nothing idle heard there, only
        // peace, and their provision morning and evening (19:61-62).
        make("p19-gardens-of-eden", backdrop: .open) { p in
            p.at(p.width / 2)
            p.horizonLight(-24, spread: 220)
            p.river(from: 28, to: 4, width: 104, naturalBanks: true, course: .bendRight)
            p.table(-104, scale: 1.5)
            p.fig(max(-166, 20 - p.width / 2), 34)
            p.flowers(from: -60, to: 14); p.flowers(from: 60, to: 130)
            p.at(84)
            p.palm(-30, 86); p.palm(-6, 62); p.tree(46, 70)
            p.hangingLantern(22, from: 40, drop: 14)
        },
        // An-Nur 1-34: houses not your own are not to be entered until you have asked leave and
        // greeted those within (24:27-29).
        make("p24-doors") { p in
            p.at(106)
            p.palm(-74, 76); p.palm(88, 52)
            p.house(-128, 42, 25); p.house(-178, 30, 17)
            p.door(6, 54)
            p.hearthSmoke(-136, 27)
            p.stars([(-150, 140), (-110, 164), (-70, 146), (-180, 170)], size: 1.3)
        },
        // An-Nur 39-64: darkness on a deep sea, wave upon wave and cloud above (24:40); the clouds
        // driven together and heaped, rain coming out of them, and the flash of their lightning (24:43).
        make("p24-dark-sea", backdrop: .open) { p in
            p.at(p.width / 2)
            p.island(-150, 130, 22)
            p.set(p.width / 2 + 162, rise: 19) { q in q.house(0, 22, 13) }
            p.water(from: -p.width / 2, to: p.width / 2, depth: 46)
            p.stormCloud(60, 150, 190); p.stormCloud(150, 182, 110)
            p.rain(from: -40, to: 190, height: 148)
            p.waves(from: -p.width / 2, to: p.width / 2, height: 17)
        },
        // Al-Furqan 1-44: "what sort of messenger is this, who eats food and walks in the
        // markets?" Every messenger before him did the same (25:7, 25:20).
        make("p25-markets") { p in
            p.at(84)
            p.town(0, houses: 6, scale: 1.5)
            p.palm(-76, 78); p.palm(66, 62)
            p.set(170, scale: 1.55) { q in q.market(0, stalls: 3) }
            p.at(84)
            p.palm(-190, 50)
            p.hearthSmoke(0, 46)
        },
        // An-Naml 59-93: the earth made a place to settle, rivers through it and mountains set
        // on it (27:61); and those mountains, which you take to be fixed, passing as the clouds
        // pass (27:88).
        make("p27-mountains-like-clouds") { p in
            p.at(p.width / 2)
            p.peak(-140, 170, 68, lean: -6); p.peak(30, 150, 90, lean: 4); p.peak(150, 170, 114, lean: 6)
            p.river(from: -56, to: -100, width: 76, naturalBanks: true, course: .bendLeft)
            // Cloud drifting across them, as they themselves will drift.
            for index in 0..<7 {
                let run = (SkylinePen.noise(index, 21) + p.time * 0.006).truncatingRemainder(dividingBy: 1)
                let x = -p.width / 2 - 40 + (p.width + 80) * CGFloat(run), y = 40 + CGFloat(SkylinePen.noise(index, 23)) * 56
                let w = 36 + CGFloat(SkylinePen.noise(index, 25)) * 30
                p.tint(p.crownPath(x, y, w, w * 0.24, lobes: 7, depth: 0.2, seed: index + 30, flat: 0.6), Color.white.opacity(0.17 * (1 - 0.4 * p.night)))
            }
            p.mist(from: -p.width / 2, to: p.width / 2, at: 10)
            p.stars([(-60, 150), (-20, 174), (60, 160), (100, 180)], size: 1.3)
        },
        // Al-Qasas 1-21: the river the infant was trusted to (28:7), and the city entered while
        // its people were off their guard (28:15).
        make("p28-river-city", backdrop: .open) { p in
            p.at(p.width / 2)
            p.river(from: -76, to: -140, width: 150, naturalBanks: true, course: .bendRight)
            p.at(100)
            p.tower(-28, 86); p.tower(34, 70)
            p.fortress(0, 130, 34)
            p.palm(-92, 62); p.palm(86, 50)
            p.reeds(-150, count: 8); p.reeds(-232, count: 6)
            p.stars([(-150, 140), (-110, 164), (-70, 146), (-180, 170), (70, 150)], size: 1.3)
        },
        // Al-Qasas 76-88: Qarun, the keys of whose treasures were a load for strong men (28:76);
        // and the earth made to swallow him and his house (28:81).
        make("p28-qarun") { p in
            p.at(p.width / 2)
            p.crackedGround(from: -p.width / 2, to: p.width / 2)
            p.set(110, lean: -0.15) { q in q.gate(0, 104, gilded: true) }
            p.set(196, lean: 0.12) { q in q.stoneWall(0, 60, 34) }
            p.at(110)
            // The earth heaved up round its foot.
            p.add(p.ridgePath([(-76, 0), (-56, 9), (-30, 13), (-6, 8), (20, 14), (48, 9), (70, 0)]))
            p.town(max(-216, 140 - p.width), houses: 3, scale: 0.8)
            p.shootingStars(over: -90)
            p.stars([(-150, 140), (-110, 164), (-70, 146), (-36, 172)], size: 1.3)
        },
        // Al-Ankabut 1-40: 'Ad and Thamud: what became of them is plain to you from their
        // dwellings (29:38); and of that town a clear sign was left (29:35).
        make("p29-dwellings") { p in
            p.at(120)
            p.cliff(-126, 124, 58)
            p.hewnDoor(-158, 10, 22); p.hewnDoor(-124, 12, 30); p.hewnDoor(-92, 10, 22)
            p.columns(-36, heights: [80, 80, 50, 92, 92, 36, 66], gap: 16)
            p.block(12, 130, 4)
            p.driftingSand(from: -282, to: 120, height: 22)
            p.stars([(-150, 140), (-110, 164), (-70, 146), (-36, 172), (90, 150)], size: 1.3)
        },
        // Ar-Rum 17-60: the winds sent as bearers of good news, the ships running at His
        // command (30:46); the clouds they raise, spread across the sky, and the rain (30:48).
        make("p30-winds-and-ships", backdrop: .open) { p in
            p.at(p.width / 2)
            p.island(-150, 130, 26)
            p.water(from: -p.width / 2, to: p.width / 2, depth: 46)
            p.windStreaks(from: -p.width / 2, to: p.width / 2, at: 110)
            p.stormCloud(124, 160, 130)
            p.rain(from: 84, to: 196, height: 156)
            p.at(128)
            p.boat(0, scale: 2.8); p.boat(-104, scale: 1.6); p.boat(74, scale: 1.1)
        },
        // Al-Ahzab 28-73: the houses of the Prophet, not to be entered until leave is given, and
        // what is asked of those within asked from behind a screen (33:53); what is recited in
        // them of the signs of Allah (33:34).
        make("p33-prophets-houses") { p in
            p.at(108)
            p.palm(-52, 80); p.palm(78, 62)
            p.house(-6, 62, 38); p.house(56, 38, 25); p.house(-70, 42, 27)
            // A curtain hung in each doorway.
            for (x, w, h) in [(-6, 6, 12.6), (56, 6, 12.6), (-70, 6, 12.6)] as [(CGFloat, CGFloat, CGFloat)] {
                p.tint(p.archPath(x, w, h, pointed: false), p.shade(0.56, 0.24, 0.22, 0.9))
            }
            p.lampLine(from: -150, to: -110, count: 2)
            p.hearthSmoke(-14, 40)
            p.at(min(322, p.width - 50))
            p.mosque(0, scale: 0.85)
        },
        // Fatir 1-26: the two waters are not alike: one fresh and sweet to drink, one salt and
        // bitter; and the ships cleaving through them (35:12).
        make("p35-two-waters", backdrop: .open) { p in
            p.at(p.width / 2)
            p.horizonLight(-70, spread: 180)
            p.twoSeas(meetAt: -10)
            p.island(-150, 140, 20)
            p.boat(-120, scale: 1.5)
            p.at(100)
            p.ship(0, scale: 1.05)
            p.stars([(-150, 150), (-110, 172), (-60, 156), (70, 176)], size: 1.3)
        },
        // Az-Zumar 68-75: led to the Garden in companies, until they come to it and its gates are
        // opened: "peace be upon you" (39:73).
        make("p39-gates-opened", backdrop: .open) { p in
            p.at(p.width / 2)
            p.road(to: 89, from: 36, width: 50)
            p.at(112)
            p.palm(-150, 66); p.tree(-100, 68); p.palm(-60, 92); p.tree(84, 72)
            p.stoneWall(-112, 132, 34); p.stoneWall(80, 64, 34)
            p.glow(0, 34, 60, SkylinePen.lampLight, 0.20)
            p.gate(0, 104, gilded: true)
            p.flowers(from: -176, to: -58)
        },
        // Ghafir 56-85: the night made for you to rest in and the day to see by (40:61); the
        // earth a place to settle, and the sky a roof over it (40:64).
        make("p40-night-for-rest") { p in
            p.at(108)
            p.constellations(over: -30, height: 184)
            p.house(-26, 66, 35)
            p.hearthSmoke(-40, 37)
            p.tree(52, 86)
            p.well(-96, scale: 1.5)
            p.palm(-140, 58)
            p.mist(from: -294, to: 108, at: 6)
        },
        // Fussilat 1-36: the sky while it was smoke (41:11); then seven heavens, the nearest
        // adorned with lamps (41:12), over the mountains set firm on the earth (41:10).
        make("p41-lamps-of-heaven") { p in
            p.at(p.width / 2)
            p.peak(-150, 170, 62, lean: -5); p.peak(132, 190, 104, lean: 5)
            p.smokeBand(at: 132)
            p.tent(-20, 44, 29); p.palm(24, 50)
            // The lamps of the nearest heaven, hung in rows.
            p.stars([(-40, 150), (0, 150), (40, 150), (80, 150), (-60, 172), (-20, 172), (20, 172), (60, 172), (100, 172),
                     (-40, 194), (0, 194), (40, 194), (80, 194)], size: 1.6)
            p.mist(from: -p.width / 2, to: p.width / 2, at: 7)
        },
        // Ash-Shura 1-31: whoever wants the harvest of the life to come is given increase in his
        // harvest (42:20).
        make("p42-harvest") { p in
            p.at(p.width / 2)
            p.greenField(from: -p.width / 2, to: p.width / 2, ripeness: 0.85)
            p.grain(from: -20, to: p.width / 2)
            // Sheaves cut and stood up to dry.
            for x in [-170, -140, -110, -76, -48] as [CGFloat] {
                let x = max(x, 8 - p.width / 2)
                let sheaf = p.polygon([(x - 6, 0), (x + 6, 0), (x + 1.6, 10), (x + 5.4, 18), (x - 5.4, 18), (x - 1.6, 10)])
                p.add(sheaf); p.tint(sheaf, p.shade(0.88, 0.72, 0.36, 0.82))
                p.tint(p.blockPath(x, 5, 1.4, from: 9.3), Color.black.opacity(0.3))
            }
            p.at(96)
            p.house(-26, 46, 27)
            p.hearthSmoke(-34, 29)
            p.tree(40, 74); p.palm(-84, 62)
        },
        // Az-Zukhruf 46-89: Pharaoh's cry to his people: "is the kingdom of Egypt not mine, and
        // these rivers running beneath me?" (43:51).
        make("p43-rivers-of-egypt", backdrop: .open) { p in
            p.at(p.width / 2)
            p.tint(p.polygon([(-p.width / 2, 0), (p.width / 2, 0), (p.width / 2, -46), (-p.width / 2, -46)]),
                   p.shade(0.36, 0.30, 0.22, 0.38))
            let rivers: [(CGFloat, CGFloat, SkylinePen.RiverCourse)] = [
                (33, -44, .bendLeft), (95, 95, .meander), (157, 240, .bendRight)
            ]
            for (far, near, course) in rivers {
                p.river(from: far, to: near, width: 58, naturalBanks: true, course: course)
            }
            p.at(106)
            // The palace on its terrace above them.
            p.block(0, 176, 13); p.block(0, 182, 1.6, from: 13)
            p.set(106, rise: 14.6) { q in
                q.tower(-44, 74); q.tower(44, 74)
                q.arcade(0, bays: 9, bay: 16, height: 34)
            }
            p.palm(-106, 84); p.palm(98, 74)
            p.reeds(-150, count: 6)
        },
        // Qaf 36-45: praise before the sun rises and before it sets, and in the night, and after
        // the prostrations (50:39-40).
        make("p50-before-sunrise", backdrop: .open) { p in
            p.at(p.width / 2)
            p.dunes([(-150, 110, 20), (176, 90, 26)])
            p.horizonLight(-36, spread: 220)
            p.driftingSand(from: -p.width / 2, to: p.width / 2, height: 12)
            p.at(100)
            p.prayerNiche(0, scale: 1.6)
            p.palm(-68, 62); p.palm(64, 50)
            p.stars([(-150, 150), (-110, 172), (-60, 156), (-20, 178), (60, 160)], size: 1.3)
        },
        // Adh-Dhariyat 15-60: gardens and springs (51:15); they slept little of the night, and
        // before dawn they asked forgiveness (51:17-18).
        make("p51-gardens-at-dawn") { p in
            p.at(p.width / 2)
            p.horizonLight(-80, spread: 180)
            p.at(104)
            p.spring(-70, scale: 2.5)
            p.tree(16, 96, spread: 74)
            p.hangingLantern(-20, from: 52, drop: 16, scale: 1.2)
            p.palm(76, 66); p.palm(-128, 58); p.fig(-180, 30)
            p.flowers(from: -44, to: 60)
        },
        // At-Tur 29-49: praise when you rise, and in the night, and at the setting of the stars
        // (52:48-49).
        make("p52-setting-stars", backdrop: .open) { p in
            p.at(p.width / 2)
            p.dunes([(-140, 120, 26), (160, 100, 18)])
            p.horizonLight(50, spread: 210)
            // The stars low in the sky, going down.
            p.stars([(-170, 46), (-128, 62), (-90, 42), (-52, 70), (-14, 50), (24, 74), (60, 48), (100, 66), (140, 44), (176, 60),
                     (-110, 98), (-30, 106), (44, 100), (120, 96)], size: 1.5)
            p.at(108)
            p.tent(4, 62, 41); p.tent(-52, 38, 25)
            p.campfire(56, 0, scale: 1.3)
            p.palm(-96, 54)
        },
        // An-Najm 33-62: 'Ad the first, and Thamud, none of them left; and the overturned towns,
        // brought down (53:50-53).
        make("p53-overturned-towns") { p in
            p.at(p.width / 2)
            p.crackedGround(from: -p.width / 2, to: p.width / 2)
            p.at(100)
            p.ruins(20, scale: 1.1)
            // A tower thrown down, lying where it fell.
            p.set(190, rise: 11, lean: 1.42) { q in q.tower(0, 96) }
            p.driftingSand(from: -302, to: 100, height: 18)
            p.stars([(-150, 140), (-110, 164), (-70, 146), (-30, 172), (40, 150), (80, 174)], size: 1.3)
        },
        // Al-Waqi'a 1-56: for those of the right hand: lote-trees without thorns, acacias in
        // tiers, shade spread wide, water kept pouring (56:27-31).
        make("p56-shade-and-water") { p in
            p.at(104)
            p.cliff(-128, 84, 58)
            // Water poured from the rock into a softly banked pool at its foot.
            p.tint(p.smoothPath([(-132, 57), (-123, 57), (-123, 41), (-121, 22), (-120, 2),
                                 (-136, 2), (-135, 22), (-134, 41)]), p.shade(0.62, 0.82, 0.92, 0.78))
            for index in 0..<6 {
                let run = CGFloat((Double(index) / 6 + p.time * 0.5).truncatingRemainder(dividingBy: 1))
                p.tint(p.blockPath(-133 + CGFloat(index % 3) * 4.6, 1.3, 8, from: 49 - run * 48), Color.white.opacity(0.5 * (1 - 0.4 * p.night)))
            }
            p.tint(p.smoothPath([(-166, 0), (-90, 0), (-77, -7), (-92, -15), (-164, -15), (-179, -7)]),
                   p.shade(0.37, 0.40, 0.27, 0.38))
            p.tint(p.smoothPath([(-160, 0), (-96, 0), (-84, -8), (-98, -12), (-158, -12), (-172, -8)]),
                   p.shade(0.20, 0.50, 0.64, 0.86))
            p.tint(p.polygon([(-140, -1), (-128, 1.2), (-116, -1), (-128, -3.2)]), Color.white.opacity(0.4 * (0.6 + 0.4 * sin(p.time * 2.2))))
            p.greatTree(10, 106)
            p.tree(-64, 54); p.fig(86, 30)
            p.flowers(from: -80, to: 70)
            p.stars([(-150, 146), (-110, 168), (-70, 150), (-180, 172)], size: 1.3)
        },
        // Al-Haqqa 19-52: a garden raised high, its clusters hanging within reach (69:22-23).
        make("p69-lofty-garden") { p in
            p.at(112)
            p.cliff(4, 172, 52)
            p.set(112, rise: 51) { q in
                // Keep every trunk on the flat top of the cliff; leave space
                // at its left edge for the fig alongside the trellis.
                q.vines(-18, bays: 3); q.palm(34, 60); q.palm(58, 42); q.fig(-55, 26)
            }
            p.house(-146, 24, 14)
            p.palm(-172, 42)
            p.flowers(from: -230, to: -190)
            p.stars([(-150, 140), (-110, 166), (-180, 172), (-50, 176)], size: 1.3)
        },
        // Al-Ma'arij 36-44: "I swear by the Lord of the risings and the settings" (70:40).
        make("p70-east-and-west", backdrop: .open, ownMoon: true) { p in
            p.at(p.width / 2)
            p.dunes([(-30, 150, 20)])
            p.horizonLight(150, spread: 180)
            p.sun(150, 18, 15)
            p.crescent(-150, 34, 9)
            p.driftingSand(from: -p.width / 2, to: p.width / 2, height: 12)
            p.palm(-4, 78); p.palm(22, 54)
            p.tent(64, 40, 26)
            p.stars([(-176, 70), (-120, 92), (-90, 56), (-50, 100)], size: 1.3)
        },
        // Al-Muddaththir 38-56: each of them wants to be handed pages spread open; no: it is a
        // reminder (74:52-54).
        make("p74-open-scrolls") { p in
            p.at(112)
            p.palm(84, 62); p.palm(-160, 50)
            p.tent(-112, 42, 27)
            p.pages(0, scale: 2.6)
            p.descendingLight(over: 0, spread: 130)
            p.stars([(-150, 140), (-110, 164), (-70, 146), (70, 160)], size: 1.3)
        },
        // Al-Qiyama 16-40: "do not hurry your tongue with it: its gathering and its recital rest
        // with Us" (75:16-19).
        make("p75-recital") { p in
            p.at(118)
            p.peak(-126, 140, 54, lean: -4)
            p.peak(8, 196, 118, lean: 6)
            // The cave near the summit where the words first came down, a lamp in it.
            p.window(-4, 14, 11, from: 76, pointed: false)
            p.detail(p.polygon([(-18, 75), (10, 75), (14, 77), (-22, 77)]), strength: 0.9)
            p.descendingLight(over: 0, spread: 150)
            p.palm(-84, 36)
            p.mist(from: -284, to: 118, at: 8)
        },
        // An-Naba 31-40: for the mindful, a place of triumph: walled gardens and grapevines, and
        // a cup filled to the brim (78:31-34).
        make("p78-gardens-and-vines") { p in
            p.at(108)
            p.palm(-176, 74); p.tree(76, 80); p.palm(-36, 96)
            p.stoneWall(-176, 96, 24)
            p.set(128, scale: 1.85) { q in q.vines(0, bays: 3) }
            p.vessels(-116, scale: 1.2)
            p.flowers(from: 48, to: 100)
            p.stars([(-150, 142), (-110, 166), (-70, 150), (60, 170)], size: 1.3)
        },
        // An-Nazi'at 27-46: the earth spread out, its water and its pasture brought out of it,
        // the mountains made fast: provision for you and for your herds (79:30-33).
        make("p79-earth-spread") { p in
            p.at(p.width / 2)
            p.peak(-160, 150, 54, lean: -5); p.peak(136, 190, 110, lean: 6)
            // Leave a feathered opening for the winding river rather than
            // continuing crop rows through its water and banks.
            p.greenField(from: -p.width / 2, to: -6, bankFade: 14, perspectiveOrigin: 126)
            p.greenField(from: 18, to: p.width / 2, leftFade: 14, perspectiveOrigin: 46)
            p.river(from: 6, to: -40, width: 84, naturalBanks: true)
            p.spring(-52, scale: 1.9)
            p.tent(54, 40, 26)
            p.tree(-110, 46)
            p.flowers(from: 80, to: 150)
            p.stars([(-40, 150), (0, 174), (40, 156), (-80, 170)], size: 1.3)
        }
    ]
}
