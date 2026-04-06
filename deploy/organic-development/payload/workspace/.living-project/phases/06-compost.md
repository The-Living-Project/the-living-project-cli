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

Save the post-mortem to `.living-project/compost/[project-name]-[date].md`

## Multi-Agent Pattern

- **Agent A:** Perform the post-mortem extraction
- **Agent B:** Research what has changed in the landscape since you started

The new seed benefits from both — internal learnings and external shifts.

## Completion Criteria

- [ ] Post-mortem saved to `.living-project/compost/`
- [ ] New seed brief generated (goes to `.living-project/seeds/`)
- [ ] Reusable components identified and preserved
- [ ] Team has read and acknowledged the learnings
- [ ] Ready to re-enter SEED phase with stronger foundation
