import type { HTMLAttributes, ReactNode } from "react";
export type SceneWeather =
  | "clear"
  | "partlyCloudy"
  | "cloudy"
  | "fog"
  | "drizzle"
  | "rain"
  | "snow"
  | "thunderstorm";
export interface SceneLight {
  id: string;
  type: "lamp" | "flood";
  /** Normalized artwork coordinates, from the top left. */
  x: number;
  y: number;
  radius: number;
  /** Used by floods; lamp brightness follows dusk automatically. */
  intensity: number;
  color: string;
}
export interface SceneAsset {
  name: string;
  /** Embedded image data URL from a saved Studio project. */
  data?: string;
  /** Same-origin or CORS-enabled image URL, resolved against the project URL/baseURL. */
  src?: string;
}
export interface SceneLayer {
  id: string;
  name: string;
  visible: boolean;
  depth: number;
  dim: number;
  asset: SceneAsset;
  lights: SceneLight[];
}
export interface SceneSettings {
  hour: number;
  weather: SceneWeather;
  ground: number;
  aspectRatio: number;
  overscan: number;
  viewport: number;
  motion: boolean;
  /** Dawn, sunrise, noon, afternoon, sunset and nightfall, in increasing local hours. */
  schedule: [number, number, number, number, number, number];
}
export interface SceneProject {
  version: 1;
  name: string;
  settings: SceneSettings;
  /** Drawing order: back to front. */
  layers: SceneLayer[];
}
export interface EmbeddedSceneProject extends Omit<SceneProject, "layers"> {
  layers: Array<
    Omit<SceneLayer, "asset"> & { asset: { name: string; data: string } }
  >;
}
/** JSON imports are runtime-validated; use SceneProject when authoring objects in TypeScript. */
export type SceneSource = SceneProject | Record<string, unknown> | string | URL;
export interface LoadSceneOptions {
  baseURL?: string | URL;
  signal?: AbortSignal;
}
export interface SceneViewProps
  extends Omit<HTMLAttributes<HTMLDivElement>, "children" | "onError"> {
  project: SceneSource;
  /** Base URL for relative artwork URLs when passing a project object. */
  baseURL?: string;
  /** Omit to use the saved project hour; "local" follows the local clock every minute. */
  hour?: number | "local";
  weather?: SceneWeather;
  /** Freeze ambient motion at its current frame. System Reduce Motion renders the rest pose. */
  paused?: boolean;
  /** Optional description. Without a label the canvas is decorative. */
  label?: string;
  /** Rendered above the canvas. Use normal accessible HTML for meaningful content. */
  children?: ReactNode;
  fallback?: ReactNode;
  errorFallback?: ReactNode;
  /** Fires after the project and its artwork decode successfully. */
  onReady?: (project: EmbeddedSceneProject) => void;
  onError?: (error: Error) => void;
}
