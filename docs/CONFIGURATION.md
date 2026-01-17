# Configuration Guide

This guide covers how to customize dsmj-ai-toolkit for your project through the `.claude/CLAUDE.md` file.

## Table of Contents

- [Overview](#overview)
- [Project Context (Prompt DNA)](#project-context-prompt-dna)
- [Communication Styles](#communication-styles)
- [Core Operating Rules](#core-operating-rules)
- [Example Configurations](#example-configurations)

## Overview

The `.claude/CLAUDE.md` file is your **primary customization point** for the toolkit. It allows you to:

- Define your project's stack and architecture
- Set goals and auto-invoke rules for skills
- Specify non-goals and anti-patterns to avoid
- Choose communication styles (professional or casual)
- Configure project-specific conventions

This file is generated during `dsmj-ai init` and is **never overwritten** by the toolkit.

## Project Context (Prompt DNA)

The Project Context section defines what Claude needs to know about your project.

### Basic Template

```markdown
## Project Context
**Stack**: Next.js 15, React 19, TypeScript, Prisma
**Current State**: Building authentication system
**Architecture**: API routes in /app/api/, components in /components/
**Database**: PostgreSQL with Prisma ORM
**Deployment**: Vercel
```

### Advanced Example

```markdown
## Project Context
**Stack**: Next.js 15, React 19, TypeScript, Prisma, tRPC
**Current State**: MVP phase - user authentication complete, building core features
**Architecture**:
- Frontend: React Server Components in /app
- API: tRPC endpoints in /server/api
- Database: PostgreSQL with Prisma (schema in /prisma/schema.prisma)
- Auth: NextAuth.js with JWT strategy
- State: Zustand for client state, React Query for server state

**Code Conventions**:
- Use functional components with hooks
- Prefer server components unless client interactivity needed
- All API calls through tRPC
- Database queries in /server/db/ directory
```

## Goals & Auto-Invoke Rules

Define when specific skills should be referenced automatically.

### Example Configuration

```markdown
## Goals & Auto-Invoke Rules

**When working with React components**:
- Reference `react` skill for hooks and patterns
- Use `accessibility` skill for ARIA and semantic HTML
- Check `performance` skill for optimization opportunities

**When building APIs**:
- Reference `api-design` skill for REST/GraphQL best practices
- Use `security` skill for authentication and validation
- Reference `trpc` skill for type-safe endpoints

**When writing database code**:
- Reference `prisma` skill for ORM patterns
- Use `database-migrations` skill for schema changes
- Check `security` skill for SQL injection prevention

**When deploying**:
- Reference `docker` skill for containerization
- Use `devops` agent for CI/CD pipeline

**Always**:
- Run tests before committing (use `testing-frameworks` skill)
- Follow security best practices (reference `security` skill)
- Maintain accessibility standards (use `accessibility` skill)
```

## Non-Goals (Anti-Patterns)

Specify what NOT to do in your project.

### Example Configuration

```markdown
## Non-Goals (Anti-Patterns)

**Don't**:
- ❌ Use client components unless absolutely necessary (Next.js App Router)
- ❌ Bypass authentication middleware
- ❌ Write inline SQL queries (use Prisma)
- ❌ Store secrets in code (use environment variables)
- ❌ Skip error handling in API routes
- ❌ Use `any` type in TypeScript
- ❌ Commit directly to main branch
- ❌ Deploy without running tests

**Code Quality**:
- ❌ No TODO comments without GitHub issues
- ❌ No console.log in production code
- ❌ No hard-coded URLs or configuration
- ❌ No duplicate code (DRY principle)

**Security**:
- ❌ No user input without validation
- ❌ No sensitive data in client components
- ❌ No authentication tokens in URLs
```

## Communication Styles

Choose how Claude communicates with you.

### Professional (Default)

```markdown
**Communication**: Professional, concise, technical

- Use clear technical language
- Provide explanations with code examples
- Focus on best practices and patterns
- Ask clarifying questions when needed
```

### Custom Style

```markdown
**Communication**: Senior Mentor Style

- Explain the "why" behind recommendations
- Provide learning resources and references
- Break down complex concepts into steps
- Encourage best practices with explanations
- Point out potential pitfalls proactively
```

## Core Operating Rules

These rules define how agents behave in your project.

### Default Rules

```markdown
### Core Operating Rules

1. **Git Commits**: Never add AI attribution to commit messages
2. **Build Process**: Never auto-build, let user decide when to build
3. **Tooling**: Use modern tools (bat/rg/fd/sd/eza) when available
4. **User Questions**: STOP and WAIT for answers, never assume
5. **Verification First**: Say "Let me verify" before confirming anything
6. **Being Wrong**: Admit mistakes with evidence or acknowledge uncertainty
7. **Show Alternatives**: Present multiple options with tradeoffs
8. **Technical Accuracy**: Verify facts before stating as truth
9. **Quality Gates**: Review → Test → Verify before committing code
```

### Custom Rules

```markdown
### Project-Specific Rules

1. **Code Style**:
   - Use Prettier for formatting (don't manually format)
   - ESLint must pass before committing
   - TypeScript strict mode enabled

2. **Testing**:
   - Unit tests required for utilities and hooks
   - Integration tests for API routes
   - E2E tests for critical user flows
   - Minimum 80% coverage for new code

3. **Documentation**:
   - JSDoc comments for public APIs
   - README updates for new features
   - Migration guides for breaking changes

4. **Security**:
   - Input validation on all user inputs
   - Rate limiting on API endpoints
   - CSRF protection enabled
   - Content Security Policy configured

5. **Performance**:
   - Lazy load components when possible
   - Optimize images (next/image)
   - Database query optimization required
   - Monitor Core Web Vitals
```

## Example Configurations

### Full-Stack Next.js App

```markdown
# Claude Code Configuration - MyApp

## Project Context
**Stack**: Next.js 15, React 19, TypeScript, Prisma, tRPC, Tailwind
**Current State**: Beta - core features complete, adding payment integration
**Architecture**:
- App Router with React Server Components
- tRPC for type-safe APIs
- Prisma + PostgreSQL for data
- NextAuth.js for authentication
- Tailwind + Radix UI for styling

## Goals & Auto-Invoke Rules
- **UI Components** → Reference `react`, `radix-ui`, `accessibility` skills
- **API Endpoints** → Reference `trpc`, `api-design`, `security` skills
- **Database** → Reference `prisma`, `database-migrations` skills
- **Forms** → Reference `react-hook-form` skill
- **State** → Reference `zustand` skill for client state

## Non-Goals
- ❌ Don't use client components unless needed
- ❌ No inline styles (use Tailwind)
- ❌ No prop drilling (use Zustand or context)
- ❌ Never expose API keys to client

## Communication
**Style**: Professional and direct

## Quality Standards
- All features need tests
- Code review by code-reviewer agent before commits
- Run E2E tests on critical paths
- Accessibility audit for new UI components
```

### Python/Django API

```markdown
# Claude Code Configuration - API Project

## Project Context
**Stack**: Django 5, Python 3.12, PostgreSQL, Redis, Docker
**Current State**: Production - maintaining and adding features
**Architecture**:
- Django REST Framework for APIs
- Celery for background tasks
- PostgreSQL for persistence
- Redis for caching and task queue
- Docker Compose for local development

## Goals & Auto-Invoke Rules
- **API Endpoints** → Reference `api-design`, `security` skills
- **Database** → Reference `database-migrations` skill
- **Testing** → Reference `testing-frameworks` skill
- **Deployment** → Reference `docker` skill, use `devops` agent

## Non-Goals
- ❌ No unvalidated user input
- ❌ No N+1 queries (use select_related/prefetch_related)
- ❌ No synchronous API calls in views (use Celery)
- ❌ No secrets in settings.py (use environment variables)

## Communication
**Style**: Professional, direct

## Standards
- Type hints for all functions
- Docstrings for public APIs
- 90% test coverage minimum
- Security scan on all dependencies
```

## Tips and Best Practices

### Keep It Updated

- Update `Current State` when moving to new phases
- Add new auto-invoke rules as patterns emerge
- Remove non-goals that no longer apply

### Be Specific

- Vague: "Use best practices"
- Better: "Validate all user input with Zod schemas"

### Reference Skills

- Instead of repeating patterns, reference skills
- Example: "Reference `security` skill" vs. listing all security rules

### Use Examples

- Provide code examples of preferred patterns
- Show what you want AND what you don't want

### Test Your Configuration

- After updating CLAUDE.md, test with Claude Code
- Verify agents reference the right skills
- Confirm communication style matches expectations

## Need Help?

- See [agents/GUIDE.md](../agents/GUIDE.md) for agent customization
- See [skills/GUIDE.md](../skills/GUIDE.md) for skill creation
- See [docs/WORKFLOWS.md](WORKFLOWS.md) for workflow examples
- See main [README.md](../README.md) for getting started

---

**Related Documentation**:
- [Architecture](ARCHITECTURE.md)
- [Workflows](WORKFLOWS.md)
- [MCP Safety](MCP_SAFETY.md)
