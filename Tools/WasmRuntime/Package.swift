// swift-tools-version:6.0
import PackageDescription
let package=Package(name:"SceneWeaverRuntime",products:[.executable(name:"SceneWeaverRuntime",targets:["Recipes"])],targets:[
 .target(name:"SwiftUI"),
 .target(name:"SceneWeaver",dependencies:["SwiftUI"]),
 .executableTarget(name:"Recipes",dependencies:["SwiftUI","SceneWeaver"],linkerSettings:[.unsafeFlags(["-Xclang-linker","-mexec-model=reactor","-Xlinker","--strip-all","-Xlinker","--export=scene_alloc","-Xlinker","--export=scene_free","-Xlinker","--export=scene_index","-Xlinker","--export=scene_render","-Xlinker","--export=scene_result_length"])])
],swiftLanguageModes:[.v5])
