# Performance & Testing - Zustand

## Selector Optimization

### Bad: Selecting Entire State

```typescript
// ❌ Component re-renders on ANY state change
function TodoList() {
  const store = useTodoStore(); // Subscribes to everything
  return <div>{store.todos.map(...)}</div>;
}
```

### Good: Selective Subscription

```typescript
// ✅ Only re-renders when todos change
function TodoList() {
  const todos = useTodoStore((state) => state.todos);
  const addTodo = useTodoStore((state) => state.addTodo);
  return <div>{todos.map(...)}</div>;
}
```

---

## Shallow Comparison

```typescript
import { shallow } from 'zustand/shallow';

// ❌ Bad: Creates new object on every render
const { user, settings } = useStore((state) => ({
  user: state.user,
  settings: state.settings,
}));

// ✅ Good: Shallow comparison prevents unnecessary re-renders
const { user, settings } = useStore(
  (state) => ({ user: state.user, settings: state.settings }),
  shallow
);
```

### Array Comparison

```typescript
// For arrays, use shallow comparison
const todoIds = useTodoStore(
  (state) => state.todos.map(t => t.id),
  shallow
);
```

---

## Custom Equality Function

```typescript
import { useStore } from 'zustand';

// Deep comparison for nested objects
const user = useStore(
  (state) => state.user,
  (oldUser, newUser) => JSON.stringify(oldUser) === JSON.stringify(newUser)
);

// Custom field comparison
const user = useStore(
  (state) => state.user,
  (a, b) => a?.id === b?.id && a?.email === b?.email
);
```

---

## Memoized Selectors

```typescript
import { useMemo } from 'react';

function TodoStats() {
  // ✅ Memoize complex computations
  const stats = useTodoStore(
    useMemo(
      () => (state) => ({
        total: state.todos.length,
        completed: state.todos.filter(t => t.completed).length,
        active: state.todos.filter(t => !t.completed).length,
      }),
      []
    )
  );

  return <div>Total: {stats.total}</div>;
}
```

---

## SSR / Next.js Integration

### Server Component Store

```typescript
// stores/server-store.ts
import { create } from 'zustand';

interface ServerStore {
  data: any;
  setData: (data: any) => void;
}

let store: ReturnType<typeof createServerStore>;

const createServerStore = (initialData?: any) => {
  return create<ServerStore>((set) => ({
    data: initialData ?? null,
    setData: (data) => set({ data }),
  }));
};

export const initializeServerStore = (initialData?: any) => {
  const _store = store ?? createServerStore(initialData);

  // For SSR, always create a new store
  if (typeof window === 'undefined') return _store;

  // For CSR, reuse existing store
  if (!store) store = _store;
  return store;
};

export const useServerStore = <T>(
  selector: (state: ServerStore) => T,
  initialData?: any
): T => {
  const store = initializeServerStore(initialData);
  return store(selector);
};
```

### Next.js App Router

```typescript
// app/providers.tsx
'use client';

import { useRef } from 'react';
import { create } from 'zustand';

interface AppStore {
  count: number;
  increment: () => void;
}

const createStore = (initialState?: Partial<AppStore>) => {
  return create<AppStore>((set) => ({
    count: initialState?.count ?? 0,
    increment: () => set((state) => ({ count: state.count + 1 })),
  }));
};

export function StoreProvider({
  children,
  initialState
}: {
  children: React.ReactNode;
  initialState?: Partial<AppStore>;
}) {
  const storeRef = useRef<ReturnType<typeof createStore>>();

  if (!storeRef.current) {
    storeRef.current = createStore(initialState);
  }

  return (
    <StoreContext.Provider value={storeRef.current}>
      {children}
    </StoreContext.Provider>
  );
}

// app/layout.tsx
export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        <StoreProvider initialState={{ count: 0 }}>
          {children}
        </StoreProvider>
      </body>
    </html>
  );
}
```

---

## Testing

### Basic Store Testing

```typescript
import { renderHook, act } from '@testing-library/react';
import { useCounterStore } from './counter-store';

describe('CounterStore', () => {
  beforeEach(() => {
    // Reset store before each test
    useCounterStore.setState({ count: 0 });
  });

  it('increments count', () => {
    const { result } = renderHook(() => useCounterStore());

    expect(result.current.count).toBe(0);

    act(() => {
      result.current.increment();
    });

    expect(result.current.count).toBe(1);
  });

  it('decrements count', () => {
    const { result } = renderHook(() => useCounterStore());

    act(() => {
      result.current.increment();
      result.current.decrement();
    });

    expect(result.current.count).toBe(0);
  });
});
```

### Testing with Initial State

```typescript
it('starts with custom initial count', () => {
  useCounterStore.setState({ count: 10 });

  const { result } = renderHook(() => useCounterStore());
  expect(result.current.count).toBe(10);
});
```

### Testing Async Actions

```typescript
import { waitFor } from '@testing-library/react';

it('fetches user data', async () => {
  const { result } = renderHook(() => useUserStore());

  expect(result.current.isLoading).toBe(false);

  act(() => {
    result.current.fetchUser('123');
  });

  expect(result.current.isLoading).toBe(true);

  await waitFor(() => {
    expect(result.current.isLoading).toBe(false);
    expect(result.current.user).toEqual({ id: '123', name: 'John' });
  });
});
```

### Testing Selectors

```typescript
it('selects only count', () => {
  const { result } = renderHook(() =>
    useCounterStore((state) => state.count)
  );

  expect(result.current).toBe(0);

  act(() => {
    useCounterStore.getState().increment();
  });

  expect(result.current).toBe(1);
});
```

### Testing Persist Middleware

```typescript
import { renderHook, act } from '@testing-library/react';

beforeEach(() => {
  localStorage.clear();
});

it('persists state to localStorage', () => {
  const { result } = renderHook(() => usePersistedStore());

  act(() => {
    result.current.setCount(5);
  });

  const stored = localStorage.getItem('counter-storage');
  expect(JSON.parse(stored!)).toEqual({ state: { count: 5 }, version: 0 });
});

it('rehydrates state from localStorage', () => {
  localStorage.setItem(
    'counter-storage',
    JSON.stringify({ state: { count: 10 }, version: 0 })
  );

  const { result } = renderHook(() => usePersistedStore());

  // Wait for rehydration
  expect(result.current.count).toBe(10);
});
```

---

## Performance Monitoring

### Track Re-renders

```typescript
import { useEffect, useRef } from 'react';

function Component() {
  const renderCount = useRef(0);

  useEffect(() => {
    renderCount.current += 1;
    console.log('Render count:', renderCount.current);
  });

  const count = useCounterStore((state) => state.count);

  return <div>{count}</div>;
}
```

### React DevTools Profiler

```typescript
import { Profiler } from 'react';

function App() {
  return (
    <Profiler
      id="TodoApp"
      onRender={(id, phase, actualDuration) => {
        console.log(`${id} (${phase}) took ${actualDuration}ms`);
      }}
    >
      <TodoApp />
    </Profiler>
  );
}
```

---

## Bundle Size Optimization

```typescript
// ✅ Good: Import only what you need
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

// ❌ Bad: Imports everything
import * as zustand from 'zustand';
```

### Tree Shaking

```json
// package.json
{
  "sideEffects": false
}
```

---

## State Reset Patterns

### Reset Individual Store

```typescript
interface Store {
  count: number;
  user: User | null;
  reset: () => void;
}

const initialState = { count: 0, user: null };

export const useStore = create<Store>((set) => ({
  ...initialState,
  reset: () => set(initialState),
}));
```

### Reset All Stores

```typescript
// utils/reset-stores.ts
export const resetAllStores = () => {
  useCounterStore.getState().reset();
  useUserStore.getState().reset();
  useTodoStore.getState().reset();
};

// Usage (e.g., on logout)
resetAllStores();
```

---

## Debugging

### Log State Changes

```typescript
import { create } from 'zustand';
import { subscribeWithSelector } from 'zustand/middleware';

export const useStore = create<Store>()(
  subscribeWithSelector((set) => ({
    count: 0,
    increment: () => set((state) => ({ count: state.count + 1 })),
  }))
);

// Subscribe to all changes
useStore.subscribe(
  (state) => state,
  (state) => console.log('State changed:', state)
);

// Subscribe to specific field
useStore.subscribe(
  (state) => state.count,
  (count) => console.log('Count changed to:', count)
);
```

### Redux DevTools

```typescript
import { devtools } from 'zustand/middleware';

export const useStore = create<Store>()(
  devtools(
    (set) => ({
      count: 0,
      increment: () => set((state) => ({ count: state.count + 1 })),
    }),
    {
      name: 'MyStore',
      enabled: process.env.NODE_ENV === 'development',
    }
  )
);
```
