// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SceneWeaver",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [.library(name: "SceneWeaver", targets: ["SceneWeaver"]),
        .library(name: "SceneWeaverCatalog", targets: ["SceneWeaverCatalog"])],
    targets: [
        .target(name: "SceneWeaver"),
        .target(name: "SceneWeaverCatalog", dependencies: ["SceneWeaver"], resources: [.process("Resources")]),
        .target(name: "SceneWeaverExamples", dependencies: ["SceneWeaver"], path: "Examples"),
        .executableTarget(name: "SceneWeaverCatalogExport", dependencies: ["SceneWeaver", "SceneWeaverCatalog"], path: "Tools/CatalogExport"),
        .testTarget(name: "SceneWeaverTests", dependencies: ["SceneWeaver"]),
        .testTarget(name: "SceneWeaverCatalogTests", dependencies: ["SceneWeaver", "SceneWeaverCatalog"])
    ]
)
