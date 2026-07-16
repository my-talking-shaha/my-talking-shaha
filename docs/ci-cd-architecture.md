# CI/CD Architecture

## Continuous integration

GitHub Actions runs CI for pull requests, pushes to `main`, and `v*` tags. It
verifies the Spring Boot backend with Maven, formats/analyzes/tests the Flutter
frontend, builds the web app and Android APK, and smoke-tests the Docker stack
through its Nginx router. CI also validates that the deployment Compose file is
image-only.

## Artifact publishing

After all required checks pass on `main`, backend and frontend Docker images
are published to GHCR with immutable commit-SHA tags. Android APKs are retained
as CI artifacts; a valid `vX.Y.Z` tag also publishes the signed APK to GitHub
Releases.

## Continuous deployment

A successful `main` CI run triggers the development deployment workflow. It
uploads only the runtime configuration over SSH, then deploys the matching GHCR
images into the inactive blue or green slot. Health, API, OpenAPI, and Swagger
checks run before and after Nginx switches traffic; failed post-switch checks
restore the previous slot automatically. Both slots share persistent PostgreSQL
storage, so Flyway migrations must remain backward-compatible. Server, database,
JWT, AI, and Android-signing credentials are supplied through GitHub Actions
secrets rather than committed files.
