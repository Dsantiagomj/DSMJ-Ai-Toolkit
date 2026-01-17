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
// stores/slices/user-slice.ts
export interface UserSlice {
  user: User | null;
  setUser: (user: User) => void;
  clearUser: () => void;
}

export const createUserSlice: StateCreator<
  StoreState,
  [],
  [],
  UserSlice
> = (set) => ({
  user: null,
  setUser: (user) => set({ user }),
  clearUser: () => set({ user: null }),
});

// stores/slices/settings-slice.ts
export interface SettingsSlice {
  theme: 'light' | 'dark';
  language: string;
  setTheme: (theme: 'light' | 'dark') => void;
  setLanguage: (language: string) => void;
}

export const createSettingsSlice: StateCreator<
  StoreState,
  [],
  [],
  SettingsSlice
> = (set) => ({
  theme: 'light',
  language: 'en',
  setTheme: (theme) => set({ theme }),
  setLanguage: (language) => set({ language }),
});

// stores/index.ts
type StoreState = UserSlice & SettingsSlice;

export const useStore = create<StoreState>()((...a) => ({
  ...createUserSlice(...a),
  ...createSettingsSlice(...a),
}));

// ❌ Bad: One massive store object
export const useStore = create((set) => ({
  user: null,
  theme: 'light',
  language: 'en',
  posts: [],
  comments: [],
  notifications: [],
  // 50+ more fields...
  // 100+ actions...
}));
```

**Why**: Slices improve maintainability; separate concerns; easier testing; better code organization.

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

### Pattern 5: Persist Middleware for Data Persistence

```typescript
// ✅ Good: Persist specific state to localStorage
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';

interface SettingsStore {
  theme: 'light' | 'dark';
  language: string;
  notifications: boolean;
  setTheme: (theme: 'light' | 'dark') => void;
  setLanguage: (language: string) => void;
  toggleNotifications: () => void;
}

export const useSettingsStore = create<SettingsStore>()(
  persist(
    (set) => ({
      theme: 'light',
      language: 'en',
      notifications: true,
      
      setTheme: (theme) => set({ theme }),
      setLanguage: (language) => set({ language }),
      toggleNotifications: () => set((state) => ({ 
        notifications: !state.notifications 
      })),
    }),
    {
      name: 'settings-storage', // localStorage key
      storage: createJSONStorage(() => localStorage),
      partialize: (state) => ({ 
        theme: state.theme,
        language: state.language,
        notifications: state.notifications,
        // Don't persist actions
      }),
    }
  )
);

// ✅ Good: Custom storage (e.g., IndexedDB)
import { StateStorage } from 'zustand/middleware';

const indexedDBStorage: StateStorage = {
  getItem: async (name) => {
    const value = await getFromIndexedDB(name);
    return value || null;
  },
  setItem: async (name, value) => {
    await saveToIndexedDB(name, value);
  },
  removeItem: async (name) => {
    await deleteFromIndexedDB(name);
  },
};

export const useDataStore = create<DataStore>()(
  persist(
    (set) => ({ /* ... */ }),
    {
      name: 'app-data',
      storage: indexedDBStorage,
    }
  )
);

// ❌ Bad: Persisting everything including functions
export const useStore = create(
  persist(
    (set) => ({
      data: [],
      fetchData: async () => { /* ... */ }, // Functions can't be serialized!
    }),
    { name: 'store' }
  )
);
```

**Why**: Persist middleware simplifies state persistence; partialize prevents serialization errors; custom storage allows flexibility.

---

### Pattern 6: DevTools for Debugging

```typescript
// ✅ Good: Enable DevTools in development
import { devtools } from 'zustand/middleware';

export const useStore = create<Store>()(
  devtools(
    (set) => ({
      count: 0,
      increment: () => set((state) => ({ count: state.count + 1 }), false, 'increment'),
      decrement: () => set((state) => ({ count: state.count - 1 }), false, 'decrement'),
    }),
    { name: 'CounterStore' }
  )
);

// ✅ Good: Combine middleware
export const useStore = create<Store>()(
  devtools(
    persist(
      (set) => ({ /* ... */ }),
      { name: 'store-storage' }
    ),
    { name: 'MyStore' }
  )
);

// ❌ Bad: No debugging tools
export const useStore = create((set) => ({
  // Complex state logic with no way to debug
}));
```

**Why**: DevTools enable time-travel debugging; action names help track state changes; essential for complex apps.

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
export function TodoList() {
  const completedTodos = useStore((state) => 
    state.todos.filter(todo => todo.completed) // New array every time
  );

  return (
    <div>
      {completedTodos.map(todo => <Todo key={todo.id} todo={todo} />)}
    </div>
  );
}
```

**Why it's wrong**: Component re-renders even when filtered result is the same; performance issues with large lists.

**Solution**:
```typescript
// ✅ Use shallow comparison for derived state
import { shallow } from 'zustand/shallow';

export function TodoList() {
  const completedTodos = useStore(
    (state) => state.todos.filter(todo => todo.completed),
    shallow
  );

  return (
    <div>
      {completedTodos.map(todo => <Todo key={todo.id} todo={todo} />)}
    </div>
  );
}

// ✅ Or memoize with useMemo
export function TodoList() {
  const todos = useStore((state) => state.todos);
  
  const completedTodos = useMemo(
    () => todos.filter(todo => todo.completed),
    [todos]
  );

  return (
    <div>
      {completedTodos.map(todo => <Todo key={todo.id} todo={todo} />)}
    </div>
  );
}

// ✅ Or create derived state in the store
export const useTodoStore = create<TodoStore>((set, get) => ({
  todos: [],
  
  addTodo: (text) => set((state) => ({
    todos: [...state.todos, { id: Date.now(), text, completed: false }],
  })),
  
  // Getter function (doesn't cause re-renders)
  getCompletedTodos: () => get().todos.filter(t => t.completed),
}));

// Use it
const getCompletedTodos = useTodoStore((state) => state.getCompletedTodos);
const completedTodos = getCompletedTodos(); // Called in render
```

---

### Anti-Pattern 3: Overusing Global State

```typescript
// ❌ Problem: Everything in global state
export const useFormStore = create((set) => ({
  email: '',
  password: '',
  confirmPassword: '',
  setEmail: (email) => set({ email }),
  setPassword: (password) => set({ password }),
  setConfirmPassword: (confirmPassword) => set({ confirmPassword }),
}));

export function LoginForm() {
  const email = useFormStore((state) => state.email);
  const setEmail = useFormStore((state) => state.setEmail);
  // ... more fields
}
```

**Why it's wrong**: Unnecessary global state; harder to test; form state should be local; overkill for component-scoped data.

**Solution**:
```typescript
// ✅ Use local state for component-specific data
export function LoginForm() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    await login(email, password);
  };

  return (
    <form onSubmit={handleSubmit}>
      <input value={email} onChange={(e) => setEmail(e.target.value)} />
      <input value={password} onChange={(e) => setPassword(e.target.value)} />
      <button type="submit">Login</button>
    </form>
  );
}

// ✅ Use Zustand only for truly global state
export const useAuthStore = create((set) => ({
  user: null,
  isAuthenticated: false,
  login: (user) => set({ user, isAuthenticated: true }),
  logout: () => set({ user: null, isAuthenticated: false }),
}));
```

---

### Anti-Pattern 4: Direct Store Manipulation Outside React

```typescript
// ❌ Problem: Mutating store directly
export const useStore = create((set) => ({
  count: 0,
  increment: () => set((state) => ({ count: state.count + 1 })),
}));

// Somewhere outside React
useStore.getState().count = 10; // Direct mutation!
```

**Why it's wrong**: Breaks reactivity; components don't re-render; state becomes inconsistent; debugging nightmare.

**Solution**:
```typescript
// ✅ Always use setState or actions
export const useStore = create<Store>((set) => ({
  count: 0,
  increment: () => set((state) => ({ count: state.count + 1 })),
  setCount: (count) => set({ count }),
}));

// Outside React
useStore.getState().setCount(10); // Use action

// Or use setState directly
useStore.setState({ count: 10 });

// ✅ Subscribe to changes outside React
const unsubscribe = useStore.subscribe(
  (state) => state.count,
  (count) => console.log('Count changed:', count)
);

// Cleanup
unsubscribe();
```

---

### Anti-Pattern 5: Not Cleaning Up Subscriptions

```typescript
// ❌ Problem: Manual subscriptions without cleanup
useEffect(() => {
  const unsubscribe = useStore.subscribe(
    (state) => state.user,
    (user) => console.log('User:', user)
  );
  
  // Missing cleanup!
}, []);
```

**Why it's wrong**: Memory leaks; subscriptions keep firing after unmount; performance degradation.

**Solution**:
```typescript
// ✅ Return cleanup function
useEffect(() => {
  const unsubscribe = useStore.subscribe(
    (state) => state.user,
    (user) => console.log('User:', user)
  );
  
  return () => unsubscribe(); // Cleanup on unmount
}, []);

// ✅ Better: use the hook (auto-cleanup)
const user = useStore((state) => state.user);

useEffect(() => {
  console.log('User:', user);
}, [user]);
```

---

### Anti-Pattern 6: Storing Non-Serializable Data

```typescript
// ❌ Problem: Storing functions, class instances, or DOM nodes
export const useStore = create((set) => ({
  callback: () => console.log('hello'), // Function
  socket: new WebSocket('ws://...'), // Class instance
  element: document.getElementById('root'), // DOM node
}));
```

**Why it's wrong**: Can't use persist middleware; breaks serialization; causes bugs with SSR; hard to debug.

**Solution**:
```typescript
// ✅ Store only serializable data
export const useStore = create((set) => ({
  // Serializable data only
  socketUrl: 'ws://...',
  socketStatus: 'disconnected' as 'connected' | 'disconnected',
  
  // Actions are fine (not part of state)
  connect: () => {
    const socket = new WebSocket(useStore.getState().socketUrl);
    // Use socket, but don't store it
    socket.onopen = () => set({ socketStatus: 'connected' });
  },
}));

// ✅ Keep non-serializable objects outside store
let socket: WebSocket | null = null;

export const useSocketStore = create((set) => ({
  status: 'disconnected',
  
  connect: () => {
    socket = new WebSocket('ws://...');
    socket.onopen = () => set({ status: 'connected' });
  },
  
  send: (message) => {
    socket?.send(message);
  },
  
  disconnect: () => {
    socket?.close();
    socket = null;
    set({ status: 'disconnected' });
  },
}));
```

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

## Async Actions

```typescript
interface UserStore {
  user: User | null;
  isLoading: boolean;
  error: string | null;
  fetchUser: (id: string) => Promise<void>;
}

export const useUserStore = create<UserStore>((set, get) => ({
  user: null,
  isLoading: false,
  error: null,

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

---

## Selectors

```typescript
// ❌ Bad: Re-renders on any state change
const store = useStore();

// ✅ Good: Only re-renders when count changes
const count = useStore((state) => state.count);
const increment = useStore((state) => state.increment);

// ✅ Good: Multiple values with shallow comparison
import { shallow } from 'zustand/shallow';

const { user, isLoading } = useUserStore(
  (state) => ({ user: state.user, isLoading: state.isLoading }),
  shallow
);
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
