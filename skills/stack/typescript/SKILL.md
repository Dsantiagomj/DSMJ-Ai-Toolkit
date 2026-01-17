---
name: typescript
domain: fullstack
description: >
  TypeScript type system for type-safe JavaScript development. Covers types, interfaces, generics, and configuration for both frontend and backend.
  Trigger: When writing TypeScript code, when defining types or interfaces, when using generics, when configuring tsconfig.json.
version: 1.0.0
tags: [typescript, types, javascript, fullstack, static-typing, type-safety]
metadata:
  version: "1.0"
  last_updated: "2026-01-17"
  category: stack
references:
  - name: TypeScript Documentation
    url: https://www.typescriptlang.org/
    type: documentation
  - name: TypeScript Handbook
    url: https://www.typescriptlang.org/docs/handbook/
    type: documentation
  - name: TypeScript GitHub
    url: https://github.com/microsoft/TypeScript
    type: repository
  - name: TypeScript Context7
    url: /websites/typescriptlang
    type: context7
  - name: Examples
    url: ./references/examples.md
    type: local
  - name: Advanced Patterns
    url: ./references/patterns.md
    type: local
  - name: Configuration
    url: ./references/configuration.md
    type: local
  - name: Advanced Types
    url: ./references/advanced-types.md
    type: local
  - name: Best Practices
    url: ./references/best-practices.md
    type: local
  - name: Node.js Patterns
    url: ./references/nodejs.md
    type: local
---

# TypeScript - Type-Safe JavaScript

**Static typing for JavaScript - works across frontend, backend, and full-stack applications**

---

## When to Use This Skill

**Use this skill when**:
- Writing any JavaScript code that would benefit from type safety
- Building Node.js backend applications
- Developing React, Vue, or other frontend frameworks
- Creating libraries or shared code packages
- Working with APIs and need to define request/response types
- Refactoring existing JavaScript to add type safety

**Don't use this skill when**:
- Writing simple scripts where type safety adds no value (config files, build scripts)
- Working with languages other than JavaScript/TypeScript (use their respective skills)
- Types become more complex than the value they provide (prefer simplicity)

---

## Critical Patterns

### Pattern 1: Type Inference vs Explicit Types

**When**: Writing functions and variables

**Good**:
```typescript
// ✅ Let TypeScript infer simple types
const name = 'John' // inferred as string
const age = 30 // inferred as number
const items = [1, 2, 3] // inferred as number[]

// ✅ Explicit types for function signatures (better docs)
function processUser(id: string, options?: { admin: boolean }): User {
  return { id, name: 'John', isAdmin: options?.admin ?? false }
}

// ✅ Infer return type for simple functions
const double = (n: number) => n * 2 // return type inferred as number

// ✅ Explicit return type for complex functions
async function fetchUser(id: string): Promise<User | null> {
  const response = await fetch(`/api/users/${id}`)
  if (!response.ok) return null
  return response.json()
}
```

**Bad**:
```typescript
// ❌ Over-annotating obvious types
const name: string = 'John' // unnecessary
const age: number = 30 // unnecessary

// ❌ Missing function parameter types
function processUser(id, options) { // any, any - loses type safety
  return { id, name: 'John' }
}

// ❌ Missing return types on exported functions
export function fetchUser(id: string) { // return type unclear
  return fetch(`/api/users/${id}`).then(r => r.json())
}
```

**Why**: Let TypeScript infer simple types to reduce noise. Add explicit types for function signatures to improve documentation and catch errors.

---

### Pattern 2: Discriminated Unions for Type Safety

**When**: Handling multiple possible states or types

**Good**:
```typescript
// ✅ Discriminated union with type field
type Result<T> =
  | { status: 'success'; data: T }
  | { status: 'error'; error: string }
  | { status: 'loading' }

function handleResult<T>(result: Result<T>) {
  if (result.status === 'success') {
    console.log(result.data) // ✅ TypeScript knows data exists
  } else if (result.status === 'error') {
    console.log(result.error) // ✅ TypeScript knows error exists
  } else {
    console.log('Loading...') // ✅ TypeScript knows no extra fields
  }
}

// ✅ Discriminated union for different shapes
type Shape =
  | { kind: 'circle'; radius: number }
  | { kind: 'rectangle'; width: number; height: number }
  | { kind: 'square'; size: number }

function calculateArea(shape: Shape): number {
  switch (shape.kind) {
    case 'circle':
      return Math.PI * shape.radius ** 2
    case 'rectangle':
      return shape.width * shape.height
    case 'square':
      return shape.size ** 2
  }
}
```

**Bad**:
```typescript
// ❌ Union without discriminator
type Result<T> = {
  data?: T
  error?: string
  loading?: boolean
}

function handleResult<T>(result: Result<T>) {
  if (result.data) {
    console.log(result.data) // ❌ Could still have error or loading
  }
}
```

**Why**: Discriminated unions provide exhaustive type checking and make illegal states unrepresentable.

---

### Pattern 3: Generic Constraints for Reusable Code

**When**: Writing reusable functions that work with multiple types

**Good**:
```typescript
// ✅ Generic with constraints
interface HasId {
  id: string
}

function findById<T extends HasId>(items: T[], id: string): T | undefined {
  return items.find(item => item.id === id) // ✅ TypeScript knows T has id
}

// ✅ keyof constraint
function getProperty<T, K extends keyof T>(obj: T, key: K): T[K] {
  return obj[key] // ✅ Type-safe property access
}

const user = { name: 'John', age: 30 }
const name = getProperty(user, 'name') // string
const age = getProperty(user, 'age') // number
```

**Bad**:
```typescript
// ❌ Generic without constraints
function findById<T>(items: T[], id: string): T | undefined {
  return items.find(item => item.id === id) // ❌ Error: 'id' doesn't exist on T
}

// ❌ Using any loses type safety
function getProperty(obj: any, key: string): any {
  return obj[key] // ❌ No type safety
}
```

**Why**: Generic constraints ensure type safety while maintaining flexibility.

---

### Pattern 4: Utility Types for Type Transformations

**When**: Deriving new types from existing ones

**Good**:
```typescript
interface User {
  id: string
  name: string
  email: string
  password: string
  role: 'admin' | 'user'
  createdAt: Date
}

// ✅ Pick for selecting specific properties
type UserPreview = Pick<User, 'id' | 'name'>

// ✅ Omit for excluding sensitive data
type PublicUser = Omit<User, 'password'>

// ✅ Partial for optional updates
function updateUser(id: string, updates: Partial<User>) {
  // ✅ Can update any subset of user fields
}

// ✅ Record for maps/dictionaries
type UserMap = Record<string, User>
const users: UserMap = {
  'user1': { id: '1', name: 'John', /* ... */ },
}

// ✅ ReturnType to extract function return type
function getUser() {
  return { id: '1', name: 'John', email: 'john@example.com' }
}

type UserType = ReturnType<typeof getUser>
```

**Bad**:
```typescript
// ❌ Manually duplicating types
type UserPreview = {
  id: string // ❌ Duplicated from User
  name: string // ❌ Duplicated from User
}
```

**Why**: Utility types keep types DRY and automatically sync with source types.

For more examples and patterns, see [references/examples.md](./references/examples.md) and [references/patterns.md](./references/patterns.md).

---

## Anti-Patterns

### ❌ Anti-Pattern 1: Overusing `any`

**Don't do this**:
```typescript
// ❌ Using any defeats the purpose of TypeScript
function processData(data: any): any {
  return data.map((item: any) => item.value)
}
```

**Why it's bad**: Disables TypeScript's type checking, loses IntelliSense.

**Do this instead**:
```typescript
// ✅ Use specific types or generics
function processData<T extends { value: any }>(data: T[]): any[] {
  return data.map(item => item.value)
}

// ✅ Or use unknown for truly unknown data
function processUnknown(data: unknown) {
  if (typeof data === 'string') {
    return data.toUpperCase() // ✅ Type narrowed to string
  }
  throw new Error('Invalid data')
}
```

---

### ❌ Anti-Pattern 2: Type Assertions Instead of Type Guards

**Don't do this**:
```typescript
// ❌ Unsafe type assertion
function processUser(data: any) {
  const user = data as User // ❌ No runtime check
  console.log(user.name.toUpperCase()) // ❌ Runtime error if not a User
}
```

**Why it's bad**: Type assertions bypass type checking and can cause runtime errors.

**Do this instead**:
```typescript
// ✅ Type guards for runtime validation
function isUser(data: unknown): data is User {
  return (
    typeof data === 'object' &&
    data !== null &&
    'id' in data &&
    'name' in data
  )
}

function processUser(data: unknown) {
  if (isUser(data)) {
    console.log(data.name.toUpperCase()) // ✅ Type-safe
  }
}
```

---

### ❌ Anti-Pattern 3: Ignoring Strict Mode

**Don't do this**:
```typescript
// tsconfig.json
{
  "compilerOptions": {
    "strict": false // ❌ Disables all strict checks
  }
}
```

**Why it's bad**: Disables TypeScript's most valuable features.

**Do this instead**:
```typescript
// tsconfig.json
{
  "compilerOptions": {
    "strict": true, // ✅ Enable all strict checks
    "noUncheckedIndexedAccess": true,
    "noImplicitOverride": true
  }
}
```

For more anti-patterns and solutions, see [references/best-practices.md](./references/best-practices.md).

---

## Quick Reference

```typescript
// Type annotations
let name: string = 'John'
let numbers: number[] = [1, 2, 3]

// Interfaces
interface User {
  id: string
  name: string
  email?: string // Optional
}

// Type aliases
type ID = string | number
type Status = 'idle' | 'loading' | 'success'

// Functions
function add(a: number, b: number): number {
  return a + b
}

// Generics
function identity<T>(value: T): T {
  return value
}

// Utility types
Partial<T>        // All properties optional
Required<T>       // All properties required
Readonly<T>       // All properties readonly
Pick<T, K>        // Select properties
Omit<T, K>        // Exclude properties
Record<K, T>      // Object with keys K and values T
```

---

## Learn More

- **Examples**: [references/examples.md](./references/examples.md) - Complete code examples for basic and advanced usage
- **Advanced Patterns**: [references/patterns.md](./references/patterns.md) - Mapped types, conditional types, advanced generics
- **Configuration**: [references/configuration.md](./references/configuration.md) - tsconfig.json, compiler options
- **Advanced Types**: [references/advanced-types.md](./references/advanced-types.md) - Template literals, branded types
- **Best Practices**: [references/best-practices.md](./references/best-practices.md) - Code organization, naming conventions
- **Node.js Patterns**: [references/nodejs.md](./references/nodejs.md) - Express, Prisma, tRPC integration

---

## External References

- [TypeScript Documentation](https://www.typescriptlang.org/)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/)

---

_Maintained by dsmj-ai-toolkit_
