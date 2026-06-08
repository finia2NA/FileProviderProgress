# File Provider Progress

Raycast frontend for the `fp-progress` Swift probe.

## Development

From the repo root:

```sh
make raycast-install
make raycast-dev
```

Development mode builds the Swift debug CLI, copies it to `raycast/assets/bin/fp-progress`, and launches Raycast with that bundled asset.

## Production-style Build

```sh
make raycast-build
```

This builds the Swift CLI in release mode, copies it to `raycast/assets/bin/fp-progress`, and runs Raycast's production build validation.

The bundled binary is generated from this repo's Swift source and intentionally ignored by git while the project is moving quickly.

Strict Store linting requires the `author` field in `package.json` to be a real Raycast Store username. The default local lint target runs TypeScript checks; `npm run lint:raycast` and `npm run lint:store` are available once the author handle is finalized.
