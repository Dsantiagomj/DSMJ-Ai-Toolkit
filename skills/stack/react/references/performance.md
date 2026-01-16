# Performance Optimization - React

## React.memo

### When to Use

```tsx
import { memo } from 'react'

// ❌ Don't memo everything
export default memo(function SimpleDiv({ text }: { text: string }) {
  return <div>{text}</div>
})

// ✅ Memo for expensive components that re-render often
export default memo(function ExpensiveChart({ data }: { data: number[] }) {
  const processed = expensiveCalculation(data)
  return <Chart data={processed} />
})
```

### Custom Comparison

```tsx
export default memo(
  function ProductCard({ product }: { product: Product }) {
    return (
      <div>
        <h3>{product.name}</h3>
        <p>${product.price}</p>
      </div>
    )
  },
  (prevProps, nextProps) => {
    // Only re-render if product ID or price changes
    return (
      prevProps.product.id === nextProps.product.id &&
      prevProps.product.price === nextProps.product.price
    )
  }
)
```

---

## useMemo

### Expensive Calculations

```tsx
'use client'
import { useMemo } from 'react'

export function DataTable({ data }: { data: Item[] }) {
  const [filter, setFilter] = useState('')
  const [sortBy, setSortBy] = useState<'name' | 'price'>('name')

  // ❌ Bad: Runs on every render
  const processedData = data
    .filter(item => item.name.includes(filter))
    .sort((a, b) => a[sortBy].localeCompare(b[sortBy]))

  // ✅ Good: Only recalculates when dependencies change
  const processedData = useMemo(() => {
    return data
      .filter(item => item.name.includes(filter))
      .sort((a, b) => a[sortBy].localeCompare(b[sortBy]))
  }, [data, filter, sortBy])

  return <Table data={processedData} />
}
```

### Prevent Reference Changes

```tsx
function Component({ items }: { items: string[] }) {
  // ❌ Bad: New array on every render
  const config = items.map(item => ({ id: item, selected: false }))

  // ✅ Good: Stable reference
  const config = useMemo(
    () => items.map(item => ({ id: item, selected: false })),
    [items]
  )

  return <ChildComponent config={config} />
}
```

---

## useCallback

### Memoize Event Handlers

```tsx
'use client'
import { useCallback, useState, memo } from 'react'

export function TodoList() {
  const [todos, setTodos] = useState<Todo[]>([])

  // ❌ Bad: New function on every render
  const handleToggle = (id: string) => {
    setTodos(todos => todos.map(todo =>
      todo.id === id ? { ...todo, done: !todo.done } : todo
    ))
  }

  // ✅ Good: Stable function reference
  const handleToggle = useCallback((id: string) => {
    setTodos(todos => todos.map(todo =>
      todo.id === id ? { ...todo, done: !todo.done } : todo
    ))
  }, [])

  return (
    <>
      {todos.map(todo => (
        <TodoItem key={todo.id} todo={todo} onToggle={handleToggle} />
      ))}
    </>
  )
}

const TodoItem = memo(function TodoItem({
  todo,
  onToggle
}: {
  todo: Todo
  onToggle: (id: string) => void
}) {
  return (
    <div onClick={() => onToggle(todo.id)}>
      {todo.text}
    </div>
  )
})
```

---

## Code Splitting

### Dynamic Imports

```tsx
import { lazy, Suspense } from 'react'

// Lazy load component
const HeavyChart = lazy(() => import('./HeavyChart'))

export function Dashboard() {
  return (
    <div>
      <Header />
      <Suspense fallback={<ChartSkeleton />}>
        <HeavyChart />
      </Suspense>
    </div>
  )
}
```

### Route-Based Splitting

```tsx
// Next.js automatically code-splits by route
// app/dashboard/page.tsx
export default function Dashboard() {
  return <div>Dashboard</div>
}

// app/settings/page.tsx
export default function Settings() {
  return <div>Settings</div>
}
```

---

## List Optimization

### Keys

```tsx
// ❌ Bad: Using index as key
{items.map((item, index) => (
  <div key={index}>{item.name}</div>
))}

// ✅ Good: Using unique ID
{items.map(item => (
  <div key={item.id}>{item.name}</div>
))}
```

### Virtualization

```tsx
import { FixedSizeList } from 'react-window'

export function LongList({ items }: { items: Item[] }) {
  return (
    <FixedSizeList
      height={600}
      itemCount={items.length}
      itemSize={50}
      width="100%"
    >
      {({ index, style }) => (
        <div style={style}>
          {items[index].name}
        </div>
      )}
    </FixedSizeList>
  )
}
```

---

## Avoiding Re-renders

### Component Structure

```tsx
// ❌ Bad: Entire form re-renders on every input change
export function Form() {
  const [name, setName] = useState('')
  const [email, setEmail] = useState('')
  const [age, setAge] = useState(0)

  return (
    <>
      <HeavyComponent /> {/* Re-renders unnecessarily */}
      <input value={name} onChange={(e) => setName(e.target.value)} />
      <input value={email} onChange={(e) => setEmail(e.target.value)} />
      <input value={age} onChange={(e) => setAge(+e.target.value)} />
    </>
  )
}

// ✅ Good: Split into smaller components
export function Form() {
  return (
    <>
      <HeavyComponent />
      <NameInput />
      <EmailInput />
      <AgeInput />
    </>
  )
}

function NameInput() {
  const [name, setName] = useState('')
  return <input value={name} onChange={(e) => setName(e.target.value)} />
}
```

### Children Pattern

```tsx
// ✅ Good: Children don't re-render when parent state changes
export function Parent({ children }: { children: React.ReactNode }) {
  const [count, setCount] = useState(0)

  return (
    <div>
      <button onClick={() => setCount(count + 1)}>Count: {count}</button>
      {children} {/* Doesn't re-render */}
    </div>
  )
}

// Usage
<Parent>
  <HeavyComponent />
</Parent>
```

---

## Derived State

### Calculate During Render

```tsx
// ❌ Bad: Using useEffect for derived state
function Component({ items }: { items: Item[] }) {
  const [total, setTotal] = useState(0)

  useEffect(() => {
    setTotal(items.reduce((sum, item) => sum + item.price, 0))
  }, [items])

  return <div>Total: {total}</div>
}

// ✅ Good: Calculate during render
function Component({ items }: { items: Item[] }) {
  const total = items.reduce((sum, item) => sum + item.price, 0)
  return <div>Total: {total}</div>
}

// ✅ Good: useMemo if calculation is expensive
function Component({ items }: { items: Item[] }) {
  const total = useMemo(
    () => items.reduce((sum, item) => sum + item.price, 0),
    [items]
  )
  return <div>Total: {total}</div>
}
```

---

## Bundle Size Optimization

### Tree Shaking

```tsx
// ❌ Bad: Imports entire library
import _ from 'lodash'

// ✅ Good: Import only what you need
import debounce from 'lodash/debounce'
```

### Dynamic Imports for Heavy Libraries

```tsx
'use client'
import { useState } from 'react'

export function Chart() {
  const [ChartComponent, setChartComponent] = useState<any>(null)

  async function loadChart() {
    const module = await import('heavy-chart-library')
    setChartComponent(() => module.Chart)
  }

  return (
    <div>
      <button onClick={loadChart}>Load Chart</button>
      {ChartComponent && <ChartComponent />}
    </div>
  )
}
```

---

## Image Optimization

### Next.js Image Component

```tsx
import Image from 'next/image'

export function ProductImage({ src, alt }: { src: string; alt: string }) {
  return (
    <Image
      src={src}
      alt={alt}
      width={500}
      height={300}
      loading="lazy"
      placeholder="blur"
    />
  )
}
```

---

## Server Components Performance

### Move Logic to Server

```tsx
// ❌ Bad: Client-side data processing
'use client'
import { useEffect, useState } from 'react'

export function Dashboard() {
  const [data, setData] = useState([])

  useEffect(() => {
    fetch('/api/data')
      .then(res => res.json())
      .then(data => setData(processData(data)))
  }, [])

  return <Chart data={data} />
}

// ✅ Good: Server-side processing
export default async function Dashboard() {
  const rawData = await fetchData()
  const processed = processData(rawData)
  return <Chart data={processed} />
}
```

---

## Profiling

### React DevTools Profiler

```tsx
import { Profiler } from 'react'

export function App() {
  return (
    <Profiler
      id="App"
      onRender={(id, phase, actualDuration) => {
        console.log(`${id} (${phase}) took ${actualDuration}ms`)
      }}
    >
      <Dashboard />
    </Profiler>
  )
}
```

### Performance Monitoring

```tsx
'use client'
import { useEffect } from 'react'

export function PerformanceMonitor({ children }: { children: React.ReactNode }) {
  useEffect(() => {
    // Monitor Core Web Vitals
    if (typeof window !== 'undefined' && 'performance' in window) {
      const observer = new PerformanceObserver((list) => {
        list.getEntries().forEach((entry) => {
          console.log(entry.name, entry.startTime)
        })
      })

      observer.observe({ entryTypes: ['measure', 'navigation'] })

      return () => observer.disconnect()
    }
  }, [])

  return <>{children}</>
}
```

---

## Common Performance Pitfalls

### ❌ Inline Functions in Props

```tsx
// Bad: New function on every render
{items.map(item => (
  <Item key={item.id} onClick={() => handleClick(item.id)} />
))}

// Good: Pass stable function
const handleClick = useCallback((id: string) => {
  // handle click
}, [])

{items.map(item => (
  <Item key={item.id} onClick={handleClick} id={item.id} />
))}
```

### ❌ Creating Objects/Arrays in Render

```tsx
// Bad: New object on every render
<Component style={{ margin: 10, padding: 20 }} />

// Good: Create outside or memoize
const style = { margin: 10, padding: 20 }
<Component style={style} />
```

### ❌ Unnecessary useEffect

```tsx
// Bad: Triggers extra render
const [count, setCount] = useState(0)
const [doubled, setDoubled] = useState(0)

useEffect(() => {
  setDoubled(count * 2)
}, [count])

// Good: Calculate during render
const [count, setCount] = useState(0)
const doubled = count * 2
```

---

## Performance Checklist

- [ ] Use Server Components by default
- [ ] Memo only expensive components
- [ ] useMemo for expensive calculations
- [ ] useCallback for callbacks to memoized children
- [ ] Code split large components
- [ ] Virtualize long lists
- [ ] Use proper keys for lists
- [ ] Optimize images (Next.js Image)
- [ ] Avoid inline functions/objects in JSX
- [ ] Profile with React DevTools
- [ ] Monitor Core Web Vitals
- [ ] Tree shake dependencies
- [ ] Lazy load heavy components
