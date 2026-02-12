---
name: feature-workorders
description: Create and manage workorders using GitHub issues, splitting by portal feature, creating feature branches, and enforcing unit/integration/deploy gates. Use when the user mentions issues, workorders, feature requests, branches, PRs, or multi-feature changes.
---

# Feature workorders (GitHub issues) skill

## No direct commits to main (enforce always)
- **Never commit to `main`.** Never push to `main` with new work. All changes must go through a feature branch and a PR.
- Before making any commit: if current branch is `main`, **create a feature branch first** (`git checkout -b feat/<issue-number>-<slug>` or `fix/...`), then make all commits on that branch.
- If the user asks to "commit to main" or "push to main": refuse and instruct them to create a branch, commit there, open a PR, and merge after gates pass.
- When suggesting or running `git` commands: never run `git push origin main` with new commits; never stage and commit on `main` for feature work.

## Decision: which features are impacted?
Given a request:
1. List **candidate features** under `lib/features/` that are affected (screens, routes, widgets, data used by a feature).
2. If the change is cross-cutting (e.g. auth, config, core router), treat as **shared/core** and create one issue for that scope; do not attribute to a single feature.
3. If a feature doesn’t exist yet, classify as **new feature**.
4. Output: request → [(feature_name | shared/core) → scope].

## Issue splitting rules
- Create **one issue per feature** (or one for shared/core).
- If spanning multiple features, also create an optional **umbrella tracking issue** linking the per-feature issues.
- Each issue is written from the **feature perspective** (what changes in that feature, not a cross-cutting essay).

## GitHub issue creation (use temp files)
Use a temp file for the body to avoid formatting/quoting problems:

```bash
body_file="$(mktemp)"
$EDITOR "$body_file"
gh issue create --title "feat(<feature_name>): <short title>" --body-file "$body_file"
rm -f "$body_file"
```

### Per-feature issue body template
Use this structure:

```markdown
## Feature
- Name: <feature_name>
- Capability doc: lib/features/<feature_name>/FEATURE.md

## Goal (business outcome)
<what success looks like>

## Functional requirements
- ...

## Technical scope
- Code/files to touch:
  - lib/features/<feature_name>/...
  - (if applicable) lib/core/app_router.dart, lib/features/_registry.dart

## Acceptance criteria
- [ ] ...

## Test plan
- Unit:
  - Location: ...
  - Command: flutter test ...
- Integration (if any):
  - Location: ...
  - Command: ...

## Deploy/verify plan (dev)
- Run locally: tools/run_local.sh --env dev --variant ops
- Deploy to hosting (if UI change): tools/deploy_to_hosting.sh --env dev --variant ops
- Post-deploy verification: ...
```

## Branching workflow
- **Always work on a branch.** Never commit to `main`. Branch per issue: `feat/<issue-number>-<slug>` (or `fix/<issue-number>-<slug>`).
- Create the branch (from `main`) after issue creation; include the issue number in branch name, commits, and PR title.
- **Isolation rule (multi-feature work)**:
  - Multiple issues → **multiple branches** (one per issue).
  - Each branch/PR must include changes for **exactly one** feature (or shared/core).
  - Do **not** commit changes for feature B on feature A’s branch.
  - For shared work: use a **separate shared/core issue + branch/PR**, then consume from feature branches, or **cherry-pick** commits onto each feature branch.

## Definition of Done (per feature issue)
- `FEATURE.md` updated and matches implementation.
- Unit tests added/updated and run on every commit (`flutter test`).
- Integration tests added/updated and run as acceptance criteria when defined.
- If the change affects the deployed app: deploy to dev (e.g. `tools/deploy_to_hosting.sh --env dev --variant ops`) and verify.

## New feature add-on requirements
When introducing a new feature, additionally:
- Create `lib/features/<feature_name>/FEATURE.md`.
- Create a feature subagent: `.cursor/agents/feature-<feature_name>.md`.
- Put all feature-specific guidance in that subagent; keep skills generic.

## Commit / push checklist (before every commit or push)
- Current branch is **not** `main`. If it is, create and switch to a feature branch first.
- Unit tests pass (`flutter test`).
- Commit message references the issue or acceptance criteria where helpful.
- Push goes to the feature branch only (`git push -u origin feat/...`), never `git push origin main`.
