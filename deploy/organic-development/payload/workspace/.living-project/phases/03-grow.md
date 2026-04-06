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
