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
