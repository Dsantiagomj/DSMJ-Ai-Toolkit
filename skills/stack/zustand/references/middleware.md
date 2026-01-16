# Middleware & Advanced Patterns - Zustand

## Persist Middleware

```typescript
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';

interface UserStore {
  user: User | null;
  setUser: (user: User) => void;
  logout: () => void;
}

export const useUserStore = create<UserStore>()(
  persist(
    (set) => ({
      user: null,
      setUser: (user) => set({ user }),
      logout: () => set({ user: null }),
    }),
    {
      name: 'user-storage',
      storage: createJSONStorage(() => localStorage),
      // Partial persistence
      partialize: (state) => ({ user: state.user }),
      // Custom serialization
      serialize: (state) => JSON.stringify(state),
      deserialize: (str) => JSON.parse(str),
    }
  )
);
```

### SessionStorage

```typescript
persist(
  (set) => ({ /* ... */ }),
  {
    name: 'session-storage',
    storage: createJSONStorage(() => sessionStorage),
  }
)
```

### Custom Storage

```typescript
import { StateStorage } from 'zustand/middleware';

const customStorage: StateStorage = {
  getItem: async (name) => {
    const value = await AsyncStorage.getItem(name);
    return value ?? null;
  },
  setItem: async (name, value) => {
    await AsyncStorage.setItem(name, value);
  },
  removeItem: async (name) => {
    await AsyncStorage.removeItem(name);
  },
};

persist(
  (set) => ({ /* ... */ }),
  { name: 'app-storage', storage: createJSONStorage(() => customStorage) }
)
```

---

## DevTools Middleware

```typescript
import { devtools } from 'zustand/middleware';

interface CounterStore {
  count: number;
  increment: () => void;
}

export const useCounterStore = create<CounterStore>()(
  devtools(
    (set) => ({
      count: 0,
      increment: () => set((state) => ({ count: state.count + 1 }), false, 'increment'),
    }),
    {
      name: 'CounterStore',
      enabled: process.env.NODE_ENV === 'development',
    }
  )
);
```

### With Named Actions

```typescript
devtools(
  (set) => ({
    todos: [],
    addTodo: (text) => set(
      (state) => ({ todos: [...state.todos, { id: Date.now(), text }] }),
      false,
      'addTodo' // Action name in DevTools
    ),
    removeTodo: (id) => set(
      (state) => ({ todos: state.todos.filter(t => t.id !== id) }),
      false,
      { type: 'removeTodo', id } // Object for more details
    ),
  }),
  { name: 'TodoStore' }
)
```

---

## Immer Middleware

```typescript
import { immer } from 'zustand/middleware/immer';

interface TodoStore {
  todos: Todo[];
  addTodo: (text: string) => void;
  toggleTodo: (id: number) => void;
  updateTodo: (id: number, text: string) => void;
}

export const useTodoStore = create<TodoStore>()(
  immer((set) => ({
    todos: [],

    addTodo: (text) => set((state) => {
      state.todos.push({ id: Date.now(), text, completed: false });
    }),

    toggleTodo: (id) => set((state) => {
      const todo = state.todos.find(t => t.id === id);
      if (todo) todo.completed = !todo.completed;
    }),

    updateTodo: (id, text) => set((state) => {
      const todo = state.todos.find(t => t.id === id);
      if (todo) todo.text = text;
    }),
  }))
);
```

---

## Combining Middleware

```typescript
import { create } from 'zustand';
import { persist, devtools } from 'zustand/middleware';
import { immer } from 'zustand/middleware/immer';

interface Store {
  count: number;
  increment: () => void;
}

export const useStore = create<Store>()(
  devtools(
    persist(
      immer((set) => ({
        count: 0,
        increment: () => set((state) => { state.count += 1; }),
      })),
      { name: 'counter-storage' }
    ),
    { name: 'CounterStore' }
  )
);
```

---

## Slices Pattern

```typescript
import { StateCreator } from 'zustand';

// User slice
interface UserSlice {
  user: User | null;
  setUser: (user: User) => void;
}

const createUserSlice: StateCreator<
  UserSlice & TodoSlice & SettingsSlice,
  [],
  [],
  UserSlice
> = (set) => ({
  user: null,
  setUser: (user) => set({ user }),
});

// Todo slice
interface TodoSlice {
  todos: Todo[];
  addTodo: (text: string) => void;
}

const createTodoSlice: StateCreator<
  UserSlice & TodoSlice & SettingsSlice,
  [],
  [],
  TodoSlice
> = (set) => ({
  todos: [],
  addTodo: (text) => set((state) => ({
    todos: [...state.todos, { id: Date.now(), text }]
  })),
});

// Settings slice
interface SettingsSlice {
  theme: 'light' | 'dark';
  toggleTheme: () => void;
}

const createSettingsSlice: StateCreator<
  UserSlice & TodoSlice & SettingsSlice,
  [],
  [],
  SettingsSlice
> = (set) => ({
  theme: 'light',
  toggleTheme: () => set((state) => ({
    theme: state.theme === 'light' ? 'dark' : 'light'
  })),
});

// Combine slices
export const useStore = create<UserSlice & TodoSlice & SettingsSlice>()(
  (...a) => ({
    ...createUserSlice(...a),
    ...createTodoSlice(...a),
    ...createSettingsSlice(...a),
  })
);
```

### Using Slices

```typescript
// Each component only subscribes to its slice
function UserProfile() {
  const user = useStore((state) => state.user);
  const setUser = useStore((state) => state.setUser);
  return <div>{user?.name}</div>;
}

function TodoList() {
  const todos = useStore((state) => state.todos);
  const addTodo = useStore((state) => state.addTodo);
  return <ul>{todos.map(t => <li key={t.id}>{t.text}</li>)}</ul>;
}
```

---

## Subscriptions

```typescript
// Subscribe to entire store
const unsubscribe = useStore.subscribe((state) => {
  console.log('State changed:', state);
});

// Subscribe to specific value
const unsubscribe = useStore.subscribe(
  (state) => state.count,
  (count, prevCount) => {
    console.log('Count changed from', prevCount, 'to', count);
  }
);

// Cleanup
unsubscribe();
```

### React Effect Subscription

```typescript
import { useEffect } from 'react';

function Component() {
  useEffect(() => {
    const unsubscribe = useStore.subscribe(
      (state) => state.user,
      (user) => {
        if (user) {
          // Sync to analytics
          analytics.identify(user.id);
        }
      }
    );

    return unsubscribe;
  }, []);

  return <div>...</div>;
}
```

---

## Computed Values

```typescript
interface Store {
  todos: Todo[];
  getTodoCount: () => number;
  getCompletedCount: () => number;
  getActiveCount: () => number;
}

export const useTodoStore = create<Store>((set, get) => ({
  todos: [],

  // Computed getters
  getTodoCount: () => get().todos.length,
  getCompletedCount: () => get().todos.filter(t => t.completed).length,
  getActiveCount: () => get().todos.filter(t => !t.completed).length,
}));

// Usage
const totalCount = useTodoStore((state) => state.getTodoCount());
const completedCount = useTodoStore((state) => state.getCompletedCount());
```

### With Selectors

```typescript
// Create derived selector
const selectCompletedTodos = (state: Store) =>
  state.todos.filter(t => t.completed);

const selectActiveTodos = (state: Store) =>
  state.todos.filter(t => !t.completed);

// Use in components
const completedTodos = useTodoStore(selectCompletedTodos);
const activeTodos = useTodoStore(selectActiveTodos);
```
