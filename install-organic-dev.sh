#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════════╗
# ║  ORGANIC DEVELOPMENT - Project Installer v2.0                   ║
# ║  A Nature-Inspired Framework for AI-Assisted Project Dev        ║
# ║  Author: Chamal Abeysekera | CC BY 4.0                         ║
# ╚══════════════════════════════════════════════════════════════════╝
#
# Usage:
#   ./install-organic-dev.sh                    # Install in current directory
#   ./install-organic-dev.sh /path/to/project   # Install in specified directory
#   ./install-organic-dev.sh --help             # Show help

set -euo pipefail

VERSION="2.0"
GREEN='\033[0;32m'
BROWN='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# ── Help ──
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  echo ""
  echo -e "${GREEN}${BOLD}Organic Development Installer v${VERSION}${NC}"
  echo ""
  echo "Usage:"
  echo "  ./install-organic-dev.sh                    # Install in current directory"
  echo "  ./install-organic-dev.sh /path/to/project   # Install in target directory"
  echo ""
  echo "Creates:"
  echo "  .organic-dev/           # Framework configuration"
  echo "    SKILL.md              # MCP skill definition (drop into /mnt/skills/user/)"
  echo "    phases/               # Phase guidance and templates"
  echo "    context/              # Living context store"
  echo "    compost/              # Archived learnings from completed cycles"
  echo "    cultivate-log.md      # Portfolio awareness journal"
  echo ""
  exit 0
fi

TARGET="${1:-.}"
OD_DIR="${TARGET}/.organic-dev"

echo ""
echo -e "${GREEN}${BOLD}  ╔══════════════════════════════════════════╗${NC}"
echo -e "${GREEN}${BOLD}  ║   ORGANIC DEVELOPMENT INSTALLER v${VERSION}    ║${NC}"
echo -e "${GREEN}${BOLD}  ║   Seed • Nourish • Grow • Prune         ║${NC}"
echo -e "${GREEN}${BOLD}  ║   Repot • Compost • Cultivate           ║${NC}"
echo -e "${GREEN}${BOLD}  ╚══════════════════════════════════════════╝${NC}"
echo ""

# ── Create structure ──
echo -e "${BROWN}Creating project structure...${NC}"
mkdir -p "${OD_DIR}/phases"
mkdir -p "${OD_DIR}/context"
mkdir -p "${OD_DIR}/compost"
mkdir -p "${OD_DIR}/seeds"

# ── SKILL.md (MCP Skill Definition) ──
cat > "${OD_DIR}/SKILL.md" << 'SKILL_EOF'
---
name: organic-development
description: >
  Use this skill when the user wants to follow the Organic Development methodology
  for AI-assisted project work. Triggers include: mentions of "organic development",
  "seed a project", "nourish context", "grow phase", "prune output", "repot scope",
  "compost learnings", "cultivate portfolio", or any reference to the seven-phase
  framework. Also trigger when users say "start a new project", "review my work",
  "is this scope creeping", "should I start over", or "what's the status across
  my projects". This skill provides structured phase guidance, prompt templates,
  and multi-agent orchestration patterns.
---

# Organic Development — AI-Assisted Project Framework

## Overview

Organic Development treats AI-assisted project work as a living system with seven phases:

**Core Loop:** SEED → NOURISH → GROW → PRUNE → (repeat)
**Strategic Phases:** REPOT | COMPOST | CULTIVATE

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

Check `.organic-dev/` for:
- `seeds/` — Active and archived seed statements
- `context/` — Living context documents
- `compost/` — Learnings from completed/abandoned cycles
- `cultivate-log.md` — Portfolio awareness journal
SKILL_EOF

# ── Phase 1: SEED ──
cat > "${OD_DIR}/phases/01-seed.md" << 'EOF'
# Phase 1: SEED — Plant the Question

## What To Do

Every project begins with a question, not an answer.

1. **Run the 5 Whys** on the raw problem statement. Keep asking "why" until you
   reach the root cause, not the symptom. For complex problems with multiple
   interacting causes, pair with a fishbone diagram or causal loop analysis.

2. **Answer the 5W Framework:**
   - **Who** is this for? (specific user/stakeholder, not "everyone")
   - **What** does it solve? (the root problem from your 5 Whys)
   - **Where** does it live? (system, organization, workflow)
   - **When** is it needed? (timeline, urgency, dependencies)
   - **Why** does it matter now? (what changes if we don't do this)

3. **Write a seed statement** — one paragraph that captures the real need.
   Save it to `.organic-dev/seeds/[project-name].md`

## How To Frame It

### Primary prompt:
```
The problem is [X]. Ask me 5 Whys — challenge each of my answers and tell
me when we've hit root cause. Don't accept my first answer.
```

### After 5 Whys:
```
Based on our root cause analysis, generate a structured seed statement
answering: Who is this for? What does it solve? Where does it live? When
is it needed? Why does it matter now? Then identify 3 assumptions we're
making and 2 blind spots we might have.
```

### Alternative framing prompt:
```
Here is my problem statement: [X]. Generate 3 alternative framings of
this problem. For each, explain what would change about the solution if
we framed it that way. Which framing is strongest and why?
```

## Multi-Agent Pattern

Assign parallel agents:
- **Agent A:** Run the 5 Whys analysis on the raw problem
- **Agent B:** Research how others have solved this class of problem
- **Agent C:** Challenge the problem statement itself — is this the right problem?

Compare all three outputs before committing to a seed.

## Completion Criteria

You're ready to move to NOURISH when:
- [ ] You have a root cause, not a symptom
- [ ] All 5Ws are answered with specifics (no "everyone" or "ASAP")
- [ ] You can state the seed in one paragraph without jargon
- [ ] You've identified at least 2 assumptions you're making
- [ ] Seed statement saved to `.organic-dev/seeds/`
EOF

# ── Phase 2: NOURISH ──
cat > "${OD_DIR}/phases/02-nourish.md" << 'EOF'
# Phase 2: NOURISH — Context Is Fertilizer

## What To Do

This is the phase most teams skip, and it's the single biggest determinant
of output quality. Load your AI workspace with EVERY piece of relevant context.

1. **Gather inputs:** Prior art, stakeholder notes, technical constraints,
   data, competitive analysis, internal docs, institutional knowledge.

2. **Compile a context brief** — a structured document the AI can reference.
   Save to `.organic-dev/context/[project-name]-context.md`

3. **Validate context completeness** — ask the AI what's missing.

## How To Frame It

### Context loading prompt:
```
Here is everything relevant to this project:

[SEED STATEMENT from Phase 1]

[PASTE: documents, data, constraints, stakeholder notes]

Summarize what you now know about this project. Then:
1. Flag any contradictions in the source material
2. Identify what context is MISSING that you'd need to do great work
3. Produce a structured context inventory I can reuse across conversations
```

### Context completeness check:
```
Given the seed statement [X] and the context I've provided, what questions
would a domain expert ask that I haven't answered? What assumptions am I
making that should be validated before we move to generation?
```

## Multi-Agent Pattern

Run three agents in parallel:
- **Agent A:** Summarize and cross-reference internal documents
- **Agent B:** Research external best practices and competitive landscape
- **Agent C:** Map stakeholder positions from communications (email/Slack/notes)

Merge the three outputs into a unified context brief.

## Completion Criteria

You're ready to move to GROW when:
- [ ] Context brief saved to `.organic-dev/context/`
- [ ] AI has confirmed no major contradictions in source material
- [ ] You've addressed the AI's "missing context" questions
- [ ] Your prompt could NOT apply to any random company — it's specific
- [ ] A colleague could read the context brief and understand the project
EOF

# ── Phase 3: GROW ──
cat > "${OD_DIR}/phases/03-grow.md" << 'EOF'
# Phase 3: GROW — From What Exists to What Should Exist

## What To Do

Bridge the gap between current state (documented in Nourish) and desired
state (defined in Seed). This is directional generation, not open-ended.

1. **Generate with direction.** Always include context + outcome + constraints.
2. **Iterate rapidly.** Each output feeds the next round. Don't start over.
3. **Bias toward quantity.** Perfection comes in Prune. Generate variants.

## How To Frame It

### Generation prompt template:
```
Given this context: [paste context brief or key sections]

Generate [specific deliverable] that achieves [seed outcome].
Format: [document type, structure, length]
Audience: [specific reader/user]
Constraints: [technical, timeline, scope boundaries]
```

### Chaining prompt (iteration 2+):
```
Here is your previous output: [paste or reference]

Corrections needed: [specific issues]
New direction: [what to change or add]
Keep: [what worked well]

Regenerate with these adjustments.
```

### Variant generation:
```
Generate 3 different approaches to [deliverable]:
1. Conservative — minimal risk, proven patterns
2. Ambitious — stretches current capabilities
3. Unconventional — challenges assumptions

Evaluate each against: [seed criteria]. Recommend which to develop further.
```

## Multi-Agent Pattern

Run three agents generating three different approaches simultaneously:
- **Agent A:** Conservative approach
- **Agent B:** Ambitious approach
- **Agent C:** Unconventional approach

Evaluate all three against seed criteria before picking a direction to iterate on.

## Completion Criteria

You're ready to move to PRUNE when:
- [ ] You have at least one complete draft of the deliverable
- [ ] The draft addresses the seed statement directly
- [ ] You've iterated at least twice (no first drafts leave Grow)
- [ ] You can articulate what's good and what's weak about the output
EOF

# ── Phase 4: PRUNE ──
cat > "${OD_DIR}/phases/04-prune.md" << 'EOF'
# Phase 4: PRUNE — Check Your Work, Make Improvements

## What To Do

AI generates plausible content, not necessarily correct content. This is
where human judgment meets AI capability.

1. **Turn the AI against its own work.** Self-critique is underused.
2. **Restate the seed** when asking for critique — the agent needs the measuring stick.
3. **Every element must earn its place.** Cut ruthlessly.

## How To Frame It

### Critique prompt:
```
Review this output against the original goal:
[RESTATE SEED STATEMENT]

Identify:
1. Gaps — what's missing that should be there?
2. Redundancies — what's repeated or unnecessary?
3. Logical errors — what doesn't follow?
4. Risks — what could go wrong if we ship this?

Score 1-10 with justification. Then fix what you found.
```

### Robustness test:
```
Would this output have caught [specific known past failure]?
Walk through the scenario and show where this solution handles
or fails to handle it.
```

### Before/after validation:
```
Here is the version before pruning: [paste]
Here is the version after pruning: [paste]
Did pruning improve or degrade the work? Be specific about what
got better and what got worse.
```

## Multi-Agent Pattern

Give the same output to two agents with different lenses:
- **Agent A:** Critique for technical accuracy and completeness
- **Agent B:** Critique for audience fit, clarity, and actionability

Where their feedback conflicts, you've found a blind spot worth investigating.

## Completion Criteria

You're ready to exit the core loop (or repeat) when:
- [ ] AI self-critique has been run and addressed
- [ ] Output scores 7+ against seed criteria
- [ ] No major gaps or logical errors remain
- [ ] A colleague could use this output without additional explanation
- [ ] Then evaluate: REPOT? COMPOST? CULTIVATE? Or loop again?
EOF

# ── Phase 5: REPOT ──
cat > "${OD_DIR}/phases/05-repot.md" << 'EOF'
# Phase 5: REPOT — Does It Need a Bigger Pot?

## What To Do

Evaluate whether the project has outgrown its original scope, resources,
or architecture. This is deliberate scope evolution, not scope creep.

## When To Repot (vs. Compost)

| Signal | Repot | Compost instead |
|---|---|---|
| Core architecture | Sound, needs more room | Fundamentally wrong |
| Assumptions | Still valid, scope grew | Key assumptions invalidated |
| Team energy | Excited but under-resourced | Fatigued or disengaged |
| Time ratio | Building > fixing | Fixing > building |
| Requirements | Shifted in scope, not kind | Shifted in kind or domain |
| Output quality | Improving each cycle | Plateaued or declining |

## How To Frame It

```
Here is the original project scope: [paste seed statement]
Here is what the project has become: [describe current state]

Evaluate whether this requires restructuring. Give me a pros/cons
analysis for three options:
(a) Constrain back to original scope
(b) Expand with additional resources/time
(c) Split into two or more sub-projects

For each option, estimate: effort, risk, and time to value.
```

## Multi-Agent Pattern

- **Agent A:** Model the constrained path (what do we cut?)
- **Agent B:** Model the expanded path (what do we need?)

Compare timelines, risks, and resource requirements side by side.
The gardener decides — the agents provide the analysis.

## Completion Criteria

- [ ] Decision made: constrain, expand, or split
- [ ] If expanding: resource plan drafted
- [ ] If splitting: sub-project seeds written
- [ ] Updated seed statement saved to `.organic-dev/seeds/`
EOF

# ── Phase 6: COMPOST ──
cat > "${OD_DIR}/phases/06-compost.md" << 'EOF'
# Phase 6: COMPOST — Decompose the Old, Fertilize the New

## What To Do

End a growth cycle deliberately. Composting is not failure — it's the
productive act of breaking down a completed or stalled effort so its
nutrients feed the next thing you grow.

## When To Compost

- Core assumptions have been invalidated
- You're spending more time fixing than building
- The problem has been fundamentally reframed
- Team energy is depleted on this direction
- Output quality has plateaued despite iteration

## How To Frame It

### The composting prompt (this IS the bridge to the next cycle):
```
This project direction is not working. Before we stop, I need a
thorough extraction:

1. List every VALIDATED assumption (things we proved true)
2. List every INVALIDATED assumption (things we proved false)
3. Identify reusable components (code, designs, research, templates)
4. Capture key learnings (what would we do differently?)
5. Write a NEW seed brief for the next attempt that incorporates
   all of the above

The new seed should be stronger than the original because of what
we learned.
```

### Archive prompt:
```
Generate a post-mortem document for this project cycle covering:
- Original seed statement and goals
- What was attempted and what resulted
- Root causes of the decision to compost
- Validated learnings to carry forward
- Recommended approach for the next cycle
```

Save the post-mortem to `.organic-dev/compost/[project-name]-[date].md`

## Multi-Agent Pattern

- **Agent A:** Perform the post-mortem extraction
- **Agent B:** Research what has changed in the landscape since you started

The new seed benefits from both — internal learnings and external shifts.

## Completion Criteria

- [ ] Post-mortem saved to `.organic-dev/compost/`
- [ ] New seed brief generated (goes to `.organic-dev/seeds/`)
- [ ] Reusable components identified and preserved
- [ ] Team has read and acknowledged the learnings
- [ ] Ready to re-enter SEED phase with stronger foundation
EOF

# ── Phase 7: CULTIVATE ──
cat > "${OD_DIR}/phases/07-cultivate.md" << 'EOF'
# Phase 7: CULTIVATE — Tend to Several at Once

## What To Do

Portfolio awareness across your active project threads. This is NOT
enterprise portfolio management (use PMI/SAFe for that). This is the
gardener stepping back to see the whole garden.

Recommended cadence: weekly.

## How To Frame It

### Weekly cultivation prompt:
```
Here are my active projects with current status:

1. [Project A]: [2-3 line status, current phase, blockers]
2. [Project B]: [2-3 line status, current phase, blockers]
3. [Project C]: [2-3 line status, current phase, blockers]

Compare progress across all projects. For each:
- Flag risks and upcoming dependencies
- Identify where an insight or component from one project could
  benefit another (cross-pollination)
- Recommend where I should focus attention this week
- Flag any project that may need a Repot or Compost decision
```

### Cross-pollination prompt:
```
Project A just produced [insight/component/finding].
Could this be applied to any of my other active projects?
If so, how would it need to be adapted?
```

## Multi-Agent Pattern

Each project can have its own agent thread running its own core loop.
Cultivate is the phase where you, the gardener, step back and:
- Review outputs across all threads
- Move insights between threads
- Decide which projects need more attention
- Identify projects ready for Repot or Compost decisions

## Maintenance

Update `.organic-dev/cultivate-log.md` weekly with:
- Date
- Active project list and phases
- Key decisions made
- Cross-pollination actions taken
EOF

# ── Cultivate Log ──
cat > "${OD_DIR}/cultivate-log.md" << EOF
# Cultivation Log

Weekly portfolio awareness journal.

---

## $(date +%Y-%m-%d) — Initial Setup

### Active Projects
- (none yet — create your first seed)

### Notes
- Organic Development installed. Start with Phase 1: SEED.
- Run \`cat .organic-dev/phases/01-seed.md\` for guidance.

---
EOF

# ── Quick reference card ──
cat > "${OD_DIR}/QUICKSTART.md" << 'EOF'
# Organic Development — Quick Start

## Your First Project

### Step 1: Seed
```
cat .organic-dev/phases/01-seed.md    # Read the guidance
# Then use the prompt templates with your AI agent
# Save your seed to: .organic-dev/seeds/my-project.md
```

### Step 2: Nourish
```
cat .organic-dev/phases/02-nourish.md
# Compile context, feed it to your agent
# Save context brief to: .organic-dev/context/my-project-context.md
```

### Step 3: Grow
```
cat .organic-dev/phases/03-grow.md
# Generate with direction. Iterate. Chain outputs.
```

### Step 4: Prune
```
cat .organic-dev/phases/04-prune.md
# Critique. Score against seed. Cut ruthlessly.
```

### Then Evaluate:
```
cat .organic-dev/phases/05-repot.md     # Container too small?
cat .organic-dev/phases/06-compost.md   # Direction spent?
cat .organic-dev/phases/07-cultivate.md # Multiple threads?
```

## As an MCP Skill

Copy `.organic-dev/SKILL.md` to your MCP skills directory:
```
cp .organic-dev/SKILL.md /mnt/skills/user/organic-development/SKILL.md
```

Your AI agent will then automatically recognize Organic Development
triggers and route to the appropriate phase guidance.

## Key Commands

| Action | Command |
|---|---|
| Start a new seed | Create `.organic-dev/seeds/[name].md` |
| Load context | Create `.organic-dev/context/[name]-context.md` |
| Archive learnings | Save to `.organic-dev/compost/[name]-[date].md` |
| Weekly cultivate | Update `.organic-dev/cultivate-log.md` |
| Phase guidance | `cat .organic-dev/phases/0[1-7]-*.md` |

## Framework

```
SEED → NOURISH → GROW → PRUNE → (repeat)
                                    ↓
                    REPOT | COMPOST | CULTIVATE
```

License: CC BY 4.0 — Chamal Abeysekera
EOF

# ── .gitignore for organic-dev ──
cat > "${OD_DIR}/.gitignore" << 'EOF'
# Ignore personal context that shouldn't be committed
context/*.private.md
compost/*.private.md
EOF

# ── Done ──
echo ""
echo -e "${GREEN}${BOLD}  Installation complete.${NC}"
echo ""
echo -e "  ${BOLD}Created:${NC}"
echo -e "    ${GREEN}.organic-dev/${NC}"
echo -e "    ${DIM}├── SKILL.md              ${NC}${DIM}# MCP skill (copy to /mnt/skills/user/)${NC}"
echo -e "    ${DIM}├── QUICKSTART.md          ${NC}${DIM}# Quick reference${NC}"
echo -e "    ${DIM}├── cultivate-log.md       ${NC}${DIM}# Portfolio journal${NC}"
echo -e "    ${DIM}├── phases/${NC}"
echo -e "    ${DIM}│   ├── 01-seed.md         ${NC}${DIM}# Phase guidance + prompts${NC}"
echo -e "    ${DIM}│   ├── 02-nourish.md${NC}"
echo -e "    ${DIM}│   ├── 03-grow.md${NC}"
echo -e "    ${DIM}│   ├── 04-prune.md${NC}"
echo -e "    ${DIM}│   ├── 05-repot.md${NC}"
echo -e "    ${DIM}│   ├── 06-compost.md${NC}"
echo -e "    ${DIM}│   └── 07-cultivate.md${NC}"
echo -e "    ${DIM}├── seeds/                 ${NC}${DIM}# Your seed statements${NC}"
echo -e "    ${DIM}├── context/               ${NC}${DIM}# Living context docs${NC}"
echo -e "    ${DIM}└── compost/               ${NC}${DIM}# Archived learnings${NC}"
echo ""
echo -e "  ${BOLD}Next steps:${NC}"
echo -e "    ${GREEN}1.${NC} Read the quickstart:  ${BLUE}cat .organic-dev/QUICKSTART.md${NC}"
echo -e "    ${GREEN}2.${NC} Start your first seed: ${BLUE}cat .organic-dev/phases/01-seed.md${NC}"
echo -e "    ${GREEN}3.${NC} Install as MCP skill:  ${BLUE}cp .organic-dev/SKILL.md /mnt/skills/user/organic-development/SKILL.md${NC}"
echo ""
echo -e "  ${DIM}Organic Development v${VERSION} — Chamal Abeysekera — CC BY 4.0${NC}"
echo ""
