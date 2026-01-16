---
name: vercel-ai-sdk
domain: backend
description: AI integration with Vercel AI SDK - Build AI-powered applications with streaming, function calling, and tool use. Covers React hooks, streaming responses, OpenAI integration, and structured outputs.
version: 1.0.0
tags: [ai, vercel, openai, streaming, llm, react, nextjs]
references:
  - name: Vercel AI SDK Documentation
    url: https://sdk.vercel.ai/docs
    type: documentation
  - name: Vercel AI SDK GitHub
    url: https://github.com/vercel/ai
    type: repository
  - name: Vercel AI SDK Context7
    url: /websites/ai-sdk_dev
    type: context7
  - name: Advanced Patterns
    url: ./references/advanced.md
    type: local
  - name: Full Examples
    url: ./references/examples.md
    type: local
  - name: Best Practices
    url: ./references/best-practices.md
    type: local
---

# Vercel AI SDK - Build AI-Powered Apps

**Stream AI responses, call functions, and build conversational interfaces**

---

## What This Skill Covers

This skill provides guidance on:
- **React Hooks** (useChat, useCompletion, useAssistant)
- **Streaming responses** from LLMs
- **Function calling** and tool use
- **Structured outputs** with Zod
- **OpenAI integration** and other providers

For advanced patterns, error handling, and full examples, see [references/](./references/).

---

## Installation

```bash
npm install ai @ai-sdk/openai zod
```

```typescript
// Set environment variable
OPENAI_API_KEY=your_api_key_here
```

---

## useChat - Chat Interface

### Basic Chat Component

```typescript
'use client';

import { useChat } from 'ai/react';

export function Chat() {
  const { messages, input, handleInputChange, handleSubmit, isLoading } = useChat({
    api: '/api/chat',
  });

  return (
    <div className="flex flex-col h-screen">
      {/* Messages */}
      <div className="flex-1 overflow-y-auto p-4 space-y-4">
        {messages.map((message) => (
          <div key={message.id} className={message.role === 'user' ? 'justify-end' : 'justify-start'}>
            <div className={message.role === 'user' ? 'bg-blue-600 text-white' : 'bg-gray-200'}>
              {message.content}
            </div>
          </div>
        ))}
      </div>

      {/* Input */}
      <form onSubmit={handleSubmit} className="p-4 border-t">
        <input
          value={input}
          onChange={handleInputChange}
          placeholder="Type your message..."
          disabled={isLoading}
        />
        <button type="submit" disabled={isLoading}>Send</button>
      </form>
    </div>
  );
}
```

### Chat Route Handler

```typescript
// app/api/chat/route.ts
import { openai } from '@ai-sdk/openai';
import { streamText } from 'ai';

export async function POST(req: Request) {
  const { messages } = await req.json();

  const result = streamText({
    model: openai('gpt-4-turbo'),
    messages,
    system: 'You are a helpful assistant.',
  });

  return result.toDataStreamResponse();
}
```

---

## useCompletion - Text Generation

```typescript
'use client';

import { useCompletion } from 'ai/react';

export function CompletionDemo() {
  const { completion, input, handleInputChange, handleSubmit, isLoading } = useCompletion({
    api: '/api/completion',
  });

  return (
    <div className="space-y-4">
      <form onSubmit={handleSubmit}>
        <textarea value={input} onChange={handleInputChange} placeholder="Enter a prompt..." />
        <button type="submit" disabled={isLoading}>Generate</button>
      </form>

      {completion && <div className="p-4 bg-gray-100">{completion}</div>}
    </div>
  );
}
```

```typescript
// app/api/completion/route.ts
import { openai } from '@ai-sdk/openai';
import { streamText } from 'ai';

export async function POST(req: Request) {
  const { prompt } = await req.json();

  const result = streamText({
    model: openai('gpt-4-turbo'),
    prompt,
  });

  return result.toDataStreamResponse();
}
```

---

## Function Calling / Tool Use

### Define Tools

```typescript
// app/api/chat/route.ts
import { openai } from '@ai-sdk/openai';
import { streamText, tool } from 'ai';
import { z } from 'zod';

export async function POST(req: Request) {
  const { messages } = await req.json();

  const result = streamText({
    model: openai('gpt-4-turbo'),
    messages,
    tools: {
      getWeather: tool({
        description: 'Get the current weather for a location',
        parameters: z.object({
          location: z.string().describe('The city and state, e.g. San Francisco, CA'),
        }),
        execute: async ({ location }) => {
          const weather = await fetchWeather(location);
          return weather;
        },
      }),

      searchWeb: tool({
        description: 'Search the web for information',
        parameters: z.object({
          query: z.string().describe('The search query'),
        }),
        execute: async ({ query }) => {
          const results = await searchAPI(query);
          return results;
        },
      }),
    },
    maxSteps: 5, // Allow multiple tool calls
  });

  return result.toDataStreamResponse();
}
```

See [examples/tool-calls-ui.md](./references/examples.md#tool-calls-ui) for displaying tool calls in the UI.

---

## Structured Outputs

### Generate Structured Data

```typescript
// app/api/extract/route.ts
import { openai } from '@ai-sdk/openai';
import { generateObject } from 'ai';
import { z } from 'zod';

const RecipeSchema = z.object({
  name: z.string(),
  ingredients: z.array(z.object({
    name: z.string(),
    amount: z.string(),
  })),
  steps: z.array(z.string()),
  prepTime: z.number().describe('Preparation time in minutes'),
  cookTime: z.number().describe('Cooking time in minutes'),
});

export async function POST(req: Request) {
  const { prompt } = await req.json();

  const { object } = await generateObject({
    model: openai('gpt-4-turbo'),
    schema: RecipeSchema,
    prompt,
  });

  return Response.json(object);
}
```

See [examples/structured-outputs-client.md](./references/examples.md#structured-outputs-client) for the client-side implementation.

---

## Quick Reference

### React Hooks

```typescript
// useChat
const { messages, input, handleInputChange, handleSubmit, isLoading, error, reload } = useChat({
  api: '/api/chat',
  initialMessages: [],
  onFinish: (message) => {},
  onError: (error) => {},
});

// useCompletion
const { completion, input, handleInputChange, handleSubmit, isLoading } = useCompletion({
  api: '/api/completion',
});

// useAssistant
const { status, messages, input, handleInputChange, submitMessage } = useAssistant({
  api: '/api/assistant',
});
```

### Server Functions

```typescript
// streamText
const result = streamText({
  model: openai('gpt-4-turbo'),
  messages: [],
  system: 'System message',
  tools: {},
  maxSteps: 5,
  temperature: 0.7,
  maxTokens: 1000,
});
return result.toDataStreamResponse();

// generateObject
const { object } = await generateObject({
  model: openai('gpt-4-turbo'),
  schema: z.object({...}),
  prompt: 'Extract data',
});

// tool definition
const myTool = tool({
  description: 'Tool description',
  parameters: z.object({...}),
  execute: async (params) => {...},
});
```

---

## Learn More

- **Advanced Patterns**: [references/advanced.md](./references/advanced.md) - Multiple providers, system messages, temperature, abort requests, streaming, useAssistant
- **Full Examples**: [references/examples.md](./references/examples.md) - Complete code examples with tool calls UI, structured outputs client, error handling
- **Best Practices**: [references/best-practices.md](./references/best-practices.md) - Security, cost optimization, error recovery

---

## External References

- [Vercel AI SDK Documentation](https://sdk.vercel.ai/docs)
- [Vercel AI SDK GitHub](https://github.com/vercel/ai)

---

_Maintained by dsmj-ai-toolkit_
