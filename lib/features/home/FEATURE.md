# Dashboard (feature: home)

## Business
### User need / problem
Ops users need a single entry point after login to see overview and navigate to other areas.
### Users / personas
Operators using the Ops portal.
### Outcomes / value
- Clear landing after auth.
- Navigation to other features via shell/nav (when present).
### Non-goals
- Not a full dashboard with widgets/metrics yet; extend when needed.

## Functional
### Capabilities
- Renders the main post-login screen at `/`.
- Can be extended with nav items and child routes via the feature registry.
### Screens / routes
- Path: `/` (root); home is also rendered when no OAuth `code` is present.
### Inputs and outputs
- No explicit inputs; uses app config and auth state from shell.
### Constraints / limits
- Root route is shared with OAuth callback handling (presence of `?code=`); see callback feature.

## Technical / implementation
### Widgets / screens
- `HomeScreen` in `home_screen.dart`.
- Descriptor: `home_feature.dart` (name `home`, navLabel "Dashboard", navPath `/`).
### Routing (registry vs app_router)
- Registered in `lib/features/_registry.dart`. Root route `/` is defined in `app_router.dart` and shows `HomeScreen` when there is no `code` query param.
### Data and config dependencies
- App config and auth from core; no feature-specific backend yet.
### Failure modes & recovery
- If config or auth fails, core guard handles redirect to sign-in or error.

## Testing
### Unit
- Add tests under `test/features/home/` when logic is added.
### Integration (if any)
- E2E can target `/` after login.
