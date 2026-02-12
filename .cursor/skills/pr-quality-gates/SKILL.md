---
name: pr-quality-gates
description: Enforce PR quality gates: no direct commits to main; implementation must match the request and feature capability docs; unit tests required; deploy to dev when UI changes. Use when reviewing PRs or preparing to merge.
---

# PR quality gates skill (portal)

## Main is protected
- **No direct commits to main.** All changes must land via a feature branch and a pull request. If a PR contains commits that were made directly on `main`, reject the workflow and require redoing the work on a branch.
- Recommend **branch protection** for `main`: require a pull request before merging, require status checks (e.g. CI running `flutter test`), disallow force-push and direct push to `main`. Configure in GitHub: Settings → Branches → Add rule for `main`.

## Review inputs (must gather)
- The originating issue(s) (one per feature, or shared/core)
- The impacted feature capability docs: `lib/features/<feature_name>/FEATURE.md`
- Diff / commits in the PR

## PR review checklist (must pass before merge)
- **Scope correctness**: implementation matches issue functional requirements and acceptance criteria.
- **Capability coverage**: `FEATURE.md` is updated and clearly describes the new/changed behavior.
- **No obvious mistakes**: correctness, edge cases, error handling, routing/auth contract.
- **Tests**:
  - Unit tests added/updated for new logic (`flutter test`).
  - Integration tests added/updated when defined for the feature.
- **Release gate (dev)**:
  - If the change affects the deployed app: deploy to dev (e.g. `tools/deploy_to_hosting.sh --env dev --variant ops`) and verify.
  - Run integration tests against dev as acceptance criteria when defined.

## Merge rule
- Do not merge until all gates above are satisfied and verified, and any discrepancies between the request and implementation are reconciled.
- **Only merge via PR.** Never merge by pushing directly to `main` or by committing on `main`. The only way code gets onto `main` is by merging a PR that has passed the checklist above.
