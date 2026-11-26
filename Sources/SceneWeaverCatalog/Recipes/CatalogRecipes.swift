import SwiftUI
import SceneWeaver

// Shared unchanged by the native catalog and the browser's Swift runtime.
struct CatalogRecipe {
    let id:String;let name:String;let category:String;let tags:[String];let city:Cityscape
}
enum CatalogRecipes {
    private static func title(_ id: String) -> String {
        id.split(separator: "-").map { $0.prefix(1).uppercased() + $0.dropFirst() }.joined(separator: " ")
    }
    static let scenes: [CatalogRecipe] = {
        var result: [CatalogRecipe] = []
        func add(_ city: Cityscape, _ category: String, _ name: String? = nil, _ tags: [String] = []) {
            result.append(CatalogRecipe(id: city.id, name: name ?? (city.name.isEmpty ? title(city.id) : city.name),
                               category: category, tags: tags, city: city))
        }
        add(Cityscape(id:"coastal-town",name:"Coastal town",latitude:0,longitude:0,backdrop:.hills) { p in
            p.at(p.width*0.70);p.shape([(-12,0),(12,0),(7,90),(-7,90)]);p.block(0,26,4,from:76);p.block(0,21,13,from:80);p.shape([(-14,93),(14,93),(0,106)]);p.block(0,13,8,from:82,.light);p.beacon(0,106)
            for x: CGFloat in [-56,-30,30,56] { p.block(x,3,12) };p.block(0,132,3,from:10)
        },"Examples")
        for (id,name,group) in [("alpine","Alpine hideaway","Starter scenes"),("harbor","Harbor at dusk","Starter scenes"),("gallery-layered","Native gallery · Layered forest","Examples"),("haramcourtyard","Makkah · Original illustration","Illustrations"),("nabawicourtyard","Madinah · Original illustration","Illustrations")] {
            add(Cityscape(id:id,name:name,latitude:0,longitude:0,wild:true,draw:{_ in}),group)
        }
        for city in Cityscape.all { add(city, "Cities", nil, city.aliases) }
        add(.mountainOfLight, "Landscapes", "Mountain of Light")
        add(.oasis, "Landscapes", "Oasis")
        add(.masjidAlHaram, "Illustrations", "Makkah · Masjid al-Haram", ["Mecca", "Kaaba"])
        add(.masjidAnNabawi, "Illustrations", "Madinah · Masjid an-Nabawi", ["Medina"])
        var locations:[String:(Int,Int)]=[:]
        for number in 1...114 {for portion in SurahScenes.portions(of:number){locations[portion.scene.id]=(number,portion.from)}}
        for key in SurahScenes.byID.keys.sorted() { if let scene = SurahScenes.byID[key] {
            var words=key.split(separator:"-").map(String.init)
            let prefixed=words.first.flatMap{Int($0.dropFirst())}
            if prefixed != nil {words.removeFirst()}
            let number=locations[key]?.0 ?? prefixed
            let label=(number.map{"Surah \($0) · "} ?? "Surah scene · ")+title(words.joined(separator:"-"))
            add(scene,"Surah scenes",label,number.map{["surah \($0)","ayah \(locations[key]?.1 ?? 1)"]} ?? [])
        } }
        for key in DuaScenes.byCategory.keys.sorted() { if let scene = DuaScenes.byCategory[key] { add(scene, "Dua categories", title(key.replacingOccurrences(of: "_", with: "-"))) } }
        for key in DuaScenes.byDua.keys.sorted() { if let scene = DuaScenes.byDua[key] { add(scene, "Dua scenes", "Dua \(key) · \(title(scene.id.split(separator:"-").dropFirst(2).joined(separator:"-")))") } }
        return result
    }()
}
