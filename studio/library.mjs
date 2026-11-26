export function mountLibrary({ button, dialog, catalog, onSelect }) {
  const search = dialog.querySelector("input"),
    filter = dialog.querySelector("select"),
    grid = dialog.querySelector(".catalog-grid"),
    count = dialog.querySelector("[role=status]");
  for (const category of [
    ...new Set(catalog.map((s) => s.category || "Starter scenes")),
  ]) {
    const option = document.createElement("option");
    option.value = category;
    option.textContent = category;
    filter.append(option);
  }
  let token = 0;
  function render() {
    const query = search.value.trim().toLowerCase();
    const items = catalog.filter(
      (s) =>
        (!filter.value || (s.category || "Starter scenes") === filter.value) &&
        [s.name, s.id, ...(s.tags || [])]
          .join(" ")
          .toLowerCase()
          .includes(query),
    );
    count.textContent = `${items.length} of ${catalog.length} scenes`;
    grid.replaceChildren(
      ...items.map((scene) => {
        const card = document.createElement("button");
        card.className = "catalog-card";
        card.type = "button";
        card.setAttribute("aria-label", `Open ${scene.name}`);
        const img = document.createElement("img");
        img.alt = "";
        img.loading = "lazy";
        img.width = 402;
        img.height = 268;
        img.src = scene.thumbnail
          ? `assets/${scene.thumbnail}`
          : "assets/library-placeholder.svg";
        const name = document.createElement("strong");
        name.textContent = scene.name;
        const category = document.createElement("span");
        category.textContent = scene.category || "Starter scenes";
        card.append(img, name, category);
        card.onclick = async () => {
          const request = ++token;
          card.disabled = true;
          try {
            await onSelect(scene);
            if (request === token) dialog.close();
          } catch (error) {
            count.textContent = error.message;
          } finally {
            card.disabled = false;
          }
        };
        return card;
      }),
    );
  }
  search.oninput = filter.onchange = render;
  dialog.querySelector("[data-close-library]").onclick = () => dialog.close();
  button.textContent = `Browse library · ${catalog.length}`;
  button.onclick = () => {
    render();
    dialog.showModal();
    search.focus();
  };
}
