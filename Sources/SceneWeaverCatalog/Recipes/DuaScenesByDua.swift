import SwiftUI
import SceneWeaver

/// Scenes of single duas, by the dua's id. See `DuaScenes`. The duas of a
/// group stand in the group's place, each with a different piece or moment of it.
extension DuaScenes {
    static let byDua: [Int: Cityscape] = [morning, evening, sleep, nightPrayer, prayer, afterPrayer, masjid, wudu, recitation, knowledge,
                                          guidance, forgiveness, gratitude, distress, grief, illness, protection, house, parents, children,
                                          marriage, food, business, travel, hajj, weather, dhikr].reduce(into: [:]) { all, group in
        all.merge(group) { kept, _ in kept }
    }

    // MARK: Morning: the oasis mosque at first light

    private static let morning: [Int: Cityscape] = [
        // Morning Remembrance: the sun coming up beside the oasis mosque and its palms.
        1: make("1-sunrise") { p in
            p.at(110)
            p.horizonLight(-156, spread: 160)
            p.sun(-156, 58, 16)
            oasisMosque(&p, 18, 0.95)
            for (x, h) in [(-48.0, 50.0), (-70, 36), (88, 42), (-94, 56)] as [(CGFloat, CGFloat)] { p.palm(x, h) }
        },
        // Master of Forgiveness: the oasis spring welling up clear in the foreground, the mosque behind it.
        2: make("2-spring") { p in
            p.at(110)
            p.horizonLight(-196, spread: 170)
            oasisMosque(&p, 58, 0.5)
            p.palm(-118, 62); p.palm(-140, 44); p.palm(96, 38)
            p.spring(-30, scale: 4.2)
            p.flowers(from: -130, to: -84)
        },
        // Protection Morning Dua: the oasis safe behind its wall and shut gate as the light comes.
        3: make("3-wall") { p in
            p.at(110)
            p.horizonLight(-230, spread: 150)
            oasisMosque(&p, 34, 0.9)
            p.stoneWall(-150, 96, 26)
            p.door(-70, 30)
            p.palm(-124, 60); p.palm(-160, 48); p.palm(96, 44)
        },
        // Morning Tasbih: the oasis garden in flower, early mist lying in it.
        46: make("46-garden") { p in
            p.at(110)
            oasisMosque(&p, 30, 0.9)
            p.fig(-82, 52)
            p.palm(-140, 46)
            p.flowers(from: -160, to: 100)
            p.mist(from: p.leftEdge, to: 110)
        },
        // Al-Mu'awwidhat in the morning: daybreak itself, wide on the horizon, the mosque dark against it.
        47: make("47-daybreak", backdrop: .open) { p in
            p.at(p.width / 2)
            p.dunes([(-160, 100, 18), (150, 110, 14)])
            p.at(110)
            p.horizonLight(-80, spread: 330)
            oasisMosque(&p, 40, 0.62)
            p.palm(-6, 40); p.palm(-30, 28); p.palm(88, 34)
            p.brightStar(-20, 164)
        },
        // Dua for Good Morning: the road to the mosque in the first light.
        48: make("48-road") { p in
            p.at(110)
            p.horizonLight(-180, spread: 180)
            p.road(to: 12, from: -70, width: 40)
            oasisMosque(&p, 12, 0.9)
            for (x, h) in [(-52.0, 54.0), (-74, 40), (76, 48), (96, 36)] as [(CGFloat, CGFloat)] { p.palm(x, h) }
            p.mist(from: p.leftEdge, to: 110)
        },
        // SubhanAllahil Adheem wa Bihamdihi: one great tree planted by the oasis.
        49: make("49-tree") { p in
            p.at(110)
            p.horizonLight(-210, spread: 150)
            oasisMosque(&p, -128, 0.5)
            p.greatTree(16, 104)
            p.spring(-70, scale: 1.7)
            p.flowers(from: -50, to: 100)
        }
    ]

    // MARK: Evening: the same oasis as the lamps are lit

    private static let evening: [Int: Cityscape] = [
        // Evening Remembrance: the oasis mosque across its pool, the new moon over it.
        4: make("4-pool", ownMoon: true) { p in
            p.at(110)
            p.water(from: p.leftEdge, to: 110, depth: 36)
            oasisMosque(&p, 0, 1.12)
            p.palm(-78, 60); p.palm(-100, 44); p.palm(86, 50)
            p.reeds(-136); p.reeds(-176, count: 7)
            p.crescent(-40, 152, 11)
            p.stars([(-150, 150), (-96, 176), (10, 176), (84, 140)], size: 1.3)
        },
        // Evening Protection: the gate in the oasis wall shut for the night, its lamp lit.
        5: make("5-gate") { p in
            p.at(110)
            oasisMosque(&p, -130, 0.55)
            p.palm(-62, 82); p.palm(84, 78)
            p.stoneWall(-70, 60, 22)
            p.door(14, 50)
            p.stars([(-150, 150), (-90, 176), (-20, 150), (60, 176)], size: 1.3)
        },
        // Evening Remembrance of Allah: the houses of the oasis at day's end, windows lit, smoke rising.
        50: make("50-houses") { p in
            p.at(110)
            oasisMosque(&p, 68, 0.6)
            p.town(-22, houses: 6, scale: 1.4)
            p.hearthSmoke(-44, 30); p.hearthSmoke(4, 26)
            p.palm(-96, 54); p.palm(-118, 40)
            p.lampLine(from: -170, to: -140, count: 2)
        },
        // Seeking Forgiveness 100 Times a Day: the prayer niche in the oasis court, its lamp burning into the evening.
        51: make("51-niche") { p in
            p.at(110)
            p.prayerNiche(0, scale: 1.6)
            p.palm(-66, 66); p.palm(-90, 46); p.palm(68, 56)
            lampPost(&p, -130, 48, arm: 10)
            p.stars([(-150, 150), (-90, 176), (40, 178), (90, 150)], size: 1.3)
        },
        // Evening Protection (second narration): a watch-fire kept under the oasis palms through the night.
        52: make("52-watchfire") { p in
            p.at(110)
            oasisMosque(&p, -150, 0.5)
            p.palm(30, 86); p.palm(58, 66); p.palm(6, 56)
            p.campfire(-40, 0, scale: 1.5)
            p.stars([(-150, 150), (-90, 176), (-40, 140), (90, 160)], size: 1.3)
        }
    ]

    // MARK: Sleep: a quiet house at night

    private static let sleep: [Int: Cityscape] = [
        // Before Sleeping: the house gone quiet, one lantern left burning by its door.
        14: make("14-lantern") { p in
            p.at(110)
            home(&p, 22, 1.4)
            lampPost(&p, -40, 42, arm: 9)
            p.tree(-104, 44)
            p.mist(from: p.leftEdge, to: 110)
            p.shootingStars(over: -60)
        },
        // Upon Waking Up: the same house at daybreak, the sun rising on it.
        15: make("15-daybreak") { p in
            p.at(110)
            p.horizonLight(-150, spread: 200)
            p.sun(-150, 56, 15)
            home(&p, 26, 1.35)
            p.palm(-48, 66)
            p.flowers(from: -100, to: 110)
        },
        // Al-Mu'awwidhat before sleep: the house shut within its wall under the stars.
        61: make("61-wall") { p in
            p.at(110)
            p.palm(-62, 72); p.palm(80, 78)
            home(&p, 10, 1.45)
            p.stoneWall(10, 190, 18)
            p.constellations(over: -30, height: 182)
        },
        // Dua for a Bad Dream: a dark cloud and a wind passing over the house, its lamp still lit.
        62: make("62-cloud") { p in
            p.at(110)
            p.stormCloud(-16, 152, 150)
            p.windStreaks(from: p.leftEdge, to: 110, at: 100)
            home(&p, 36, 1.3)
            p.bareTree(-72, 60)
        },
        // Upon Waking at Night: light coming down on the house in the deep of the night.
        63: make("63-night") { p in
            p.at(110)
            home(&p, -10, 1.4)
            p.palm(66, 72)
            p.descendingLight(over: -10, spread: 150)
            p.stars([(-150, 150), (-96, 176), (30, 180), (92, 150)], size: 1.4)
            p.mist(from: p.leftEdge, to: 110)
        },
        // Upon Seeing a Good Dream: the house in its garden in flower, one bright star over it.
        64: make("64-garden") { p in
            p.at(110)
            home(&p, -24, 1.35)
            p.fig(66, 50)
            p.tree(-110, 36)
            p.flowers(from: -130, to: 110)
            p.brightStar(-24, 160)
        }
    ]

    // MARK: Night prayer: the niche and its lamp

    private static let nightPrayer: [Int: Cityscape] = [
        // Dua at Tahajjud: the lamp in its niche (You are the Light of the heavens and the earth).
        120: make("120-lamp") { p in
            p.at(110)
            p.lampNiche(14)
            p.palm(-62, 58); p.palm(86, 46)
            p.constellations(over: -70, height: 182)
            p.mist(from: p.leftEdge, to: 110)
        },
        // Witr Qunut: the niche beside the arcade, the last prayer of the night under a thin moon.
        121: make("121-witr", ownMoon: true) { p in
            p.at(110)
            p.arcade(-80, bays: 4, bay: 16, height: 32)
            p.prayerNiche(20, scale: 1.7)
            p.crescent(-44, 152, 11)
            p.stars([(-150, 150), (-100, 178), (10, 180), (88, 146)], size: 1.3)
            p.mist(from: p.leftEdge, to: 110)
        },
        // Dua for Laylat al-Qadr: the niche by a sleeping house under the moon's whole month, light descending (better than a thousand months).
        122: make("122-qadr", ownMoon: true) { p in
            p.at(110)
            p.house(-92, 38, 22)
            p.palm(-126, 44); p.palm(-58, 52)
            p.prayerNiche(32, scale: 1.55)
            p.moonPhases(from: -150, to: 86, at: 164)
            p.descendingLight(over: 32, spread: 130, height: 150)
        },
        // Opening of Tahajjud Prayer: the niche under the seven heavens (Creator of the heavens and the earth).
        123: make("123-heavens") { p in
            p.at(110)
            p.prayerNiche(-10, scale: 1.6)
            p.palm(72, 50)
            p.sevenHeavens(over: -10)
        }
    ]

    // MARK: In the prayer: the niche and the mat

    private static let prayer: [Int: Cityscape] = [
        // Opening Supplication: the niche at the head of the prayer hall, the arcade running from it.
        6: make("6-hall") { p in
            p.at(110)
            hall(&p, -74, bays: 5, bay: 18, height: 40)
            p.prayerNiche(44, scale: 1.7)
            p.palm(-142, 44)
        },
        // Between the prostrations: the niche in a soft rain (My Lord, forgive me).
        7: make("7-rain") { p in
            p.at(110)
            p.prayerNiche(10, scale: 1.7)
            p.tree(-78, 46)
            p.rain(from: p.leftEdge, to: 140, height: 190)
            p.mist(from: p.leftEdge, to: 110)
        },
        // Dua in Sujud: the mat spread wide before the niche, one star high over it (my Lord, the Most High).
        8: make("8-mat") { p in
            p.at(110)
            p.prayerNiche(0, scale: 2.2)
            p.palm(-92, 46)
            p.brightStar(-84, 162)
            p.stars([(-150, 150), (-40, 184), (70, 170)], size: 1.3)
        },
        // Dua in Ruku: the niche at the foot of a great mountain (my Lord, the Most Great).
        53: make("53-mountain") { p in
            p.at(110)
            p.peak(36, 140, 120, lean: 4)
            p.prayerNiche(-66, scale: 1.5)
            p.palm(-126, 40)
            p.mist(from: p.leftEdge, to: 110)
        },
        // Rising from Ruku: the niche with the sun up and the ground in flower (praise abundant, pure and blessed).
        54: make("54-praise") { p in
            p.at(110)
            p.sun(-58, 150, 16)
            p.prayerNiche(12, scale: 1.8)
            p.palm(-84, 50)
            p.flowers(from: -140, to: -40); p.flowers(from: 66, to: 110)
        },
        // Tashahud: the niche between two olive trees (peace be upon us and upon the righteous).
        55: make("55-olives") { p in
            p.at(110)
            p.olive(-84, 62); p.olive(76, 54)
            p.prayerNiche(0, scale: 1.6)
            p.stars([(-150, 150), (-100, 176), (30, 182), (92, 150)], size: 1.3)
        },
        // Salawat Ibrahimiyya: the niche, and far off the Prophet's Mosque with its green dome.
        56: make("56-madinah") { p in
            p.at(110)
            p.greenDome(-114, scale: 0.7)
            p.palm(-40, 46); p.palm(90, 52)
            p.prayerNiche(34, scale: 1.6)
            p.stars([(-150, 150), (-90, 176), (-30, 150), (88, 170)], size: 1.3)
        },
        // Dua Before Salam: the niche set in a strong stone wall, a place of refuge.
        57: make("57-refuge") { p in
            p.at(110)
            p.palm(-76, 72); p.palm(86, 60)
            p.stoneWall(0, 230, 30)
            p.prayerNiche(0, scale: 1.7)
            p.lampLine(from: -96, to: -66, count: 2)
            p.stars([(-150, 150), (-90, 176), (60, 178), (94, 146)], size: 1.3)
        }
    ]

    // MARK: After the prayer: the mosque's arcade and its lanterns

    private static let afterPrayer: [Int: Cityscape] = [
        // Istighfar After Prayer: the spring in the mosque's court, the arcade behind it.
        9: make("9-spring") { p in
            p.at(110)
            hall(&p, 24, bays: 5, bay: 20, height: 44)
            p.dome(24, 44, on: 45.8, rise: 24); p.finial(24, from: 69, height: 9, gilt: true)
            p.palm(-150, 50)
            p.spring(-86, scale: 3.0)
        },
        // SubhanAllah After Prayer: the arcade under the great figures of the stars.
        10: make("10-stars") { p in
            p.at(110)
            hall(&p, -16, bays: 7, bay: 18, height: 40)
            minaret(&p, 76, 110)
            p.constellations(over: -20, height: 186)
        },
        // Alhamdulillah After Prayer: the court in flower under the sun, a fig tree by the arcade.
        11: make("11-court") { p in
            p.at(110)
            p.sun(-30, 158, 14)
            hall(&p, 40, bays: 4, bay: 22, height: 48)
            p.fig(-72, 56)
            p.flowers(from: -160, to: -6)
        },
        // Allahu Akbar After Prayer: the tall minaret standing over the arcade.
        12: make("12-minaret") { p in
            p.at(110)
            hall(&p, -56, bays: 5, bay: 18, height: 38)
            p.dome(-56, 40, on: 39.8, rise: 22); p.finial(-56, from: 61, height: 8, gilt: true)
            p.block(40, 20, 15); p.block(40, 23, 1.6, from: 15)
            p.tallMinaret(40, 126, width: 10)
            p.stars([(-150, 150), (-100, 176), (-30, 160), (84, 150)], size: 1.3)
        },
        // Ayat al-Kursi After Prayer: the arcade under the seven heavens (His Kursi extends over the heavens and the earth).
        13: make("13-kursi") { p in
            p.at(110)
            hall(&p, 0, bays: 6, bay: 18, height: 40)
            p.dome(0, 46, on: 41.8, rise: 25); p.finial(0, from: 66, height: 9, gilt: true)
            p.sevenHeavens(over: 0)
        },
        // La ilaha illallah after Fajr and Maghrib: the arcade with the light low on the horizon.
        58: make("58-twilight") { p in
            p.at(110)
            p.horizonLight(-150, spread: 230)
            hall(&p, 30, bays: 5, bay: 20, height: 42)
            p.palm(-48, 62); p.palm(-72, 44)
        },
        // Best of This World and Next: the arcade over a garden with a stream running through it.
        59: make("59-garden") { p in
            p.at(110)
            p.river(from: -92, to: -150, width: 90, naturalBanks: true, course: .bendLeft)
            hall(&p, 12, bays: 6, bay: 18, height: 40)
            p.palm(-64, 66); p.palm(88, 52)
            p.tree(-130, 40)
            p.flowers(from: -80, to: -40)
        },
        // Help in Remembrance and Worship: open pages on a stand in the arcade's court.
        60: make("60-pages") { p in
            p.at(110)
            hall(&p, -66, bays: 5, bay: 18, height: 40)
            p.pages(46, scale: 1.9)
            p.stars([(-150, 150), (-90, 176), (-20, 160), (90, 176)], size: 1.3)
        }
    ]

    // MARK: At the mosque: the mosque and its gate

    private static let masjid: [Int: Cityscape] = [
        // Entering the Masjid: the gate standing open, the road running in (open for me the doors of Your mercy).
        23: make("23-open-gate") { p in
            p.at(110)
            p.road(to: 14, from: -40, width: 46)
            p.mosque(-112, scale: 0.9)
            p.gate(14, 110)
            p.palm(-172, 46); p.palm(90, 48)
            p.lampLine(from: -58, to: 68, count: 2)
        },
        // Leaving the Masjid: the road out from the mosque towards the market (I ask You of Your favour).
        24: make("24-way-out") { p in
            p.at(110)
            p.road(to: 33, from: -110, width: 48)
            p.mosque(44, scale: 1.5)
            p.market(-140, stalls: 2)
            p.palm(-58, 50)
        },
        // Dua After Adhan: the minaret the call has just gone out from, lamps lit below it.
        72: make("72-minaret") { p in
            p.at(110)
            p.mosque(-4, scale: 1.8)
            p.lampLine(from: -150, to: -96, count: 3)
            p.stars([(-150, 150), (-100, 176), (-40, 150), (90, 170)], size: 1.3)
            p.shootingStars(over: -70)
        },
        // Entering with Salam on the Prophet: the Prophet's Mosque, the green dome among its minarets.
        73: make("73-green-dome") { p in
            p.at(110)
            p.road(to: -6, from: -66, width: 42)
            p.greenDome(-6, scale: 1.15)
            p.palm(-124, 50); p.palm(98, 44)
            p.stars([(-150, 150), (-90, 176), (40, 180)], size: 1.3)
        }
    ]

    // MARK: Wudu: a spring and a well

    private static let wudu: [Int: Cityscape] = [
        // Before Wudu: the well, its bucket on the rope, a jug set beside it.
        41: make("41-well") { p in
            p.at(110)
            p.palm(88, 70); p.palm(-152, 50)
            lampPost(&p, -122, 58, arm: 9)
            p.well(14, scale: 3.4)
            p.vessels(-68, scale: 1.25)
        },
        // After Wudu: the spring before an open gate with light in it (the gates of Paradise are opened to him).
        42: make("42-gate") { p in
            p.at(110)
            p.gate(36, 100)
            p.horizonLight(36, spread: 130)
            p.palm(-138, 50)
            p.spring(-66, scale: 3.0)
            p.flowers(from: -130, to: -10)
        },
        // Complete After-Wudu Dua: the spring running over into a clear stream (among those who purify themselves).
        43: make("43-stream") { p in
            p.at(110)
            // Bring the channel up to the existing spring instead of leaving
            // the source and stream visibly disconnected.
            p.river(from: 13, to: -70, width: 80, naturalBanks: true, course: .meander)
            p.mosque(-140, scale: 0.75)
            p.spring(24, scale: 4.0, outflow: false)
            p.reeds(-56); p.reeds(-96, count: 7)
        },
        // When Putting On Clothes: washed cloth drying on a line by the well.
        44: make("44-cloth") { p in
            p.at(110)
            p.palm(-108, 66)
            washing(&p, from: -76, to: 36, height: 62)
            p.well(80, scale: 2.0)
            p.stars([(-150, 150), (-60, 176), (60, 160)], size: 1.3)
        },
        // When Undressing: a closed door with its lamp, the well beside it.
        45: make("45-door") { p in
            p.at(110)
            p.palm(-122, 56)
            p.door(24, 46)
            p.well(-72, scale: 2.4)
            p.stars([(-150, 150), (-90, 176), (-20, 150), (70, 176)], size: 1.3)
        }
    ]

    // MARK: Reciting the Quran: pages on a stand, a lamp

    private static let recitation: [Int: Cityscape] = [
        // Before Reciting the Quran: the pages on their stand under the lamp in its niche.
        124: make("124-lamp") { p in
            p.at(110)
            p.lampNiche(44)
            p.pages(-52, scale: 1.9)
            p.palm(-128, 44)
        },
        // Al-Fatiha: the open pages, and a straight road running to the light (guide us to the straight path).
        125: make("125-straight-path") { p in
            p.at(110)
            p.road(to: -110, from: -180, width: 38)
            p.horizonLight(-110, spread: 190)
            p.pages(36, scale: 2.3)
            p.stars([(-150, 150), (-60, 176), (20, 170), (90, 150)], size: 1.3)
        },
        // Dua Upon Completing the Quran: the pages with light descending on them, flowers about the stand.
        126: make("126-completion") { p in
            p.at(110)
            p.palm(90, 56)
            p.pages(-8, scale: 2.6)
            p.flowers(from: -130, to: 100)
            p.descendingLight(over: -8, spread: 150)
            p.stars([(-150, 150), (-90, 176), (60, 180)], size: 1.3)
        }
    ]

    // MARK: Knowledge: pen and inkwell

    private static let knowledge: [Int: Cityscape] = [
        // Increase in Knowledge: the pen and inkwell, and steps climbing into the sky.
        35: make("35-steps") { p in
            p.at(110)
            p.stairway(48, steps: 14, rise: 150)
            p.penAndInkwell(-78, scale: 1.25)
            p.stars([(-150, 150), (-90, 176), (-20, 150)], size: 1.3)
        },
        // Dua for Beneficial Knowledge: the pen and inkwell beside open pages, a lamp to read by.
        84: make("84-pages") { p in
            p.at(110)
            p.pages(-80, scale: 1.6)
            p.penAndInkwell(28, scale: 1.35)
            lampPost(&p, -136, 56, arm: 10)
            p.stars([(-150, 150), (-60, 176), (90, 170)], size: 1.3)
        },
        // Seeking Refuge from Useless Knowledge: the pen and inkwell under a tree that bears nothing, sand blowing past.
        85: make("85-bare-tree") { p in
            p.at(110)
            p.bareTree(66, 86)
            p.penAndInkwell(-44, scale: 1.4)
            lampPost(&p, -112, 50, arm: 9, scale: 0.8)
            p.driftingSand(from: p.leftEdge, to: 110)
            p.stars([(-150, 150), (-90, 176), (-20, 160), (20, 180)], size: 1.3)
        }
    ]

    // MARK: Guidance: a road towards light

    private static let guidance: [Int: Cityscape] = [
        // Istikhara: the road dividing in two, a lamp where it parts and light at the end of one way.
        37: make("37-two-ways") { p in
            p.at(110)
            p.peak(-190, 150, 52)
            p.twoPaths(from: -40)
            p.horizonLight(-7, spread: 120)
            p.lampLine(from: -52, to: -52, count: 1)
            p.tree(46, 52); p.palm(78, 62)
            p.stars([(-150, 150), (-90, 176), (-20, 150), (60, 176)], size: 1.3)
        },
        // Steadfastness on the Truth: a great tree firm beside the road while the wind goes by (keep my heart firm).
        88: make("88-firm-tree") { p in
            p.at(110)
            p.road(to: -96, from: -160, width: 38)
            p.greatTree(16, 106)
            p.windStreaks(from: p.leftEdge, to: 110, at: 70)
            p.stars([(-150, 150), (-90, 176), (-40, 140)], size: 1.3)
        },
        // Dua for Good Character: the road running through a garden in flower, an olive tree and a spring beside it.
        89: make("89-garden-road") { p in
            p.at(110)
            p.road(to: -22, from: -74, width: 38)
            p.horizonLight(-22, spread: 130)
            p.olive(58, 72)
            p.spring(-116, scale: 2.0)
            p.flowers(from: p.leftEdge, to: -64); p.flowers(from: 8, to: 110)
            p.stars([(-150, 150), (-90, 176), (-30, 150)], size: 1.3)
        }
    ]

    // MARK: Forgiveness: a storm clearing over greening land

    private static let forgiveness: [Int: Cityscape] = [
        // Seeking Forgiveness: rain coming down on cracked, thirsting ground.
        28: make("28-first-rain") { p in
            p.at(110)
            p.crackedGround(from: p.leftEdge, to: 110)
            p.stormCloud(-6, 150, 190)
            p.house(-70, 30, 18)
            p.bareTree(50, 66)
            p.rain(from: -200, to: 140, height: 150)
        },
        // Comprehensive Forgiveness: the storm gone by, the wet road shining towards the light.
        29: make("29-clearing") { p in
            p.at(110)
            p.road(to: -60, from: -124, width: 38)
            p.horizonLight(-60, spread: 210)
            p.stormCloud(46, 160, 130)
            p.bareTree(70, 52)
            p.tree(4, 64)
            p.flowers(from: -40, to: 50); p.flowers(from: -150, to: -90)
            p.stars([(-150, 150), (-90, 176), (-30, 150)], size: 1.3)
        },
        // Dua for Laylat al-Qadr: light descending on a mosque among green fields in the still of the night.
        78: make("78-qadr") { p in
            p.at(110)
            p.greenField(from: p.leftEdge, to: 110)
            p.mosque(24, scale: 1.35)
            p.descendingLight(over: 14, spread: 180)
            p.mist(from: p.leftEdge, to: 110)
            p.stars([(-150, 150), (-100, 176), (-50, 150)], size: 1.3)
        },
        // Forgiveness for Self, Parents and Believers: the rain passing from over the homes of a whole town.
        79: make("79-town") { p in
            p.at(110)
            p.greenField(from: p.leftEdge, to: 110)
            p.stormCloud(48, 158, 130, lightning: false)
            p.sun(-70, 150, 14)
            p.town(-30, houses: 7, scale: 1.45)
            p.hearthSmoke(-54, 32)
            p.rain(from: 12, to: 150, height: 152)
        },
        // Dua of Adam and Hawwa: the garden's great tree and its spring, the cloud drawing off.
        80: make("80-garden") { p in
            p.at(110)
            p.stormCloud(52, 168, 110, lightning: false)
            p.greatTree(-2, 104)
            p.spring(-116, scale: 2.6)
            p.flowers(from: -170, to: 104)
            p.stars([(-150, 150), (-90, 176), (-40, 146)], size: 1.3)
        }
    ]

    // MARK: Gratitude: grain, vines, a garden

    private static let gratitude: [Int: Cityscape] = [
        // Thanking Allah: a wide field of ripe grain under the sun.
        38: make("38-harvest") { p in
            p.at(110)
            p.sun(-30, 152, 18)
            p.greenField(from: p.leftEdge, to: 110, ripeness: 0.6)
            p.house(-66, 34, 20)
            p.hearthSmoke(-72, 22)
            p.palm(50, 84); p.palm(80, 62)
            p.grain(from: p.leftEdge, to: 110)
            p.grazingSheep(-150, scale: 0.70); p.grazingSheep(-126, scale: 0.58)
        },
        // Dua of Sulayman for Gratitude: the valley floor with its small mounds, a garden beyond (27:18-19).
        90: make("90-valley") { p in
            p.at(110)
            p.peak(-196, 160, 46); p.peak(100, 100, 60)
            p.olive(50, 76)
            p.vines(-72, bays: 2)
            p.house(-12, 26, 16)
            p.anthills(from: -160, to: 20)
            p.stars([(-150, 150), (-90, 176), (-20, 150)], size: 1.3)
        },
        // Praising Allah Upon Receiving a Blessing: the vines heavy with fruit, a spring beside them.
        91: make("91-vines") { p in
            p.at(110)
            p.palm(64, 86); p.palm(-84, 64)
            p.vines(-8, bays: 4)
            p.spring(-124, scale: 2.0)
            p.flowers(from: -70, to: 100)
            p.stars([(-150, 150), (-90, 176), (-20, 150), (60, 176)], size: 1.3)
        }
    ]

    // MARK: Distress: a ship in heavy seas

    private static let distress: [Int: Cityscape] = [
        // Dua for Distress: the ship in the worst of it, rain and a heavy sea under a black sky.
        25: make("25-storm", backdrop: .open) { p in
            p.at(110)
            p.waves(from: p.leftEdge, to: 110, height: 14)
            p.stormCloud(0, 148, 210)
            p.ship(6, scale: 1.2)
            p.rain(from: p.leftEdge, to: 140)
        },
        // Dua of Yunus: the laden ship sailing on, and the bare shore with one broad-leaved plant growing on it (37:140-146).
        26: make("26-shore", backdrop: .open) { p in
            p.at(110)
            p.waves(from: p.leftEdge, to: 110, height: 9)
            p.island(40, 190, 12)
            p.fig(30, 44)
            p.ship(-150, scale: 0.55)
            p.stars([(-150, 150), (-90, 176), (-20, 150), (60, 176)], size: 1.3)
        },
        // When Anxious or Worried: a small boat in the swell making for a lit tower on the shore.
        27: make("27-harbour-light", backdrop: .open) { p in
            p.at(110)
            p.waves(from: p.leftEdge, to: 110, height: 10)
            p.stormCloud(-54, 160, 130)
            p.island(58, 130, 14)
            p.tower(58, 100)
            p.glow(58, 96, 18, SkylinePen.lampLight, 0.5, nightOnly: true)
            p.disc(58, 97, 2.2, .light)
            p.boat(-70, scale: 1.8)
        },
        // Dua of Ayyub: the storm over, a cool spring breaking out on the shore (38:42).
        74: make("74-spring", backdrop: .open) { p in
            p.at(110)
            p.water(from: p.leftEdge, to: 110, depth: 46)
            p.island(30, 270, 10)
            p.palm(84, 72)
            p.spring(6, scale: 3.4)
            p.boat(-170, scale: 1.3)
            p.stars([(-150, 150), (-90, 176), (-20, 150), (60, 176)], size: 1.3)
        },
        // Hasbunallah: the ship holding its course with the wind full in her sails.
        75: make("75-fair-wind", backdrop: .open) { p in
            p.at(110)
            p.waves(from: p.leftEdge, to: 110, height: 10)
            p.island(-210, 110, 18)
            p.windStreaks(from: p.leftEdge, to: 110, at: 140)
            p.ship(0, scale: 1.35)
        },
        // La Hawla Wa La Quwwata: a small boat carried on a great swell under the whole sky.
        76: make("76-small-boat", backdrop: .open) { p in
            p.at(110)
            p.waves(from: p.leftEdge, to: 110, height: 14)
            p.boat(10, scale: 2.5)
            p.constellations(over: -30, height: 184)
        },
        // Dua for Ease in Difficulty: the ship come in to still water under the lamps of a harbour town.
        77: make("77-harbour", backdrop: .open) { p in
            p.at(110)
            p.water(from: p.leftEdge, to: 110, depth: 46)
            p.town(48, houses: 6, scale: 1.3)
            p.lampLine(from: -30, to: -4, count: 2)
            p.ship(-112, scale: 0.75)
            p.stars([(-150, 150), (-90, 176), (-20, 150), (60, 176)], size: 1.3)
        }
    ]

    // MARK: Grief: a bare tree on a quiet slope

    private static let grief: [Int: Cityscape] = [
        // Inna Lillahi: the bare tree, and a road going on from it to the light (to Him we shall return).
        108: make("108-return") { p in
            p.at(110)
            p.hills(seed: 4, height: 24)
            p.road(to: -70, from: -130, width: 36)
            p.horizonLight(-70, spread: 200)
            p.bareTree(46, 92)
            p.mist(from: p.leftEdge, to: 110, at: 10)
            p.stars([(-150, 150), (-90, 176), (-20, 150), (60, 176)], size: 1.3)
        },
        // Dua for the Deceased: headstones on the slope in a soft rain (wash him with water, snow and hail).
        109: make("109-rain") { p in
            p.at(110)
            p.hills(seed: 9, height: 22)
            p.bareTree(68, 72)
            p.graves(from: -150, to: 40, count: 11)
            p.rain(from: p.leftEdge, to: 140, height: 180)
            p.stars([(-150, 150), (-90, 176), (40, 176)], size: 1.3)
        },
        // Dua for Patience in Grief: beside the bare tree a young one in leaf, flowers under it (something better in its place).
        110: make("110-new-leaf") { p in
            p.at(110)
            p.hills(seed: 4, height: 22)
            p.bareTree(-58, 80)
            p.tree(42, 60)
            p.flowers(from: 0, to: 104)
            p.mist(from: p.leftEdge, to: 0, at: 10)
            p.stars([(-150, 150), (-90, 176), (40, 176)], size: 1.3)
        },
        // Dua at the Graveside: the headstones at night, a lantern left burning beside them.
        111: make("111-graveside", ownMoon: true) { p in
            p.at(110)
            p.hills(seed: 12, height: 20)
            p.graves(from: -140, to: 20, count: 9)
            lampPost(&p, 72, 64, arm: -12)
            p.crescent(-10, 152, 10)
            p.mist(from: p.leftEdge, to: 110, at: 10)
        }
    ]

    // MARK: Illness: a house under an olive tree, a spring

    private static let illness: [Int: Cityscape] = [
        // Visiting the Sick: the path coming up to the house door, a lamp lit beside it.
        30: make("30-path") { p in
            p.at(110)
            p.road(to: 36, from: -56, width: 38)
            p.olive(-66, 76)
            home(&p, 36, 1.3)
            lampPost(&p, -16, 40, arm: -9)
        },
        // Dua for Healing: the spring rising clear by the olive tree (there is no cure but Your cure).
        31: make("31-spring") { p in
            p.at(110)
            p.olive(64, 76)
            home(&p, -152, 0.75)
            p.spring(-30, scale: 4.2)
            p.flowers(from: -120, to: 20)
        },
        // Ruqyah: the house at night, a lantern hung in the olive tree, one window awake.
        81: make("81-vigil") { p in
            p.at(110)
            p.olive(-72, 82)
            home(&p, 22, 1.25)
            p.hangingLantern(-46, from: 46, drop: 13)
            p.mist(from: p.leftEdge, to: 110)
            p.stars([(-150, 150), (-90, 176), (30, 180), (90, 150)], size: 1.3)
        },
        // Dua for Someone Who Is Ill: the house under the olive with a new day's light coming, flowers at the door.
        82: make("82-new-day") { p in
            p.at(110)
            p.horizonLight(-186, spread: 190)
            p.olive(46, 88)
            home(&p, -52, 1.2)
            p.flowers(from: -130, to: 100)
        },
        // Dua for Pain in the Body: the hearth kept warm, water and cups set out by the door.
        83: make("83-care") { p in
            p.at(110)
            p.olive(-136, 60)
            home(&p, 40, 1.25)
            p.hearthSmoke(60, 47)
            p.vessels(-58, scale: 1.2)
        }
    ]

    // MARK: Protection: a stronghold and the lamp at its gate

    private static let protection: [Int: Cityscape] = [
        // Protection from the Evil Eye: the stronghold's door shut fast, its lamp lit, palms behind the wall.
        39: make("39-shut-door") { p in
            p.at(110)
            p.palm(-92, 86); p.palm(-134, 72)
            p.stoneWall(-106, 150, 46)
            p.door(24, 50)
            p.stars([(-150, 150), (-60, 176), (60, 176)], size: 1.3)
        },
        // General Protection: the stronghold whole under the night sky, falling stars above it (nothing harms in the earth or the heavens).
        40: make("40-under-heaven") { p in
            p.at(110)
            p.fortress(6, 150, 52)
            p.constellations(over: -30, height: 186)
            p.shootingStars(over: -70)
            p.mist(from: p.leftEdge, to: 110)
        },
        // Last Two Verses of al-Baqarah: the pages open before the wall at night, light descending on them.
        92: make("92-two-verses") { p in
            p.at(110)
            p.fortress(40, 120, 46)
            p.pages(-86, scale: 1.7)
            p.descendingLight(over: -86, spread: 110)
            p.stars([(-150, 150), (-20, 176), (60, 176)], size: 1.3)
        },
        // Protection from Dajjal: the great gate shut and shining while a storm passes outside the wall.
        93: make("93-great-gate") { p in
            p.at(110)
            p.stormCloud(-40, 162, 140)
            p.windStreaks(from: p.leftEdge, to: 110, at: 118)
            p.stoneWall(-88, 100, 42); p.stoneWall(86, 60, 42)
            p.gate(10, 104, gilded: true)
        }
    ]

    // MARK: Home: a house and its hearth

    private static let house: [Int: Cityscape] = [
        // Leaving the Home: the road running out from the door, a lamp left lit beside it.
        21: make("21-leaving") { p in
            p.at(110)
            p.road(to: 46, from: -110, width: 46)
            home(&p, 46, 1.35)
            lampPost(&p, -8, 42, arm: -9)
            p.palm(-60, 60); p.tree(-136, 40)
        },
        // Entering the Home: the door standing open with the light inside, smoke from the hearth.
        22: make("22-entering") { p in
            p.at(110)
            home(&p, -4, 1.5, open: true)
            p.hearthSmoke(26, 56)
            p.palm(74, 76)
            lampPost(&p, -76, 46, arm: 9)
            p.flowers(from: -70, to: 60)
        }
    ]

    // MARK: Parents: a great tree sheltering a house

    private static let parents: [Int: Cityscape] = [
        // Dua for Parents: a young tree grown up in the shade of the great one (as they raised me when I was small).
        36: make("36-young-tree") { p in
            p.at(110)
            home(&p, -146, 0.7)
            p.greatTree(26, 100)
            p.tree(-76, 38)
            p.flowers(from: -110, to: 0)
        },
        // Dua for Deceased Parents: the great tree keeping its shade over two headstones.
        86: make("86-headstones") { p in
            p.at(110)
            p.greatTree(18, 106)
            p.graves(from: -130, to: -84, count: 2)
            p.mist(from: p.leftEdge, to: 110)
            p.stars([(-150, 150), (-100, 176), (-50, 146)], size: 1.3)
        },
        // Dua for Living Parents' Well-being: the house under the tree, its door open and lamps lit (whoever enters my house).
        87: make("87-open-house") { p in
            p.at(110)
            p.greatTree(34, 98)
            home(&p, -58, 1.2, open: true)
            p.hearthSmoke(-38, 45)
            p.lampLine(from: -156, to: -122, count: 2)
            p.flowers(from: -10, to: 100)
        }
    ]

    // MARK: Children: young trees and flowers by a home

    private static let children: [Int: Cityscape] = [
        // Dua for Newborn Protection: the home within its wall under a new moon, a sapling just planted outside.
        112: make("112-new-moon", ownMoon: true) { p in
            p.at(110)
            home(&p, 14, 1.3)
            p.stoneWall(14, 170, 14)
            p.tree(-104, 26)
            p.crescent(-44, 152, 10)
            p.stars([(-150, 150), (-96, 176), (20, 180), (90, 150)], size: 1.3)
        },
        // Dua for Righteous Children: the prayer niche where it was asked, young trees growing beside it (3:38).
        113: make("113-niche") { p in
            p.at(110)
            p.house(-144, 28, 17)
            p.prayerNiche(36, scale: 1.4)
            p.tree(-42, 34); p.tree(-80, 26)
            p.flowers(from: -116, to: -8)
        },
        // Dua of Ibrahim for His Offspring: the Sacred House in its bare valley, young palms coming up round it (14:37-40).
        114: make("114-valley") { p in
            p.at(110)
            p.peak(-136, 170, 60); p.peak(98, 110, 68)
            p.house(-96, 22, 13)
            p.kaaba(-6, 1.6)
            p.palm(-52, 26); p.palm(-70, 18); p.palm(38, 22)
            p.stars([(-150, 150), (-60, 176), (10, 150)], size: 1.3)
        },
        // Dua Upon Seeing a Newborn: three trees by the home, each taller than the last (may he reach maturity).
        115: make("115-growing") { p in
            p.at(110)
            home(&p, 72, 0.95)
            p.tree(-84, 26); p.tree(-46, 42); p.tree(4, 62)
            p.flowers(from: -120, to: 36)
        }
    ]

    // MARK: Marriage: a lantern-lit home among palms

    private static let marriage: [Int: Cityscape] = [
        // Dua on Seeing Spouse: the door of the new home, lamps either side and flowers at the threshold.
        100: make("100-threshold") { p in
            p.at(110)
            p.palm(-70, 80); p.palm(92, 62)
            p.door(14, 48)
            lampPost(&p, -56, 46, arm: -9)
            p.flowers(from: -110, to: 100)
        },
        // Dua Before Intercourse: the home closed within its wall for the night, a crescent over the palms.
        101: make("101-night", ownMoon: true) { p in
            p.at(110)
            p.palm(-72, 78); p.palm(86, 66)
            home(&p, 10, 1.35)
            p.stoneWall(10, 180, 16)
            p.crescent(-30, 154, 11)
            p.stars([(-150, 150), (-96, 176), (30, 182), (70, 146)], size: 1.3)
        },
        // Dua for a Righteous Spouse and Offspring: two palms grown together by the home, saplings and flowers round them.
        102: make("102-family") { p in
            p.at(110)
            home(&p, -58, 1.15)
            p.hearthSmoke(-40, 43)
            p.palm(18, 86); p.palm(44, 72)
            p.tree(82, 30); p.tree(-128, 26)
            p.flowers(from: -20, to: 110)
        },
        // Dua at a Wedding: banners out, lanterns strung across the yard and the table spread.
        103: make("103-wedding") { p in
            p.at(110)
            home(&p, 62, 1.0)
            p.block(-112, 1.6, 64)
            lanternString(&p, from: (-112, 63), to: (30, 38), count: 4)
            p.table(-46, scale: 1.6)
            p.banner(-140, 52, p.shade(0.18, 0.50, 0.38)); p.banner(-166, 40, p.shade(0.86, 0.84, 0.78))
        }
    ]

    // MARK: Food: a spread table

    private static let food: [Int: Cityscape] = [
        // Before Eating: the table just spread, steam rising, a lantern over it.
        16: make("16-spread") { p in
            p.at(110)
            p.palm(-112, 54)
            p.table(-6, scale: 2.8)
            lampPost(&p, 88, 80, arm: -12)
        },
        // After Eating: the table, and behind it the grain and the vines it came from (who fed me this and provided it).
        17: make("17-provision") { p in
            p.at(110)
            p.house(-150, 30, 18)
            p.hearthSmoke(-156, 20)
            p.vines(-86, bays: 2)
            p.table(34, scale: 2.1)
            p.grain(from: p.leftEdge, to: -124)
        },
        // Forgetting Bismillah Before Eating: the meal already under way in the arcade's court, a lantern lit over it.
        18: make("18-court") { p in
            p.at(110)
            hall(&p, -76, bays: 4, bay: 18, height: 40)
            p.table(34, scale: 2.2)
            p.stars([(-150, 150), (-90, 176), (-20, 150), (60, 176)], size: 1.3)
        },
        // Dua at Iftar: the table set at sunset in Ramadan, the mosque lit and the new moon up.
        65: make("65-iftar", ownMoon: true) { p in
            p.at(110)
            p.mosque(64, scale: 1.05)
            p.table(-38, scale: 2.2)
            p.crescent(4, 160, 11)
            p.stars([(-150, 150), (-90, 176), (-40, 146), (70, 176)], size: 1.3)
        },
        // Dua for the Host: the host's house and table, light coming down on them (may the angels send blessings upon you).
        67: make("67-host") { p in
            p.at(110)
            home(&p, -64, 1.2)
            p.hearthSmoke(-44, 45)
            p.lampLine(from: -150, to: -124, count: 2)
            p.table(46, scale: 2.0)
            p.descendingLight(over: 20, spread: 170)
        },
        // Dua When Invited to Eat: the table set out before the host's door, his lamp lit.
        66: make("66-guest") { p in
            p.at(110)
            p.door(52, 40)
            p.table(-58, scale: 2.0)
            p.stars([(-150, 150), (-90, 176), (-30, 150)], size: 1.3)
        },
        // Dua When Breaking the Fast: the jug and cups at day's end, the date palm over them (the thirst has gone).
        127: make("127-water") { p in
            p.at(110)
            p.horizonLight(-196, spread: 170)
            p.palm(82, 76)
            p.well(-118, scale: 1.8)
            p.vessels(-8, scale: 2.1)
            p.stars([(-150, 150), (-90, 176), (-20, 160), (40, 180)], size: 1.3)
        }
    ]

    // MARK: Business: market stalls and the scales

    private static let business: [Int: Cityscape] = [
        // Dua for Provision: the scales standing level over a field of grain (suffice me with what is lawful).
        116: make("116-lawful") { p in
            p.at(110)
            p.palm(-92, 52)
            p.scales(8, 108)
            p.grain(from: p.leftEdge, to: -60)
            p.stars([(-150, 150), (-90, 176), (90, 170)], size: 1.3)
        },
        // Dua for Paying Off Debt: the scales, and beyond them a clear road running to the light.
        117: make("117-debt") { p in
            p.at(110)
            p.road(to: -104, from: -166, width: 38)
            p.horizonLight(-104, spread: 190)
            p.scales(30, 98)
            p.stars([(-150, 150), (-90, 176), (-20, 150), (60, 176)], size: 1.3)
        },
        // Dua for Barakah in Wealth: the stalls full, palms and grain standing behind them.
        118: make("118-plenty") { p in
            p.at(110)
            p.palm(60, 88); p.palm(84, 64)
            p.fig(-130, 46)
            p.market(-30, stalls: 3)
            p.grain(from: 36, to: 110)
        },
        // Dua at the Market: the market street, the town's houses lit behind the stalls.
        119: make("119-market") { p in
            p.at(110)
            p.town(50, houses: 5, scale: 1.4)
            p.market(-70, stalls: 3)
            p.lampLine(from: -150, to: -150, count: 1)
            p.banner(-8, 46, p.shade(0.70, 0.26, 0.20))
        }
    ]

    // MARK: Travel: a road through the dunes

    private static let travel: [Int: Cityscape] = [
        // Travel Dua: the road going on through the high dunes, sand blowing across it.
        19: make("19-dunes", backdrop: .open) { p in
            p.at(p.width / 2)
            p.dunes([(-140, 120, 34), (60, 150, 46), (190, 80, 20)])
            p.road(to: -30, from: -110, width: 36)
            p.driftingSand(from: -p.width / 2, to: p.width / 2)
            p.at(110)
            p.palm(80, 50)
            p.desertCamel(-148, scale: 0.75)
            p.sceneTraveler(-116, scale: 0.8)
            p.stars([(-150, 150), (-90, 176), (-20, 150), (40, 180), (90, 150)], size: 1.3)
        },
        // Entering a Town or City: the town's gate, its houses to either side and the road going in.
        20: make("20-town-gate") { p in
            p.at(110)
            p.road(to: 6, from: -50, width: 48)
            p.town(-86, houses: 4, scale: 1.2); p.town(84, houses: 3, scale: 1.1)
            p.hearthSmoke(-98, 26)
            p.palm(-156, 52)
            p.gate(6, 104)
        },
        // Stopping at a Place: tents pitched by a well, a fire lit for the night.
        68: make("68-camp") { p in
            p.at(110)
            p.palm(86, 70)
            p.well(-112, scale: 1.8)
            p.tent(4, 72, 48); p.tent(58, 44, 28)
            p.campfire(-54, 0, scale: 1.3)
            p.stars([(-150, 150), (-90, 176), (-20, 150), (40, 180)], size: 1.3)
        },
        // Returning From Travel: the home town in sight at the road's end, its lamps lit.
        69: make("69-return") { p in
            p.at(110)
            p.road(to: 20, from: -110, width: 42)
            p.town(30, houses: 7, scale: 1.3)
            p.palm(98, 50)
            p.lampLine(from: -130, to: -50, count: 3)
        },
        // Dua for the Traveler: the house he left, one window lit, the road running away from it.
        70: make("70-lit-window") { p in
            p.at(p.width / 2)
            p.dunes([(-150, 100, 20)])
            p.at(110)
            p.road(to: 20, from: -170, width: 40)
            home(&p, 52, 1.25)
            p.tree(-28, 42)
            p.stars([(-150, 150), (-90, 176), (-20, 150)], size: 1.3)
        },
        // Dua at the Beginning of a Journey: the road leaving the town at first light.
        71: make("71-setting-out") { p in
            p.at(110)
            p.horizonLight(-186, spread: 200)
            p.road(to: 4, from: -150, width: 46)
            p.town(50, houses: 6, scale: 1.3)
            p.palm(-24, 50)
        }
    ]

    // MARK: Hajj: the Kaaba and the tents of Mina

    private static let hajj: [Int: Cityscape] = [
        // Talbiyah: the pilgrim road coming down between the mountains, the Kaaba in sight at its end.
        104: make("104-talbiyah") { p in
            p.at(110)
            p.peak(-186, 150, 60); p.peak(96, 100, 74)
            p.road(to: 6, from: -76, width: 46)
            p.kaaba(6, 0.9)
            p.tentCamp(-112, count: 7)
            p.banner(-44, 40, p.shade(0.90, 0.88, 0.82))
            p.stars([(-150, 150), (-60, 176), (10, 150)], size: 1.3)
        },
        // Dua at the Ka'bah: the House itself, close, between the arcades of the Sacred Mosque.
        105: make("105-kaaba") { p in
            p.at(110)
            p.arcade(-104, bays: 4, bay: 16, height: 30); p.arcade(88, bays: 2, bay: 16, height: 30)
            p.tallMinaret(-146, 84); p.tallMinaret(98, 108, width: 6.4)
            p.kaaba(4, 2.5)
            lampPost(&p, -56, 50, arm: -9, scale: 0.9); lampPost(&p, 62, 50, arm: 9, scale: 0.9)
            p.stars([(-150, 150), (-90, 176), (-40, 150), (50, 180)], size: 1.3)
        },
        // Dua at Safa and Marwa: the two hills and the lamp-lit way between them.
        106: make("106-safa-marwa") { p in
            p.at(110)
            p.peak(-106, 96, 50); p.peak(66, 88, 58, lean: 3)
            p.tint(p.polygon([(-66, 0.6), (28, 0.6), (40, -7), (-80, -7)]), p.shade(0.78, 0.70, 0.56, 0.36))
            p.lampLine(from: -52, to: 14, count: 4)
            p.kaaba(-196, 0.9)
            p.mist(from: p.leftEdge, to: 110)
            p.stars([(-150, 150), (-90, 176), (-10, 160)], size: 1.3)
        },
        // Dua at Arafah: the plain of Arafah, the Mount of Mercy with its pillar, tents across the plain.
        107: make("107-arafah") { p in
            p.at(110)
            p.sun(-56, 158, 16)
            p.peak(18, 180, 80)
            p.block(18, 5, 14, from: 76)
            p.tint(p.blockPath(18, 5, 14, from: 76), p.shade(0.92, 0.90, 0.84, 0.9))
            p.tentCamp(-124, count: 9); p.tentCamp(-40, count: 5)
        }
    ]

    // MARK: Weather: cloud, rain and wind

    private static let weather: [Int: Cityscape] = [
        // When It Rains: steady rain on a green field and the house beside it (a beneficial rain).
        32: make("32-rain") { p in
            p.at(110)
            p.greenField(from: p.leftEdge, to: 110)
            p.stormCloud(-10, 156, 180)
            home(&p, 30, 1.1)
            p.palm(-42, 58)
            p.rain(from: p.leftEdge, to: 140)
        },
        // After Rain: the cloud gone off, the sun out, a stream running and flowers open.
        33: make("33-after-rain") { p in
            p.at(110)
            p.greenField(from: p.leftEdge, to: 110)
            p.river(from: -64, to: -124, width: 80, naturalBanks: true)
            p.stormCloud(56, 168, 120, lightning: false)
            p.sun(-56, 152, 16)
            p.house(-10, 30, 18)
            p.tree(66, 66)
            p.flowers(from: -40, to: 110)
        },
        // During Thunder: the thundercloud heavy over the mountains, lightning in it, the wind up.
        34: make("34-thunder") { p in
            p.at(110)
            p.peak(-76, 190, 76); p.peak(70, 130, 96, lean: -4)
            p.stormCloud(4, 142, 200)
            p.windStreaks(from: p.leftEdge, to: 110, at: 100)
            // Preserve the small foreground group at narrow screen widths.
            p.house(max(-196, p.leftEdge + 53), 26, 15)
            p.bareTree(max(-226, p.leftEdge + 14), 40)
        }
    ]

    // MARK: Dhikr: a still night under the stars

    private static let dhikr: [Int: Cityscape] = [
        // SubhanAllah wa Bihamdihi x100: the sea breaking in foam on a still night (though they were as the foam of the sea).
        94: make("94-foam", backdrop: .open) { p in
            p.at(110)
            p.waves(from: p.leftEdge, to: 110, height: 9)
            p.island(56, 150, 26)
            p.palm(50, 70); p.palm(74, 56)
            p.stars([(-150, 150), (-110, 180), (-60, 140), (-20, 172), (20, 150), (60, 184), (92, 150)], size: 1.4)
            p.shootingStars(over: -60)
        },
        // The Best Dhikr: one palm and one bright star over the still desert.
        95: make("95-one-star", backdrop: .open) { p in
            p.at(p.width / 2)
            p.dunes([(-150, 110, 18), (60, 140, 24)])
            p.at(110)
            p.palm(40, 94)
            p.brightStar(-30, 160)
            p.mist(from: p.leftEdge, to: 110)
        },
        // Salawat on the Prophet: the green dome of Madinah in the still night, light descending on it.
        96: make("96-madinah") { p in
            p.at(110)
            p.greenDome(0, scale: 0.95)
            p.palm(-106, 50); p.palm(94, 44)
            p.descendingLight(over: 0, spread: 170)
            p.stars([(-150, 150), (-100, 176), (-50, 150), (70, 178)], size: 1.3)
        },
        // Hasbiyallah: one lamp-lit tent alone in the wide desert under all the stars (He is sufficient for me).
        97: make("97-one-tent", backdrop: .open) { p in
            p.at(p.width / 2)
            p.dunes([(-160, 120, 22), (130, 130, 18)])
            p.at(110)
            p.tent(10, 78, 52)
            p.stars([(-160, 150), (-120, 182), (-80, 136), (-40, 168), (0, 190), (30, 150), (64, 176), (92, 140), (-10, 120), (-150, 116)], size: 1.4)
            p.mist(from: p.leftEdge, to: 110)
        },
        // Two words heavy on the scales: the balance standing under the stars.
        98: make("98-scales", backdrop: .open) { p in
            p.at(p.width / 2)
            p.dunes([(-150, 110, 18), (150, 100, 14)])
            p.at(110)
            p.scales(10, 106)
            p.stars([(-150, 150), (-100, 178), (-60, 140), (30, 184), (88, 160)], size: 1.4)
            p.shootingStars(over: -70)
        },
        // Complete Tasbih, Tahmid, Takbir: four palms by still water, the sun over them (dearer than all the sun rises on).
        99: make("99-four-palms", backdrop: .open) { p in
            p.at(110)
            p.water(from: p.leftEdge, to: 110, depth: 30)
            p.sun(-12, 166, 14)
            p.palm(-64, 60); p.palm(-22, 78); p.palm(20, 68); p.palm(62, 86)
            p.stars([(-150, 150), (-100, 178), (-40, 160), (30, 184), (88, 160)], size: 1.4)
        }
    ]
}
