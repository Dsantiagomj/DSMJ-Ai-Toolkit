# Best Practices - Docker

## .dockerignore

```
# Dependencies
node_modules
npm-debug.log
yarn-error.log

# Environment files
.env
.env.local
.env.*.local

# Git
.git
.gitignore

# Documentation
README.md
*.md

# Build output
.next
.vercel
dist
build
coverage

# IDE
.vscode
.idea
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Logs
*.log
logs
```

---

## Layer Caching

### Optimize Build Speed

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

### Order Matters

```dockerfile
# ✅ Good: Least changing layers first
FROM node:20-alpine

WORKDIR /app

# 1. Dependencies (rarely change)
COPY package*.json ./
RUN npm ci

# 2. Source code (changes often)
COPY . .

# 3. Build (depends on source)
RUN npm run build

# ❌ Bad: Invalidates cache on every change
FROM node:20-alpine
WORKDIR /app
COPY . .
RUN npm ci && npm run build
```

---

## Security

### Non-Root User

```dockerfile
# ✅ Good: Run as non-root user
FROM node:20-alpine

WORKDIR /app

# Create user
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001

COPY --chown=nextjs:nodejs . .

USER nextjs

CMD ["node", "server.js"]

# ❌ Bad: Running as root
FROM node:20-alpine
COPY . /app
CMD ["node", "server.js"]
```

### Use Specific Versions

```dockerfile
# ✅ Good: Pin specific version
FROM node:20.11-alpine3.19

# ✅ Acceptable: Pin major.minor
FROM node:20-alpine

# ❌ Bad: Use latest tag
FROM node:latest
FROM node:alpine
```

### Scan for Vulnerabilities

```bash
# Scan image
docker scan myapp:latest

# Scan with Trivy
trivy image myapp:latest

# Scan with Snyk
snyk container test myapp:latest
```

### Secrets Management

```dockerfile
# ❌ Bad: Hardcoded secrets
ENV DATABASE_PASSWORD=mysecret

# ✅ Good: Use build secrets (BuildKit)
RUN --mount=type=secret,id=db_password \
    export DB_PASS=$(cat /run/secrets/db_password) && \
    echo "Using secret safely"
```

```bash
# Build with secrets
docker build --secret id=db_password,src=./secrets/db.txt -t myapp .
```

```yaml
# docker-compose with secrets
services:
  app:
    secrets:
      - db_password
      - api_key

secrets:
  db_password:
    file: ./secrets/db_password.txt
  api_key:
    file: ./secrets/api_key.txt
```

---

## Image Size Optimization

### Use Alpine Images

```dockerfile
# Alpine (smallest)
FROM node:20-alpine     # ~120 MB

# Slim
FROM node:20-slim       # ~200 MB

# Standard (largest)
FROM node:20            # ~900 MB
```

### Multi-Stage Builds

```dockerfile
# Build stage with all tools
FROM node:20 AS builder
WORKDIR /app
COPY . .
RUN npm ci && npm run build

# Production stage with minimal dependencies
FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
CMD ["node", "dist/index.js"]
```

### Remove Unnecessary Files

```dockerfile
# Clean up after installation
RUN npm ci --only=production && \
    npm cache clean --force && \
    rm -rf /tmp/*

# Remove dev dependencies
RUN npm prune --production
```

### Use .dockerignore

```
# Excludes files from build context
node_modules
.git
.next
dist
coverage
*.log
```

---

## Health Checks

### Node.js Health Check

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node healthcheck.js || exit 1
```

```javascript
// healthcheck.js
const http = require('http');

const options = {
  host: 'localhost',
  port: 3000,
  path: '/health',
  timeout: 2000,
};

const request = http.request(options, (res) => {
  process.exit(res.statusCode === 200 ? 0 : 1);
});

request.on('error', () => process.exit(1));
request.end();
```

### HTTP Health Check

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1
```

### Docker Compose Health Check

```yaml
services:
  app:
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 3s
      retries: 3
      start_period: 40s

  db:
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5
```

---

## Logging

### JSON Logging

```javascript
// Use structured logging
console.log(JSON.stringify({
  level: 'info',
  message: 'Server started',
  port: 3000,
  timestamp: new Date().toISOString(),
}));
```

### Log Drivers

```yaml
services:
  app:
    logging:
      driver: json-file
      options:
        max-size: "10m"
        max-file: "3"
```

```yaml
# Use syslog
services:
  app:
    logging:
      driver: syslog
      options:
        syslog-address: "tcp://192.168.0.42:123"
```

### View Logs

```bash
# Follow logs
docker-compose logs -f app

# Last 100 lines
docker-compose logs --tail=100 app

# Since timestamp
docker logs --since 2023-01-01T00:00:00 app
```

---

## Build Optimization

### BuildKit

```bash
# Enable BuildKit
export DOCKER_BUILDKIT=1
docker build -t myapp .

# Or inline
DOCKER_BUILDKIT=1 docker build -t myapp .
```

```dockerfile
# syntax=docker/dockerfile:1.4

# Use BuildKit features
FROM node:20-alpine

# Cache mounts
RUN --mount=type=cache,target=/root/.npm \
    npm ci --only=production
```

### Parallel Builds

```dockerfile
# Build dependencies in parallel
FROM node:20-alpine AS deps-prod
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:20-alpine AS deps-dev
WORKDIR /app
COPY package*.json ./
RUN npm ci

# Use deps in final stage
FROM node:20-alpine
COPY --from=deps-prod /app/node_modules ./node_modules
```

---

## Development vs Production

### Separate Dockerfiles

```dockerfile
# Dockerfile.dev
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
CMD ["npm", "run", "dev"]
```

```dockerfile
# Dockerfile
FROM node:20-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci

FROM node:20-alpine AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build

FROM node:20-alpine
WORKDIR /app
ENV NODE_ENV=production
COPY --from=builder /app/dist ./dist
CMD ["node", "dist/index.js"]
```

### Compose Override

```yaml
# docker-compose.yml (base)
version: '3.8'
services:
  app:
    build: .
    ports:
      - '3000:3000'
```

```yaml
# docker-compose.override.yml (dev)
version: '3.8'
services:
  app:
    build:
      dockerfile: Dockerfile.dev
    volumes:
      - .:/app
      - /app/node_modules
    environment:
      - NODE_ENV=development
```

```yaml
# docker-compose.prod.yml (production)
version: '3.8'
services:
  app:
    build:
      dockerfile: Dockerfile
    environment:
      - NODE_ENV=production
    restart: unless-stopped
```

```bash
# Development (uses override automatically)
docker-compose up

# Production
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up
```

---

## Common Pitfalls

### ❌ Copying node_modules

```dockerfile
# Bad: Copies host node_modules
COPY . .
```

```
# Fix: Use .dockerignore
node_modules
```

### ❌ Not Using Layer Caching

```dockerfile
# Bad: Changes to code invalidate dependencies
COPY . .
RUN npm ci
```

```dockerfile
# Good: Dependencies cached separately
COPY package*.json ./
RUN npm ci
COPY . .
```

### ❌ Running as Root

```dockerfile
# Bad: Security risk
FROM node:20-alpine
COPY . /app
CMD ["node", "server.js"]
```

```dockerfile
# Good: Non-root user
FROM node:20-alpine
RUN adduser -D appuser
USER appuser
COPY . /app
CMD ["node", "server.js"]
```

### ❌ Using latest Tag

```dockerfile
# Bad: Unpredictable builds
FROM node:latest
```

```dockerfile
# Good: Pin specific version
FROM node:20.11-alpine3.19
```
