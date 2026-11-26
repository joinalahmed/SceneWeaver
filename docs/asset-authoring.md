# Scene assets and Studio projects

The public catalog includes procedural Swift recipes, SVG illustrations and the original layered raster artwork, all explicitly released for redistribution. Their geometry and project files are covered by the repository's MIT license. User-imported artwork retains its own license. Agent workflow: [sceneweaver-assets/SKILL.md](../skills/sceneweaver-assets/SKILL.md).

## Catalog layout

`studio/assets/catalog.json` lists `{ "id", "name", "project" }` entries in its `scenes` array, with `version: 1`. Project filenames are JSON files directly inside `studio/assets`. A project's `asset.src` points to a file relative to that directory; keep each scene's artwork in a named subdirectory.

Each image plate must use the same canvas and aspect ratio. SVGs require a `viewBox="0 0 width height"` and explicit intrinsic width/height. Keep SVGs self-contained, without scripts, external resources or embedded HTML. For new raster catalog artwork, prefer transparent PNG. Match `settings.aspectRatio` to canvas width / height.

## Project shape

```json
{
  "version": 1,
  "name": "Forest cabin",
  "settings": {
    "hour": 18.6,
    "weather": "clear",
    "ground": 36,
    "aspectRatio": 1.5,
    "overscan": 1.12,
    "viewport": 1.5,
    "motion": true,
    "schedule": [5, 6, 12, 15, 18, 19.5]
  },
  "layers": [{
    "id": "forest-cabin",
    "name": "Cabin",
    "visible": true,
    "depth": 1.3,
    "dim": 0.46,
    "asset": { "name": "ForestCabin", "src": "forest/cabin.png" },
    "lights": [{
      "id": "porch",
      "type": "lamp",
      "x": 0.75,
      "y": 0.74,
      "radius": 0.012,
      "intensity": 0.34,
      "color": "#ffd78a"
    }]
  }]
}
```

`layers` runs back to front. Asset names must start with a letter and contain only ASCII letters, numbers and underscores; they are unique without regard to case. Layer IDs are unique within the project, light IDs within their layer. The source of truth for numeric limits and validation is [studio/model.mjs](../studio/model.mjs).

A saved project replaces `asset.src` with an embedded `asset.data` image data URL. This makes project downloads portable; importing a saved project never fetches artwork from a URL. Catalog entries are loaded from the same site's `assets` directory.

`dim` controls night material darkening. A `flood` uses radius, intensity and color for illumination clipped to the plate's alpha. A `lamp` uses normalized image coordinates, halo radius and color; its brightness follows dusk. Its `intensity` field is retained for a uniform project format but is not applied by the native lamp API.

The six `schedule` entries are local creative daylight hours. They are not calculated astronomical times. `hour` and `motion` are preview controls; export follows the current clock and native Reduce Motion preference. Supply your own schedule and `previewDate` in SwiftUI when using real event times or a fixed preview.

## Export

Studio generates `ComposedScene.swift`, universal PNG imagesets in `Assets.xcassets`, an embedded project JSON and integration notes. Hidden layers remain in the editable project but are omitted from the native composition and asset catalog. Each image plate is followed by its lamps in the exported layer array, preserving occlusion. Floodlights stay attached to their image plate.

The web preview implements the same plate framing and daylight palette interpolation, with approximate sky, weather and compositing. SwiftUI remains the final renderer. Studio v1 does not serialize procedural pen geometry or arbitrary actor callbacks.

## Checks

```sh
node scripts/validate-studio-assets.mjs
node --test studio/tests/*.test.mjs
python3 -m http.server 5173
# Open http://localhost:5173/studio/
```

Inspect daylight, dusk and night, both landscape and portrait framing, and paused motion. Place lights on authored fixtures, preserve foreground occlusion, and verify the native export in Xcode before shipping a consumer app.

### Animated water

A layer can include `"water": {"x": 0, "y": 0.73, "width": 1, "height": 0.27, "opacity": 0.28}`. Bounds use normalized artwork coordinates and must fit inside the plate. Put this on the background water plate; later foreground plates naturally occlude the ripples. Studio and React animate the highlights, and SwiftUI export emits the matching Canvas layer. Omit it for dry scenes; `null` explicitly disables it. The Studio checkbox uses a bottom-quarter region by default; edit the project JSON for a different water boundary.

## Keeping the full library aligned

Register new scenes in both `SceneCatalog` (through `CatalogRecipes` for procedural content) and the web catalog with the same `nativeID`. Include category, tags and a lazy-loaded WebP thumbnail. Add native image resources for new image compositions. Run `node scripts/validate-studio-assets.mjs` to verify full native/web coverage.

Procedural source belongs in `Sources/SceneWeaverCatalog/Recipes`; do not maintain a separate JavaScript copy of a canonical Swift recipe. Rebuild the live Swift runtime after recipe changes. Follow [the parity maintenance workflow](parity.md). Image plates remain independently editable in Studio; procedural geometry is a native drawing layer with optional image overlays.
