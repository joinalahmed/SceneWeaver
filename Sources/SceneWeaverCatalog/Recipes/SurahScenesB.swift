import SwiftUI
import SceneWeaver

/// Scenes for surahs 30 to 57. See `SurahScenes`.
extension SurahScenes {
    static let partB: [Int: [Cityscape]] = [
        // Ar-Rum: the walls of a Roman stronghold on a far horizon, its banners flying (30:2-4).
        30: [
            make("b30-rum-fortress") { p in
                p.at(p.width / 2)
                p.road(to: 85, from: 20, width: 30)
                p.driftingSand(from: -p.width / 2, to: p.width / 2, height: 16)
                p.at(116)
                p.peak(-176, 130, 44, lean: -4)
                p.fortress(0, 128, 42)
                p.banner(-64, 74, p.shade(0.62, 0.17, 0.20)); p.banner(64, 74, p.shade(0.62, 0.17, 0.20))
                p.palm(-98, 44); p.palm(-114, 32)
                p.stars([(-120, 136), (-60, 170), (0, 124), (40, 162), (88, 134)], size: 1.2)
            }
        ],
        // Luqman: a great tree on the shore of the sea (31:27);
        // or the pen and its ink beside that sea, which would run dry before the words did.
        31: [
            make("b31-luqman-tree", backdrop: .open) { p in
                p.at(p.width / 2)
                p.island(-161, 120, 26)
                p.water(from: -p.width / 2, to: p.width / 2, depth: 46)
                p.at(112)
                // The shore the tree stands on.
                p.add(p.ridgePath([(-128, 0), (-96, 4), (-40, 7), (30, 7), (84, 4), (112, 0)]))
                p.greatTree(0, 98)
                p.hangingLantern(-48, from: 54, drop: 16)
                p.reeds(-104, count: 8); p.reeds(84, count: 6)
                p.boat(-160, scale: 1.1)
            },
            make("b31-luqman-ink", backdrop: .open) { p in
                p.at(p.width / 2)
                p.island(-150, 120, 26)
                p.water(from: -p.width / 2, to: p.width / 2, depth: 46)
                p.at(118)
                // The shore, running down to the water's edge.
                p.tint(p.polygon([(-150, 0.6), (p.rightEdge, 0.6), (p.rightEdge, -46), (-206, -46)]), p.shade(0.44, 0.39, 0.30))
                p.tint(p.polygon([(-150, 0.6), (-136, 0.6), (-186, -46), (-206, -46)]), Color.black.opacity(0.16))
                p.tint(p.strokePath([(-150, 0.6), (-206, -46)], 1.4), Color.white.opacity(0.26))
                p.penAndInkwell(-6, scale: 1.5)
                p.palm(-110, 50); p.palm(-130, 36)
                p.campfire(-84, 0, scale: 0.9)
                p.stars([(-120, 150), (-60, 178), (40, 164), (84, 132), (-10, 128)], size: 1.2)
            }
        ],
        // As-Sajda: the last third of the night, and a prayer niche with its lamp burning (32:16).
        32: [
            make("b32-sajda-niche", ownMoon: true) { p in
                p.at(104)
                p.house(-78, 46, 26)
                p.prayerNiche(0, scale: 1.8)
                p.palm(62, 60); p.palm(-122, 48)
                p.crescent(-70, 156, 10)
                p.stars([(-128, 132), (-104, 168), (-30, 176), (20, 150), (58, 172), (84, 138)], size: 1.3)
            }
        ],
        // Al-Ahzab: the trench dug before Madinah (33:10-11);
        // or the wind sent against the confederates' camp (33:9).
        33: [
            make("b33-ahzab-trench") { p in
                p.at(p.width / 2)
                p.trench(from: -p.width / 2 - 10, to: p.width / 2 + 10)
                p.at(110)
                p.town(0, houses: 6, scale: 1.7)
                p.palm(-92, 62); p.palm(-112, 44); p.palm(86, 52); p.palm(-150, 38)
                p.hearthSmoke(-20, 44)
            },
            make("b33-ahzab-wind", backdrop: .open) { p in
                p.at(p.width / 2)
                p.windStreaks(from: -p.width / 2, to: p.width / 2, at: 78)
                p.driftingSand(from: -p.width / 2, to: p.width / 2, height: 34)
                p.at(118)
                p.tent(0, 86, 60); p.tent(-74, 52, 34); p.tent(72, 44, 29); p.tent(-126, 38, 24)
                p.banner(44, 70, p.shade(0.66, 0.22, 0.18))
            }
        ],
        // Saba: the dam of Ma'rib with a garden on its right and on its left (34:15-16);
        // or the road of towns in sight of one another, safe to travel by night and by day (34:18).
        34: [
            make("b34-saba-dam") { p in
                // Keep both gardens in view around the dam on narrow phones.
                let gardenSpacing = min(1, (p.width - 40) / 362)
                p.at(p.width * 142 / 402)
                p.dam(0, 86, 50)
                p.palm(-152 * gardenSpacing, 56); p.fig(-176 * gardenSpacing, 28)
                p.house(-126 * gardenSpacing, 24, 14); p.palm(-100 * gardenSpacing, 46)
                p.palm(94 * gardenSpacing, 54); p.fig(114 * gardenSpacing, 28); p.palm(126 * gardenSpacing, 40)
                p.flowers(from: -190 * gardenSpacing, to: -92 * gardenSpacing)
                p.flowers(from: 86 * gardenSpacing, to: 142 * gardenSpacing)
                p.hearthSmoke(-126 * gardenSpacing, 17)
            },
            make("b34-saba-road") { p in
                p.at(108)
                p.road(to: -134, from: -86, width: 34)
                p.town(0, houses: 5, scale: 1.8)
                p.town(-200, houses: 4, scale: 0.85)
                p.town(-272, houses: 3, scale: 0.5)
                p.lampLine(from: -164, to: -104, count: 4)
                p.palm(82, 60); p.palm(-88, 48)
                p.stars([(-120, 146), (-50, 176), (30, 158), (84, 130)], size: 1.2)
            }
        ],
        // Fatir: mountains streaked white and red, and fruits of many colours under them (35:27).
        35: [
            make("b35-fatir-streaks") { p in
                p.at(124)
                p.peak(-186, 110, 50, lean: -4)
                p.peak(0, 220, 120)
                let pale = p.shade(0.93, 0.90, 0.84, 0.50), red = p.shade(0.74, 0.30, 0.22, 0.58)
                let bands: [([(CGFloat, CGFloat)], Color)] = [
                    ([(-10, 100), (-5, 100), (-34, 38), (-42, 40)], pale),
                    ([(2, 104), (8, 100), (-4, 30), (-14, 30)], red),
                    ([(14, 92), (19, 94), (40, 30), (31, 30)], pale),
                    ([(30, 82), (36, 80), (64, 24), (54, 24)], red),
                    ([(-38, 66), (-34, 68), (-62, 22), (-70, 22)], red),
                    ([(-180, 38), (-176, 39), (-164, 12), (-171, 12)], pale),
                    ([(-198, 34), (-194, 36), (-208, 10), (-215, 10)], red)
                ]
                for band in bands { p.tint(p.polygon(band.0), band.1) }
                p.house(-120, 22, 13)
                p.palm(-138, 38); p.palm(-104, 32); p.fig(98, 28)
                p.flowers(from: -150, to: -96)
                p.hearthSmoke(-120, 16)
                p.stars([(-150, 96), (-110, 132), (-70, 164), (96, 150)], size: 1.2)
            }
        ],
        // Ya-Sin: the moon passing through its phases over the town (36:13, 36:39);
        // or the dead land brought to life: grain, palms and vines, and springs breaking out (36:33-34).
        36: [
            make("b36-yasin-moon", ownMoon: true) { p in
                p.at(112)
                p.moonPhases(from: -140, to: 92, at: 160)
                p.town(0, houses: 7, scale: 1.5)
                p.palm(-96, 56); p.palm(88, 48); p.palm(-116, 40)
                p.grain(from: -184, to: -128)
                p.hearthSmoke(14, 40)
            },
            make("b36-yasin-revived") { p in
                p.at(120)
                p.spring(-26, scale: 2.4)
                p.palm(34, 82); p.palm(58, 62); p.palm(-78, 58)
                p.vines(-136, bays: 3)
                p.house(92, 22, 14)
                p.grain(from: 60, to: 122)
                p.stars([(-110, 120), (-50, 160), (0, 132), (90, 150)], size: 1.2)
            }
        ],
        // As-Saffat: the nearest heaven adorned with stars, and a piercing flame that pursues (37:6-10).
        37: [
            make("b37-saffat-stars", backdrop: .open) { p in
                p.at(p.width / 2)
                p.hills(seed: 37, height: 18)
                p.at(114)
                p.constellations(over: -14, height: 184)
                p.stars([(-150, 128), (-96, 186), (-40, 196), (30, 190), (74, 120), (96, 172), (-64, 104), (10, 92)], size: 1.1)
                p.shootingStars(over: -40, height: 180)
                p.tent(8, 50, 32); p.campfire(-34, 0, scale: 1.1); p.palm(52, 54)
            }
        ],
        // Sad: the mountains that gave praise at nightfall and at sunrise (38:18);
        // or the cool spring opened for Ayyub (38:42).
        38: [
            make("b38-sad-mountains") { p in
                p.at(p.width / 2)
                p.horizonLight(-5, spread: 110)
                p.peak(-112, 150, 74, lean: -6)
                p.peak(110, 170, 116, lean: 6)
                p.palm(-28, 34); p.palm(22, 28)
                p.mist(from: -p.width / 2, to: p.width / 2, at: 8)
                p.stars([(-40, 150), (10, 176), (40, 140), (150, 160), (184, 128)], size: 1.2)
            },
            make("b38-sad-spring") { p in
                p.at(106)
                p.spring(0, scale: 3.4)
                p.tree(-78, 58); p.fig(72, 34)
                p.reeds(-54, count: 6); p.flowers(from: 54, to: 104)
                p.house(-140, 26, 15)
                p.mist(from: -260, to: 106)
            }
        ],
        // Az-Zumar: rain sent down and led through the earth to break out as springs,
        // and crops of many colours after it (39:21). The night wrapping over the day (39:5) is the sky's own.
        39: [
            make("b39-zumar-springs") { p in
                p.at(116)
                p.cliff(14, 140, 70)
                p.stormCloud(10, 150, 150)
                p.rain(from: -60, to: 104, height: 148)
                // Keep the western spring and its neighbouring details on the
                // screen as the artwork narrows on smaller phones.
                let westernSpring = -min(CGFloat(164), p.width - 185)
                let westernHouse = -min(CGFloat(212), p.width - 130)
                let westernPalm = -min(CGFloat(190), p.width - 166)
                p.spring(-96, scale: 2.2); p.spring(westernSpring, scale: 1.4)
                p.flowers(from: -142, to: -120)
                p.house(westernHouse, 24, 14); p.palm(westernPalm, 44)
                p.grain(from: max(-270, -p.width + 134), to: max(-230, -p.width + 165))
            }
        ],
        // Ghafir: the Nile, and the tower Pharaoh ordered raised to reach the heavens, never finished (40:36-37).
        40: [
            make("b40-ghafir-tower", backdrop: .open) { p in
                p.at(p.width / 2)
                p.water(from: -p.width / 2, to: p.width / 2, depth: 46)
                p.at(104)
                p.block(-30, 190, 4)
                p.tower(8, 122, unfinished: true)
                p.town(-74, houses: 4, scale: 1.2)
                p.palm(48, 50); p.palm(66, 38); p.palm(-128, 44)
                p.reeds(80, count: 7); p.reeds(-160, count: 8)
                p.boat(-min(CGFloat(206), p.width - 135), scale: 1.2)
            }
        ],
        // Fussilat: the earth lying lifeless, then stirring and swelling green when rain falls on it (41:39).
        41: [
            make("b41-fussilat-revived") { p in
                p.at(p.width / 2)
                // Slight overlap lets the lifeless ground give way to the
                // green plot instead of leaving an empty vertical seam.
                p.crackedGround(from: -p.width / 2, to: 18)
                p.greenField(from: 12, to: p.width / 2 + 24, leftFade: 20)
                p.stormCloud(96, 150, 150)
                p.rain(from: 20, to: 200, height: 148)
                p.bareTree(-66, 46)
                p.tree(92, 66)
                p.house(min(160, p.width / 2 - 15), 24, 14)
            }
        ],
        // Ash-Shura: ships riding the sea like mountains (42:32).
        42: [
            make("b42-shura-ships", backdrop: .open, rtlPlacement: .preserve) { p in
                p.at(p.width / 2)
                p.island(-161, 130, 34)
                p.water(from: -p.width / 2, to: p.width / 2, depth: 46)
                p.waves(from: -p.width / 2, to: p.width / 2, height: 7)
                p.at(120)
                p.ship(-118, scale: 0.55, variant: 1)
                p.ship(0, scale: 1.45)
                p.stars([(-150, 140), (-96, 176), (-60, 120), (84, 150), (100, 96)], size: 1.2)
            }
        ],
        // Az-Zukhruf: houses roofed with silver and a gateway of gold, the adornment of this life only (43:33-35).
        43: [
            make("b43-zukhruf-gate") { p in
                p.at(108)
                p.gate(0, 98, gilded: true)
                let silver = p.shade(0.80, 0.85, 0.92, 0.92)
                for (x, w, h) in [(-78, 36, 26), (-118, 30, 20), (-152, 26, 16), (72, 30, 22)] as [(CGFloat, CGFloat, CGFloat)] {
                    p.house(x, w, h)
                    p.dome(x, w * 0.56, on: h + 1.4, rise: w * 0.24)
                    p.tint(p.domePath(x, w * 0.56, on: h + 1.4, rise: w * 0.24), silver)
                }
                p.palm(-98, 58); p.palm(-172, 40); p.palm(92, 44)
            }
        ],
        // Ad-Dukhan: the day the sky brings a visible smoke that covers the people (44:10-11);
        // or what was left behind: gardens and springs, crops and noble halls (44:25-27).
        44: [
            make("b44-dukhan-smoke") { p in
                p.at(p.width / 2)
                p.smokeBand(at: 124)
                p.at(110)
                p.peak(-170, 150, 62, lean: -5)
                p.town(0, houses: 6, scale: 1.4)
                p.palm(-84, 50); p.palm(84, 42)
            },
            make("b44-dukhan-left-behind", backdrop: .open) { p in
                p.at(118)
                p.columns(-30, heights: [80, 80, 62, 88, 88, 54], gap: 16)
                p.block(10, 104, 4)
                p.hangingLantern(26, from: 86, drop: 24)
                p.spring(-84, scale: 2.3)
                p.palm(-124, 54); p.fig(-160, 28); p.palm(84, 46)
                p.grain(from: -226, to: -186)
                p.stars([(-130, 140), (-70, 172), (-20, 120), (70, 160), (96, 110)], size: 1.2)
            }
        ],
        // Al-Jathiya: ships running on the sea at His command, as the night gives way to the day (45:5, 45:12).
        45: [
            make("b45-jathiya-ships", backdrop: .open) { p in
                p.at(p.width / 2)
                p.horizonLight(30, spread: 210)
                p.water(from: -p.width / 2, to: p.width / 2, depth: 46)
                p.at(112)
                p.boat(0, scale: 2.7)
                p.boat(-104, scale: 1.6); p.boat(72, scale: 1.1); p.boat(-180, scale: 0.9)
                p.stars([(-130, 150), (-70, 180), (50, 170), (90, 128)], size: 1.2)
            }
        ],
        // Al-Ahqaf: the wind-curved sand tracts, and the cloud they took for rain coming up their valley (46:21-25).
        46: [
            make("b46-ahqaf-cloud", backdrop: .open) { p in
                p.at(p.width / 2)
                p.dunes([(-150, 104, 30), (-16, 118, 48)])
                p.stormCloud(36, 132, 170)
                p.driftingSand(from: -p.width / 2, to: p.width / 2, height: 30)
                p.town(min(148, p.width / 2 - 44), houses: 4, scale: 1.3)
                p.palm(min(102, p.width / 2 - 95), 44)
            }
        ],
        // Muhammad: the garden promised to the mindful, with its rivers running through it (47:15).
        47: [
            make("b47-muhammad-rivers", backdrop: .open) { p in
                p.at(p.width / 2)
                p.tint(p.polygon([(-p.width / 2, 0), (p.width / 2, 0), (p.width / 2, -46), (-p.width / 2, -46)]),
                       p.shade(0.24, 0.34, 0.22, 0.38))
                for (far, near, course) in [(-104, -236, SkylinePen.RiverCourse.bendLeft),
                                             (-38, -86, .meander), (30, 66, .bendRight),
                                             (96, 216, .gentle)] as [(CGFloat, CGFloat, SkylinePen.RiverCourse)] {
                    p.river(from: far, to: near, width: 58, naturalBanks: true, course: course)
                }
                p.palm(-144, 50); p.tree(-70, 38); p.fig(-4, 28)
                p.palm(46, 72); p.palm(84, 58)
                p.arcade(64, bays: 3, height: 22)
                p.tree(134, 60)
                p.flowers(from: 108, to: 196)
            }
        ],
        // Al-Fath: the tree under which the pledge was given, by the road to Makkah (48:18).
        48: [
            make("b48-fath-tree") { p in
                p.at(p.width / 2)
                p.road(to: 12, from: -40, width: 34)
                p.at(118)
                p.greatTree(0, 102)
                p.well(58, scale: 1.3)
                p.tent(-118, 40, 26); p.tent(-154, 30, 19)
                p.banner(-94, 40, p.shade(0.92, 0.90, 0.84))
            }
        ],
        // Al-Hujurat: the Prophet's mosque, and the chambers ranged beside its courtyard (49:4).
        49: [
            make("b49-hujurat-chambers") { p in
                p.at(104)
                p.palm(-66, 56); p.palm(-124, 48); p.palm(-182, 40)
                p.mosque(22, scale: 1.45)
                for (x, h) in [(-52, 18), (-81, 16), (-110, 19), (-139, 16), (-168, 18)] as [(CGFloat, CGFloat)] { p.house(x, 26, h) }
                p.hearthSmoke(-110, 22)
            }
        ],
        // Qaf: blessed rain, and by it gardens, grain for the harvest, and tall palms with clustered dates (50:9-11).
        50: [
            make("b50-qaf-palms", backdrop: .open) { p in
                p.at(110)
                p.stormCloud(8, 164, 110)
                for (x, h) in [(-70, 80), (-38, 104), (-4, 92), (30, 116), (62, 86)] as [(CGFloat, CGFloat)] { p.palm(x, h) }
                p.house(-128, 24, 14)
                p.grain(from: -178, to: -92)
                p.mist(from: -260, to: 110, at: 5)
            }
        ],
        // Adh-Dhariyat: the winds that scatter, driving dust over the dunes (51:1).
        51: [
            make("b51-dhariyat-winds", backdrop: .open) { p in
                p.at(p.width / 2)
                p.dunes([(-150, 92, 22), (128, 104, 44)])
                p.windStreaks(from: -p.width / 2, to: p.width / 2, at: 84)
                p.driftingSand(from: -p.width / 2, to: p.width / 2, height: 46)
                p.tent(-6, 54, 34)
                p.palm(34, 52)
            }
        ],
        // An-Najm: the star as it goes down (53:1).
        53: [
            make("b53-najm-star", backdrop: .open) { p in
                p.at(p.width / 2)
                p.hills(seed: 53, height: 20)
                p.at(120)
                p.brightStar(-36, 58)
                p.stars([(-120, 140), (-84, 176), (-10, 150), (40, 184), (84, 132), (64, 96)], size: 1.1)
                p.palm(58, 72); p.palm(80, 50)
                p.tent(-110, 42, 27)
                p.mist(from: -270, to: 124)
            }
        ],
        // Al-Qamar: the full moon over the hills of Makkah (54:1);
        // or the palms of 'Ad torn up by the wind, and their dwellings left empty (54:19-20).
        54: [
            make("b54-qamar-moon", ownMoon: true) { p in
                p.at(130)
                p.peak(-150, 150, 72, lean: -5); p.peak(78, 110, 92, lean: 5)
                // The moon at its full, over the valley. Night only, like the bank's own moons.
                p.glow(-28, 142, 40, Color.white, 0.20, nightOnly: true)
                p.tint(p.discPath(-28, 142, 14), Color(red: 0.98, green: 0.96, blue: 0.88), nightOnly: true)
                p.tint(p.discPath(-32, 145.5, 3.4), Color.black.opacity(0.07), nightOnly: true)
                p.tint(p.discPath(-23, 137, 2.4), Color.black.opacity(0.06), nightOnly: true)
                p.town(-28, houses: 4, scale: 1.2)
                p.hearthSmoke(-28, 30)
                p.mist(from: -280, to: 130, at: 7)
            },
            make("b54-qamar-wind", backdrop: .open) { p in
                p.at(p.width / 2)
                p.windStreaks(from: -p.width / 2, to: p.width / 2, at: 72)
                p.driftingSand(from: -p.width / 2, to: p.width / 2, height: 32)
                p.at(112)
                p.ruins(26, scale: 1.2)
                p.fallenPalms(-150, count: 2)
                p.palmStump(-72, 15)
                p.stars([(-140, 136), (-80, 172), (-10, 150), (50, 182), (90, 124)], size: 1.2)
            }
        ],
        // Ar-Rahman: the two seas that meet and do not overrun each other, and two gardens beyond them (55:19-20, 55:46);
        // or the balance set up among palms, grain and sweet herbs, sun and moon keeping their count (55:5-12).
        55: [
            make("b55-rahman-seas", backdrop: .open) { p in
                p.at(p.width / 2)
                p.twoSeas(meetAt: 6)
                p.island(-118, 170, 13); p.island(120, 170, 15)
                p.palm(max(-160, -p.width / 2 + 20), 44); p.tree(-122, 36); p.palm(-84, 52)
                p.palm(76, 66); p.tree(108, 50); p.palm(min(172, p.width / 2 - 24), 78)
                p.tent(min(142, p.width / 2 - 48), 30, 21)
            },
            make("b55-rahman-balance", ownMoon: true) { p in
                p.at(108)
                p.sun(60, 158, 12)
                p.crescent(60, 158, 10)
                p.scales(0, 98)
                p.palm(-90, 68); p.palm(-116, 48); p.palm(84, 56)
                p.grain(from: -192, to: -132)
                p.flowers(from: 24, to: 66)
            }
        ],
        // Al-Waqi'a: the seed you sow, the water sent down from the cloud, and the tree that feeds your fire (56:63-73).
        56: [
            make("b56-waqia-signs", backdrop: .open) { p in
                p.at(p.width / 2)
                // The verses mention growing crops, rain, and the tree from
                // which fire comes as distinct signs. Keep the downpour over
                // the field and the fire under clear sky on the other side.
                p.greenField(from: -p.width / 2 - 20, to: p.width * 0.03, bankFade: 22)
                p.stormCloud(-p.width * 0.24, 150, min(140, p.width * 0.36))
                p.rain(from: -p.width / 2, to: -p.width * 0.12, height: 146)
                p.tree(p.width * 0.30, 72)
                p.campfire(p.width * 0.14, 0, scale: 1.4)
            }
        ],
        // Al-Hadid: iron sent down, and great strength in it: a forge alight under ore-dark mountains (57:25);
        // or the wall with a door in it, mercy within (57:13).
        57: [
            make("b57-hadid-forge") { p in
                p.at(p.width / 2)
                p.peak(-130, 130, 58, lean: -4); p.peak(112, 180, 112, lean: 5)
                // Seams of ore in the rock, kept high so the forge stands clear of them.
                let rust = p.shade(0.52, 0.25, 0.16, 0.52), dark = Color.black.opacity(0.24)
                let seams: [([(CGFloat, CGFloat)], Color)] = [
                    ([(108, 92), (112, 94), (97, 40), (89, 40)], rust),
                    ([(130, 84), (135, 86), (146, 36), (138, 36)], dark),
                    ([(151, 62), (156, 60), (170, 22), (162, 22)], rust),
                    ([(-130, 46), (-126, 45), (-112, 14), (-119, 14)], dark)
                ]
                for seam in seams { p.tint(p.polygon(seam.0), seam.1) }
                p.forge(-24)
                p.stars([(-50, 150), (0, 178), (30, 136), (-80, 118)], size: 1.2)
            },
            make("b57-hadid-wall", backdrop: .open) { p in
                p.at(132)
                // The garden within, seen over the wall.
                p.palm(-150, 60); p.tree(-96, 62); p.palm(30, 102); p.tree(88, 76)
                p.stoneWall(-126, 152, 40)
                p.stoneWall(86, 72, 40)
                p.door(0, 46)
            }
        ]
    ]
}
