---
name: living-project
description: >
  Use this skill when the user wants a guided project workflow for AI-assisted work,
  especially for starting a new project, loading context, generating deliverables,
  reviewing work, resetting direction, or managing multiple active efforts. Trigger
  on mentions of "the living project", "living project", "organic development",
  "seed a project", "nourish context", "grow phase", "prune output", "repot scope",
  "compost learnings", "cultivate portfolio", or any reference to the seven-phase
  framework. Also trigger when users say
  "start a new project", "help me get started", "what should I do next", "review my
  work", "is this scope creeping", "should I start over", or "what's the status
  across my projects". This skill provides structured phase guidance, prompt
  templates, first-run onboarding, and multi-agent orchestration patterns.
---

# The Living Project — AI-Assisted Project Framework

## Overview

The Living Project treats AI-assisted project work as a living system with seven phases:

**Core Loop:** SEED → NOURISH → GROW → PRUNE → (repeat)
**Strategic Phases:** REPOT | COMPOST | CULTIVATE

## First-Run Behavior

When the workspace is new or the user is unsure where to begin:

1. Check `.living-project/` for an existing seed, context brief, and prior outputs.
2. If the workspace is empty or early-stage, default to **SEED** and guide the user
   with the fewest questions needed to create momentum.
3. If files already exist, infer the most likely current phase before asking for more input.
4. Write outputs into `.living-project/` as you go so the workspace becomes the system of record.
5. Prefer plain-language guidance. Do not require the user to know the framework vocabulary.

## Phase Guidance

When the user enters a phase, read the corresponding file from `phases/` and follow
its instructions. Each phase file contains:
- What to do (practitioner guidance)
- How to frame prompts (exact templates)
- Multi-agent patterns (parallel agent strategies)
- Completion criteria (when to move to next phase)

### Quick Phase Router

| User says... | Phase | Action |
|---|---|---|
| "Start a new project" / "I have an idea" | SEED | Read phases/01-seed.md |
| "Here's the background" / "Let me give you context" | NOURISH | Read phases/02-nourish.md |
| "Generate" / "Build" / "Draft" / "Create" | GROW | Read phases/03-grow.md |
| "Review this" / "Check my work" / "Improve" | PRUNE | Read phases/04-prune.md |
| "This is getting too big" / "Scope is growing" | REPOT | Read phases/05-repot.md |
| "This isn't working" / "Start over" / "What did we learn" | COMPOST | Read phases/06-compost.md |
| "Status across projects" / "What's the priority" | CULTIVATE | Read phases/07-cultivate.md |

### Key Principles

1. **Context is fertilizer.** Always front-load context before generation.
2. **Never start with "write me a..."** Start with the problem, not the deliverable.
3. **Use parallel agents.** Multiple perspectives beat sequential refinement.
4. **Restate the seed when pruning.** The agent needs the measuring stick.
5. **Composting is productive.** Nothing is wasted — learnings feed the next cycle.

### Project State

Check `.living-project/` for:
- `seeds/` — Active and archived seed statements
- `context/` — Living context documents
- `compost/` — Learnings from completed/abandoned cycles
- `cultivate-log.md` — Portfolio awareness journal

## Operating Expectations

- If the user is vague, help them start instead of asking for a framework term.
- When a phase is obvious, begin the work and explain the next best step briefly.
- Keep the user moving: ask only high-value questions and convert answers into files.
- Treat `.living-project/` as the durable memory layer for the project.
