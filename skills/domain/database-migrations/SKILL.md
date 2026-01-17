---
name: database-migrations
domain: backend
description: >
  Database schema migrations and change management. Covers Prisma migrations, schema versioning, rollback strategies, and safe production deployments.
  Trigger: When creating database migrations, when modifying schemas, when deploying database changes, when handling rollbacks.
version: 1.0.0
tags: [database, migrations, prisma, schema, sql, rollback]
metadata:
  version: "1.0"
  last_updated: "2026-01-17"
  category: domain
  progressive_disclosure: true
references:
  - name: Prisma Workflows
    url: ./references/prisma-workflows.md
    type: local
  - name: Migration Strategies
    url: ./references/migration-strategies.md
    type: local
  - name: Prisma Migrate Docs
    url: https://www.prisma.io/docs/concepts/components/prisma-migrate
    type: documentation
---

# Database Migrations

**Evolve your database schema safely and confidently**

---

## When to Use This Skill

Use this skill when:
- Creating or modifying database schemas
- Deploying database changes to production
- Planning rollback strategies
- Performing data migrations

---

## Critical Patterns

### Pattern 1: Development Workflow

**When**: Creating new migrations in development

**Good**:
```bash
# 1. Modify schema.prisma
model User {
  id    Int    @id @default(autoincrement())
  email String @unique
  name  String
}

# 2. Create migration
npx prisma migrate dev --name add_user_model

# Creates migration file and applies it
```

**Why**: `migrate dev` handles everything in development.

---

### Pattern 2: Production Deployment

**When**: Deploying to production

**Good**:
```bash
# Deploy migrations (non-interactive)
npx prisma migrate deploy

# CI/CD pipeline
```

**Bad**:
```bash
# ❌ Never use migrate dev in production
npx prisma migrate dev
```

**Why**: `migrate deploy` is non-interactive and safe for automation.

---

### Pattern 3: Backward Compatible Changes

**When**: Adding new fields or models

**Good**:
```prisma
// ✅ Adding optional field
model User {
  id       Int     @id
  email    String  @unique
  bio      String? // Existing rows get NULL
}

// ✅ Adding field with default
model User {
  id        Int      @id
  email     String   @unique
  role      String   @default("USER")
  createdAt DateTime @default(now())
}
```

**Why**: These changes don't break existing data or code.

---

### Pattern 4: Safe Field Rename

**When**: Renaming without data loss

**Good** (3-step process):
```prisma
// Step 1: Add new field mapping to same column
model User {
  id       Int    @id
  name     String
  fullName String @map("name")
}

// Step 2: Update app code to use fullName
// Step 3: Remove old field
model User {
  id       Int    @id
  fullName String @map("name")
}
```

**Bad**:
```prisma
// ❌ Direct rename (data loss)
model User {
  id       Int    @id
  fullName String // Was "name", data lost!
}
```

**Why**: Direct rename is seen as remove + add.

---

### Pattern 5: Making Field Required

**When**: Converting optional to required field

**Good** (3-step process):
```prisma
// Step 1: Add default
model User {
  id    Int     @id
  name  String? @default("")
}
```

```bash
npx prisma migrate dev --name add_default_name
```

```typescript
// Step 2: Backfill NULL values
await prisma.$executeRaw`UPDATE "User" SET name = '' WHERE name IS NULL`
```

```prisma
// Step 3: Make required
model User {
  id    Int    @id
  name  String @default("")
}
```

**Why**: Multi-step prevents errors from existing NULL values.

---

## Code Examples

### Example 1: Adding a New Model

```prisma
// schema.prisma
model User {
  id        Int      @id @default(autoincrement())
  email     String   @unique
  name      String
  createdAt DateTime @default(now())
  posts     Post[]
}

model Post {
  id        Int      @id @default(autoincrement())
  title     String
  content   String
  published Boolean  @default(false)
  authorId  Int
  author    User     @relation(fields: [authorId], references: [id])
  createdAt DateTime @default(now())
}
```

```bash
# Create migration
npx prisma migrate dev --name add_post_model

# Applies migration and generates Prisma Client
```

### Example 2: Safe Data Migration

```typescript
// Backfill default values before making field required
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function backfillUserNames() {
  // Update all NULL names to empty string
  await prisma.$executeRaw`
    UPDATE "User"
    SET name = COALESCE(name, '')
    WHERE name IS NULL
  `;

  console.log('Backfill complete');
}

backfillUserNames()
  .catch(console.error)
  .finally(() => prisma.$disconnect());
```

For comprehensive examples and detailed implementations, see the [references/](./references/) folder.

---

## Production Checklist

**Before deployment**:
- [ ] Test migration in staging (with production data copy)
- [ ] Backup production database
- [ ] Review migration SQL
- [ ] Have rollback plan ready

**Deployment**:
```bash
# 1. Backup
pg_dump production_db > backup_$(date +%Y%m%d).sql

# 2. Deploy code (if backward compatible)
git push production main

# 3. Run migrations
npx prisma migrate deploy

# 4. Verify
npx prisma migrate status
```

---

## Best Practices

**Development**:
- ✅ Use `prisma migrate dev` for iterative changes
- ✅ Keep migrations small and focused
- ✅ Review generated SQL before committing

**Production**:
- ✅ Always backup before migration
- ✅ Test in staging first
- ✅ Use `prisma migrate deploy` only
- ✅ Have rollback plan

**Safety**:
- ❌ Never delete deployed migrations
- ❌ Never modify committed migrations
- ❌ Never use `migrate reset` in production

---

## Progressive Disclosure

For detailed implementations:
- **[Prisma Workflows](./references/prisma-workflows.md)** - Dev workflow, production deployment, reset commands
- **[Migration Strategies](./references/migration-strategies.md)** - Safe renames, data migrations, breaking changes

---

## References

- [Prisma Workflows](./references/prisma-workflows.md)
- [Migration Strategies](./references/migration-strategies.md)
- [Prisma Migrate Docs](https://www.prisma.io/docs/concepts/components/prisma-migrate)

---

_Maintained by dsmj-ai-toolkit_
