---
name: sceneweaver
description: Build or modify live SwiftUI scenes with SceneWeaver, including vector landscapes, layered illustrations, weather, daylight and night lighting. Use when integrating this package or authoring content for its renderer.
---

# SceneWeaver

Use SceneWeaver for decorative 2D worlds in iOS 17+ or macOS 14+ SwiftUI apps. It supplies the renderer; the host supplies the scene's subject, artwork, daylight dates and weather. Keep application models, location services and data fetching in the host.

## Find the API

Read [README.md](README.md) for installation and runnable examples. For the current signatures, inspect only the relevant source:

- [SceneDefinition.swift](Sources/SceneWeaver/SceneDefinition.swift): scene configuration, daylight schedule, weather and frame inputs.
- [ScenePen.swift](Sources/SceneWeaver/ScenePen.swift): vector geometry, materials, lights and transforms.
- [LayeredArtwork.swift](Sources/SceneWeaver/LayeredArtwork.swift): image plates, framing, floodlights and lamps.
- [SceneWeaverGallery.swift](Examples/SceneWeaverGallery.swift): a self-contained consumer example.

When this skill is read outside a checkout, use the [public repository](https://github.com/joinalahmed/SceneWeaver) to obtain those files. Match the consumer's resolved package version rather than assuming main has the same API. Add the `SceneWeaver` library product to the consumer target before importing it.

## Scene assets and the browser configurator

For new artwork or asset-catalog scenes, use the focused [sceneweaver-assets skill](skills/sceneweaver-assets/SKILL.md). [SceneWeaver Studio](https://joinalahmed.github.io/SceneWeaver/) composes image plates and lights and exports a SwiftUI view with an Xcode asset catalog. Read [asset-authoring.md](docs/asset-authoring.md) for its project format. Browser previews approximate the native renderer; verify the generated composition in Xcode.

## React consumers

For React 18/19 apps, use [sceneweaver-react](packages/react/README.md). It shares Studio's browser renderer and accepts its saved JSON through `project`, with optional `hour`, `weather` and `paused` props. Its API differs from SwiftUI's `SceneView(schedule:...)`; follow the React package's types and README. Preserve the `use client` boundary and run the package's lifecycle tests when changing the component.

## Choose a composition

Use `SceneDefinition(draw:)` for silhouettes and code-drawn geometry. The pen separates solids, cutouts, colored tints, gradients and lights; drawing order across these groups is determined by the renderer. Use `render:` with `LayeredArtwork` when the illustration needs authored detail or depth-based occlusion. Use `overlay:` for content above the scene but below precipitation.

Keep custom geometry in a reusable definition or helper. For example:

```swift
let landscape = SceneDefinition(backdrop: .hills, wild: true, draw: { pen in
    pen.at(pen.width * 0.65)
    pen.block(0, 40, 28)
    pen.shape([(-25, 28), (25, 28), (0, 52)])
    pen.block(0, 9, 12, from: 8, .light)
})
// schedule contains six increasing Date values supplied by the host.
// SceneView(schedule: schedule, scene: landscape).frame(height: 320).clipped()
```

`ScenePen.at(_:)` measures from the viewport's **right edge**. Subsequent X coordinates are offsets from that center; positive Y rises **up from the horizon**. `time` drives motion, `night` controls lighting, and `clockDate` is the displayed wall-clock date. Use `apply(_:)` and `merge(_:)` to keep paths, gradients and beacons registered during composition.

`wild: true` suppresses incidental buildings, birds, aircraft and traffic. `ownMoon: true` suppresses the built-in moon. `illustrated: true` selects warmer foreground materials. Enable `movesForRTL` for compact landmarks that should translate to the left margin; preserve the placement of full-width authored landscapes.

## Author layered illustrations

Use aligned transparent plates with identical canvas dimensions and aspect ratio. Load and retain images outside per-frame callbacks. Array order is depth order: distant plate, moving content and distant lights, foreground plate, then nearby lamps. A foreground plate can naturally occlude actors or lamps behind it.

Create `.image(ArtworkLayer(...))` for plates and `.canvas(depth: ...) { context, rect, frame in ... }` for custom motion or lights between them. Pass the composition to `SceneDefinition(render: { context, frame in artwork.draw(in: &context, frame: frame) })`.

Image coordinates for `ArtworkLight` and `SceneLamp` are normalized from the **top left**, unlike the pen's coordinates. Floodlights tint only the plate's alpha; `SceneLamp` draws a visible luminous point and halo. Place both where the artwork's fixtures actually sit. Put lamps on a Canvas layer at the same depth as their plate.

`LayeredArtwork` shares `ArtworkLayout` across plates. Its default 12% overscan covers side edges during normal depth motion. To correct exposed edges, adjust shared aspect ratio, overscan or depth; do not stretch individual plates independently. Set the host view's height and clipping explicitly. `reservedHeight` can tell the sky how high an authored composition rises; it does not set the SwiftUI view's height.

## Time and accessibility

Supply a `DaylightSchedule` with dawn, sunrise, noon, afternoon, sunset and nightfall dates in increasing order for the same local day. SceneWeaver does not calculate these times. Incomplete or unordered schedules fall back to night. Refresh the schedule when the local day changes.

Omit `SceneView.now` for automatic minute updates; provide a fixed date for previews or a host-controlled timeline. Animation seconds are independent of that date. Drive custom animation from `frame.time`, not another timer: it freezes at zero under Reduce Motion. Use `frame.date` for clocks, and honor `frame.motionEnabled` for effects that need separate handling.

Canvas scenes are accessibility-hidden. Put meaningful text, controls and accessibility labels in the host SwiftUI view.

## Verify the affected behavior

Build the consumer target and inspect the rendered result. For framing or lighting changes, compare daylight and night at the narrowest supported width; include wide layouts, RTL or Reduce Motion when the change affects them. Confirm that lamps align with fixtures, silhouettes retain cutouts, and foreground plates occlude the intended content.

For engine changes, run `swift test` and the iOS build command in the README. For example changes, also build `SceneWeaverExamples`. Use [scripts/capture-screenshots.py](scripts/capture-screenshots.py) to regenerate the documented iOS gallery screenshots when the example's appearance changes. Do not substitute generated mockups for runtime screenshots.
