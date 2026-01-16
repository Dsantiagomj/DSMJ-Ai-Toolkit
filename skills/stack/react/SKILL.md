---
name: react
description: Modern React patterns with Server Components, Actions, and hooks. Use when writing React components, JSX files, or working with React-specific features.
tags: [react, frontend, javascript, typescript, ui, components, server-components, hooks]
author: dsmj-ai-toolkit
metadata:
  auto_invoke: "Writing React components, JSX files, hooks, or React-specific code"
  stack_category: frontend
  progressive_disclosure: true
---

# React Skill

Modern React patterns with Server Components, Server Actions, and concurrent features.

---

## When to Use This Skill

**Auto-invoke when**:
- Writing `.jsx` or `.tsx` files
- Creating React components
- Working with React hooks
- Implementing React patterns
- Dealing with state management
- Handling forms and user input

---

## React 19 Key Concepts

### Server Components First (Default)

**React 19 philosophy**: Server Components by default, Client Components only when needed.

```tsx
// ✅ Server Component (default)
// app/dashboard/page.tsx
export default async function Dashboard() {
  const data = await fetchData() // Direct data fetching
  return <DashboardUI data={data} />
}
```

**When to use Server Components**:
- ✅ Data fetching
- ✅ Direct database access
- ✅ Reading from filesystem
- ✅ Static content rendering
- ✅ SEO-critical content

**Benefits**:
- Zero JavaScript sent to client
- Direct backend access (no API layer needed)
- Better performance
- Automatic code splitting

### Client Components ("use client")

**Only use when you need**:
- Browser-only APIs (`window`, `localStorage`, etc.)
- Event handlers (`onClick`, `onChange`, etc.)
- React hooks (`useState`, `useEffect`, etc.)
- Third-party libraries that use browser APIs

```tsx
// ❌ Don't use client for everything
'use client'
export default function ServerRenderable() {
  return <div>Static content</div>
}

// ✅ Use client only when needed
'use client'
import { useState } from 'react'

export default function Counter() {
  const [count, setCount] = useState(0)
  return <button onClick={() => setCount(count + 1)}>{count}</button>
}
```

### Server Actions

**New in React 19**: Direct server functions from components

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
- Type-safe (with TypeScript)
- Progressive enhancement
- Automatic revalidation

---

## Component Patterns

### Composition Over Configuration

```tsx
// ❌ Too many props (configuration)
<Modal
  showCloseButton={true}
  closeButtonPosition="top-right"
  closeButtonColor="red"
  onClose={handleClose}
/>

// ✅ Composition (flexible)
<Modal onClose={handleClose}>
  <Modal.Header>
    <Modal.CloseButton className="text-red-500" />
    <Modal.Title>Settings</Modal.Title>
  </Modal.Header>
  <Modal.Content>{/* ... */}</Modal.Content>
</Modal>
```

### Compound Components

```tsx
// lib/components/Card.tsx
export const Card = ({ children }: { children: React.ReactNode }) => {
  return <div className="card">{children}</div>
}

Card.Header = ({ children }: { children: React.ReactNode }) => {
  return <div className="card-header">{children}</div>
}

Card.Body = ({ children }: { children: React.ReactNode }) => {
  return <div className="card-body">{children}</div>
}

// Usage
<Card>
  <Card.Header>Title</Card.Header>
  <Card.Body>Content</Card.Body>
</Card>
```

### Server Component Data Patterns

```tsx
// ✅ Direct data fetching in Server Component
export default async function ProductPage({ params }: { params: { id: string } }) {
  // Parallel data fetching
  const [product, reviews] = await Promise.all([
    fetchProduct(params.id),
    fetchReviews(params.id),
  ])

  return (
    <>
      <ProductDetails product={product} />
      <ReviewsList reviews={reviews} />
    </>
  )
}

// ✅ Streaming with Suspense
import { Suspense } from 'react'

export default function Page() {
  return (
    <>
      <ProductDetails /> {/* Fast content */}
      <Suspense fallback={<ReviewsSkeleton />}>
        <Reviews /> {/* Slow async component */}
      </Suspense>
    </>
  )
}

async function Reviews() {
  const reviews = await fetchReviews() // This can be slow
  return <ReviewsList reviews={reviews} />
}
```

---

## Modern Hooks

### useOptimistic (New in React 19)

**For optimistic UI updates**:

```tsx
'use client'
import { useOptimistic } from 'react'
import { sendMessage } from './actions'

export function MessageForm({ messages }: { messages: Message[] }) {
  const [optimisticMessages, addOptimisticMessage] = useOptimistic(
    messages,
    (state, newMessage: string) => [
      ...state,
      { text: newMessage, sending: true }
    ]
  )

  async function formAction(formData: FormData) {
    const message = formData.get('message') as string
    addOptimisticMessage(message)
    await sendMessage(message)
  }

  return (
    <>
      {optimisticMessages.map((msg, i) => (
        <div key={i} className={msg.sending ? 'opacity-50' : ''}>
          {msg.text}
        </div>
      ))}
      <form action={formAction}>
        <input name="message" />
        <button>Send</button>
      </form>
    </>
  )
}
```

### useTransition

**For non-urgent updates**:

```tsx
'use client'
import { useState, useTransition } from 'react'

export function SearchResults() {
  const [query, setQuery] = useState('')
  const [results, setResults] = useState([])
  const [isPending, startTransition] = useTransition()

  function handleSearch(e: React.ChangeEvent<HTMLInputElement>) {
    const value = e.target.value
    setQuery(value) // Urgent: update input immediately

    startTransition(() => {
      // Non-urgent: can be delayed for better UX
      setResults(expensiveFilter(value))
    })
  }

  return (
    <>
      <input value={query} onChange={handleSearch} />
      {isPending && <div>Loading...</div>}
      <Results items={results} />
    </>
  )
}
```

### use (New in React 19)

**For reading promises/context in render**:

```tsx
import { use } from 'react'

export default function Page({ commentsPromise }: { commentsPromise: Promise<Comment[]> }) {
  // Read promise directly in render
  const comments = use(commentsPromise)
  return <CommentsList comments={comments} />
}

// Conditional use() is OK in React 19
function ConditionalData({ showData }: { showData: boolean }) {
  if (!showData) return null

  const data = use(fetchData()) // Conditional hook usage now allowed!
  return <div>{data}</div>
}
```

---

## State Management

### useState Basics

```tsx
'use client'
import { useState } from 'react'

// ✅ Simple state
const [count, setCount] = useState(0)

// ✅ Functional updates when based on previous state
setCount(prev => prev + 1)

// ✅ Complex state with proper typing
interface FormState {
  name: string
  email: string
}

const [form, setForm] = useState<FormState>({ name: '', email: '' })

// Partial updates
setForm(prev => ({ ...prev, name: 'John' }))
```

### useReducer for Complex State

```tsx
'use client'
import { useReducer } from 'react'

type State = { count: number; step: number }
type Action =
  | { type: 'increment' }
  | { type: 'decrement' }
  | { type: 'setStep'; step: number }

function reducer(state: State, action: Action): State {
  switch (action.type) {
    case 'increment':
      return { ...state, count: state.count + state.step }
    case 'decrement':
      return { ...state, count: state.count - state.step }
    case 'setStep':
      return { ...state, step: action.step }
    default:
      return state
  }
}

export function Counter() {
  const [state, dispatch] = useReducer(reducer, { count: 0, step: 1 })

  return (
    <>
      <p>Count: {state.count}</p>
      <button onClick={() => dispatch({ type: 'increment' })}>+</button>
      <button onClick={() => dispatch({ type: 'decrement' })}>-</button>
      <input
        type="number"
        value={state.step}
        onChange={(e) => dispatch({ type: 'setStep', step: +e.target.value })}
      />
    </>
  )
}
```

---

## Performance Optimization

### React.memo

**Only for expensive components that re-render often**:

```tsx
import { memo } from 'react'

// ❌ Don't memo everything
export default memo(function SimpleDiv({ text }: { text: string }) {
  return <div>{text}</div>
})

// ✅ Memo for expensive components
export default memo(function ExpensiveChart({ data }: { data: number[] }) {
  const processedData = expensiveCalculation(data) // Expensive
  return <Chart data={processedData} />
})

// ✅ With custom comparison
export default memo(
  function ProductCard({ product }: { product: Product }) {
    return <div>{product.name}</div>
  },
  (prevProps, nextProps) => prevProps.product.id === nextProps.product.id
)
```

### useMemo and useCallback

```tsx
'use client'
import { useMemo, useCallback, useState } from 'react'

export function DataTable({ data }: { data: Item[] }) {
  const [filter, setFilter] = useState('')

  // ✅ Memoize expensive calculations
  const filteredData = useMemo(() => {
    return data.filter(item => item.name.includes(filter))
  }, [data, filter])

  // ✅ Memoize callbacks passed to memoized children
  const handleDelete = useCallback((id: string) => {
    deleteItem(id)
  }, [])

  return (
    <>
      <input value={filter} onChange={e => setFilter(e.target.value)} />
      {filteredData.map(item => (
        <Row key={item.id} item={item} onDelete={handleDelete} />
      ))}
    </>
  )
}

const Row = memo(function Row({ item, onDelete }: RowProps) {
  return <div onClick={() => onDelete(item.id)}>{item.name}</div>
})
```

---

## Anti-Patterns to Avoid

### ❌ useEffect for Derived State

```tsx
// ❌ Don't use useEffect for derived values
function BadComponent({ items }: { items: Item[] }) {
  const [total, setTotal] = useState(0)

  useEffect(() => {
    setTotal(items.reduce((sum, item) => sum + item.price, 0))
  }, [items])

  return <div>Total: {total}</div>
}

// ✅ Calculate during render
function GoodComponent({ items }: { items: Item[] }) {
  const total = items.reduce((sum, item) => sum + item.price, 0)
  return <div>Total: {total}</div>
}
```

### ❌ Prop Drilling

```tsx
// ❌ Passing props through many levels
<Parent>
  <Middle user={user} onUpdate={onUpdate}>
    <Child user={user} onUpdate={onUpdate}>
      <GrandChild user={user} onUpdate={onUpdate} />
    </Child>
  </Middle>
</Parent>

// ✅ Use Context for deeply nested data
const UserContext = createContext<UserContextType>(null!)

function Parent() {
  const [user, setUser] = useState(initialUser)
  return (
    <UserContext.Provider value={{ user, updateUser: setUser }}>
      <Middle />
    </UserContext.Provider>
  )
}

function GrandChild() {
  const { user, updateUser } = useContext(UserContext)
  // Direct access, no prop drilling
}
```

### ❌ Unnecessary "use client"

```tsx
// ❌ Client component for static content
'use client'
export default function About() {
  return <div>About us...</div>
}

// ✅ Server component by default
export default function About() {
  return <div>About us...</div>
}
```

---

## Error Handling

### Error Boundaries (Class Components)

```tsx
import { Component, ErrorInfo, ReactNode } from 'react'

interface Props {
  children: ReactNode
  fallback?: ReactNode
}

interface State {
  hasError: boolean
  error?: Error
}

export class ErrorBoundary extends Component<Props, State> {
  state: State = { hasError: false }

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error }
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error('Error caught:', error, errorInfo)
    // Send to error reporting service
  }

  render() {
    if (this.state.hasError) {
      return this.props.fallback || <h1>Something went wrong.</h1>
    }

    return this.props.children
  }
}

// Usage
<ErrorBoundary fallback={<ErrorFallback />}>
  <SomeComponent />
</ErrorBoundary>
```

### Async Error Handling (Server Components)

```tsx
// app/error.tsx - Next.js error boundary
'use client'

export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  return (
    <div>
      <h2>Something went wrong!</h2>
      <button onClick={() => reset()}>Try again</button>
    </div>
  )
}

// page.tsx
export default async function Page() {
  const data = await fetchData() // Errors caught by error.tsx
  return <div>{data}</div>
}
```

---

## TypeScript with React

### Component Props

```tsx
// ✅ Inline props (simple components)
export default function Button({ label, onClick }: {
  label: string
  onClick: () => void
}) {
  return <button onClick={onClick}>{label}</button>
}

// ✅ Interface for complex props
interface UserCardProps {
  user: {
    name: string
    email: string
    avatar?: string
  }
  showEmail?: boolean
  onEdit?: (id: string) => void
}

export default function UserCard({ user, showEmail = true, onEdit }: UserCardProps) {
  return (
    <div>
      <h3>{user.name}</h3>
      {showEmail && <p>{user.email}</p>}
      {onEdit && <button onClick={() => onEdit(user.id)}>Edit</button>}
    </div>
  )
}

// ✅ Children prop
interface LayoutProps {
  children: React.ReactNode
}

export default function Layout({ children }: LayoutProps) {
  return <main>{children}</main>
}
```

---

## Forms and User Input

### Controlled vs Uncontrolled

```tsx
// ✅ Controlled (recommended for most cases)
function ControlledForm() {
  const [value, setValue] = useState('')

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    console.log(value)
  }

  return (
    <form onSubmit={handleSubmit}>
      <input value={value} onChange={(e) => setValue(e.target.value)} />
      <button>Submit</button>
    </form>
  )
}

// ✅ Uncontrolled with ref (for simple cases)
function UncontrolledForm() {
  const inputRef = useRef<HTMLInputElement>(null)

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    console.log(inputRef.current?.value)
  }

  return (
    <form onSubmit={handleSubmit}>
      <input ref={inputRef} defaultValue="" />
      <button>Submit</button>
    </form>
  )
}
```

### Server Actions with Forms

```tsx
// app/actions.ts
'use server'

export async function createPost(formData: FormData) {
  const title = formData.get('title') as string
  const content = formData.get('content') as string

  await db.posts.create({ title, content })
  revalidatePath('/posts')
  redirect('/posts')
}

// app/posts/new/page.tsx
import { createPost } from '../actions'

export default function NewPost() {
  return (
    <form action={createPost}>
      <input name="title" required />
      <textarea name="content" required />
      <button type="submit">Create Post</button>
    </form>
  )
}
```

---

## Progressive Disclosure

For detailed information, see `/references`:
- `server-components.md` - Deep dive into Server Components architecture
- `hooks-reference.md` - Complete hooks API and patterns
- `performance.md` - Advanced optimization techniques
- `testing.md` - Testing strategies for React 19
- `migration.md` - Migrating from React 18 to 19

---

## Quick Reference

**Server vs Client**:
- Default = Server Component (no "use client")
- Use "use client" only for interactivity, browser APIs, hooks

**Data Fetching**:
- Server Components: `await` directly in component
- Client Components: Use libraries (SWR, React Query) or Server Actions

**Forms**:
- Prefer Server Actions with progressive enhancement
- Use controlled components for complex validation

**Performance**:
- `memo()` for expensive components
- `useMemo()` for expensive calculations
- `useCallback()` for callbacks passed to memoized children

**State**:
- `useState` for simple state
- `useReducer` for complex state logic
- Context for avoiding prop drilling

---

_This skill provides React 19 patterns. For Next.js-specific routing, layouts, and app directory patterns, reference the `nextjs-15` skill._
