---
name: git-conventional-commits
description: Conventional Commits specification patterns. Use when creating git commits to follow standardized commit message format.
tags: [git, workflow, conventions]
author: dsmj-ai-toolkit
---

# Git Conventional Commits - Standardized Commit Messages

**Simple skill demonstrating minimal viable skill structure**

---

## Overview

**What this skill provides**: Conventional Commits format patterns
**When to use**: Creating git commit messages
**Key concept**: Structured commit messages for better changelog and versioning

---

## Core Pattern

### Commit Message Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style (formatting, semicolons)
- `refactor`: Code restructuring (no feat/fix)
- `test`: Add or update tests
- `chore`: Build, dependencies, tooling

---

## Common Scenarios

### Feature Addition

```bash
git commit -m "feat: add user profile editing"

git commit -m "feat(auth): add JWT token refresh"
```

### Bug Fix

```bash
git commit -m "fix: resolve null pointer in user lookup"

git commit -m "fix(api): handle missing email field"
```

### Breaking Change

```bash
git commit -m "feat!: redesign authentication API

BREAKING CHANGE: Auth endpoints moved from /auth to /api/v2/auth"
```

---

## Quick Reference

| Type | Use When | Example |
|------|----------|---------|
| feat | New feature | `feat: add dark mode` |
| fix | Bug fix | `fix: correct validation logic` |
| docs | Documentation | `docs: update API reference` |
| refactor | Code restructure | `refactor: extract auth utilities` |
| test | Add/update tests | `test: add user registration tests` |

---

## Anti-Patterns

❌ **Don't**: `git commit -m "stuff"`
✅ **Do**: `git commit -m "fix: resolve login validation bug"`

❌ **Don't**: `git commit -m "FEAT: Add Feature"` (uppercase)
✅ **Do**: `git commit -m "feat: add feature"` (lowercase)

---

_This skill demonstrates the minimal viable skill structure with one core pattern and quick reference._
