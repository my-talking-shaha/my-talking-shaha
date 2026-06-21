# Autodeploy

Autodeploy runs from GitHub Actions after every push to `main`.

## One-time server setup

1. Install Git, Docker, and Docker Compose on the server.
2. Clone this repository on the server:

   ```bash
   git clone https://github.com/my-talking-shaha/my-talking-shaha.git /opt/my-talking-shaha
   cd /opt/my-talking-shaha
   ```

3. Make sure the SSH user used by GitHub Actions can run Docker:

   ```bash
   sudo usermod -aG docker <ssh-user>
   ```

   Log out and log back in after changing groups.

4. Run the backend once manually:

   ```bash
   docker compose -f docker/docker-compose.yml up -d --build backend
   ```

## GitHub secrets

Add these secrets in GitHub:

- `SERVER_HOST` - server IP address or hostname.
- `SERVER_USER` - SSH user.
- `SERVER_SSH_KEY` - private SSH key with access to the server.
- `SERVER_APP_PATH` - repository path on the server, for example `/opt/my-talking-shaha`.
- `SERVER_PORT` - optional SSH port. If omitted, port `22` is used.

## Deployment flow

On every push to `main`, the workflow:

1. Checks out the repository on the GitHub Actions runner.
2. Builds and starts the backend Docker stack with Postgres.
3. Waits for `http://localhost:8080/actuator/health`.
4. Stops the smoke-test stack.
5. Connects to the server over SSH.
6. Goes to `SERVER_APP_PATH`.
7. Runs `git fetch --prune origin main`.
8. Updates the server checkout with `git pull --ff-only origin main`.
9. Rebuilds and restarts only the backend service and its dependencies:

   ```bash
   docker compose -f docker/docker-compose.yml up -d --build --remove-orphans backend
   ```

## Database note

The current Docker Compose file sets `SPRING_JPA_HIBERNATE_DDL_AUTO=validate` and leaves schema changes to Flyway migrations. The deployment workflow smoke-tests this path with Postgres before connecting to the server.
