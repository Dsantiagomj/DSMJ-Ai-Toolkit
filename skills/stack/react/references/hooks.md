# Hooks Reference - React

## useState

### Basic Usage

```tsx
'use client'
import { useState } from 'react'

export function Counter() {
  const [count, setCount] = useState(0)

  return (
    <div>
      <p>Count: {count}</p>
      <button onClick={() => setCount(count + 1)}>Increment</button>
    </div>
  )
}
```

### Functional Updates

```tsx
// ❌ Bad: Stale closure
setCount(count + 1)
setCount(count + 1) // Still increments by 1!

// ✅ Good: Based on previous state
setCount(prev => prev + 1)
setCount(prev => prev + 1) // Increments by 2
```

### Complex State

```tsx
interface FormState {
  name: string
  email: string
  age: number
}

const [form, setForm] = useState<FormState>({
  name: '',
  email: '',
  age: 0,
})

// Partial updates
setForm(prev => ({ ...prev, name: 'John' }))
```

### Lazy Initialization

```tsx
// ❌ Bad: Expensive calculation runs on every render
const [state, setState] = useState(expensiveCalculation())

// ✅ Good: Only runs once
const [state, setState] = useState(() => expensiveCalculation())
```

---

## useEffect

### Basic Side Effects

```tsx
'use client'
import { useEffect, useState } from 'react'

export function Timer() {
  const [seconds, setSeconds] = useState(0)

  useEffect(() => {
    const interval = setInterval(() => {
      setSeconds(s => s + 1)
    }, 1000)

    // Cleanup function
    return () => clearInterval(interval)
  }, []) // Empty deps = run once on mount

  return <div>{seconds}s</div>
}
```

### Dependencies

```tsx
// Run on every render (usually wrong)
useEffect(() => {
  console.log('Every render')
})

// Run once on mount
useEffect(() => {
  console.log('Mount only')
}, [])

// Run when count changes
useEffect(() => {
  console.log('Count changed:', count)
}, [count])

// Multiple dependencies
useEffect(() => {
  fetchData(id, filter)
}, [id, filter])
```

### Common Use Cases

```tsx
// Fetch data
useEffect(() => {
  let cancelled = false

  async function loadData() {
    const data = await fetchData()
    if (!cancelled) {
      setData(data)
    }
  }

  loadData()

  return () => {
    cancelled = true
  }
}, [])

// Subscribe to events
useEffect(() => {
  function handleResize() {
    setSize(window.innerWidth)
  }

  window.addEventListener('resize', handleResize)
  return () => window.removeEventListener('resize', handleResize)
}, [])

// Update document title
useEffect(() => {
  document.title = `Count: ${count}`
}, [count])
```

---

## useReducer

### Basic Reducer

```tsx
'use client'
import { useReducer } from 'react'

type State = { count: number; step: number }
type Action =
  | { type: 'increment' }
  | { type: 'decrement' }
  | { type: 'setStep'; step: number }
  | { type: 'reset' }

function reducer(state: State, action: Action): State {
  switch (action.type) {
    case 'increment':
      return { ...state, count: state.count + state.step }
    case 'decrement':
      return { ...state, count: state.count - state.step }
    case 'setStep':
      return { ...state, step: action.step }
    case 'reset':
      return { count: 0, step: 1 }
    default:
      return state
  }
}

export function Counter() {
  const [state, dispatch] = useReducer(reducer, { count: 0, step: 1 })

  return (
    <div>
      <p>Count: {state.count}</p>
      <button onClick={() => dispatch({ type: 'increment' })}>+</button>
      <button onClick={() => dispatch({ type: 'decrement' })}>-</button>
      <button onClick={() => dispatch({ type: 'reset' })}>Reset</button>
      <input
        type="number"
        value={state.step}
        onChange={(e) => dispatch({ type: 'setStep', step: +e.target.value })}
      />
    </div>
  )
}
```

---

## useContext

### Basic Context

```tsx
import { createContext, useContext, useState } from 'react'

interface UserContextType {
  user: User | null
  setUser: (user: User | null) => void
}

const UserContext = createContext<UserContextType>(null!)

export function UserProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null)

  return (
    <UserContext.Provider value={{ user, setUser }}>
      {children}
    </UserContext.Provider>
  )
}

export function useUser() {
  const context = useContext(UserContext)
  if (!context) {
    throw new Error('useUser must be used within UserProvider')
  }
  return context
}

// Usage
function Profile() {
  const { user, setUser } = useUser()
  return <div>{user?.name}</div>
}
```

---

## useMemo

### Memoize Expensive Calculations

```tsx
'use client'
import { useMemo, useState } from 'react'

export function DataTable({ data }: { data: Item[] }) {
  const [filter, setFilter] = useState('')

  // ❌ Bad: Recalculates on every render
  const filteredData = data.filter(item => item.name.includes(filter))

  // ✅ Good: Only recalculates when dependencies change
  const filteredData = useMemo(() => {
    return data.filter(item => item.name.includes(filter))
  }, [data, filter])

  return <div>{/* ... */}</div>
}
```

### Prevent Reference Changes

```tsx
// ❌ Bad: New object on every render
function Component() {
  const config = { theme: 'dark', locale: 'en' }
  return <ChildComponent config={config} />
}

// ✅ Good: Stable reference
function Component() {
  const config = useMemo(
    () => ({ theme: 'dark', locale: 'en' }),
    []
  )
  return <ChildComponent config={config} />
}
```

---

## useCallback

### Memoize Callbacks

```tsx
'use client'
import { useCallback, useState, memo } from 'react'

export function Parent() {
  const [count, setCount] = useState(0)
  const [name, setName] = useState('')

  // ❌ Bad: New function on every render
  const handleDelete = (id: string) => {
    deleteItem(id)
  }

  // ✅ Good: Stable function reference
  const handleDelete = useCallback((id: string) => {
    deleteItem(id)
  }, [])

  return (
    <>
      <input value={name} onChange={(e) => setName(e.target.value)} />
      <Child onDelete={handleDelete} />
    </>
  )
}

const Child = memo(function Child({ onDelete }: { onDelete: (id: string) => void }) {
  // Won't re-render when parent's name changes
  return <button onClick={() => onDelete('123')}>Delete</button>
})
```

---

## useRef

### Reference DOM Elements

```tsx
'use client'
import { useRef, useEffect } from 'react'

export function AutoFocusInput() {
  const inputRef = useRef<HTMLInputElement>(null)

  useEffect(() => {
    inputRef.current?.focus()
  }, [])

  return <input ref={inputRef} />
}
```

### Store Mutable Values

```tsx
export function Counter() {
  const [count, setCount] = useState(0)
  const renderCount = useRef(0)

  useEffect(() => {
    renderCount.current += 1
  })

  return (
    <div>
      <p>Count: {count}</p>
      <p>Renders: {renderCount.current}</p>
      <button onClick={() => setCount(count + 1)}>Increment</button>
    </div>
  )
}
```

---

## useTransition (React 19)

### Non-Blocking Updates

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
    <div>
      <input value={query} onChange={handleSearch} />
      {isPending && <div>Loading...</div>}
      <Results items={results} />
    </div>
  )
}
```

---

## useOptimistic (React 19)

### Optimistic UI Updates

```tsx
'use client'
import { useOptimistic } from 'react'
import { sendMessage } from './actions'

export function MessageForm({ messages }: { messages: Message[] }) {
  const [optimisticMessages, addOptimistic] = useOptimistic(
    messages,
    (state, newMessage: string) => [
      ...state,
      { id: crypto.randomUUID(), text: newMessage, sending: true }
    ]
  )

  async function formAction(formData: FormData) {
    const message = formData.get('message') as string
    addOptimistic(message)
    await sendMessage(message)
  }

  return (
    <>
      {optimisticMessages.map((msg) => (
        <div key={msg.id} className={msg.sending ? 'opacity-50' : ''}>
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

---

## use (React 19)

### Read Promises in Render

```tsx
import { use } from 'react'

// Read promise directly
export default function Comments({ commentsPromise }: { commentsPromise: Promise<Comment[]> }) {
  const comments = use(commentsPromise)
  return <CommentsList comments={comments} />
}

// Conditional use() now allowed
function ConditionalData({ showData }: { showData: boolean }) {
  if (!showData) return null

  const data = use(fetchData()) // Conditional hook usage OK!
  return <div>{data}</div>
}
```

### Read Context

```tsx
import { use } from 'react'

function useTheme() {
  return use(ThemeContext)
}
```

---

## useId

### Generate Unique IDs

```tsx
import { useId } from 'react'

export function FormField({ label }: { label: string }) {
  const id = useId()

  return (
    <div>
      <label htmlFor={id}>{label}</label>
      <input id={id} />
    </div>
  )
}
```

---

## Custom Hooks

### useLocalStorage

```tsx
import { useState, useEffect } from 'react'

export function useLocalStorage<T>(key: string, initialValue: T) {
  const [value, setValue] = useState<T>(() => {
    if (typeof window === 'undefined') return initialValue

    try {
      const item = window.localStorage.getItem(key)
      return item ? JSON.parse(item) : initialValue
    } catch {
      return initialValue
    }
  })

  useEffect(() => {
    window.localStorage.setItem(key, JSON.stringify(value))
  }, [key, value])

  return [value, setValue] as const
}

// Usage
const [name, setName] = useLocalStorage('name', '')
```

### useDebounce

```tsx
import { useState, useEffect } from 'react'

export function useDebounce<T>(value: T, delay: number): T {
  const [debouncedValue, setDebouncedValue] = useState(value)

  useEffect(() => {
    const timer = setTimeout(() => {
      setDebouncedValue(value)
    }, delay)

    return () => clearTimeout(timer)
  }, [value, delay])

  return debouncedValue
}

// Usage
const [search, setSearch] = useState('')
const debouncedSearch = useDebounce(search, 500)

useEffect(() => {
  fetchResults(debouncedSearch)
}, [debouncedSearch])
```

### usePrevious

```tsx
import { useRef, useEffect } from 'react'

export function usePrevious<T>(value: T): T | undefined {
  const ref = useRef<T>()

  useEffect(() => {
    ref.current = value
  }, [value])

  return ref.current
}

// Usage
const [count, setCount] = useState(0)
const prevCount = usePrevious(count)

console.log(`Current: ${count}, Previous: ${prevCount}`)
```

### useToggle

```tsx
import { useState, useCallback } from 'react'

export function useToggle(initialValue = false) {
  const [value, setValue] = useState(initialValue)

  const toggle = useCallback(() => {
    setValue(v => !v)
  }, [])

  return [value, toggle] as const
}

// Usage
const [isOpen, toggleOpen] = useToggle(false)
```

### useMediaQuery

```tsx
import { useState, useEffect } from 'react'

export function useMediaQuery(query: string): boolean {
  const [matches, setMatches] = useState(false)

  useEffect(() => {
    const media = window.matchMedia(query)
    setMatches(media.matches)

    const listener = (e: MediaQueryListEvent) => setMatches(e.matches)
    media.addEventListener('change', listener)

    return () => media.removeEventListener('change', listener)
  }, [query])

  return matches
}

// Usage
const isMobile = useMediaQuery('(max-width: 768px)')
```
