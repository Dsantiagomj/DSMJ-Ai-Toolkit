# Best Practices - React

## Component Design

### Composition Over Configuration

```tsx
// ❌ Bad: Too many props (configuration)
<Modal
  showCloseButton={true}
  closeButtonPosition="top-right"
  closeButtonColor="red"
  showHeader={true}
  headerAlign="center"
  onClose={handleClose}
/>

// ✅ Good: Composition (flexible)
<Modal onClose={handleClose}>
  <Modal.Header className="text-center">
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

Card.Footer = ({ children }: { children: React.ReactNode }) => {
  return <div className="card-footer">{children}</div>
}

// Usage
<Card>
  <Card.Header>
    <h2>Product Details</h2>
  </Card.Header>
  <Card.Body>
    <p>Product description...</p>
  </Card.Body>
  <Card.Footer>
    <button>Buy Now</button>
  </Card.Footer>
</Card>
```

---

## Anti-Patterns to Avoid

### ❌ useEffect for Derived State

```tsx
// Bad: Using useEffect for calculated values
function BadComponent({ items }: { items: Item[] }) {
  const [total, setTotal] = useState(0)
  const [count, setCount] = useState(0)

  useEffect(() => {
    setTotal(items.reduce((sum, item) => sum + item.price, 0))
    setCount(items.length)
  }, [items])

  return (
    <div>
      Total: {total}, Count: {count}
    </div>
  )
}

// Good: Calculate during render
function GoodComponent({ items }: { items: Item[] }) {
  const total = items.reduce((sum, item) => sum + item.price, 0)
  const count = items.length

  return (
    <div>
      Total: {total}, Count: {count}
    </div>
  )
}

// Good: useMemo if calculation is expensive
function GoodComponent({ items }: { items: Item[] }) {
  const total = useMemo(
    () => items.reduce((sum, item) => sum + item.price, 0),
    [items]
  )

  return <div>Total: {total}</div>
}
```

### ❌ Prop Drilling

```tsx
// Bad: Passing props through many levels
function App() {
  const [user, setUser] = useState<User | null>(null)

  return (
    <Layout user={user} onUpdate={setUser}>
      <Content user={user} onUpdate={setUser}>
        <Profile user={user} onUpdate={setUser} />
      </Content>
    </Layout>
  )
}

// Good: Use Context for deeply nested data
const UserContext = createContext<UserContextType>(null!)

function App() {
  const [user, setUser] = useState<User | null>(null)

  return (
    <UserContext.Provider value={{ user, updateUser: setUser }}>
      <Layout>
        <Content>
          <Profile />
        </Content>
      </Layout>
    </UserContext.Provider>
  )
}

function Profile() {
  const { user, updateUser } = useContext(UserContext)
  // Direct access, no prop drilling
}
```

### ❌ Unnecessary "use client"

```tsx
// Bad: Client component for static content
'use client'
export default function About() {
  return (
    <div>
      <h1>About Us</h1>
      <p>We are a company that...</p>
    </div>
  )
}

// Good: Server component by default
export default function About() {
  return (
    <div>
      <h1>About Us</h1>
      <p>We are a company that...</p>
    </div>
  )
}
```

### ❌ Too Many useState

```tsx
// Bad: Multiple related state variables
function BadForm() {
  const [name, setName] = useState('')
  const [email, setEmail] = useState('')
  const [age, setAge] = useState(0)
  const [address, setAddress] = useState('')

  return <form>{/* ... */}</form>
}

// Good: Single state object
function GoodForm() {
  const [form, setForm] = useState({
    name: '',
    email: '',
    age: 0,
    address: ''
  })

  const updateField = (field: string, value: any) => {
    setForm(prev => ({ ...prev, [field]: value }))
  }

  return <form>{/* ... */}</form>
}

// Better: useReducer for complex state
type State = { name: string; email: string; age: number; address: string }
type Action = { type: 'updateField'; field: keyof State; value: any }

function reducer(state: State, action: Action): State {
  if (action.type === 'updateField') {
    return { ...state, [action.field]: action.value }
  }
  return state
}

function BestForm() {
  const [form, dispatch] = useReducer(reducer, {
    name: '',
    email: '',
    age: 0,
    address: ''
  })

  return <form>{/* ... */}</form>
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
  onError?: (error: Error, errorInfo: ErrorInfo) => void
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
    this.props.onError?.(error, errorInfo)

    // Log to analytics
    if (typeof window !== 'undefined') {
      // logErrorToService(error, errorInfo)
    }
  }

  render() {
    if (this.state.hasError) {
      return (
        this.props.fallback || (
          <div>
            <h1>Something went wrong</h1>
            <pre>{this.state.error?.message}</pre>
          </div>
        )
      )
    }

    return this.props.children
  }
}

// Usage
<ErrorBoundary fallback={<ErrorFallback />} onError={logError}>
  <App />
</ErrorBoundary>
```

### Server Component Errors

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
  useEffect(() => {
    // Log error to service
    console.error(error)
  }, [error])

  return (
    <div>
      <h2>Something went wrong!</h2>
      <p>{error.message}</p>
      <button onClick={() => reset()}>Try again</button>
    </div>
  )
}

// app/page.tsx
export default async function Page() {
  const data = await fetchData() // Errors caught by error.tsx
  return <div>{data}</div>
}
```

### Try-Catch in Server Actions

```tsx
'use server'

export async function createUser(formData: FormData) {
  try {
    const name = formData.get('name') as string
    const user = await db.users.create({ name })
    revalidatePath('/users')
    return { success: true, user }
  } catch (error) {
    console.error('Failed to create user:', error)
    return { success: false, error: 'Failed to create user' }
  }
}
```

---

## Forms and User Input

### Controlled vs Uncontrolled

```tsx
// Controlled (recommended for most cases)
function ControlledForm() {
  const [value, setValue] = useState('')

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    console.log(value)
  }

  return (
    <form onSubmit={handleSubmit}>
      <input
        value={value}
        onChange={(e) => setValue(e.target.value)}
      />
      <button>Submit</button>
    </form>
  )
}

// Uncontrolled with ref (for simple cases)
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

## State Management

### Local vs Global State

```tsx
// ❌ Bad: Global state for local UI
const useStore = create((set) => ({
  modalOpen: false,
  openModal: () => set({ modalOpen: true }),
  closeModal: () => set({ modalOpen: false }),
}))

// ✅ Good: Local state for UI
function Modal() {
  const [isOpen, setIsOpen] = useState(false)
  return <div>{/* ... */}</div>
}

// ✅ Good: Global state for shared data
const useUserStore = create((set) => ({
  user: null,
  setUser: (user) => set({ user }),
}))
```

### Colocation

```tsx
// ❌ Bad: State far from usage
function App() {
  const [filter, setFilter] = useState('')

  return (
    <div>
      <Header />
      <Sidebar />
      <Content filter={filter} onFilterChange={setFilter} />
    </div>
  )
}

// ✅ Good: State colocated with usage
function App() {
  return (
    <div>
      <Header />
      <Sidebar />
      <Content />
    </div>
  )
}

function Content() {
  const [filter, setFilter] = useState('')
  return <div>{/* use filter here */}</div>
}
```

---

## Accessibility

### Semantic HTML

```tsx
// ❌ Bad: Div soup
<div onClick={handleClick}>
  <div className="title">Product</div>
  <div className="description">Description</div>
</div>

// ✅ Good: Semantic HTML
<article>
  <h2>Product</h2>
  <p>Description</p>
  <button onClick={handleClick}>Buy Now</button>
</article>
```

### ARIA Attributes

```tsx
export function Modal({ isOpen, onClose, children }: ModalProps) {
  return (
    <div
      role="dialog"
      aria-modal="true"
      aria-labelledby="modal-title"
      hidden={!isOpen}
    >
      <h2 id="modal-title">Modal Title</h2>
      {children}
      <button onClick={onClose} aria-label="Close modal">
        ×
      </button>
    </div>
  )
}
```

### Keyboard Navigation

```tsx
export function Tabs({ tabs }: { tabs: Tab[] }) {
  const [selectedIndex, setSelectedIndex] = useState(0)

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'ArrowRight') {
      setSelectedIndex((i) => (i + 1) % tabs.length)
    } else if (e.key === 'ArrowLeft') {
      setSelectedIndex((i) => (i - 1 + tabs.length) % tabs.length)
    }
  }

  return (
    <div role="tablist" onKeyDown={handleKeyDown}>
      {tabs.map((tab, i) => (
        <button
          key={tab.id}
          role="tab"
          aria-selected={i === selectedIndex}
          tabIndex={i === selectedIndex ? 0 : -1}
          onClick={() => setSelectedIndex(i)}
        >
          {tab.label}
        </button>
      ))}
    </div>
  )
}
```

---

## Security

### XSS Prevention

```tsx
// ❌ Dangerous: Using dangerouslySetInnerHTML without sanitization
<div dangerouslySetInnerHTML={{ __html: userContent }} />

// ✅ Safe: Use a sanitization library
import DOMPurify from 'isomorphic-dompurify'

const sanitized = DOMPurify.sanitize(userContent)
<div dangerouslySetInnerHTML={{ __html: sanitized }} />
```

### Sensitive Data

```tsx
// ❌ Bad: Exposing secrets in client components
'use client'

const API_KEY = process.env.NEXT_PUBLIC_SECRET_KEY

// ✅ Good: Keep secrets in server components
export default async function Page() {
  const apiKey = process.env.SECRET_KEY // Not exposed to client
  const data = await fetchData(apiKey)
  return <Display data={data} />
}
```

---

## Testing Best Practices

### Component Testing

```tsx
import { render, screen, fireEvent } from '@testing-library/react'

describe('Counter', () => {
  it('increments count', () => {
    render(<Counter />)

    const button = screen.getByRole('button', { name: /increment/i })
    const count = screen.getByText(/count: 0/i)

    fireEvent.click(button)

    expect(screen.getByText(/count: 1/i)).toBeInTheDocument()
  })
})
```

---

## File Organization

```
src/
├── app/                    # Next.js app directory
│   ├── (marketing)/        # Route groups
│   │   ├── about/
│   │   └── contact/
│   ├── dashboard/
│   │   ├── page.tsx
│   │   └── layout.tsx
│   └── layout.tsx
├── components/             # Shared components
│   ├── ui/                 # UI primitives
│   │   ├── button.tsx
│   │   └── input.tsx
│   └── features/           # Feature components
│       └── user-profile.tsx
├── lib/                    # Utilities
│   ├── db.ts
│   └── auth.ts
└── hooks/                  # Custom hooks
    └── use-user.ts
```

---

## Code Quality

### Naming Conventions

```tsx
// ✅ Components: PascalCase
function UserProfile() {}

// ✅ Hooks: camelCase with 'use' prefix
function useAuth() {}

// ✅ Constants: UPPER_SNAKE_CASE
const MAX_ITEMS = 100

// ✅ Variables/Functions: camelCase
const userName = 'John'
function getUserData() {}
```

### Comment When Necessary

```tsx
// ❌ Bad: Obvious comments
// Set the count to 0
const count = 0

// ✅ Good: Explain why, not what
// Reset count to 0 because the API returns cumulative values
// and we need to track only the delta
const count = 0

// ✅ Good: Document complex logic
/**
 * Calculates the optimal batch size based on available memory
 * and network latency. Uses exponential backoff for retries.
 */
function calculateBatchSize(memory: number, latency: number): number {
  // implementation
}
```
