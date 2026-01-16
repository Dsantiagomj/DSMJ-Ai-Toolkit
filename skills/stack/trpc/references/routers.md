# Routers & Procedures - tRPC

## Protected Procedures

```typescript
const protectedProcedure = publicProcedure.use(async ({ ctx, next }) => {
  if (!ctx.session?.user) {
    throw new TRPCError({ code: 'UNAUTHORIZED' });
  }
  
  return next({
    ctx: {
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

## Middleware

```typescript
const loggingMiddleware = t.middleware(async ({ path, type, next }) => {
  const start = Date.now();
  const result = await next();
  const durationMs = Date.now() - start;
  
  console.log({ path, type, durationMs, ok: result.ok });
  return result;
});

const loggedProcedure = publicProcedure.use(loggingMiddleware);
```

## Error Handling

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
