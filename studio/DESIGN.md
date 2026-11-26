# Studio UI

The user-selected direction is a **Figma-style light editor**: white panels, neutral gray chrome, blue selection states and a canvas-first workspace. Do not reintroduce the previous forest/amber dashboard theme, promotional headings, decorative cards or an oversized upload area.

Reference: [Figma's interface anatomy](https://help.figma.com/hc/en-us/articles/30925881896727-FD4B-Navigate-Figma-Design-files). The layout uses familiar layer-stack, canvas and contextual-properties patterns; it is not an exact Figma clone. Functional and rendered-verification guidance also comes from [Anti-Slop-FrontEnd](https://github.com/vijay2411/Anti-Slop-FrontEnd/tree/b8e9f288cc4cd359f93ff98c89be8c2e1cc7bb9c).

## Layout

- A compact file bar holds the editable document name, local-save state and file actions.
- The left panel contains scene selection, a flat ordered layer stack and a compact image-import control.
- The central gray work area holds one fitted artboard. Its dimensions preserve the selected aspect ratio. The timeline is a compact strip below it.
- The right panel has functional Layer and Scene tabs. Layer properties and lights are contextual; atmosphere and framing live under Scene.
- On phones, Layers / Canvas / Properties navigation switches actual panels. Canvas is the initial view, with touch controls and scrollable properties. Do not stack the entire desktop sidebar above the artboard.

The illustration provides the color and motion. Keep editor surfaces neutral. Avoid hero copy, status badges without a purpose, gradient panel backgrounds, excessive rounding and marketing sections inside the editor. Selection handles must remain distinct from the authored lamp glow.

## Dependencies and tokens

The editor runs on browser Canvas 2D, ES modules, FileReader and IndexedDB. It has no frontend runtime dependencies. Tokens are in `style.css`; do not rely on duplicate override sheets. Icons are locally authored SVG symbols in `index.html`.

Typography is locally bundled IBM Plex Sans, with IBM Plex Mono for time and measurements. SIL Open Font License notices are in `fonts/`. No external font requests occur at runtime. The separate React playground is built from `packages/react` during deployment; the main editor remains plain JavaScript.

## Behavior and validation

Use native form controls and semantic buttons with visible focus states. Keep editable fields readable and mobile inputs at 16px. Scene edits are reversible with Undo. Show actual persistence state and retain portable project downloads when browser storage is unavailable.

Studio's web preview is an approximation of SwiftUI. Do not present decorative mockups as renderer screenshots. Preserve project/export compatibility when changing layout.

The browser test checks project round trips, imports, light placement and dragging, keyboard nudging, layer order, export and persistence. It verifies console/network errors, accessibility snapshots and screenshots at 375, 768 and 1440px. Inspect the actual rendered screenshots after layout changes. React has separate StrictMode, SSR and packed-consumer tests.
