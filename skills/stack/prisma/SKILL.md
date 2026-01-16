---
name: prisma
domain: backend
description: Prisma ORM for TypeScript - Next-generation ORM with type-safe queries, migrations, and database management. Use for database operations, schema design, and data access patterns.
version: 1.0.0
tags: [prisma, orm, database, typescript, postgresql, mysql, sqlite, migrations]
references:
  - name: Prisma Documentation
    url: https://www.prisma.io/docs
    type: documentation
  - name: Prisma GitHub
    url: https://github.com/prisma/prisma
    type: repository
  - name: Prisma Context7
    url: /websites/prisma_io
    type: context7
  - name: Schema & Relations
    url: ./references/schema.md
    type: local
  - name: Advanced Queries
    url: ./references/queries.md
    type: local
  - name: Migrations & Best Practices
    url: ./references/migrations.md
    type: local
---

# Prisma - Next-Generation ORM

**Type-safe database access with auto-generated queries and migrations**

---

## What This Skill Covers

- **Prisma Schema** design and relationships
- **Prisma Client** for type-safe queries
- **CRUD Operations** (Create, Read, Update, Delete)
- **Migrations** for schema changes
- **Relations** and transactions

For advanced queries, migrations, and best practices, see [references/](./references/).

---

## Installation

```bash
npm install @prisma/client
npm install -D prisma

# Initialize Prisma
npx prisma init
```

---

## Basic Schema

```prisma
// schema.prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id        String   @id @default(cuid())
  email     String   @unique
  name      String?
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  posts     Post[]
}

model Post {
  id        String   @id @default(cuid())
  title     String
  content   String?
  published Boolean  @default(false)

  author    User     @relation(fields: [authorId], references: [id])
  authorId  String

  @@index([authorId])
}
```

See [schema.md](./references/schema.md) for field types, relations, and advanced schema patterns.

---

## Prisma Client Setup

```typescript
// lib/prisma.ts
import { PrismaClient } from '@prisma/client';

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined;
};

export const prisma =
  globalForPrisma.prisma ??
  new PrismaClient({
    log: process.env.NODE_ENV === 'development' ? ['query', 'error', 'warn'] : ['error'],
  });

if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma;
```

---

## CRUD Operations

### Create

```typescript
// Create single record
const user = await prisma.user.create({
  data: {
    email: 'alice@example.com',
    name: 'Alice',
  },
});

// Create with relations
const user = await prisma.user.create({
  data: {
    email: 'alice@example.com',
    name: 'Alice',
    posts: {
      create: [
        { title: 'First Post', content: 'Hello World' },
      ],
    },
  },
  include: { posts: true },
});
```

### Read

```typescript
// Find unique
const user = await prisma.user.findUnique({
  where: { email: 'alice@example.com' },
  include: { posts: true },
});

// Find many with filters
const posts = await prisma.post.findMany({
  where: {
    published: true,
    author: {
      email: { contains: '@example.com' },
    },
  },
  include: {
    author: {
      select: { name: true, email: true },
    },
  },
  orderBy: { createdAt: 'desc' },
  take: 10,
});
```

### Update

```typescript
// Update single
const user = await prisma.user.update({
  where: { id: userId },
  data: { name: 'Alice Smith' },
});

// Update many
await prisma.post.updateMany({
  where: { published: false },
  data: { published: true },
});

// Upsert (update or create)
const user = await prisma.user.upsert({
  where: { email: 'alice@example.com' },
  update: { name: 'Alice Updated' },
  create: {
    email: 'alice@example.com',
    name: 'Alice',
  },
});
```

### Delete

```typescript
// Delete single
await prisma.user.delete({
  where: { id: userId },
});

// Delete many
await prisma.post.deleteMany({
  where: { published: false },
});
```

See [queries.md](./references/queries.md) for pagination, filtering, aggregations, and transactions.

---

## Migrations

```bash
# Create migration from schema changes
npx prisma migrate dev --name add_user_role

# Deploy migrations (production)
npx prisma migrate deploy

# Generate Prisma Client
npx prisma generate

# Push schema without migration (prototyping)
npx prisma db push
```

See [migrations.md](./references/migrations.md) for migration workflows and seeding.

---

## Quick Reference

```typescript
// Create
await prisma.user.create({ data: { email: 'user@example.com' } });
await prisma.user.createMany({ data: [...] });

// Read
await prisma.user.findUnique({ where: { id: '...' } });
await prisma.user.findMany({ where: { ... }, take: 10 });
await prisma.user.count({ where: { ... } });

// Update
await prisma.user.update({ where: { id: '...' }, data: { ... } });
await prisma.user.updateMany({ where: { ... }, data: { ... } });
await prisma.user.upsert({ where: { ... }, update: { ... }, create: { ... } });

// Delete
await prisma.user.delete({ where: { id: '...' } });
await prisma.user.deleteMany({ where: { ... } });

// Transactions
await prisma.$transaction([...]);
await prisma.$transaction(async (tx) => { ... });
```

---

## Learn More

- **Schema & Relations**: [references/schema.md](./references/schema.md) - Field types, relations (one-to-one, one-to-many, many-to-many)
- **Advanced Queries**: [references/queries.md](./references/queries.md) - Pagination, filtering, aggregations, transactions
- **Migrations & Best Practices**: [references/migrations.md](./references/migrations.md) - Migration workflows, seeding, performance optimization

---

## External References

- [Prisma Documentation](https://www.prisma.io/docs)
- [Prisma GitHub](https://github.com/prisma/prisma)

---

_Maintained by dsmj-ai-toolkit_
