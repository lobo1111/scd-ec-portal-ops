# EchoCorner portal browser E2E (Playwright)

This suite lives in the **flut-template** (portal) repo. It validates portal login/logout and API health against the deployed `dev` environment. Portal login/render tests run when the app is deployed; API health can run anytime.

When portals existed, this suite validated login/logout flows for the three portals against the deployed `dev` environment by:

- creating a dedicated ephemeral Cognito user in the relevant user pool (admin APIs)
- completing interactive sign-in on the Cognito **Managed Login (v2)** pages
- asserting the portal reaches `/dashboard`
- logging out and asserting `/logout`
- deleting the test user (best-effort cleanup even on failures)

## Prerequisites
- Node.js installed
- AWS credentials for `dev` that can run Cognito admin APIs:
  - `cognito-idp:AdminCreateUser`
  - `cognito-idp:AdminSetUserPassword`
  - `cognito-idp:AdminDeleteUser`

## Install

```bash
cd tools/e2e
npm install
npm run install:browsers
```

## Run (recommended)

Provide the Cognito user pool IDs via env vars (do not commit secrets):

```bash
cd tools/e2e
export AWS_PROFILE=sandbox
export AWS_REGION=eu-central-1

export EC_E2E_ADMINS_USER_POOL_ID=eu-central-1_XXXXXXXXX
export EC_E2E_OPS_USER_POOL_ID=eu-central-1_XXXXXXXXX
export EC_E2E_USERS_USER_POOL_ID=eu-central-1_XXXXXXXXX

# Optional: override the default password used for ephemeral users
export EC_E2E_PASSWORD='E2ePassword123'

npm test
```

## Optional: local convenience from scd state

If you have a local `.deployer/.deploy-state.json` with `dev` outputs, the suite will also try to read the pool IDs from there when the env vars aren’t set. (That file is ignored by git.)

## Optional: verify Hosted UI SSL before E2E

If E2E fails with `ERR_SSL_VERSION_OR_CIPHER_MISMATCH` on the Cognito Hosted UI (e.g. after a custom domain recreation), verify TLS from the CLI before re-running tests:

```bash
openssl s_client -connect login.ops.dev.echocorner.kopacki.eu:443 -servername login.ops.dev.echocorner.kopacki.eu </dev/null
```

Confirm the handshake completes and the certificate is the expected one. If it fails, re-apply the relevant Cognito auth product and wait 15–30 minutes (up to 1 hour) for CloudFront/ACM propagation; see the product's `CAPABILITY.md` runbook (e.g. `ec_security_cognito_operators_portal_auth`).

