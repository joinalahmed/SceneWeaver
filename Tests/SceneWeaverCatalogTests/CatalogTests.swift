import XCTest
import SwiftUI
import SceneWeaver
import SceneWeaverCatalog

final class CatalogTests:XCTestCase {
    func testCompleteInventoryAndNoDuplicateScenes(){
        XCTAssertEqual(SceneCatalog.scenes.count,428)
        XCTAssertEqual(Set(SceneCatalog.scenes.map(\.id)).count,428)
        XCTAssertEqual(SceneCatalog.scenes.filter{$0.category=="Cities"}.count,23)
        XCTAssertEqual(SceneCatalog.scenes.filter{$0.category=="Surah scenes"}.count,241)
        XCTAssertEqual(SceneCatalog.scenes.filter{$0.category=="Dua categories"}.count,27)
        XCTAssertEqual(SceneCatalog.scenes.filter{$0.category=="Dua scenes"}.count,127)
        for id in ["masjid-al-haram","masjid-an-nabawi","alpine","harbor","coastal-town","gallery-layered"]{XCTAssertNotNil(SceneCatalog.scene(id:id))}
    }
    func testEveryProceduralRecipeDrawsFiniteGeometryInDayAndNight(){
        for item in SceneCatalog.scenes where item.definition.render == nil {
            for (time,night) in [(0.0,0.0),(3.7,1.0)] {
                let pen=item.geometry(width:402,horizon:224,time:time,night:night)
                let paths=pen.solids+pen.holes+pen.lights+pen.tints.map(\.path)
                XCTAssertFalse(paths.isEmpty,item.id)
                for path in paths where !path.isEmpty {
                    XCTAssertTrue(path.boundingRect.minX.isFinite && path.boundingRect.minY.isFinite,item.id)
                }
            }
        }
    }
    func testAllIllustrationAndGalleryPlatesAreBundled(){
        for name in ["HaramBackground","HaramForeground","HaramCourtyard","NabawiBackgroundV2","NabawiForeground","NabawiCourtyard","GalleryDistant","GalleryNear","Alpine_distance","Harbor_distance"] {
            XCTAssertNotNil(SceneCatalog.artworkURL(named:name),name)
        }
        XCTAssertNil(SceneCatalog.artworkURL(named:"../outside"))
    }
}
