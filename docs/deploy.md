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

4. Run the application once manually:

   ```bash
   docker compose -f docker/docker-compose.yml up -d --build backend frontend
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
2. Builds and starts the application Docker stack with Postgres.
3. Waits for `http://localhost:8080/actuator/health`.
4. Waits for `http://localhost/health`.
5. Verifies the generated OpenAPI docs at `http://localhost/v3/api-docs`.
6. Stops the smoke-test stack.
7. Connects to the server over SSH.
8. Goes to `SERVER_APP_PATH`.
9. Runs `git fetch --prune origin main`.
10. Updates the server checkout with `git pull --ff-only origin main`.
11. Rebuilds and restarts the backend and frontend services with their dependencies:

   ```bash
   docker compose -f docker/docker-compose.yml up -d --build --remove-orphans backend frontend
   ```

After deployment, the web app should be available at `http://SERVER_HOST`.

Swagger UI should be available at `http://SERVER_HOST/swagger-ui.html`.
The generated OpenAPI JSON should be available at `http://SERVER_HOST/v3/api-docs`.

## Database note

The current Docker Compose file sets `SPRING_JPA_HIBERNATE_DDL_AUTO=validate` and leaves schema changes to Flyway migrations. The deployment workflow smoke-tests this path with Postgres before connecting to the server.
