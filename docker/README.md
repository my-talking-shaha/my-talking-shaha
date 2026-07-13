# Docker Configuration for My Talking Shaha

## Structure

- `Dockerfile.backend` - Multi-stage build for Spring Boot backend
- `Dockerfile.frontend` - Multi-stage build for Flutter web frontend
- `docker-compose.yml` - Orchestration configuration
- `prometheus.yml` - local Prometheus scrape configuration for backend metrics
- `grafana/provisioning/` - local Grafana datasource and dashboard provisioning
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
- **Prometheus**: Scrapes backend metrics from `/actuator/prometheus` for local/internal monitoring
- **Grafana**: Opens a preconfigured local dashboard backed by Prometheus

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
- **Prometheus**: http://localhost:9090, bound to localhost only
- **Grafana**: http://localhost:3000, bound to localhost only. The overview
  dashboard is also available directly at
  http://localhost:3000/d/talking-shaha-overview/my-talking-shaha-overview?orgId=1.
  Default local credentials are `admin` / `admin` unless `GRAFANA_ADMIN_USER`
  and `GRAFANA_ADMIN_PASSWORD` are set in `.env`.

## Metrics

The backend exposes Prometheus metrics at `/actuator/prometheus`. The local
Prometheus container scrapes that endpoint through the Docker network, and
Grafana provisions the `My Talking Shaha Overview` dashboard automatically.

The dashboard includes basic technical metrics from Spring Boot and Micrometer:

- backend scrape health;
- API request rate by method, path, and status;
- API max latency.

It also includes a small set of business-oriented metrics that are available
from current backend flows without adding a separate event pipeline:

- total registered users and vehicles;
- registered users over time;
- successful registrations;
- created vehicles over time;
- timeline events by type over time;
- created parts;
- user chat messages over time;
- analytics endpoint views over time.

The dashboard excludes the local `demo@talkingshaha.local` seed user from the
user and vehicle totals. Action charts are rounded to whole events because these
metrics represent discrete backend actions.

In the blue-green deployment topology, only `talking-shaha-router` binds public
port `80`. The blue and green frontend/backend app containers expose ports only
inside Docker networks, and the router reloads nginx upstreams to switch traffic.
This runtime manifest does not build images or require a source checkout on the
server; it pulls the immutable public GHCR images published by CI.

Prometheus and Grafana are not included in the blue-green deployment manifest.
They are internal monitoring tools, not end-user application components. If the
development VM needs shared monitoring, run a separate VM-side monitoring stack
and keep Grafana/Prometheus private.