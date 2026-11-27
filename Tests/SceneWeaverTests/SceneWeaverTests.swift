import XCTest
import SwiftUI
@testable import SceneWeaver

final class SceneWeaverTests: XCTestCase {
    func testLayerRegistrationAndViewportCoverage() {
        for width: CGFloat in [320, 375, 402, 440, 660, 1024] {
            for motion: CGFloat in [-1, 0, 1] {
                for depth: CGFloat in [0, 1, 2, 3] {
                    let r = ArtworkLayout.rect(width: width, horizon: 320, motion: motion, depth: depth)
                    XCTAssertLessThanOrEqual(r.minX, 0)
                    XCTAssertGreaterThanOrEqual(r.maxX, width)
                    XCTAssertEqual(r.maxY, 320, accuracy: 0.001)
                    XCTAssertEqual(r.width / r.height, 1.5, accuracy: 0.001)
                }
            }
        }
    }

    func testScheduleRejectsMissingEqualAndReversedTimes() {
        let dates = (0..<6).map { Date(timeIntervalSince1970: Double($0) * 3600) }
        XCTAssertTrue(DaylightSchedule(orderedDates: dates).isValid)
        XCTAssertFalse(DaylightSchedule(orderedDates: Array(dates.prefix(5))).isValid)
        XCTAssertFalse(DaylightSchedule(orderedDates: dates.reversed()).isValid)
        XCTAssertFalse(DaylightSchedule(orderedDates: Array(repeating: dates[0], count: 6)).isValid)
    }

    func testDepthMovesNearPartsFurtherAndLeavesAFlatSceneAlone() {
        func drawn(shift: CGFloat) -> ScenePen {
            var pen = ScenePen(width: 400, horizon: 200, shift: shift)
            pen.at(100)
            pen.depth = 0.5; pen.block(0, 20, 40)
            pen.depth = 1.5; pen.disc(0, 30, 4, .light); pen.beacon(0, 60)
            pen.depth = 1; pen.shape([(-5, 0), (5, 0), (0, 20)])
            return pen
        }
        let flat = drawn(shift: 0), moved = drawn(shift: 10)
        XCTAssertEqual(moved.solids[0].boundingRect.minX - flat.solids[0].boundingRect.minX, 5, accuracy: 0.001)
        XCTAssertEqual(moved.lights[0].boundingRect.minX - flat.lights[0].boundingRect.minX, 15, accuracy: 0.001)
        XCTAssertEqual(moved.beacons[0].x - flat.beacons[0].x, 15, accuracy: 0.001)
        XCTAssertEqual(moved.solids[1].boundingRect.minX - flat.solids[1].boundingRect.minX, 10, accuracy: 0.001)
        XCTAssertEqual(moved.solids[0].boundingRect.minY, flat.solids[0].boundingRect.minY, accuracy: 0.001)
        // The margin is measured at rest, so a tilted skyline keeps its displacement.
        var placed = moved
        placed.move(by: flat.leftMarginOffset ?? 0)
        XCTAssertEqual(placed.solids[0].boundingRect.minX, 8 + 5, accuracy: 0.001)
    }

    func testTransformsKeepMaterialsAndLightsRegistered() {
        var pen = ScenePen(width: 400, horizon: 200)
        pen.at(100)
        let path = pen.blockPath(0, 20, 40)
        pen.block(0, 20, 40); pen.block(0, 5, 5, .light)
        pen.wash(path, top: .red, bottom: .blue); pen.beacon(0, 40)
        let original = pen.solids[0].boundingRect
        pen.apply(CGAffineTransform(translationX: 14, y: -7))
        XCTAssertEqual(pen.solids[0].boundingRect, original.offsetBy(dx: 14, dy: -7))
        XCTAssertEqual(pen.tints[0].path.boundingRect, pen.solids[0].boundingRect)
        XCTAssertNotNil(pen.tints[0].lowerColor)
        XCTAssertEqual(pen.beacons[0], CGPoint(x: 314, y: 153))
        var combined = ScenePen(width: 400, horizon: 200)
        combined.merge(pen)
        XCTAssertEqual(combined.lights.count, 1)
        XCTAssertEqual(combined.tints.count, 1)
        XCTAssertNotNil(combined.tints[0].lowerColor)
        combined.occludeLights(behind: pen.solids[0])
        XCTAssertTrue(combined.lights.isEmpty)
    }

    func testRTLTranslatesWithoutReflecting() {
        var pen = ScenePen(width: 400, horizon: 200)
        pen.at(100); pen.shape([(0, 0), (10, 0), (0, 30)])
        let width = pen.solids[0].boundingRect.width
        pen.moveToLeftMargin()
        XCTAssertEqual(pen.solids[0].boundingRect.minX, 8)
        XCTAssertEqual(pen.solids[0].boundingRect.width, width)
        XCTAssertTrue(pen.solids[0].contains(CGPoint(x: 9, y: 180)))
        XCTAssertFalse(pen.solids[0].contains(CGPoint(x: 17, y: 180)))
    }
}
