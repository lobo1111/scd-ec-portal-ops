---
name: feature-capability-docs
description: Create and maintain per-feature FEATURE.md files describing portal features in business, functional, and technical terms. Use when adding features, changing feature behavior, or turning requests into feature workorders.
---

# Feature capability docs skill

## File location (required)
- `lib/features/<feature_name>/FEATURE.md`

## Structure (must keep this order)
Use this template.

```markdown
# <Display name> (feature: <feature_name>)

## Business
### User need / problem
### Users / personas
### Outcomes / value
### Non-goals

## Functional
### Capabilities
- ...
### Screens / routes
- Path(s): ...
### Inputs and outputs
### Constraints / limits

## Technical / implementation
### Widgets / screens
### Routing (registry vs app_router)
### Data and config dependencies
### Failure modes & recovery

## Testing
### Unit
### Integration (if any)
```

## Update rules
- Every change that touches a feature must:
  - update `FEATURE.md` first (or alongside code changes)
  - ensure the issue acceptance criteria map to sections in `FEATURE.md`
- Keep it **feature-specific**: avoid cross-feature narration; reference other features or core (auth, config) only when the feature depends on them.

## New feature add-on
When introducing a new feature, additionally:
- Create `lib/features/<feature_name>/FEATURE.md`.
- Create a feature subagent: `.cursor/agents/feature-<feature_name>.md`.
- Put feature-specific guidance (source of truth, guardrails, typical changes) in that subagent; do not create a per-feature skill (skills stay generic).
