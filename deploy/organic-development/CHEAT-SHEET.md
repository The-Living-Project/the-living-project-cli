# The Living Project Cheat Sheet

## Page 1: Start Fast

### One-Line Install

Published package:

```powershell
npx -y @the-living-project/the-living-project-cli init
```

Tested package version:

```text
@the-living-project/the-living-project-cli@3.0.3
```

Local package folder:

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

### What The Installer Creates

- `START-HERE.md`
  The one file most users need to open first.
- `.living-project/seeds/`
  Seed statements for each project or sub-project.
- `.living-project/context/`
  Context briefs, stakeholder inputs, notes, and constraints.
- `.living-project/phases/`
  The framework guidance for the seven phases.
- `.living-project/compost/`
  Post-mortems, lessons learned, reusable components.
- `.living-project/cultivate-log.md`
  Cross-project review, prioritization, and weekly status.

### The One Prompt To Use

Universal:

```text
Use The Living Project framework in this folder. Treat this as my active workspace.
Read `.living-project/QUICKSTART.md`, figure out the right phase automatically,
ask me only the minimum questions needed, and write the outputs into
`.living-project` as we go.
```

Codex shortcut:

```text
Use $living-project in this folder and guide me to the right next step.
```

### The Core Loop

1. `SEED`
   Define the real problem, not just the requested deliverable.
2. `NOURISH`
   Load the context: background, constraints, data, prior art, stakeholders.
3. `GROW`
   Generate drafts, options, and candidate solutions.
4. `PRUNE`
   Critique, tighten, reduce risk, and improve clarity.
5. Repeat until the output is strong enough to ship or hand off.

### The Strategic Phases

- `REPOT`
  The project still makes sense, but the scope or structure needs to change.
- `COMPOST`
  The direction is no longer right, so capture the learnings and restart smarter.
- `CULTIVATE`
  Step back and manage multiple active projects as a portfolio.

### How To Know Where To Start

- New project or fuzzy idea:
  Start with `SEED`.
- You already have notes, emails, requirements, or research:
  Move into `NOURISH`.
- You need a draft, options, or a first version:
  Move into `GROW`.
- You already have an output and want it improved:
  Move into `PRUNE`.
- Scope is drifting or architecture feels too small:
  Use `REPOT`.
- The current direction is failing:
  Use `COMPOST`.
- You need to compare projects or decide priorities:
  Use `CULTIVATE`.

---

## Page 2: Work The Framework

### What Good Usage Looks Like

- Start with the problem, not "write me a document."
- Give the assistant the seed and the real context before asking it to generate.
- Let the assistant write into `.living-project/` so the workspace becomes the source of truth.
- Ask for multiple approaches when the direction is still uncertain.
- Use critique intentionally before shipping or sharing output.

### The Minimum Inputs For Each Phase

- `SEED`
  Problem statement, audience, urgency, and why it matters now.
- `NOURISH`
  Prior work, constraints, stakeholder notes, examples, and success criteria.
- `GROW`
  Desired deliverable, format, audience, and constraints.
- `PRUNE`
  The original goal plus the current draft or output.
- `REPOT`
  Original scope, current scope, and what has changed.
- `COMPOST`
  What failed, what was learned, and what should carry forward.
- `CULTIVATE`
  Current project list, phases, blockers, and upcoming decisions.

### File Guide

- Create seeds in:
  `.living-project/seeds/project-name.md`
- Store context in:
  `.living-project/context/project-name-context.md`
- Save post-mortems in:
  `.living-project/compost/project-name-YYYY-MM-DD.md`
- Keep your portfolio review in:
  `.living-project/cultivate-log.md`

### Upgrade Commands

```powershell
npx -y @the-living-project/the-living-project-cli upgrade
npx -y @the-living-project/the-living-project-cli doctor
```

What upgrades do:

- refresh managed framework files
- preserve user work in `seeds`, `context`, `compost`, and `cultivate-log.md`
- back up replaced managed files before updating

### Common Team Habits

- Every new effort gets a seed.
- Every important project gets a living context brief.
- Every major draft gets pruned before wider review.
- Every stalled direction gets composted instead of silently abandoned.
- Every week, someone cultivates across the active project set.

### Manager Shortcut Prompts

```text
Review this workspace and tell me which phase this project is in, what is missing,
and what the next best action should be.
```

```text
Compare the active projects in this workspace, flag risks and dependencies,
and recommend where attention should go this week.
```

### Contributor Shortcut Prompts

```text
Help me create a strong seed for this project and save it into `.living-project/seeds`.
```

```text
Turn my notes into a context brief and save it into `.living-project/context`.
```

```text
Review my current draft against the original seed, identify gaps and risks,
and improve it.
```

### Rule Of Thumb

If the work feels vague, go back to `SEED`.
If the output feels generic, improve `NOURISH`.
If the draft feels weak, iterate in `GROW`.
If the result feels risky, run `PRUNE`.

### Release Model

- npm package is live and publicly installable
- GitHub is the source of truth for changes and releases
- trusted publishing is configured for future tagged releases
- the standard release tag format is `living-project-vX.Y.Z`
