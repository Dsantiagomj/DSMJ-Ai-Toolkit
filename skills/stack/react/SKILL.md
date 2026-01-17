---
name: react
description: >
  Modern React patterns with Server Components, Actions, and hooks.
  Trigger: When writing React components, when creating JSX files, when implementing hooks, when using Server Components or Actions.
tags: [react, frontend, javascript, typescript, ui, components, server-components, hooks]
author: dsmj-ai-toolkit
metadata:
  auto_invoke: "Writing React components, JSX files, hooks, or React-specific code"
  stack_category: frontend
  progressive_disclosure: true
  version: "1.0"
  last_updated: "2026-01-17"
  category: stack
references:
  - name: Server Components
    url: ./references/server-components.md
    type: local
  - name: Hooks Reference
    url: ./references/hooks.md
    type: local
  - name: Performance
    url: ./references/performance.md
    type: local
  - name: Best Practices
    url: ./references/best-practices.md
    type: local
  - name: TypeScript Patterns
    url: ./references/typescript.md
    type: local
---

# React - Modern Patterns

**Server Components, Actions, and concurrent features for modern React applications**

---

## When to Use This Skill

**Use this skill when**:
- Building user interfaces with React (any version, with focus on React 19 features)
- Implementing Server Components in Next.js or React Server Components framework
- Creating interactive client-side components with hooks
- Building forms with Server Actions
- Optimizing React application performance
- Working with concurrent React features (Suspense, Transitions, etc.)

**Don't use this skill when**:
- Building static HTML sites without interactivity (use vanilla HTML/CSS)
- Working with other frameworks (Vue, Svelte, Angular - use their respective skills)
- Building server-only APIs (use backend skills like tRPC, Express)
- Implementing routing in Next.js (use the `nextjs` skill instead)

---

## Critical Patterns

### Pattern 1: Server vs Client Component Boundary

**When**: Every React component in modern frameworks (Next.js 13+, React 19)

**Good**:
```tsx
// app/dashboard/page.tsx - Server Component (default)
export default async function Dashboard() {
  // ✅ Direct data fetching on server
  const stats = await db.stats.findMany()

  return (
    <div>
      <h1>Dashboard</h1>
      {/* ✅ Pass data to client component */}
      <InteractiveChart data={stats} />
    </div>
  )
}

// components/InteractiveChart.tsx - Client Component
'use client'
import { useState } from 'react'

export function InteractiveChart({ data }: { data: Stat[] }) {
  const [filter, setFilter] = useState('all')
  // ✅ Interactivity only where needed
  return <Chart data={data} filter={filter} onFilterChange={setFilter} />
}
```

**Bad**:
```tsx
// ❌ Making everything a client component
'use client'
import { useEffect, useState } from 'react'

export default function Dashboard() {
  const [stats, setStats] = useState([])

  // ❌ Client-side data fetching (slower, requires API route)
  useEffect(() => {
    fetch('/api/stats').then(r => r.json()).then(setStats)
  }, [])

  return <div>{/* ... */}</div>
}
```

**Why**: Server Components reduce JavaScript bundle size, enable direct database access, and improve initial page load. Client Components should only be used for interactivity.

---

### Pattern 2: State Colocation and Lifting

**When**: Managing state across multiple components

**Good**:
```tsx
// ✅ State colocated with usage
function SearchBar() {
  const [query, setQuery] = useState('')
  // State lives where it's used
  return <input value={query} onChange={(e) => setQuery(e.target.value)} />
}

// ✅ Lift state only when shared
function FilteredList() {
  const [filter, setFilter] = useState('')

  return (
    <>
      <SearchInput value={filter} onChange={setFilter} />
      <ResultsList filter={filter} />
    </>
  )
}
```

**Bad**:
```tsx
// ❌ Premature state lifting (props drilling)
function App() {
  // ❌ State at top level when only SearchBar needs it
  const [query, setQuery] = useState('')

  return <Layout><Header><Nav><SearchBar query={query} setQuery={setQuery} /></Nav></Header></Layout>
}
```

**Why**: Keep state as close to where it's used as possible. Only lift state when multiple components truly need to share it. This improves performance and maintainability.

---

### Pattern 3: Effect Dependencies and Cleanup

**When**: Using useEffect for side effects

**Good**:
```tsx
'use client'
import { useEffect, useState } from 'react'

function ChatRoom({ roomId }: { roomId: string }) {
  const [messages, setMessages] = useState<Message[]>([])

  useEffect(() => {
    const socket = new WebSocket(`wss://chat.example.com/${roomId}`)

    socket.onmessage = (event) => {
      setMessages(prev => [...prev, JSON.parse(event.data)])
    }

    // ✅ Cleanup on unmount or dependency change
    return () => {
      socket.close()
    }
  }, [roomId]) // ✅ Correct dependencies

  return <MessageList messages={messages} />
}
```

**Bad**:
```tsx
// ❌ Missing cleanup and wrong dependencies
function ChatRoom({ roomId }: { roomId: string }) {
  const [messages, setMessages] = useState<Message[]>([])

  useEffect(() => {
    const socket = new WebSocket(`wss://chat.example.com/${roomId}`)

    socket.onmessage = (event) => {
      // ❌ Memory leak: old sockets never closed
      setMessages(prev => [...prev, JSON.parse(event.data)])
    }
    // ❌ No cleanup function
  }, []) // ❌ Missing roomId dependency - socket won't reconnect

  return <MessageList messages={messages} />
}
```

**Why**: Missing cleanup causes memory leaks. Incorrect dependencies cause stale closures and bugs. Always clean up subscriptions, timers, and listeners.

---

### Pattern 4: Memoization for Performance

**When**: Expensive calculations or preventing unnecessary re-renders

**Good**:
```tsx
'use client'
import { useMemo, useCallback, memo } from 'react'

// ✅ Memoize expensive calculations
function DataTable({ data, filter }: Props) {
  const filteredData = useMemo(() => {
    // Only recalculates when data or filter changes
    return data.filter(item => item.name.includes(filter))
  }, [data, filter])

  // ✅ Memoize callbacks passed to children
  const handleDelete = useCallback((id: string) => {
    deleteItem(id)
  }, [])

  return <Table data={filteredData} onDelete={handleDelete} />
}

// ✅ Memo for expensive child components
const ExpensiveRow = memo(({ item }: { item: Item }) => {
  const processedData = expensiveProcessing(item)
  return <tr>{processedData}</tr>
})
```

**Bad**:
```tsx
// ❌ No memoization - expensive calculation on every render
function DataTable({ data, filter }: Props) {
  // ❌ Runs on every render, even when data/filter unchanged
  const filteredData = data.filter(item => item.name.includes(filter))

  // ❌ New function instance on every render
  const handleDelete = (id: string) => deleteItem(id)

  return <Table data={filteredData} onDelete={handleDelete} />
}
```

**Why**: Memoization prevents unnecessary recalculations and re-renders. Critical for performance in data-heavy applications.

---

## Anti-Patterns

### ❌ Anti-Pattern 1: Prop Drilling

**Don't do this**:
```tsx
// ❌ Passing props through many levels
function App() {
  const [user, setUser] = useState(null)
  return <Layout user={user} setUser={setUser} />
}

function Layout({ user, setUser }) {
  return <Sidebar user={user} setUser={setUser} />
}

function Sidebar({ user, setUser }) {
  return <UserMenu user={user} setUser={setUser} />
}

function UserMenu({ user, setUser }) {
  return <div>{user.name}</div>
}
```

**Why it's bad**: Difficult to maintain, all intermediate components must know about props they don't use, breaks component encapsulation.

**Do this instead**:
```tsx
// ✅ Use Context for global state
import { createContext, useContext, useState } from 'react'

const UserContext = createContext(null)

function App() {
  const [user, setUser] = useState(null)
  return (
    <UserContext.Provider value={{ user, setUser }}>
      <Layout />
    </UserContext.Provider>
  )
}

function UserMenu() {
  const { user } = useContext(UserContext)
  return <div>{user.name}</div>
}
```

---

### ❌ Anti-Pattern 2: Large useEffect with Multiple Responsibilities

```tsx
// ❌ One effect doing too many things
useEffect(() => {
  fetch('/api/user').then(setUser)
  const socket = new WebSocket('ws://...')
  const timer = setInterval(() => refreshData(), 5000)
  analytics.track('page_view')
  return () => { socket.close(); clearInterval(timer); }
}, []) // What dependencies are needed? Unclear!

// ✅ Separate effects for separate concerns
useEffect(() => fetch('/api/user').then(setUser), [])
useEffect(() => {
  const socket = new WebSocket('ws://...')
  return () => socket.close()
}, [handleMessage])
```

---

### ❌ Anti-Pattern 3: Mutating State Directly

```tsx
// ❌ Mutating state directly
const addTodo = (text) => {
  todos.push({ id: Date.now(), text }) // ❌ Direct mutation
  setTodos(todos) // ❌ React won't detect the change
}

// ✅ Create new state objects
const addTodo = (text) => {
  setTodos([...todos, { id: Date.now(), text }]) // ✅ New array
}
```

For more anti-patterns and best practices, see [references/best-practices.md](./references/best-practices.md).

---

## What This Skill Covers

- **Server Components** (default in React 19)
- **Client Components** (use client)
- **Server Actions** for forms and mutations
- **Modern Hooks** (useState, useEffect, new React 19 hooks)
- **Performance** optimization patterns

For detailed patterns, hooks reference, and advanced techniques, see [references/](./references/).

---

## Server vs Client Components

### Server Components (Default)

```tsx
// app/dashboard/page.tsx
// ✅ Server Component (default, no directive needed)
export default async function Dashboard() {
  const data = await fetchData() // Direct data fetching
  return <DashboardUI data={data} />
}
```

**Use Server Components for**:
- Data fetching
- Direct database access
- Static content rendering
- SEO-critical content

**Benefits**:
- Zero JavaScript sent to client
- No API layer needed
- Better performance
- Automatic code splitting

### Client Components

```tsx
'use client'
import { useState } from 'react'

export default function Counter() {
  const [count, setCount] = useState(0)
  return (
    <button onClick={() => setCount(count + 1)}>
      Count: {count}
    </button>
  )
}
```

**Use Client Components for**:
- Event handlers (`onClick`, `onChange`, etc.)
- React hooks (`useState`, `useEffect`, etc.)
- Browser APIs (`window`, `localStorage`, etc.)
- Third-party libraries using browser APIs

---

## Server Actions

```tsx
// app/actions.ts
'use server'
export async function createUser(formData: FormData) {
  await db.users.create({ name: formData.get('name') })
  revalidatePath('/users')
}

// app/users/page.tsx
import { createUser } from './actions'
export default function UsersPage() {
  return (
    <form action={createUser}>
      <input name="name" required />
      <button type="submit">Create User</button>
    </form>
  )
}
```

For advanced Server Actions patterns, see [references/server-components.md](./references/server-components.md).

---

## Essential Hooks

### useState

```tsx
'use client'
import { useState } from 'react'

export function Form() {
  const [value, setValue] = useState('')

  // Functional updates
  const increment = () => setCount(prev => prev + 1)

  return (
    <input
      value={value}
      onChange={(e) => setValue(e.target.value)}
    />
  )
}
```

### useEffect

```tsx
'use client'
import { useEffect, useState } from 'react'

export function Timer() {
  const [seconds, setSeconds] = useState(0)

  useEffect(() => {
    const interval = setInterval(() => {
      setSeconds(s => s + 1)
    }, 1000)

    // Cleanup
    return () => clearInterval(interval)
  }, []) // Empty deps = run once

  return <div>{seconds}s</div>
}
```

For advanced hooks (useOptimistic, useTransition, custom hooks), see [references/hooks.md](./references/hooks.md).

---

## Component Patterns & Performance

For composition patterns, TypeScript props, React.memo, and performance optimization, see:
- [references/typescript.md](./references/typescript.md) - TypeScript patterns and props
- [references/performance.md](./references/performance.md) - Optimization techniques

---

## Quick Reference

```tsx
// Server Component (default)
export default async function Page() {
  const data = await fetchData()
  return <div>{data}</div>
}

// Client Component
'use client'
export default function Interactive() {
  const [state, setState] = useState(0)
  return <button onClick={() => setState(state + 1)}>{state}</button>
}

// Server Action
'use server'
export async function submitForm(formData: FormData) {
  await db.create(formData)
  revalidatePath('/items')
}

// Hooks
useState(initial)              // State management
useEffect(() => {}, [deps])    // Side effects
useMemo(() => value, [deps])   // Memoize values
useCallback(() => {}, [deps])  // Memoize callbacks
useOptimistic(state, updater)  // Optimistic UI
useTransition()                // Non-blocking updates
```

---

## Learn More

- **Server Components**: [references/server-components.md](./references/server-components.md) - Deep dive, streaming, Suspense
- **Hooks Reference**: [references/hooks.md](./references/hooks.md) - Complete hooks API and patterns
- **Performance**: [references/performance.md](./references/performance.md) - Advanced optimization
- **Best Practices**: [references/best-practices.md](./references/best-practices.md) - Anti-patterns, error handling
- **TypeScript**: [references/typescript.md](./references/typescript.md) - Advanced TypeScript patterns

---

_For Next.js-specific routing, layouts, and app directory patterns, reference the `nextjs` skill._
