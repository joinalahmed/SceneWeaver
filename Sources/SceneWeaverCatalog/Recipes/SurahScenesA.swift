import SwiftUI
import SceneWeaver

private extension SkylinePen {
    /// Draws pieces standing `rise` above the ground, as on a summit or a ledge.
    /// `still` holds them motionless: a thing come to rest.
    mutating func raised(_ fromRight: CGFloat, by rise: CGFloat, still: Bool = false, _ draw: (inout SkylinePen) -> Void) {
        var high = SkylinePen(width: width, horizon: horizon - rise, time: still ? 0 : time, night: night, clockDate: clockDate, quranScene: quranScene)
        high.at(fromRight)
        draw(&high)
        for path in high.solids { add(path) }
        for path in high.holes { add(path, .hole) }
        for path in high.lights { add(path, .light) }
        for part in high.tints { tint(part.path, part.color, nightOnly: part.nightOnly) }
    }
}

/// Scenes for surahs 1 to 29. See `SurahScenes`.
extension SurahScenes {
    static let partA: [Int: [Cityscape]] = [
        // Al-Fatiha: the straight path (1:6), a road running towards first light.
        1: [
            make("a01-straight-path", backdrop: .open) { p in
                p.at(p.width / 2)
                p.dunes([(-150, 100, 16), (176, 70, 12)])
                p.horizonLight(70, spread: 210)
                p.road(to: 70, from: 46, width: 46)
                p.at(p.width / 2 - 70)
                p.palm(42, 78); p.palm(60, 52); p.palm(-48, 46)
                p.house(-108, 22, 13)
                p.stars([(-70, 150), (-36, 172), (-4, 158), (30, 178), (62, 150), (84, 168)], size: 1.3)
            }
        ],
        // Al-Baqara: Madinah's oasis under the new crescent (2:189); or the garden on
        // high ground that heavy rain falls on (2:265).
        2: [
            make("a02-oasis-crescent", ownMoon: true) { p in
                p.at(p.width / 2)
                p.water(from: -p.width / 2, to: p.width / 2, depth: 38)
                p.at(112)
                p.house(-34, 32, 19); p.house(-66, 22, 13)
                p.palm(36, 88); p.palm(54, 60); p.palm(76, 46); p.palm(-96, 72); p.palm(-114, 50); p.palm(-8, 44)
                p.reeds(-158, count: 9); p.reeds(84, count: 6)
                p.hearthSmoke(-40, 21)
                p.crescent(-30, 148, 10)
            },
            make("a02-garden-on-height") { p in
                p.at(116)
                p.cliff(0, 176, 42)
                p.raised(116, by: 41) { q in
                    q.olive(-42, 46); q.fig(6, 34); q.palm(42, 58); q.palm(-14, 44)
                }
                p.house(-132, 22, 13)
                p.grain(from: -176, to: -146)
                p.at(p.width / 2)
                p.rain(from: -p.width / 2, to: p.width / 2 + 30)
            }
        ],
        // Aal-Imran: Mount Uhud above Madinah's palms (3:121); or the prayer niche
        // where Maryam was kept (3:37).
        3: [
            make("a03-uhud", backdrop: .open) { p in
                p.at(120)
                p.uhud(10, scale: 1.0)
                p.palm(-92, 78); p.palm(-110, 60); p.palm(-132, 46); p.palm(-166, 62); p.palm(-184, 40)
                p.house(-148, 20, 12)
                p.hearthSmoke(-152, 14)
                p.grain(from: -70, to: 30)
                p.stars([(-170, 124), (-136, 148), (-100, 130), (-64, 156), (-20, 136), (30, 160), (70, 134)], size: 1.3)
            },
            make("a03-mihrab") { p in
                p.at(106)
                p.stoneWall(-94, 110, 22)
                p.olive(-116, 56)
                p.prayerNiche(0, scale: 1.7)
                p.palm(72, 54)
                p.stars([(-120, 130), (-84, 152), (-50, 136), (56, 150), (80, 128), (-14, 168)], size: 1.3)
            }
        ],
        // An-Nisa: the homes of Madinah, their windows lit.
        4: [
            make("a04-homes") { p in
                p.at(114)
                p.town(-8, houses: 7, scale: 1.5)
                p.house(-108, 30, 18); p.house(80, 22, 14)
                p.palm(-80, 62); p.palm(58, 72); p.palm(-140, 46)
                p.hearthSmoke(-112, 20); p.hearthSmoke(-4, 40)
            }
        ],
        // Al-Ma'ida: a spread table (5:114) under the evening sky, a lantern over it.
        5: [
            make("a05-table") { p in
                p.at(130)
                p.tree(72, 96, spread: 72)
                p.table(-30, scale: 2.3)
                p.hangingLantern(30, from: 52, drop: 18, scale: 1.1)
                p.flowers(from: -160, to: -100)
                p.stars([(-130, 138), (-92, 164), (-52, 144), (-16, 172), (20, 140)], size: 1.3)
            }
        ],
        // Al-An'am: open pasture; a star, then the moon, then the sun (6:76-78).
        6: [
            make("a06-pasture-signs", backdrop: .open, ownMoon: true) { p in
                p.at(p.width / 2)
                p.hills(seed: 6, height: 14)
                p.greenField(from: -p.width / 2, to: p.width / 2)
                p.at(112)
                p.tent(-44, 44, 29); p.tent(-86, 30, 20)
                p.tree(50, 58)
                p.grazingSheep(-142, scale: 0.72); p.grazingSheep(-121, scale: 0.60)
                p.flowers(from: -18, to: 24)
                p.brightStar(-74, 124); p.crescent(-10, 146, 9); p.sun(56, 164, 13)
            }
        ],
        // Al-A'raf: the Heights (7:46), a high ridge standing between two valleys.
        7: [
            make("a07-heights") { p in
                p.at(128)
                p.peak(-4, 176, 70)
                p.cliff(-4, 96, 104)
                p.tree(-96, 36); p.tree(-124, 28); p.palm(-146, 46)
                p.spring(-66, scale: 1.3)
                p.house(-172, 20, 12)
                p.bareTree(72, 40); p.bareTree(102, 26)
                p.mist(from: -270, to: 128, at: 6)
                p.stars([(-120, 140), (-80, 160), (60, 150), (96, 128), (-44, 176)], size: 1.3)
            }
        ],
        // Al-Anfal: the wells and dunes of Badr at dawn; or the two camps, one on
        // the near bank of the valley and one on the far (8:42).
        8: [
            make("a08-badr", backdrop: .open) { p in
                p.at(p.width / 2)
                p.horizonLight(-46, spread: 220)
                p.dunes([(-150, 110, 30), (190, 70, 30)])
                p.driftingSand(from: -p.width / 2, to: p.width / 2)
                p.at(104)
                p.well(-8, scale: 2.0)
                p.well(-74, scale: 1.3)
                p.palm(36, 70); p.palm(54, 48)
                p.tent(-150, 30, 20)
            },
            make("a08-two-banks", backdrop: .open) { p in
                p.at(p.width / 2)
                p.dunes([(-170, 70, 20), (200, 80, 24)])
                p.driftingSand(from: -p.width / 2, to: p.width / 2, height: 20)
                p.at(108)
                p.tent(8, 56, 38); p.tent(-42, 40, 27); p.tent(56, 38, 25)
                p.banner(-18, 72, p.shade(0.92, 0.90, 0.84))
                p.tent(-148, 26, 17); p.tent(-176, 20, 13)
                p.campfire(-100, 0, scale: 1.1)
            }
        ],
        // At-Tawba: the long road to Tabuk under a midday sun (9:81); or the mosque
        // founded on piety from its first day, among Quba's palms (9:108).
        9: [
            make("a09-tabuk-road", backdrop: .open) { p in
                p.at(p.width / 2)
                p.dunes([(-160, 90, 18)])
                p.road(to: 16, from: -64, width: 46)
                p.driftingSand(from: -p.width / 2, to: p.width / 2, height: 20)
                p.at(98)
                p.cliff(6, 116, 60)
                p.bareTree(88, 30)
                p.tent(-126, 32, 21); p.tent(-154, 24, 16)
                p.sun(-44, 164, 15)
            },
            make("a09-quba") { p in
                p.at(112)
                p.mosque(-4, scale: 1.25)
                p.palm(-72, 64); p.palm(-90, 46); p.palm(66, 56); p.palm(84, 40)
                p.grain(from: -170, to: -104)
                p.stars([(-130, 136), (-96, 160), (-58, 142), (-20, 170), (74, 132)], size: 1.3)
            }
        ],
        // Yunus: a ship on a dark sea under the stars (10:22).
        10: [
            make("a10-ship", backdrop: .open) { p in
                p.at(p.width / 2)
                p.water(from: -p.width / 2, to: p.width / 2, depth: 46)
                p.at(118)
                p.constellations(over: -96, height: 180)
                p.ship(0, scale: 1.2)
                p.at(p.width / 2)
                p.waves(from: -p.width / 2, to: p.width / 2, height: 9)
            }
        ],
        // Hud: the ark come to rest on Mount Judi as the water falls (11:44).
        11: [
            make("a11-judi", backdrop: .open) { p in
                p.at(p.width / 2)
                p.water(from: -p.width / 2, to: p.width / 2, depth: 46)
                p.island(-146, 110, 28)
                p.at(118)
                p.peak(-32, 196, 60, lean: -4); p.peak(36, 186, 58, lean: 4)
                // The saddle between the two heads, where she lies.
                p.add(p.ridgePath([(-44, 38), (-22, 58), (2, 61), (26, 58), (46, 38)], base: 30))
                p.raised(118, by: 64, still: true) { q in q.ark(0) }
                p.mist(from: -270, to: 118, at: 5)
            }
        ],
        // Ar-Ra'd: thunder and lightning over the hills (13:12-13); or tracts side by
        // side, vines, grain and palms, all watered with one water (13:4).
        13: [
            make("a13-thunder") { p in
                p.at(p.width / 2)
                p.hills(seed: 13, height: 18)
                p.at(112)
                p.house(-64, 32, 22)
                p.tree(40, 46); p.tree(70, 32)
                p.stormCloud(-6, 128, 190)
                p.rain(from: -100, to: 96, height: 126)
            },
            make("a13-tracts", rtlPlacement: .preserve) { p in
                p.at(p.width / 2)
                let half = p.width / 2
                // The same moving water can meet cultivated ground naturally
                // here while other scenes retain the river's original banks.
                p.greenField(from: -half, to: -6, ripeness: 0.2, bankFade: 22)
                p.river(from: 10, to: 6, width: min(84, p.width * 0.23), naturalBanks: true, course: .bendRight)
                p.house(-min(124, half - 34), 28, 16)
                p.olive(-min(60, half - 30), 42)
                p.grain(from: -half + 5, to: -22)
                p.vines(min(100, half - 45), bays: 3)
                p.palm(min(52, half - 60), 58)
                p.palm(min(152, half - 40), 66); p.palm(min(166, half - 24), 46)
            }
        ],
        // Ibrahim: the barren valley by the Sacred House (14:37), and a good tree,
        // its root firm and its branches in the sky (14:24).
        14: [
            make("a14-valley-tree") { p in
                p.at(116)
                p.peak(-214, 130, 54, lean: -4)
                p.kaaba(-100, 1.0)
                p.tent(-140, 24, 16)
                p.greatTree(8, 100)
                p.driftingSand(from: -290, to: 116, height: 16)
                p.stars([(-170, 128), (-132, 150), (-100, 132), (-150, 170)], size: 1.3)
            }
        ],
        // Al-Hijr: dwellings carved into the rock (15:82), under a guarded sky (15:16-18).
        15: [
            make("a15-hijr") { p in
                p.at(118)
                p.cliff(0, 204, 100)
                // Doorways cut in the face, a stepped lintel over each; lamps within two of them after dark.
                for (x, w, h, lit) in [(-62.0, 11.0, 24.0, false), (-26, 13, 32, true), (14, 15, 40, true), (54, 12, 28, false)] as [(CGFloat, CGFloat, CGFloat, Bool)] {
                    if lit { p.window(x, w, h, from: 0, pointed: false) } else { p.tint(p.archPath(x, w, h, pointed: false), Color.black.opacity(0.34)) }
                    p.detail(p.blockPath(x, w + 9, 1.2, from: h + 3), strength: 0.9)
                    p.detail(p.blockPath(x, w + 5, 1.2, from: h + 5.6), strength: 0.75)
                    p.detail(p.blockPath(x, w + 1, 1.2, from: h + 8.2), strength: 0.6)
                }
                for (x, y) in [(-44.0, 54.0), (-6, 66), (36, 64), (70, 52)] as [(CGFloat, CGFloat)] { p.window(x, 5, 8, from: y) }
                p.palm(-136, 52); p.palm(-154, 36)
                p.stars([(-150, 120), (-116, 146), (-70, 128), (-30, 156), (20, 134), (64, 160), (92, 126)], size: 1.3)
                p.shootingStars(over: -60)
            }
        ],
        // An-Nahl: hives in the mountainside (16:68), above blossom.
        16: [
            make("a16-hives") { p in
                p.at(114)
                p.peak(14, 196, 118, lean: 6)
                p.cliff(-34, 124, 44)
                p.hives(-34, 44, count: 5)
                p.sceneBees(over: -34, height: 66)
                p.tree(-126, 42)
                p.house(-158, 20, 12)
                p.flowers(from: -112, to: 40)
                p.stars([(-150, 130), (-110, 156), (-74, 134), (-90, 176)], size: 1.3)
            }
        ],
        // Al-Isra: night, and Al-Aqsa on the horizon (17:1).
        17: [
            make("a17-aqsa") { p in
                p.at(110)
                p.aqsa(-2, scale: 1.1)
                p.olive(-140, 46); p.olive(-168, 32)
                p.stars([(-140, 126), (-104, 150), (-66, 132), (-30, 164), (8, 140), (44, 170), (80, 136)], size: 1.4)
                p.shootingStars(over: -60)
            }
        ],
        // Maryam: a palm beside a stream (19:23-25), far from the town.
        19: [
            make("a19-palm-stream") { p in
                p.at(p.width / 2)
                // The stream has natural banks so its water meets the soil and
                // reeds softly, as it does in the adjacent-tracts scene.
                p.river(from: 58, to: 24, width: min(84, p.width * 0.25), naturalBanks: true, course: .bendLeft)
                p.at(104)
                p.palm(6, 116)
                p.reeds(-70, count: 9); p.reeds(-26, count: 6)
                p.flowers(from: 22, to: 62)
                p.town(-156, houses: 3, scale: 0.7)
                p.stars([(-120, 134), (-84, 158), (-48, 140), (52, 150), (80, 126)], size: 1.3)
            }
        ],
        // Ta-Ha: a fire at the foot of Mount Tur, in the valley of Tuwa (20:10-12).
        20: [
            make("a20-tuwa-fire") { p in
                p.at(108)
                p.peak(34, 196, 120, lean: -8)
                p.peak(-176, 150, 50)
                p.tree(-116, 24)
                p.campfire(-86, 0, scale: 2.2)
                p.stars([(-150, 128), (-118, 152), (-84, 136), (-56, 166), (-170, 160)], size: 1.3)
            }
        ],
        // Al-Anbiya: a line of lamps along a night valley, one after another.
        21: [
            make("a21-lamps") { p in
                p.at(p.width / 2)
                p.peak(-186, 170, 54); p.peak(176, 190, 88, lean: -6)
                p.lampLine(from: -150, to: 140, count: 9)
                p.mist(from: -p.width / 2, to: p.width / 2, at: 5)
                p.stars([(-20, 150), (20, 172), (56, 142), (90, 166), (-52, 132)], size: 1.3)
            }
        ],
        // Al-Hajj: the Kaaba and the tents of Mina (22:26-28); or an abandoned well
        // and a lofty palace, left standing (22:45).
        22: [
            make("a22-kaaba-mina") { p in
                p.at(112)
                p.peak(-150, 150, 56, lean: -4); p.peak(96, 120, 72)
                p.kaaba(6, 1.9)
                p.tentCamp(-96, count: 9)
                p.hearthSmoke(-118, 16); p.hearthSmoke(-70, 14)
                p.stars([(-130, 132), (-92, 156), (-54, 138), (-20, 166), (30, 140)], size: 1.3)
            },
            make("a22-abandoned-well", backdrop: .open) { p in
                p.at(p.width / 2)
                p.dunes([(-150, 100, 20)])
                p.driftingSand(from: -p.width / 2, to: p.width / 2, height: 18)
                p.at(108)
                p.ruins(-62, scale: 0.9)
                p.well(4, scale: 1.7, abandoned: true)
                p.tower(56, 104)
                p.bareTree(88, 30)
                p.stars([(-140, 128), (-100, 152), (-60, 134), (-20, 160), (16, 138)], size: 1.3)
            }
        ],
        // Al-Mu'minun: an olive tree issuing from Mount Sinai, and gardens of palms
        // and vines (23:19-20).
        23: [
            make("a23-olive-sinai") { p in
                p.at(120)
                p.peak(-146, 170, 62, lean: -5)
                p.palm(-78, 58); p.palm(-60, 40)
                p.vines(-30, bays: 2)
                p.olive(36, 102)
                p.house(86, 18, 11)
                p.stars([(-130, 130), (-96, 154), (-60, 136), (-30, 166)], size: 1.3)
            }
        ],
        // Al-Furqan: two seas, one sweet and one salt, a barrier between them (25:53),
        // under the great stars set in the sky (25:61).
        25: [
            make("a25-two-seas", backdrop: .open) { p in
                p.at(p.width / 2)
                p.constellations(over: 40, height: 178)
                p.twoSeas(meetAt: 16)
                p.island(140, 150, 58); p.island(-160, 90, 18)
                p.boat(-70, scale: 1.7); p.boat(44, scale: 1.1)
            }
        ],
        // Ash-Shu'ara: the sea parted at sunrise, a dry path between walls of water
        // (26:60-63); or the strongholds built on every height (26:128-129).
        26: [
            make("a26-parted-sea", backdrop: .open) { p in
                p.at(120)
                p.horizonLight(0, spread: 110)
                p.partedSea(0, gap: 46, height: 86)
                p.stars([(-150, 140), (-110, 165), (-70, 150), (-30, 172), (0, 150), (70, 160), (100, 140)], size: 1.3)
            },
            make("a26-heights") { p in
                p.at(116)
                p.cliff(-126, 72, 24)
                p.raised(116, by: 23) { q in q.tower(-126, 38) }
                p.cliff(10, 150, 56)
                p.raised(116, by: 55) { q in q.fortress(10, 80, 22) }
                p.driftingSand(from: -290, to: 116, height: 18)
                p.stars([(-150, 126), (-110, 150), (-70, 132), (-90, 172), (-40, 160)], size: 1.3)
            }
        ],
        // An-Naml: the Valley of the Ants, a wide valley floor (27:18); or the court
        // paved with glass, taken for a pool (27:44).
        27: [
            make("a27-valley-ants") { p in
                p.at(p.width / 2)
                p.peak(-196, 150, 50); p.peak(190, 170, 78, lean: -6)
                p.anthills(from: -120, to: 104)
                p.tree(86, 52)
                p.tent(44, 28, 19)
                p.driftingSand(from: -p.width / 2, to: p.width / 2, height: 14)
                p.stars([(-40, 140), (0, 166), (40, 146), (80, 172), (120, 138)], size: 1.3)
            },
            make("a27-glass-court", backdrop: .open) { p in
                p.at(p.width / 2)
                p.water(from: -p.width / 2, to: p.width / 2, depth: 40)
                p.at(112)
                p.arcade(-74, bays: 6, bay: 15, height: 30)
                p.gate(20, 86)
                p.palm(78, 58); p.palm(-140, 48)
                p.stars([(-130, 130), (-94, 154), (-58, 136), (-76, 174)], size: 1.3)
            }
        ],
        // Al-Qasas: the well of Madyan, and the shade beside it (28:23-24).
        28: [
            make("a28-madyan-well") { p in
                p.at(112)
                p.tree(44, 100, spread: 76)
                p.well(-36, scale: 2.2)
                p.tree(-100, 52)
                p.house(-146, 26, 15)
                p.hearthSmoke(-150, 17)
                p.stars([(-150, 130), (-112, 154), (-76, 136), (-40, 162), (-8, 140)], size: 1.3)
            }
        ],
        // Al-Ankabut: a web strung with dew at dawn, the frailest of houses (29:41).
        29: [
            make("a29-web") { p in
                p.at(p.width / 2)
                p.horizonLight(-20, spread: 200)
                p.at(114)
                p.web(0, 64, radius: 40)
                p.reeds(-84, count: 8); p.reeds(60, count: 5)
                p.flowers(from: -40, to: 40)
                p.house(-140, 24, 14)
            }
        ]
    ]
}
