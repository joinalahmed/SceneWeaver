import SwiftUI
import SceneWeaver

/// Scenes for surahs 58 to 86. See `SurahScenes`.
extension SurahScenes {
    static let partC: [Int: [Cityscape]] = [
        // Al-Mujadila: a house in Madinah at night, its neighbours dark, one window lit (58:1).
        58: [
            make("c58-mujadila-window") { p in
                p.at(112)
                p.palm(-58, 72); p.palm(56, 56); p.palm(-118, 46)
                // The neighbours asleep: walls with no lamp in them.
                p.block(-86, 44, 24); p.block(-86, 47, 1.4, from: 24)
                p.block(76, 34, 20); p.block(76, 37, 1.4, from: 20)
                // The house, its door, and the one window with a lamp behind it.
                p.shape([(-36, 0), (36, 0), (35, 48), (-35, 48)])
                p.block(0, 73, 1.6, from: 48)
                p.block(-33.5, 3, 1.8, from: 49.6); p.block(33.5, 3, 1.8, from: 49.6)
                p.tint(p.archPath(-13, 9, 19, pointed: false), Color.black.opacity(0.38))
                p.window(14, 12, 17, from: 22)
                p.glow(14, 30, 24, SkylinePen.lampLight, 0.20, nightOnly: true)
                p.hearthSmoke(-24, 50)
            }
        ],
        // Al-Hashr: the fortresses among the palms (59:2); or the mountain that would
        // have humbled itself and split had the Qur'an come down on it (59:21).
        59: [
            make("c59-hashr-fortresses") { p in
                p.at(118)
                p.fortress(-100, 64, 24)
                p.palm(-160, 52); p.palm(-58, 68)
                p.fortress(14, 108, 46)
                p.palm(-24, 84); p.palm(38, 76); p.palm(92, 58)
                p.driftingSand(from: -280, to: 118, height: 14)
            },
            make("c59-hashr-mountain") { p in
                p.at(p.width / 2)
                p.crackedGround(from: -p.width / 2, to: p.width / 2)
                p.at(124)
                p.peak(-98, 120, 54)
                p.peak(6, 196, 118, lean: -8)
                // The rock parted from its head downward.
                p.tint(p.polygon([(-3, 110), (0, 110), (-5, 92), (2, 74), (-3, 56), (-5, 56), (-1, 74), (-8, 92)]), Color.black.opacity(0.5))
                p.descendingLight(over: 0, spread: 150)
                p.mist(from: -270, to: 124, at: 8)
            }
        ],
        // Al-Mumtahana: the road of the emigrants, from the mountains of Makkah to the palms of Madinah (60:10).
        60: [
            make("c60-mumtahana-road") { p in
                p.at(p.width / 2)
                p.peak(-150, 150, 52, lean: 6); p.peak(-66, 110, 34)
                p.road(to: 97, from: -24, width: 30)
                p.driftingSand(from: -p.width / 2, to: p.width / 2, height: 18)
                p.at(104)
                p.palm(-40, 58); p.palm(46, 66); p.palm(64, 46)
                p.town(0, houses: 4, scale: 1.1)
                p.tent(-96, 26, 17)
            }
        ],
        // As-Saff: a wall built firm, stone on stone, the standards of the ranks over it (61:4);
        // or the light that no breath puts out (61:8).
        61: [
            make("c61-saff-wall") { p in
                p.at(116)
                p.stoneWall(4, 160, 62)
                p.banner(-52, 96, p.shade(0.16, 0.44, 0.30))
                p.banner(0, 100, p.shade(0.92, 0.90, 0.84))
                p.banner(52, 96, p.shade(0.16, 0.44, 0.30))
                p.tent(-146, 30, 19)
                p.campfire(-112, 0, scale: 1.2)
            },
            make("c61-saff-light") { p in
                p.at(108)
                p.palm(-82, 62); p.palm(72, 44)
                p.lampNiche(0)
                p.windStreaks(from: -290, to: 108, at: 112)
                p.driftingSand(from: -290, to: 108, height: 22)
            }
        ],
        // Al-Jumu'a: the mosque of Madinah on Friday at midday, the market left standing (62:9-11).
        62: [
            make("c62-jumua-mosque") { p in
                p.at(100)
                p.sun(-70, 162, 12)
                p.palm(-94, 48); p.palm(-108, 36)
                p.greenDome(0, scale: 1.0)
                p.market(-140, stalls: 2)
            }
        ],
        // Al-Munafiqun: Madinah at dusk, and timbers propped against a wall (63:4).
        63: [
            make("c63-munafiqun-timbers") { p in
                p.at(106)
                p.palm(-96, 58); p.palm(-164, 42)
                p.town(-130, houses: 3, scale: 1.0)
                p.house(34, 96, 46)
                // Timbers leaned on the wall's corner: sound to look at, holding nothing up.
                for (foot, top) in [((-80, 0), (0, 59)), ((-64, 0), (-3, 60)), ((-48, 0), (-7, 60)), ((-36, 0), (-10, 59.5))] as [((CGFloat, CGFloat), (CGFloat, CGFloat))] {
                    p.line([foot, top], 3.2)
                }
                p.hearthSmoke(-130, 26)
            }
        ],
        // At-Taghabun: Madinah's oasis, and the light sent down showing on the horizon (64:8).
        64: [
            make("c64-taghabun-oasis", backdrop: .open) { p in
                p.at(p.width / 2)
                p.horizonLight(-40, spread: 210)
                p.at(108)
                p.palm(-22, 80); p.palm(4, 62); p.palm(30, 94); p.palm(56, 58); p.palm(80, 76)
                p.house(16, 30, 17)
                p.spring(-64, scale: 1.8)
                p.flowers(from: -24, to: 92)
            }
        ],
        // At-Talaq: seven heavens one above another, and of the earth the like of them,
        // over the homes the surah speaks for (65:12, 65:1).
        65: [
            make("c65-talaq-heavens") { p in
                p.at(110)
                p.sevenHeavens(over: -30)
                p.house(-30, 46, 25)
                p.palm(-76, 48); p.palm(14, 38)
                p.tree(-114, 26)
                p.hearthSmoke(-42, 27)
            }
        ],
        // At-Tahrim: the homes of Madinah at evening, lamps along the lane.
        66: [
            make("c66-tahrim-homes") { p in
                p.at(114)
                p.palm(-98, 64); p.palm(-22, 80); p.palm(68, 72)
                p.town(-12, houses: 8, scale: 1.45)
                p.lampLine(from: -168, to: -118, count: 3)
                p.hearthSmoke(-44, 40); p.hearthSmoke(22, 36)
                p.tree(94, 28)
            }
        ],
        // Al-Mulk: a flawless sky, its lamps the stars, over still water (67:3-5);
        // or the well in dry ground: if your water sank away, who would bring it back? (67:30).
        67: [
            make("c67-mulk-stars") { p in
                p.at(p.width / 2)
                p.water(from: -p.width / 2, to: p.width / 2, depth: 46)
                p.at(110)
                p.tent(-36, 34, 22)
                p.palm(4, 60); p.palm(26, 44)
                p.reeds(-96); p.reeds(58, count: 7)
                // Hung in ranks, like lamps.
                p.stars([(-140, 112), (-92, 112), (-44, 112), (4, 112), (52, 112), (92, 112),
                         (-116, 136), (-68, 136), (-20, 136), (28, 136), (74, 136),
                         (-140, 160), (-92, 160), (-44, 160), (66, 160),
                         (-116, 184), (-68, 184), (-20, 184), (84, 184)], size: 1.6)
            },
            make("c67-mulk-water") { p in
                p.at(p.width / 2)
                p.crackedGround(from: -p.width / 2, to: p.width / 2)
                p.at(112)
                p.bareTree(-80, 64)
                p.well(0, scale: 2.3)
                p.tent(76, 28, 18)
                p.stars([(-60, 126), (-24, 150), (-96, 168), (40, 132), (78, 176), (-8, 186)], size: 1.4)
            }
        ],
        // Al-Qalam: the pen and what they write (68:1); or the garden at morning,
        // found stripped bare by those who had sworn to harvest it (68:17-20).
        68: [
            make("c68-qalam-pen") { p in
                p.at(116)
                p.palm(-164, 62); p.palm(94, 48)
                p.door(-106, 36)
                p.penAndInkwell(-4, scale: 1.55)
            },
            make("c68-qalam-garden") { p in
                p.at(p.width / 2)
                // This garden has been stripped, rather than simply harvested:
                // keep the same field asset, with its sparse damaged variation.
                p.greenField(from: -p.width / 2, to: p.width / 2, ripeness: 1, stripped: true)
                p.at(112)
                p.house(-126, 30, 18)
                p.bareTree(-44, 54); p.bareTree(6, 78); p.bareTree(58, 62)
                p.palmStump(-84, 13)
                p.hearthSmoke(26, 4)
                p.mist(from: -290, to: 112, at: 8)
            }
        ],
        // Al-Haqqa: the ruins of 'Ad, and palm trunks torn up hollow by the wind (69:6-7).
        69: [
            make("c69-haqqa-ruins") { p in
                p.at(p.width / 2)
                p.dunes([(-150, 120, 16)])
                p.windStreaks(from: -p.width / 2, to: p.width / 2, at: 98)
                p.at(112)
                p.ruins(28, scale: 1.15)
                p.fallenPalms(-116, count: 2)
                p.driftingSand(from: -290, to: 112, height: 30)
                p.stars([(-50, 160), (-20, 128), (10, 150), (44, 134), (72, 158), (86, 122), (-84, 136)], size: 1.4)
            }
        ],
        // Al-Ma'arij: the stairways rising into the sky, the mountains soft as wool (70:3-4, 70:9).
        70: [
            make("c70-maarij-stairway") { p in
                p.at(124)
                p.peak(-190, 130, 44); p.peak(-150, 80, 26)
                p.stairway(0, steps: 16, rise: 172)
                p.palm(-56, 40); p.palm(58, 34)
                p.tent(-88, 24, 16)
                p.mist(from: -278, to: 124, at: 10)
                p.stars([(-44, 150), (38, 132), (-26, 190), (56, 178), (-68, 118)], size: 1.3)
            }
        ],
        // Al-Jinn: a night sky crossed by shooting stars (72:8-9), over a mosque among the palms (72:18).
        72: [
            make("c72-jinn-meteors") { p in
                p.at(p.width / 2)
                p.dunes([(-150, 130, 18)])
                p.at(104)
                p.palm(-78, 58); p.palm(-100, 42); p.palm(66, 50)
                p.mosque(-6, scale: 1.2)
                p.shootingStars(over: -70, height: 184); p.shootingStars(over: 0, height: 150)
                p.stars([(-120, 150), (-84, 176), (-40, 134), (70, 150), (-150, 118), (84, 186)], size: 1.2)
            }
        ],
        // Al-Muzzammil: the night vigil, one lamp in a window (73:1-6);
        // or the place of prayer, its lamp burning through the night (73:20).
        73: [
            make("c73-muzzammil-vigil") { p in
                p.at(108)
                p.peak(-124, 150, 64, lean: 8)
                p.palm(66, 52)
                p.block(-58, 40, 30); p.block(-58, 43, 1.4, from: 30)
                // The upper room, and its window standing open to the night.
                p.shape([(-38, 0), (38, 0), (36.5, 76), (-36.5, 76)])
                p.block(0, 77, 1.8, from: 76)
                p.block(-35, 4, 2, from: 77.8); p.block(35, 4, 2, from: 77.8)
                p.tint(p.archPath(0, 30, 42, from: 24, pointed: true), Color.black.opacity(0.36))
                p.detail(p.archPath(0, 34, 45, from: 23, pointed: true).strokedPath(StrokeStyle(lineWidth: 1)), strength: 0.9)
                p.detail(p.blockPath(0, 38, 1.2, from: 21.6), strength: 0.9)
                p.hangingLantern(0, from: 64, drop: 16, scale: 1.5)
            },
            make("c73-muzzammil-prayer") { p in
                p.at(118)
                p.peak(-118, 150, 62, lean: 6)
                p.palm(84, 50)
                p.prayerNiche(6, scale: 1.7)
                p.mist(from: -284, to: 118, at: 8)
                p.shootingStars(over: -80)
            }
        ],
        // Al-Muddaththir: the moon, the night as it withdraws, the dawn as it brightens (74:32-34).
        74: [
            make("c74-muddaththir-dawn", ownMoon: true) { p in
                p.at(p.width / 2)
                p.horizonLight(-20, spread: 170)
                p.at(112)
                // Keep the left mountain in the frame on small phones while
                // leaving the dawn glow visible in the valley between peaks.
                p.peak(max(-246, 164 - p.width), 110, 44)
                p.peak(96, 90, 60); p.peak(36, 150, 98, lean: -8)
                p.crescent(-52, 152, 11)
                p.mist(from: -290, to: 112, at: 8)
            }
        ],
        // Al-Qiyama: the sun and the moon brought together (75:9), over the graves
        // of those who thought their bones would not be gathered (75:3).
        75: [
            make("c75-qiyama-sun-moon", ownMoon: true) { p in
                p.at(118)
                p.graves(from: -150, to: 60, count: 12)
                p.bareTree(72, 72)
                p.sunAndMoon(-36, 150)
                p.mist(from: -284, to: 118, at: 10)
            }
        ],
        // Al-Insan: a garden with a spring and vessels of silver (76:5-6, 76:15-16);
        // or the food set out for the needy, the orphan and the captive (76:8-9).
        76: [
            make("c76-insan-garden") { p in
                p.at(112)
                p.palm(-146, 62)
                p.greatTree(-10, 104)
                p.hangingLantern(37, from: 60, drop: 22, scale: 1.2)
                p.spring(-70, scale: 2.2)
                p.vessels(72)
                p.flowers(from: -168, to: -106); p.flowers(from: -36, to: 42)
            },
            make("c76-insan-table") { p in
                p.at(110)
                p.palm(-152, 66); p.palm(84, 56)
                p.door(18, 44)
                p.table(-88, scale: 1.5)
            }
        ],
        // Al-Mursalat: the winds sent out one after another, the clouds racing (77:1-4);
        // or the shadow of smoke rising in three columns (77:30-33).
        77: [
            make("c77-mursalat-winds") { p in
                p.at(p.width / 2)
                p.windStreaks(from: -p.width / 2, to: p.width / 2, at: 104)
                p.stormCloud(70, 142, 140)
                p.grain(from: -p.width / 2, to: p.width / 2)
                p.at(104)
                p.palm(-30, 70); p.palm(4, 56); p.palm(60, 64)
                p.house(-86, 36, 22)
            },
            make("c77-mursalat-smoke") { p in
                p.at(118)
                p.peak(-136, 130, 50); p.peak(98, 90, 38)
                p.fireColumns(0, count: 3, height: 104)
                p.smokeBand(at: 152)
                p.driftingSand(from: -284, to: 118, height: 16)
            }
        ],
        // An-Naba: mountains like pegs, a blazing lamp, rain from the clouds, grain and gardens (78:7, 78:13-16).
        78: [
            make("c78-naba-signs") { p in
                p.at(112)
                p.sun(-66, 160, 13)
                p.peak(-36, 64, 96, lean: -3); p.peak(70, 62, 88, lean: 2); p.peak(18, 76, 124, lean: 4)
                p.stormCloud(40, 150, 110)
                p.rain(from: -10, to: 112, height: 150)
                p.palm(-158, 56)
                p.house(-128, 28, 17)
                p.olive(-92, 42)
                p.greenField(from: -290, to: -70, bankFade: 22)
            }
        ],
        // An-Nazi'at: the valley of Tuwa (79:16), its night darkened and its morning brought out (79:29).
        79: [
            make("c79-naziat-tuwa") { p in
                p.at(116)
                p.cliff(-122, 124, 76)
                p.cliff(74, 112, 98)
                p.horizonLight(-21, spread: 66)
                // Let the water narrow into the valley instead of meeting the
                // cliffs in a hard triangular wedge.
                p.river(from: -21, to: -70, width: 80, naturalBanks: true, course: .bendLeft)
                p.reeds(-6, count: 5)
                p.mist(from: -286, to: 116, at: 6)
                p.stars([(-34, 118), (-8, 142), (-40, 166), (-14, 188)], size: 1.3)
            }
        ],
        // 'Abasa: grain, vines, olives and palms (80:27-29); or the honoured pages, raised high (80:13-14).
        80: [
            make("c80-abasa-harvest") { p in
                p.at(108)
                p.palm(-162, 70); p.palm(-142, 52)
                p.house(-112, 26, 21)
                p.olive(-70, 50); p.olive(80, 42)
                p.vines(6, bays: 4)
                p.grain(from: -176, to: 104)
            },
            make("c80-abasa-pages") { p in
                p.at(116)
                p.peak(-126, 150, 56)
                p.pages(0, scale: 2.8)
                p.descendingLight(over: 0, spread: 150)
                p.mist(from: -286, to: 116, at: 8)
            }
        ],
        // At-Takwir: the sun wrapped up, the stars falling, the mountains set moving (81:1-3).
        81: [
            make("c81-takwir-sun") { p in
                p.at(112)
                p.peak(-126, 110, 60, lean: 10); p.peak(46, 130, 88, lean: -12)
                p.sun(-30, 150, 15)
                // Its light folded away.
                p.tint(p.discPath(-30, 150, 15.5), Color.black.opacity(0.34 * (1 - p.night)))
                p.smokeBand(at: 150)
                p.tent(-54, 24, 16); p.tent(-30, 18, 12)
                p.driftingSand(from: -290, to: 112, height: 34)
                p.fallingStars(over: -30, spread: 230)
            }
        ],
        // Al-Infitar: the sky split, the stars strewn, the seas burst forth (82:1-3).
        82: [
            make("c82-infitar-rift", backdrop: .open) { p in
                p.at(p.width / 2)
                p.island(-110, 160, 28); p.island(96, 110, 38)
                p.water(from: -p.width / 2, to: p.width / 2, depth: 46)
                p.waves(from: -p.width / 2, to: p.width / 2, height: 12)
                p.at(124)
                p.riftInSky(0)
                // Strewn from the tear, thinning as they fall away from it.
                p.stars([(-18, 176), (-30, 158), (-22, 138), (-48, 146), (-44, 120), (-70, 130), (-84, 104), (-112, 116),
                         (24, 168), (36, 144), (30, 118), (58, 128), (70, 100), (88, 112)], size: 1.5)
            }
        ],
        // Al-Mutaffifin: the scales of the market, and those who give short measure (83:1-3).
        83: [
            make("c83-mutaffifin-scales") { p in
                p.at(118)
                p.palm(-78, 76); p.palm(92, 52)
                p.market(-126, stalls: 2)
                p.scales(10, 104)
            }
        ],
        // Al-Inshiqaq: the twilight glow, the night and what it gathers, the moon as it grows full (84:16-19).
        84: [
            make("c84-inshiqaq-twilight", backdrop: .open, ownMoon: true) { p in
                p.at(p.width / 2)
                p.dunes([(-130, 140, 14)])
                p.horizonLight(-10, spread: 240)
                p.moonPhases(from: -60, to: 180, at: 158)
                p.driftingSand(from: -p.width / 2, to: p.width / 2, height: 14)
                p.at(100)
                p.bareTree(4, 66)
                p.tent(52, 30, 19)
            }
        ],
        // Al-Buruj: the sky with its great constellations (85:1), over the trench and its fire fed with fuel (85:4-5).
        85: [
            make("c85-buruj-constellations") { p in
                p.at(p.width / 2)
                p.hills(seed: 8, height: 18)
                p.trench(from: -180, to: 180)
                for x in [-132, -48, 100, 164] as [CGFloat] {
                    p.campfire(min(x, p.width / 2 - 15), -12, scale: 1.3)
                }
                p.at(110)
                p.fortress(26, 84, 32)
                p.constellations(over: -44, height: 152)
            }
        ],
        // At-Tariq: the piercing star of the night (86:1-3); or the sky that gives back
        // its rain and the earth that splits open with growth (86:11-12).
        86: [
            make("c86-tariq-star") { p in
                p.at(120)
                p.peak(-122, 110, 50)
                p.peak(-10, 190, 100, lean: 6)
                p.palm(-162, 64)
                p.house(97, 28, 17)
                p.brightStar(-34, 158)
                p.mist(from: -282, to: 120)
            },
            make("c86-tariq-rain") { p in
                p.at(p.width / 2)
                p.stormCloud(40, 138, 150)
                p.rain(from: -60, to: 196, height: 140)
                p.greenField(from: -p.width / 2, to: p.width / 2)
                p.at(106)
                p.palm(-72, 54)
                p.house(-20, 34, 19)
                p.tree(34, 46)
                p.flowers(from: 56, to: 102)
            }
        ]
    ]
}
