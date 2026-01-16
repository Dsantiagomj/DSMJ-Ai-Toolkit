---
name: react
description: Modern React patterns with Server Components, Actions, and hooks. Use when writing React components, JSX files, or working with React-specific features.
tags: [react, frontend, javascript, typescript, ui, components, server-components, hooks]
author: dsmj-ai-toolkit
metadata:
  auto_invoke: "Writing React components, JSX files, hooks, or React-specific code"
  stack_category: frontend
  progressive_disclosure: true
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
  const name = formData.get('name')
  await db.users.create({ name })
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

**Benefits**:
- No API routes needed
- Type-safe with TypeScript
- Progressive enhancement
- Automatic revalidation

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

### useOptimistic (React 19)

```tsx
'use client'
import { useOptimistic } from 'react'
import { sendMessage } from './actions'

export function Messages({ messages }: { messages: Message[] }) {
  const [optimisticMessages, addOptimistic] = useOptimistic(
    messages,
    (state, newMessage: string) => [
      ...state,
      { text: newMessage, sending: true }
    ]
  )

  async function formAction(formData: FormData) {
    const message = formData.get('message') as string
    addOptimistic(message)
    await sendMessage(message)
  }

  return (
    <form action={formAction}>
      {optimisticMessages.map((msg, i) => (
        <div key={i} className={msg.sending ? 'opacity-50' : ''}>
          {msg.text}
        </div>
      ))}
      <input name="message" />
    </form>
  )
}
```

---

## Component Patterns

### Composition

```tsx
// ✅ Good: Composition over configuration
<Modal onClose={handleClose}>
  <Modal.Header>
    <Modal.Title>Settings</Modal.Title>
  </Modal.Header>
  <Modal.Content>{/* ... */}</Modal.Content>
</Modal>

// ❌ Bad: Too many props
<Modal
  showCloseButton={true}
  closeButtonPosition="top-right"
  closeButtonColor="red"
  onClose={handleClose}
/>
```

### TypeScript Props

```tsx
// Simple inline props
export default function Button({ label, onClick }: {
  label: string
  onClick: () => void
}) {
  return <button onClick={onClick}>{label}</button>
}

// Complex props with interface
interface UserCardProps {
  user: {
    name: string
    email: string
    avatar?: string
  }
  showEmail?: boolean
  onEdit?: (id: string) => void
}

export default function UserCard({ user, showEmail = true }: UserCardProps) {
  return <div>{user.name}</div>
}
```

---

## Performance Basics

### React.memo

```tsx
import { memo } from 'react'

// ✅ Memo for expensive components
export default memo(function ExpensiveChart({ data }: { data: number[] }) {
  const processed = expensiveCalculation(data)
  return <Chart data={processed} />
})
```

### useMemo / useCallback

```tsx
'use client'
import { useMemo, useCallback } from 'react'

export function DataTable({ data }: { data: Item[] }) {
  const [filter, setFilter] = useState('')

  // Memoize expensive calculations
  const filtered = useMemo(() => {
    return data.filter(item => item.name.includes(filter))
  }, [data, filter])

  // Memoize callbacks
  const handleDelete = useCallback((id: string) => {
    deleteItem(id)
  }, [])

  return <div>{/* ... */}</div>
}
```

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
