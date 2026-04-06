# The Living Project Deployment Package

## One-Line Install

Published package:

```powershell
npx -y __PACKAGE_NAME__ init
```

Alternative runners:

```powershell
pnpm dlx __PACKAGE_NAME__ init
bunx __PACKAGE_NAME__ init
yarn dlx __PACKAGE_NAME__ init
```

Local package folder:

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

Optional custom workspace name:

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1 "My Project Workspace"
```

## What It Does

- installs the `living-project` skill into the local Codex skills directory when available
- creates a new workspace folder with a ready-to-use `.living-project/` framework
- drops a visible `START-HERE.md` file with a universal prompt plus a Codex shortcut
- preserves user-created project files on rerun while upgrading managed framework files

## How Upgrades Work

Share a newer version of this package and rerun the same command.

- the skill is replaced with the new version after backing up the previous one
- managed workspace files are refreshed
- user work in `seeds/`, `context/`, `compost/`, and `cultivate-log.md` is preserved

## Commands

```powershell
npx -y __PACKAGE_NAME__ init
npx -y __PACKAGE_NAME__ upgrade
npx -y __PACKAGE_NAME__ doctor
```

## Branding And Release

Edit `release.config.json` to set your author name, npm package name, and repository URLs.

Then run:

```powershell
node .\scripts\prepare-release.mjs
npm pack
```
