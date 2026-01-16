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
- **Route handlers** for Next.js
- **Prompt engineering** patterns
- **Error handling** and retries

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

### Basic Chat

```typescript
'use client';

import { useChat } from 'ai/react';

export function Chat() {
  const { messages, input, handleInputChange, handleSubmit, isLoading } = useChat({
    api: '/api/chat',
  });

  return (
    <div className="flex flex-col h-screen">
      <div className="flex-1 overflow-y-auto p-4 space-y-4">
        {messages.map((message) => (
          <div
            key={message.id}
            className={`flex ${
              message.role === 'user' ? 'justify-end' : 'justify-start'
            }`}
          >
            <div
              className={`rounded-lg px-4 py-2 max-w-md ${
                message.role === 'user'
                  ? 'bg-blue-600 text-white'
                  : 'bg-gray-200 text-gray-900'
              }`}
            >
              {message.content}
            </div>
          </div>
        ))}

        {isLoading && (
          <div className="flex justify-start">
            <div className="bg-gray-200 rounded-lg px-4 py-2">
              <div className="flex gap-1">
                <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce" />
                <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce [animation-delay:0.2s]" />
                <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce [animation-delay:0.4s]" />
              </div>
            </div>
          </div>
        )}
      </div>

      <form onSubmit={handleSubmit} className="p-4 border-t">
        <div className="flex gap-2">
          <input
            value={input}
            onChange={handleInputChange}
            placeholder="Type your message..."
            className="flex-1 px-4 py-2 border rounded-lg"
            disabled={isLoading}
          />
          <button
            type="submit"
            disabled={isLoading}
            className="px-6 py-2 bg-blue-600 text-white rounded-lg disabled:opacity-50"
          >
            Send
          </button>
        </div>
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

export const runtime = 'edge';

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

## useCompletion - Text Completion

### Basic Completion

```typescript
'use client';

import { useCompletion } from 'ai/react';

export function CompletionDemo() {
  const {
    completion,
    input,
    handleInputChange,
    handleSubmit,
    isLoading,
  } = useCompletion({
    api: '/api/completion',
  });

  return (
    <div className="space-y-4">
      <form onSubmit={handleSubmit} className="space-y-2">
        <textarea
          value={input}
          onChange={handleInputChange}
          placeholder="Enter a prompt..."
          className="w-full px-4 py-2 border rounded-lg"
          rows={4}
        />
        <button
          type="submit"
          disabled={isLoading}
          className="px-6 py-2 bg-blue-600 text-white rounded-lg"
        >
          Generate
        </button>
      </form>

      {completion && (
        <div className="p-4 bg-gray-100 rounded-lg">
          <p className="whitespace-pre-wrap">{completion}</p>
        </div>
      )}
    </div>
  );
}
```

### Completion Route Handler

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
          // Call weather API
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
          // Call search API
          const results = await searchAPI(query);
          return results;
        },
      }),

      createCalendarEvent: tool({
        description: 'Create a calendar event',
        parameters: z.object({
          title: z.string(),
          date: z.string().describe('ISO 8601 date string'),
          description: z.string().optional(),
        }),
        execute: async ({ title, date, description }) => {
          // Create calendar event
          const event = await createEvent({ title, date, description });
          return event;
        },
      }),
    },
    maxSteps: 5, // Allow multiple tool calls
  });

  return result.toDataStreamResponse();
}

async function fetchWeather(location: string) {
  // Implement weather API call
  return {
    temperature: 72,
    condition: 'Sunny',
    location,
  };
}
```

### Display Tool Calls in UI

```typescript
'use client';

import { useChat } from 'ai/react';

export function ChatWithTools() {
  const { messages } = useChat({ api: '/api/chat' });

  return (
    <div className="space-y-4">
      {messages.map((message) => (
        <div key={message.id}>
          {/* Regular message */}
          {message.content && (
            <div className="rounded-lg px-4 py-2 bg-gray-200">
              {message.content}
            </div>
          )}

          {/* Tool calls */}
          {message.toolInvocations?.map((toolInvocation) => (
            <div key={toolInvocation.toolCallId} className="mt-2 p-3 bg-blue-50 rounded-lg">
              {toolInvocation.state === 'call' && (
                <div>
                  <p className="font-semibold">Calling {toolInvocation.toolName}...</p>
                  <pre className="text-xs mt-1">
                    {JSON.stringify(toolInvocation.args, null, 2)}
                  </pre>
                </div>
              )}

              {toolInvocation.state === 'result' && (
                <div>
                  <p className="font-semibold">{toolInvocation.toolName} result:</p>
                  <pre className="text-xs mt-1">
                    {JSON.stringify(toolInvocation.result, null, 2)}
                  </pre>
                </div>
              )}
            </div>
          ))}
        </div>
      ))}
    </div>
  );
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

### Using in Client

```typescript
'use client';

export function RecipeExtractor() {
  const [recipe, setRecipe] = useState(null);

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    const formData = new FormData(e.currentTarget);
    const prompt = formData.get('prompt');

    const response = await fetch('/api/extract', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ prompt }),
    });

    const recipe = await response.json();
    setRecipe(recipe);
  };

  return (
    <div>
      <form onSubmit={handleSubmit}>
        <textarea name="prompt" placeholder="Describe a recipe..." />
        <button type="submit">Extract Recipe</button>
      </form>

      {recipe && (
        <div>
          <h2>{recipe.name}</h2>
          <p>Prep: {recipe.prepTime}min | Cook: {recipe.cookTime}min</p>

          <h3>Ingredients:</h3>
          <ul>
            {recipe.ingredients.map((ing, i) => (
              <li key={i}>{ing.amount} {ing.name}</li>
            ))}
          </ul>

          <h3>Steps:</h3>
          <ol>
            {recipe.steps.map((step, i) => (
              <li key={i}>{step}</li>
            ))}
          </ol>
        </div>
      )}
    </div>
  );
}
```

---

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

## Advanced Patterns

### System Messages

```typescript
const result = streamText({
  model: openai('gpt-4-turbo'),
  messages,
  system: `You are a helpful customer support agent.
Current date: ${new Date().toISOString()}
User timezone: UTC-5`,
});
```

### Temperature and Settings

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

### Abort Requests

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

## Error Handling

### Client-Side

```typescript
const { messages, error, reload } = useChat({
  api: '/api/chat',
  onError: (error) => {
    console.error('Chat error:', error);
    toast.error('Failed to send message. Please try again.');
  },
});

{error && (
  <div className="p-4 bg-red-100 text-red-700 rounded-lg">
    <p>{error.message}</p>
    <button onClick={reload} className="mt-2 text-sm underline">
      Retry
    </button>
  </div>
)}
```

### Server-Side

```typescript
// app/api/chat/route.ts
export async function POST(req: Request) {
  try {
    const { messages } = await req.json();

    const result = streamText({
      model: openai('gpt-4-turbo'),
      messages,
    });

    return result.toDataStreamResponse();
  } catch (error) {
    console.error('API Error:', error);

    // Return error response
    return new Response(
      JSON.stringify({
        error: 'Failed to process request',
        details: error instanceof Error ? error.message : 'Unknown error',
      }),
      {
        status: 500,
        headers: { 'Content-Type': 'application/json' },
      }
    );
  }
}
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

---

## Best Practices

### Security

```typescript
// ✅ Good: Validate user input
const { messages } = await req.json();

if (!Array.isArray(messages)) {
  return new Response('Invalid messages', { status: 400 });
}

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

// ✅ Good: Authentication
const session = await getServerSession();
if (!session) {
  return new Response('Unauthorized', { status: 401 });
}
```

### Cost Optimization

```typescript
// ✅ Good: Set max tokens
const result = streamText({
  model: openai('gpt-4-turbo'),
  messages,
  maxTokens: 500, // Limit response length
});

// ✅ Good: Use cheaper models when appropriate
const result = streamText({
  model: openai('gpt-3.5-turbo'), // Cheaper for simple tasks
  messages,
});
```

### Error Recovery

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

## Quick Reference

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

// streamText (server)
const result = streamText({
  model: openai('gpt-4-turbo'),
  messages: [],
  system: '',
  tools: {},
  maxSteps: 5,
  temperature: 0.7,
  maxTokens: 1000,
});

// generateObject (server)
const { object } = await generateObject({
  model: openai('gpt-4-turbo'),
  schema: z.object({...}),
  prompt: '',
});

// tool definition
const myTool = tool({
  description: 'Tool description',
  parameters: z.object({...}),
  execute: async (params) => {...},
});
```

---

## References

- [Vercel AI SDK Documentation](https://sdk.vercel.ai/docs)
- [Vercel AI SDK GitHub](https://github.com/vercel/ai)

---

_Maintained by dsmj-ai-toolkit_
