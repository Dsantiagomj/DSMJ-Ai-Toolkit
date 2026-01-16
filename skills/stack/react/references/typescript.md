# TypeScript Patterns - React

## Component Props

### Inline Props (Simple Components)

```tsx
export default function Button({ label, onClick }: {
  label: string
  onClick: () => void
}) {
  return <button onClick={onClick}>{label}</button>
}
```

### Interface for Complex Props

```tsx
interface UserCardProps {
  user: {
    id: string
    name: string
    email: string
    avatar?: string
  }
  showEmail?: boolean
  onEdit?: (id: string) => void
  onDelete?: (id: string) => void
}

export default function UserCard({
  user,
  showEmail = true,
  onEdit,
  onDelete
}: UserCardProps) {
  return (
    <div>
      <h3>{user.name}</h3>
      {showEmail && <p>{user.email}</p>}
      {onEdit && <button onClick={() => onEdit(user.id)}>Edit</button>}
      {onDelete && <button onClick={() => onDelete(user.id)}>Delete</button>}
    </div>
  )
}
```

### Children Prop

```tsx
// Simple children
interface LayoutProps {
  children: React.ReactNode
}

export default function Layout({ children }: LayoutProps) {
  return <main>{children}</main>
}

// Function as children (render props)
interface DataProviderProps<T> {
  data: T[]
  children: (item: T, index: number) => React.ReactNode
}

export function DataProvider<T>({ data, children }: DataProviderProps<T>) {
  return (
    <ul>
      {data.map((item, index) => (
        <li key={index}>{children(item, index)}</li>
      ))}
    </ul>
  )
}

// Usage
<DataProvider data={users}>
  {(user, index) => <UserCard user={user} />}
</DataProvider>
```

---

## Event Handlers

### Common Events

```tsx
interface FormProps {
  onSubmit: (data: FormData) => void
}

export function Form({ onSubmit }: FormProps) {
  const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    const formData = new FormData(e.currentTarget)
    onSubmit(formData)
  }

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    console.log(e.target.value)
  }

  const handleClick = (e: React.MouseEvent<HTMLButtonElement>) => {
    e.stopPropagation()
  }

  const handleKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Enter') {
      // handle enter
    }
  }

  return (
    <form onSubmit={handleSubmit}>
      <input onChange={handleChange} onKeyDown={handleKeyDown} />
      <button onClick={handleClick}>Submit</button>
    </form>
  )
}
```

---

## useState Types

### Type Inference

```tsx
// ✅ Type inferred from initial value
const [count, setCount] = useState(0) // number
const [name, setName] = useState('') // string
const [isOpen, setIsOpen] = useState(false) // boolean

// ❌ Bad: undefined initial value
const [user, setUser] = useState() // any

// ✅ Good: Explicit type with union
const [user, setUser] = useState<User | null>(null)
```

### Complex Types

```tsx
interface User {
  id: string
  name: string
  email: string
}

// Object
const [user, setUser] = useState<User | null>(null)

// Array
const [users, setUsers] = useState<User[]>([])

// Union types
const [status, setStatus] = useState<'idle' | 'loading' | 'success' | 'error'>('idle')

// Complex state
interface FormState {
  values: Record<string, string>
  errors: Record<string, string>
  isSubmitting: boolean
}

const [form, setForm] = useState<FormState>({
  values: {},
  errors: {},
  isSubmitting: false
})
```

---

## useRef Types

### DOM References

```tsx
// Input element
const inputRef = useRef<HTMLInputElement>(null)

// Div element
const divRef = useRef<HTMLDivElement>(null)

// Button element
const buttonRef = useRef<HTMLButtonElement>(null)

// Generic HTMLElement
const elementRef = useRef<HTMLElement>(null)

// Usage
useEffect(() => {
  inputRef.current?.focus()

  if (divRef.current) {
    divRef.current.scrollTop = 0
  }
}, [])
```

### Mutable Values

```tsx
// Number
const renderCount = useRef<number>(0)

// Object
interface TimerRef {
  intervalId: number | null
  startTime: number
}

const timerRef = useRef<TimerRef>({
  intervalId: null,
  startTime: Date.now()
})

// Function
const callbackRef = useRef<(() => void) | null>(null)
```

---

## useReducer Types

### Discriminated Unions

```tsx
type State = {
  count: number
  error: string | null
  isLoading: boolean
}

type Action =
  | { type: 'increment' }
  | { type: 'decrement' }
  | { type: 'setCount'; payload: number }
  | { type: 'setError'; payload: string }
  | { type: 'setLoading'; payload: boolean }

function reducer(state: State, action: Action): State {
  switch (action.type) {
    case 'increment':
      return { ...state, count: state.count + 1 }
    case 'decrement':
      return { ...state, count: state.count - 1 }
    case 'setCount':
      return { ...state, count: action.payload }
    case 'setError':
      return { ...state, error: action.payload }
    case 'setLoading':
      return { ...state, isLoading: action.payload }
    default:
      return state
  }
}

const [state, dispatch] = useReducer(reducer, {
  count: 0,
  error: null,
  isLoading: false
})

// TypeScript ensures payload types
dispatch({ type: 'setCount', payload: 10 }) // ✅
dispatch({ type: 'setCount', payload: 'invalid' }) // ❌ Type error
```

---

## useContext Types

### Typed Context

```tsx
interface UserContextType {
  user: User | null
  login: (email: string, password: string) => Promise<void>
  logout: () => void
  isLoading: boolean
}

const UserContext = createContext<UserContextType | undefined>(undefined)

export function UserProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null)
  const [isLoading, setIsLoading] = useState(false)

  const login = async (email: string, password: string) => {
    setIsLoading(true)
    try {
      const user = await authService.login(email, password)
      setUser(user)
    } finally {
      setIsLoading(false)
    }
  }

  const logout = () => {
    setUser(null)
  }

  return (
    <UserContext.Provider value={{ user, login, logout, isLoading }}>
      {children}
    </UserContext.Provider>
  )
}

export function useUser() {
  const context = useContext(UserContext)
  if (context === undefined) {
    throw new Error('useUser must be used within UserProvider')
  }
  return context
}
```

---

## Generic Components

### Generic Props

```tsx
interface ListProps<T> {
  items: T[]
  renderItem: (item: T, index: number) => React.ReactNode
  keyExtractor: (item: T) => string
}

export function List<T>({ items, renderItem, keyExtractor }: ListProps<T>) {
  return (
    <ul>
      {items.map((item, index) => (
        <li key={keyExtractor(item)}>
          {renderItem(item, index)}
        </li>
      ))}
    </ul>
  )
}

// Usage
<List
  items={users}
  renderItem={(user) => <UserCard user={user} />}
  keyExtractor={(user) => user.id}
/>
```

### Generic Hooks

```tsx
function useLocalStorage<T>(key: string, initialValue: T) {
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
const [user, setUser] = useLocalStorage<User | null>('user', null)
const [settings, setSettings] = useLocalStorage<Settings>('settings', defaultSettings)
```

---

## Server Actions

### Typed Actions

```tsx
'use server'

import { z } from 'zod'

const userSchema = z.object({
  name: z.string().min(2),
  email: z.string().email(),
  age: z.number().min(18),
})

type UserInput = z.infer<typeof userSchema>

export async function createUser(
  data: UserInput
): Promise<{ success: true; user: User } | { success: false; error: string }> {
  const result = userSchema.safeParse(data)

  if (!result.success) {
    return { success: false, error: result.error.message }
  }

  try {
    const user = await db.users.create(result.data)
    revalidatePath('/users')
    return { success: true, user }
  } catch (error) {
    return { success: false, error: 'Failed to create user' }
  }
}

// Usage in Client Component
'use client'

import { createUser } from './actions'

export function CreateUserForm() {
  async function handleSubmit(data: UserInput) {
    const result = await createUser(data)

    if (result.success) {
      console.log('User created:', result.user)
    } else {
      console.error('Error:', result.error)
    }
  }

  return <form>{/* ... */}</form>
}
```

---

## Async Components (Server Components)

### Typed Server Components

```tsx
interface PageProps {
  params: { id: string }
  searchParams: { filter?: string; sort?: 'asc' | 'desc' }
}

export default async function ProductPage({ params, searchParams }: PageProps) {
  const product = await fetchProduct(params.id)
  const reviews = await fetchReviews(params.id, {
    filter: searchParams.filter,
    sort: searchParams.sort
  })

  return (
    <>
      <ProductDetails product={product} />
      <ReviewsList reviews={reviews} />
    </>
  )
}
```

---

## Utility Types

### Component Props Extraction

```tsx
import { ComponentProps } from 'react'

// Extract props from existing component
type ButtonProps = ComponentProps<typeof Button>

// Extract props from HTML element
type DivProps = ComponentProps<'div'>
type InputProps = ComponentProps<'input'>

// Extend with additional props
interface CustomButtonProps extends ComponentProps<'button'> {
  variant: 'primary' | 'secondary'
  loading?: boolean
}
```

### PropsWithChildren

```tsx
import { PropsWithChildren } from 'react'

interface CardProps {
  title: string
  footer?: React.ReactNode
}

// Automatically adds children prop
export function Card({ title, footer, children }: PropsWithChildren<CardProps>) {
  return (
    <div>
      <h2>{title}</h2>
      <div>{children}</div>
      {footer && <footer>{footer}</footer>}
    </div>
  )
}
```

### Omit and Pick

```tsx
interface User {
  id: string
  name: string
  email: string
  password: string
  createdAt: Date
}

// Omit sensitive fields
type PublicUser = Omit<User, 'password'>

// Pick only needed fields
type UserSummary = Pick<User, 'id' | 'name'>

// In components
interface UserCardProps {
  user: PublicUser
}

export function UserCard({ user }: UserCardProps) {
  return <div>{user.name}</div>
}
```

---

## Type Guards

### Type Narrowing

```tsx
interface User {
  type: 'user'
  name: string
  email: string
}

interface Admin {
  type: 'admin'
  name: string
  permissions: string[]
}

type Account = User | Admin

function isAdmin(account: Account): account is Admin {
  return account.type === 'admin'
}

export function AccountCard({ account }: { account: Account }) {
  if (isAdmin(account)) {
    // TypeScript knows account is Admin here
    return (
      <div>
        <p>{account.name}</p>
        <p>Permissions: {account.permissions.join(', ')}</p>
      </div>
    )
  }

  // TypeScript knows account is User here
  return (
    <div>
      <p>{account.name}</p>
      <p>{account.email}</p>
    </div>
  )
}
```

---

## forwardRef

### Typed forwardRef

```tsx
import { forwardRef } from 'react'

interface InputProps {
  label: string
  error?: string
}

export const Input = forwardRef<HTMLInputElement, InputProps>(
  ({ label, error }, ref) => {
    return (
      <div>
        <label>{label}</label>
        <input ref={ref} />
        {error && <span>{error}</span>}
      </div>
    )
  }
)

Input.displayName = 'Input'

// Usage
const inputRef = useRef<HTMLInputElement>(null)
<Input ref={inputRef} label="Name" />
```

---

## React.FC vs Function Components

```tsx
// ❌ Avoid: React.FC (deprecated pattern)
const Component: React.FC<Props> = ({ children }) => {
  return <div>{children}</div>
}

// ✅ Prefer: Regular function with typed props
function Component({ children }: { children: React.ReactNode }) {
  return <div>{children}</div>
}

// ✅ Or: Arrow function with typed props
const Component = ({ children }: { children: React.ReactNode }) => {
  return <div>{children}</div>
}
```

---

## Best Practices

### Prefer Interfaces Over Types for Props

```tsx
// ✅ Good: Interface (can be extended)
interface UserCardProps {
  user: User
  onEdit?: () => void
}

// Can be extended
interface AdminCardProps extends UserCardProps {
  permissions: string[]
}

// ❌ Less flexible: Type (can't be extended the same way)
type UserCardProps = {
  user: User
  onEdit?: () => void
}
```

### Use const Assertions

```tsx
// ✅ Good: Literal types preserved
const STATUSES = ['idle', 'loading', 'success', 'error'] as const
type Status = typeof STATUSES[number] // 'idle' | 'loading' | 'success' | 'error'

// ❌ Bad: Widened to string[]
const STATUSES = ['idle', 'loading', 'success', 'error']
```

### NonNullable Type

```tsx
interface User {
  id: string
  name: string
  email?: string
}

// Remove undefined/null from type
type RequiredEmail = NonNullable<User['email']> // string

function sendEmail(email: NonNullable<User['email']>) {
  // email is guaranteed to be string, not string | undefined
}
```
