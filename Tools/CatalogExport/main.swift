import Foundation
import SwiftUI
import AppKit
import SceneWeaver
import SceneWeaverCatalog

func rounded(_ value: Double, _ places: Double = 1000) -> Double { value.isFinite ? (value * places).rounded() / places : 0 }
func pathData(_ path: Path) -> String {
    var parts: [String] = []
    func n(_ value: CGFloat) -> String { var result=String(format: "%.3f", Double(value)); while result.last == "0" { result.removeLast() }; if result.last == "." { result.removeLast() }; return result }
    path.forEach { item in
        switch item {
        case .move(to: let p): parts.append("M\(n(p.x)) \(n(p.y))")
        case .line(to: let p): parts.append("L\(n(p.x)) \(n(p.y))")
        case .quadCurve(to: let p, control: let c): parts.append("Q\(n(c.x)) \(n(c.y)) \(n(p.x)) \(n(p.y))")
        case .curve(to: let p, control1: let a, control2: let b): parts.append("C\(n(a.x)) \(n(a.y)) \(n(b.x)) \(n(b.y)) \(n(p.x)) \(n(p.y))")
        case .closeSubpath: parts.append("Z")
        }
    }
    return parts.joined(separator: " ")
}
var colorCache: [Color:[Double]] = [:]
func rgba(_ color: Color) -> [Double] {
    if let value=colorCache[color] { return value }
    let c = NSColor(color).usingColorSpace(.sRGB) ?? .black
    let result = [c.redComponent,c.greenComponent,c.blueComponent,c.alphaComponent].map { min(1,max(0,rounded(Double($0), 10000))) }; colorCache[color]=result; return result
}
if CommandLine.arguments.contains("--help") {
    print("Usage: swift run SceneWeaverCatalogExport [output-directory] [--inventory]\nExports native inventory or static fallback geometry. Rebuild live geometry with scripts/build-wasm.py.")
    exit(0)
}
let root = URL(fileURLWithPath: CommandLine.arguments.dropFirst().first(where: { !$0.hasPrefix("--") }) ?? "studio/assets")
let directory = root.appendingPathComponent("library")
try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
if CommandLine.arguments.contains("--inventory") {
    let inventory=SceneCatalog.scenes.map{["id":$0.id,"name":$0.name,"category":$0.category,"tags":$0.tags] as [String:Any]}
    try JSONSerialization.data(withJSONObject:inventory,options:[.sortedKeys,.prettyPrinted]).write(to:root.appendingPathComponent("swift-inventory.json"))
    print("Inventoried \(inventory.count) native catalog scenes");exit(0)
}
var inventory: [[String: Any]] = []
for (index,item) in SceneCatalog.scenes.enumerated() {
    if item.category == "Illustrations" || ["alpine","harbor","gallery-layered"].contains(item.id) { continue }
    let existingName = "native-" + item.id
    if CommandLine.arguments.contains("--resume"), let bytes=try? Data(contentsOf: directory.appendingPathComponent(existingName+".geometry.json")),
       let old=(try? JSONSerialization.jsonObject(with:bytes)) as? [String:Any], old["motion"] != nil {
        inventory.append(["id":existingName,"name":item.name,"category":item.category,"tags":item.tags+[item.id],"project":existingName+".json","nativeID":item.id]); continue
    }
    colorCache.removeAll(keepingCapacity:true)
    var pool: [String] = [], lookup: [String:Int] = [:]
    func intern(_ path: Path) -> Int {
        let key=path.description
        if let id=lookup[key] { return id }
        let id=pool.count; pool.append(pathData(path));lookup[key]=id;return id
    }
    func frame(_ time: Double, _ night: Double) -> [String:Any] {
        let p=item.geometry(width:402,horizon:224,time:time,night:night,date:Date(timeIntervalSince1970:43200))
        return ["solids":p.solids.map(intern),"holes":p.holes.map(intern),"lights":p.lights.map(intern),
                "tints":p.tints.map { t -> [String:Any] in
                    var value: [String:Any] = ["path":intern(t.path),"color":rgba(t.color),"nightOnly":t.nightOnly,"bounds":[rounded(Double(t.path.boundingRect.minX)),rounded(Double(t.path.boundingRect.minY)),rounded(Double(t.path.boundingRect.width)),rounded(Double(t.path.boundingRect.height))]]
                    if let lower=t.lowerColor { value["lower"]=rgba(lower) };return value
                },"beacons":p.beacons.map{[rounded(Double($0.x)),rounded(Double($0.y))]}]
    }
    // Geometry is captured from the shipping Swift recipes, never redrawn by hand.
    let day=frame(0,0), night=frame(0,1)
    let samples = CommandLine.arguments.contains("--motion") ? 48 : 0
    var motion: [[String:Any]] = []
    if samples > 0 {
        for tick in 0..<samples {
            let t = Double(tick) / 2
            let a = frame(t, 0), b = frame(t, 1)
            func delta(_ current: [String:Any], _ base: [String:Any]) -> [String:Any] {
                current.filter { key, value in
                    guard let old=base[key] else { return true }
                    return !NSDictionary(dictionary:[key:value]).isEqual(to:[key:old])
                }
            }
            motion.append(["day":delta(a,day),"night":delta(b,night)])
        }
    }
    var shape: [String:Any] = ["version":1,"width":402,"horizon":224,"paths":pool,"day":day,"night":night,
                             "backdrop":item.definition.backdrop.rawValue,"wild":item.definition.wild,
                             "ownMoon":item.definition.ownMoon,"illustrated":item.definition.illustrated,
                             "movesForRTL":item.definition.movesForRTL]
    if !motion.isEmpty { shape["motion"] = ["fps":2,"duration":24,"frames":motion] }
    let name="native-"+item.id
    try JSONSerialization.data(withJSONObject:shape,options:[.sortedKeys]).write(to:directory.appendingPathComponent(name+".geometry.json"))
    let project: [String:Any] = ["version":1,"name":item.name,"settings":["hour":18.6,"weather":"clear","ground":36,"aspectRatio":1.5,"overscan":1.12,"viewport":1.5,"motion":true,"schedule":[5,6,12,15,18,19.5]],"layers":[],"nativeScene":["id":item.id,"src":"library/"+name+".geometry.json"]]
    try JSONSerialization.data(withJSONObject:project,options:[.sortedKeys]).write(to:root.appendingPathComponent(name+".json"))
    inventory.append(["id":name,"name":item.name,"category":item.category,"tags":item.tags+[item.id],"project":name+".json","nativeID":item.id])
    if index % 40 == 0 { print("Exported \(index + 1)/\(SceneCatalog.scenes.count)") }
}
try JSONSerialization.data(withJSONObject:inventory,options:[.sortedKeys,.prettyPrinted]).write(to:root.appendingPathComponent("native-catalog.json"))
print("Exported \(inventory.count) native scenes")
