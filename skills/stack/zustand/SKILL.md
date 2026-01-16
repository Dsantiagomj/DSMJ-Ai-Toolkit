---
name: zustand
domain: frontend
description: Minimalist state management with Zustand - Simple, fast state management for React. Covers store creation, middleware, TypeScript patterns, and async actions.
version: 1.0.0
tags: [zustand, state-management, react, typescript, hooks]
references:
  - name: Zustand Documentation
    url: https://zustand.pmnd.rs/
    type: documentation
  - name: Zustand GitHub
    url: https://github.com/pmndrs/zustand
    type: repository
  - name: Zustand Context7
    url: /websites/zustand_pmnd_rs
    type: context7
---

# Zustand - Minimalist State Management

**Simple, fast, and scalable state management without the boilerplate**

---

## What This Skill Covers

This skill provides guidance on:
- **Store creation** with TypeScript
- **React integration** with hooks
- **Middleware** (persist, devtools, immer)
- **Async actions** and side effects
- **Selectors** and performance optimization
- **Slices pattern** for large stores
- **Testing** zustand stores

---

## Basic Store

```typescript
import { create } from 'zustand';

interface CounterStore {
  count: number;
  increment: () => void;
  decrement: () => void;
  reset: () => void;
}

export const useCounterStore = create<CounterStore>((set) => ({
  count: 0,
  increment: () => set((state) => ({ count: state.count + 1 })),
  decrement: () => set((state) => ({ count: state.count - 1 })),
  reset: () => set({ count: 0 }),
}));
```

### Usage in Component

```typescript
'use client';

import { useCounterStore } from '@/stores/counter';

export function Counter() {
  const count = useCounterStore((state) => state.count);
  const increment = useCounterStore((state) => state.increment);
  const decrement = useCounterStore((state) => state.decrement);

  return (
    <div>
      <p>Count: {count}</p>
      <button onClick={increment}>+</button>
      <button onClick={decrement}>-</button>
    </div>
  );
}
```

---

## TypeScript Patterns

### Proper Type Inference

```typescript
import { create } from 'zustand';

interface UserStore {
  user: User | null;
  isLoading: boolean;
  error: string | null;
  setUser: (user: User) => void;
  clearUser: () => void;
  fetchUser: (id: string) => Promise<void>;
}

export const useUserStore = create<UserStore>((set, get) => ({
  user: null,
  isLoading: false,
  error: null,

  setUser: (user) => set({ user, error: null }),

  clearUser: () => set({ user: null, error: null }),

  fetchUser: async (id) => {
    set({ isLoading: true, error: null });

    try {
      const response = await fetch(`/api/users/${id}`);
      const user = await response.json();
      set({ user, isLoading: false });
    } catch (error) {
      set({
        error: error instanceof Error ? error.message : 'Unknown error',
        isLoading: false
      });
    }
  },
}));
```

### Read from State in Actions

```typescript
const useStore = create<Store>((set, get) => ({
  items: [],

  addItem: (item) => {
    const currentItems = get().items;
    set({ items: [...currentItems, item] });
  },

  // Or use set callback
  addItemAlt: (item) => {
    set((state) => ({ items: [...state.items, item] }));
  },
}));
```

---

## Async Actions

### API Integration

```typescript
import { create } from 'zustand';

interface Post {
  id: string;
  title: string;
  content: string;
}

interface PostStore {
  posts: Post[];
  isLoading: boolean;
  error: string | null;
  fetchPosts: () => Promise<void>;
  createPost: (data: { title: string; content: string }) => Promise<void>;
  deletePost: (id: string) => Promise<void>;
}

export const usePostStore = create<PostStore>((set, get) => ({
  posts: [],
  isLoading: false,
  error: null,

  fetchPosts: async () => {
    set({ isLoading: true, error: null });

    try {
      const response = await fetch('/api/posts');
      const posts = await response.json();
      set({ posts, isLoading: false });
    } catch (error) {
      set({
        error: 'Failed to fetch posts',
        isLoading: false
      });
    }
  },

  createPost: async (data) => {
    set({ isLoading: true, error: null });

    try {
      const response = await fetch('/api/posts', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data),
      });

      const newPost = await response.json();

      set((state) => ({
        posts: [...state.posts, newPost],
        isLoading: false,
      }));
    } catch (error) {
      set({
        error: 'Failed to create post',
        isLoading: false
      });
    }
  },

  deletePost: async (id) => {
    try {
      await fetch(`/api/posts/${id}`, { method: 'DELETE' });

      set((state) => ({
        posts: state.posts.filter((post) => post.id !== id),
      }));
    } catch (error) {
      set({ error: 'Failed to delete post' });
    }
  },
}));
```

---

## Middleware

### Persist Middleware

```typescript
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';

interface AuthStore {
  token: string | null;
  user: User | null;
  login: (token: string, user: User) => void;
  logout: () => void;
}

export const useAuthStore = create<AuthStore>()(
  persist(
    (set) => ({
      token: null,
      user: null,

      login: (token, user) => set({ token, user }),
      logout: () => set({ token: null, user: null }),
    }),
    {
      name: 'auth-storage', // LocalStorage key
      storage: createJSONStorage(() => localStorage),

      // Optionally whitelist/blacklist specific keys
      partialize: (state) => ({
        token: state.token,
        user: state.user
      }),
    }
  )
);
```

### DevTools Middleware

```typescript
import { devtools } from 'zustand/middleware';

export const useStore = create<Store>()(
  devtools(
    (set) => ({
      count: 0,
      increment: () => set((state) => ({ count: state.count + 1 }), undefined, 'increment'),
      decrement: () => set((state) => ({ count: state.count - 1 }), undefined, 'decrement'),
    }),
    { name: 'CounterStore' }
  )
);
```

### Immer Middleware

```typescript
import { immer } from 'zustand/middleware/immer';

interface TodoStore {
  todos: Todo[];
  addTodo: (todo: Todo) => void;
  toggleTodo: (id: string) => void;
  updateTodo: (id: string, updates: Partial<Todo>) => void;
}

export const useTodoStore = create<TodoStore>()(
  immer((set) => ({
    todos: [],

    addTodo: (todo) => set((state) => {
      state.todos.push(todo);
    }),

    toggleTodo: (id) => set((state) => {
      const todo = state.todos.find((t) => t.id === id);
      if (todo) {
        todo.completed = !todo.completed;
      }
    }),

    updateTodo: (id, updates) => set((state) => {
      const todo = state.todos.find((t) => t.id === id);
      if (todo) {
        Object.assign(todo, updates);
      }
    }),
  }))
);
```

### Combining Middleware

```typescript
import { create } from 'zustand';
import { devtools, persist } from 'zustand/middleware';
import { immer } from 'zustand/middleware/immer';

export const useStore = create<Store>()(
  devtools(
    persist(
      immer((set) => ({
        // Store definition
      })),
      { name: 'app-storage' }
    ),
    { name: 'AppStore' }
  )
);
```

---

## Selectors and Performance

### Basic Selectors

```typescript
// ❌ Bad: Re-renders on any state change
const store = useStore();

// ✅ Good: Only re-renders when count changes
const count = useStore((state) => state.count);
const increment = useStore((state) => state.increment);
```

### Multiple Selectors

```typescript
// ❌ Bad: Creates new object every render
const { user, isLoading } = useUserStore((state) => ({
  user: state.user,
  isLoading: state.isLoading,
}));

// ✅ Good: Use separate selectors
const user = useUserStore((state) => state.user);
const isLoading = useUserStore((state) => state.isLoading);

// ✅ Good: Or use shallow comparison
import { shallow } from 'zustand/shallow';

const { user, isLoading } = useUserStore(
  (state) => ({ user: state.user, isLoading: state.isLoading }),
  shallow
);
```

### Custom Selectors

```typescript
// Create reusable selectors
const selectUser = (state: UserStore) => state.user;
const selectIsAuthenticated = (state: UserStore) => !!state.user;
const selectUserEmail = (state: UserStore) => state.user?.email;

// Use in components
const user = useUserStore(selectUser);
const isAuthenticated = useUserStore(selectIsAuthenticated);
const email = useUserStore(selectUserEmail);
```

---

## Slices Pattern (Large Stores)

```typescript
import { create } from 'zustand';

// Define slices
interface UserSlice {
  user: User | null;
  setUser: (user: User) => void;
}

interface SettingsSlice {
  theme: 'light' | 'dark';
  setTheme: (theme: 'light' | 'dark') => void;
}

interface NotificationSlice {
  notifications: Notification[];
  addNotification: (notification: Notification) => void;
}

// Create slice factories
const createUserSlice = (set: any): UserSlice => ({
  user: null,
  setUser: (user) => set({ user }),
});

const createSettingsSlice = (set: any): SettingsSlice => ({
  theme: 'light',
  setTheme: (theme) => set({ theme }),
});

const createNotificationSlice = (set: any): NotificationSlice => ({
  notifications: [],
  addNotification: (notification) =>
    set((state: any) => ({
      notifications: [...state.notifications, notification]
    })),
});

// Combine slices
type AppStore = UserSlice & SettingsSlice & NotificationSlice;

export const useAppStore = create<AppStore>((set) => ({
  ...createUserSlice(set),
  ...createSettingsSlice(set),
  ...createNotificationSlice(set),
}));
```

---

## Subscriptions

### Subscribe to Changes

```typescript
// Subscribe to specific changes
const unsubscribe = useStore.subscribe(
  (state) => state.count,
  (count, previousCount) => {
    console.log('Count changed from', previousCount, 'to', count);
  }
);

// Unsubscribe when done
unsubscribe();
```

### React useEffect Integration

```typescript
import { useEffect } from 'react';

function Component() {
  useEffect(() => {
    const unsubscribe = useStore.subscribe(
      (state) => state.user,
      (user) => {
        if (user) {
          trackUser(user);
        }
      }
    );

    return unsubscribe;
  }, []);

  return <div>...</div>;
}
```

---

## Server-Side Rendering (Next.js)

### Initializing Store with Server Data

```typescript
import { create } from 'zustand';

interface StoreState {
  data: Data | null;
  hydrate: (data: Data) => void;
}

export const useStore = create<StoreState>((set) => ({
  data: null,
  hydrate: (data) => set({ data }),
}));

// In Server Component
export default async function Page() {
  const data = await fetchData();

  return <ClientComponent initialData={data} />;
}

// In Client Component
'use client';

import { useEffect } from 'react';

export function ClientComponent({ initialData }: { initialData: Data }) {
  const hydrate = useStore((state) => state.hydrate);

  useEffect(() => {
    hydrate(initialData);
  }, [initialData, hydrate]);

  const data = useStore((state) => state.data);

  return <div>{data?.title}</div>;
}
```

---

## Testing

### Testing Stores

```typescript
import { renderHook, act } from '@testing-library/react';
import { useCounterStore } from './counter';

describe('Counter Store', () => {
  beforeEach(() => {
    // Reset store before each test
    useCounterStore.setState({ count: 0 });
  });

  it('increments count', () => {
    const { result } = renderHook(() => useCounterStore());

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

### Testing Async Actions

```typescript
import { waitFor } from '@testing-library/react';

it('fetches posts', async () => {
  const { result } = renderHook(() => usePostStore());

  act(() => {
    result.current.fetchPosts();
  });

  await waitFor(() => {
    expect(result.current.isLoading).toBe(false);
  });

  expect(result.current.posts.length).toBeGreaterThan(0);
});
```

---

## Best Practices

### Store Organization

```typescript
// ✅ Good: Single responsibility
export const useAuthStore = create<AuthStore>(/* auth logic */);
export const usePostStore = create<PostStore>(/* post logic */);
export const useUIStore = create<UIStore>(/* UI state */);

// ❌ Bad: Everything in one store
export const useGlobalStore = create<GlobalStore>(/* everything */);
```

### Avoid Unnecessary Re-renders

```typescript
// ✅ Good: Select only what you need
const user = useStore((state) => state.user);

// ❌ Bad: Selecting entire store
const store = useStore();
```

### Actions vs Direct Set

```typescript
// ✅ Good: Encapsulate logic in actions
const useStore = create<Store>((set) => ({
  count: 0,
  increment: () => set((state) => ({ count: state.count + 1 })),
}));

// ❌ Bad: Direct mutation outside store
const Component = () => {
  useStore.setState({ count: 5 }); // Avoid this
};
```

### TypeScript

```typescript
// ✅ Good: Full type safety
interface Store {
  count: number;
  increment: () => void;
}

const useStore = create<Store>((set) => ({
  count: 0,
  increment: () => set((state) => ({ count: state.count + 1 })),
}));

// ❌ Bad: No types
const useStore = create((set) => ({
  count: 0,
  increment: () => set((state) => ({ count: state.count + 1 })),
}));
```

---

## Advanced Patterns

### Computed Values

```typescript
interface CartStore {
  items: CartItem[];
  addItem: (item: CartItem) => void;
  removeItem: (id: string) => void;
  // Computed values
  get total(): number;
  get itemCount(): number;
}

export const useCartStore = create<CartStore>((set, get) => ({
  items: [],

  addItem: (item) => set((state) => ({
    items: [...state.items, item]
  })),

  removeItem: (id) => set((state) => ({
    items: state.items.filter((item) => item.id !== id),
  })),

  get total() {
    return get().items.reduce((sum, item) => sum + item.price, 0);
  },

  get itemCount() {
    return get().items.length;
  },
}));

// Usage
const total = useCartStore((state) => state.total);
const itemCount = useCartStore((state) => state.itemCount);
```

### Transient Updates (No Re-render)

```typescript
const useStore = create<Store>((set) => ({
  count: 0,
  // This won't trigger re-renders
  _internalCount: 0,
}));

// Update without triggering subscribers
useStore.setState({ _internalCount: 5 }, true);
```

---

## Quick Reference

```typescript
// Create store
const useStore = create<Store>((set, get) => ({
  count: 0,
  increment: () => set((state) => ({ count: state.count + 1 })),
}));

// Use in component
const count = useStore((state) => state.count);
const increment = useStore((state) => state.increment);

// Subscribe
const unsubscribe = useStore.subscribe(
  (state) => state.count,
  (count) => console.log(count)
);

// Get state outside React
const count = useStore.getState().count;

// Set state outside React
useStore.setState({ count: 5 });

// Reset store
useStore.setState(initialState);

// Middleware
import { persist, devtools } from 'zustand/middleware';
import { immer } from 'zustand/middleware/immer';

const useStore = create<Store>()(
  devtools(
    persist(
      immer((set) => ({
        // Store definition
      })),
      { name: 'storage-key' }
    )
  )
);
```

---

## References

- [Zustand Documentation](https://zustand.pmnd.rs/)
- [Zustand GitHub](https://github.com/pmndrs/zustand)

---

_Maintained by dsmj-ai-toolkit_
