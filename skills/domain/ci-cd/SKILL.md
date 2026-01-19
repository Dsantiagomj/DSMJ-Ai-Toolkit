---
name: ci-cd
description: >
  CI/CD patterns for GitHub Actions, deployment strategies, and pipeline automation.
  Trigger: When setting up CI/CD pipelines, when configuring GitHub Actions, when automating deployments,
  when implementing deployment strategies, when building release workflows.
tags: [ci-cd, github-actions, deployment, automation, pipelines, devops, releases]
author: dsmj-ai-toolkit
metadata:
  version: "1.0"
  last_updated: "2026-01-19"
  category: domain
  auto_invoke: "When implementing CI/CD pipelines or deployment automation"
  stack_category: devops
  progressive_disclosure: true
references:
  - name: GitHub Actions Patterns
    url: ./references/github-actions.md
    type: local
---

# CI/CD - Pipeline & Deployment Patterns

**Production patterns for GitHub Actions, deployment strategies, and release automation**

---

## When to Use This Skill

**Use this skill when**:
- Setting up CI/CD pipelines
- Configuring GitHub Actions workflows
- Implementing deployment strategies
- Automating testing and linting
- Building release workflows
- Setting up preview deployments

**Don't use this skill when**:
- Using managed deployment platforms only (Vercel, Netlify auto-deploy)
- Infrastructure as code (see `docker` skill)

---

## Critical Patterns

### Pattern 1: Basic CI Pipeline

**When**: Automated testing on every PR

```yaml
# ✅ GOOD: .github/workflows/ci.yml
name: CI

on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - run: npm ci

      - run: npm run lint

  typecheck:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - run: npm ci

      - run: npm run typecheck

  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - run: npm ci

      - run: npm test -- --coverage

      - uses: codecov/codecov-action@v4
        with:
          token: ${{ secrets.CODECOV_TOKEN }}

  build:
    runs-on: ubuntu-latest
    needs: [lint, typecheck, test]
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - run: npm ci

      - run: npm run build

      - uses: actions/upload-artifact@v4
        with:
          name: build
          path: .next

# ❌ BAD: Single job doing everything sequentially
jobs:
  build:
    steps:
      - run: npm run lint && npm run typecheck && npm test && npm run build
```

### Pattern 2: Deployment Workflow

**When**: Automated staging and production deployments

```yaml
# ✅ GOOD: .github/workflows/deploy.yml
name: Deploy

on:
  push:
    branches: [main]
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment to deploy'
        required: true
        default: 'staging'
        type: choice
        options:
          - staging
          - production

jobs:
  test:
    uses: ./.github/workflows/ci.yml

  deploy-staging:
    needs: test
    runs-on: ubuntu-latest
    environment:
      name: staging
      url: https://staging.example.com
    steps:
      - uses: actions/checkout@v4

      - name: Deploy to Vercel (Staging)
        run: |
          npx vercel deploy --token=${{ secrets.VERCEL_TOKEN }} \
            --env NEXT_PUBLIC_API_URL=${{ vars.API_URL }}

  deploy-production:
    needs: deploy-staging
    runs-on: ubuntu-latest
    if: github.event.inputs.environment == 'production' || github.ref == 'refs/heads/main'
    environment:
      name: production
      url: https://example.com
    steps:
      - uses: actions/checkout@v4

      - name: Deploy to Vercel (Production)
        run: |
          npx vercel deploy --prod --token=${{ secrets.VERCEL_TOKEN }} \
            --env NEXT_PUBLIC_API_URL=${{ vars.API_URL }}

      - name: Notify Slack
        uses: slackapi/slack-github-action@v1
        with:
          payload: |
            {
              "text": "🚀 Deployed to production: ${{ github.sha }}"
            }
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK }}
```

### Pattern 3: Release Workflow

**When**: Automating version bumps and changelog generation

```yaml
# ✅ GOOD: .github/workflows/release.yml
name: Release

on:
  push:
    tags:
      - 'v*'

permissions:
  contents: write
  packages: write

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Generate changelog
        id: changelog
        uses: orhun/git-cliff-action@v3
        with:
          config: cliff.toml
          args: --latest --strip header

      - name: Create GitHub Release
        uses: softprops/action-gh-release@v1
        with:
          body: ${{ steps.changelog.outputs.content }}
          draft: false
          prerelease: ${{ contains(github.ref, 'alpha') || contains(github.ref, 'beta') }}

      - name: Deploy to Production
        run: |
          npx vercel deploy --prod --token=${{ secrets.VERCEL_TOKEN }}

# Conventional commit workflow for automatic versioning
# .github/workflows/version.yml
name: Version

on:
  push:
    branches: [main]

jobs:
  version:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
          token: ${{ secrets.PAT }}

      - name: Bump version
        uses: conventional-changelog/standard-version@v15
        with:
          release-as: patch  # or minor, major

      - name: Push changes
        run: |
          git push --follow-tags origin main
```

### Pattern 4: Preview Deployments

**When**: Creating preview environments for PRs

```yaml
# ✅ GOOD: .github/workflows/preview.yml
name: Preview

on:
  pull_request:
    types: [opened, synchronize, reopened]

jobs:
  deploy-preview:
    runs-on: ubuntu-latest
    permissions:
      pull-requests: write
    steps:
      - uses: actions/checkout@v4

      - name: Deploy Preview
        id: deploy
        run: |
          PREVIEW_URL=$(npx vercel deploy --token=${{ secrets.VERCEL_TOKEN }})
          echo "url=$PREVIEW_URL" >> $GITHUB_OUTPUT

      - name: Comment on PR
        uses: actions/github-script@v7
        with:
          script: |
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: `🔗 Preview deployed: ${{ steps.deploy.outputs.url }}`
            })

  cleanup-preview:
    runs-on: ubuntu-latest
    if: github.event.action == 'closed'
    steps:
      - name: Delete Preview
        run: |
          # Clean up preview deployment
          echo "Cleaning up preview for PR #${{ github.event.number }}"
```

### Pattern 5: Matrix Testing

**When**: Testing across multiple versions or platforms

```yaml
# ✅ GOOD: Matrix strategy for comprehensive testing
name: Test Matrix

on: [push, pull_request]

jobs:
  test:
    runs-on: ${{ matrix.os }}
    strategy:
      fail-fast: false
      matrix:
        os: [ubuntu-latest, macos-latest, windows-latest]
        node: [18, 20, 22]
        exclude:
          - os: windows-latest
            node: 18  # Skip old Node on Windows

    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node }}
          cache: 'npm'

      - run: npm ci

      - run: npm test

  test-database:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:16
        env:
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: test
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

      redis:
        image: redis:7
        ports:
          - 6379:6379

    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - run: npm ci

      - name: Run migrations
        run: npx prisma migrate deploy
        env:
          DATABASE_URL: postgres://postgres:postgres@localhost:5432/test

      - name: Run tests
        run: npm test
        env:
          DATABASE_URL: postgres://postgres:postgres@localhost:5432/test
          REDIS_URL: redis://localhost:6379
```

---

## Code Examples

For complete, production-ready examples, see [references/examples.md](./references/examples.md):
- Reusable Workflow
- Database Migration Pipeline
- Monorepo CI
- Docker Build and Push

---

## Anti-Patterns

### Don't: Hardcode Secrets

```yaml
# ❌ BAD: Secrets in workflow file
env:
  API_KEY: sk-12345abcdef

# ✅ GOOD: Use GitHub Secrets
env:
  API_KEY: ${{ secrets.API_KEY }}
```

### Don't: Deploy Without Tests

```yaml
# ❌ BAD: Deploy without testing
on:
  push:
    branches: [main]
jobs:
  deploy:
    steps:
      - run: npm run deploy  # What if tests fail?

# ✅ GOOD: Tests must pass first
jobs:
  test:
    # ... run tests
  deploy:
    needs: test  # Only runs if test passes
```

### Don't: Skip Caching

```yaml
# ❌ BAD: Installing dependencies every time
- run: npm ci  # Downloads everything every run

# ✅ GOOD: Cache dependencies
- uses: actions/setup-node@v4
  with:
    cache: 'npm'
- run: npm ci  # Uses cache when possible
```

---

## Quick Reference

| Task | Action/Approach | Example |
|------|-----------------|---------|
| Cache deps | `actions/setup-node` with cache | `cache: 'npm'` |
| Parallel jobs | Matrix strategy | `matrix: { node: [18, 20] }` |
| Service deps | Services containers | `services: postgres:` |
| Preview deploy | PR comment with URL | `actions/github-script` |
| Auto-release | Tag-triggered workflow | `on: push: tags: ['v*']` |
| Reuse workflows | `workflow_call` | `uses: ./.github/workflows/x.yml` |

---

## Resources

**Official Documentation**:
- [GitHub Actions](https://docs.github.com/en/actions)
- [Workflow Syntax](https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions)

**Related Skills**:
- **docker**: Container builds in CI
- **observability**: Deployment monitoring
- **security**: Secure CI/CD practices

---

## Keywords

`ci-cd`, `github-actions`, `deployment`, `pipelines`, `automation`, `continuous-integration`, `continuous-deployment`, `release`, `preview`
