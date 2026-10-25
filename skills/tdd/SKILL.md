---
name: tdd
description: Test-driven development — the red → green loop, done so the tests are worth keeping. Use when the user wants to build features or fix bugs test-first, mentions "red-green-refactor" or "TDD", wants integration tests, or asks to add tests to a function, fix a bug in it, or change its behavior — even when the code is pasted inline and tests aren't mentioned. Use on every bug report (reproduce with a failing test before touching the fix).
---

# Test-Driven Development

TDD is the red → green loop. This skill is the reference that makes that loop produce tests worth keeping: what a good test is, where tests go, the anti-patterns, and the rules of the loop. Every section applies on every cycle — consult them before and during the loop, not after.

When exploring the codebase, read `CONTEXT.md` (if it exists) so test names and interface vocabulary match the project's domain language, and respect ADRs in the area you're touching.

## Discover the stack first

The loop is universal; the commands are not. Before the first test, find out how *this* repo tests and use its commands for every RED, GREEN, and verification step:

- **Build system** — `package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, a `Makefile`
- **Checked-in wrappers** — prefer `make test`, a repo script, or `./gradlew` over globally installed tools
- **Test framework + config** — and how it runs *one focused test* vs the full suite (`vitest run path/to/file`, `npx playwright test -g "name"`)
- **Conventions** — where tests live, file naming, patterns neighboring tests follow
- **Documented commands** — README, CONTRIBUTING, and CI workflows show what actually gates merges

Run the focused-test command during the loop and the full-suite command before claiming done. Never assume `npm test`.

## What a good test is

Tests verify behavior through public interfaces, not implementation details. Code can change entirely; tests shouldn't. A good test reads like a specification — "user can checkout with valid cart" tells you exactly what capability exists — and survives refactors because it doesn't care about internal structure.

See [tests.md](tests.md) for examples and [mocking.md](mocking.md) for mocking guidelines.

## Seams — where tests go

A **seam** is the public boundary you test at: the interface where you observe behavior without reaching inside. Tests live at seams, never against internals.

**Test only at pre-agreed seams.** Before writing any test, write down the seams under test and confirm them with the user. No test is written at an unconfirmed seam. You can't test everything — agreeing the seams up front is how testing effort lands on the critical paths and complex logic instead of every edge case.

Ask: "What's the public interface, and which seams should we test?"

## The Prove-It pattern (bug fixes)

When a bug is reported, **do not start by trying to fix it.** Start by writing a test at the seam that reproduces it.

```
Bug report → write test that demonstrates the bug → test FAILS (bug confirmed)
           → implement fix → test PASSES (fix proven) → full suite (no regressions)
```

```typescript
// Bug: "Completing a task doesn't set completedAt"
it('sets completedAt when a task is completed', async () => {
  const task = await taskService.createTask({ title: 'Test' });
  const completed = await taskService.completeTask(task.id);
  expect(completed.status).toBe('completed');
  expect(completed.completedAt).toBeInstanceOf(Date); // fails → bug confirmed
});
```

A fix without a reproducing test is a guess that happened to compile. The test is the proof, and it's the regression guard afterwards.

## Anti-patterns

- **Implementation-coupled** — mocks internal collaborators, tests private methods, or verifies through a side channel (querying the database instead of using the interface). The tell: the test breaks when you refactor but behavior hasn't changed.
- **Tautological** — the assertion recomputes the expected value the way the code does (`expect(add(a, b)).toBe(a + b)`, a snapshot derived by hand the same way, a constant asserted equal to itself), so it passes by construction and can never disagree with the code. Expected values must come from an independent source of truth — a known-good literal, a worked example, the spec.
- **Horizontal slicing** — writing all tests first, then all implementation. Bulk tests verify _imagined_ behavior: you test the _shape_ of things rather than user-facing behavior, the tests go insensitive to real changes, and you commit to test structure before understanding the implementation. Work in **vertical slices** instead — one test → one implementation → repeat, each test a **tracer bullet** that responds to what the last cycle taught you.

## Rules of the loop

- **Red before green.** Write the failing test first, *watch it fail for the right reason*, then only enough code to pass it. Don't anticipate future tests or add speculative features.
- **One slice at a time.** One seam, one test, one minimal implementation per cycle.
- **Refactoring is not part of the loop.** It belongs to the review stage (see the `code-review` skill), not the red → green implementation cycle.
- **Full suite before done.** A green focused test is not done; the suite is. Run it once after the last change — not again "to be sure" when nothing changed.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I'll write tests after the code works" | You won't. Tests written after test the implementation you already chose, not the behavior. |
| "This is too simple to test" | Simple code gets complicated. The test documents the expected behavior for whoever changes it next. |
| "I tested it manually" | Manual testing doesn't persist. Tomorrow's change breaks it with no way to know. |
| "It's just a prototype" | Prototypes become production. Tests from day one prevent the test-debt crisis. |
| "I know what's wrong, let me just fix the bug" | Then the reproducing test will take two minutes. Write it. If it doesn't fail, you didn't know what was wrong. |
| "I'll test everything to be thorough" | Untargeted tests at unagreed seams are noise that rots. Agree the seams; test the critical paths. |
| "Let me run the suite again just to be sure" | After a clean run, repeating the same command adds nothing unless code changed. |

## Red Flags

- Implementation code written before a failing test exists
- A test that passes on first run (it's not testing the new behavior, or it's tautological)
- A test written at a seam the user never agreed to
- A bug "fixed" with no test that reproduced it
- Tests that assert on mocks of internal collaborators
- A batch of tests written before any implementation (horizontal slicing)
- Refactoring inside the red → green cycle
- Claiming done without the full suite run
