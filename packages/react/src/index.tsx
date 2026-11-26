"use client";
import { useEffect, useMemo, useRef, useState } from "react";
import type { ReactElement } from "react";
import { createRenderer, decodeArtwork } from "../../../studio/render.mjs";
import { validateProject } from "../../../studio/model.mjs";
import { loadSceneProject } from "./load-project.js";
import type { EmbeddedSceneProject, SceneViewProps } from "./types.js";
export { loadSceneProject } from "./load-project.js";
export type {
  SceneProject,
  SceneLayer,
  SceneAsset,
  SceneLight,
  SceneSettings,
  SceneSource,
  SceneWeather,
  SceneViewProps,
  EmbeddedSceneProject,
  LoadSceneOptions,
} from "./types.js";
import { blankProject } from "../../../studio/model.mjs";
const EMPTY_PROJECT: EmbeddedSceneProject = {
  version: 1,
  name: "Procedural scene",
  settings: {
    ...blankProject().settings,
    weather: "clear",
    schedule: [5, 6, 12, 15, 18, 19.5],
  },
  layers: [],
};
interface Resource {
  source: SceneViewProps["project"];
  baseURL?: string;
  project: EmbeddedSceneProject | null;
  images: Map<string, HTMLImageElement>;
  error: Error | null;
}
function initialViewport(source: unknown): number {
  const value =
    source && typeof source === "object"
      ? (source as { settings?: { viewport?: unknown } }).settings?.viewport
      : undefined;
  return typeof value === "number" &&
    Number.isFinite(value) &&
    value >= 0.5 &&
    value <= 2.5
    ? value
    : 1.5;
}
const asError = (error: unknown): Error =>
  error instanceof Error ? error : new Error(String(error));
/** Responsive Canvas scenes using the same renderer as SceneWeaver Studio. */
export function SceneView({
  project = EMPTY_PROJECT,
  definition,
  baseURL,
  hour,
  weather,
  paused,
  showsSunPath,
  label,
  children,
  fallback = null,
  errorFallback = (
    <span role="alert" style={{ color: "#e5e9ed", padding: 16 }}>
      Unable to load scene.
    </span>
  ),
  onReady,
  onError,
  className,
  style,
  ...attributes
}: SceneViewProps): ReactElement {
  const canvas = useRef<HTMLCanvasElement>(null);
  const callbacks = useRef({ onReady, onError });
  const currentProject = useRef<EmbeddedSceneProject | null>(null);
  const visible = useRef(true);
  const currentDefinition = useRef(definition);
  useEffect(() => {
    currentDefinition.current = definition;
  }, [definition]);
  const [resource, setResource] = useState<Resource | null>(null);
  const [clockHour, setClockHour] = useState<number | undefined>(undefined);
  const [rendererError, setRendererError] = useState<Error | null>(null);
  useEffect(() => {
    callbacks.current = { onReady, onError };
  }, [onReady, onError]);
  useEffect(() => {
    if (hour !== "local") return;
    const tick = () => {
      const now = new Date();
      setClockHour(now.getHours() + now.getMinutes() / 60);
    };
    tick();
    const timer = setInterval(tick, 60000);
    return () => clearInterval(timer);
  }, [hour]);
  useEffect(() => {
    let active = true;
    const controller = new AbortController();
    setRendererError(null);
    loadSceneProject(project, { baseURL, signal: controller.signal })
      .then(async (loaded) => {
        const decoded = new Map<string, HTMLImageElement>();
        await Promise.all(
          loaded.layers.map(async (layer) => {
            if (controller.signal.aborted) return;
            decoded.set(layer.id, await decodeArtwork(layer.asset.data));
          }),
        );
        if (!active) return;
        setResource({
          source: project,
          baseURL,
          project: loaded,
          images: decoded,
          error: null,
        });
      })
      .catch((error) => {
        if (active)
          setResource({
            source: project,
            baseURL,
            project: null,
            images: new Map(),
            error: asError(error),
          });
      });
    return () => {
      active = false;
      controller.abort();
    };
  }, [project, baseURL]);
  useEffect(() => {
    if (
      resource?.project &&
      resource.source === project &&
      resource.baseURL === baseURL
    )
      callbacks.current.onReady?.(resource.project);
  }, [resource, project, baseURL]);
  const resolved = useMemo(() => {
    if (
      !resource ||
      resource.source !== project ||
      resource.baseURL !== baseURL
    )
      return { project: null, error: null };
    if (resource.error || !resource.project)
      return { project: null, error: resource.error };
    try {
      const saved = resource.project;
      return {
        project: validateProject({
          ...saved,
          settings: {
            ...saved.settings,
            hour:
              hour === "local"
                ? (clockHour ?? saved.settings.hour)
                : (hour ?? saved.settings.hour),
            weather: weather ?? saved.settings.weather,
            motion: paused === undefined ? saved.settings.motion : !paused,
            ...(showsSunPath === undefined ? {} : {showsSunPath}),
          },
        }) as EmbeddedSceneProject,
        error: null,
      };
    } catch (error) {
      return { project: null, error: asError(error) };
    }
  }, [resource, project, baseURL, hour, clockHour, weather, paused, showsSunPath]);
  const error = resolved.error ?? rendererError;
  useEffect(() => {
    currentProject.current = resolved.project;
  }, [resolved.project]);
  useEffect(() => {
    if (error) callbacks.current.onError?.(error);
  }, [error]);
  useEffect(() => {
    if (
      !canvas.current ||
      !resource?.project ||
      resource.source !== project ||
      resource.baseURL !== baseURL
    )
      return;
    const node = canvas.current;
    visible.current = true;
    const observer =
      typeof IntersectionObserver === "undefined"
        ? null
        : new IntersectionObserver((entries) => {
            visible.current = entries[0]?.isIntersecting ?? true;
          });
    observer?.observe(node);
    let renderer: ReturnType<typeof createRenderer> | undefined;
    try {
      renderer = createRenderer(
        node,
        () => (visible.current ? currentProject.current : null),
        () => resource.images,
        () => {},
        { getDefinition: () => currentDefinition.current },
      );
    } catch (error) {
      setRendererError(asError(error));
    }
    return () => {
      observer?.disconnect();
      renderer?.destroy();
    };
  }, [resource, project, baseURL]);
  const ready = Boolean(resolved.project && !error);
  const ratio = resolved.project?.settings.viewport ?? initialViewport(project);
  return (
    <div
      {...attributes}
      className={className}
      data-scene-state={error ? "error" : ready ? "ready" : "loading"}
      style={{
        position: "relative",
        width: "100%",
        aspectRatio: ratio,
        overflow: "hidden",
        background: "#102034",
        ...style,
      }}
    >
      <canvas
        ref={canvas}
        role={label ? "img" : undefined}
        aria-label={label}
        aria-hidden={label ? undefined : true}
        style={{
          display: "block",
          position: "absolute",
          inset: 0,
          width: "100%",
          height: "100%",
          pointerEvents: "none",
          visibility: ready ? "visible" : "hidden",
        }}
      />
      {!ready && (
        <div
          style={{
            position: "absolute",
            inset: 0,
            display: "grid",
            placeItems: "center",
          }}
        >
          {error ? errorFallback : fallback}
        </div>
      )}
      {children !== undefined && (
        <div style={{ position: "relative" }}>{children}</div>
      )}
    </div>
  );
}

export { SceneLibrary } from "./library.js";
export type { SceneLibraryEntry, SceneLibraryProps } from "./library.js";

export { ScenePen, ScenePath } from "./pen.js";
export type {
  SceneDefinition,
  SceneFrame,
  ScenePenOptions,
  SceneColor,
  ScenePoint,
  SceneTransform,
} from "./pen.js";
