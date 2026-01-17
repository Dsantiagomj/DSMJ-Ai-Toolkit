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

## When to Use This Skill

**Use this skill when**:
- Containerizing applications for consistent deployment
- Setting up local development environments
- Creating multi-service applications with docker-compose
- Building production-ready container images
- Deploying to container orchestration platforms (Kubernetes, ECS, etc.)
- Ensuring environment parity between development and production

**Don't use this skill when**:
- Running simple static sites (use static hosting instead)
- System resources are limited (containers add overhead)
- Deploying to serverless platforms that manage containers for you (Vercel, Netlify)
- Working with legacy systems that can't be containerized

---

## Critical Patterns

### Pattern 1: Multi-Stage Builds for Smaller Images

**When**: Building production containers for any application

**Good**:
```dockerfile
# ✅ Multi-stage build - smaller final image
FROM node:20-alpine AS builder

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci

# Build application
COPY . .
RUN npm run build

# Production stage - only runtime files
FROM node:20-alpine AS production

WORKDIR /app

# Copy only production dependencies
COPY package*.json ./
RUN npm ci --only=production

# Copy built application from builder
COPY --from=builder /app/dist ./dist

# Run as non-root user
USER node

EXPOSE 3000

CMD ["node", "dist/index.js"]
```

**Bad**:
```dockerfile
# ❌ Single stage - includes build tools in final image
FROM node:20

WORKDIR /app

# ❌ Includes dev dependencies in production
COPY package*.json ./
RUN npm install

COPY . .
RUN npm run build

# ❌ Running as root
EXPOSE 3000

CMD ["node", "dist/index.js"]
# Final image: ~1GB with dev dependencies and build tools
```

**Why**: Multi-stage builds reduce final image size by 60-90%, exclude build tools from production, improve security by minimizing attack surface, and speed up deployment.

---

### Pattern 2: Layer Caching Optimization

**When**: Writing Dockerfiles for faster builds

**Good**:
```dockerfile
# ✅ Copy package files first (changes infrequently)
FROM node:20-alpine

WORKDIR /app

# Copy dependency files (layer cached until these change)
COPY package*.json ./
RUN npm ci

# Copy source code (changes frequently, separate layer)
COPY . .

RUN npm run build

CMD ["npm", "start"]
```

**Bad**:
```dockerfile
# ❌ Copy everything first - cache invalidated on any file change
FROM node:20-alpine

WORKDIR /app

# ❌ Any file change invalidates all subsequent layers
COPY . .
RUN npm ci
RUN npm run build

CMD ["npm", "start"]
```

**Why**: Proper layer ordering uses Docker's cache effectively. Dependencies change less frequently than source code, so installing them first means rebuilds only reinstall dependencies when package.json changes.

---

### Pattern 3: .dockerignore for Lean Builds

**When**: Every Docker project

**Good**:
```dockerfile
# Dockerfile
FROM node:20-alpine
WORKDIR /app
COPY . .
RUN npm ci
```

```
# ✅ .dockerignore - exclude unnecessary files
node_modules
npm-debug.log
.git
.gitignore
README.md
.env
.env.local
dist
build
coverage
.next
.vscode
.idea
*.md
Dockerfile
docker-compose*.yml
```

**Bad**:
```dockerfile
# ❌ No .dockerignore file
FROM node:20-alpine
WORKDIR /app
# Copies everything including:
# - node_modules (will be reinstalled anyway)
# - .git history (adds MBs to context)
# - IDE configs
# - Build artifacts
COPY . .
RUN npm ci
```

**Why**: .dockerignore reduces build context size (faster uploads to Docker daemon), prevents accidentally copying sensitive files (.env), excludes unnecessary files from final image, and speeds up COPY operations.

---

### Pattern 4: Health Checks for Container Monitoring

```dockerfile
# ✅ Good: Health check built into image
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD node healthcheck.js

# ❌ Bad: No health check
```

**Why**: Health checks enable automatic restart and prevent routing traffic to failing instances. For complete health check patterns, see [references/production.md](./references/production.md).

---

## Anti-Patterns

### ❌ Anti-Pattern 1: Running as Root User

**Don't do this**:
```dockerfile
# ❌ Running application as root
FROM node:20-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .

EXPOSE 3000

# ❌ No USER directive - runs as root by default
CMD ["node", "index.js"]
```

**Why it's bad**: Security risk if container is compromised, attackers get root access, violates principle of least privilege, fails security scans.

**Do this instead**:
```dockerfile
# ✅ Run as non-root user
FROM node:20-alpine

WORKDIR /app

# Copy files first
COPY package*.json ./
RUN npm ci

COPY . .

# Change ownership to node user
RUN chown -R node:node /app

# Switch to non-root user
USER node

EXPOSE 3000

CMD ["node", "index.js"]
```

---

### ❌ Anti-Pattern 2: Hardcoded Configuration

**Don't do this**:
```dockerfile
# ❌ Hardcoded environment variables
FROM node:20-alpine

WORKDIR /app

COPY . .

# ❌ Can't change these without rebuilding image
ENV DATABASE_URL="postgresql://localhost:5432/mydb"
ENV API_KEY="hardcoded-secret"
ENV NODE_ENV="production"

CMD ["node", "index.js"]
```

**Why it's bad**: Must rebuild image to change configuration, secrets baked into image layers, can't use same image across environments, violates 12-factor app principles.

**Do this instead**:
```dockerfile
# ✅ Use environment variables at runtime
FROM node:20-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .

# Only set defaults, allow override at runtime
ENV NODE_ENV=production

CMD ["node", "index.js"]
```

```yaml
# docker-compose.yml
version: '3.8'

services:
  app:
    build: .
    environment:
      # ✅ Configure at runtime
      - DATABASE_URL=${DATABASE_URL}
      - API_KEY=${API_KEY}
      - NODE_ENV=${NODE_ENV:-production}
    env_file:
      - .env # ✅ Load from file
```

---

### ❌ Anti-Pattern 3: Using Latest Tag in Production

**Don't do this**:
```dockerfile
# ❌ Unpredictable base image
FROM node:latest

WORKDIR /app
COPY . .
RUN npm ci
CMD ["node", "index.js"]
```

```yaml
# docker-compose.yml
services:
  app:
    # ❌ Latest tag changes over time
    image: myapp:latest
```

**Why it's bad**: Latest tag is mutable and changes over time, breaks reproducible builds, can introduce breaking changes unexpectedly, difficult to rollback, production deploys become unpredictable.

**Do this instead**:
```dockerfile
# ✅ Pin specific version
FROM node:20.11.0-alpine3.19

WORKDIR /app
COPY . .
RUN npm ci
CMD ["node", "index.js"]
```

```yaml
# docker-compose.yml
services:
  app:
    # ✅ Use semantic versioning or commit SHA
    image: myapp:1.2.3
    # or
    # image: myapp:sha-abc123
```

---

For more anti-patterns (bloated images, .dockerignore, security best practices), see [references/best-practices.md](./references/best-practices.md).

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

For full docker-compose examples with multiple services, see [references/advanced.md](./references/advanced.md).

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
