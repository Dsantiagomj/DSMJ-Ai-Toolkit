---
name: database-migrations
domain: backend
description: >
  Database schema migrations and change management. Covers Prisma migrations, schema versioning, rollback strategies, and safe production deployments.
  Trigger: When creating database migrations, when modifying schemas, when deploying database changes, when handling rollbacks, when versioning database schemas.
version: 1.0.0
tags: [database, migrations, prisma, schema, sql, rollback]
metadata:
  version: "1.0"
  last_updated: "2026-01-17"
  category: domain
references:
  - name: Prisma Migrate Documentation
    url: https://www.prisma.io/docs/concepts/components/prisma-migrate
    type: documentation
  - name: Prisma Schema Reference
    url: https://www.prisma.io/docs/reference/api-reference/prisma-schema-reference
    type: documentation
---

# Database Migrations - Schema Management & Safe Deployments

**Evolve your database schema safely and confidently**

---

## What This Skill Covers

This skill provides guidance on:
- **Prisma migrations** workflow (dev, deploy, reset)
- **Schema changes** (backward compatible vs breaking)
- **Migration strategies** for production
- **Rollback procedures** and safety
- **Data migrations** vs schema migrations
- **Multi-environment** workflows (dev, staging, production)

---

## Prisma Migration Workflow

### Development Workflow

```bash
# 1. Modify your Prisma schema
# schema.prisma
model User {
  id    Int    @id @default(autoincrement())
  email String @unique
  name  String
}

# 2. Create and apply migration in development
npx prisma migrate dev --name add_user_model

# This does three things:
# - Creates SQL migration file
# - Applies migration to database
# - Regenerates Prisma Client
```

### Migration Files

```sql
-- migrations/20240115120000_add_user_model/migration.sql
-- CreateTable
CREATE TABLE "User" (
    "id" SERIAL NOT NULL,
    "email" TEXT NOT NULL,
    "name" TEXT NOT NULL,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");
```

### Production Deployment

```bash
# Deploy migrations to production (no prompt, non-interactive)
npx prisma migrate deploy

# This:
# - Applies pending migrations
# - Does NOT create new migrations
# - Does NOT reset database
# - Suitable for CI/CD pipelines
```

### Reset Database (Development Only)

```bash
# ⚠️ DESTRUCTIVE: Drops and recreates database
npx prisma migrate reset

# This:
# - Drops database
# - Creates new database
# - Applies all migrations
# - Runs seed script (if configured)
```

---

## Schema Changes

### Backward Compatible Changes (Safe)

```prisma
// ✅ Adding new model (doesn't affect existing data)
model Post {
  id        Int      @id @default(autoincrement())
  title     String
  content   String
  authorId  Int
  author    User     @relation(fields: [authorId], references: [id])
  createdAt DateTime @default(now())
}

// ✅ Adding optional field (existing rows get NULL)
model User {
  id       Int     @id @default(autoincrement())
  email    String  @unique
  name     String
  bio      String? // Optional field
}

// ✅ Adding field with default value
model User {
  id        Int      @id @default(autoincrement())
  email     String   @unique
  name      String
  role      String   @default("USER") // Has default
  createdAt DateTime @default(now())
}

// ✅ Adding index (improves performance, doesn't change data)
model User {
  id    Int    @id @default(autoincrement())
  email String @unique
  name  String

  @@index([name]) // New index
}
```

```bash
# Create migration
npx prisma migrate dev --name add_user_bio_and_role

# Safe to deploy immediately
npx prisma migrate deploy
```

---

### Breaking Changes (Requires Care)

```prisma
// ❌ Removing field (data loss!)
model User {
  id    Int    @id @default(autoincrement())
  email String @unique
  // name field removed - existing data will be lost
}

// ❌ Renaming field (Prisma sees as remove + add)
model User {
  id       Int    @id @default(autoincrement())
  email    String @unique
  fullName String // Was "name", data will be lost
}

// ❌ Making field required (existing NULL values will fail)
model User {
  id    Int    @id @default(autoincrement())
  email String @unique
  name  String  // Was String?, existing NULLs will cause error
}

// ❌ Changing field type (may lose data)
model User {
  id    Int    @id @default(autoincrement())
  email String @unique
  age   String // Was Int, conversion may fail
}
```

---

### Safe Breaking Changes

**Rename field without data loss**:

```prisma
// Step 1: Add new field with @map
model User {
  id       Int    @id @default(autoincrement())
  email    String @unique
  name     String  // Old field name
  fullName String  @map("name") // New field maps to same column
}
```

```bash
# This creates no migration (both map to same column)
npx prisma migrate dev --name add_fullname_alias
```

```typescript
// Step 2: Update application code to use fullName
const user = await prisma.user.create({
  data: {
    email: 'alice@example.com',
    fullName: 'Alice Smith', // Use new name
  },
});
```

```prisma
// Step 3: Remove old field after code is deployed
model User {
  id       Int    @id @default(autoincrement())
  email    String @unique
  fullName String @map("name")
}
```

**Make field required (multi-step)**:

```prisma
// Current state: name is optional
model User {
  id    Int     @id @default(autoincrement())
  email String  @unique
  name  String?
}

// Step 1: Add default value for new rows
model User {
  id    Int     @id @default(autoincrement())
  email String  @unique
  name  String? @default("")
}
```

```bash
npx prisma migrate dev --name add_default_name
```

```typescript
// Step 2: Backfill existing NULL values
await prisma.$executeRaw`UPDATE "User" SET name = '' WHERE name IS NULL`;
```

```prisma
// Step 3: Make field required
model User {
  id    Int    @id @default(autoincrement())
  email String @unique
  name  String @default("")
}
```

```bash
npx prisma migrate dev --name make_name_required
```

---

## Data Migrations

Sometimes you need to transform data, not just schema.

```typescript
// prisma/migrations/20240115120000_migrate_user_roles/data-migration.ts
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  // Migrate old role values to new enum
  await prisma.$executeRaw`
    UPDATE "User"
    SET role = CASE
      WHEN role = 'admin' THEN 'ADMIN'
      WHEN role = 'user' THEN 'USER'
      ELSE 'GUEST'
    END
  `;

  console.log('Data migration complete');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
```

```bash
# Run data migration after schema migration
npx prisma migrate deploy
node prisma/migrations/20240115120000_migrate_user_roles/data-migration.ts
```

---

## Production Migration Strategy

### Pre-Deployment Checklist

```bash
# 1. Test migration in staging environment
# (staging should be copy of production data)
npx prisma migrate deploy

# 2. Backup production database
pg_dump production_db > backup_$(date +%Y%m%d_%H%M%S).sql

# 3. Check migration status
npx prisma migrate status

# 4. Review migration SQL
cat prisma/migrations/20240115120000_add_user_bio/migration.sql
```

### Deployment Process

```bash
# 1. Deploy application code first (if backward compatible)
git push production main

# 2. Run migrations
npx prisma migrate deploy

# 3. Verify migration applied
npx prisma migrate status

# 4. Smoke test application
curl https://api.example.com/health
```

### Rollback Strategy

**Option 1: Database restore** (safest for breaking changes):
```bash
# Restore from backup
psql production_db < backup_20240115_120000.sql

# Revert application code
git revert <commit-hash>
git push production main
```

**Option 2: Reverse migration** (for simple changes):
```sql
-- Create reverse migration manually
-- migrations/20240115130000_rollback_add_user_bio/migration.sql
ALTER TABLE "User" DROP COLUMN "bio";
```

```bash
npx prisma migrate resolve --rolled-back 20240115120000_add_user_bio
npx prisma migrate dev --name rollback_add_user_bio
```

---

## Multi-Environment Workflow

### Development Environment

```bash
# Iterate freely
npx prisma migrate dev --name add_feature

# Reset when needed
npx prisma migrate reset

# Generate client
npx prisma generate
```

### Staging Environment

```bash
# Test production-like migrations
npx prisma migrate deploy

# Verify with production data copy
npx prisma db seed
```

### Production Environment

```bash
# Only use migrate deploy (never migrate dev!)
npx prisma migrate deploy

# CI/CD pipeline example (GitHub Actions)
```

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

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'

      - name: Install dependencies
        run: npm ci

      - name: Run database migrations
        run: npx prisma migrate deploy
        env:
          DATABASE_URL: ${{ secrets.DATABASE_URL }}

      - name: Deploy application
        run: npm run deploy
```

---

## Common Patterns

### Adding Relationship

```prisma
// Before
model User {
  id    Int    @id @default(autoincrement())
  email String @unique
  name  String
}

model Post {
  id      Int    @id @default(autoincrement())
  title   String
  content String
}

// After
model User {
  id    Int    @id @default(autoincrement())
  email String @unique
  name  String
  posts Post[] // Relation field (not in database)
}

model Post {
  id       Int    @id @default(autoincrement())
  title    String
  content  String
  authorId Int    // Foreign key
  author   User   @relation(fields: [authorId], references: [id])

  @@index([authorId])
}
```

```bash
npx prisma migrate dev --name add_post_author_relation
```

**Generated SQL**:
```sql
ALTER TABLE "Post" ADD COLUMN "authorId" INTEGER NOT NULL;
ALTER TABLE "Post" ADD CONSTRAINT "Post_authorId_fkey"
  FOREIGN KEY ("authorId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
CREATE INDEX "Post_authorId_idx" ON "Post"("authorId");
```

---

### Changing Primary Key

```prisma
// Before: Auto-increment ID
model User {
  id    Int    @id @default(autoincrement())
  email String @unique
}

// After: UUID
model User {
  id    String @id @default(uuid())
  email String @unique
}
```

**⚠️ Warning**: This is a breaking change. Requires:
1. Create new table with UUID
2. Copy data
3. Update foreign keys
4. Drop old table
5. Rename new table

**Better approach**: Create new model, migrate data gradually.

---

### Soft Deletes

```prisma
model User {
  id        Int       @id @default(autoincrement())
  email     String    @unique
  name      String
  deletedAt DateTime? // NULL = active, non-NULL = deleted

  @@index([deletedAt])
}
```

```typescript
// Filter out soft-deleted records
const activeUsers = await prisma.user.findMany({
  where: {
    deletedAt: null,
  },
});

// Soft delete
await prisma.user.update({
  where: { id: 1 },
  data: { deletedAt: new Date() },
});

// Hard delete (actually remove)
await prisma.user.delete({
  where: { id: 1 },
});
```

---

## Schema Best Practices

### Naming Conventions

```prisma
// ✅ Good: PascalCase for models
model User {
  id Int @id @default(autoincrement())
}

model BlogPost {
  id Int @id @default(autoincrement())
}

// ✅ Good: camelCase for fields
model User {
  id        Int      @id @default(autoincrement())
  firstName String
  lastName  String
  createdAt DateTime @default(now())
}

// ✅ Good: Plural for collections
model User {
  posts    Post[]    // Plural
  comments Comment[] // Plural
}
```

### Indexes

```prisma
model User {
  id        Int      @id @default(autoincrement())
  email     String   @unique // Automatically indexed
  username  String   @unique
  firstName String
  lastName  String
  createdAt DateTime @default(now())

  // Composite index for queries like: WHERE firstName = ? AND lastName = ?
  @@index([firstName, lastName])

  // Index for sorting/filtering
  @@index([createdAt])
}
```

### Timestamps

```prisma
// ✅ Good: Always include timestamps
model User {
  id        Int      @id @default(autoincrement())
  email     String   @unique
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt // Auto-updated on changes
}
```

### Enums

```prisma
enum UserRole {
  ADMIN
  USER
  GUEST
}

model User {
  id    Int      @id @default(autoincrement())
  email String   @unique
  role  UserRole @default(USER)
}
```

---

## Troubleshooting

### Migration Failed

```bash
# Check migration status
npx prisma migrate status

# Mark migration as rolled back
npx prisma migrate resolve --rolled-back <migration_name>

# Or mark as applied (if it partially succeeded)
npx prisma migrate resolve --applied <migration_name>
```

### Schema Drift

```bash
# Compare schema with database
npx prisma db pull

# This creates a new schema based on current database state
# Compare with your prisma/schema.prisma to see differences
```

### Reset Migrations (Development Only)

```bash
# ⚠️ Deletes all data and migrations
# Creates single new migration from current schema
npx prisma migrate reset

# Then create baseline migration
npx prisma migrate dev --name init
```

---

## Best Practices Summary

**Development**:
- ✅ Use `prisma migrate dev` for iterative changes
- ✅ Test migrations with realistic data
- ✅ Keep migrations small and focused
- ✅ Review generated SQL before committing

**Production**:
- ✅ Always backup database before migration
- ✅ Test migrations in staging first
- ✅ Use `prisma migrate deploy` (never `migrate dev`)
- ✅ Have rollback plan ready
- ✅ Monitor application after deployment

**Schema Design**:
- ✅ Include `createdAt` and `updatedAt` timestamps
- ✅ Add indexes for foreign keys and frequently queried fields
- ✅ Use enums for fixed sets of values
- ✅ Prefer `@default()` over nullable fields when possible

**Safety**:
- ❌ Never delete migrations that were deployed
- ❌ Never modify migrations after they're committed
- ❌ Never use `migrate reset` in production
- ❌ Never skip testing in staging environment

---

## References

- [Prisma Migrate Documentation](https://www.prisma.io/docs/concepts/components/prisma-migrate)
- [Prisma Schema Reference](https://www.prisma.io/docs/reference/api-reference/prisma-schema-reference)

---

_Maintained by dsmj-ai-toolkit_
