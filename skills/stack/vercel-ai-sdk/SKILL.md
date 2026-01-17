---
name: vercel-ai-sdk
domain: backend
description: >
  AI integration with Vercel AI SDK - Build AI-powered applications with streaming, function calling, and tool use.
  Trigger: When implementing AI features, when using useChat or useCompletion, when building chatbots, when integrating LLMs, when implementing function calling.
version: 1.0.0
tags: [ai, vercel, openai, streaming, llm, react, nextjs]
metadata:
  version: "1.0"
  last_updated: "2026-01-17"
  category: stack
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
  - name: Streaming & Hooks
    url: ./references/streaming.md
    type: local
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

## When to Use

Use Vercel AI SDK when you need:
- **Streaming responses** from LLMs with real-time UI updates
- **React hooks** (useChat, useCompletion) for chat/completion interfaces
- **Function calling** and tool use for AI agents
- **Structured outputs** with Zod schema validation
- **Multi-provider support** (OpenAI, Anthropic, Google, etc.)
- **Edge runtime** compatibility for fast global responses

Choose alternatives when:
- Building non-JavaScript/TypeScript applications
- Need direct provider SDKs for specialized features
- Not using streaming (simple REST API might suffice)
- Building complex agent frameworks (consider LangChain, AutoGPT)

---

## Critical Patterns

### Pattern 1: Streaming with Error Handling

```typescript
// ✅ Good: Proper error handling and loading states
'use client';

import { useChat } from 'ai/react';

export function Chat() {
  const {
    messages,
    input,
    handleInputChange,
    handleSubmit,
    isLoading,
    error,
    reload,
  } = useChat({
    api: '/api/chat',
    onError: (error) => {
      console.error('Chat error:', error);
      toast.error('Failed to send message');
    },
    onFinish: (message) => {
      console.log('Message completed:', message);
    },
  });

  return (
    <div>
      <div className="messages">
        {messages.map((message) => (
          <div key={message.id}>
            <strong>{message.role}:</strong> {message.content}
          </div>
        ))}

        {isLoading && <div className="loading">AI is thinking...</div>}

        {error && (
          <div className="error">
            <p>Error: {error.message}</p>
            <button onClick={() => reload()}>Retry</button>
          </div>
        )}
      </div>

      <form onSubmit={handleSubmit}>
        <input
          value={input}
          onChange={handleInputChange}
          disabled={isLoading}
          placeholder="Type a message..."
        />
        <button type="submit" disabled={isLoading || !input.trim()}>
          Send
        </button>
      </form>
    </div>
  );
}

// ❌ Bad: No error handling, no loading states
export function BadChat() {
  const { messages, input, handleInputChange, handleSubmit } = useChat();

  return (
    <div>
      {messages.map((m) => <div key={m.id}>{m.content}</div>)}
      <form onSubmit={handleSubmit}>
        <input value={input} onChange={handleInputChange} />
        <button>Send</button>
      </form>
    </div>
  );
}
```

**Why**: Error handling improves UX; loading states provide feedback; retry gives users control.

---

### Pattern 2: Tool Calling with UI Feedback

```typescript
// ✅ Good: Show tool calls in UI, handle execution properly
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
        description: 'Get current weather for a location',
        parameters: z.object({
          location: z.string().describe('City and state, e.g. San Francisco, CA'),
          unit: z.enum(['celsius', 'fahrenheit']).default('fahrenheit'),
        }),
        execute: async ({ location, unit }) => {
          const weather = await fetchWeatherAPI(location, unit);
          return {
            location,
            temperature: weather.temp,
            conditions: weather.conditions,
            unit,
          };
        },
      }),
    },
    maxSteps: 5,
  });

  return result.toDataStreamResponse();
}

// Client: Display tool calls
'use client';

export function ChatWithTools() {
  const { messages } = useChat({ api: '/api/chat' });

  return (
    <div>
      {messages.map((message) => (
        <div key={message.id}>
          <div>{message.content}</div>

          {message.toolInvocations?.map((tool, i) => (
            <div key={i} className="tool-call">
              {tool.state === 'call' && (
                <p>Calling {tool.toolName}...</p>
              )}
              {tool.state === 'result' && (
                <div>
                  <p>Used {tool.toolName}</p>
                  <pre>{JSON.stringify(tool.result, null, 2)}</pre>
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

**Why**: Showing tool calls builds trust; users understand AI's actions; debugging is easier.

---

### Pattern 3: Structured Outputs with Validation

```typescript
// ✅ Good: Use generateObject for structured data
// app/api/extract/route.ts
import { openai } from '@ai-sdk/openai';
import { generateObject } from 'ai';
import { z } from 'zod';

const RecipeSchema = z.object({
  name: z.string().describe('Recipe name'),
  ingredients: z.array(
    z.object({
      name: z.string(),
      amount: z.string(),
      unit: z.string().optional(),
    })
  ),
  steps: z.array(z.string()).min(1),
  prepTime: z.number().describe('Prep time in minutes'),
  cookTime: z.number().describe('Cook time in minutes'),
  servings: z.number().positive(),
  difficulty: z.enum(['easy', 'medium', 'hard']),
});

export async function POST(req: Request) {
  const { prompt } = await req.json();

  try {
    const { object } = await generateObject({
      model: openai('gpt-4-turbo'),
      schema: RecipeSchema,
      prompt: `Extract recipe information: ${prompt}`,
    });

    return Response.json({ success: true, data: object });
  } catch (error) {
    return Response.json(
      { success: false, error: 'Failed to extract recipe' },
      { status: 500 }
    );
  }
}
```

**Why**: generateObject ensures valid output; Zod schema provides type safety; reduces parsing errors.

For complete streaming and hook examples, see [references/streaming.md](./references/streaming.md).

---

## Anti-Patterns

### ❌ Anti-Pattern 1: Not Streaming When Beneficial

**Don't do this**:
```typescript
// ❌ Using generateText instead of streamText
export async function POST(req: Request) {
  const { messages } = await req.json();

  const { text } = await generateText({
    model: openai('gpt-4-turbo'),
    messages,
  });

  return Response.json({ text }); // User waits for entire response
}
```

**Why it's wrong**: Poor UX; long wait times; higher perceived latency.

**Do this instead**:
```typescript
// ✅ Stream for better UX
export async function POST(req: Request) {
  const { messages } = await req.json();

  const result = streamText({
    model: openai('gpt-4-turbo'),
    messages,
  });

  return result.toDataStreamResponse();
}
```

---

### ❌ Anti-Pattern 2: Exposing API Keys Client-Side

**Don't do this**:
```typescript
// ❌ Using OpenAI directly from client
'use client';

import OpenAI from 'openai';

export function Chat() {
  const openai = new OpenAI({
    apiKey: process.env.NEXT_PUBLIC_OPENAI_KEY, // EXPOSED!
  });
}
```

**Why it's wrong**: API keys exposed in browser; security risk; quota abuse.

**Do this instead**:
```typescript
// ✅ Use API routes (server-side)
// app/api/chat/route.ts
import { openai } from '@ai-sdk/openai';
import { streamText } from 'ai';

export async function POST(req: Request) {
  const { messages } = await req.json();

  const result = streamText({
    model: openai('gpt-4-turbo'),
    messages,
  });

  return result.toDataStreamResponse();
}

// Client calls your API
'use client';

export function Chat() {
  const { messages } = useChat({ api: '/api/chat' });
  // API key never exposed
}
```

---

### ❌ Anti-Pattern 3: No Token/Cost Limits

**Don't do this**:
```typescript
// ❌ No limits on token usage
export async function POST(req: Request) {
  const { messages } = await req.json();

  const result = streamText({
    model: openai('gpt-4-turbo'),
    messages,
    // No maxTokens, no checks
  });

  return result.toDataStreamResponse();
}
```

**Why it's wrong**: Runaway costs; unpredictable bills.

**Do this instead**:
```typescript
// ✅ Set limits and validate input
export async function POST(req: Request) {
  const { messages } = await req.json();

  if (messages.length > 50) {
    return Response.json({ error: 'Too many messages' }, { status: 400 });
  }

  const totalLength = messages.reduce((sum, msg) => sum + msg.content.length, 0);
  if (totalLength > 10000) {
    return Response.json({ error: 'Messages too long' }, { status: 400 });
  }

  const result = streamText({
    model: openai('gpt-4-turbo'),
    messages,
    maxTokens: 1000, // Limit response length
  });

  return result.toDataStreamResponse();
}
```

For more anti-patterns and solutions, see [references/best-practices.md](./references/best-practices.md).

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
```

---

## Learn More

- **Streaming & Hooks**: [references/streaming.md](./references/streaming.md) - Complete useChat, useCompletion examples
- **Advanced Patterns**: [references/advanced.md](./references/advanced.md) - Multiple providers, abort requests, useAssistant
- **Full Examples**: [references/examples.md](./references/examples.md) - Tool calls UI, structured outputs, error handling
- **Best Practices**: [references/best-practices.md](./references/best-practices.md) - Security, cost optimization

---

## External References

- [Vercel AI SDK Documentation](https://sdk.vercel.ai/docs)
- [Vercel AI SDK GitHub](https://github.com/vercel/ai)

---

_Maintained by dsmj-ai-toolkit_
