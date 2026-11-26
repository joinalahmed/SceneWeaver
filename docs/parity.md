# SwiftUI, React and Studio parity

Version 0.2.0 includes the entire original scene library: **428 scenes**. The optional `SceneWeaverCatalog` Swift product and `studio/assets/catalog.json` expose the same IDs.

| Library | Scenes |
| --- | ---: |
| Cities | 23 |
| Surah scenes and variants | 241 |
| Dua categories | 27 |
| Individual dua scenes | 127 |
| Landscapes | 2 |
| Layered mosque illustrations and original reference illustrations | 4 |
| Starter scenes | 2 |
| Example scenes | 2 |

## One recipe source

The 421 procedural scenes live in `Sources/SceneWeaverCatalog/Recipes`. SwiftUI uses these recipes directly. The browser executes those same Swift files and the core `ScenePen.swift`, compiled to WebAssembly. Geometry is generated at the current width, animation time, darkness, clock hour and layout direction. It is not a recording or a sampled animation loop.

`Tools/WasmRuntime` provides the geometry, path and color adapter needed to run these recipes without SwiftUI. The browser Canvas renderer paints the resulting paths and materials. Static gzip geometry is retained as a lightweight initial/fallback representation. Studio and React load the live runtime before presenting a procedural project as ready.

## Shared capabilities

| Capability | SwiftUI | React / Studio |
| --- | --- | --- |
| Full catalog and searchable gallery | `SceneCatalogGallery` | `SceneLibrary` / Browse library |
| Layered artwork, depth, dimming, floodlights, lamps | Yes | Yes |
| Water, boats, landmark clocks, crowds, fixture halos and floor reflections | Yes | Yes |
| Live daylight, weather, clouds, moon, stars, birds, aircraft and traffic | Yes | Yes |
| Procedural geometry, cutouts, material gradients and beacons | `ScenePen` | Live Swift catalog; JavaScript `ScenePen` for custom scenes |
| Custom drawing and overlays | SwiftUI Canvas callbacks | Canvas 2D callbacks |
| RTL placement and scene-specific reserved height | Yes | Yes |
| Play, pause, resume and Reduce Motion | Yes | Yes |
| Portable Studio project documents | `SceneProject` / `SceneProjectView` | `SceneView project` |

Platform gradients, font rendering, color spaces and antialiasing can differ. Custom Canvas callbacks use their platform's API; Swift source closures are not JavaScript callbacks. Studio's editor manipulates image plates and lights; an original procedural drawing remains one native drawing layer.

## Distribution

The core `SceneWeaver` product remains independent of the catalog and has no bundled artwork. Add `SceneWeaverCatalog` to opt into the complete original visual library. No application data, Quran text dataset, location history or app services are included.

The React package contains the renderer, components and TypeScript declarations. Host the contents of the `sceneweaver-library-0.2.0.zip` release asset under your site's `/scenes/` directory, retaining relative paths. Pass `/scenes/catalog.json` to `SceneLibrary`, and use its selected project URL with `SceneView`. The same files are served by the public demo.

Saved procedural projects embed the verified compressed runtime and saved image projects embed their artwork, so they can be reopened without the catalog server. The WASI adapter and Swift runtime notices are in `studio/assets/runtime/`; retain these notices when redistributing the library.

## Updating procedural recipes

1. Edit the canonical files in `Sources/SceneWeaverCatalog/Recipes`.
2. Run `swift run SceneWeaverCatalogExport --help` to inspect native export options. Regenerate inventory and fallback geometry when adding or changing scenes.
3. Build the browser runtime with `SCENEWEAVER_SWIFT=/path/to/upstream/swift python3 scripts/build-wasm.py`. This requires the matching upstream Swift 6.4.2 toolchain and its `swift-6.4.2-RELEASE_wasm` SDK; Xcode's bundled compiler is not interchangeable with that SDK.
4. Register project metadata and thumbnails, then run `node scripts/validate-studio-assets.mjs`, `node --test studio/tests/*.test.mjs` and `swift test`.

The validator checks complete catalog coverage, artwork and geometry references, and runtime integrity/source hashes. The runtime test executes every procedural scene at day/night, a narrow RTL width and animation times beyond 24 seconds. A recipe edit without a matching rebuilt runtime fails validation.
