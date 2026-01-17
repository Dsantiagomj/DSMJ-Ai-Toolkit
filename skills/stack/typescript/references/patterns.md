# Advanced TypeScript Patterns

## Advanced Utility Types

### Complex Type Transformations

```typescript
interface User {
  id: string
  name: string
  email: string
  password: string
  role: 'admin' | 'user'
  createdAt: Date
}

// Pick for selecting specific properties
type UserPreview = Pick<User, 'id' | 'name'>
// { id: string, name: string }

// Omit for excluding sensitive data
type PublicUser = Omit<User, 'password'>
// { id, name, email, role, createdAt }

// Partial for optional updates
type UserUpdate = Partial<User>
// All properties optional

function updateUser(id: string, updates: Partial<User>) {
  // Can update any subset of user fields
}

// Required for making all properties required
type RequiredUser = Required<Partial<User>>
// All properties required

// Readonly for immutable data
type ImmutableUser = Readonly<User>
const user: ImmutableUser = { /* ... */ }
// user.name = 'Jane' // Error: readonly property

// Record for maps/dictionaries
type UserMap = Record<string, User>
const users: UserMap = {
  'user1': { id: '1', name: 'John', /* ... */ },
  'user2': { id: '2', name: 'Jane', /* ... */ }
}

// ReturnType to extract function return type
function getUser() {
  return { id: '1', name: 'John', email: 'john@example.com' }
}

type UserType = ReturnType<typeof getUser>
// { id: string, name: string, email: string }
```

---

## Mapped Types

### Custom Mapped Types

```typescript
// Make all properties optional and nullable
type Nullable<T> = {
  [P in keyof T]: T[P] | null
}

type NullableUser = Nullable<User>
// { id: string | null, name: string | null, ... }

// Make specific properties required
type RequireKeys<T, K extends keyof T> = T & Required<Pick<T, K>>

interface Config {
  host?: string
  port?: number
  secure?: boolean
}

type ConfigWithHost = RequireKeys<Config, 'host'>
// { host: string, port?: number, secure?: boolean }

// Deep Readonly
type DeepReadonly<T> = {
  readonly [P in keyof T]: T[P] extends object ? DeepReadonly<T[P]> : T[P]
}

interface NestedData {
  user: {
    profile: {
      name: string
    }
  }
}

type ReadonlyNested = DeepReadonly<NestedData>
// All nested properties are readonly
```

---

## Conditional Types

### Advanced Conditional Patterns

```typescript
// UnwrapPromise
type UnwrapPromise<T> = T extends Promise<infer U> ? U : T

type A = UnwrapPromise<Promise<string>> // string
type B = UnwrapPromise<number> // number

// Extract array element type
type ArrayElement<T> = T extends (infer U)[] ? U : T

type C = ArrayElement<string[]> // string
type D = ArrayElement<number> // number

// Function return type extraction
type ReturnTypeOf<T> = T extends (...args: any[]) => infer R ? R : never

function getNumber() {
  return 42
}

type NumberType = ReturnTypeOf<typeof getNumber> // number

// Exclude null and undefined
type NonNullish<T> = T extends null | undefined ? never : T

type E = NonNullish<string | null> // string
type F = NonNullish<number | undefined> // number
```

---

## Template Literal Types

### String Type Manipulation

```typescript
// Combine string literals
type Color = 'red' | 'blue' | 'green'
type Size = 'small' | 'medium' | 'large'

type ColoredSize = `${Color}-${Size}`
// 'red-small' | 'red-medium' | 'red-large' | 'blue-small' | ...

// HTTP methods with paths
type HTTPMethod = 'GET' | 'POST' | 'PUT' | 'DELETE'
type API = '/users' | '/posts' | '/comments'

type Endpoint = `${HTTPMethod} ${API}`
// 'GET /users' | 'POST /users' | ...

// CSS properties
type CSSProperty = 'margin' | 'padding'
type CSSValue = 'top' | 'bottom' | 'left' | 'right'

type CSSRule = `${CSSProperty}-${CSSValue}`
// 'margin-top' | 'margin-bottom' | ...
```

---

## Branded Types

### Type Safety for Primitives

```typescript
// Create branded types for stronger typing
type UserId = string & { readonly brand: unique symbol }
type PostId = string & { readonly brand: unique symbol }

function createUserId(id: string): UserId {
  return id as UserId
}

function createPostId(id: string): PostId {
  return id as PostId
}

function getUser(id: UserId) {
  // Only accepts UserId, not just any string
}

const userId = createUserId('user123')
const postId = createPostId('post456')

getUser(userId) // OK
// getUser(postId) // Error: PostId is not assignable to UserId
// getUser('user123') // Error: string is not assignable to UserId
```

---

## Advanced Generics

### Generic Constraints and Inference

```typescript
// Generic with multiple constraints
interface HasId {
  id: string
}

interface HasTimestamps {
  createdAt: Date
  updatedAt: Date
}

function findById<T extends HasId & HasTimestamps>(
  items: T[],
  id: string
): T | undefined {
  return items.find(item => item.id === id)
}

// Conditional generic constraints
type OnlyStrings<T> = T extends string ? T : never

type ValidKeys = OnlyStrings<'name' | 'email' | 123>
// 'name' | 'email' (123 is filtered out)

// Generic factory pattern
interface Constructor<T = any> {
  new (...args: any[]): T
}

function createInstance<T>(ctor: Constructor<T>): T {
  return new ctor()
}

class User {
  constructor(public name: string = 'John') {}
}

const user = createInstance(User)
```

---

## Type Inference Patterns

### Infer Keyword Usage

```typescript
// Extract parameter types
type Parameters<T extends (...args: any) => any> = T extends (
  ...args: infer P
) => any
  ? P
  : never

type FnParams = Parameters<(a: string, b: number) => void>
// [string, number]

// Extract constructor parameters
type ConstructorParameters<T extends new (...args: any) => any> =
  T extends new (...args: infer P) => any ? P : never

class Example {
  constructor(public name: string, public age: number) {}
}

type ExampleParams = ConstructorParameters<typeof Example>
// [string, number]

// Extract instance type
type InstanceType<T extends new (...args: any) => any> = T extends new (
  ...args: any
) => infer R
  ? R
  : any

type ExampleInstance = InstanceType<typeof Example>
// Example
```

---

## Recursive Types

### Deep Type Operations

```typescript
// Deep Partial
type DeepPartial<T> = {
  [P in keyof T]?: T[P] extends object ? DeepPartial<T[P]> : T[P]
}

interface NestedUser {
  id: string
  profile: {
    name: string
    address: {
      street: string
      city: string
    }
  }
}

type PartialNestedUser = DeepPartial<NestedUser>
// All nested properties optional

// Flatten object type
type Flatten<T> = T extends Array<infer U> ? U : T

type FlatArray = Flatten<string[]> // string
type NotArray = Flatten<number> // number

// Path to property
type PathToProperty<T, K extends keyof T> = K extends string
  ? T[K] extends Record<string, any>
    ? K | `${K}.${PathToProperty<T[K], keyof T[K]> & string}`
    : K
  : never

type UserPath = PathToProperty<NestedUser, keyof NestedUser>
// 'id' | 'profile' | 'profile.name' | 'profile.address' | 'profile.address.street' | ...
```

---

## Builder Pattern with Types

### Type-Safe Fluent API

```typescript
class QueryBuilder<T> {
  private filters: Array<(item: T) => boolean> = []
  private sorter?: (a: T, b: T) => number
  private limitValue?: number

  where(predicate: (item: T) => boolean): this {
    this.filters.push(predicate)
    return this
  }

  orderBy(compareFn: (a: T, b: T) => number): this {
    this.sorter = compareFn
    return this
  }

  limit(n: number): this {
    this.limitValue = n
    return this
  }

  execute(data: T[]): T[] {
    let result = data.filter(item => this.filters.every(f => f(item)))

    if (this.sorter) {
      result = result.sort(this.sorter)
    }

    if (this.limitValue) {
      result = result.slice(0, this.limitValue)
    }

    return result
  }
}

interface User {
  name: string
  age: number
}

const users: User[] = [
  { name: 'John', age: 30 },
  { name: 'Jane', age: 25 },
]

const result = new QueryBuilder<User>()
  .where(u => u.age > 20)
  .orderBy((a, b) => a.age - b.age)
  .limit(10)
  .execute(users)
```
