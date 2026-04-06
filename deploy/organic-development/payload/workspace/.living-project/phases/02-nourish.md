# Phase 2: NOURISH — Context Is Fertilizer

## What To Do

This is the phase most teams skip, and it's the single biggest determinant
of output quality. Load your AI workspace with EVERY piece of relevant context.

1. **Gather inputs:** Prior art, stakeholder notes, technical constraints,
   data, competitive analysis, internal docs, institutional knowledge.

2. **Compile a context brief** — a structured document the AI can reference.
   Save to `.living-project/context/[project-name]-context.md`

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
- [ ] Context brief saved to `.living-project/context/`
- [ ] AI has confirmed no major contradictions in source material
- [ ] You've addressed the AI's "missing context" questions
- [ ] Your prompt could NOT apply to any random company — it's specific
- [ ] A colleague could read the context brief and understand the project
