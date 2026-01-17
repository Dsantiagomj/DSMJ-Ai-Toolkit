# Zustand Advanced Patterns

Advanced patterns for complex state management scenarios.

---

## Server State vs Client State

### Don't Use Zustand for Server State

```typescript
// ❌ Bad: Managing server data with Zustand
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

// ✅ Good: Use React Query for server state
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
      queryClient.invalidateQueries({ queryKey: ['posts'] });
    },
  });
}

// ✅ Good: Use Zustand only for UI/client state
export const useUIStore = create((set) => ({
  sidebarOpen: false,
  theme: 'light',
  toggleSidebar: () => set((state) => ({ sidebarOpen: !state.sidebarOpen })),
}));
```

---

## State Colocation

```typescript
// ❌ Bad: Global state for local concerns
export const useFormStore = create((set) => ({
  email: '',
  password: '',
  confirmPassword: '',
  setEmail: (email) => set({ email }),
  setPassword: (password) => set({ password }),
  setConfirmPassword: (confirmPassword) => set({ confirmPassword }),
}));

// ✅ Good: Use local state for component-specific data
export function LoginForm() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  return (
    <form>
      <input value={email} onChange={(e) => setEmail(e.target.value)} />
      <input value={password} onChange={(e) => setPassword(e.target.value)} />
    </form>
  );
}

// ✅ Good: Zustand only for truly global state
export const useAuthStore = create((set) => ({
  user: null,
  isAuthenticated: false,
  login: (user) => set({ user, isAuthenticated: true }),
  logout: () => set({ user: null, isAuthenticated: false }),
}));
```

---

## Transient Updates

```typescript
// For updates that don't need to trigger React re-renders
export const useStore = create<Store>((set, get) => ({
  count: 0,

  // Regular update (triggers re-render)
  increment: () => set((state) => ({ count: state.count + 1 })),

  // Transient update (no re-render)
  incrementSilent: () => {
    const state = get();
    useStore.setState({ count: state.count + 1 }, true); // true = replace
  },
}));
```

---

## Resetting State

```typescript
interface Store {
  count: number;
  user: User | null;
  settings: Settings;
  reset: () => void;
  resetUser: () => void;
}

const initialState = {
  count: 0,
  user: null,
  settings: { theme: 'light', language: 'en' },
};

export const useStore = create<Store>((set) => ({
  ...initialState,

  increment: () => set((state) => ({ count: state.count + 1 })),
  setUser: (user) => set({ user }),

  // Reset entire store
  reset: () => set(initialState),

  // Reset specific slice
  resetUser: () => set({ user: null }),
}));
```

---

## Middleware Patterns

### Custom Middleware

```typescript
import { StateCreator, StoreMutatorIdentifier } from 'zustand';

// Logger middleware
export const logger = <
  T,
  Mps extends [StoreMutatorIdentifier, unknown][] = [],
  Mcs extends [StoreMutatorIdentifier, unknown][] = []
>(
  config: StateCreator<T, Mps, Mcs>
): StateCreator<T, Mps, Mcs> => {
  return (set, get, api) =>
    config(
      (...args) => {
        console.log('  applying', args);
        set(...args);
        console.log('  new state', get());
      },
      get,
      api
    );
};

// Use it
export const useStore = create<Store>()(
  logger((set) => ({
    count: 0,
    increment: () => set((state) => ({ count: state.count + 1 })),
  }))
);
```

### Conditional Middleware

```typescript
import { devtools, persist } from 'zustand/middleware';

export const useStore = create<Store>()(
  // Only use devtools in development
  process.env.NODE_ENV === 'development'
    ? devtools(
        persist(
          (set) => ({ /* ... */ }),
          { name: 'store' }
        )
      )
    : persist(
        (set) => ({ /* ... */ }),
        { name: 'store' }
      )
);
```

---

## Testing Patterns

### Resetting Store Between Tests

```typescript
import { act, renderHook } from '@testing-library/react';
import { useStore } from './store';

describe('useStore', () => {
  beforeEach(() => {
    // Reset store before each test
    useStore.setState({ count: 0 });
  });

  it('increments count', () => {
    const { result } = renderHook(() => useStore());

    act(() => {
      result.current.increment();
    });

    expect(result.current.count).toBe(1);
  });
});
```

### Testing Actions Directly

```typescript
import { useStore } from './store';

describe('store actions', () => {
  it('adds item to cart', () => {
    const { addItem } = useStore.getState();

    addItem({ id: '1', name: 'Product', price: 10 });

    const { items } = useStore.getState();
    expect(items).toHaveLength(1);
    expect(items[0].name).toBe('Product');
  });
});
```

---

## SSR and Next.js

### Server-Side Rendering

```typescript
import { create } from 'zustand';

// Create store factory
export const createStore = (initialState = {}) => {
  return create<Store>((set) => ({
    count: 0,
    ...initialState,
    increment: () => set((state) => ({ count: state.count + 1 })),
  }));
};

// Client-side singleton
let store;

export const useStore = () => {
  if (!store) {
    store = createStore();
  }
  return store();
};
```

### With Next.js App Router

```typescript
'use client';

import { create } from 'zustand';
import { persist } from 'zustand/middleware';

export const useStore = create<Store>()(
  persist(
    (set) => ({
      count: 0,
      increment: () => set((state) => ({ count: state.count + 1 })),
    }),
    {
      name: 'store',
      // Skip hydration check (optional)
      skipHydration: true,
    }
  )
);

// Hydrate on client
if (typeof window !== 'undefined') {
  useStore.persist.rehydrate();
}
```

---

## Performance Optimization

### Selector Optimization

```typescript
// ❌ Bad: New object on every selector call
const { user, isLoading } = useStore((state) => ({
  user: state.user,
  isLoading: state.isLoading,
}));

// ✅ Good: Use shallow comparison
import { shallow } from 'zustand/shallow';

const { user, isLoading } = useStore(
  (state) => ({ user: state.user, isLoading: state.isLoading }),
  shallow
);

// ✅ Good: Separate selectors
const user = useStore((state) => state.user);
const isLoading = useStore((state) => state.isLoading);
```

### Batching Updates

```typescript
// Multiple updates in one render cycle
export const useStore = create<Store>((set) => ({
  items: [],
  total: 0,

  addMultipleItems: (newItems) => set((state) => {
    const items = [...state.items, ...newItems];
    const total = items.reduce((sum, i) => sum + i.price, 0);

    // Single update, single re-render
    return { items, total };
  }),
}));
```

---

_Back to main: [SKILL.md](../SKILL.md)_
