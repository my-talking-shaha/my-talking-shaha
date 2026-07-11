# GHCR Runtime Deployment Design

## Goal

Deploy the application to the development server from immutable public GHCR
images, without cloning, pulling, or building the source repository on that
server.

## Scope

- Publish separate backend and frontend images after CI has validated a push to
  `main`.
- Keep the existing blue-green rollout, health checks, and rollback behaviour.
- Treat the deployment server as a runtime host: it receives only deployment
  configuration, pulls images, and runs containers.
- Update the deployment runbook and add lightweight configuration validation.

This does not change the database topology, migration policy, public HTTP
ports, or deployment trigger.

## Image Publication

The CI workflow publishes two public packages after the backend, frontend, and
Docker smoke jobs succeed for a push to `main`:

- `ghcr.io/my-talking-shaha/my-talking-shaha-backend:<full-commit-sha>`
- `ghcr.io/my-talking-shaha/my-talking-shaha-frontend:<full-commit-sha>`

Each build uses GitHub's `GITHUB_TOKEN` with `packages: write`, Buildx cache,
and OCI labels that identify the source repository and commit. The immutable
full commit SHA is the deployment reference. A convenience moving tag may be
published, but the deploy workflow must never consume it.

The package administrator must make each newly created GHCR package public
once in GitHub Packages settings. Public GHCR images allow the server to pull
without a registry credential; no package token is stored on the server.

## Deployment Runtime

The deploy workflow remains gated on a successful `CI` workflow for `main`.
It checks out the exact successful commit solely on the GitHub runner to obtain
the deployment runtime files. It then copies these files to
`SERVER_APP_PATH/runtime` over SSH:

- the image-only blue-green Compose manifest;
- the router configuration;
- the blue-green deployment script.

The remote command runs the copied script from that runtime directory. It does
not execute any Git command and does not build images. `SERVER_APP_PATH/.deploy`
and Docker volumes remain outside the copied runtime directory so active-slot
state and persistent data survive each deployment.

The server bootstrap therefore requires Docker, Docker Compose, and an empty
application directory owned by the deploy user; Git is no longer required.

## Blue-Green Behaviour

The deployment Compose manifest removes `build:` directives and derives both
image references from `DEPLOY_IMAGE_TAG`, which is set to the successful
workflow run's full commit SHA. Before creating the inactive slot, the script
pulls the backend and frontend images for that exact tag. It then preserves the
existing sequence: start shared Postgres, start and verify the inactive slot,
switch the stable router, verify public traffic, and roll back to the previous
slot if post-switch checks fail.

Failure to pull either image stops the deploy before the inactive slot is
changed. A failed target verification continues to leave the active slot
serving traffic.

## Verification

CI validates the deployment manifest with `docker compose config` using
non-secret test environment values, and checks the deployment shell script with
`bash -n`. The existing Docker smoke test remains the functional verification
of application images and routing.

The deployment documentation records the required GHCR package visibility,
the revised one-time server setup, the runtime-only deployment sequence, and
the fact that the server has no source checkout.

## Security Constraints

- Image tags consumed by deploy are full commit SHAs, never `latest`.
- No secret is baked into an image or copied into the runtime files.
- Application secrets remain GitHub Actions secrets and are passed only as
  remote process environment variables.
- The public backend and frontend images contain only the already-public
  application binaries and static assets; package visibility does not expose
  server configuration or database data.
