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
---

# Prisma - Next-Generation ORM

**Type-safe database access with auto-generated queries and migrations**

---

## What This Skill Covers

This skill provides guidance on:
- **Prisma Schema** design and relationships
- **Prisma Client** for type-safe queries
- **Migrations** for schema changes
- **Relations** (one-to-one, one-to-many, many-to-many)
- **Queries** (CRUD, filtering, sorting, pagination)
- **Transactions** and batch operations
- **Performance** optimization and best practices

---

## Prisma Schema

### Basic Schema

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
  profile   Profile?
}

model Post {
  id        String   @id @default(cuid())
  title     String
  content   String?
  published Boolean  @default(false)
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  author    User     @relation(fields: [authorId], references: [id], onDelete: Cascade)
  authorId  String

  tags      Tag[]

  @@index([authorId])
  @@index([published])
}

model Profile {
  id     String  @id @default(cuid())
  bio    String?
  avatar String?

  user   User    @relation(fields: [userId], references: [id], onDelete: Cascade)
  userId String  @unique
}

model Tag {
  id    String @id @default(cuid())
  name  String @unique

  posts Post[]
}
```

### Field Types

```prisma
model Example {
  // String types
  string     String        // Text
  optString  String?       // Optional text
  email      String        @unique
  slug       String        @db.VarChar(100)

  // Number types
  int        Int
  bigInt     BigInt
  float      Float
  decimal    Decimal

  // Boolean
  isActive   Boolean       @default(false)

  // DateTime
  createdAt  DateTime      @default(now())
  updatedAt  DateTime      @updatedAt
  publishAt  DateTime?

  // JSON
  metadata   Json?

  // Enums
  role       Role          @default(USER)

  // Arrays (PostgreSQL only)
  tags       String[]
}

enum Role {
  USER
  ADMIN
  MODERATOR
}
```

---

## Relations

### One-to-One

```prisma
model User {
  id      String   @id @default(cuid())
  email   String   @unique
  profile Profile?
}

model Profile {
  id     String @id @default(cuid())
  bio    String?
  user   User   @relation(fields: [userId], references: [id], onDelete: Cascade)
  userId String @unique
}
```

### One-to-Many

```prisma
model User {
  id    String @id @default(cuid())
  posts Post[]
}

model Post {
  id       String @id @default(cuid())
  title    String
  author   User   @relation(fields: [authorId], references: [id])
  authorId String

  @@index([authorId])
}
```

### Many-to-Many (Explicit Join Table)

```prisma
model Post {
  id   String     @id @default(cuid())
  tags PostTag[]
}

model Tag {
  id    String    @id @default(cuid())
  name  String    @unique
  posts PostTag[]
}

model PostTag {
  post      Post     @relation(fields: [postId], references: [id], onDelete: Cascade)
  postId    String
  tag       Tag      @relation(fields: [tagId], references: [id], onDelete: Cascade)
  tagId     String
  assignedAt DateTime @default(now())

  @@id([postId, tagId])
}
```

### Many-to-Many (Implicit)

```prisma
model Post {
  id   String @id @default(cuid())
  tags Tag[]
}

model Tag {
  id    String @id @default(cuid())
  name  String @unique
  posts Post[]
}
```

---

## Prisma Client - Queries

### Setup

```typescript
import { PrismaClient } from '@prisma/client';

// Create singleton instance
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

### Create

```typescript
// Create single record
const user = await prisma.user.create({
  data: {
    email: 'alice@example.com',
    name: 'Alice',
    posts: {
      create: [
        { title: 'First Post', content: 'Hello World' },
        { title: 'Second Post', content: 'TypeScript is great' },
      ],
    },
  },
  include: {
    posts: true,
  },
});

// Create many
const users = await prisma.user.createMany({
  data: [
    { email: 'bob@example.com', name: 'Bob' },
    { email: 'charlie@example.com', name: 'Charlie' },
  ],
  skipDuplicates: true, // Skip records if unique constraint fails
});
```

### Read

```typescript
// Find unique
const user = await prisma.user.findUnique({
  where: { email: 'alice@example.com' },
  include: { posts: true },
});

// Find first
const firstPublishedPost = await prisma.post.findFirst({
  where: { published: true },
  orderBy: { createdAt: 'desc' },
});

// Find many with filters
const posts = await prisma.post.findMany({
  where: {
    published: true,
    author: {
      email: {
        contains: '@example.com',
      },
    },
    OR: [
      { title: { contains: 'TypeScript' } },
      { content: { contains: 'TypeScript' } },
    ],
  },
  include: {
    author: {
      select: {
        name: true,
        email: true,
      },
    },
    tags: true,
  },
  orderBy: {
    createdAt: 'desc',
  },
  take: 10,
  skip: 0,
});

// Count
const count = await prisma.post.count({
  where: { published: true },
});
```

### Update

```typescript
// Update single
const updatedUser = await prisma.user.update({
  where: { id: userId },
  data: {
    name: 'Alice Smith',
    posts: {
      create: { title: 'New Post' },
    },
  },
});

// Update many
const result = await prisma.post.updateMany({
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
const deletedUser = await prisma.user.delete({
  where: { id: userId },
});

// Delete many
const result = await prisma.post.deleteMany({
  where: {
    published: false,
    createdAt: {
      lt: new Date('2023-01-01'),
    },
  },
});
```

---

## Advanced Queries

### Pagination

```typescript
// Offset-based pagination
async function getPosts(page: number, pageSize: number) {
  const posts = await prisma.post.findMany({
    skip: (page - 1) * pageSize,
    take: pageSize,
    orderBy: { createdAt: 'desc' },
  });

  const total = await prisma.post.count();

  return {
    posts,
    pagination: {
      page,
      pageSize,
      total,
      totalPages: Math.ceil(total / pageSize),
    },
  };
}

// Cursor-based pagination
async function getPostsCursor(cursor?: string, limit = 10) {
  const posts = await prisma.post.findMany({
    take: limit,
    ...(cursor && {
      skip: 1,
      cursor: { id: cursor },
    }),
    orderBy: { createdAt: 'desc' },
  });

  return {
    posts,
    nextCursor: posts.length === limit ? posts[posts.length - 1].id : null,
  };
}
```

### Filtering & Sorting

```typescript
// Complex filters
const posts = await prisma.post.findMany({
  where: {
    AND: [
      { published: true },
      {
        OR: [
          { title: { contains: 'TypeScript', mode: 'insensitive' } },
          { content: { contains: 'TypeScript', mode: 'insensitive' } },
        ],
      },
    ],
    author: {
      posts: {
        some: {
          published: true,
        },
      },
    },
    createdAt: {
      gte: new Date('2024-01-01'),
      lte: new Date('2024-12-31'),
    },
  },
  orderBy: [
    { published: 'desc' },
    { createdAt: 'desc' },
  ],
});
```

### Aggregations

```typescript
// Count, sum, avg, min, max
const stats = await prisma.post.aggregate({
  where: { published: true },
  _count: true,
  _avg: { viewCount: true },
  _sum: { viewCount: true },
  _min: { createdAt: true },
  _max: { createdAt: true },
});

// Group by
const userStats = await prisma.post.groupBy({
  by: ['authorId'],
  _count: {
    id: true,
  },
  _avg: {
    viewCount: true,
  },
  where: {
    published: true,
  },
  orderBy: {
    _count: {
      id: 'desc',
    },
  },
});
```

---

## Transactions

### Sequential Operations

```typescript
const result = await prisma.$transaction(async (tx) => {
  // All operations use tx instead of prisma
  const user = await tx.user.create({
    data: { email: 'alice@example.com', name: 'Alice' },
  });

  const post = await tx.post.create({
    data: {
      title: 'First Post',
      authorId: user.id,
    },
  });

  return { user, post };
});
```

### Batch Operations

```typescript
const [deleteResult, createResult] = await prisma.$transaction([
  prisma.post.deleteMany({ where: { published: false } }),
  prisma.user.create({ data: { email: 'new@example.com' } }),
]);
```

### With Error Handling

```typescript
try {
  const result = await prisma.$transaction(
    async (tx) => {
      const user = await tx.user.create({
        data: { email: 'alice@example.com', name: 'Alice' },
      });

      // This will fail if post creation fails
      const post = await tx.post.create({
        data: {
          title: 'Post',
          authorId: user.id,
        },
      });

      return { user, post };
    },
    {
      maxWait: 5000, // Max time to wait for transaction
      timeout: 10000, // Max execution time
    }
  );
} catch (error) {
  // Transaction rolled back
  console.error('Transaction failed:', error);
}
```

---

## Migrations

### Development Workflow

```bash
# Create migration from schema changes
npx prisma migrate dev --name add_user_role

# Reset database (WARNING: deletes all data)
npx prisma migrate reset

# Generate Prisma Client after schema changes
npx prisma generate

# Push schema without creating migration (prototyping)
npx prisma db push
```

### Production Workflow

```bash
# Deploy pending migrations
npx prisma migrate deploy

# Check migration status
npx prisma migrate status
```

### Seed Database

```typescript
// prisma/seed.ts
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  const alice = await prisma.user.upsert({
    where: { email: 'alice@example.com' },
    update: {},
    create: {
      email: 'alice@example.com',
      name: 'Alice',
      posts: {
        create: [
          {
            title: 'First Post',
            content: 'Hello World',
            published: true,
          },
        ],
      },
    },
  });

  console.log({ alice });
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

```json
// package.json
{
  "prisma": {
    "seed": "tsx prisma/seed.ts"
  }
}
```

```bash
# Run seed
npx prisma db seed
```

---

## Best Practices

### Singleton Pattern (Next.js)

```typescript
// lib/prisma.ts
import { PrismaClient } from '@prisma/client';

const prismaClientSingleton = () => {
  return new PrismaClient();
};

declare global {
  var prisma: undefined | ReturnType<typeof prismaClientSingleton>;
}

const prisma = globalThis.prisma ?? prismaClientSingleton();

export default prisma;

if (process.env.NODE_ENV !== 'production') globalThis.prisma = prisma;
```

### Type Safety with Select

```typescript
// ✅ Good: Select only needed fields
const user = await prisma.user.findUnique({
  where: { id: userId },
  select: {
    id: true,
    name: true,
    email: true,
    posts: {
      select: {
        id: true,
        title: true,
      },
    },
  },
});

// Type is automatically inferred:
// { id: string; name: string | null; email: string; posts: { id: string; title: string }[] }
```

### Avoid N+1 Queries

```typescript
// ❌ Bad: N+1 query problem
const users = await prisma.user.findMany();
for (const user of users) {
  const posts = await prisma.post.findMany({
    where: { authorId: user.id },
  });
}

// ✅ Good: Single query with include
const users = await prisma.user.findMany({
  include: {
    posts: true,
  },
});
```

### Input Validation

```typescript
import { z } from 'zod';

const createUserSchema = z.object({
  email: z.string().email(),
  name: z.string().min(2).max(100),
});

async function createUser(input: unknown) {
  const data = createUserSchema.parse(input);

  return prisma.user.create({
    data,
  });
}
```

### Error Handling

```typescript
import { Prisma } from '@prisma/client';

async function createUser(email: string, name: string) {
  try {
    return await prisma.user.create({
      data: { email, name },
    });
  } catch (error) {
    if (error instanceof Prisma.PrismaClientKnownRequestError) {
      // Unique constraint violation
      if (error.code === 'P2002') {
        throw new Error('Email already exists');
      }
      // Foreign key constraint violation
      if (error.code === 'P2003') {
        throw new Error('Referenced record does not exist');
      }
    }
    throw error;
  }
}
```

---

## Performance Optimization

### Indexes

```prisma
model Post {
  id        String   @id @default(cuid())
  title     String
  authorId  String
  published Boolean
  createdAt DateTime

  // Single column indexes
  @@index([authorId])
  @@index([published])

  // Composite index
  @@index([authorId, published])

  // Unique composite
  @@unique([authorId, title])
}
```

### Connection Pooling

```typescript
// For serverless (Next.js, Vercel)
const prisma = new PrismaClient({
  datasources: {
    db: {
      url: process.env.DATABASE_URL + '?connection_limit=1',
    },
  },
});
```

### Query Optimization

```typescript
// ✅ Good: Select only needed fields
const users = await prisma.user.findMany({
  select: {
    id: true,
    email: true,
    _count: {
      select: { posts: true },
    },
  },
});

// ✅ Good: Use cursor pagination for large datasets
const posts = await prisma.post.findMany({
  take: 10,
  cursor: lastPost ? { id: lastPost.id } : undefined,
  skip: lastPost ? 1 : 0,
});
```

---

## Quick Reference

```typescript
// Create
await prisma.user.create({ data: { email: 'user@example.com' } });
await prisma.user.createMany({ data: [...] });

// Read
await prisma.user.findUnique({ where: { id: '...' } });
await prisma.user.findFirst({ where: { ... } });
await prisma.user.findMany({ where: { ... }, take: 10, skip: 0 });
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

// Raw SQL
await prisma.$queryRaw`SELECT * FROM User WHERE email = ${email}`;
await prisma.$executeRaw`UPDATE User SET name = ${name} WHERE id = ${id}`;
```

---

## References

- [Prisma Documentation](https://www.prisma.io/docs)
- [Prisma GitHub](https://github.com/prisma/prisma)

---

_Maintained by dsmj-ai-toolkit_
