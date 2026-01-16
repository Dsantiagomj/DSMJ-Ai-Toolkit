# Client Usage - tRPC

## Setup

```typescript
import { createTRPCClient, httpBatchLink } from '@trpc/client';
import { type AppRouter } from '@/server/api/root';
import superjson from 'superjson';

export const api = createTRPCClient<AppRouter>({
  links: [
    httpBatchLink({
      url: '/api/trpc',
      transformer: superjson,
    }),
  ],
});
```

## Optimistic Updates

```typescript
const utils = api.useUtils();

const deleteMutation = api.post.delete.useMutation({
  onMutate: async ({ id }) => {
    await utils.post.getAll.cancel();
    const previousPosts = utils.post.getAll.getData();
    
    utils.post.getAll.setData(undefined, old =>
      old?.filter(post => post.id !== id)
    );
    
    return { previousPosts };
  },
  onError: (err, variables, context) => {
    if (context?.previousPosts) {
      utils.post.getAll.setData(undefined, context.previousPosts);
    }
  },
  onSettled: () => {
    utils.post.getAll.invalidate();
  },
});
```

## Server-Side Caller

```typescript
import { createCaller } from '@/server/api/root';

export default async function PostPage({ params }: { params: { id: string } }) {
  const ctx = await createTRPCContext({ headers: new Headers() });
  const caller = createCaller(ctx);
  
  const post = await caller.post.getById({ id: params.id });
  
  return <div>{post.title}</div>;
}
```
