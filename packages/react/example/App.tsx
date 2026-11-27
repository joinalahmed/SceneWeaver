import { useState, useEffect } from "react";
import { createRoot } from "react-dom/client";
import { SceneView, SceneLibrary } from "../dist/index.js";
import type { SceneWeather } from "../dist/index.js";
function App() {
  const [scene, setScene] = useState("alpine"),
    [hour, setHour] = useState(18.6),
    [weather, setWeather] = useState<SceneWeather>("clear"),
    [paused, setPaused] = useState(false),
    [catalog, setCatalog] = useState<
      Array<{ id: string; name: string; category?: string; project: string }>
    >([]),
    [components, setComponents] = useState<typeof catalog>([]),
    [libraryOpen, setLibraryOpen] = useState(false);
  const catalogURL = new URL(
    "../assets/catalog.json?v=components-1",
    location.href,
  ).href;
  useEffect(() => {
    const controller = new AbortController();
    fetch(new URL('components.json',catalogURL),{signal:controller.signal}).then(r=>r.json()).then(data=>setComponents(data.scenes)).catch(()=>{});
    fetch(catalogURL, { signal: controller.signal })
      .then((r) => r.json())
      .then((data) => setCatalog(data.scenes))
      .catch(() => {});
    return () => controller.abort();
  }, [catalogURL]);
  const selected = [...components,...catalog].find((entry) => entry.id === scene);
  const url = new URL(
    `../assets/${selected?.project ?? `${scene}.json`}`,
    location.href,
  ).href;
  return (
    <main className="playground">
      <header>
        <a href="../">← SceneWeaver Studio</a>
        <span>REACT / 0.3</span>
      </header>
      <section className="intro">
        <div>
          <p className="eyebrow">React component example</p>
          <h1>SceneWeaver for React</h1>
          <p>
            One example per reusable component. Open All scenes for the full artwork collection.
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
        onReady={project => {
          if (selected?.id.startsWith('component-')) {
            setHour(project.settings.hour);setWeather(project.settings.weather);
          }
        }}
        hour={hour}
        weather={weather}
        paused={paused}
        label={selected?.name ?? "Scene preview"}
        className="demo-scene"
        style={{ borderRadius: 0 }}
        fallback={<span>Loading artwork…</span>}
      />
      <button
        onClick={() => setLibraryOpen(!libraryOpen)}
        aria-expanded={libraryOpen}
      >
        Browse component library
      </button>
      {libraryOpen && (
        <SceneLibrary
          catalogURL={catalogURL}
          componentCatalogURL={new URL("components.json", catalogURL).href}
          onSelect={(entry) => {
            setScene(entry.id);
            setLibraryOpen(false);
          }}
        />
      )}
      <section className="controls" aria-label="Scene controls">
        <label>
          Composition
          <select value={scene} onChange={(e) => setScene(e.target.value)}>
            {(catalog.length
              ? [...components, ...catalog.filter(entry => ["alpine","harbor",scene].includes(entry.id))]
              : [
                  { id: "alpine", name: "Alpine hideaway" },
                  { id: "harbor", name: "Harbor at dusk" },
                ]
            ).map((entry) => (
              <option key={entry.id} value={entry.id}>
                {entry.name}
              </option>
            ))}
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
            <option value="partlyCloudy">Partly cloudy</option>
            <option value="cloudy">Cloudy</option>
            <option value="fog">Fog</option>
            <option value="drizzle">Drizzle</option>
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
          <code>{`import { SceneView, SceneLibrary } from "sceneweaver-react";\n\n<SceneView\n  project="/scenes/my-project.json"\n  hour={${hour.toFixed(1)}}\n  weather="${weather}"\n  paused={${paused}}\n/>`}</code>
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
