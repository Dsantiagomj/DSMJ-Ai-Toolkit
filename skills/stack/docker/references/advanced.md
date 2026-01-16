# Advanced Patterns - Docker

## Multi-Stage Builds

### Optimized Node.js Build

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

### Next.js Production Build

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

### Python Multi-Stage

```dockerfile
# Build stage
FROM python:3.12-slim AS builder

WORKDIR /app

COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Runtime stage
FROM python:3.12-slim

WORKDIR /app

COPY --from=builder /root/.local /root/.local
COPY . .

ENV PATH=/root/.local/bin:$PATH

CMD ["python", "app.py"]
```

---

## Full-Stack Docker Compose

### Next.js + Prisma + PostgreSQL + Redis

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
      - NODE_ENV=development
    depends_on:
      - db
      - redis
    volumes:
      - .:/app
      - /app/node_modules
      - /app/.next

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

### Microservices Setup

```yaml
version: '3.8'

services:
  frontend:
    build: ./frontend
    ports:
      - '3000:3000'
    depends_on:
      - api
      - auth

  api:
    build: ./api
    ports:
      - '4000:4000'
    environment:
      - DATABASE_URL=postgresql://postgres:postgres@db:5432/api
    depends_on:
      - db
      - redis

  auth:
    build: ./auth
    ports:
      - '5000:5000'
    environment:
      - DATABASE_URL=postgresql://postgres:postgres@db:5432/auth
    depends_on:
      - db

  db:
    image: postgres:16-alpine
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
      - POSTGRES_MULTIPLE_DATABASES=api,auth
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data

volumes:
  postgres_data:
  redis_data:
```

---

## Networking

### Custom Networks

```yaml
version: '3.8'

services:
  app:
    networks:
      - frontend
      - backend

  api:
    networks:
      - backend

  db:
    networks:
      - backend

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: true  # No external access
```

### Network Aliases

```yaml
services:
  db:
    networks:
      backend:
        aliases:
          - database
          - postgres-server
```

### Host Networking

```yaml
services:
  app:
    network_mode: host  # Use host network (Linux only)
```

### Port Binding

```yaml
services:
  app:
    ports:
      - '3000:3000'                # Public access
      - '127.0.0.1:5432:5432'      # Localhost only
      - '8080-8090:8080-8090'      # Port range
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
    driver: local
    driver_opts:
      type: none
      device: /path/on/host
      o: bind
```

### Bind Mounts (Development)

```yaml
services:
  app:
    volumes:
      - .:/app                    # Mount current directory
      - /app/node_modules         # Prevent override
      - /app/.next                # Prevent override
```

### Read-Only Volumes

```yaml
services:
  app:
    volumes:
      - ./config:/app/config:ro   # Read-only
```

### Volume Backup

```bash
# Backup volume
docker run --rm \
  -v postgres_data:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/postgres-backup.tar.gz -C /data .

# Restore volume
docker run --rm \
  -v postgres_data:/data \
  -v $(pwd):/backup \
  alpine tar xzf /backup/postgres-backup.tar.gz -C /data
```

---

## Development Workflow

### Hot Reload Setup

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
      - NODE_ENV=development
    depends_on:
      - db

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

volumes:
  postgres_data:
```

### Running Migrations

```bash
# Run Prisma migrations
docker-compose exec app npx prisma migrate dev

# Run Django migrations
docker-compose exec app python manage.py migrate

# Seed database
docker-compose exec app npm run seed
```

---

## Build Arguments

```dockerfile
ARG NODE_VERSION=20
FROM node:${NODE_VERSION}-alpine

ARG BUILD_ENV=production
ENV NODE_ENV=${BUILD_ENV}

WORKDIR /app

COPY . .

RUN if [ "$BUILD_ENV" = "production" ]; then \
      npm ci --only=production; \
    else \
      npm install; \
    fi
```

```yaml
# docker-compose.yml
services:
  app:
    build:
      context: .
      args:
        - NODE_VERSION=20
        - BUILD_ENV=production
```

```bash
# CLI build
docker build \
  --build-arg NODE_VERSION=20 \
  --build-arg BUILD_ENV=production \
  -t myapp:latest .
```

---

## Container Resources

### Memory and CPU Limits

```yaml
services:
  app:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 2G
        reservations:
          cpus: '0.5'
          memory: 512M
```

### Health Checks

```yaml
services:
  app:
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 3s
      retries: 3
      start_period: 40s
```

### Restart Policies

```yaml
services:
  app:
    restart: unless-stopped  # Always restart unless manually stopped
    # restart: always        # Always restart
    # restart: on-failure    # Restart on non-zero exit
    # restart: no            # Never restart
```

---

## Multi-Platform Builds

```bash
# Create builder
docker buildx create --name multiplatform --use

# Build for multiple platforms
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t myapp:latest \
  --push .
```

```dockerfile
# Platform-specific commands
FROM --platform=$BUILDPLATFORM node:20-alpine AS builder

ARG TARGETPLATFORM
ARG BUILDPLATFORM

RUN echo "Building on $BUILDPLATFORM for $TARGETPLATFORM"
```

---

## Debugging Containers

```bash
# Interactive shell
docker exec -it <container> sh

# View processes
docker top <container>

# Resource usage
docker stats <container>

# Inspect container
docker inspect <container>

# View container filesystem
docker diff <container>

# Copy files
docker cp <container>:/path/to/file ./local-path
docker cp ./local-path <container>:/path/to/file
```
