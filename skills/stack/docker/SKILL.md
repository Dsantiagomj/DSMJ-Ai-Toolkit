---
name: docker
domain: devops
description: Docker containerization for development and deployment. Use for Dockerfile creation, docker-compose setup, and container orchestration.
version: 1.0.0
tags: [docker, containers, devops, deployment, docker-compose, containerization]
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
---

# Docker - Containerization Platform

**Package applications in containers for consistent deployment across environments**

---

## What This Skill Covers

- **Dockerfile** creation and best practices
- **docker-compose** for multi-container applications
- **Development workflows** with Docker
- **Production deployment** patterns
- **Multi-stage builds** for optimization
- **Networking** and volumes

---

## Dockerfile Basics

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

### Multi-Stage Build (Optimized)

```dockerfile
# Build stage
FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

# Production stage
FROM node:20-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY --from=builder /app/dist ./dist

EXPOSE 3000

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

### Full Stack (Next.js + Prisma + Redis)

```yaml
version: '3.8'

services:
  app:
    build: .
    ports:
      - '3000:3000'
    environment:
      - DATABASE_URL=postgresql://postgres:postgres@db:5432/myapp
      - REDIS_URL=redis://redis:6379
    depends_on:
      - db
      - redis
    volumes:
      - .:/app
      - /app/node_modules

  db:
    image: postgres:16-alpine
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
      - POSTGRES_DB=myapp
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - '5432:5432'

  redis:
    image: redis:7-alpine
    ports:
      - '6379:6379'
    volumes:
      - redis_data:/data

volumes:
  postgres_data:
  redis_data:
```

---

## Development Workflow

### Docker Compose Commands

```bash
# Start services
docker-compose up

# Start in background
docker-compose up -d

# Stop services
docker-compose down

# Rebuild and start
docker-compose up --build

# View logs
docker-compose logs -f app

# Execute command in container
docker-compose exec app sh

# Run migrations
docker-compose exec app npm run migrate
```

### Hot Reload (Development)

```dockerfile
# Dockerfile.dev
FROM node:20-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 3000

CMD ["npm", "run", "dev"]
```

```yaml
# docker-compose.dev.yml
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile.dev
    ports:
      - '3000:3000'
    volumes:
      - .:/app
      - /app/node_modules
    environment:
      - DATABASE_URL=postgresql://postgres:postgres@db:5432/myapp
    depends_on:
      - db
```

---

## Best Practices

### .dockerignore

```
node_modules
npm-debug.log
.env
.env.local
.git
.gitignore
README.md
.next
.vercel
dist
coverage
```

### Layer Caching

```dockerfile
# ✅ Good: Dependencies cached separately
COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

# ❌ Bad: Everything copied together
COPY . .
RUN npm ci && npm run build
```

### Security

```dockerfile
# ✅ Good: Run as non-root user
FROM node:20-alpine

RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001

USER nextjs

# ✅ Good: Use specific versions
FROM node:20.11-alpine

# ❌ Bad: Use latest tag
FROM node:latest
```

### Health Checks

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node healthcheck.js || exit 1
```

---

## Production Patterns

### Next.js Production

```dockerfile
FROM node:20-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci

FROM node:20-alpine AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build

FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

EXPOSE 3000

ENV PORT 3000

CMD ["node", "server.js"]
```

### Environment Variables

```yaml
# docker-compose.prod.yml
services:
  app:
    build: .
    environment:
      - NODE_ENV=production
      - DATABASE_URL=${DATABASE_URL}
      - NEXTAUTH_SECRET=${NEXTAUTH_SECRET}
      - NEXTAUTH_URL=${NEXTAUTH_URL}
    env_file:
      - .env.production
```

---

## Common Commands

```bash
# Build image
docker build -t myapp:latest .

# Run container
docker run -p 3000:3000 myapp:latest

# List containers
docker ps
docker ps -a

# Stop container
docker stop <container-id>

# Remove container
docker rm <container-id>

# List images
docker images

# Remove image
docker rmi <image-id>

# Clean up
docker system prune -a

# View logs
docker logs -f <container-id>

# Execute command
docker exec -it <container-id> sh
```

---

## Networking

### Connect Services

```yaml
services:
  app:
    networks:
      - app-network

  db:
    networks:
      - app-network

networks:
  app-network:
    driver: bridge
```

### Port Mapping

```yaml
services:
  app:
    ports:
      - '3000:3000'      # host:container
      - '127.0.0.1:5432:5432'  # bind to localhost only
```

---

## Volumes

### Named Volumes

```yaml
services:
  db:
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

### Bind Mounts (Development)

```yaml
services:
  app:
    volumes:
      - .:/app                 # Mount current directory
      - /app/node_modules      # Don't override node_modules
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
HEALTHCHECK CMD command
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

```bash
# Essential commands
docker-compose up -d
docker-compose down
docker-compose logs -f
docker-compose exec service sh
docker-compose build
```

---

## References

- [Docker Documentation](https://docs.docker.com/)
- [Docker GitHub](https://github.com/docker)

---

_Maintained by dsmj-ai-toolkit_
