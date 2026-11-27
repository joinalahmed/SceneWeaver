# SceneWeaver Studio

A static browser configurator for the native SceneWeaver engine. No build step, account or API key is needed. Artwork is decoded in the browser. The last working scene is saved to this origin's IndexedDB when storage is available; Save project downloads a portable JSON file with embedded images.

## Run

From the repository root:

```sh
python3 -m http.server 5173
```

Open http://localhost:5173/studio/. ES modules and catalog requests require HTTP rather than opening `index.html` directly.

## Workspace

The light editor keeps layers on the left, a fitted artboard in the center, and Layer / Scene properties on the right. The Scene tab contains weather, framing and daylight controls. On phones, use the bottom Layers / Canvas / Properties navigation; the canvas opens first.

## Compose

Use **Browse components** for one example per reusable component: sky, weather, geometry, layers, water, boats, clocks, crowds, fixtures, lamps and floodlights. Switch the Collection control to **All scenes** for the 428 original scenes. The quick selector contains component examples and the two starter compositions. Import aligned PNG, WebP or JPEG plates. Order them front to back in the layer list; the underlying project and native export use back-to-front drawing order. Select a plate, use Lamp or Floodlight, then click on the artwork. Drag the handle or edit normalized coordinates in the inspector. Arrow keys nudge a focused light. Undo or ⌘/Ctrl+Z restores the last scene edit; ⌘/Ctrl+S saves a project copy.

Set layer depth, ambient dimming, light colors and radius. Preview weather, daylight transitions, overscan and different viewport ratios. All image plates share one authored canvas aspect ratio. Transparent PNG or WebP works best; opaque images cover the live sky.

Play and Pause control ambient animation at the selected time of day. Pause freezes the current frame; resume continues from there. The starter scenes include animated water ripples. Select their water-bearing background layer to toggle **Animate water on this layer**. Water is drawn before foreground plates, and the native export includes the same effect. The artboard scales a 402-point scene so atmospheric effects retain phone-sized proportions as the editor resizes. Native export uses SceneWeaver's ambient animation and system Reduce Motion behavior. The displayed hour is also a preview; exported `ComposedScene()` follows the clock, or accepts a fixed `previewDate`.

## Export

Export SwiftUI downloads a ZIP containing:

- `ComposedScene.swift`, compatible with SceneWeaver 0.2.0+. Procedural scenes also require the `SceneWeaverCatalog` product.
- `Assets.xcassets` with universal PNG imagesets. SVG starter plates are rasterized locally.
- `sceneweaver-project.json` with all authored layers and embedded original artwork.
- `README.txt` with integration and asset licensing notes.

Add the view and assets to an app target linked to SceneWeaver. Merge imagesets if the app already has an asset catalog. Hidden layers are omitted from the SwiftUI composition but preserved in the project.

The 421 procedural scenes execute the canonical Swift recipes live through WebAssembly; the browser paints their paths with Canvas 2D. Seven image compositions supply the remaining scenes. Studio and React share the complete catalog, atmospheric formulas, actors, lighting and artwork. Platform gradients, color spaces and antialiasing can differ. See [parity and runtime maintenance](../docs/parity.md).

## React

[The React component](../packages/react/README.md) renders these same projects and shares this renderer. Use Save project to obtain embedded JSON, then pass the object or a hosted JSON URL to React's `SceneView`. The [live React playground](https://joinalahmed.github.io/SceneWeaver/react/) is built from the package during deployment.

## Development

```sh
node --test studio/tests/*.test.mjs
node scripts/validate-studio-assets.mjs
```

For interaction tests, install Playwright in a development environment, start the HTTP server above, then run `node studio/tests/browser.mjs`. An existing installation can be selected with `PLAYWRIGHT_MODULE=/absolute/path/to/playwright`. `STUDIO_URL` overrides the local test URL and `STUDIO_TEST_OUTPUT` controls the artifact directory.

See [asset-authoring.md](../docs/asset-authoring.md) and the [asset creation agent skill](../skills/sceneweaver-assets/SKILL.md) for adding catalog scenes. UI refinement follows the existing-UI and rendered-verification guidance in [Anti-Slop-FrontEnd](https://github.com/vijay2411/Anti-Slop-FrontEnd). The configurator keeps its native Canvas animation and has no frontend runtime dependencies.

## Fonts

IBM Plex Sans and IBM Plex Mono are bundled locally from Google Fonts, under the SIL Open Font License. The original copyright and license notices are in `fonts/*-OFL.txt`. Font requests do not go to a third-party CDN at runtime.
