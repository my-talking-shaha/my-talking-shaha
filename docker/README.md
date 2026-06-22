# Docker Configuration for My Talking Shaha

## Structure

- `Dockerfile.backend` - Multi-stage build for Spring Boot backend
- `Dockerfile.frontend` - Multi-stage build for Flutter web frontend
- `docker-compose.yml` - Orchestration configuration
- `nginx.conf` - Nginx configuration for frontend and API routing

## Prerequisites

- Docker
- Docker Compose (v3.8 or higher)

## Building and Running

### Quick Start

```bash
docker-compose -f docker/docker-compose.yml up --build
```

The app will be available at [http://localhost](http://localhost)

### Details

Docker Compose will automatically build:

- **Backend**: Multi-stage Maven build for Spring Boot application
- **Frontend**: Clones Flutter SDK, installs dependencies, and builds the web app

### Running in Background

```bash
docker-compose -f docker/docker-compose.yml up -d --build
```

### Stopping Services

```bash
docker-compose -f docker/docker-compose.yml down
```

### Viewing Logs

```bash
# All services
docker-compose -f docker/docker-compose.yml logs -f

# Specific service
docker-compose -f docker/docker-compose.yml logs -f backend
docker-compose -f docker/docker-compose.yml logs -f frontend
```

## Accessing the Application

- **Frontend**: http://localhost
- **Backend API**: http://localhost:8080, bound to localhost only
- **Health Check**: http://localhost/health
- **Database**: postgres://localhost:5432/talking_shaha, bound to localhost only
