# Development Autodeploy

Autodeploy runs from GitHub Actions after every push to `main`.

This deployment profile is for the shared development server only. It uses a
blue-green Docker deployment and preserves the Postgres Docker volume on each
deploy, so Flyway applies new migrations to the existing database. Do not use
this flow for staging or production data without reviewing the runtime settings
and migration policy.

## Android APK releases

CI builds an Android release APK for every pull request, push to `main`, and
push of a tag starting with `v`. Builds from pull requests and `main` are kept
as GitHub Actions artifacts for 14 days. A tag in the `vX.Y.Z` format also
publishes the APK in GitHub Releases after all CI checks finish successfully.

Publishing an APK release does not deploy the backend or web application to the
development server. The development deploy workflow still runs only for pushes
to `main`.

### Create a release

1. Update `version` in `frontend/pubspec.yaml`. Keep the tag and version name
   aligned, and increase the numeric build number after `+` for every release
   that users may install over a previous APK. For example:

   ```yaml
   version: 1.2.3+4
   ```

2. Commit and push the release changes to `main`. Create an annotated tag on
   the exact commit to release, then push the tag:

   ```bash
   git switch main
   git pull --ff-only origin main
   git tag -a v1.2.3 -m "Release v1.2.3"
   git push origin v1.2.3
   ```

3. Open the matching `CI` run in GitHub Actions. It runs the backend and
   frontend checks, Docker smoke test, runtime validation, and Android APK
   build. If every required job succeeds, `Publish Android APK to GitHub
   Releases` creates the release and attaches `app-release.apk`.

4. Download the APK from the repository's **Releases** page. While CI is still
   running, the same file is also available in the
   `my-talking-shaha-release-apk-<commit-sha>` Actions artifact.

### Release behavior and troubleshooting

- Re-running a successful tag workflow replaces the APK asset in the existing
  GitHub Release; release notes are generated only when the release is first
  created.
- If CI fails, no release is published. Fix the failure, commit the fix, and
  create a new version tag instead of moving an existing release tag.
- The release job needs the repository setting **Settings → Actions → General
  → Workflow permissions → Read and write permissions**, or an organization
  policy that permits `contents: write`. Without it, GitHub cannot create the
  Release.

### Android signing

The CI job receives the following GitHub Actions secrets:

- `ANDROID_KEYSTORE_BASE64` - Base64-encoded contents of the release keystore.
- `ANDROID_KEYSTORE_PASSWORD` - keystore password.
- `ANDROID_KEY_ALIAS` - release key alias.
- `ANDROID_KEY_PASSWORD` - password for that key.

The keystore is decoded to a temporary file on the GitHub runner, used only for
the APK build, and removed before the artifact is uploaded. Its contents and
passwords are never written to the repository or workflow logs.

All four secrets are required for a tag release. If any are missing, the APK
build fails and the GitHub Release is not published. Pull requests without
access to repository secrets retain debug signing so their APK build can still
be validated; these artifacts are not published as GitHub Releases.

## One-time server setup

1. Install Docker and Docker Compose on the server. Git is not required.
2. Create an application-state directory owned by the SSH deploy user:

   ```bash
   install -d -m 0750 /opt/my-talking-shaha
   ```

3. Make sure the SSH user used by GitHub Actions can run Docker:

   ```bash
   sudo usermod -aG docker <ssh-user>
   ```

   Log out and log back in after changing groups.

GitHub Actions creates `$SERVER_APP_PATH/runtime/docker` on the first deploy
and copies only the deployment Compose manifest, router configuration, and
blue-green script there. The server never stores a source checkout.

## GHCR package setup

After the first successful CI run on `main`, GitHub Packages contains:

- `ghcr.io/my-talking-shaha/my-talking-shaha-backend`
- `ghcr.io/my-talking-shaha/my-talking-shaha-frontend`

An administrator must open each package's Settings in GitHub Packages and set
its visibility to **Public** once. Public GHCR container packages can be pulled
anonymously, so the deployment server does not need a package token or a
`docker login`. The images are tagged with the full commit SHA; deployment
always pulls that immutable tag rather than `latest`.

## GitHub secrets

Add these secrets in GitHub:

- `SERVER_HOST` - server IP address or hostname.
- `SERVER_USER` - SSH user.
- `SERVER_SSH_KEY` - private SSH key with access to the server.
- `SERVER_APP_PATH` - application-state directory on the server, for example
  `/opt/my-talking-shaha`; it is not a repository checkout.
- `SERVER_PORT` - optional SSH port. If omitted, port `22` is used.
- `JWT_SECRET` - production-grade JWT signing secret, at least 32 bytes, not
  the local development placeholder.
- `DB_USERNAME` - production database username, not the committed local default.
- `DB_PASSWORD` - production database password, not the committed local default.
- `TIMEWEB_AI_BASE_URL` - OpenAI-compatible Timeweb AI base URL, for example
  `https://agent.timeweb.cloud/api/v1/cloud-ai/agents/<agent_id>/v1`.
- `TIMEWEB_AI_TOKEN` - Timeweb AI API token for the agent or AI Gateway.

The backend fails during startup outside `local` or `test` profiles when
`JWT_SECRET`, `DB_USERNAME`, or `DB_PASSWORD` are missing or still set to known
development placeholders. The deploy workflow checks the same required GitHub
secrets before it starts the remote Docker stack.

## Deployment flow

On every push to `main`, the workflow:

1. Checks out the repository on the GitHub Actions runner.
2. Builds and starts the application Docker stack with Postgres and the router.
3. Waits for `http://localhost:8080/actuator/health`.
4. Waits for `http://localhost/health`.
5. Verifies the generated OpenAPI docs at `http://localhost/v3/api-docs`.
6. Verifies Swagger UI and an authenticated API smoke flow through `/api`.
7. Validates the image-only blue-green runtime manifest and deploy script.
8. Publishes backend and frontend images to public GHCR with the full commit SHA.
9. Connects to the server over SSH and uploads only the deployment runtime
   files to `SERVER_APP_PATH/runtime/docker`.
10. Reads `SERVER_APP_PATH/.deploy/active-slot` to find the active slot, either
    `blue` or `green`.
11. Selects the inactive slot as the target slot and pulls the exact GHCR
    backend and frontend images for that commit SHA.
12. Starts the target backend and frontend containers without binding either app container to public port `80`.
13. Verifies the target slot before switching traffic:
    backend health, frontend health, OpenAPI, Swagger UI, Swagger CSS, and an expected `/api/v1/users/me` unauthorized response through the target frontend nginx.
14. Switches traffic by updating `SERVER_APP_PATH/.deploy/nginx/active-upstreams.conf` and reloading the stable `talking-shaha-router` nginx container.
15. Verifies public traffic after the switch:
    backend health, frontend health, OpenAPI, Swagger UI, Swagger CSS, and `/api` routing.
16. If public post-switch verification fails, automatically reloads the router
    back to the previous slot and stops the failed target slot.

After deployment, the web app should be available at `http://SERVER_HOST`.

Swagger UI should be available at `http://SERVER_HOST/swagger-ui.html`.
The generated OpenAPI JSON should be available at `http://SERVER_HOST/v3/api-docs`.

## Blue-green runtime

The blue-green deployment uses the image-only
`SERVER_APP_PATH/runtime/docker/docker-compose.blue-green.yml` manifest.

- `backend-blue` and `frontend-blue` are the blue slot.
- `backend-green` and `frontend-green` are the green slot.
- `router` is the only service that binds public port `80`.
- app containers expose ports only on Docker networks.
- `postgres` is shared by both slots and keeps the `postgres-data` volume.
- `SERVER_APP_PATH/.deploy/active-slot` stores the active slot name.
- `SERVER_APP_PATH/.deploy/nginx/active-upstreams.conf` stores the nginx upstreams used by the router.

Deployment logs include `active_slot`, `target_slot`, `switch_result`, and
`rollback_status`. A healthy deploy ends with:

```text
[blue-green] switch_result=switched previous_slot=<old> active_slot=<new>
[blue-green] rollback_status=not_needed active_slot=<new>
```

If target verification fails before traffic switches, the workflow logs
`switch_result=not_attempted` and leaves the previous active slot running. If
post-switch verification fails, the workflow logs `switch_result=failed_post_switch`,
reloads the router to the previous slot, verifies public traffic again, and logs
`rollback_status=succeeded` when rollback is complete.

## Manual rollback

Automatic rollback runs only during the deploy job after a failed post-switch
verification. To roll back manually later, SSH to the server and switch the
router back to the inactive slot:

```bash
export BACKEND_IMAGE=ghcr.io/my-talking-shaha/my-talking-shaha-backend:<deployed-commit-sha>
export FRONTEND_IMAGE=ghcr.io/my-talking-shaha/my-talking-shaha-frontend:<deployed-commit-sha>
export DEPLOY_STATE_DIR=/opt/my-talking-shaha/.deploy
cd /opt/my-talking-shaha/runtime

previous_slot=blue # or green
mkdir -p "$DEPLOY_STATE_DIR/nginx"
cat > "$DEPLOY_STATE_DIR/nginx/active-upstreams.conf" <<EOF
upstream frontend_active {
    server frontend-${previous_slot}:80;
}

upstream backend_active {
    server backend-${previous_slot}:8080;
}
EOF
printf '%s\n' "$previous_slot" > "$DEPLOY_STATE_DIR/active-slot"
docker exec talking-shaha-router nginx -t
docker exec talking-shaha-router nginx -s reload

curl --fail http://localhost/health
curl --fail http://localhost/v3/api-docs >/dev/null
curl --fail http://localhost/swagger-ui.html >/dev/null
```

After confirming the rollback, optionally stop the bad inactive slot:

```bash
docker compose -f docker/docker-compose.blue-green.yml stop frontend-green backend-green
```

Replace `green` with `blue` if blue is the bad inactive slot.

## Database note

The current Docker Compose file sets `SPRING_JPA_HIBERNATE_DDL_AUTO=validate`
and leaves schema changes to Flyway migrations. The development deployment
preserves the `postgres-data` volume, so migrations must be safe to apply to the
existing database.

Never edit migrations that have already been applied to a shared database. Add
schema changes as new versions, for example `V03__add_maintenance_name.sql`.
Because the inactive backend may run Flyway while the previous active slot is
still serving traffic, schema changes must be backward-compatible with the
previous app version for at least one deployment.
