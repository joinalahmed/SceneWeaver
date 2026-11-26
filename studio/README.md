# SceneWeaver Studio

A static browser configurator for the native SceneWeaver engine. No build step, account or API key is needed. Artwork is decoded in the browser. The last working scene is saved to this origin's IndexedDB when storage is available; Save project downloads a portable JSON file with embedded images.

## Run

From the repository root:

```sh
python3 -m http.server 5173
```

Open http://localhost:5173/studio/. ES modules and catalog requests require HTTP rather than opening `index.html` directly.

## Compose

Choose Alpine hideaway, Harbor at dusk or a blank canvas. Import aligned PNG, WebP or JPEG plates. Order them front to back in the layer list; the underlying project and native export use back-to-front drawing order. Select a plate, use Lamp or Floodlight, then click on the artwork. Drag the handle or edit normalized coordinates in the inspector. Arrow keys nudge a focused light. Undo or ⌘/Ctrl+Z restores the last scene edit; ⌘/Ctrl+S saves a project copy.

Set layer depth, ambient dimming, light colors and radius. Preview weather, daylight transitions, overscan and different viewport ratios. All image plates share one authored canvas aspect ratio. Transparent PNG or WebP works best; opaque images cover the live sky.

The playback button pauses the **preview**. Native export uses SceneWeaver's ambient animation and system Reduce Motion behavior. The displayed hour is also a preview; exported `ComposedScene()` follows the clock, or accepts a fixed `previewDate`.

## Export

Export SwiftUI downloads a ZIP containing:

- `ComposedScene.swift`, compatible with SceneWeaver 0.1.0+.
- `Assets.xcassets` with universal PNG imagesets. SVG starter plates are rasterized locally.
- `sceneweaver-project.json` with all authored layers and embedded original artwork.
- `README.txt` with integration and asset licensing notes.

Add the view and assets to an app target linked to SceneWeaver. Merge imagesets if the app already has an asset catalog. Hidden layers are omitted from the SwiftUI composition but preserved in the project.

The browser preview approximates SwiftUI's Canvas rendering. Plate framing and daylight palette interpolation follow the engine; weather, gradients and antialiasing can differ. Verify final output in Xcode. Studio currently composes image plates and lights; arbitrary native Canvas callbacks and procedural pen scenes are outside its project format.

## Development

```sh
node --test studio/tests/*.test.mjs
node scripts/validate-studio-assets.mjs
```

For interaction tests, install Playwright in a development environment, start the HTTP server above, then run `node studio/tests/browser.mjs`. An existing installation can be selected with `PLAYWRIGHT_MODULE=/absolute/path/to/playwright`. `STUDIO_URL` overrides the local test URL and `STUDIO_TEST_OUTPUT` controls the artifact directory.

See [asset-authoring.md](../docs/asset-authoring.md) and the [asset creation agent skill](../skills/sceneweaver-assets/SKILL.md) for adding catalog scenes. UI refinement follows the existing-UI and rendered-verification guidance in [Anti-Slop-FrontEnd](https://github.com/vijay2411/Anti-Slop-FrontEnd). The configurator keeps its native Canvas animation and has no frontend runtime dependencies.

## Fonts

IBM Plex Sans and IBM Plex Mono are bundled locally from Google Fonts, under the SIL Open Font License. The original copyright and license notices are in `fonts/*-OFL.txt`. Font requests do not go to a third-party CDN at runtime.
