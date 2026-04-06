# The Living Project Whitepaper

## Overview

The Living Project is a model-agnostic framework and installable CLI for running AI-assisted project work with stronger context, better iteration discipline, and safer release practices. It combines a one-line public installer, a structured local workspace, an optional Codex skill, and a release process that supports versioned upgrades over time.

The current live package is:

```text
@the-living-project/the-living-project-cli
```

The current tested one-line install command is:

```powershell
npx -y @the-living-project/the-living-project-cli init
```

## The Problem

Most AI-assisted work fails for predictable reasons:

- teams start with deliverables instead of the real problem
- context is incomplete, fragmented, or never written down
- first drafts are treated as finished work
- scope drift is noticed too late
- abandoned efforts are not mined for reusable insight
- every new project starts from scratch instead of from a reusable system

The Living Project addresses those issues by turning the workspace itself into a durable operating model.

## Framework Design

The Living Project uses a seven-phase structure.

Core loop:

1. `SEED`
   Define the real problem and root need.
2. `NOURISH`
   Load relevant context before generation.
3. `GROW`
   Generate drafts, options, and candidate outputs.
4. `PRUNE`
   Critique, improve, reduce risk, and tighten quality.

Strategic phases:

- `REPOT`
  Restructure scope or architecture without discarding the effort.
- `COMPOST`
  Archive learnings and restart with stronger insight.
- `CULTIVATE`
  Step back to manage multiple active projects as a portfolio.

## Product Architecture

The current implementation has four main layers:

1. Public npm package
   Distributed through npm as `@the-living-project/the-living-project-cli`.
2. CLI runtime
   Handles `init`, `upgrade`, and `doctor`.
3. Workspace payload
   Creates a project folder with `.living-project/`, `START-HERE.md`, and phase guidance.
4. Optional Codex skill
   Installs a local skill when Codex is present, while keeping the workspace usable in any AI tool through a universal prompt.

## Workspace Contract

The installer creates a workspace that behaves as the durable memory layer for the project.

Key files and folders:

- `START-HERE.md`
  The visible first-run handoff for end users.
- `.living-project/seeds/`
  Seed statements and sub-project seeds.
- `.living-project/context/`
  Context briefs and working memory.
- `.living-project/phases/`
  The reusable phase guidance.
- `.living-project/compost/`
  Post-mortems and extracted learnings.
- `.living-project/cultivate-log.md`
  Portfolio and weekly review record.

## Installation Experience

The design goal is zero-training startup.

End-user flow:

1. Run one command.
2. Open the generated workspace.
3. Paste the provided prompt.
4. Let the AI route the user into the right phase.

That minimizes onboarding burden and makes the framework usable by people who do not already know the vocabulary.

## Model-Agnostic Strategy

The Living Project is not tied to a single model vendor.

It stays portable by separating:

- framework content
- workspace structure
- optional client-specific integrations

The same workspace can be used with:

- Codex, using the installed local skill when available
- other AI tools, using the universal prompt in `START-HERE.md`

This keeps the method portable while still allowing richer local experiences where supported.

## Release And Upgrade Model

The project supports versioned distribution and repeatable upgrades.

Current release model:

- source of truth: GitHub
- distribution: npm
- release automation: GitHub Actions
- npm publishing: trusted publishing via OIDC

Managed files are refreshed during upgrades while user work is preserved in:

- `seeds`
- `context`
- `compost`
- `cultivate-log.md`

This is essential for enterprise use because the framework itself can evolve while active project material remains intact.

## Current State

As of the current release:

- the GitHub repository is live
- the npm package is published
- the one-line installer is working
- trusted publishing is configured for future releases
- CI exists to validate package behavior on `main` and pull requests

Current tested release:

```text
3.0.3
```

## Why This Matters

The Living Project is not just a prompt pack or template bundle. It is an operational wrapper around AI-assisted project work. Its main value is not only better outputs, but a better system for producing, revising, and sustaining those outputs across time.

In practice, it gives teams:

- a repeatable way to start projects
- a consistent method for loading context
- a safer review habit before shipping work
- an upgradeable framework that does not destroy user content
- a portable system that can move across AI tools

## Next Evolution

The strongest next improvements are:

- a top-level GitHub landing README
- a richer website or documentation portal
- broader cross-platform smoke testing
- release notes for every tagged version
- additional integration paths for non-Codex clients

## Conclusion

The Living Project has moved from concept to deployable product. It now exists as a public package, a working CLI, a reusable workspace framework, and a release-managed system that can be improved over time without breaking user adoption.
