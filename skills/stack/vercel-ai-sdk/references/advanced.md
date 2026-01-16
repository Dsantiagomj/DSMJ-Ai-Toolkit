# Advanced Patterns - Vercel AI SDK

## Multiple Providers

### OpenAI

```typescript
import { openai } from '@ai-sdk/openai';
import { streamText } from 'ai';

const result = streamText({
  model: openai('gpt-4-turbo'),
  prompt: 'Hello!',
});
```

### Anthropic

```typescript
import { anthropic } from '@ai-sdk/anthropic';

const result = streamText({
  model: anthropic('claude-3-5-sonnet-20241022'),
  prompt: 'Hello!',
});
```

### Custom Provider

```typescript
import { createOpenAI } from '@ai-sdk/openai';

const customProvider = createOpenAI({
  baseURL: 'https://api.your-provider.com/v1',
  apiKey: process.env.CUSTOM_API_KEY,
});

const result = streamText({
  model: customProvider('model-name'),
  prompt: 'Hello!',
});
```

---

## System Messages

```typescript
const result = streamText({
  model: openai('gpt-4-turbo'),
  messages,
  system: `You are a helpful customer support agent.
Current date: ${new Date().toISOString()}
User timezone: UTC-5`,
});
```

---

## Temperature and Settings

```typescript
const result = streamText({
  model: openai('gpt-4-turbo'),
  messages,
  temperature: 0.7,        // 0-2, higher = more creative
  maxTokens: 500,          // Max response length
  topP: 0.9,               // Nucleus sampling
  frequencyPenalty: 0.5,   // Reduce repetition
  presencePenalty: 0.5,    // Encourage diversity
});
```

---

## Abort Requests

```typescript
const abortController = new AbortController();

const result = streamText({
  model: openai('gpt-4-turbo'),
  messages,
  abortSignal: abortController.signal,
});

// Later: cancel the request
abortController.abort();
```

---

## Streaming Text (Non-React)

### Server-Side Streaming

```typescript
import { streamText } from 'ai';
import { openai } from '@ai-sdk/openai';

export async function POST(req: Request) {
  const { prompt } = await req.json();

  const result = streamText({
    model: openai('gpt-4-turbo'),
    prompt,
  });

  // Stream as Server-Sent Events
  return result.toDataStreamResponse();

  // Or get full text
  const { text } = await result.text;
  return Response.json({ text });

  // Or stream manually
  return new Response(result.textStream, {
    headers: {
      'Content-Type': 'text/plain; charset=utf-8',
    },
  });
}
```

---

## useAssistant - Assistants API

```typescript
'use client';

import { useAssistant } from 'ai/react';

export function AssistantChat() {
  const {
    status,
    messages,
    input,
    handleInputChange,
    submitMessage,
  } = useAssistant({
    api: '/api/assistant',
  });

  return (
    <div>
      {messages.map((message) => (
        <div key={message.id}>
          <strong>{message.role}:</strong> {message.content}
        </div>
      ))}

      <form onSubmit={(e) => {
        e.preventDefault();
        submitMessage();
      }}>
        <input
          value={input}
          onChange={handleInputChange}
          disabled={status !== 'awaiting_message'}
        />
        <button type="submit">Send</button>
      </form>

      <p>Status: {status}</p>
    </div>
  );
}
```
