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
          // Actual API call
          const weather = await fetchWeatherAPI(location, unit);
          return {
            location,
            temperature: weather.temp,
            conditions: weather.conditions,
            unit,
          };
        },
      }),

      searchWeb: tool({
        description: 'Search the web for current information',
        parameters: z.object({
          query: z.string(),
          maxResults: z.number().default(5),
        }),
        execute: async ({ query, maxResults }) => {
          const results = await searchAPI(query, maxResults);
          return results;
        },
      }),
    },
    maxSteps: 5, // Allow multiple tool calls
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

// ❌ Bad: No tool result display, user can't see what happened
export function BadChatWithTools() {
  const { messages } = useChat({ api: '/api/chat' });

  return (
    <div>
      {messages.map((m) => (
        <div key={m.id}>{m.content}</div>
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

// ❌ Bad: Using chat completion and parsing JSON manually
export async function POST(req: Request) {
  const { prompt } = await req.json();

  const result = await streamText({
    model: openai('gpt-4-turbo'),
    prompt: `Extract recipe as JSON: ${prompt}`,
  });

  const text = await result.text;
  const json = JSON.parse(text); // Might fail, no validation
  return Response.json(json);
}
```

**Why**: generateObject ensures valid output; Zod schema provides type safety and validation; reduces parsing errors.

---

### Pattern 4: Abort Requests on Unmount

```typescript
// ✅ Good: Cleanup on unmount
'use client';

import { useChat } from 'ai/react';
import { useEffect } from 'react';

export function Chat() {
  const { messages, input, handleInputChange, handleSubmit, stop } = useChat({
    api: '/api/chat',
  });

  // Cleanup on unmount
  useEffect(() => {
    return () => {
      stop(); // Abort ongoing requests
    };
  }, [stop]);

  return (
    <div>
      <div className="messages">
        {messages.map((m) => (
          <div key={m.id}>{m.content}</div>
        ))}
      </div>

      <form onSubmit={handleSubmit}>
        <input value={input} onChange={handleInputChange} />
        <button type="submit">Send</button>
        <button type="button" onClick={stop}>Stop</button>
      </form>
    </div>
  );
}

// ❌ Bad: No cleanup, memory leaks
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

**Why**: Prevents memory leaks; stops unnecessary API calls; improves performance.

---

### Pattern 5: System Messages and Temperature Control

```typescript
// ✅ Good: Configure model behavior properly
// app/api/chat/route.ts
export async function POST(req: Request) {
  const { messages } = await req.json();

  const result = streamText({
    model: openai('gpt-4-turbo'),
    messages,
    system: `You are a helpful coding assistant. 
      - Provide concise, accurate answers
      - Use code examples when relevant
      - Cite sources when making factual claims
      - Admit when you don't know something`,
    temperature: 0.7, // Balanced creativity/accuracy
    maxTokens: 1000,
    topP: 0.9,
  });

  return result.toDataStreamResponse();
}

// For deterministic responses (e.g., data extraction)
export async function POST(req: Request) {
  const { messages } = await req.json();

  const result = streamText({
    model: openai('gpt-4-turbo'),
    messages,
    system: 'Extract data accurately. Return only valid JSON.',
    temperature: 0.1, // More deterministic
    maxTokens: 500,
  });

  return result.toDataStreamResponse();
}

// ❌ Bad: No system message, default temperature
export async function POST(req: Request) {
  const { messages } = await req.json();

  const result = streamText({
    model: openai('gpt-4-turbo'),
    messages,
  });

  return result.toDataStreamResponse();
}
```

**Why**: System messages guide behavior; temperature controls randomness; max tokens prevents runaway costs.

---

## Anti-Patterns

### Anti-Pattern 1: Not Streaming When Beneficial

```typescript
// ❌ Problem: Using generateText instead of streamText
export async function POST(req: Request) {
  const { messages } = await req.json();

  const { text } = await generateText({
    model: openai('gpt-4-turbo'),
    messages,
  });

  return Response.json({ text }); // User waits for entire response
}
```

**Why it's wrong**: Poor UX; long wait times; users don't see progress; higher perceived latency.

**Solution**:
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

// Client gets progressive updates
const { messages } = useChat({ api: '/api/chat' });
```

---

### Anti-Pattern 2: Exposing API Keys Client-Side

```typescript
// ❌ Problem: Using OpenAI directly from client
'use client';

import OpenAI from 'openai';

export function Chat() {
  const openai = new OpenAI({
    apiKey: process.env.NEXT_PUBLIC_OPENAI_KEY, // EXPOSED!
  });

  // Making direct calls from browser
}
```

**Why it's wrong**: API keys exposed in browser; security risk; users can abuse your quota; CORS issues.

**Solution**:
```typescript
// ✅ Use API routes (server-side)
// app/api/chat/route.ts
import { openai } from '@ai-sdk/openai';
import { streamText } from 'ai';

export async function POST(req: Request) {
  // API key stays on server (OPENAI_API_KEY env var)
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

### Anti-Pattern 3: No Token/Cost Limits

```typescript
// ❌ Problem: No limits on token usage
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

**Why it's wrong**: Runaway costs; users can abuse the system; unpredictable bills.

**Solution**:
```typescript
// ✅ Set limits and validate input
export async function POST(req: Request) {
  const { messages } = await req.json();

  // Validate message count
  if (messages.length > 50) {
    return Response.json(
      { error: 'Too many messages' },
      { status: 400 }
    );
  }

  // Validate message length
  const totalLength = messages.reduce(
    (sum, msg) => sum + msg.content.length,
    0
  );
  if (totalLength > 10000) {
    return Response.json(
      { error: 'Messages too long' },
      { status: 400 }
    );
  }

  const result = streamText({
    model: openai('gpt-4-turbo'),
    messages,
    maxTokens: 1000, // Limit response length
  });

  return result.toDataStreamResponse();
}

// ✅ Add rate limiting
import { rateLimit } from '@/lib/rate-limit';

export async function POST(req: Request) {
  const ip = req.headers.get('x-forwarded-for') || 'unknown';
  
  const { success } = await rateLimit.check(ip);
  if (!success) {
    return Response.json(
      { error: 'Rate limit exceeded' },
      { status: 429 }
    );
  }

  // Process request
}
```

---

### Anti-Pattern 4: Ignoring Tool Execution Errors

```typescript
// ❌ Problem: Tool execution fails silently
tools: {
  getWeather: tool({
    description: 'Get weather',
    parameters: z.object({ location: z.string() }),
    execute: async ({ location }) => {
      const weather = await fetchWeather(location); // Might throw
      return weather;
    },
  }),
}
```

**Why it's wrong**: Silent failures confuse AI; users get incomplete responses; hard to debug.

**Solution**:
```typescript
// ✅ Handle tool errors properly
tools: {
  getWeather: tool({
    description: 'Get weather for a location',
    parameters: z.object({ location: z.string() }),
    execute: async ({ location }) => {
      try {
        const weather = await fetchWeather(location);
        return {
          success: true,
          data: weather,
        };
      } catch (error) {
        console.error('Weather fetch failed:', error);
        return {
          success: false,
          error: 'Could not fetch weather. The location might be invalid or the service is unavailable.',
        };
      }
    },
  }),
}

// AI can see the error and respond appropriately
```

---

### Anti-Pattern 5: Not Using Initial Messages

```typescript
// ❌ Problem: Sending context with every request
'use client';

export function ChatAboutDocument() {
  const { messages, input, handleInputChange, handleSubmit } = useChat({
    api: '/api/chat',
  });

  // Have to manually include document context in every message
  const submitWithContext = (e) => {
    e.preventDefault();
    const messageWithContext = `Context: ${documentContent}\n\nQuestion: ${input}`;
    // Send messageWithContext
  };
}
```

**Why it's wrong**: Inefficient; wastes tokens; hard to manage context; inconsistent behavior.

**Solution**:
```typescript
// ✅ Use initialMessages for context
'use client';

export function ChatAboutDocument({ document }: { document: string }) {
  const { messages, input, handleInputChange, handleSubmit } = useChat({
    api: '/api/chat',
    initialMessages: [
      {
        id: 'context',
        role: 'system',
        content: `You are helping the user analyze this document:\n\n${document}\n\nAnswer questions about it.`,
      },
    ],
  });

  return (
    <form onSubmit={handleSubmit}>
      <input value={input} onChange={handleInputChange} />
      <button>Ask</button>
    </form>
  );
}

// ✅ Or use system message in the API
export async function POST(req: Request) {
  const { messages, documentId } = await req.json();
  
  const document = await getDocument(documentId);

  const result = streamText({
    model: openai('gpt-4-turbo'),
    messages,
    system: `You are analyzing this document:\n\n${document.content}\n\nAnswer questions about it.`,
  });

  return result.toDataStreamResponse();
}
```

---

### Anti-Pattern 6: Not Handling Message History

```typescript
// ❌ Problem: Unlimited message history
const { messages } = useChat({ api: '/api/chat' });

// messages array grows forever, high costs
```

**Why it's wrong**: Unbounded token usage; high costs; degraded performance; context window limits.

**Solution**:
```typescript
// ✅ Limit message history
'use client';

export function Chat() {
  const { messages, input, handleInputChange, handleSubmit } = useChat({
    api: '/api/chat',
    maxSteps: 10, // Limit conversation turns
  });

  // Or manually slice messages
  const recentMessages = messages.slice(-20); // Keep last 20 messages
}

// ✅ Server-side truncation
export async function POST(req: Request) {
  const { messages } = await req.json();

  // Keep system message + last 10 exchanges (20 messages)
  const systemMessages = messages.filter(m => m.role === 'system');
  const conversationMessages = messages.filter(m => m.role !== 'system').slice(-20);
  
  const truncatedMessages = [...systemMessages, ...conversationMessages];

  const result = streamText({
    model: openai('gpt-4-turbo'),
    messages: truncatedMessages,
  });

  return result.toDataStreamResponse();
}

// ✅ Use summarization for long conversations
const shouldSummarize = messages.length > 30;

if (shouldSummarize) {
  const summary = await generateText({
    model: openai('gpt-4-turbo'),
    prompt: `Summarize this conversation:\n${conversationHistory}`,
  });
  
  // Start new conversation with summary
  const newMessages = [
    { role: 'system', content: `Previous conversation summary: ${summary.text}` },
    ...recentMessages,
  ];
}
```

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
