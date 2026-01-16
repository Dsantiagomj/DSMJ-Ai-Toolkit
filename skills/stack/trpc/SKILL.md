---
name: trpc
domain: backend
description: Type-safe APIs with tRPC - End-to-end typesafe APIs without code generation. Covers routers, procedures, context, middleware, and React Query integration.
version: 1.0.0
tags: [trpc, api, typescript, type-safety, react-query, next.js]
references:
  - name: tRPC Official Documentation
    url: https://trpc.io/docs
    type: documentation
  - name: tRPC GitHub
    url: https://github.com/trpc/trpc
    type: repository
---

# tRPC - End-to-End Type Safety

**Build fully typesafe APIs without schemas or code generation**

---

## What This Skill Covers

This skill provides guidance on:
- **Router** creation and organization
- **Procedures** (queries and mutations)
- **Context** for shared data (auth, database)
- **Middleware** for reusable logic
- **React Query integration** for client-side
- **Input validation** with Zod
- **Error handling** and custom errors

---

## Basic Setup

### Server Router

```typescript
// server/api/routers/post.ts
import { z } from 'zod';
import { createTRPCRouter, publicProcedure, protectedProcedure } from '../trpc';

export const postRouter = createTRPCRouter({
  // Query: Get all posts
  getAll: publicProcedure
    .query(async ({ ctx }) => {
      return ctx.db.post.findMany({
        orderBy: { createdAt: 'desc' },
      });
    }),

  // Query with input: Get post by ID
  getById: publicProcedure
    .input(z.object({ id: z.string() }))
    .query(async ({ ctx, input }) => {
      return ctx.db.post.findUnique({
        where: { id: input.id },
      });
    }),

  // Mutation: Create post (protected)
  create: protectedProcedure
    .input(z.object({
      title: z.string().min(1).max(100),
      content: z.string().min(1),
    }))
    .mutation(async ({ ctx, input }) => {
      return ctx.db.post.create({
        data: {
          title: input.title,
          content: input.content,
          authorId: ctx.session.user.id,
        },
      });
    }),

  // Mutation: Delete post
  delete: protectedProcedure
    .input(z.object({ id: z.string() }))
    .mutation(async ({ ctx, input }) => {
      // Check ownership
      const post = await ctx.db.post.findUnique({
        where: { id: input.id },
      });

      if (post?.authorId !== ctx.session.user.id) {
        throw new TRPCError({
          code: 'FORBIDDEN',
          message: 'You can only delete your own posts',
        });
      }

      return ctx.db.post.delete({
        where: { id: input.id },
      });
    }),
});
```

### Root Router

```typescript
// server/api/root.ts
import { createCallerFactory, createTRPCRouter } from './trpc';
import { postRouter } from './routers/post';
import { userRouter } from './routers/user';

export const appRouter = createTRPCRouter({
  post: postRouter,
  user: userRouter,
});

// Export type definition
export type AppRouter = typeof appRouter;

// Create caller factory
export const createCaller = createCallerFactory(appRouter);
```

---

## Context

Context provides shared data to all procedures:

```typescript
// server/api/trpc.ts
import { type Session } from 'next-auth';
import { db } from '@/server/db';

interface CreateContextOptions {
  session: Session | null;
}

export const createTRPCContext = async (opts: {
  headers: Headers;
}) => {
  const session = await getServerAuthSession();

  return {
    session,
    db,
  };
};

export type Context = Awaited<ReturnType<typeof createTRPCContext>>;
```

---

## Procedures

### Public Procedure

```typescript
import { createTRPCRouter, publicProcedure } from '../trpc';

export const exampleRouter = createTRPCRouter({
  hello: publicProcedure
    .input(z.object({ name: z.string().optional() }))
    .query(({ input }) => {
      return {
        greeting: `Hello ${input.name ?? 'World'}!`,
      };
    }),
});
```

### Protected Procedure

```typescript
import { TRPCError } from '@trpc/server';

const protectedProcedure = publicProcedure.use(async ({ ctx, next }) => {
  if (!ctx.session?.user) {
    throw new TRPCError({ code: 'UNAUTHORIZED' });
  }

  return next({
    ctx: {
      // Infer session is non-nullable
      session: { ...ctx.session, user: ctx.session.user },
    },
  });
});

export const userRouter = createTRPCRouter({
  getProfile: protectedProcedure
    .query(async ({ ctx }) => {
      return ctx.db.user.findUnique({
        where: { id: ctx.session.user.id },
      });
    }),
});
```

---

## Middleware

### Logging Middleware

```typescript
const loggingMiddleware = t.middleware(async ({ path, type, next }) => {
  const start = Date.now();

  const result = await next();

  const durationMs = Date.now() - start;
  const meta = { path, type, durationMs };

  result.ok
    ? console.log('OK request', meta)
    : console.error('Non-OK request', meta);

  return result;
});

const loggedProcedure = publicProcedure.use(loggingMiddleware);
```

### Rate Limiting Middleware

```typescript
import { Ratelimit } from '@upstash/ratelimit';
import { Redis } from '@upstash/redis';

const ratelimit = new Ratelimit({
  redis: Redis.fromEnv(),
  limiter: Ratelimit.slidingWindow(10, '10 s'),
});

const rateLimitMiddleware = t.middleware(async ({ ctx, next }) => {
  const identifier = ctx.session?.user?.id ?? 'anonymous';

  const { success } = await ratelimit.limit(identifier);

  if (!success) {
    throw new TRPCError({
      code: 'TOO_MANY_REQUESTS',
      message: 'Rate limit exceeded',
    });
  }

  return next();
});

const rateLimitedProcedure = publicProcedure.use(rateLimitMiddleware);
```

---

## Input Validation with Zod

```typescript
import { z } from 'zod';

export const userRouter = createTRPCRouter({
  update: protectedProcedure
    .input(z.object({
      name: z.string().min(2).max(50).optional(),
      bio: z.string().max(500).optional(),
      email: z.string().email().optional(),
    }))
    .mutation(async ({ ctx, input }) => {
      return ctx.db.user.update({
        where: { id: ctx.session.user.id },
        data: input,
      });
    }),

  // Nested validation
  createAddress: protectedProcedure
    .input(z.object({
      address: z.object({
        street: z.string(),
        city: z.string(),
        zipCode: z.string().regex(/^\d{5}$/),
        country: z.enum(['US', 'CA', 'MX']),
      }),
    }))
    .mutation(async ({ ctx, input }) => {
      return ctx.db.address.create({
        data: {
          ...input.address,
          userId: ctx.session.user.id,
        },
      });
    }),

  // Array validation
  addTags: protectedProcedure
    .input(z.object({
      postId: z.string(),
      tags: z.array(z.string()).min(1).max(10),
    }))
    .mutation(async ({ ctx, input }) => {
      return ctx.db.post.update({
        where: { id: input.postId },
        data: {
          tags: { push: input.tags },
        },
      });
    }),
});
```

---

## Client Usage (React Query Integration)

### Setup Client

```typescript
// lib/api.ts
import { createTRPCClient, httpBatchLink } from '@trpc/client';
import { type AppRouter } from '@/server/api/root';
import superjson from 'superjson';

function getBaseUrl() {
  if (typeof window !== 'undefined') return '';
  if (process.env.VERCEL_URL) return `https://${process.env.VERCEL_URL}`;
  return `http://localhost:${process.env.PORT ?? 3000}`;
}

export const api = createTRPCClient<AppRouter>({
  links: [
    httpBatchLink({
      url: `${getBaseUrl()}/api/trpc`,
      transformer: superjson,
    }),
  ],
});
```

### React Hooks

```typescript
'use client';

import { api } from '@/lib/api';

export function PostList() {
  // Query
  const { data: posts, isLoading } = api.post.getAll.useQuery();

  // Mutation
  const createPost = api.post.create.useMutation({
    onSuccess: () => {
      // Invalidate and refetch
      utils.post.getAll.invalidate();
    },
  });

  const handleCreate = () => {
    createPost.mutate({
      title: 'New Post',
      content: 'Post content...',
    });
  };

  if (isLoading) return <div>Loading...</div>;

  return (
    <div>
      {posts?.map(post => (
        <PostCard key={post.id} post={post} />
      ))}
      <button onClick={handleCreate}>Create Post</button>
    </div>
  );
}
```

### Query with Input

```typescript
function Post({ id }: { id: string }) {
  const { data: post } = api.post.getById.useQuery({ id });

  return <div>{post?.title}</div>;
}
```

### Optimistic Updates

```typescript
const utils = api.useUtils();

const deleteMutation = api.post.delete.useMutation({
  onMutate: async ({ id }) => {
    // Cancel outgoing fetches
    await utils.post.getAll.cancel();

    // Snapshot previous value
    const previousPosts = utils.post.getAll.getData();

    // Optimistically update
    utils.post.getAll.setData(undefined, old =>
      old?.filter(post => post.id !== id)
    );

    return { previousPosts };
  },
  onError: (err, variables, context) => {
    // Rollback on error
    if (context?.previousPosts) {
      utils.post.getAll.setData(undefined, context.previousPosts);
    }
  },
  onSettled: () => {
    // Refetch after error or success
    utils.post.getAll.invalidate();
  },
});
```

---

## Error Handling

### Custom Errors

```typescript
import { TRPCError } from '@trpc/server';

export const postRouter = createTRPCRouter({
  getById: publicProcedure
    .input(z.object({ id: z.string() }))
    .query(async ({ ctx, input }) => {
      const post = await ctx.db.post.findUnique({
        where: { id: input.id },
      });

      if (!post) {
        throw new TRPCError({
          code: 'NOT_FOUND',
          message: `Post with ID ${input.id} not found`,
        });
      }

      return post;
    }),
});
```

### Error Codes

```typescript
// Common tRPC error codes:
'BAD_REQUEST'          // 400
'UNAUTHORIZED'         // 401
'FORBIDDEN'            // 403
'NOT_FOUND'            // 404
'METHOD_NOT_SUPPORTED' // 405
'TIMEOUT'              // 408
'CONFLICT'             // 409
'PRECONDITION_FAILED'  // 412
'PAYLOAD_TOO_LARGE'    // 413
'TOO_MANY_REQUESTS'    // 429
'CLIENT_CLOSED_REQUEST'// 499
'INTERNAL_SERVER_ERROR'// 500
```

### Client Error Handling

```typescript
const createPost = api.post.create.useMutation({
  onError: (error) => {
    if (error.data?.code === 'UNAUTHORIZED') {
      router.push('/login');
    } else if (error.data?.code === 'BAD_REQUEST') {
      toast.error(error.message);
    } else {
      toast.error('Something went wrong');
    }
  },
});
```

---

## Server-Side Caller

```typescript
// Call tRPC from Server Components
import { createCaller } from '@/server/api/root';
import { createTRPCContext } from '@/server/api/trpc';

export default async function PostPage({ params }: { params: { id: string } }) {
  const ctx = await createTRPCContext({ headers: new Headers() });
  const caller = createCaller(ctx);

  const post = await caller.post.getById({ id: params.id });

  return <div>{post.title}</div>;
}
```

---

## Best Practices

### Router Organization

```
server/api/
├── root.ts              # Main router
├── trpc.ts              # tRPC initialization
└── routers/
    ├── post.ts          # Post procedures
    ├── user.ts          # User procedures
    ├── comment.ts       # Comment procedures
    └── admin/
        ├── analytics.ts # Admin analytics
        └── users.ts     # Admin user management
```

### Naming Conventions

```typescript
// ✅ Good: Descriptive names
getAll, getById, getBySlug
create, update, delete
search, filter, paginate

// ❌ Bad: Vague names
get, list, fetch
add, edit, remove
```

### Input Validation

```typescript
// ✅ Good: Validate all inputs
.input(z.object({ id: z.string().uuid() }))

// ❌ Bad: No validation
.input(z.any())
```

### Type Safety

```typescript
// ✅ Good: Explicit types from database
type Post = Awaited<ReturnType<typeof ctx.db.post.findUnique>>;

// ❌ Bad: Loose types
const post: any = await ctx.db.post.findUnique(...);
```

---

## Advanced Patterns

### Subscription (WebSockets)

```typescript
import { observable } from '@trpc/server/observable';

export const chatRouter = createTRPCRouter({
  onMessage: protectedProcedure
    .subscription(() => {
      return observable<Message>((emit) => {
        const onMessage = (message: Message) => {
          emit.next(message);
        };

        eventEmitter.on('message', onMessage);

        return () => {
          eventEmitter.off('message', onMessage);
        };
      });
    }),
});
```

### Batching

```typescript
// Enabled by default with httpBatchLink
// Combines multiple requests into single HTTP call

const [posts, user, comments] = await Promise.all([
  api.post.getAll.query(),
  api.user.getProfile.query(),
  api.comment.getRecent.query(),
]);

// Single HTTP request instead of 3!
```

---

## Quick Reference

```typescript
// Define router
export const router = createTRPCRouter({
  // Query (read)
  getName: publicProcedure.query(() => 'Alice'),

  // Query with input
  getById: publicProcedure
    .input(z.object({ id: z.string() }))
    .query(({ input }) => ({ id: input.id })),

  // Mutation (write)
  create: protectedProcedure
    .input(z.object({ name: z.string() }))
    .mutation(({ input }) => ({ name: input.name })),

  // With middleware
  protected: publicProcedure
    .use(authMiddleware)
    .query(() => 'Protected data'),
});

// Use in React
const { data } = api.router.getName.useQuery();
const mutation = api.router.create.useMutation();
```

---

## References

- [tRPC Official Documentation](https://trpc.io/docs)
- [tRPC GitHub](https://github.com/trpc/trpc)

---

_Maintained by dsmj-ai-toolkit_
