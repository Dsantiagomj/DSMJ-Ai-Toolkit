# Migration Strategies

Safe strategies for production database changes.

---

## Backward Compatible Changes

```prisma
// ✅ Adding new model
model Post {
  id        Int      @id @default(autoincrement())
  title     String
  content   String
}

// ✅ Adding optional field
model User {
  id       Int     @id
  email    String  @unique
  bio      String? // Optional
}

// ✅ Adding field with default
model User {
  id        Int      @id
  email     String   @unique
  role      String   @default("USER")
  createdAt DateTime @default(now())
}
```

---

## Breaking Changes

```prisma
// ❌ Removing field (data loss)
// ❌ Renaming field (data loss)
// ❌ Making field required (fails for NULL)
// ❌ Changing field type (may fail)
```

---

## Safe Field Rename

```prisma
// Step 1: Add new field with @map
model User {
  id       Int    @id
  name     String
  fullName String @map("name")
}

// Step 2: Update application code

// Step 3: Remove old field
model User {
  id       Int    @id
  fullName String @map("name")
}
```

---

## Make Field Required Safely

```prisma
// Step 1: Add default
model User {
  id    Int     @id
  name  String? @default("")
}

// Step 2: Backfill NULL values
await prisma.$executeRaw`UPDATE "User" SET name = '' WHERE name IS NULL`

// Step 3: Make required
model User {
  id    Int    @id
  name  String @default("")
}
```

---

## Data Migrations

```typescript
// data-migration.ts
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  // Migrate data
  await prisma.$executeRaw`
    UPDATE "User"
    SET role = CASE
      WHEN role = 'admin' THEN 'ADMIN'
      ELSE 'USER'
    END
  `;
}

main().finally(() => prisma.$disconnect());
```

---

_Maintained by dsmj-ai-toolkit_
