# Best Practices - TypeScript

## Type Safety

### Avoid any

```typescript
// ❌ Bad: Loses all type safety
function processData(data: any) {
  return data.value
}

// ✅ Good: Use unknown when type is truly unknown
function processData(data: unknown) {
  if (typeof data === 'object' && data !== null && 'value' in data) {
    return (data as { value: any }).value
  }
  throw new Error('Invalid data')
}

// ✅ Better: Use generics
function processData<T extends { value: unknown }>(data: T) {
  return data.value
}
```

### Strict Null Checks

```typescript
// ❌ Bad: Nullable values without checks
function getLength(str: string | null): number {
  return str.length // Error with strictNullChecks
}

// ✅ Good: Handle null explicitly
function getLength(str: string | null): number {
  if (str === null) {
    return 0
  }
  return str.length
}

// ✅ Good: Use optional chaining
function getLength(str: string | null): number {
  return str?.length ?? 0
}

// ✅ Good: Use type guards
function isString(value: unknown): value is string {
  return typeof value === 'string'
}
```

### Type Assertions

```typescript
// ❌ Bad: Unsafe type assertion
const value = data as string

// ✅ Good: Type guard before assertion
if (typeof data === 'string') {
  const value: string = data
}

// ❌ Bad: Double assertion (escape hatch)
const value = data as unknown as string

// ✅ Good: Use type predicate
function isString(value: unknown): value is string {
  return typeof value === 'string'
}

if (isString(data)) {
  const value: string = data
}
```

---

## Naming Conventions

### Interfaces and Types

```typescript
// ✅ Good: PascalCase for types and interfaces
interface User {
  id: string
  name: string
}

type UserRole = 'admin' | 'user' | 'guest'

// ❌ Bad: Don't prefix with I
interface IUser { } // Avoid

// ✅ Good: Descriptive names
interface UserCreateInput {
  name: string
  email: string
}

interface UserUpdateInput {
  name?: string
  email?: string
}
```

### Variables and Functions

```typescript
// ✅ Good: camelCase for variables and functions
const userName = 'John'
function getUserById(id: string) { }

// ✅ Good: UPPER_SNAKE_CASE for constants
const MAX_RETRY_COUNT = 3
const API_BASE_URL = 'https://api.example.com'

// ✅ Good: Descriptive boolean names
const isLoading = true
const hasError = false
const canEdit = true
```

### Generics

```typescript
// ✅ Good: Single letter for simple generics
function identity<T>(value: T): T {
  return value
}

// ✅ Good: Descriptive names for complex generics
function mapArray<TInput, TOutput>(
  arr: TInput[],
  fn: (item: TInput) => TOutput
): TOutput[] {
  return arr.map(fn)
}

// ✅ Convention: T, U, V for types; K, V for key-value pairs
type Record<K extends string | number, V> = {
  [P in K]: V
}
```

---

## Code Organization

### File Structure

```
src/
├── types/              # Shared type definitions
│   ├── user.ts
│   ├── api.ts
│   └── index.ts
├── lib/                # Utilities and helpers
│   ├── db.ts
│   └── auth.ts
├── models/             # Data models
│   └── user.model.ts
└── services/           # Business logic
    └── user.service.ts
```

### Export Patterns

```typescript
// ✅ Good: Named exports (tree-shakeable)
export interface User {
  id: string
  name: string
}

export function getUser(id: string): User {
  // ...
}

// ❌ Bad: Default export for types (harder to refactor)
export default interface User {
  id: string
}

// ✅ Good: Barrel exports for convenience
// types/index.ts
export * from './user'
export * from './api'

// Usage
import { User, ApiResponse } from '@/types'
```

### Declaration Files

```typescript
// types/api.d.ts
declare namespace API {
  interface Response<T> {
    data: T
    error: string | null
  }

  interface PaginatedResponse<T> extends Response<T[]> {
    page: number
    total: number
  }
}

// Usage
const response: API.Response<User> = await fetchUser()
```

---

## Interface vs Type

### When to Use Interface

```typescript
// ✅ Good: Use interface for object shapes
interface User {
  id: string
  name: string
}

// ✅ Good: Interfaces can be extended
interface Admin extends User {
  permissions: string[]
}

// ✅ Good: Interfaces can be merged (declaration merging)
interface Window {
  myCustomProperty: string
}
```

### When to Use Type

```typescript
// ✅ Good: Use type for unions
type Status = 'idle' | 'loading' | 'success' | 'error'

// ✅ Good: Use type for intersections
type UserWithTimestamps = User & {
  createdAt: Date
  updatedAt: Date
}

// ✅ Good: Use type for mapped types
type Nullable<T> = {
  [K in keyof T]: T[K] | null
}

// ✅ Good: Use type for conditional types
type NonNullable<T> = T extends null | undefined ? never : T
```

---

## Function Overloads

### Proper Overloading

```typescript
// ✅ Good: Clear overload signatures
function createElement(tag: 'div'): HTMLDivElement
function createElement(tag: 'span'): HTMLSpanElement
function createElement(tag: 'button'): HTMLButtonElement
function createElement(tag: string): HTMLElement {
  return document.createElement(tag)
}

const div = createElement('div') // HTMLDivElement
const span = createElement('span') // HTMLSpanElement

// ❌ Bad: Over-complicating with too many overloads
function fn(x: number): number
function fn(x: string): string
function fn(x: boolean): boolean
function fn(x: any[]): any[]
// ... 10 more overloads
function fn(x: any): any { }
```

---

## Generics Best Practices

### Constraint Generics

```typescript
// ❌ Bad: Too generic
function getProperty<T>(obj: T, key: string) {
  return obj[key] // Error
}

// ✅ Good: Constrain to object with key
function getProperty<T, K extends keyof T>(obj: T, key: K): T[K] {
  return obj[key]
}

// ✅ Good: Extend from interface
interface HasId {
  id: string
}

function findById<T extends HasId>(items: T[], id: string): T | undefined {
  return items.find(item => item.id === id)
}
```

### Default Generic Types

```typescript
// ✅ Good: Provide sensible defaults
interface Response<T = unknown> {
  data: T
  status: number
}

const response: Response = { data: {}, status: 200 }
const userResponse: Response<User> = { data: user, status: 200 }
```

---

## Error Handling

### Type-Safe Errors

```typescript
// ✅ Good: Custom error classes
class ValidationError extends Error {
  constructor(
    message: string,
    public field: string
  ) {
    super(message)
    this.name = 'ValidationError'
  }
}

class NotFoundError extends Error {
  constructor(
    message: string,
    public resource: string
  ) {
    super(message)
    this.name = 'NotFoundError'
  }
}

// ✅ Good: Result type pattern
type Result<T, E = Error> =
  | { success: true; data: T }
  | { success: false; error: E }

async function fetchUser(id: string): Promise<Result<User>> {
  try {
    const user = await db.user.findUnique({ where: { id } })
    if (!user) {
      return { success: false, error: new NotFoundError('User not found', 'user') }
    }
    return { success: true, data: user }
  } catch (error) {
    return { success: false, error: error as Error }
  }
}

// Usage
const result = await fetchUser('123')
if (result.success) {
  console.log(result.data.name) // Type-safe
} else {
  console.error(result.error.message)
}
```

---

## Immutability

### Readonly Properties

```typescript
// ✅ Good: Use readonly for immutable data
interface Config {
  readonly apiUrl: string
  readonly timeout: number
}

// ✅ Good: Readonly arrays
const numbers: readonly number[] = [1, 2, 3]
numbers.push(4) // ❌ Error

// ✅ Good: ReadonlyArray type
const names: ReadonlyArray<string> = ['John', 'Jane']

// ✅ Good: Deeply readonly
type DeepReadonly<T> = {
  readonly [K in keyof T]: T[K] extends object
    ? DeepReadonly<T[K]>
    : T[K]
}
```

### As Const

```typescript
// ❌ Bad: Mutable literal
const colors = ['red', 'green', 'blue'] // string[]

// ✅ Good: Readonly literal
const colors = ['red', 'green', 'blue'] as const
// readonly ['red', 'green', 'blue']

type Color = typeof colors[number] // 'red' | 'green' | 'blue'

// ✅ Good: Const objects
const config = {
  apiUrl: 'https://api.example.com',
  timeout: 5000
} as const
// readonly { apiUrl: 'https://api.example.com'; timeout: 5000 }
```

---

## Performance

### Type Computation

```typescript
// ❌ Bad: Deep recursion can be slow
type DeepNested = {
  value: DeepNested
}

// ✅ Good: Limit recursion depth
type DeepPartial<T, D extends number = 10> = D extends 0
  ? T
  : {
      [K in keyof T]?: T[K] extends object
        ? DeepPartial<T[K], Prev<D>>
        : T[K]
    }
```

### Avoid Expensive Computations

```typescript
// ❌ Bad: Complex type computation on every usage
type ComplexUnion<T> = T extends any
  ? T extends any
    ? T extends any
      ? T
      : never
    : never
  : never

// ✅ Good: Compute once and reuse
type PrecomputedType = ComplexUnion<MyType>
function fn(value: PrecomputedType) { }
```

---

## Documentation

### JSDoc Comments

```typescript
/**
 * Fetches a user by ID from the database.
 *
 * @param id - The unique identifier of the user
 * @returns A promise that resolves to the user object
 * @throws {NotFoundError} When user is not found
 * @throws {DatabaseError} When database operation fails
 *
 * @example
 * ```typescript
 * const user = await getUser('user-123')
 * console.log(user.name)
 * ```
 */
async function getUser(id: string): Promise<User> {
  // ...
}

/**
 * Configuration options for the API client.
 */
interface ApiConfig {
  /** Base URL for all API requests */
  baseUrl: string

  /** Timeout in milliseconds (default: 5000) */
  timeout?: number

  /** Custom headers to include in all requests */
  headers?: Record<string, string>
}
```

---

## Common Pitfalls

### ❌ Ignoring Errors

```typescript
// Bad
async function fetchData() {
  try {
    return await fetch('/api/data')
  } catch {
    // Silently ignoring errors
  }
}

// Good
async function fetchData(): Promise<Response> {
  try {
    return await fetch('/api/data')
  } catch (error) {
    console.error('Failed to fetch data:', error)
    throw error
  }
}
```

### ❌ Using Non-Null Assertion Carelessly

```typescript
// Bad: Assumes value exists
const value = data!.value!.nested!.field

// Good: Use optional chaining
const value = data?.value?.nested?.field

// Good: Check explicitly
if (data?.value?.nested?.field) {
  const value = data.value.nested.field
}
```

### ❌ Modifying Readonly Types

```typescript
// Bad: Casting away readonly
const data: readonly number[] = [1, 2, 3]
;(data as number[]).push(4)

// Good: Create new array
const newData = [...data, 4]
```

---

## Testing with TypeScript

### Type-Safe Tests

```typescript
import { expect, test } from 'vitest'

test('user service', () => {
  const user: User = {
    id: '123',
    name: 'John',
    email: 'john@example.com'
  }

  // Type-safe assertions
  expect(user.name).toBe('John')
  expect(user.email).toContain('@')
})

// Type-safe mocks
interface UserService {
  getUser(id: string): Promise<User>
  updateUser(id: string, data: Partial<User>): Promise<User>
}

const mockUserService: UserService = {
  getUser: vi.fn(),
  updateUser: vi.fn()
}
```

---

## Migration Tips

### Gradual Adoption

```json
// tsconfig.json - Start permissive
{
  "compilerOptions": {
    "strict": false,
    "noImplicitAny": false,
    "allowJs": true,
    "checkJs": false
  }
}

// Gradually enable strict options
{
  "compilerOptions": {
    "noImplicitAny": true,    // Enable first
    "strictNullChecks": true, // Then this
    "strict": true            // Finally all strict options
  }
}
```

### @ts-check for JavaScript

```javascript
// @ts-check

/**
 * @param {string} name
 * @param {number} age
 * @returns {User}
 */
function createUser(name, age) {
  return { id: '123', name, age }
}
```

---

## Checklist

- [ ] Enable `strict: true` in tsconfig.json
- [ ] Avoid `any` - use `unknown` or generics
- [ ] Use type guards for narrowing
- [ ] Prefer `interface` for object shapes
- [ ] Prefer `type` for unions and mapped types
- [ ] Use `readonly` for immutable data
- [ ] Document complex types with JSDoc
- [ ] Constrain generics appropriately
- [ ] Handle errors type-safely
- [ ] Use proper file organization
- [ ] Follow naming conventions
- [ ] Test with type-safe assertions
