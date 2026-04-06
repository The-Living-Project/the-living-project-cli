# The Living Project 3.0.3

## Highlights

- published The Living Project under the live npm package:
  `@the-living-project/the-living-project-cli`
- enabled GitHub Actions trusted publishing for future releases
- verified the one-line install flow from npm
- fixed Windows packaging behavior for the workspace template `.gitignore`

## Install

```powershell
npx -y @the-living-project/the-living-project-cli init
```

## What This Release Delivers

- creates a ready-to-use `The Living Project Workspace`
- installs the `living-project` Codex skill when available
- writes the framework into `.living-project/`
- includes `START-HERE.md` with a universal prompt and Codex shortcut
- supports safe upgrades of managed files while preserving user work

## Release Notes

- `3.0.0`
  First public npm release.
- `3.0.1`
  Improved executable mapping for npm launch behavior.
- `3.0.2`
  Simplified direct `npx` usage.
- `3.0.3`
  Fixed packaged workspace `.gitignore` handling so the public one-line install completes correctly on Windows.
