---
name: sceneweaver-assets
description: Create or extend layered artwork for a requested SceneWeaver scene and register it in the browser Studio. Use for new landscapes, places, buildings, foreground props and authored lamp or floodlight positions.
---

# Create SceneWeaver assets

Turn the user's scene requirement into aligned, reusable artwork that works in both SceneWeaver Studio and the native SwiftUI engine. Keep the scene's subject unrestricted: a city, forest, shop, fantasy world or other environment can use the same engine.

## Establish the composition

Read the requested subject, style, perspective, detail level and intended viewport. Inspect the nearest existing scene in `studio/assets/catalog.json` and its project JSON before creating files. Reuse appropriate existing assets or match their visual language when extending a scene. Ask only when a missing requirement would materially change the result.

For an existing checkout, see [asset contract](../../docs/asset-authoring.md), [layer APIs](../../Sources/SceneWeaver/LayeredArtwork.swift) and [project validation](../../studio/model.mjs). Outside the checkout, obtain these files from [SceneWeaver](https://github.com/joinalahmed/SceneWeaver). Do not assume a Studio project supports arbitrary native drawing callbacks.

Plan depth before drawing. Two or three image plates are often enough: distant terrain or architecture, the focal scene, then nearby structures or foliage. Put fixtures on the plate that owns them. Decide which objects must occlude actors or lights. Preserve an existing good plate rather than regenerating the whole scene for a small addition.

## Produce the plates

Use SVG for artwork whose intended style is vector illustration or procedural geometry. For detailed raster illustrations, use an available image-generation or image-editing tool with the user's references and the established style. If the required tool or source is unavailable, report the limitation accurately; do not substitute a low-detail diagram and describe it as a reference match.

Every plate in one scene must have identical canvas dimensions, aspect ratio and registration. Use a transparent background above and between objects so the live sky remains visible. Do not independently crop foreground cutouts. Keep alignment landmarks and the authored horizon consistent. PNG or WebP with alpha works for raster plates; self-contained SVG works for Studio catalog assets. Studio rasterizes SVG into PNG when exporting to Xcode.

Keep important objects away from the outer overscan edges. Evaluate the actual viewport: width-filling artwork is anchored to the horizon and can crop vertically in wide or short layouts. Do not stretch plates separately to hide a framing problem.

Keep static materials in the artwork. Let the engine supply the changing sky, ambient dimming, facade floods and point-light glow. Avoid baking a solid sky, a rectangular light wash or a permanent night halo into a daytime image.

Record the asset's provenance and license. Do not copy private app illustrations into the public catalog by default. Use artwork the project can redistribute.

## Register a scene or extend one

1. Store aligned plates in `studio/assets/<scene-id>/` with descriptive filenames.
2. Create or edit `studio/assets/<scene-id>.json`. Copy the shape of an existing project, not its IDs or fixture coordinates. The canonical schema is enforced by `validateProject` in `studio/model.mjs`.
3. Keep `layers` ordered **back to front**. Studio displays this list in reverse so the nearest layer appears at the top. Give each layer a unique ID and a distinct Xcode asset name containing only letters, digits and underscores, starting with a letter.
4. Set each catalog asset's `src` relative to `studio/assets/`, for example `forest/cabin.svg`. Set `settings.aspectRatio` to the shared canvas width divided by height. Use smaller `depth` for distant plates and larger values for nearer ones. `dim` is ambient darkening, not opacity.
5. For a new preset, add its ID, display name and JSON filename to `studio/assets/catalog.json`. For a standalone user project, use Studio's saved JSON with embedded artwork instead of catalog-relative paths.

A light belongs in the owning layer's `lights` array:

```json
{
  "id": "cabin-porch-lamp",
  "type": "lamp",
  "x": 0.755,
  "y": 0.74,
  "radius": 0.012,
  "intensity": 0.34,
  "color": "#ffd78a"
}
```

Coordinates are normalized from the image's **top left**: divide authored pixel X by canvas width, and pixel Y by canvas height. Use a `lamp` for visible glass, bulb or flame cores, and a `flood` for an alpha-clipped wash across a facade. `intensity` controls floods; native lamp brightness follows dusk automatically. Keep the field in both types for a consistent project shape.

Place lights on visible fixtures rather than arbitrary bright spots. In the export, each plate's lamps are drawn immediately above it; later foreground plates can occlude them. Add a separate light only when it represents a distinct fixture or wash.

Studio v1 composes images, depth motion and lighting. Native `LayeredArtwork.canvas` can add custom actors, but Studio does not serialize arbitrary Swift closures. When the requirement needs custom native animation, deliver that callback separately and explain what Studio can preview.

## Verify and deliver

Run `node scripts/validate-studio-assets.mjs` and `node --test studio/tests/*.test.mjs`. Open Studio and inspect the new scene in daylight and at night, at narrow and wide viewport ratios, and with motion paused. Check transparent edges, plate registration, fixture alignment and foreground occlusion. Confirm no side gaps appear at the chosen depth and overscan.

Export the scene, check the ZIP's asset names and generated Swift, and build it in a consumer when the asset change introduces a new composition behavior. A browser screenshot is a preview, not proof that SwiftUI is pixel-identical. Report the added files, the intended depth order, any required native callback and the verification performed.

## Full catalog and parity

Before authoring new content, search the existing 428-scene catalog. Reuse a scene or its registered plates when appropriate. Read [parity maintenance](../../docs/parity.md) for the canonical Swift recipe location, live WebAssembly rebuild, native resource registration, inventory coverage checks and distribution requirements. Studio and React use the same complete library; keep their `nativeID` values aligned with `SceneWeaverCatalog`. Validate native and browser rendering after changing geometry, actor placement, framing or lights.
