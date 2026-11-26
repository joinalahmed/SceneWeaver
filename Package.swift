// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SceneWeaver",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [.library(name: "SceneWeaver", targets: ["SceneWeaver"])],
    targets: [
        .target(name: "SceneWeaver"),
        .target(name: "SceneWeaverExamples", dependencies: ["SceneWeaver"], path: "Examples"),
        .testTarget(name: "SceneWeaverTests", dependencies: ["SceneWeaver"])
    ]
)
