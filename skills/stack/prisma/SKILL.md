---
name: prisma
domain: backend
description: >
  Prisma ORM for TypeScript - Next-generation ORM with type-safe queries, migrations, and database management.
  Trigger: When defining Prisma schema, when writing database queries, when creating migrations, when setting up database models.
version: 1.0.0
tags: [prisma, orm, database, typescript, postgresql, mysql, sqlite, migrations]
metadata:
  version: "1.0"
  last_updated: "2026-01-17"
  category: stack
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

## When to Use This Skill

**Use this skill when**:
- Building type-safe database layers in TypeScript applications
- Working with PostgreSQL, MySQL, SQLite, MongoDB, or SQL Server
- Creating database schemas with migrations
- Implementing complex database relationships
- Generating type-safe database clients
- Migrating from raw SQL or other ORMs

**Don't use this skill when**:
- Building serverless functions with cold starts (consider PrismaClient connection pooling or lighter ORMs)
- Working with non-supported databases (use appropriate database drivers)
- Simple key-value data (consider simpler solutions like Redis)
- Applications requiring extremely complex raw SQL (though Prisma supports raw queries)

---

## Critical Patterns

### Pattern 1: Singleton Pattern for Prisma Client

**When**: Using Prisma in any Node.js application

**Good**:
```typescript
// lib/prisma.ts
// ✅ Singleton pattern prevents multiple instances

import { PrismaClient } from '@prisma/client'

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined
}

export const prisma =
  globalForPrisma.prisma ??
  new PrismaClient({
    log: process.env.NODE_ENV === 'development' ? ['query', 'error', 'warn'] : ['error'],
  })

// Prevent multiple instances in development (hot reload)
if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma
```

**Bad**:
```typescript
// ❌ Creating new client instances everywhere

// services/user.ts
import { PrismaClient } from '@prisma/client'
const prisma = new PrismaClient() // ❌ New instance

export async function getUser(id: string) {
  return prisma.user.findUnique({ where: { id } })
}

// services/post.ts
import { PrismaClient } from '@prisma/client'
const prisma = new PrismaClient() // ❌ Another new instance

export async function getPost(id: string) {
  return prisma.post.findUnique({ where: { id } })
}
```

**Why**: Multiple PrismaClient instances exhaust database connections, cause connection pool issues, waste resources, and slow down the application. The singleton pattern ensures one client instance per application.

---

### Pattern 2: Select and Include for Performance

**When**: Fetching data from database

**Good**:
```typescript
// ✅ Only select fields you need
async function getUserPreview(id: string) {
  return prisma.user.findUnique({
    where: { id },
    select: {
      id: true,
      name: true,
      email: true,
      // ✅ Exclude password, timestamps, etc.
    }
  })
}

// ✅ Include relations only when needed
async function getUserWithPosts(id: string) {
  return prisma.user.findUnique({
    where: { id },
    include: {
      posts: {
        take: 10, // ✅ Limit relations
        orderBy: { createdAt: 'desc' },
        select: {
          id: true,
          title: true,
          createdAt: true,
          // ✅ Don't fetch full content for preview
        }
      }
    }
  })
}
```

**Bad**:
```typescript
// ❌ Fetching all fields including sensitive data
async function getUserPreview(id: string) {
  return prisma.user.findUnique({
    where: { id }
    // ❌ Returns all fields: password, internal IDs, etc.
  })
}

// ❌ Over-fetching relations
async function getUsers() {
  return prisma.user.findMany({
    include: {
      posts: true, // ❌ ALL posts for EVERY user
      comments: true, // ❌ ALL comments for EVERY user
      likes: true, // ❌ ALL likes for EVERY user
      // Potential N+1 problem and memory issues
    }
  })
}
```

**Why**: Selecting only needed fields reduces data transfer, improves query performance, prevents exposing sensitive data, and reduces memory usage. Over-fetching can cause performance issues and security problems.

---

### Pattern 3: Transactions for Data Integrity

**When**: Multiple related database operations that must succeed or fail together

**Good**:
```typescript
// ✅ Transaction for related operations
async function transferFunds(fromId: string, toId: string, amount: number) {
  return await prisma.$transaction(async (tx) => {
    // Deduct from sender
    const sender = await tx.account.update({
      where: { id: fromId },
      data: { balance: { decrement: amount } }
    })

    // Verify sender has sufficient balance
    if (sender.balance < 0) {
      throw new Error('Insufficient funds')
    }

    // Add to recipient
    const recipient = await tx.account.update({
      where: { id: toId },
      data: { balance: { increment: amount } }
    })

    // Log transaction
    await tx.transaction.create({
      data: {
        fromId,
        toId,
        amount,
        type: 'transfer'
      }
    })

    return { sender, recipient }
  })
  // ✅ All operations succeed or all rollback
}

// ✅ Array-based transaction for simple cases
async function createUserWithProfile(email: string, name: string) {
  const [user, profile] = await prisma.$transaction([
    prisma.user.create({ data: { email } }),
    prisma.profile.create({ data: { name } })
  ])

  return { user, profile }
}
```

**Bad**:
```typescript
// ❌ No transaction - data integrity risk
async function transferFunds(fromId: string, toId: string, amount: number) {
  // ❌ Separate operations, not atomic
  await prisma.account.update({
    where: { id: fromId },
    data: { balance: { decrement: amount } }
  })

  // ❌ If this fails, sender already lost money!
  await prisma.account.update({
    where: { id: toId },
    data: { balance: { increment: amount } }
  })

  // ❌ If this fails, money disappeared!
  await prisma.transaction.create({
    data: { fromId, toId, amount }
  })
}
```

**Why**: Transactions ensure atomicity - all operations succeed or all fail. Without transactions, partial failures can corrupt data, lose money, or create inconsistent state.

---

### Pattern 4: Proper Indexing in Schema

**When**: Designing Prisma schema

**Good**:
```prisma
// ✅ Indexes for frequently queried fields
model User {
  id        String   @id @default(cuid())
  email     String   @unique // ✅ Automatic index
  name      String
  role      String
  createdAt DateTime @default(now())

  posts     Post[]

  // ✅ Composite index for common queries
  @@index([role, createdAt])
  // ✅ Index for foreign key queries
  @@index([email, role])
}

model Post {
  id          String   @id @default(cuid())
  title       String
  content     String
  published   Boolean  @default(false)
  authorId    String
  categoryId  String
  createdAt   DateTime @default(now())

  author      User     @relation(fields: [authorId], references: [id])

  // ✅ Index on foreign key
  @@index([authorId])
  // ✅ Composite index for common filter
  @@index([published, createdAt])
  // ✅ Index for category filtering
  @@index([categoryId, published])
}
```

**Bad**:
```prisma
// ❌ No indexes on frequently queried fields
model User {
  id        String   @id @default(cuid())
  email     String   // ❌ No unique constraint or index
  name      String
  role      String   // ❌ Filtered often but no index
  createdAt DateTime @default(now())

  posts     Post[]
}

model Post {
  id          String   @id @default(cuid())
  title       String
  content     String
  published   Boolean  @default(false)
  authorId    String   // ❌ No index on foreign key
  categoryId  String   // ❌ No index
  createdAt   DateTime @default(now())

  author      User     @relation(fields: [authorId], references: [id])
  // ❌ Queries like WHERE published = true ORDER BY createdAt are slow
}
```

**Why**: Proper indexing dramatically improves query performance, especially for filtering, sorting, and joins. Missing indexes cause full table scans, slow queries, and poor scalability.

---

## Anti-Patterns

### ❌ Anti-Pattern 1: N+1 Query Problem

**Don't do this**:
```typescript
// ❌ N+1 queries - fetches users then posts separately
async function getUsersWithPostCounts() {
  const users = await prisma.user.findMany()

  // ❌ Loop makes separate query for each user
  const usersWithCounts = await Promise.all(
    users.map(async (user) => {
      const postCount = await prisma.post.count({
        where: { authorId: user.id }
      })
      return { ...user, postCount }
    })
  )

  return usersWithCounts
  // 1 query for users + N queries for each user's posts = N+1 problem
}
```

**Why it's bad**: Makes N+1 database queries instead of 1-2, extremely slow for large datasets, overwhelms database with connections, scales poorly.

**Do this instead**:
```typescript
// ✅ Single query with aggregation
async function getUsersWithPostCounts() {
  return await prisma.user.findMany({
    select: {
      id: true,
      name: true,
      email: true,
      _count: {
        select: { posts: true }
      }
    }
  })
  // Single query with COUNT aggregation
}

// ✅ Or use groupBy for more complex cases
async function getPostCountsByUser() {
  return await prisma.post.groupBy({
    by: ['authorId'],
    _count: {
      id: true
    }
  })
}
```

---

### ❌ Anti-Pattern 2: Not Using TypeScript Generated Types

**Don't do this**:
```typescript
// ❌ Using any loses type safety
async function getUser(id: string): Promise<any> {
  return await prisma.user.findUnique({
    where: { id }
  })
}

// ❌ No type safety on returned data
const user = await getUser('123')
console.log(user.emial) // ❌ Typo not caught - runtime error

// ❌ Manual type definitions that get out of sync
interface User {
  id: string
  name: string
  email: string
  // ❌ Schema changes won't update this
}
```

**Why it's bad**: Loses Prisma's main benefit (type safety), allows typos and bugs, types get out of sync with schema, no autocomplete.

**Do this instead**:
```typescript
// ✅ Use Prisma generated types
import { User } from '@prisma/client'

async function getUser(id: string): Promise<User | null> {
  return await prisma.user.findUnique({
    where: { id }
  })
}

// ✅ Type safety and autocomplete
const user = await getUser('123')
if (user) {
  console.log(user.email) // ✅ Autocomplete and type-safe
  // console.log(user.emial) // ✅ TypeScript error
}

// ✅ Use Prisma types for custom queries
import { Prisma } from '@prisma/client'

type UserWithPosts = Prisma.UserGetPayload<{
  include: { posts: true }
}>

async function getUserWithPosts(id: string): Promise<UserWithPosts | null> {
  return await prisma.user.findUnique({
    where: { id },
    include: { posts: true }
  })
}
```

---

### ❌ Anti-Pattern 3: Ignoring Connection Pool Limits

**Don't do this**:
```typescript
// ❌ Creating new client for every request
export async function GET(request: Request) {
  const prisma = new PrismaClient() // ❌ New instance every request

  const users = await prisma.user.findMany()

  return Response.json(users)
  // ❌ Client not disconnected, connection leak
}

// ❌ No connection limit configuration
// DATABASE_URL="postgresql://user:pass@localhost:5432/db"
// ❌ Using default limits with serverless
```

**Why it's bad**: Exhausts database connections, causes "too many connections" errors, slows down application, crashes in high traffic.

**Do this instead**:
```typescript
// ✅ Use singleton client (as shown in Pattern 1)
import { prisma } from '@/lib/prisma'

export async function GET(request: Request) {
  const users = await prisma.user.findMany()
  return Response.json(users)
  // ✅ Reuses existing client and connection pool
}

// ✅ Configure connection pool for serverless
// DATABASE_URL="postgresql://user:pass@localhost:5432/db?connection_limit=5&pool_timeout=20"

// ✅ Or use Prisma connection pooling
// lib/prisma.ts
export const prisma = new PrismaClient({
  datasources: {
    db: {
      url: process.env.DATABASE_URL,
    },
  },
}).$extends({
  // Add connection management
})

// ✅ Use Prisma Data Proxy for serverless
// DATABASE_URL="prisma://aws-us-east-1.prisma-data.com/?api_key=xxx"
```

---

### ❌ Anti-Pattern 4: Raw SQL for Everything

**Don't do this**:
```typescript
// ❌ Using raw SQL when Prisma query would work
async function getPublishedPosts() {
  return await prisma.$queryRaw`
    SELECT * FROM "Post" WHERE published = true
  `
  // ❌ No type safety, SQL injection risk, loses Prisma benefits
}

// ❌ Complex raw query that's hard to maintain
async function getUserStats(userId: string) {
  return await prisma.$queryRaw`
    SELECT
      u.id,
      u.name,
      COUNT(DISTINCT p.id) as post_count,
      COUNT(DISTINCT c.id) as comment_count,
      AVG(p.likes) as avg_likes
    FROM "User" u
    LEFT JOIN "Post" p ON u.id = p.authorId
    LEFT JOIN "Comment" c ON u.id = c.authorId
    WHERE u.id = ${userId}
    GROUP BY u.id, u.name
  `
  // ❌ Difficult to maintain, no type safety
}
```

**Why it's bad**: Loses type safety, prone to SQL injection, no autocomplete, harder to maintain, database-specific syntax, breaks with schema changes.

**Do this instead**:
```typescript
// ✅ Use Prisma query builder
async function getPublishedPosts() {
  return await prisma.post.findMany({
    where: { published: true }
  })
  // ✅ Type-safe, database-agnostic
}

// ✅ Use Prisma's aggregation features
async function getUserStats(userId: string) {
  const [user, postCount, commentCount, avgLikes] = await Promise.all([
    prisma.user.findUnique({
      where: { id: userId },
      select: { id: true, name: true }
    }),
    prisma.post.count({
      where: { authorId: userId }
    }),
    prisma.comment.count({
      where: { authorId: userId }
    }),
    prisma.post.aggregate({
      where: { authorId: userId },
      _avg: { likes: true }
    })
  ])

  return {
    ...user,
    postCount,
    commentCount,
    avgLikes: avgLikes._avg.likes
  }
  // ✅ Type-safe and maintainable
}

// ✅ Use raw SQL only when truly necessary
// (e.g., database-specific features, extreme performance needs)
async function complexAnalytics() {
  return await prisma.$queryRaw<AnalyticsResult[]>`
    WITH RECURSIVE ... /* Complex CTE that Prisma can't express */
  `
  // ✅ But add type safety with generics
}
```

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
