import { StrictMode, useState } from "react";
import { createRoot } from "react-dom/client";
import { SceneView } from "../dist/index.js";
const metrics = { ready: 0, errors: [] as string[], frames: new Set<number>() };
const request = window.requestAnimationFrame.bind(window),
  cancel = window.cancelAnimationFrame.bind(window);
window.requestAnimationFrame = (callback) => {
  const handle = request((time) => {
    metrics.frames.delete(handle);
    callback(time);
  });
  metrics.frames.add(handle);
  return handle;
};
window.cancelAnimationFrame = (handle) => {
  metrics.frames.delete(handle);
  cancel(handle);
};
function Fixture() {
  const [source, setSource] = useState("/studio/assets/alpine.json"),
    [hour, setHour] = useState(18.6),
    [weather, setWeather] = useState<"clear" | "rain">("clear"),
    [paused, setPaused] = useState(false),
    [mounted, setMounted] = useState(true);
  Object.assign(window, {
    sceneTest: {
      metrics,
      setSource,
      setHour,
      setWeather,
      setPaused,
      setMounted,
    },
  });
  return (
    <>
      {mounted && (
        <SceneView
          project={source}
          hour={hour}
          weather={weather}
          paused={paused}
          label="Test landscape"
          data-testid="scene"
          style={{ maxWidth: 800 }}
          onReady={() => metrics.ready++}
          onError={(error) => metrics.errors.push(error.message)}
        >
          <button id="overlay-button">Interactive overlay</button>
        </SceneView>
      )}
    </>
  );
}
createRoot(document.getElementById("root")!).render(
  <StrictMode>
    <Fixture />
  </StrictMode>,
);
