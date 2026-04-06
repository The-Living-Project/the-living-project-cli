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
   Save it to `.living-project/seeds/[project-name].md`

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
- [ ] Seed statement saved to `.living-project/seeds/`
