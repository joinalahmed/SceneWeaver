import { validateProject } from "../../../studio/model.mjs";
import type {
  EmbeddedSceneProject,
  LoadSceneOptions,
  SceneSource,
} from "./types.js";
function resolveURL(value: string | URL, base?: string | URL): URL {
  const fallback =
    typeof document === "undefined" ? undefined : document.baseURI;
  const url = new URL(value, base ?? fallback);
  if (!["https:", "http:"].includes(url.protocol))
    throw new Error(
      "Scene URLs must use HTTP or HTTPS. Pass embedded artwork through asset.data.",
    );
  return url;
}
function aborted(signal?: AbortSignal) {
  if (signal?.aborted)
    throw new DOMException("Scene loading was cancelled.", "AbortError");
}
async function fetchResponse(
  url: URL,
  signal?: AbortSignal,
): Promise<Response> {
  const response = await fetch(url, { signal });
  if (!response.ok)
    throw new Error(`Could not load scene resource (HTTP ${response.status}).`);
  return response;
}
function dataURL(type: string, bytes: Uint8Array): string {
  let binary = "";
  for (let i = 0; i < bytes.length; i += 32768)
    binary += String.fromCharCode(...bytes.subarray(i, i + 32768));
  return `data:${type};base64,${btoa(binary)}`;
}
/** Load Studio project JSON and embed relative image assets without mutating the source. */
export async function loadSceneProject(
  source: SceneSource,
  options: LoadSceneOptions = {},
): Promise<EmbeddedSceneProject> {
  aborted(options.signal);
  let input: unknown = source,
    base = options.baseURL;
  if (typeof source === "string" || source instanceof URL) {
    const url = resolveURL(source, base),
      response = await fetchResponse(url, options.signal);
    const text = await response.text();
    if (text.length > 50000000) throw new Error("Scene project exceeds 50 MB.");
    input = JSON.parse(text);
    base = response.url || url.href;
  }
  // Validate structure before fetching artwork. Consumers can use absolute or
  // root-relative URLs as well as the catalog-relative Studio source format.
  const raw = input as {
    layers?: Array<{ asset?: { src?: unknown; data?: unknown } }>;
  };
  const candidate =
    raw && typeof raw === "object"
      ? {
          ...raw,
          layers: Array.isArray(raw.layers)
            ? raw.layers.map((layer) => ({
                ...layer,
                asset: {
                  ...layer?.asset,
                  ...(typeof layer?.asset?.src === "string" &&
                  layer.asset.data === undefined
                    ? { data: "data:image/png;base64," }
                    : {}),
                },
              }))
            : raw.layers,
        }
      : input;
  const result = validateProject(candidate) as EmbeddedSceneProject;
  await Promise.all(
    result.layers.map(async (layer, index) => {
      const original = raw.layers![index]?.asset;
      if (original?.data !== undefined) return;
      if (typeof original?.src !== "string")
        throw new Error(`Missing artwork for ${layer.name}.`);
      const response = await fetchResponse(
        resolveURL(original.src, base),
        options.signal,
      );
      const type = (response.headers.get("content-type") ?? "")
        .split(";")[0]
        .trim()
        .toLowerCase();
      if (
        !["image/png", "image/jpeg", "image/webp", "image/svg+xml"].includes(
          type,
        )
      )
        throw new Error(`Unsupported artwork type for ${layer.name}.`);
      const bytes = new Uint8Array(await response.arrayBuffer());
      if (bytes.length > 12000000)
        throw new Error(`Artwork for ${layer.name} exceeds 12 MB.`);
      layer.asset = { name: layer.asset.name, data: dataURL(type, bytes) };
    }),
  );
  aborted(options.signal);
  return validateProject(result) as EmbeddedSceneProject;
}
