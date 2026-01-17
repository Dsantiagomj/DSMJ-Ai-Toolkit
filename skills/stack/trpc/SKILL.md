---
name: trpc
domain: backend
description: >
  Type-safe APIs with tRPC - End-to-end typesafe APIs without code generation. Covers routers, procedures, context, middleware, and React Query integration.
  Trigger: When creating tRPC routers, when implementing procedures, when setting up API endpoints, when using tRPC with React Query.
version: 1.0.0
tags: [trpc, api, typescript, type-safety, react-query, next.js]
metadata:
  version: "1.0"
  last_updated: "2026-01-17"
  category: stack
references:
  - name: tRPC Official Documentation
    url: https://trpc.io/docs
    type: documentation
  - name: tRPC GitHub
    url: https://github.com/trpc/trpc
    type: repository
  - name: Routers & Procedures
    url: ./references/routers.md
    type: local
  - name: Client Usage
    url: ./references/client.md
    type: local
---

# tRPC - End-to-End Type Safety

**Build fully typesafe APIs without schemas or code generation**

---

## When to Use

Use tRPC when you need:
- **Full-stack TypeScript** - Both frontend and backend in TypeScript
- **Type safety** - Compile-time checks for API contracts
- **Monorepo setup** - Shared code between client and server
- **React Query integration** - Built-in caching and state management
- **Rapid development** - No need to maintain OpenAPI specs or generate clients

Choose alternatives when:
- Building public APIs (use REST or GraphQL with OpenAPI)
- Multiple client platforms (mobile, non-TypeScript clients)
- Team uses different languages for frontend/backend
- Need GraphQL features (complex queries, subscriptions, federation)

---

## Critical Patterns

### Pattern 1: Proper Router Organization

```typescript
// ✅ Good: Organized by feature/domain
// server/api/routers/post.ts
export const postRouter = createTRPCRouter({
  getAll: publicProcedure.query(async ({ ctx }) => {
    return ctx.db.post.findMany();
  }),
  
  getById: publicProcedure
    .input(z.object({ id: z.string() }))
    .query(async ({ ctx, input }) => {
      return ctx.db.post.findUnique({ where: { id: input.id } });
    }),
    
  create: protectedProcedure
    .input(z.object({
      title: z.string().min(1),
      content: z.string(),
    }))
    .mutation(async ({ ctx, input }) => {
      return ctx.db.post.create({
        data: { ...input, authorId: ctx.session.user.id },
      });
    }),
});

// server/api/root.ts
export const appRouter = createTRPCRouter({
  post: postRouter,
  user: userRouter,
  comment: commentRouter,
});

// ❌ Bad: Everything in one router
export const appRouter = createTRPCRouter({
  getAllPosts: publicProcedure.query(/* ... */),
  getPostById: publicProcedure.input(/* ... */).query(/* ... */),
  createPost: protectedProcedure.input(/* ... */).mutation(/* ... */),
  getAllUsers: publicProcedure.query(/* ... */),
  getUserById: publicProcedure.input(/* ... */).query(/* ... */),
  // Hundreds of procedures...
});
```

**Why**: Feature-based routers improve maintainability, enable code splitting, and make the API easier to navigate.

---

### Pattern 2: Context for Shared Data

```typescript
// ✅ Good: Create context with session and shared resources
export const createTRPCContext = async (opts: { headers: Headers }) => {
  const session = await getServerAuthSession();
  
  return {
    session,
    db: prisma,
    redis: redisClient,
  };
};

export type Context = Awaited<ReturnType<typeof createTRPCContext>>;

// Use context in procedures
export const protectedProcedure = t.procedure
  .use(async ({ ctx, next }) => {
    if (!ctx.session?.user) {
      throw new TRPCError({ code: 'UNAUTHORIZED' });
    }
    return next({
      ctx: {
        session: { ...ctx.session, user: ctx.session.user },
      },
    });
  });

// ❌ Bad: Recreating connections in every procedure
export const getUser = publicProcedure
  .input(z.object({ id: z.string() }))
  .query(async ({ input }) => {
    const db = new PrismaClient(); // Creates new connection!
    const session = await getServerAuthSession(); // Fetches session every time!
    return db.user.findUnique({ where: { id: input.id } });
  });
```

**Why**: Context provides shared resources once per request, improving performance and reducing code duplication.

---

### Pattern 3: Input Validation with Zod

```typescript
// ✅ Good: Comprehensive validation with Zod
export const createPost = protectedProcedure
  .input(
    z.object({
      title: z.string().min(1, 'Title required').max(100, 'Title too long'),
      content: z.string().min(1, 'Content required'),
      tags: z.array(z.string()).max(10, 'Max 10 tags'),
      published: z.boolean().default(false),
      publishAt: z.date().optional(),
    })
    .refine(
      (data) => {
        if (data.published && !data.publishAt) return false;
        return true;
      },
      { message: 'publishAt required when published is true' }
    )
  )
  .mutation(async ({ ctx, input }) => {
    return ctx.db.post.create({ data: input });
  });

// ❌ Bad: No validation, runtime errors
export const createPost = protectedProcedure
  .mutation(async ({ ctx, input }: any) => {
    // input could be anything!
    return ctx.db.post.create({ data: input });
  });

// ❌ Bad: Manual validation, loses type safety
export const createPost = protectedProcedure
  .mutation(async ({ ctx, input }: { input: any }) => {
    if (!input.title || typeof input.title !== 'string') {
      throw new Error('Invalid title');
    }
    // Tedious and error-prone
  });
```

**Why**: Zod provides runtime validation, type inference, and clear error messages automatically.

---

### Pattern 4: Middleware for Reusable Logic

```typescript
// ✅ Good: Reusable middleware for auth, logging, rate limiting
const enforceUserAuth = t.middleware(async ({ ctx, next }) => {
  if (!ctx.session?.user) {
    throw new TRPCError({ code: 'UNAUTHORIZED' });
  }

  return next({
    ctx: {
      session: { ...ctx.session, user: ctx.session.user },
    },
  });
});

const logProcedure = t.middleware(async ({ path, type, next }) => {
  const start = Date.now();
  const result = await next();
  const duration = Date.now() - start;
  
  console.log(`${type} ${path} - ${duration}ms`);
  return result;
});

export const protectedProcedure = t.procedure
  .use(logProcedure)
  .use(enforceUserAuth);

// ❌ Bad: Duplicate auth logic in every procedure
export const deletePost = publicProcedure
  .input(z.object({ id: z.string() }))
  .mutation(async ({ ctx, input }) => {
    if (!ctx.session?.user) {
      throw new TRPCError({ code: 'UNAUTHORIZED' });
    }
    // Delete logic
  });

export const updatePost = publicProcedure
  .input(z.object({ id: z.string(), title: z.string() }))
  .mutation(async ({ ctx, input }) => {
    if (!ctx.session?.user) {
      throw new TRPCError({ code: 'UNAUTHORIZED' });
    }
    // Update logic
  });
```

**Why**: Middleware centralizes cross-cutting concerns, reduces duplication, and improves type safety.

---

### Pattern 5: Client-Side Optimistic Updates

For optimistic updates with rollback, see [references/client.md](./references/client.md).

---

## Anti-Patterns

### Anti-Pattern 1: Using Any for Input/Context

```typescript
// ❌ Problem: Losing type safety
export const getUser = publicProcedure
  .query(async ({ ctx, input }: any) => {
    return ctx.db.user.findUnique({ where: { id: input.id } });
  });
```

**Why it's wrong**: Defeats the entire purpose of tRPC; loses compile-time safety; runtime errors.

**Solution**:
```typescript
// ✅ Always use typed inputs and context
export const getUser = publicProcedure
  .input(z.object({ id: z.string() }))
  .query(async ({ ctx, input }) => {
    // ctx and input are fully typed
    return ctx.db.user.findUnique({ where: { id: input.id } });
  });
```

---

### Anti-Pattern 2: Not Using Procedures Composition

```typescript
// ❌ Problem: Duplicate middleware/auth logic
export const deletePost = publicProcedure
  .use(enforceAuth)
  .use(rateLimit)
  .mutation(/* ... */);

export const updatePost = publicProcedure
  .use(enforceAuth)
  .use(rateLimit)
  .mutation(/* ... */);

export const createPost = publicProcedure
  .use(enforceAuth)
  .use(rateLimit)
  .mutation(/* ... */);
```

**Why it's wrong**: Tedious, error-prone (easy to forget middleware), hard to maintain.

**Solution**:
```typescript
// ✅ Create composed procedures
export const protectedProcedure = t.procedure
  .use(enforceAuth)
  .use(rateLimit);

export const deletePost = protectedProcedure.mutation(/* ... */);
export const updatePost = protectedProcedure.mutation(/* ... */);
export const createPost = protectedProcedure.mutation(/* ... */);
```

---

### Anti-Pattern 3: Over-fetching with getAll

```typescript
// ❌ Problem: Fetching all data without pagination
export const postRouter = createTRPCRouter({
  getAll: publicProcedure.query(async ({ ctx }) => {
    return ctx.db.post.findMany(); // Could be thousands!
  }),
});

// ✅ Solution: Server-side filtering and pagination
export const postRouter = createTRPCRouter({
  getAll: publicProcedure
    .input(z.object({
      limit: z.number().min(1).max(100).default(10),
      published: z.boolean().optional(),
    }))
    .query(async ({ ctx, input }) => {
      return ctx.db.post.findMany({
        take: input.limit,
        where: { published: input.published },
      });
    }),
});
```

---

### Anti-Pattern 4: Not Handling Errors Properly

```typescript
// ❌ Generic errors
throw new Error('Failed');

// ✅ Use TRPCError with specific codes
import { TRPCError } from '@trpc/server';
throw new TRPCError({
  code: 'FORBIDDEN',
  message: 'You do not have permission',
});
```

For detailed error handling patterns, see [references/routers.md](./references/routers.md).

---

For more anti-patterns (calling procedures from procedures, query invalidation, error handling), see [references/client.md](./references/client.md).

---

## What This Skill Covers

- **Router** creation and organization
- **Procedures** (queries and mutations)
- **Context** for shared data
- **Middleware** for reusable logic
- **React Query integration**

For advanced patterns and full examples, see [references/](./references/).

---

## Basic Router

```typescript
import { z } from 'zod';
import { createTRPCRouter, publicProcedure } from '../trpc';

export const postRouter = createTRPCRouter({
  // Query: Get all posts
  getAll: publicProcedure
    .query(async ({ ctx }) => {
      return ctx.db.post.findMany({
        orderBy: { createdAt: 'desc' },
      });
    }),

  // Query with input
  getById: publicProcedure
    .input(z.object({ id: z.string() }))
    .query(async ({ ctx, input }) => {
      return ctx.db.post.findUnique({
        where: { id: input.id },
      });
    }),

  // Mutation
  create: publicProcedure
    .input(z.object({
      title: z.string().min(1).max(100),
      content: z.string().min(1),
    }))
    .mutation(async ({ ctx, input }) => {
      return ctx.db.post.create({
        data: input,
      });
    }),
});
```

---

## Context

```typescript
export const createTRPCContext = async (opts: { headers: Headers }) => {
  const session = await getServerAuthSession();
  
  return {
    session,
    db,
  };
};

export type Context = Awaited<ReturnType<typeof createTRPCContext>>;
```

---

## Client Usage

```typescript
'use client';

import { api } from '@/lib/api';

export function PostList() {
  // Query
  const { data: posts, isLoading } = api.post.getAll.useQuery();

  // Mutation
  const createPost = api.post.create.useMutation({
    onSuccess: () => {
      utils.post.getAll.invalidate();
    },
  });

  return (
    <div>
      {posts?.map(post => (
        <div key={post.id}>{post.title}</div>
      ))}
    </div>
  );
}
```

See [client.md](./references/client.md) for optimistic updates and advanced patterns.

---

## Quick Reference

```typescript
// Define router
export const router = createTRPCRouter({
  getAll: publicProcedure.query(() => [...]),
  getById: publicProcedure
    .input(z.object({ id: z.string() }))
    .query(({ input }) => ({ id: input.id })),
  create: publicProcedure
    .input(z.object({ name: z.string() }))
    .mutation(({ input }) => ({ name: input.name })),
});

// Use in React
const { data } = api.router.getAll.useQuery();
const mutation = api.router.create.useMutation();
```

---

## Learn More

- **Routers & Procedures**: [references/routers.md](./references/routers.md) - Protected procedures, middleware, error handling
- **Client Usage**: [references/client.md](./references/client.md) - React Query integration, optimistic updates

---

## External References

- [tRPC Official Documentation](https://trpc.io/docs)
- [tRPC GitHub](https://github.com/trpc/trpc)

---

_Maintained by dsmj-ai-toolkit_
