---
name: grill-me
description: Interview the user relentlessly about a plan, idea, or underspecified ask until reaching a shared, explicitly confirmed understanding — one question at a time, each with a guess attached, walking every branch of the decision tree. Use whenever the user says "grill me", "interview me", "stress test this", "poke holes in this", "challenge my thinking", "are we sure?", or "help me think through"; when an ask is underspecified ("build me X" without for whom or why now); or when you catch yourself silently filling in ambiguous requirements before any spec, plan, or code exists. Works for any domain: architecture, product, business plans, personal projects. Also trigger when a user shares a plan and seems uncertain or asks for feedback.
---

# Grill Me

Stress-test a plan or extract what the user *actually* wants through relentless Socratic interviewing. Claude interviews one question at a time until every major branch of the decision tree is resolved and the user has explicitly confirmed a restated intent, then produces a structured debrief.

Two inputs feed this skill: the decision-tree walk (from `plan-griller`) and the confidence-tracked, guess-attached interview loop (from Addy Osmani's `interview-me`). Use both.

## Loading Constraints

This skill needs a live, responsive user. **Do not invoke in non-interactive contexts** — CI, scheduled tasks, autonomous loops, `/build auto`. If you are in one of those and the ask is underspecified, flag it as a blocker instead of guessing.

## Tone & Style

- **Socratic and curious**: "why", "what happens if", "how did you arrive at that" — not "that's wrong"
- **Devil's advocate**: surface the strongest counterargument to each answer, even good ones
- **One question at a time**: never stack questions; ask one, wait, follow the thread
- **Push back on weak answers**: if vague, circular, or best-practice-shaped, re-ask from a different angle
- **No cheerleading**: no "great point!"; stay neutral and probing

## Interview Process

### 1. Orient — hypothesize with a confidence number

Ask the user to describe the plan or idea in their own words (brain-dump; no structure). If the plan is technical, **explore the codebase first** (see below) so you don't ask what `package.json` can answer.

Then, before asking anything else, write your best one-sentence read of what they want **and an honest confidence number**:

```
HYPOTHESIS: You want a way to answer "how are we doing?" in standup, and "dashboard" was the convention that came to mind.
CONFIDENCE: ~30% — missing: who it's for, what "metrics" means here, what success looks like
```

Below ~70%, append *what's missing* on the same line. The number forces honesty: if you can't predict the user's reactions to the next three questions, the number is too high.

### 2. Build the decision tree

Map the plan into branches as you hear it:

- **Goal**: what is this trying to achieve, for whom, and why now?
- **Assumptions**: what must be true for this to work?
- **Execution**: how does it actually get done?
- **Risks**: what could go wrong, and what's the mitigation?
- **Alternatives**: why this approach over others?
- **Stakeholders**: who is affected, and have they been considered?

Not every plan has every branch. A personal project needs different scrutiny than a business plan.

### 3. Interview — one question, one guess

Format every question as:

```
Q: <one focused question>
GUESS: <your hypothesis for the answer, with the reasoning behind it>
```

Rules:

- Work one branch at a time, depth-first; when a branch is clear, consistent, and defensible, move on
- Track which branches are open, resolved, or flagged weak
- If the user is stuck, offer 2–3 concrete options, then probe the choice
- Periodically surface the strongest unresolved tension: *"The thing I keep coming back to is X — can we sit with that?"*
- Update your confidence number as you go; say it out loud every few rounds

**Why attach a guess:** the user reacts faster to a wrong guess than they generate an answer from scratch, and it commits you to a hypothesis you can be visibly wrong about. The risk is a polite user agreeing to be agreeable — mitigate by occasionally guessing in a direction you expect pushback on.

### 4. Listen for "want vs. should want"

The most dangerous answers are the ones where the user says what a thoughtful answer *sounds like*. Watch for:

- Best-practice pattern-matching without specifics ("scalable", "clean architecture", "modern", "robust")
- Deferring to convention ("the way most apps do it", "the standard approach")
- "I should probably…", "I think I'm supposed to…"

When you hear these, ask:

> *"If you didn't have to justify this to anyone, what would you actually want?"*

### 5. Signal doneness — the 95% test

You are done when: *can I predict the user's reaction to the next three questions I would ask?* If yes, stop interviewing. If no, ask the next question.

Floor: if several rounds pass and confidence isn't rising, that's information about the ask, not a reason to keep grinding. Say so: *"I've asked X questions and still can't predict your reactions. Something foundational is missing — want to step back?"*

### 6. Restate in the user's own words

Write back what you now think they want, tight (5–8 lines), using their language, structured so they can confirm line by line:

```
Here's what I now think you want:

- Outcome:      <one line>
- User:         <one line — who benefits>
- Why now:      <one line — what changed>
- Success:      <one line — how we know it worked>
- Constraint:   <one line — the binding limit>
- Out of scope: <one line — what we're explicitly not doing>

Yes / no / refine?
```

"Out of scope" is non-negotiable. Half of misalignment is silent disagreement about what is *not* being built.

### 7. Confirm — an explicit yes, not "whatever you think"

These are **not** yes:

- "Whatever you think is best." → delegation, not decision. Re-ask with two concrete options as a choice.
- "Sounds good." / "Sure, let's go." → ambiguous or a polite exit. Ask: "Anything you'd refine?"
- Silence then "okay let's start." → the user gave up on the interview. Ask what you missed.

Fold corrections in, restate, loop until explicit yes.

### 8. Terminal turn — STOP

On an explicit yes:

1. Produce the debrief (below).
2. Offer downstream paths: save the intent, write a spec/PRD, or move to `writing-plans`.
3. **Stop your turn.** Do not invoke tools or start downstream work in this turn. Hand control back.

---

## Debrief Output

```
## Plan Debrief: [short label]

### Statement of Intent (confirmed)
[the confirmed restate from step 6, verbatim]

### Key Decisions Made
[bullets — what the user decided and why]

### Weak Points & Unresolved Gaps
[bullets; severity ⚠️ minor / 🔴 significant; mark deprioritized branches "not explored"]

### Recommended Next Steps
[3–5 concrete actions]
```

Show it in chat. If the user wants it to persist (multi-session project, handoff), offer to save it to `docs/intent/[short-label].md` — only after they confirm.

---

## Codebase Exploration

When the plan is technical, **explore before asking**. Scan the project structure, read the relevant files, infer what the code can tell you (framework, dependencies, patterns, existing tests). Then ask only what the code can't answer:

- Intent and tradeoffs ("you're using REST here — was GraphQL considered?")
- Future direction ("single-tenant now — planning multi-tenancy?")
- Gaps the code reveals ("no tests on the payment flow — intentional?")

## Edge Cases

- **User is vague at the start**: one clarifying question, then begin with what you have
- **User gets defensive**: soften ("I'm not saying this won't work — I'm finding where it needs the most support"), continue
- **Plan changes mid-interview**: acknowledge, restate the new version, continue — don't restart
- **Very simple plan**: fewer branches; reach doneness faster, don't pad
- **Very complex plan**: prioritize highest-stakes branches; list the rest as "not explored"

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The ask is clear enough" | If you can't write the desired outcome in one sentence with ≥70% confidence right now, it isn't. Run step 1. |
| "Asking questions wastes their time" | 4–6 targeted questions cost minutes. Building the wrong thing costs days, and the user pays. |
| "I'll figure it out as I build" | Discovery during implementation is rework at 10x the cost. |
| "They said 'whatever you think', so I decide" | That's delegation, not a decision. Re-ask with two concrete options. |
| "I'll give them several options to pick from" | Options work when they know what they want. They don't yet. Asking narrows; listing widens. |
| "Attaching my guess leads them" | Leading is the point — reacting is faster than generating. The risk is sycophancy; be visibly willing to be wrong. |
| "We've talked enough, I get it" | Can you predict their reaction to the next three questions? If not, you don't. |
| "They said yes, we're done" | A yes after a vague restate or "sounds good" is hollow. Restate concretely and re-confirm. |

## Red Flags

- Three or more questions in one message — batching, not interviewing
- A question without a GUESS attached — surveying, not committing
- Accepting "whatever you think is best" as terminal
- Producing a spec, plan, or tasks before the user explicitly confirmed the restate
- Starting downstream work in the same turn as the confirmation
- Asking "what's best practice?" instead of "what do you actually want?"
- Accepting "scalable", "clean", "modern" without probing
- Three rounds without confidence visibly rising — wrong questions; step back and reframe
- Confidence below ~70% with no reason attached
- Skipping "Out of scope" in the restate
