# OAuth callback (feature: callback)

## Business
### User need / problem
After signing in via Cognito Hosted UI, the user is redirected back to the app with auth tokens in the URL; the app must complete the code exchange and then show the main UI.
### Users / personas
Any user completing the Hosted UI sign-in flow (web).
### Outcomes / value
- Seamless handoff from Cognito back to the app; session established; user lands on home.
### Non-goals
- Does not handle sign-out redirects or custom schemes (mobile); those are auth/core.

## Functional
### Capabilities
- Handles the OAuth redirect (path with `?code=...&state=...`).
- Completes token exchange via Amplify and redirects to `/`.
### Screens / routes
- Path: `/` when `code` (and optionally `state`) query parameters are present; `app_router.dart` renders `CallbackScreen` in that case.
### Inputs and outputs
- Inputs: `AppConfig`, `AuthService` (injected by router).
- Output: redirect to `/` after session fetch.
### Constraints / limits
- Must use the same origin/callback URL configured in Cognito (e.g. `https://<origin>/` or `/callback` depending on app config).

## Technical / implementation
### Widgets / screens
- `CallbackScreen` in `callback_screen.dart`; shows a loading indicator while `fetchAuthSession()` runs, then `context.go('/')`.
### Routing (registry vs app_router)
- Not in the feature registry. Root route in `lib/core/app_router.dart` checks for `code` in query params and builds `CallbackScreen`; otherwise builds `HomeScreen`.
### Data and config dependencies
- `AuthService` (Amplify), `AppConfig` (Cognito client ID, redirect URLs).
### Failure modes & recovery
- If `fetchAuthSession()` fails, callback still redirects to `/`; auth guard may redirect back to sign-in.

## Testing
### Unit
- Can unit-test callback logic in isolation with mocked `AuthService`.
### Integration (if any)
- E2E: run through Hosted UI and assert redirect to `/` and session present.
