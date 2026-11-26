import { validateNativeScene } from "./native-scene.mjs";
/** Decode compressed catalog geometry (or ordinary JSON), never executable code. */
export async function readNativeGeometry(response) {
  if (!response.ok)
    throw Error(`Could not load native scene (HTTP ${response.status}).`);
  const bytes = new Uint8Array(await response.arrayBuffer());
  if (bytes.length > 30000000) throw Error("Native scene exceeds 30 MB.");
  let text;
  if (bytes[0] === 0x1f && bytes[1] === 0x8b) {
    if (typeof DecompressionStream === "undefined")
      throw Error("This browser does not support compressed scene assets.");
    text = await new Response(
      new Blob([bytes]).stream().pipeThrough(new DecompressionStream("gzip")),
    ).text();
  } else text = new TextDecoder().decode(bytes);
  if (text.length > 50000000)
    throw Error("Decoded native scene exceeds 50 MB.");
  return validateNativeScene(JSON.parse(text));
}
