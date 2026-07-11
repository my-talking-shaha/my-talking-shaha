# Docker Configuration for My Talking Shaha

## Structure

- `Dockerfile.backend` - Multi-stage build for Spring Boot backend
- `Dockerfile.frontend` - Multi-stage build for Flutter web frontend
- `docker-compose.yml` - Orchestration configuration
- `nginx.conf` - Nginx configuration inside each frontend container
- `router.local.conf` - stable local routing layer for frontend, API, OpenAPI, and Swagger UI
- `docker-compose.blue-green.yml` - image-only blue-green runtime topology;
  GitHub Actions supplies public GHCR image references during deployment
- `router.blue-green.conf` - stable deployment router that switches between blue and green slots
- `deploy-blue-green.sh` - remote deployment script used by GitHub Actions

## Prerequisites

- Docker
- Docker Compose (v3.8 or higher is ok)
- Explicit local secrets. Copy `.env.example` to `.env` in the repository root
  and replace `JWT_SECRET`, `DB_USERNAME`, `DB_PASSWORD`, and `TIMEWEB_AI_TOKEN`.
  The example placeholders and local development values must not be reused for
  shared, staging, or production-like deployments.

## Building and Running

### Quick Start

```bash
docker compose --env-file .env -f docker/docker-compose.yml up --build
```

The app will be available at [http://localhost](http://localhost)

### Details

Docker Compose will automatically build:

- **Backend**: Multi-stage Maven build for Spring Boot application
- **Frontend**: Uses a prebuilt Flutter SDK image, installs dependencies, and builds the web app
- **Router**: Nginx container that owns public port `80` and proxies to the frontend/backend containers

The Dockerfiles use BuildKit cache mounts for downloaded dependencies:

- apt package caches for backend and frontend image layers;
- Maven dependencies in `/root/.m2` for the backend;
- Flutter/Dart packages in `/root/.pub-cache` for the frontend.

GitHub Actions smoke tests additionally use `docker/docker-compose.ci.yml` with the GitHub Actions BuildKit cache backend, so unchanged Docker layers can be reused across workflow runs.

The frontend build uses `ghcr.io/cirruslabs/flutter:stable` by default and retries transient network steps such as Flutter web precache and `flutter pub get`. Override the Flutter SDK image when needed:

```bash
docker compose --env-file .env -f docker/docker-compose.yml build --build-arg FLUTTER_IMAGE=ghcr.io/cirruslabs/flutter:stable frontend
```

Use `--no-cache` only when you intentionally want to redownload everything.

### Running in Background

```bash
docker compose --env-file .env -f docker/docker-compose.yml up -d --build
```

### Stopping Services

```bash
docker compose --env-file .env -f docker/docker-compose.yml down
```

### Viewing Logs

```bash
# All services
docker compose --env-file .env -f docker/docker-compose.yml logs -f

# Specific service
docker compose --env-file .env -f docker/docker-compose.yml logs -f backend
docker compose --env-file .env -f docker/docker-compose.yml logs -f frontend
```

## Accessing the Application

- **Frontend**: http://localhost
- **Backend API**: http://localhost:8080, bound to localhost only
- **Health Check**: http://localhost/health
- **Database**: postgres://localhost:5432/talking_shaha, bound to localhost only

In the blue-green deployment topology, only `talking-shaha-router` binds public
port `80`. The blue and green frontend/backend app containers expose ports only
inside Docker networks, and the router reloads nginx upstreams to switch traffic.
This runtime manifest does not build images or require a source checkout on the
server; it pulls the immutable public GHCR images published by CI.
