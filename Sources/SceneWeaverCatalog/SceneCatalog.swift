import SwiftUI
import SceneWeaver
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// The complete optional scene collection. The core engine has no dependency on it.
public enum SceneCatalog {
    public struct Item: Identifiable {
        public let id: String
        public let name: String
        public let category: String
        public let tags: [String]
        let city: Cityscape
        public var definition: SceneDefinition {
            if ["alpine","harbor","gallery-layered","haramcourtyard","nabawicourtyard"].contains(id),
               let url=Bundle.module.url(forResource:id,withExtension:"json"),let bytes=try? Data(contentsOf:url),let project=try? SceneProject(data:bytes),
               let scene=try? project.definition(image:{SceneCatalog.artwork(named:$0)}) {return scene}
            let backdrop = SceneBackdrop(rawValue: String(describing: city.backdrop)) ?? .open
            var scene = SceneDefinition(backdrop: backdrop, wild: city.wild, ownMoon: city.ownMoon,
                illustrated: city.quranScene, movesForRTL: city.rtlPlacement == .leftMargin, draw: city.draw)
            if city.courtyard { scene.reservedHeight = HolyCourtyardLayout.reservedHeight }
            let haram = id == "masjid-al-haram"
            if haram || id == "masjid-an-nabawi" {
                scene.render = { context, frame in
                    let artwork = haram ? CourtyardRenderer.haramArtwork : CourtyardRenderer.nabawiArtwork
                    if let artwork {
                        CourtyardRenderer(now: frame.date, animated: frame.motionEnabled).illustratedCourtyard(
                            &context, frame.size, horizon: frame.horizon, artwork: artwork, haram: haram,
                            darkness: frame.darkness, glow: frame.glow, time: frame.time)
                    }
                }
            }
            return scene
        }
        /// Native procedural geometry, also used by the portable catalog exporter.
        public func geometry(width: CGFloat, horizon: CGFloat, time: Double = 0,
                             night: Double = 0, date: Date? = nil, rtl: Bool = false) -> ScenePen {
            var pen = ScenePen(width: width, horizon: horizon, time: time, night: night,
                               clockDate: date, illustrated: city.quranScene)
            city.draw(&pen)
            if rtl && city.rtlPlacement == .leftMargin { pen.moveToLeftMargin() }
            return pen
        }
    }
    public static let scenes:[Item] = CatalogRecipes.scenes.map { Item(id:$0.id,name:$0.name,category:$0.category,tags:$0.tags,city:$0.city) }
    private static let imageLock=NSLock()
    private static var imageCache:[String:Image]=[:]
    public static func artwork(named name:String)->Image? {
        imageLock.lock();defer{imageLock.unlock()}
        if let existing=imageCache[name]{return existing}
        guard let url=artworkURL(named:name)else{return nil}
        #if canImport(UIKit)
        guard let decoded=UIImage(contentsOfFile:url.path)else{return nil}
        let image=Image(uiImage:decoded)
        #else
        guard let decoded=NSImage(contentsOf:url)else{return nil}
        let image=Image(nsImage:decoded)
        #endif
        imageCache[name]=image;return image
    }
    public static func artworkURL(named name:String)->URL? {
        guard !name.contains("/"),!name.contains("..") else{return nil}
        return Bundle.module.url(forResource:name,withExtension:"png")
    }
    public static func scene(id: String) -> Item? { scenes.first { $0.id == id } }
}
