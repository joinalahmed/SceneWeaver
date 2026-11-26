"use client";
import { useEffect, useMemo, useState, type CSSProperties } from "react";
export interface SceneLibraryEntry {
  id: string;
  name: string;
  category?: string;
  tags?: string[];
  project: string;
  thumbnail?: string;
  nativeID?: string;
}
export interface SceneLibraryProps {
  catalogURL: string;
  onSelect: (entry: SceneLibraryEntry, projectURL: string) => void;
  className?: string;
  style?: CSSProperties;
}
/** Searchable, lazy-loaded browser for the complete catalog; artwork loads on selection. */
export function SceneLibrary({
  catalogURL,
  onSelect,
  className,
  style,
}: SceneLibraryProps) {
  const libraryURL =
    typeof document === "undefined"
      ? catalogURL
      : new URL(catalogURL, document.baseURI).href;
  const [entries, setEntries] = useState<SceneLibraryEntry[]>([]),
    [query, setQuery] = useState(""),
    [category, setCategory] = useState(""),
    [error, setError] = useState("");
  useEffect(() => {
    const controller = new AbortController();
    setEntries([]);
    setError("");
    fetch(libraryURL, { signal: controller.signal })
      .then((r) => {
        if (!r.ok) throw Error(`Could not load library (HTTP ${r.status}).`);
        return r.json();
      })
      .then((data) => {
        if (
          !Array.isArray(data.scenes) ||
          data.scenes.some(
            (e: SceneLibraryEntry) =>
              !e.id ||
              typeof e.name !== "string" ||
              !/^[-A-Za-z0-9_]+\.json$/.test(e.project),
          )
        )
          throw Error("Invalid scene library.");
        if (!controller.signal.aborted) setEntries(data.scenes);
      })
      .catch((e) => {
        if (!controller.signal.aborted) setError(e.message);
      });
    return () => controller.abort();
  }, [libraryURL]);
  const categories = useMemo(
    () => [...new Set(entries.map((e) => e.category || "Starter scenes"))],
    [entries],
  );
  const filtered = entries.filter(
    (e) =>
      (!category || (e.category || "Starter scenes") === category) &&
      [e.name, e.id, ...(e.tags || [])]
        .join(" ")
        .toLowerCase()
        .includes(query.toLowerCase()),
  );
  return (
    <section className={className} style={style} aria-label="Scene library">
      <div
        style={{ display: "flex", gap: 12, flexWrap: "wrap", marginBottom: 12 }}
      >
        <input
          aria-label="Search scene library"
          type="search"
          placeholder="Search places, scenes and themes"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
        />
        <select
          aria-label="Filter scene category"
          value={category}
          onChange={(e) => setCategory(e.target.value)}
        >
          <option value="">All categories</option>
          {categories.map((c) => (
            <option key={c}>{c}</option>
          ))}
        </select>
      </div>
      <p role={error ? "alert" : "status"}>
        {error || `${filtered.length} of ${entries.length} scenes`}
      </p>
      <div
        style={{
          display: "grid",
          gridTemplateColumns: "repeat(auto-fill,minmax(180px,1fr))",
          gap: 16,
        }}
      >
        {filtered.map((entry) => (
          <button
            key={entry.id}
            type="button"
            aria-label={`Open ${entry.name}`}
            onClick={() =>
              onSelect(entry, new URL(entry.project, libraryURL).href)
            }
            style={{
              padding: 0,
              textAlign: "left",
              background: "white",
              border: "1px solid #d9dce2",
              overflow: "hidden",
              cursor: "pointer",
            }}
          >
            {entry.thumbnail && (
              <img
                loading="lazy"
                alt=""
                width={402}
                height={268}
                style={{ display: "block", width: "100%", height: "auto" }}
                src={new URL(entry.thumbnail, libraryURL).href}
              />
            )}
            <strong
              style={{ display: "block", padding: "10px 10px 0", fontSize: 13 }}
            >
              {entry.name}
            </strong>
            <span
              style={{
                display: "block",
                padding: 10,
                color: "#666",
                fontSize: 12,
              }}
            >
              {entry.category || "Starter scenes"}
            </span>
          </button>
        ))}
      </div>
    </section>
  );
}
