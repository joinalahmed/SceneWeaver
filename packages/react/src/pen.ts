import {
  ScenePen as Pen,
  ScenePath as Path,
} from "../../../studio/scene-pen.mjs";
import type { SceneWeather } from "./types.js";
export type SceneColor = string | [number, number, number, number?];
export type ScenePoint = { x: number; y: number };
export type SceneTransform = [number, number, number, number, number, number];
export interface ScenePath {
  move(to: ScenePoint): this;
  moveTo(x: number, y: number): this;
  addLine(to: ScenePoint): this;
  lineTo(x: number, y: number): this;
  addCurve(to: ScenePoint, control1: ScenePoint, control2: ScenePoint): this;
  bezierCurveTo(
    ax: number,
    ay: number,
    bx: number,
    by: number,
    x: number,
    y: number,
  ): this;
  addQuadCurve(to: ScenePoint, control: ScenePoint): this;
  quadraticCurveTo(cx: number, cy: number, x: number, y: number): this;
  closeSubpath(): this;
  closePath(): this;
  addPath(path: ScenePath): this;
  applying(transform: SceneTransform): ScenePath;
  readonly boundingRect: {
    x: number;
    y: number;
    width: number;
    height: number;
  };
  readonly description: string;
}
export const ScenePath = Path as { new (): ScenePath };
export interface ScenePenOptions {
  width: number;
  horizon: number;
  time?: number;
  night?: number;
  clockDate?: Date;
  illustrated?: boolean;
}
export interface ScenePen {
  readonly width: number;
  readonly horizon: number;
  readonly time: number;
  readonly night: number;
  readonly clockDate: Date;
  readonly illustrated: boolean;
  solids: ScenePath[];
  holes: ScenePath[];
  lights: ScenePath[];
  tints: Array<{
    path: ScenePath;
    color: number[];
    nightOnly: boolean;
    lower?: number[];
  }>;
  beacons: ScenePoint[];
  at(fromRight: number): this;
  point(x: number, y: number): ScenePoint;
  blockPath(x: number, width: number, height: number, from?: number): ScenePath;
  discPath(x: number, y: number, radius: number): ScenePath;
  domePath(x: number, width: number, on: number, rise?: number): ScenePath;
  polygon(points: [number, number][]): ScenePath;
  block(
    x: number,
    width: number,
    height: number,
    from?: number,
    layer?: "solid" | "hole" | "light",
  ): this;
  disc(
    x: number,
    y: number,
    radius: number,
    layer?: "solid" | "hole" | "light",
  ): this;
  dome(
    x: number,
    width: number,
    on: number,
    rise?: number,
    layer?: "solid" | "hole" | "light",
  ): this;
  shape(points: [number, number][], layer?: "solid" | "hole" | "light"): this;
  curve(
    build: (
      path: ScenePath,
      point: (x: number, y: number) => ScenePoint,
    ) => void,
  ): this;
  curve(
    layer: "solid" | "hole" | "light",
    build: (
      path: ScenePath,
      point: (x: number, y: number) => ScenePoint,
    ) => void,
  ): this;
  tint(path: ScenePath, color: SceneColor, nightOnly?: boolean): this;
  wash(path: ScenePath, top: SceneColor, bottom: SceneColor): this;
  detail(path: ScenePath, strength?: number): this;
  beacon(x: number, y: number): this;
  spire(x: number, width: number, from: number, to: number): this;
  onion(x: number, width: number, on: number, height: number): this;
  arch(
    x: number,
    width: number,
    height: number,
    from?: number,
    pointed?: boolean,
    layer?: "solid" | "hole" | "light",
  ): this;
  minaret(
    x: number,
    height: number,
    style?: "arab" | "ottoman" | "mughal",
  ): this;
  hue(seconds: number, offset?: number): number[];
  apply(transform: SceneTransform): this;
  merge(other: ScenePen): this;
  moveToLeftMargin(): this;
  occludeLights(foreground: ScenePath): this;
}
export const ScenePen = Pen as unknown as {
  new (options: ScenePenOptions): ScenePen;
  noise(a: number, b: number): number;
};
export interface SceneFrame {
  size: { width: number; height: number };
  horizon: number;
  time: number;
  date: Date;
  darkness: number;
  glow: number;
  motionEnabled: boolean;
  layoutDirection: "ltr" | "rtl";
  weather: SceneWeather;
  contentColor: string;
}
/** Custom callbacks use the host platform's Canvas API; callbacks are never serialized into JSON. */
export interface SceneDefinition {
  backdrop?: "towers" | "low" | "hills" | "open";
  wild?: boolean;
  ownMoon?: boolean;
  illustrated?: boolean;
  movesForRTL?: boolean;
  distantBuildingHeights?: [number, number];
  nearBuildingHeights?: [number, number];
  reservedHeight?: (width: number) => number;
  draw?: (pen: ScenePen) => void;
  render?: (context: CanvasRenderingContext2D, frame: SceneFrame) => void;
  overlay?: (context: CanvasRenderingContext2D, frame: SceneFrame) => void;
}
