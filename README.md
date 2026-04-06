# The Living Project CLI

The Living Project is a model-agnostic AI project workflow with a one-line installer, an upgradeable workspace structure, and a guided operating model for context, generation, review, scope change, and project portfolio management.

## One-Line Install

```powershell
npx -y @the-living-project/the-living-project-cli init
```

## What It Creates

- `START-HERE.md`
  A visible first-run prompt handoff for users.
- `.living-project/`
  The framework workspace for seeds, context, phase guidance, compost, and portfolio review.
- local `living-project` skill support when Codex is available

## How It Works

The framework uses seven phases:

- `SEED`
- `NOURISH`
- `GROW`
- `PRUNE`
- `REPOT`
- `COMPOST`
- `CULTIVATE`

The design goal is simple adoption:

1. Run one command
2. Open the generated workspace
3. Paste the prompt from `START-HERE.md`
4. Let the assistant guide the project into the right phase

## Core Documents

- [Deployment Package README](c:\Users\KTK\Desktop\Organic Development 1\deploy\organic-development\README.md)
- [Cheat Sheet](c:\Users\KTK\Desktop\Organic Development 1\deploy\organic-development\CHEAT-SHEET.md)
- [Whitepaper](c:\Users\KTK\Desktop\Organic Development 1\WHITEPAPER.md)
- [Release Notes 3.0.3](c:\Users\KTK\Desktop\Organic Development 1\RELEASE-NOTES-3.0.3.md)

## Current State

- public npm package is live
- trusted publishing is configured through GitHub Actions
- CI validates package behavior on `main` and pull requests
- the current stable tested install path is the public npm command above

## Releases

The standard release tag format is:

```text
living-project-vX.Y.Z
```

Tagged releases are intended to publish through GitHub Actions using npm trusted publishing.
