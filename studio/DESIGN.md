# Studio UI

This is an illustration editor, with the scene as its primary working surface. Preserve the forest-and-amber language; give canvas content more weight than editor decoration.

The refinement uses the existing-UI and verification guidance from [Anti-Slop-FrontEnd](https://github.com/vijay2411/Anti-Slop-FrontEnd/tree/b8e9f288cc4cd359f93ff98c89be8c2e1cc7bb9c), especially readable hierarchy, meaningful controls, responsive verification and functional behavior. It retains the existing Canvas motion and static browser architecture.

## Dependency receipt

- Runtime: browser Canvas 2D, ES modules, FileReader, IndexedDB and local modules. No frontend framework, remote scripts or runtime packages.
- Design tokens: forest backgrounds `--bg` / `--panel`, warm amber `--accent`, muted teal for drawing tools and a quiet lavender for preview caveats. Defined in `style.css`.
- Typography: IBM Plex Sans for tool labels and headings, IBM Plex Mono for measurements and time. Bundled in `fonts/`; SIL Open Font License notices are retained there. No font CDN requests at runtime.
- Icons: inline, locally authored SVG symbols in `index.html`, with shared stroke and scale. No icon-font package.
- Artwork: self-contained SVG starter plates in `assets/`, authored for this repository under MIT. Imported artwork is processed locally and retains its own license.

## Composition and behavior

Keep the desktop layer list, main canvas and inspector visible together. The layer list is a flat ordered stack, nearest plate first; selection uses a single amber edge. Avoid a separate card for every property. Keep secondary annotations quiet but readable. Use native form controls and semantic buttons, with labels and visible focus states.

Canvas tools place lights on the selected plate. The inspector and handles describe the same normalized image coordinates. Keep Undo available for reversible edits. Show actual local-save status; portable project downloads are the backup when browser storage is unavailable.

At tablet width, the inspector moves below the canvas. At phone width, use full-width touch controls and a vertical composition; do not hide essential actions. Inputs use 16px text and principal interactive targets are at least 44px. Light handles have larger hit areas than their drawn markers.

The scene itself is the motion feature. Keep UI movement short and functional; honor Reduce Motion for both interface transitions and ambient animation. Browser preview is explicitly an approximation of SwiftUI.

## Verification

The browser test covers project round trips, artwork import, light placement and dragging, layer reordering, native ZIP export and persistence. It checks console/network errors and records screenshots plus accessibility snapshots at 375, 768 and 1440px. Inspect these artifacts before shipping UI changes; test the native export separately when its generator changes.
