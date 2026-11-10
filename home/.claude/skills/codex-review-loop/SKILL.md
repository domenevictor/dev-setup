---
name: codex-review-loop
description: Get an independent code review from Codex (newest GPT Sol model, high effort) and iterate on it for up to 5 rounds, judging each finding critically instead of accepting it. Use when asked for a Codex review, a second-opinion review, or "review loop", and as the review gate inside the yolo skill.
---

# Codex review loop

Codex is a second reviewer, not an authority. The goal is to catch real defects,
not to reach zero comments. Reviewers, human or model, keep finding *something*
each round; chasing all of it produces churn, scope creep and new bugs. You
decide what gets fixed.

## Run a review

```sh
codex-review --base <base-branch>      # committed changes on this branch
codex-review --uncommitted             # working tree
codex-review --commit <sha>
codex-review --base <base> - < notes   # extra instructions on stdin
```

`codex-review` (in `~/.local/bin`) picks the newest `gpt-*-sol` model Codex
offers and runs at `high` effort. It prints the model on stderr; findings come
on stdout tagged `[P0]`–`[P3]`. A round takes from 30 seconds to several minutes.
Run it in the foreground with a 10-minute timeout. Run it from the repo root.

Prefer reviewing committed work (`--base`): commit before each round so the
review sees exactly what will ship.

## The loop (max 5 rounds)

Keep a ledger at `$(git rev-parse --git-dir)/codex-review-ledger.md` (inside
`.git`, never committed). For each finding record: round, priority, file:line,
one-line claim, verdict, reason.

Each round:

1. **Review.** Pass the ledger's declined and deferred items on stdin so Codex
   does not re-raise them, along with what the change is for:

   ```
   Intent: <one or two sentences on what this change is for>
   Report only issues a careful senior engineer would block a merge on:
   incorrect behavior, crashes, data loss, security, races, broken API or
   migration contracts, missing handling of inputs that actually occur.
   Do not report style, naming, comments, or speculative hardening.
   Already considered and declined (do not re-raise unless you have new evidence):
   - <file:line> <claim> — <reason>
   ```

2. **Verify each finding yourself** before acting. Read the code. For a
   behavioral claim, reproduce it with a test or a quick script when you can.
   Codex often reviews the diff without the surrounding code and gets the
   context wrong.

3. **Judge each finding** with one verdict:
   - **fix**: real, reachable, and matters to users, data, security, or the
     change's stated goal. Fix it with the smallest correct change, and add a
     regression test where the repo has tests.
   - **decline**: wrong, unreachable in practice, a style preference, or
     speculative "what if" hardening. Also decline anything that contradicts
     the requirements or the codebase's conventions. Write the reason.
   - **defer**: real but outside this change's scope, for example a
     pre-existing bug the diff did not touch. Note it for the final report and
     do not fix it here.

   Priority tags are Codex's opinion. A `[P1]` can be wrong; a `[P3]` can be
   real. Judge the claim, not the tag.

4. **Validate** after fixing: run the project's tests, lint, typecheck or build
   (whatever exists) and commit the fixes.

5. **Decide whether to go again:**
   - Stop with a **pass** when a round produces no `fix` verdicts.
   - Stop with a pass when the only new findings are about code your previous
     round's fixes added and they are minor. That is the nit spiral; note it
     and stop.
   - Stop after round 5 regardless. Report anything unresolved.
   - Otherwise go to the next round.

Never weaken a test, suppress a lint rule or add a broad `try/except` just to
satisfy a finding. If a finding needs a design change, defer it and say so.

## Report

End with a short summary:

- Result: **pass** (no open fixes) or **stopped at round 5** / **blocked** (with why)
- Rounds run, and the model and effort used
- Fixed: one line each, with the commit
- Declined: one line each, with the reason, so the user can overrule you
- Deferred: one line each

Keep it tight. The user reads this on a phone.
