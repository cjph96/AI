---
name: debugging
description: >
  Five-step triage for unexpected failures — reproduce, localize, reduce, fix, guard.
  Use when tests fail, builds break, behavior is wrong, or errors are unexplained.
  Do not use for feature implementation or planned refactors.
---

# Skill: Debugging

## Trigger

Use when:

- A test fails unexpectedly.
- A build or type-check breaks.
- A production report describes unexpected behavior.
- Behavior differs between environments.

Do not use for planned feature work.

## Process

### 1. Reproduce
- Recreate the failure in the smallest possible environment.
- Capture the **exact** input, expected output, and actual output.
- If you cannot reproduce, collect more data before guessing.

### 2. Localize
- Bisect by layer (unit → integration → e2e) or by commit (`git bisect`).
- Add focused logs at suspected boundaries. Remove them after.
- Read the code path top-down from the entry point the user hit.

### 3. Reduce
- Strip the failing case to its minimum: smallest input, smallest environment, smallest module.
- Convert the reduced case into a **failing automated test**. This is the regression test.

### 4. Fix
- Apply the minimum change that makes the regression test pass.
- Run the full suite. Investigate any new failures — do not silently accept them.
- Do not refactor unrelated code in the same change.

### 5. Guard
- Keep the regression test.
- Add a defensive assertion or contract check only if the same class of bug is likely to recur.
- Consider a static check (lint rule, type, schema) that would have caught it.

## Anti-patterns

- Changing random things until the error goes away ("shotgun debugging").
- Deleting the failing test.
- Wrapping the failing call in `try/catch` to suppress.
- Blaming flakiness without evidence.
- Fixing the symptom (retry, sleep, ignore) instead of the cause.

## Stop conditions

Stop and escalate to the user when:

- The root cause is in a dependency you do not control.
- The fix would change a public contract.
- The bug reveals a design flaw requiring a redesign larger than ~100 LOC.

## References

- Testing policy: `.github/instructions/testing.instructions.md`
- Code quality policy: `.github/instructions/code-quality.instructions.md`
