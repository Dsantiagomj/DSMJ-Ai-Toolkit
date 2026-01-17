# Streaming and Advanced Features

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
