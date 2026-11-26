# Contributing

Open an issue for substantial API changes before implementing them. Keep the engine independent of app-specific models, location providers and artwork catalogs.

Run `swift test`, `swift build --target SceneWeaverExamples` and the iOS simulator build documented in the README before submitting a pull request. Add a regression test for geometry, compositing or timeline changes where feasible. Check Reduce Motion, daylight and night, narrow and wide viewports, and RTL placement when they affect the change.

Use only code and assets you have the right to contribute. Contributions are provided under this repository's MIT license.
