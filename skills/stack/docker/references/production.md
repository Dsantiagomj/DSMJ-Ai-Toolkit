# Production Deployment - Docker

## Next.js Production

### Optimized Dockerfile

```dockerfile
FROM node:20-alpine AS deps
WORKDIR /app

COPY package*.json ./
RUN npm ci

FROM node:20-alpine AS builder
WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Build with standalone output
RUN npm run build

FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production

# Create non-root user
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Copy necessary files
COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

EXPOSE 3000

ENV PORT 3000
ENV HOSTNAME "0.0.0.0"

CMD ["node", "server.js"]
```

### next.config.js

```javascript
/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'standalone',
  experimental: {
    outputFileTracingRoot: undefined,
  },
};

module.exports = nextConfig;
```

---

## Environment Variables

### Production Compose

```yaml
# docker-compose.prod.yml
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - '3000:3000'
    environment:
      - NODE_ENV=production
      - DATABASE_URL=${DATABASE_URL}
      - NEXTAUTH_SECRET=${NEXTAUTH_SECRET}
      - NEXTAUTH_URL=${NEXTAUTH_URL}
      - REDIS_URL=${REDIS_URL}
    env_file:
      - .env.production
    restart: unless-stopped
    depends_on:
      - db
      - redis

  db:
    image: postgres:16-alpine
    environment:
      - POSTGRES_USER=${POSTGRES_USER}
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
      - POSTGRES_DB=${POSTGRES_DB}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data
    restart: unless-stopped

volumes:
  postgres_data:
  redis_data:
```

### .env.production

```bash
NODE_ENV=production
DATABASE_URL=postgresql://postgres:secure_password@db:5432/production_db
NEXTAUTH_SECRET=your-production-secret-key
NEXTAUTH_URL=https://yourdomain.com
REDIS_URL=redis://redis:6379
POSTGRES_USER=postgres
POSTGRES_PASSWORD=secure_password
POSTGRES_DB=production_db
```

---

## Container Orchestration

### Docker Swarm

```bash
# Initialize swarm
docker swarm init

# Deploy stack
docker stack deploy -c docker-compose.yml myapp

# List services
docker service ls

# Scale service
docker service scale myapp_app=3

# Update service
docker service update --image myapp:v2 myapp_app

# Remove stack
docker stack rm myapp
```

```yaml
# docker-compose.yml (Swarm mode)
version: '3.8'

services:
  app:
    image: myapp:latest
    deploy:
      replicas: 3
      update_config:
        parallelism: 2
        delay: 10s
      restart_policy:
        condition: on-failure
      resources:
        limits:
          cpus: '2'
          memory: 2G
        reservations:
          cpus: '0.5'
          memory: 512M
    ports:
      - '3000:3000'
    networks:
      - app-network

networks:
  app-network:
    driver: overlay
```

---

## Load Balancing

### Nginx Reverse Proxy

```yaml
# docker-compose.yml
version: '3.8'

services:
  nginx:
    image: nginx:alpine
    ports:
      - '80:80'
      - '443:443'
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./ssl:/etc/nginx/ssl:ro
    depends_on:
      - app
    restart: unless-stopped

  app:
    build: .
    deploy:
      replicas: 3
    expose:
      - '3000'
    restart: unless-stopped
```

```nginx
# nginx.conf
upstream app_servers {
    least_conn;
    server app:3000;
}

server {
    listen 80;
    server_name yourdomain.com;

    location / {
        proxy_pass http://app_servers;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

---

## SSL/TLS

### Let's Encrypt with Certbot

```yaml
version: '3.8'

services:
  nginx:
    image: nginx:alpine
    ports:
      - '80:80'
      - '443:443'
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - certbot-etc:/etc/letsencrypt
      - certbot-var:/var/lib/letsencrypt
      - web-root:/var/www/html
    depends_on:
      - app

  certbot:
    image: certbot/certbot
    volumes:
      - certbot-etc:/etc/letsencrypt
      - certbot-var:/var/lib/letsencrypt
      - web-root:/var/www/html
    command: certonly --webroot --webroot-path=/var/www/html --email you@example.com --agree-tos --no-eff-email -d yourdomain.com

  app:
    build: .
    expose:
      - '3000'

volumes:
  certbot-etc:
  certbot-var:
  web-root:
```

---

## Monitoring

### Prometheus & Grafana

```yaml
version: '3.8'

services:
  app:
    build: .
    ports:
      - '3000:3000'
      - '9090:9090'  # Metrics endpoint

  prometheus:
    image: prom/prometheus
    ports:
      - '9091:9090'
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus

  grafana:
    image: grafana/grafana
    ports:
      - '3001:3000'
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana_data:/var/lib/grafana

volumes:
  prometheus_data:
  grafana_data:
```

```yaml
# prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'app'
    static_configs:
      - targets: ['app:9090']
```

---

## Database Backups

### Automated PostgreSQL Backups

```yaml
version: '3.8'

services:
  db:
    image: postgres:16-alpine
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./backups:/backups

  backup:
    image: postgres:16-alpine
    depends_on:
      - db
    environment:
      - PGHOST=db
      - PGUSER=postgres
      - PGPASSWORD=postgres
      - PGDATABASE=myapp
    volumes:
      - ./backups:/backups
    command: >
      sh -c "
      while true; do
        pg_dump -U postgres myapp > /backups/backup_$$(date +%Y%m%d_%H%M%S).sql
        find /backups -name '*.sql' -mtime +7 -delete
        sleep 86400
      done
      "

volumes:
  postgres_data:
```

### Manual Backup

```bash
# Backup
docker-compose exec db pg_dump -U postgres myapp > backup.sql

# Restore
docker-compose exec -T db psql -U postgres myapp < backup.sql
```

---

## CI/CD Integration

### GitHub Actions

```yaml
# .github/workflows/deploy.yml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Login to Docker Hub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}

      - name: Build and push
        uses: docker/build-push-action@v4
        with:
          context: .
          push: true
          tags: myapp:latest,myapp:${{ github.sha }}

      - name: Deploy to production
        uses: appleboy/ssh-action@master
        with:
          host: ${{ secrets.HOST }}
          username: ${{ secrets.USERNAME }}
          key: ${{ secrets.SSH_KEY }}
          script: |
            cd /app
            docker-compose pull
            docker-compose up -d
            docker image prune -f
```

---

## Resource Management

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

### Docker Compose v2

```yaml
services:
  app:
    mem_limit: 2g
    cpus: 2
```

---

## Zero-Downtime Deployment

### Rolling Updates

```bash
# Update service with rolling update
docker service update \
  --image myapp:v2 \
  --update-parallelism 2 \
  --update-delay 10s \
  myapp_app
```

### Blue-Green Deployment

```yaml
# docker-compose.blue.yml
version: '3.8'

services:
  app-blue:
    image: myapp:v1
    networks:
      - app-network

networks:
  app-network:
```

```yaml
# docker-compose.green.yml
version: '3.8'

services:
  app-green:
    image: myapp:v2
    networks:
      - app-network

networks:
  app-network:
```

```bash
# Deploy new version
docker-compose -f docker-compose.green.yml up -d

# Update load balancer to point to green

# Remove old version
docker-compose -f docker-compose.blue.yml down
```

---

## Security Hardening

### Read-Only Root Filesystem

```yaml
services:
  app:
    read_only: true
    tmpfs:
      - /tmp
      - /var/run
```

### Drop Capabilities

```yaml
services:
  app:
    cap_drop:
      - ALL
    cap_add:
      - NET_BIND_SERVICE
```

### Security Options

```yaml
services:
  app:
    security_opt:
      - no-new-privileges:true
      - apparmor:docker-default
```

---

## Logging in Production

### Centralized Logging

```yaml
services:
  app:
    logging:
      driver: gelf
      options:
        gelf-address: "udp://logstash:12201"
        tag: "app"

  logstash:
    image: logstash:8
    ports:
      - "12201:12201/udp"
    volumes:
      - ./logstash.conf:/usr/share/logstash/pipeline/logstash.conf

  elasticsearch:
    image: elasticsearch:8.9.0
    environment:
      - discovery.type=single-node

  kibana:
    image: kibana:8.9.0
    ports:
      - "5601:5601"
```

---

## Production Checklist

- [ ] Use multi-stage builds
- [ ] Pin specific image versions
- [ ] Run as non-root user
- [ ] Use .dockerignore
- [ ] Set health checks
- [ ] Configure restart policies
- [ ] Set resource limits
- [ ] Enable logging
- [ ] Use secrets management
- [ ] Scan images for vulnerabilities
- [ ] Enable SSL/TLS
- [ ] Set up monitoring
- [ ] Configure automated backups
- [ ] Test disaster recovery
- [ ] Document deployment process
