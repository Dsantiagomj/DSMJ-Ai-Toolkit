# Prisma Migration Workflows

Complete guide to Prisma migration commands and workflows.

---

## Development Workflow

```bash
# 1. Modify schema.prisma
# 2. Create and apply migration
npx prisma migrate dev --name add_user_model

# This does three things:
# - Creates SQL migration file
# - Applies migration to database
# - Regenerates Prisma Client
```

---

## Production Deployment

```bash
# Deploy migrations (non-interactive)
npx prisma migrate deploy

# This:
# - Applies pending migrations
# - Does NOT create new migrations
# - Suitable for CI/CD
```

---

## Migration Files

```sql
-- migrations/20240115120000_add_user_model/migration.sql
CREATE TABLE "User" (
    "id" SERIAL NOT NULL,
    "email" TEXT NOT NULL,
    "name" TEXT NOT NULL,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "User_email_key" ON "User"("email");
```

---

## Reset Database (Dev Only)

```bash
# ⚠️ DESTRUCTIVE: Drops and recreates database
npx prisma migrate reset
```

---

_Maintained by dsmj-ai-toolkit_
