---
name: zustand
domain: frontend
description: >
  Minimalist state management with Zustand - Simple, fast state management for React.
  Trigger: When implementing global state, when managing client-side state, when creating stores, when using state management in React.
version: 1.0.0
tags: [zustand, state-management, react, typescript, hooks]
metadata:
  version: "1.0"
  last_updated: "2026-01-17"
  category: stack
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
  - name: Middleware & Advanced
    url: ./references/middleware.md
    type: local
  - name: Performance & Testing
    url: ./references/performance.md
    type: local
---

# Zustand - Minimalist State Management

**Simple, fast, and scalable state management without the boilerplate**

---

## When to Use

Use Zustand when you need:
- **Global state** shared across multiple components
- **Simple API** without boilerplate (no providers, actions, reducers)
- **Performance** with fine-grained subscriptions
- **TypeScript** support with excellent type inference
- **Middleware** for persistence, devtools, or immer
- **Lightweight** solution (small bundle size)

Choose alternatives when:
- Component-local state is sufficient (use useState)
- You need server state management (use React Query, SWR)
- Complex state machines required (use XState)
- Team strongly prefers Redux patterns

---

## Critical Patterns

### Pattern 1: Selective Subscriptions for Performance

```typescript
// ✅ Good: Subscribe to specific state slices
const count = useStore((state) => state.count);
const increment = useStore((state) => state.increment);

// Component only re-renders when count changes
export function Counter() {
  const count = useStore((state) => state.count);
  const increment = useStore((state) => state.increment);

  return (
    <div>
      <p>Count: {count}</p>
      <button onClick={increment}>+</button>
    </div>
  );
}

// ✅ Good: Multiple values with shallow comparison
import { shallow } from 'zustand/shallow';

const { user, isLoading } = useUserStore(
  (state) => ({ user: state.user, isLoading: state.isLoading }),
  shallow
);

// ❌ Bad: Subscribing to entire store
const store = useStore(); // Re-renders on ANY state change!

// ❌ Bad: Creating new object without shallow
const { count, total } = useStore((state) => ({
  count: state.count,
  total: state.total,
})); // New object every render, always re-renders
```

**Why**: Selective subscriptions prevent unnecessary re-renders; shallow comparison for multiple values avoids performance issues.

---

### Pattern 2: Actions with setState Patterns

```typescript
// ✅ Good: Update state immutably with function form
interface CounterStore {
  count: number;
  increment: () => void;
  incrementBy: (value: number) => void;
  reset: () => void;
}

export const useCounterStore = create<CounterStore>((set) => ({
  count: 0,
  
  increment: () => set((state) => ({ count: state.count + 1 })),
  
  incrementBy: (value) => set((state) => ({ count: state.count + value })),
  
  reset: () => set({ count: 0 }), // Direct object when not using previous state
}));

// ✅ Good: Complex updates with get
export const useCartStore = create<CartStore>((set, get) => ({
  items: [],
  total: 0,
  
  addItem: (item) => set((state) => {
    const newItems = [...state.items, item];
    const newTotal = newItems.reduce((sum, i) => sum + i.price, 0);
    
    return { items: newItems, total: newTotal };
  }),
  
  removeItem: (id) => set((state) => ({
    items: state.items.filter(item => item.id !== id),
  })),
  
  getItemCount: () => get().items.length, // Access state without subscribing
}));

// ❌ Bad: Mutating state directly
increment: () => {
  const state = get();
  state.count++; // MUTATION!
  set(state);
}

// ❌ Bad: Not using function form when depending on previous state
increment: () => set({ count: get().count + 1 }); // Race condition possible
```

**Why**: Immutable updates prevent bugs; function form ensures correct updates with concurrent actions; get() allows reading state in actions.

---

### Pattern 3: Organizing Large Stores with Slices

```typescript
// ✅ Good: Split large stores into slices
import { StateCreator } from 'zustand';

export interface UserSlice {
  user: User | null;
  setUser: (user: User) => void;
  clearUser: () => void;
}

export const createUserSlice: StateCreator<StoreState, [], [], UserSlice> = (set) => ({
  user: null,
  setUser: (user) => set({ user }),
  clearUser: () => set({ user: null }),
});

// Combine slices
type StoreState = UserSlice & SettingsSlice;
export const useStore = create<StoreState>()((...a) => ({
  ...createUserSlice(...a),
  ...createSettingsSlice(...a),
}));

// ❌ Bad: One massive store object with 50+ fields
```

**Why**: Slices improve maintainability and separate concerns. For full slice patterns, see [references/patterns.md](./references/patterns.md).

---

### Pattern 4: Async Actions with Proper Loading States

```typescript
// ✅ Good: Track loading and error states
interface UserStore {
  user: User | null;
  isLoading: boolean;
  error: string | null;
  fetchUser: (id: string) => Promise<void>;
  clearError: () => void;
}

export const useUserStore = create<UserStore>((set, get) => ({
  user: null,
  isLoading: false,
  error: null,

  fetchUser: async (id) => {
    set({ isLoading: true, error: null });

    try {
      const response = await fetch(`/api/users/${id}`);
      
      if (!response.ok) {
        throw new Error('Failed to fetch user');
      }
      
      const user = await response.json();
      set({ user, isLoading: false });
    } catch (error) {
      set({
        error: error instanceof Error ? error.message : 'Unknown error',
        isLoading: false,
        user: null,
      });
    }
  },

  clearError: () => set({ error: null }),
}));

// Usage in component
export function UserProfile({ userId }: { userId: string }) {
  const { user, isLoading, error, fetchUser } = useUserStore(
    (state) => ({
      user: state.user,
      isLoading: state.isLoading,
      error: state.error,
      fetchUser: state.fetchUser,
    }),
    shallow
  );

  useEffect(() => {
    fetchUser(userId);
  }, [userId, fetchUser]);

  if (isLoading) return <div>Loading...</div>;
  if (error) return <div>Error: {error}</div>;
  if (!user) return <div>No user found</div>;

  return <div>{user.name}</div>;
}

// ❌ Bad: No loading or error states
export const useUserStore = create<UserStore>((set) => ({
  user: null,
  
  fetchUser: async (id) => {
    const response = await fetch(`/api/users/${id}`);
    const user = await response.json();
    set({ user }); // No indication of loading or errors
  },
}));
```

**Why**: Loading states provide UX feedback; error handling improves reliability; clear error makes debugging easier.

---

### Pattern 5: Middleware Usage

For data persistence, debugging, and state immutability, see [Middleware & Advanced](./references/middleware.md).

---

## Anti-Patterns

### Anti-Pattern 1: Using Zustand for Server State

```typescript
// ❌ Problem: Managing server data with Zustand
export const usePostsStore = create<PostsStore>((set) => ({
  posts: [],
  isLoading: false,
  
  fetchPosts: async () => {
    set({ isLoading: true });
    const posts = await fetch('/api/posts').then(r => r.json());
    set({ posts, isLoading: false });
  },
  
  updatePost: async (id, data) => {
    await fetch(`/api/posts/${id}`, { method: 'PUT', body: JSON.stringify(data) });
    // Manual cache invalidation...
  },
}));
```

**Why it's wrong**: Manual cache management; no automatic refetching; cache invalidation is hard; missing features like background refetch, deduplication.

**Solution**:
```typescript
// ✅ Use React Query for server state
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';

export function usePosts() {
  return useQuery({
    queryKey: ['posts'],
    queryFn: () => fetch('/api/posts').then(r => r.json()),
  });
}

export function useUpdatePost() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: (data) => fetch(`/api/posts/${data.id}`, {
      method: 'PUT',
      body: JSON.stringify(data),
    }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['posts'] }); // Auto refresh
    },
  });
}

// ✅ Use Zustand for UI/client state only
export const useUIStore = create((set) => ({
  sidebarOpen: false,
  theme: 'light',
  toggleSidebar: () => set((state) => ({ sidebarOpen: !state.sidebarOpen })),
}));
```

---

### Anti-Pattern 2: Not Memoizing Selectors

```typescript
// ❌ Problem: Creating new selectors on every render
const completedTodos = useStore((state) =>
  state.todos.filter(todo => todo.completed) // New array every time
);

// ✅ Solution: Use shallow comparison
import { shallow } from 'zustand/shallow';
const completedTodos = useStore(
  (state) => state.todos.filter(todo => todo.completed),
  shallow
);
```

**Why it's wrong**: Component re-renders even when filtered result is the same.

---

### Anti-Pattern 3: Overusing Global State

```typescript
// ❌ Problem: Form state in global store
export const useFormStore = create((set) => ({
  email: '', password: '',
  setEmail: (email) => set({ email }),
}));

// ✅ Solution: Use local state for component-specific data
export function LoginForm() {
  const [email, setEmail] = useState('');
  return <input value={email} onChange={(e) => setEmail(e.target.value)} />;
}
```

**Why it's wrong**: Unnecessary global state; harder to test; overkill for component-scoped data.

For more anti-patterns and solutions, see [references/patterns.md](./references/patterns.md).

---

## What This Skill Covers

- **Store creation** with TypeScript
- **React integration** with hooks
- **Middleware** (persist, devtools, immer)
- **Async actions** and selectors

For middleware, advanced patterns, and testing, see [references/](./references/).

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

  return (
    <div>
      <p>Count: {count}</p>
      <button onClick={increment}>+</button>
    </div>
  );
}
```

---

For async actions, selectors, and advanced patterns, see [references/patterns.md](./references/patterns.md).

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

// Get state outside React
const count = useStore.getState().count;

// Set state outside React
useStore.setState({ count: 5 });

// Subscribe to changes
const unsubscribe = useStore.subscribe(
  (state) => state.count,
  (count) => console.log(count)
);
```

---

## Learn More

- **Middleware & Advanced**: [references/middleware.md](./references/middleware.md) - Persist, devtools, immer, slices pattern
- **Performance & Testing**: [references/performance.md](./references/performance.md) - Optimization, SSR, testing patterns

---

## External References

- [Zustand Documentation](https://zustand.pmnd.rs/)
- [Zustand GitHub](https://github.com/pmndrs/zustand)

---

_Maintained by dsmj-ai-toolkit_
