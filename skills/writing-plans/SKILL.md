---
name: writing-plans
description: Write an implementation plan from a spec or requirements — ordered, dependency-aware, vertically sliced tasks with real code in every step. Use when you have a spec, PRD, or clear requirements for a multi-step task and need to break it into implementable tasks, when a task feels too large to start, when parallel work is possible, or before touching code on any change spanning more than one file.
---

# Writing Plans

## Overview

Write comprehensive implementation plans assuming the engineer has zero context for our codebase and questionable taste. Document everything they need to know: which files to touch for each task, code, testing, docs they might need to check, how to test it. Give them the whole plan as bite-sized tasks. DRY. YAGNI. TDD. Frequent commits.

Assume they are a skilled developer, but know almost nothing about our toolset or problem domain. Assume they don't know good test design very well.

**Announce at start:** "I'm using the writing-plans skill to create the implementation plan."

**Context:** If working in an isolated worktree, it should have been created via the `using-git-worktrees` skill at execution time.

**Save plans to:** `docs/plans/YYYY-MM-DD-<feature-name>.md`
- (User preferences for plan location override this default)

## Scope Check

If the spec covers multiple independent subsystems, it should have been broken into sub-project specs during brainstorming. If it wasn't, suggest breaking this into separate plans — one per subsystem. Each plan should produce working, testable software on its own.

## Dependency Graph and Vertical Slices

Before writing tasks, map what depends on what, bottom-up:

```
Database schema / migration
    ├── Types & validation
    │     ├── API route / server action
    │     │     └── UI component
    │     └── Background job / n8n handoff
    └── Seed data
```

Then **slice vertically**, not horizontally. Don't plan "all the schema, then all the API, then all the UI" — plan one complete, testable feature path at a time:

```
Bad:   Task 1 entire schema · Task 2 all endpoints · Task 3 all UI · Task 4 wire it up
Good:  Task 1 user can create an account (schema + action + UI)
       Task 2 user can log in · Task 3 user can create a task · Task 4 user can view task list
```

Each slice leaves the system working. Order so that dependencies are satisfied, high-risk tasks come early (fail fast), and a checkpoint follows every 2–3 tasks.

**Declare dependencies explicitly on each task.** Executors (subagents, `/build auto`, a second session) use them to run independent tasks in parallel and sequence the rest:

- **Safe to parallelize:** independent feature slices, tests for already-built features, docs
- **Must be sequential:** migrations, shared-state changes, dependency chains
- **Needs coordination:** tasks sharing an API contract — define the contract in an earlier task, then parallelize

## File Structure

Before defining tasks, map out which files will be created or modified and what each one is responsible for. This is where decomposition decisions get locked in.

- Design units with clear boundaries and well-defined interfaces. Each file should have one clear responsibility.
- You reason best about code you can hold in context at once, and your edits are more reliable when files are focused. Prefer smaller, focused files over large ones that do too much.
- Files that change together should live together. Split by responsibility, not by technical layer.
- In existing codebases, follow established patterns. If the codebase uses large files, don't unilaterally restructure - but if a file you're modifying has grown unwieldy, including a split in the plan is reasonable.

This structure informs the task decomposition. Each task should produce self-contained changes that make sense independently.

## Task Right-Sizing

A task is the smallest unit that carries its own test cycle and is worth a
fresh reviewer's gate. When drawing task boundaries: fold setup,
configuration, scaffolding, and documentation steps into the task whose
deliverable needs them; split only where a reviewer could meaningfully
reject one task while approving its neighbor. Each task ends with an
independently testable deliverable.

## Bite-Sized Task Granularity

**Each step is one action (2-5 minutes):**
- "Write the failing test" - step
- "Run it to make sure it fails" - step
- "Implement the minimal code to make the test pass" - step
- "Run the tests and make sure they pass" - step
- "Commit" - step

## Plan Document Header

**Every plan MUST start with this header:**

```markdown
# [Feature Name] Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use subagent-driven-development (recommended) or executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies/libraries]

## Global Constraints

[The spec's project-wide requirements — version floors, dependency limits,
naming and copy rules, platform requirements — one line each, with exact
values copied verbatim from the spec. Every task's requirements implicitly
include this section.]

---
```

## Task Structure

````markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

**Interfaces:**
- Consumes: [what this task uses from earlier tasks — exact signatures]
- Produces: [what later tasks rely on — exact function names, parameter
  and return types. A task's implementer sees only their own task; this
  block is how they learn the names and types neighboring tasks use.]

**Depends on:** [Task numbers that must be complete first, or "none" — explicit so independent tasks can run in parallel]

- [ ] **Step 1: Write the failing test**

```python
def test_specific_behavior():
    result = function(input)
    assert result == expected
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/path/test.py::test_name -v`
Expected: FAIL with "function not defined"

- [ ] **Step 3: Write minimal implementation**

```python
def function(input):
    return expected
```

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/path/test.py::test_name -v`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add tests/path/test.py src/path/file.py
git commit -m "feat: add specific feature"
```
````

## Checkpoints

After every 2–3 tasks, insert a checkpoint block. It is a human gate, not a formality:

```markdown
### Checkpoint: After Tasks 1–3
- [ ] Full test suite passes
- [ ] Build succeeds
- [ ] Core user flow works end-to-end (describe the exact flow)
- [ ] Review with human before proceeding
```

## No Placeholders

Every step must contain the actual content an engineer needs. These are **plan failures** — never write them:
- "TBD", "TODO", "implement later", "fill in details"
- "Add appropriate error handling" / "add validation" / "handle edge cases"
- "Write tests for the above" (without actual test code)
- "Similar to Task N" (repeat the code — the engineer may be reading tasks out of order)
- Steps that describe what to do without showing how (code blocks required for code steps)
- References to types, functions, or methods not defined in any task

## Self-Review

After writing the complete plan, look at the spec with fresh eyes and check the plan against it. This is a checklist you run yourself — not a subagent dispatch.

**1. Spec coverage:** Skim each section/requirement in the spec. Can you point to a task that implements it? List any gaps.

**2. Placeholder scan:** Search your plan for red flags — any of the patterns from the "No Placeholders" section above. Fix them.

**3. Dependency sanity:** Does every task's "Depends on" point only at earlier tasks? Could any two tasks with no shared dependency actually run in parallel — and if so, is that stated?

**4. Type consistency:** Do the types, method signatures, and property names you used in later tasks match what you defined in earlier tasks? A function called `clearLayers()` in Task 3 but `clearFullLayers()` in Task 7 is a bug.

If you find issues, fix them inline. No need to re-review — just fix and move on. If you find a spec requirement with no task, add the task.

## Execution Handoff

After saving the plan, offer execution choice:

**"Plan complete and saved to `docs/plans/<filename>.md`. Two execution options:**

**1. Subagent-Driven (recommended)** - I dispatch a fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints

**Which approach?"**

**If Subagent-Driven chosen:**
- **REQUIRED SUB-SKILL:** Use subagent-driven-development
- Fresh subagent per task + two-stage review

**If Inline Execution chosen:**
- **REQUIRED SUB-SKILL:** Use executing-plans
- Batch execution with checkpoints for review

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I'll figure it out as I go" | That's how you get a tangled mess and rework. Ten minutes of planning saves hours. |
| "The tasks are obvious" | Write them anyway. Explicit tasks surface hidden dependencies and forgotten edge cases. |
| "Planning is overhead" | Planning *is* the task. Implementation without a plan is typing. |
| "I can hold it all in my head" | Context windows are finite. Written plans survive session boundaries and compaction. |
| "'Add validation' is specific enough" | It isn't. If the step has no code block, the implementer will invent one — probably wrong. |
| "The old plan is stale, I'll replace it" | Unchecked tasks may be mid-build in another session. Overwriting destroys state that exists nowhere else. Ask. |

## Red Flags

- Starting implementation without a saved plan
- A task that says "implement the feature" with no acceptance test
- Any placeholder from the No Placeholders list
- Horizontal slicing (all schema, then all API, then all UI)
- No "Depends on" line on a task
- No checkpoint in a plan of more than three tasks
- Overwriting a plan that still has unchecked tasks for other work, without asking
- Types or function names that differ between tasks
