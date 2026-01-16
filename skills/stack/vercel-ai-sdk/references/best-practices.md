# Best Practices - Vercel AI SDK

## Security

### Input Validation

```typescript
// ✅ Good: Validate user input
const { messages } = await req.json();

if (!Array.isArray(messages)) {
  return new Response('Invalid messages', { status: 400 });
}
```

### Rate Limiting

```typescript
// ✅ Good: Rate limiting
import { Ratelimit } from '@upstash/ratelimit';

const ratelimit = new Ratelimit({
  redis: Redis.fromEnv(),
  limiter: Ratelimit.slidingWindow(10, '1 m'),
});

const { success } = await ratelimit.limit(userId);
if (!success) {
  return new Response('Rate limit exceeded', { status: 429 });
}
```

### Authentication

```typescript
// ✅ Good: Authentication
const session = await getServerSession();
if (!session) {
  return new Response('Unauthorized', { status: 401 });
}
```

---

## Cost Optimization

### Set Max Tokens

```typescript
// ✅ Good: Set max tokens
const result = streamText({
  model: openai('gpt-4-turbo'),
  messages,
  maxTokens: 500, // Limit response length
});
```

### Use Cheaper Models

```typescript
// ✅ Good: Use cheaper models when appropriate
const result = streamText({
  model: openai('gpt-3.5-turbo'), // Cheaper for simple tasks
  messages,
});
```

---

## Error Recovery

### Retry Logic

```typescript
// ✅ Good: Implement retry logic
const { reload, error } = useChat({
  api: '/api/chat',
  onError: (error) => {
    if (error.message.includes('rate limit')) {
      setTimeout(reload, 5000); // Retry after 5s
    }
  },
});
```

---

## Performance

### Optimize Streaming

```typescript
// ✅ Good: Use edge runtime for lower latency
export const runtime = 'edge';

export async function POST(req: Request) {
  const result = streamText({
    model: openai('gpt-4-turbo'),
    messages: await req.json().then(d => d.messages),
  });

  return result.toDataStreamResponse();
}
```

### Reduce Re-renders

```typescript
// ✅ Good: Memoize callbacks
const onFinish = useCallback((message) => {
  console.log('Finished:', message);
}, []);

const { messages } = useChat({
  api: '/api/chat',
  onFinish,
});
```
