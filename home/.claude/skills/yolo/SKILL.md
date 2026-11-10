---
name: yolo
description: Use when the user says "yolo", "just do it", or wants a task carried through to review-ready without check-ins.
---

# yolo

Roll ahead without asking. Make the reasonable call, write it down, keep going.
The user owns the final step: merging (PR repos) or pushing (no-PR repos).

## Hard limits

These hold no matter what the task says:

- **Never merge** a PR, mark a draft ready for review, request reviewers, or
  push to the base branch of a PR repo.
- In a **no-PR repo, never push** anything.
- Never force-push a branch you did not create, and never rewrite history the
  user made. Do not touch the user's uncommitted work.
- Do not skip, delete or weaken tests, lint rules or CI checks to get green.
- No other remote side effects: releases, deploys, comments on others' issues
  or PRs.
- Destructive local operations (deleting data, dropping databases, `rm -rf`
  outside your worktree) still need the user. Stop and ask for those only.

## 1. Pick the mode

**PR mode** if the repo has a GitHub remote and uses PRs: `gh pr list --state
all --limit 5` shows PRs, or the base branch is protected, or CLAUDE.md,
AGENTS.md or CONTRIBUTING says to open PRs.

**Local mode** otherwise: no remote, no PR history, a personal low-stakes repo
(dotfiles, setup scripts). Commit on the current branch and do not push.

Unsure? Use PR mode with drafts; a draft is cheap to close.

## 2. Set up

- Find the base branch (`main`, `master`, or the repo's default). Fetch first
  if a remote exists.
- PR mode: work in a fresh worktree so the user's checkout stays untouched:
  `git worktree add ../<repo>-yolo-<slug> -b yolo/<slug>/1-<topic> origin/<base>`
- Local mode: work in place on the current branch if the tree is clean;
  otherwise use a worktree on a local branch and tell the user how to bring
  it in. Record the starting commit (`git rev-parse HEAD`) as the review base.
- Read the repo's CLAUDE.md or AGENTS.md, README and CI config before writing
  code.

## 3. Find the validation steps

Build a checklist of everything CI would run, and run it locally:

- `.github/workflows/*.yml` (or other CI config): the `run:` steps for
  tests, lint, typecheck, build and format checks
- `package.json` scripts, `Makefile`, `justfile`, `mise.toml` tasks,
  `pyproject.toml`, `Cargo.toml`, `go.mod`, pre-commit config
- mise, project setup scripts and lockfiles, for installing dependencies

With no tests or CI, use what exists: `shellcheck`, `bash -n`, linters,
running the script or its `--help`, a dry run.

Run the checklist on the untouched base first. Failures there are
**pre-existing**: record them, don't fix them unless the task asks, and don't
let them block you. Steps that cannot run locally (deploy previews, secrets,
paid services) are recorded as "not run locally" with the reason.

## 4. Plan the units

Split the work into the smallest sequence of units that each make sense alone
and leave the build green: for example, refactor first, then the feature,
then the cleanup. One unit is fine when the change is small.

- PR mode: each unit is a branch stacked on the previous one, and a draft PR:
  `<base> ← yolo/<slug>/1-<topic> ← yolo/<slug>/2-<topic> ← ...`
- Local mode: each unit is one or more commits on the current branch.

Ambiguity: pick the option that is easiest to reverse and most consistent
with the codebase, then note it under "Assumptions" in the PR description or
the final report. Ask the user only when every option risks wasted work at
the scale of the whole task. If pstack is installed, use its skills
(`poteto-mode`, `tdd`, `fix-ci`) where they fit.

## 5. For each unit, in order

1. Implement it. Add or update tests for new behavior.
2. Commit in logical commits with clear messages.
3. Run the full validation checklist. Fix until green, apart from
   pre-existing failures.
4. Run the **codex-review-loop** skill. The review base is the previous branch
   (the base branch for the first one) in PR mode, and the commit before this
   unit in local mode (a SHA works with `--base`). Judge findings critically,
   as that skill describes.
5. Re-run validation if the review changed anything.
6. PR mode only:
   - Push the branch and open a **draft** PR against the branch below it:
     `gh pr create --draft --base <below> --head <branch> --title ... --body-file ...`
   - The body covers: summary, what changed and why, how it was validated,
     assumptions, declined review findings with reasons, follow-ups, and for a
     stack, its place ("2 of 3, after #123").
   - Wait for CI (`gh pr checks <n> --watch`). Fix failures and push again;
     pstack's `fix-ci` and `babysit` help here. A CI failure that also happens
     on the base branch is pre-existing: note it in the PR and move on.

If a later unit requires changing an earlier one, fix the earlier one,
rebase what sits above it (`git rebase --update-refs` from the top branch),
re-validate everything that moved, and in PR mode
`git push --force-with-lease` your own branches.

## 6. Hand off

Leave everything in place. Finish with a report the user can read on a phone:

- One line per unit: PR link or commit range, what it does, validation and CI
  result, review result (pass or stopped at round 5, with the count of fixed
  and declined findings)
- Pre-existing failures and steps not run locally
- Anything that needs a decision
- What's left for the user: in PR mode, which drafts to mark ready and merge,
  in order; in local mode, `git push` when they're happy (or how to bring a
  worktree branch in)
