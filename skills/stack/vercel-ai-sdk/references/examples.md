# Full Examples - Vercel AI SDK

## Tool Calls UI {#tool-calls-ui}

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

## Structured Outputs Client {#structured-outputs-client}

### Using Structured Outputs in Client

```typescript
'use client';

import { useState } from 'react';

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

## Error Handling

### Client-Side Error Handling

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

### Server-Side Error Handling

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
