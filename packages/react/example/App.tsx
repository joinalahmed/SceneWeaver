import { useState } from "react";
import { createRoot } from "react-dom/client";
import { SceneView } from "../dist/index.js";
import type { SceneWeather } from "../dist/index.js";
function App() {
  const [scene, setScene] = useState("alpine"),
    [hour, setHour] = useState(18.6),
    [weather, setWeather] = useState<SceneWeather>("clear"),
    [paused, setPaused] = useState(false);
  const url = new URL(`../assets/${scene}.json`, location.href).href;
  return (
    <main className="playground">
      <header>
        <a href="../">← SceneWeaver Studio</a>
        <span>REACT / 0.1</span>
      </header>
      <section className="intro">
        <div>
          <p className="eyebrow">React component example</p>
          <h1>SceneWeaver for React</h1>
          <p>
            Render a Studio project with controlled time, weather and lighting.
          </p>
        </div>
        <a
          className="source"
          href="https://github.com/joinalahmed/SceneWeaver/tree/main/packages/react"
          target="_blank"
          rel="noopener noreferrer"
        >
          Source & installation ↗
        </a>
      </section>
      <SceneView
        project={url}
        hour={hour}
        weather={weather}
        paused={paused}
        label={
          scene === "alpine"
            ? "A cabin beside an alpine lake"
            : "A lighthouse overlooking a harbor"
        }
        className="demo-scene"
        style={{ borderRadius: 0 }}
        fallback={<span>Loading artwork…</span>}
      />
      <section className="controls" aria-label="Scene controls">
        <label>
          Composition
          <select value={scene} onChange={(e) => setScene(e.target.value)}>
            <option value="alpine">Alpine hideaway</option>
            <option value="harbor">Harbor at dusk</option>
          </select>
        </label>
        <label>
          Time{" "}
          <span>{`${String(Math.floor(hour)).padStart(2, "0")}:${String(Math.floor((hour % 1) * 60)).padStart(2, "0")}`}</span>
          <input
            aria-label="Time of day"
            type="range"
            min="0"
            max="23.99"
            step=".01"
            value={hour}
            onChange={(e) => setHour(Number(e.target.value))}
          />
        </label>
        <label>
          Weather
          <select
            value={weather}
            onChange={(e) => setWeather(e.target.value as SceneWeather)}
          >
            <option value="clear">Clear</option>
            <option value="rain">Rain</option>
            <option value="snow">Snow</option>
            <option value="thunderstorm">Thunderstorm</option>
          </select>
        </label>
        <button aria-pressed={paused} onClick={() => setPaused(!paused)}>
          {paused ? "Play motion" : "Pause motion"}
        </button>
      </section>
      <section className="usage">
        <div>
          <h2>Usage</h2>
          <p>
            Use a saved Studio JSON file, a project URL, or your own typed
            layers. React controls the props; the shared Canvas renderer draws
            the scene.
          </p>
          <p className="note">
            This is the web renderer. The SwiftUI package remains the native iOS
            renderer.
          </p>
        </div>
        <pre>
          <code>{`import { SceneView } from "sceneweaver-react";\n\n<SceneView\n  project="/scenes/my-project.json"\n  hour={${hour.toFixed(1)}}\n  weather="${weather}"\n  paused={${paused}}\n/>`}</code>
        </pre>
      </section>
      <footer>
        <span>React 18 & 19 · TypeScript · Studio project format</span>
        <a href="THIRD_PARTY_LICENSES.txt">Third-party licenses</a>
      </footer>
    </main>
  );
}
createRoot(document.getElementById("root")!).render(<App />);
