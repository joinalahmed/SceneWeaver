import SwiftUI
import SceneWeaver

/// Scenes for surahs 87 to 114. See `SurahScenes`.
extension SurahScenes {
    static let partD: [Int: [Cityscape]] = [
        // Al-A'la: the pasture He brings out green, then turns to dark stubble (87:4-5).
        87: [
            make("d87-pasture") { p in
                p.at(p.width / 2)
                let half = p.width / 2, boundary = -half * 0.58
                // All three stages share one vanishing point and overlap only
                // at feathered borders, so their rows meet as one pasture.
                p.greenField(from: -36, to: half, ripeness: 0, leftFade: 12, perspectiveOrigin: 0)
                p.greenField(from: boundary - 6, to: -24, ripeness: 0.5,
                             bankFade: 12, leftFade: 12, perspectiveOrigin: 0)
                p.greenField(from: -half, to: boundary + 6, ripeness: 1,
                             bankFade: 12, perspectiveOrigin: 0)
                p.house(-66, 26, 15)
                p.hearthSmoke(-72, 17)
                p.bareTree(max(-152, -half + 32), 40)
                p.at(100)
                p.tree(-8, 70); p.tree(56, 44)
                p.flowers(from: -70, to: 92)
            }
        ],
        // Al-Ghashiya: the sky raised high, the mountains set firm, the earth spread out (88:18-20);
        // or the garden's flowing spring and the cups set ready beside it (88:12-14).
        88: [
            make("d88-signs", backdrop: .open) { p in
                p.at(p.width / 2)
                p.road(to: -41, from: -110, width: 30)
                p.driftingSand(from: -p.width / 2, to: p.width / 2, height: 14)
                p.at(108)
                p.peak(-44, 130, 74, lean: -5)
                p.peak(30, 170, 124, lean: 6)
                p.tent(-152, 28, 19); p.tent(-122, 20, 14)
                p.campfire(-96, 0, scale: 0.9)
                p.stars([(-150, 152), (-98, 178), (-44, 194), (-8, 166), (70, 186)], size: 1.3)
            },
            make("d88-garden") { p in
                p.at(108)
                p.tree(-146, 48)
                p.flowers(from: -170, to: -116)
                // A lantern on its post beside the cups.
                p.block(-108, 1.6, 47)
                p.line([(-108, 46), (-104, 51), (-98, 50)], 1.2, smooth: true)
                p.hangingLantern(-98, from: 50, drop: 13)
                p.vessels(-66)
                p.spring(8, scale: 3.4)
                p.palm(74, 92)
                p.flowers(from: 62, to: 100)
            }
        ],
        // Al-Balad: this city, Makkah, and the steep pass that climbs out of it (90:1-2, 90:11);
        // or what the climb is: food set out on a day of hunger (90:12-16).
        90: [
            make("d90-pass") { p in
                p.at(112)
                p.peak(6, 150, 96, lean: -6)
                p.peak(66, 130, 118, lean: 5)
                // The way up, winding over the near mountain to the notch between the two.
                p.tint(p.strokePath([(-50, 3), (-22, 13), (-30, 25), (2, 34), (-6, 46), (24, 53), (37, 61)], 1.8, smooth: true),
                       p.shade(0.78, 0.66, 0.48, 0.6))
                p.kaaba(-90, 0.8)
                p.town(-140, houses: 4, scale: 0.85)
                p.hearthSmoke(-146, 22)
                p.mist(from: -230, to: 112)
                p.shootingStars(over: -80)
            },
            make("d90-feeding") { p in
                p.at(112)
                p.house(56, 58, 38)
                p.hearthSmoke(44, 40)
                p.table(-38, scale: 1.9)
                p.palm(-116, 58); p.palm(-142, 40)
                p.shootingStars(over: -80)
            }
        ],
        // Ash-Shams: the sun in its morning brightness over the earth spread wide; after dark
        // the moon follows in its place (91:1-6).
        91: [
            make("d91-sun", backdrop: .open) { p in
                p.at(p.width / 2)
                p.dunes([(-150, 100, 18), (190, 70, 14)])
                p.at(80)
                p.sun(0, 140, 20)
                p.at(124)
                p.palm(-30, 72); p.palm(-4, 56); p.palm(-58, 48)
                p.spring(-98, scale: 2.2)
                p.stars([(-160, 150), (-112, 176), (-66, 160), (-20, 188), (92, 180)], size: 1.3)
            }
        ],
        // Ash-Sharh: the storm drawing off and the light breaking after it: with hardship comes ease (94:5-6).
        94: [
            make("d94-relief") { p in
                p.at(p.width / 2)
                p.road(to: 104, from: -30, width: 30)
                p.stormCloud(-20, 152, 150, lightning: false)
                p.rain(from: -100, to: 56, height: 152)
                p.sun(120, 150, 18)
                p.bareTree(-84, 46)
                p.house(64, 30, 18)
                p.hearthSmoke(58, 20)
                p.tree(min(152, p.width / 2 - 30), 58)
                p.flowers(from: 84, to: min(196, p.width / 2 - 4))
            }
        ],
        // At-Tin: the fig and the olive, and Mount Sinai (95:1-2); or this city made secure, Makkah (95:3).
        95: [
            make("d95-sinai") { p in
                p.at(120)
                p.peak(42, 150, 122, lean: 6)
                p.olive(-72, 66)
                p.fig(-138, 44)
                p.mist(from: -240, to: 120, at: 8)
                p.stars([(-150, 150), (-110, 174), (-70, 190), (-28, 166), (96, 170)], size: 1.3)
            },
            make("d95-city") { p in
                p.at(p.width / 2)
                p.road(to: 85, from: 40, width: 36)
                p.at(112)
                p.kaaba(-4, 1.15)
                p.town(-82, houses: 5, scale: 0.9)
                p.town(58, houses: 3, scale: 0.85)
                p.lampLine(from: -40, to: 24, count: 2)
                p.palm(-134, 50); p.palm(-154, 34)
                p.hearthSmoke(-90, 24)
            }
        ],
        // Al-Alaq: the cave of Hira on the Mountain of Light, where the first words came down,
        // and the pen He taught by (96:1-5).
        96: [
            make("d96-hira") { p in
                p.at(104)
                // The mountain: steep shoulders, ledge on ledge, under a blunt head.
                p.curve { path, at in
                    path.move(to: at(-84, 0))
                    path.addQuadCurve(to: at(-52, 30), control: at(-70, 8))
                    path.addLine(to: at(-44, 36))
                    path.addQuadCurve(to: at(-28, 70), control: at(-38, 50))
                    path.addLine(to: at(-20, 74))
                    path.addQuadCurve(to: at(-10, 98), control: at(-16, 86))
                    path.addLine(to: at(-4, 104))
                    path.addQuadCurve(to: at(12, 124), control: at(3, 118))
                    path.addQuadCurve(to: at(30, 108), control: at(22, 124))
                    path.addLine(to: at(36, 98)); path.addLine(to: at(46, 92))
                    path.addQuadCurve(to: at(70, 54), control: at(58, 78))
                    path.addLine(to: at(78, 50))
                    path.addQuadCurve(to: at(112, 0), control: at(98, 22))
                    path.closeSubpath()
                }
                // The cave a little under the summit, the ledges, and the path worn up to it.
                p.cave(12, 90, 12, 9, lit: true)
                p.detail(p.polygon([(-44, 36), (-28, 70), (-26.6, 69), (-42.4, 36)]), strength: 0.8)
                p.detail(p.polygon([(-20, 74), (-10, 98), (-8.8, 97), (-18.6, 74)]), strength: 0.9)
                p.detail(p.polygon([(36, 98), (46, 92), (47, 93.2), (37, 99.4)]), strength: 0.8)
                p.detail(p.polygon([(70, 54), (78, 50), (79, 51.2), (71, 55.4)]), strength: 0.7)
                p.detail(p.strokePath([(-62, 6), (-34, 28), (-22, 54), (-4, 72), (6, 90)], 1.2, smooth: true), strength: 0.7)
                p.penAndInkwell(-130, scale: 0.9)
                p.palm(-94, 36)
                p.mist(from: -220, to: 104)
                p.shootingStars(over: -90)
            },
            make("d96-pen") { p in
                p.at(112)
                p.peak(-112, 110, 58, lean: -4)
                p.cave(-114, 39, 7, 5, lit: true)
                p.penAndInkwell(-14, scale: 1.55)
                p.palm(66, 62)
                p.mist(from: -230, to: 112)
                p.stars([(-150, 150), (-104, 176), (-60, 160), (-22, 190), (84, 176)], size: 1.3)
            }
        ],
        // Al-Bayyina: pages kept pure, the clear proof recited from them (98:2-3);
        // or the gardens beneath which rivers run (98:8).
        98: [
            make("d98-pages") { p in
                p.at(112)
                p.arcade(-118, bays: 4, bay: 14, height: 26)
                p.pages(0, scale: 2.3)
                p.palm(74, 70); p.palm(-70, 44)
                p.shootingStars(over: -60)
            },
            make("d98-gardens") { p in
                p.at(p.width / 2)
                let half = p.width / 2
                p.river(from: 24, to: 34, width: min(120, p.width * 0.30), naturalBanks: true, course: .bendRight)
                p.palm(-18, 68); p.palm(-48, 50)
                p.tree(-92, 44)
                p.flowers(from: max(-150, -half + 4), to: 14)
                p.greatTree(min(118, half - 68), 96)
                p.flowers(from: 40, to: half - 4)
                p.stars([(-150, 150), (-100, 176), (-50, 160), (10, 186), (60, 170), (180, 172)], size: 1.3)
            }
        ],
        // Az-Zalzala: the earth shaken with its quake, split, and giving up what it held (99:1-2).
        99: [
            make("d99-quake") { p in
                p.at(p.width / 2)
                p.crackedGround(from: -p.width / 2, to: p.width / 2)
                p.at(112)
                p.ruins(0, scale: 1.25)
                // A lantern left hanging from the broken arch, still swinging.
                p.hangingLantern(24, from: 56, drop: 13)
                p.fallenPalms(-126, count: 1)
                p.shootingStars(over: -70)
            }
        ],
        // Al-Adiyat: sparks struck from the stones, the raid at dawn, the dust raised in its
        // track (100:2-4). The road is empty: no horses are drawn.
        100: [
            make("d100-dust", backdrop: .open) { p in
                p.at(p.width / 2)
                p.dunes([(-130, 100, 14)])
                p.cliff(min(166, p.width / 2 - 46), 92, 66)
                p.horizonLight(46, spread: 120)
                p.road(to: 46, from: -16, width: 44)
                // Dust raised where the road meets the horizon, climbing and thinning as the wind takes it.
                for index in 0..<8 {
                    let part = CGFloat(index) / 7
                    let drift = CGFloat(sin(p.time * 0.3 + Double(index) * 1.3)) * 3
                    let puff = p.crownPath(44 - 84 * part + drift, 4 + 30 * part, 10 + 22 * part, 5 + 10 * part,
                                           lobes: 6, depth: 0.24, seed: index + 3, flat: 0.4)
                    p.tint(puff, p.shade(0.86, 0.74, 0.54, 0.17 - 0.09 * Double(part)))
                }
                // Stones in the road, and the sparks flying off them.
                let stones: [(CGFloat, CGFloat)] = [(39, -6), (30, -13), (14, -20), (22, -26), (0, -31), (12, -38), (-12, -41)]
                for (index, stone) in stones.enumerated() {
                    let size: CGFloat = 1.2 - stone.1 * 0.05
                    let flash = max(0, sin(p.time * 4.6 + Double(index) * 2.3))
                    p.tint(p.crownPath(stone.0, stone.1, size * 1.6, size, lobes: 5, depth: 0.2, seed: index), Color.black.opacity(0.34))
                    p.tint(p.sparklePath(stone.0 + size, stone.1 + size * 1.4, 1.4 + (1.2 + size * 0.5) * CGFloat(flash)),
                           Color(red: 1.0, green: 0.82, blue: 0.46).opacity(0.25 + 0.7 * flash))
                }
                p.driftingSand(from: -p.width / 2, to: p.width / 2, height: 40)
            }
        ],
        // Al-Qari'a: the mountains become like carded wool, and the scales on which deeds
        // weigh heavy or light (101:5-9).
        101: [
            make("d101-scales", backdrop: .open) { p in
                p.at(p.width / 2)
                // Mountains with no weight left in them: heaped like wool, tufts lifting away.
                let heaps: [(CGFloat, CGFloat, CGFloat)] = [(-162, 90, 44), (-94, 116, 72), (-28, 84, 48)]
                for (index, heap) in heaps.enumerated() {
                    let (x, w, h) = heap
                    p.add(p.crownPath(x, 0, w / 2, h * 0.52, lobes: 12, depth: 0.2, seed: 40 + index, flat: 1))
                    p.add(p.crownPath(x + w * 0.04, h * 0.40, w * 0.30, h * 0.36, lobes: 8, depth: 0.22, seed: 50 + index, flat: 0.3))
                    p.add(p.crownPath(x + w * 0.07, h * 0.74, w * 0.15, h * 0.26, lobes: 6, depth: 0.24, seed: 60 + index, flat: 0.3))
                }
                for index in 0..<7 {
                    let rise = (SkylinePen.noise(index, 5) + p.time * 0.02).truncatingRemainder(dividingBy: 1)
                    let across = -196 + 196 * CGFloat(SkylinePen.noise(index, 9)) + CGFloat(rise) * 14
                    let size = 5 + 5 * CGFloat(SkylinePen.noise(index, 11))
                    let tuft = p.crownPath(across, 44 + CGFloat(rise) * 52, size * 1.5, size * 0.8, lobes: 6, depth: 0.26, seed: index)
                    p.tint(tuft, Color.white.opacity(0.16 * sin(rise * Double.pi)))
                }
                p.at(100)
                p.scales(0, 104)
                p.stars([(-150, 160), (-96, 182), (-40, 168), (78, 178)], size: 1.3)
            }
        ],
        // At-Takathur: the graves that end the rivalry for more (102:1-2); or that rivalry
        // itself, each tower built higher than the last (102:1).
        102: [
            make("d102-graves") { p in
                p.at(112)
                p.graves(from: -156, to: 84, count: 13)
                p.bareTree(50, 86)
                p.lampLine(from: -166, to: -166, count: 1)
                p.mist(from: -240, to: 112, at: 9)
            },
            make("d102-rivalry") { p in
                p.at(112)
                p.market(-124, stalls: 2)
                p.tower(-52, 66)
                p.tower(-8, 92)
                p.banner(-8, 98, p.shade(0.72, 0.30, 0.24))
                p.tower(46, 118, unfinished: true)
            }
        ],
        // Al-Asr: the declining day: the shadows lie long, and the hour of prayer is kept (103:1-3).
        103: [
            make("d103-asr", backdrop: .open) { p in
                p.at(116)
                p.sun(88, 32, 13)
                // What stands, and the long shadow each thing throws away from the low sun.
                let shadow = Color.black.opacity(0.30 * (1 - 0.6 * p.night))
                for (x, w, h) in [(-9.0, 78.0, 30.0), (39.0, 6.0, 88.0), (-86.0, 3.0, 58.0), (-118.0, 3.0, 40.0)] as [(CGFloat, CGFloat, CGFloat)] {
                    let reach = h * 1.5, drop = min(44, h * 0.5)
                    p.tint(p.polygon([(x - w / 2, 0), (x + w / 2, 0), (x + w / 2 - reach, -drop), (x - w * 0.7 - reach, -drop)]), shadow)
                }
                p.mosque(0, scale: 1.25)
                p.palm(-86, 58); p.palm(-118, 40)
            }
        ],
        // Al-Humaza: the crushing Fire, closed over them in towering columns (104:4-9).
        104: [
            make("d104-columns", backdrop: .open) { p in
                p.at(p.width / 2)
                p.hills(seed: 104, height: 16)
                p.smokeBand(at: 150)
                p.at(112)
                p.bareTree(-134, 48)
                p.fireColumns(0, count: 5, height: 104)
            }
        ],
        // Quraysh: the House they are bidden to serve, and the roads of the winter and the summer
        // caravans that come home to it (106:1-3). The roads are empty: no camels are drawn.
        106: [
            make("d106-roads") { p in
                p.at(p.width / 2)
                p.road(to: 60, from: -130, width: 36)
                p.road(to: 118, from: 196, width: 36)
                p.driftingSand(from: -p.width / 2, to: p.width / 2, height: 12)
                p.at(112)
                p.kaaba(0, 1.5)
                p.house(-60, 26, 16); p.house(-90, 20, 12)
                p.hearthSmoke(-66, 18)
                // Bare on the winter road, in fruit on the summer one.
                p.bareTree(-140, 38)
                p.palm(60, 58); p.palm(80, 40)
            }
        ],
        // Al-Ma'un: a door kept shut on the one who asks, and beside it a place of prayer
        // kept for show (107:2-7).
        107: [
            make("d107-door") { p in
                p.at(112)
                p.door(32, 50)
                p.prayerNiche(-74, scale: 1.1)
                p.palm(-136, 50)
                p.shootingStars(over: -90)
            }
        ],
        // Al-Kawthar: abundance given: a river running full between its banks (108:1).
        108: [
            make("d108-river") { p in
                p.at(p.width / 2)
                let half = p.width / 2
                p.river(from: 16, to: -10, width: min(250, p.width * 0.62), naturalBanks: true, course: .meander)
                p.reeds(26, count: 8)
                p.palm(min(96, half - 48), 86); p.palm(min(128, half - 27), 62)
                p.tree(-84, 44)
                p.palm(-128, 52)
                p.flowers(from: 50, to: half - 4)
                p.flowers(from: max(-170, -half + 4), to: -24)
                p.stars([(-160, 150), (-110, 174), (-56, 160), (4, 186), (58, 168), (176, 178)], size: 1.3)
            }
        ],
        // Al-Kafirun: two ways parting, each going on to its own end (109:6).
        109: [
            make("d109-paths") { p in
                p.at(p.width / 2)
                p.twoPaths(from: 50)
                p.tent(-24, 28, 19); p.tent(-52, 20, 14)
                p.campfire(-80, 0, scale: 0.8)
                p.palm(-112, 44)
                p.mosque(99, scale: 1.1)
                // Keep the outer palm's trunk in view on narrower phones.
                p.palm(min(168, p.width / 2 - 16), 54); p.palm(38, 34)
            }
        ],
        // An-Nasr: the help of Allah and the opening: the Kaaba at dawn, banners flying (110:1);
        // or the city's gate standing open as they come in, crowd upon crowd (110:2).
        110: [
            make("d110-fath", backdrop: .open) { p in
                p.at(118)
                p.horizonLight(-112, spread: 150)
                p.peak(112, 140, 78, lean: -5)
                p.kaaba(0, 1.8)
                p.tentCamp(-112, count: 7)
                p.banner(-52, 72, p.shade(0.93, 0.92, 0.86))
                p.banner(46, 60, p.shade(0.16, 0.46, 0.30))
            },
            make("d110-gate") { p in
                p.at(p.width / 2)
                p.road(to: 89, from: 40, width: 44)
                p.at(112)
                p.stoneWall(-104, 116, 32)
                p.stoneWall(78, 64, 32)
                p.gate(0, 104)
                p.banner(-36, 116, p.shade(0.93, 0.92, 0.86))
                p.banner(36, 116, p.shade(0.16, 0.46, 0.30))
                p.palm(-150, 60)
            }
        ],
        // Al-Masad: the firewood carried, the rope of twisted palm fibre, and the flame it feeds (111:3-5).
        111: [
            make("d111-firewood") { p in
                p.at(112)
                p.bareTree(-128, 62)
                p.firewood(-36)
                p.campfire(-3, 0, scale: 2.6)
                p.hearthSmoke(-3, 30)
                p.palm(52, 96)
            }
        ],
        // Al-Ikhlas: nothing is drawn of Him, nor could be: only a clear, empty sky over quiet land (112:1-4).
        112: [
            make("d112-sky", backdrop: .open) { p in
                p.at(p.width / 2)
                p.grain(from: -p.width / 2, to: p.width / 2)
                p.at(92)
                p.house(-6, 24, 13)
                p.palm(26, 30); p.palm(44, 22)
                p.mist(from: -310, to: 92, at: 5)
            }
        ],
        // Al-Falaq: the daybreak, splitting the dark apart (113:1).
        113: [
            make("d113-daybreak", backdrop: .open) { p in
                p.at(p.width / 2)
                p.water(from: -p.width / 2, to: p.width / 2, depth: 46)
                p.horizonLight(52, spread: 170)
                // Frame both banks around the open horizon, even when the
                // view is narrower than the original illustration.
                p.island(max(-124, 60 - p.width / 2), 120, 34)
                p.cliff(min(184, p.width / 2 - 42), 84, 84)
                p.mist(from: -p.width / 2, to: p.width / 2, at: 5)
            }
        ],
        // An-Nas: first light coming over homes still asleep, their people in His keeping (114:1-3).
        114: [
            make("d114-homes", backdrop: .open) { p in
                p.at(p.width / 2)
                p.horizonLight(-86, spread: 150)
                p.at(104)
                p.town(4, houses: 7, scale: 1.15)
                p.palm(-76, 56); p.palm(80, 44)
                p.hearthSmoke(-10, 30)
                p.mist(from: -300, to: 104, at: 6)
            }
        ]
    ]
}
