# DevOps Workflows & Deployment Strategies

## CI/CD Pipeline Stages

### 1. Build Stage
- Install dependencies
- Compile/build code
- Generate assets

### 2. Test Stage
- Run unit tests
- Run integration tests
- Code quality checks (linting, formatting)

### 3. Security Stage
- Dependency scanning
- SAST (static analysis)
- Secret detection

### 4. Deploy Stage
- Staging deployment (automatic on main)
- Production deployment (manual approval or on tag)

## Complete GitHub Actions Example (Next.js)

```yaml
# .github/workflows/deploy.yml
name: Deploy

on:
  push:
    branches: [main]
  workflow_dispatch:

env:
  NODE_VERSION: '20'

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run linter
        run: npm run lint

      - name: Run tests
        run: npm test

      - name: Build
        run: npm run build

  deploy-staging:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    environment:
      name: staging
      url: https://staging.example.com
    steps:
      - uses: actions/checkout@v4

      - name: Deploy to Vercel (staging)
        run: |
          npx vercel --token=${{ secrets.VERCEL_TOKEN }} \
            --env=staging \
            --yes
        env:
          VERCEL_TOKEN: ${{ secrets.VERCEL_TOKEN }}
          VERCEL_ORG_ID: ${{ secrets.VERCEL_ORG_ID }}
          VERCEL_PROJECT_ID: ${{ secrets.VERCEL_PROJECT_ID }}

  deploy-production:
    needs: test
    runs-on: ubuntu-latest
    if: startsWith(github.ref, 'refs/tags/v')
    environment:
      name: production
      url: https://example.com
    steps:
      - uses: actions/checkout@v4

      - name: Deploy to Vercel (production)
        run: |
          npx vercel --prod --token=${{ secrets.VERCEL_TOKEN }} --yes
        env:
          VERCEL_TOKEN: ${{ secrets.VERCEL_TOKEN }}
          VERCEL_ORG_ID: ${{ secrets.VERCEL_ORG_ID }}
          VERCEL_PROJECT_ID: ${{ secrets.VERCEL_PROJECT_ID }}
```

## Deployment Strategies

### Blue-Green Deployment
- **What**: Two identical environments (blue = current, green = new)
- **Process**:
  1. Deploy to green environment
  2. Test green thoroughly
  3. Switch traffic from blue to green
  4. Keep blue for instant rollback
- **Pros**: Instant rollback, zero-downtime
- **Cons**: Requires double infrastructure

### Canary Deployment
- **What**: Deploy to small subset first
- **Process**:
  1. Deploy to 5% of servers/users
  2. Monitor metrics closely
  3. Gradually increase to 25%, 50%, 100%
  4. Rollback if errors spike
- **Pros**: Risk mitigation, gradual rollout
- **Cons**: More complex, longer deployment time

### Rolling Deployment
- **What**: Update servers one at a time (or in batches)
- **Process**:
  1. Take server out of rotation
  2. Deploy new version
  3. Add back to rotation
  4. Repeat for all servers
- **Pros**: Simple, maintains availability
- **Cons**: Slower rollback, mixed versions during deploy

## Deployment Scripts

### Blue-Green with Docker Compose

```bash
#!/bin/bash
# deploy.sh - Blue-Green deployment

set -euo pipefail

echo "Starting blue-green deployment..."

# Build new image
docker build -t myapp:green .

# Start green environment
docker-compose -f docker-compose.green.yml up -d

# Health check (wait for green to be ready)
echo "Waiting for green environment..."
timeout 60 bash -c 'until curl -f http://localhost:3001/health; do sleep 2; done'

# Switch traffic (update nginx/load balancer)
echo "Switching traffic to green..."
cp nginx.green.conf /etc/nginx/sites-enabled/myapp.conf
nginx -s reload

# Stop blue environment (keep for rollback)
echo "Keeping blue for rollback (manual cleanup later)"
echo "Deployment complete!"
```

### Release Script with Version Management

```bash
#!/bin/bash
# release.sh - Create and publish release

set -euo pipefail

VERSION=$1

if [[ ! $VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Usage: ./release.sh <version> (e.g., 1.2.3)"
  exit 1
fi

echo "Creating release v$VERSION..."

# Update version
npm version $VERSION --no-git-tag-version

# Update CHANGELOG
echo "## [$VERSION] - $(date +%Y-%m-%d)" > CHANGELOG.tmp
echo "" >> CHANGELOG.tmp
git log --pretty=format:"- %s" $(git describe --tags --abbrev=0)..HEAD >> CHANGELOG.tmp
echo "" >> CHANGELOG.tmp
cat CHANGELOG.md >> CHANGELOG.tmp
mv CHANGELOG.tmp CHANGELOG.md

# Commit and tag
git add package.json package-lock.json CHANGELOG.md
git commit -m "chore: release v$VERSION"
git tag -a "v$VERSION" -m "Release v$VERSION"

echo "Release v$VERSION created!"
echo "Push with: git push && git push --tags"
```

## Monitoring & Health Checks

### Health Check Endpoint Example

```typescript
// app/api/health/route.ts
export async function GET() {
  const checks = {
    database: await checkDatabase(),
    redis: await checkRedis(),
    storage: await checkStorage(),
  };

  const healthy = Object.values(checks).every(c => c.status === 'ok');

  return Response.json(
    {
      status: healthy ? 'healthy' : 'degraded',
      checks,
      timestamp: new Date().toISOString(),
      version: process.env.VERCEL_GIT_COMMIT_SHA || 'unknown',
    },
    { status: healthy ? 200 : 503 }
  );
}

async function checkDatabase() {
  try {
    await db.$queryRaw`SELECT 1`;
    return { status: 'ok' };
  } catch (error) {
    return { status: 'error', message: error.message };
  }
}

async function checkRedis() {
  try {
    await redis.ping();
    return { status: 'ok' };
  } catch (error) {
    return { status: 'error', message: error.message };
  }
}

async function checkStorage() {
  try {
    await storage.stat('health-check.txt');
    return { status: 'ok' };
  } catch (error) {
    return { status: 'error', message: error.message };
  }
}
```

## Complete CI/CD Setup Example

See the main devops.md file for a complete walkthrough of setting up CI/CD for a Next.js application with Vercel, including:
- Phase 1: Understanding requirements
- Phase 2: CI/CD configuration
- Phase 3: Monitoring setup
- Phase 4: Release documentation
- Phase 5: Secrets configuration
