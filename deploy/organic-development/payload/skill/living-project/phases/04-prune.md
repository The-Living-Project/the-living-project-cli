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
