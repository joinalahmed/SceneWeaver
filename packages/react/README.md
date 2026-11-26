# SceneWeaver for React

A reusable React component for layered scenes, live skies, weather and lighting. It renders saved SceneWeaver Studio projects using **the same Canvas renderer as Studio**.

React 18 and 19 · TypeScript declarations · ESM · SSR-safe client initialization · MIT

[Live React playground](https://joinalahmed.github.io/SceneWeaver/react/) · [Scene composer](https://joinalahmed.github.io/SceneWeaver/)

## Install

Install the built package from the public GitHub release:

```sh
npm install https://github.com/joinalahmed/SceneWeaver/releases/download/react-v0.2.0/sceneweaver-react-0.2.0.tgz
```

The package is distributed through GitHub Releases; it is not currently published to the npm registry. React is a peer dependency and is not bundled into the component. Use Node 20+ for package tooling.

## Use a Studio project

Save a project in Studio, place the downloaded JSON in your app's public directory, and render it:

```tsx
import { SceneView } from 'sceneweaver-react';

export function Landscape() {
  return (
    <SceneView
      project="/scenes/alpine.sceneweaver.json"
      hour={18.6}
      weather="clear"
      label="A cabin beside an alpine lake"
      style={{ borderRadius: 16 }}
    />
  );
}
```

Saved projects embed their artwork, so no additional image paths are required. A project object imported from JSON also works:

```tsx
import project from './my-scene.sceneweaver.json';
import { SceneView } from 'sceneweaver-react';

<SceneView project={project} paused />
```

For source projects with `asset.src`, image URLs resolve relative to the project URL. When passing an object with relative image paths, provide `baseURL`. Image endpoints must allow browser access through same-origin requests or CORS. Only HTTP(S) URLs and embedded image data are supported.

```tsx
<SceneView project={project} baseURL="https://example.com/scenes/" />
```

## Props

| Prop | Behavior |
| --- | --- |
| `project` | Studio JSON object, project URL string or `URL`. Runtime-validated before rendering. |
| `baseURL` | Base for relative asset paths when passing a project object. |
| `hour` | Number from 0 to 23.99; omit to use the saved hour, or use `"local"` to follow the local clock every minute. |
| `weather` | `clear`, `partlyCloudy`, `cloudy`, `fog`, `drizzle`, `rain`, `snow` or `thunderstorm`. Defaults to the saved condition. |
| `paused` | Freeze ambient motion at its current frame. Omit to use the project's motion setting. System Reduce Motion is always honored. |
| `label` | Accessible scene description. Without one, the canvas is decorative. |
| `children` | Normal React content above the drawing, including interactive controls. |
| `fallback` | Optional content while the project and artwork load. |
| `errorFallback` | Content on error; defaults to an accessible error message. |
| `onReady` | Called with the normalized, embedded project once its artwork decodes. Not called again for time/weather updates. |
| `onError` | Called with a loading, validation or renderer-setup error. |
| `className`, `style`, other div attributes | Applied to the wrapper. Default width is 100%; default aspect ratio comes from the project. |

Keep a programmatically created `project` object stable with `useMemo` when its content has not changed. A new object or URL triggers a new load. Time, weather and pause controls update the scene without re-fetching artwork. Source changes cancel pending requests; unmount stops the renderer and disconnects visibility tracking.

The wrapper sets its default aspect ratio to reserve space before artwork loads. Override its height/aspect ratio through `style` or your layout as needed. No stylesheet is required by the component.

## Overlay content and loading states

```tsx
<SceneView
  project="/scenes/header.json"
  fallback={<span>Preparing landscape…</span>}
  onError={error => reportError(error)}
>
  <div style={{ padding: 24, color: 'white' }}>
    <h2>Continue reading</h2>
    <button onClick={openBook}>Open book</button>
  </div>
</SceneView>
```

Use HTML for meaningful labels and controls. The canvas does not intercept pointer events. `data-scene-state` on the wrapper is `loading`, `ready` or `error`, for application styling.

## Server rendering and Next.js

The package preserves a `"use client"` boundary. Browser APIs and image decoding run in effects, not during module import or server rendering. The server produces the same initial wrapper, canvas, children and fallback that the client hydrates. Rendering begins after mount.

Pass serializable props from a Next.js server component; place callbacks and interactive state in a client component. `hour="local"` reads the client clock after hydration, avoiding a server/client time mismatch.

## Load separately

```ts
import { loadSceneProject } from 'sceneweaver-react';

const controller = new AbortController();
const project = await loadSceneProject('/scenes/project.json', {
  signal: controller.signal,
});
```

The helper resolves image URLs and returns validated JSON with embedded artwork. The React component normally handles this for you. `SceneProject`, `SceneLayer`, `SceneLight`, `SceneWeather` and other public types are exported for typed authoring.

## Renderer and limits

This is the web Canvas renderer, not a wrapper around native SwiftUI. It shares Studio’s image framing, lighting and native-derived sky/weather formulas; color spaces, gradients and antialiasing can differ from SwiftUI. It composes artwork, actors, procedural geometry and Canvas callbacks. The original catalog recipes execute live as Swift WebAssembly; custom JavaScript definitions use the exported ScenePen API. No catalog artwork, fonts, network service or location provider is bundled into the component.

## Develop

From this directory:

```sh
npm ci
npm test
npm run build:example
```

Then serve the repository root with `python3 -m http.server 5173` and open `/studio/react/`. For browser lifecycle tests, set `PLAYWRIGHT_MODULE` to an installed Playwright package and run `npm run test:browser`. The tests exercise React StrictMode, controlled props, request cancellation, error recovery, resizing, overlays, Reduce Motion and unmount cleanup.

`npm pack` produces an installable tarball containing the bundled component, TypeScript declarations, README and license. Build tools and test fixtures are excluded. The build imports the shared renderer directly from `studio/`; changes to Studio's renderer automatically reach the React bundle.

Water animation is optional per layer: `water: { x: 0, y: 0.73, width: 1, height: 0.27, opacity: 0.28 }` defines a normalized rectangle on the artwork. Highlights render after that plate and before later layers, so foreground objects occlude them. Set `water: null` to disable it. Pausing holds the current animation frame; it does not advance the displayed hour.

## Full original library

Version 0.2.0 exposes all 428 original scenes through the public demo. To self-host, download `sceneweaver-library-0.2.0.zip` from the [native release](https://github.com/joinalahmed/SceneWeaver/releases/tag/v0.2.0), extract its contents into `public/scenes/`, and retain the runtime license notices.

```tsx
import { useState } from 'react';
import { SceneView, SceneLibrary } from 'sceneweaver-react';

export function Gallery() {
  const [project, setProject] = useState('/scenes/alpine.json');
  return <>
    <SceneView project={project} hour={19} />
    <SceneLibrary catalogURL="/scenes/catalog.json"
      onSelect={(_, url) => setProject(url)} />
  </>;
}
```

Procedural catalog projects load the integrity-checked Swift WebAssembly runtime relative to their project URL. The same original recipes execute at the current width, time, night level, clock hour and RTL direction. `onReady` waits for that runtime. Custom programmatic scenes can instead use `definition={{ draw(pen) { ... }, overlay(context, frame) { ... } }}`; `ScenePen` and `ScenePath` are exported with TypeScript declarations. See [cross-platform capabilities](../../docs/parity.md).
