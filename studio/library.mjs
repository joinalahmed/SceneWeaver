export function mountLibrary({ button, dialog, catalog, components, onSelect }) {
  const search = dialog.querySelector("input"),
    filter = dialog.querySelector('[aria-label="Filter scene category"]'),
    grid = dialog.querySelector(".catalog-grid"),
    count = dialog.querySelector("[role=status]");
  const scope = dialog.querySelector('[aria-label="Library collection"]');
  let collection = components;
  function categories() {
    filter.hidden = scope.value === 'components';
    dialog.querySelector('.catalog-search').style.gridTemplateColumns = filter.hidden ? '1fr' : '';
    search.placeholder = filter.hidden ? 'Search components' : 'Search places, scenes and themes';
    filter.replaceChildren(new Option('All categories', ''));
    for (const category of new Set(collection.map(s => s.category || 'Scenes')))
      filter.append(new Option(category, category));
  }
  scope.onchange = () => {
    collection = scope.value === 'components' ? components : catalog;
    search.value = '';categories();render();
  };
  categories();
  let token = 0;
  function render() {
    const query = search.value.trim().toLowerCase();
    const items = collection.filter(
      (s) =>
        (!filter.value || (s.category || "Starter scenes") === filter.value) &&
        [s.name, s.id, ...(s.tags || [])]
          .join(" ")
          .toLowerCase()
          .includes(query),
    );
    count.textContent = `${items.length} of ${collection.length} ${scope.value === "components" ? "components" : "scenes"}`;
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
        category.textContent = scene.description || scene.category || "Scenes";
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
  button.textContent = `Browse components · ${components.length}`;
  button.onclick = () => {
    render();
    dialog.showModal();
    search.focus();
  };
}
