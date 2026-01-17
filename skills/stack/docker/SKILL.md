---
name: docker
domain: devops
description: >
  Docker containerization for development and deployment.
  Trigger: When creating Dockerfiles, when setting up docker-compose, when containerizing applications, when configuring development environments.
version: 1.0.0
tags: [docker, containers, devops, deployment, docker-compose, containerization]
metadata:
  version: "1.0"
  last_updated: "2026-01-17"
  category: stack
references:
  - name: Docker Documentation
    url: https://docs.docker.com/
    type: documentation
  - name: Docker GitHub
    url: https://github.com/docker
    type: repository
  - name: Docker Context7
    url: /websites/docker
    type: context7
  - name: Advanced Patterns
    url: ./references/advanced.md
    type: local
  - name: Best Practices
    url: ./references/best-practices.md
    type: local
  - name: Production Deployment
    url: ./references/production.md
    type: local
---

# Docker - Containerization Platform

**Package applications in containers for consistent deployment across environments**

---

## What This Skill Covers

- **Dockerfile** creation
- **docker-compose** for multi-container applications
- **Development workflows** with Docker
- **Production deployment** patterns

For advanced patterns, networking, volumes, and production optimizations, see [references/](./references/).

---

## Basic Dockerfile

### Node.js Application

```dockerfile
FROM node:20-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy application code
COPY . .

# Build application (if needed)
RUN npm run build

# Expose port
EXPOSE 3000

# Start application
CMD ["node", "dist/index.js"]
```

---

## Docker Compose

### Next.js + PostgreSQL

```yaml
# docker-compose.yml
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - '3000:3000'
    environment:
      - DATABASE_URL=postgresql://postgres:postgres@db:5432/myapp
      - NODE_ENV=production
    depends_on:
      - db
    restart: unless-stopped

  db:
    image: postgres:16-alpine
    ports:
      - '5432:5432'
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
      - POSTGRES_DB=myapp
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped

volumes:
  postgres_data:
```

---

## Common Commands

```bash
# Build image
docker build -t myapp:latest .

# Run container
docker run -p 3000:3000 myapp:latest

# Compose commands
docker-compose up -d        # Start in background
docker-compose down         # Stop services
docker-compose logs -f app  # View logs
docker-compose exec app sh  # Execute shell

# Container management
docker ps                   # List running containers
docker ps -a                # List all containers
docker stop <container-id>  # Stop container
docker rm <container-id>    # Remove container

# Image management
docker images               # List images
docker rmi <image-id>       # Remove image
docker system prune -a      # Clean up
```

---

## Quick Reference

```dockerfile
# Dockerfile syntax
FROM image:tag
WORKDIR /path
COPY source dest
RUN command
EXPOSE port
ENV KEY=value
CMD ["executable", "arg1"]
USER username
```

```yaml
# docker-compose.yml syntax
version: '3.8'
services:
  service-name:
    build: .
    image: image:tag
    ports:
      - 'host:container'
    environment:
      - KEY=value
    volumes:
      - source:destination
    depends_on:
      - other-service
    restart: unless-stopped
```

---

## Learn More

- **Advanced Patterns**: [references/advanced.md](./references/advanced.md) - Multi-stage builds, networking, volumes, full-stack compose
- **Best Practices**: [references/best-practices.md](./references/best-practices.md) - Security, optimization, .dockerignore
- **Production Deployment**: [references/production.md](./references/production.md) - Next.js production, environment variables

---

## External References

- [Docker Documentation](https://docs.docker.com/)
- [Docker GitHub](https://github.com/docker)

---

_Maintained by dsmj-ai-toolkit_
