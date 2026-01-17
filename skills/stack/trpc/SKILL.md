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
