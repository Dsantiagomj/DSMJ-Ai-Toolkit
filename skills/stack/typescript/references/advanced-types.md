# Advanced Types - TypeScript

## Mapped Types

### Basic Mapped Types

```typescript
type User = {
  id: string
  name: string
  email: string
}

// Make all properties optional
type PartialUser = {
  [K in keyof User]?: User[K]
}

// Make all properties readonly
type ReadonlyUser = {
  readonly [K in keyof User]: User[K]
}

// Make all properties nullable
type NullableUser = {
  [K in keyof User]: User[K] | null
}
```

### Mapped Types with Modifiers

```typescript
// Remove readonly modifier
type Mutable<T> = {
  -readonly [K in keyof T]: T[K]
}

// Remove optional modifier
type Required<T> = {
  [K in keyof T]-?: T[K]
}

// Add readonly and optional
type ReadonlyPartial<T> = {
  readonly [K in keyof T]?: T[K]
}
```

### Key Remapping

```typescript
// Prefix all keys with "get"
type Getters<T> = {
  [K in keyof T as `get${Capitalize<string & K>}`]: () => T[K]
}

interface User {
  name: string
  age: number
}

type UserGetters = Getters<User>
// {
//   getName: () => string
//   getAge: () => number
// }

// Filter out specific keys
type OmitId<T> = {
  [K in keyof T as Exclude<K, 'id'>]: T[K]
}

// Convert union to mapped type
type EventMap<T extends string> = {
  [K in T]: (payload: any) => void
}

type Events = EventMap<'click' | 'hover' | 'focus'>
// {
//   click: (payload: any) => void
//   hover: (payload: any) => void
//   focus: (payload: any) => void
// }
```

---

## Conditional Types

### Basic Conditional Types

```typescript
// Syntax: T extends U ? X : Y
type IsString<T> = T extends string ? true : false

type A = IsString<string> // true
type B = IsString<number> // false

// Extract array element type
type ArrayElement<T> = T extends (infer E)[] ? E : never

type Numbers = ArrayElement<number[]> // number
type Strings = ArrayElement<string[]> // string
```

### Distributive Conditional Types

```typescript
// Distributes over unions
type ToArray<T> = T extends any ? T[] : never

type StrOrNum = string | number
type ArrayType = ToArray<StrOrNum> // string[] | number[]

// Non-distributive (wrap in tuple)
type ToArrayNonDist<T> = [T] extends [any] ? T[] : never
type ArrayType2 = ToArrayNonDist<StrOrNum> // (string | number)[]
```

### Inferring Types

```typescript
// Infer return type
type ReturnType<T> = T extends (...args: any[]) => infer R ? R : never

function getUser() {
  return { id: '123', name: 'John' }
}

type User = ReturnType<typeof getUser> // { id: string; name: string }

// Infer array element type
type Flatten<T> = T extends Array<infer U> ? U : T

type Num = Flatten<number[]> // number
type Str = Flatten<string> // string

// Infer promise type
type Awaited<T> = T extends Promise<infer U> ? U : T

type Result = Awaited<Promise<string>> // string
```

---

## Template Literal Types

### Basic Template Literals

```typescript
type Greeting = `Hello, ${string}!`

const greeting1: Greeting = 'Hello, World!' // ✅
const greeting2: Greeting = 'Hi there!' // ❌

// Combine with unions
type Color = 'red' | 'green' | 'blue'
type HexColor = `#${string}`
type ColorValue = Color | HexColor

// Event names
type EventName = 'click' | 'focus' | 'blur'
type EventHandler = `on${Capitalize<EventName>}`
// 'onClick' | 'onFocus' | 'onBlur'
```

### Template Literal Utilities

```typescript
// Uppercase
type UpperName = Uppercase<'john'> // 'JOHN'

// Lowercase
type LowerName = Lowercase<'JOHN'> // 'john'

// Capitalize
type CapName = Capitalize<'john'> // 'John'

// Uncapitalize
type UncapName = Uncapitalize<'John'> // 'john'

// Combine
type MakeGetter<T extends string> = `get${Capitalize<T>}`
type Getter = MakeGetter<'userName'> // 'getUserName'
```

### Advanced Template Literals

```typescript
// HTTP methods with paths
type Method = 'GET' | 'POST' | 'PUT' | 'DELETE'
type Path = '/users' | '/posts' | '/comments'
type Route = `${Method} ${Path}`
// 'GET /users' | 'GET /posts' | ... | 'DELETE /comments'

// CSS properties
type CSSProperty =
  | 'margin'
  | 'padding'
  | 'border'

type Side = 'top' | 'right' | 'bottom' | 'left'
type CSSPropertyWithSide = `${CSSProperty}-${Side}`
// 'margin-top' | 'margin-right' | ... | 'border-left'

// Database field paths
type NestedKeyOf<T> = T extends object
  ? {
      [K in keyof T]: K extends string
        ? T[K] extends object
          ? `${K}` | `${K}.${NestedKeyOf<T[K]>}`
          : `${K}`
        : never
    }[keyof T]
  : never

interface User {
  profile: {
    name: string
    address: {
      city: string
    }
  }
}

type UserPath = NestedKeyOf<User>
// 'profile' | 'profile.name' | 'profile.address' | 'profile.address.city'
```

---

## Recursive Types

### Recursive Object Types

```typescript
// JSON type
type JSONValue =
  | string
  | number
  | boolean
  | null
  | JSONValue[]
  | { [key: string]: JSONValue }

const data: JSONValue = {
  name: 'John',
  age: 30,
  hobbies: ['reading', 'coding'],
  address: {
    city: 'NYC',
    coordinates: [40.7128, -74.0060]
  }
}

// Deeply nested object
type DeepPartial<T> = {
  [K in keyof T]?: T[K] extends object ? DeepPartial<T[K]> : T[K]
}

interface Config {
  database: {
    host: string
    port: number
    credentials: {
      username: string
      password: string
    }
  }
}

const partialConfig: DeepPartial<Config> = {
  database: {
    credentials: {
      username: 'admin'
    }
  }
}
```

### Path Building

```typescript
type PathsToStringProps<T> = T extends string
  ? []
  : {
      [K in Extract<keyof T, string>]: [K, ...PathsToStringProps<T[K]>]
    }[Extract<keyof T, string>]

type Join<T extends string[], D extends string = '.'> = T extends []
  ? never
  : T extends [infer F]
  ? F
  : T extends [infer F, ...infer R]
  ? F extends string
    ? `${F}${D}${Join<Extract<R, string[]>, D>}`
    : never
  : string

interface User {
  profile: {
    name: string
    settings: {
      theme: string
    }
  }
}

type UserPaths = Join<PathsToStringProps<User>>
// 'profile' | 'profile.name' | 'profile.settings' | 'profile.settings.theme'
```

---

## Branded Types

### Nominal Typing

```typescript
// Brand type to create nominal types
type Brand<K, T> = K & { __brand: T }

type UserId = Brand<string, 'UserId'>
type ProductId = Brand<string, 'ProductId'>

function getUserById(id: UserId): void {
  console.log('User:', id)
}

const userId = 'user-123' as UserId
const productId = 'product-456' as ProductId

getUserById(userId) // ✅
getUserById(productId) // ❌ Type error
```

### Tagged Types

```typescript
interface User {
  _tag: 'User'
  id: string
  name: string
}

interface Product {
  _tag: 'Product'
  id: string
  price: number
}

type Entity = User | Product

function processEntity(entity: Entity) {
  switch (entity._tag) {
    case 'User':
      console.log(entity.name) // TypeScript knows this is User
      break
    case 'Product':
      console.log(entity.price) // TypeScript knows this is Product
      break
  }
}
```

---

## Index Signatures

### Basic Index Signatures

```typescript
// String index
interface StringMap {
  [key: string]: string
}

const map: StringMap = {
  name: 'John',
  email: 'john@example.com'
}

// Number index
interface NumberMap {
  [key: number]: string
}

const arr: NumberMap = ['a', 'b', 'c']

// Mixed
interface Dictionary {
  [key: string]: string | number
  length: number // Specific property
}
```

### Record Type

```typescript
// Better alternative to index signatures
type StringRecord = Record<string, string>
type UserRoles = Record<string, string[]>

const roles: UserRoles = {
  admin: ['read', 'write', 'delete'],
  user: ['read']
}

// With specific keys
type Status = 'idle' | 'loading' | 'success' | 'error'
type StatusMap = Record<Status, string>

const statusMessages: StatusMap = {
  idle: 'Ready',
  loading: 'Loading...',
  success: 'Done!',
  error: 'Failed'
}
```

---

## Variance

### Covariance and Contravariance

```typescript
// Covariance (return types)
interface Producer<T> {
  produce: () => T
}

let animalProducer: Producer<Animal>
let dogProducer: Producer<Dog>

animalProducer = dogProducer // ✅ OK (covariant)

// Contravariance (parameter types)
interface Consumer<T> {
  consume: (item: T) => void
}

let animalConsumer: Consumer<Animal>
let dogConsumer: Consumer<Dog>

dogConsumer = animalConsumer // ✅ OK (contravariant)

// Invariance (both parameter and return)
interface Box<T> {
  value: T
  set: (value: T) => void
}

let animalBox: Box<Animal>
let dogBox: Box<Dog>

animalBox = dogBox // ❌ Error (invariant)
```

---

## Advanced Utility Types

### DeepReadonly

```typescript
type DeepReadonly<T> = {
  readonly [K in keyof T]: T[K] extends object
    ? DeepReadonly<T[K]>
    : T[K]
}

interface Config {
  database: {
    host: string
    port: number
  }
}

const config: DeepReadonly<Config> = {
  database: {
    host: 'localhost',
    port: 5432
  }
}

config.database.host = 'newhost' // ❌ Error
```

### DeepRequired

```typescript
type DeepRequired<T> = {
  [K in keyof T]-?: T[K] extends object
    ? DeepRequired<T[K]>
    : T[K]
}
```

### Mutable (Remove Readonly)

```typescript
type Mutable<T> = {
  -readonly [K in keyof T]: T[K]
}

interface ReadonlyUser {
  readonly id: string
  readonly name: string
}

type MutableUser = Mutable<ReadonlyUser>
// { id: string; name: string }
```

### PickByValue

```typescript
type PickByValue<T, V> = {
  [K in keyof T as T[K] extends V ? K : never]: T[K]
}

interface User {
  id: string
  name: string
  age: number
  email: string
}

type StringProps = PickByValue<User, string>
// { id: string; name: string; email: string }
```

### OmitByValue

```typescript
type OmitByValue<T, V> = {
  [K in keyof T as T[K] extends V ? never : K]: T[K]
}

type NonStringProps = OmitByValue<User, string>
// { age: number }
```

### NonNullableProperties

```typescript
type NonNullableProperties<T> = {
  [K in keyof T]: NonNullable<T[K]>
}

interface User {
  name: string | null
  email: string | undefined
  age: number
}

type RequiredUser = NonNullableProperties<User>
// { name: string; email: string; age: number }
```

---

## Type Challenges

### Function Composition

```typescript
type Compose<F extends Function, G extends Function> =
  F extends (arg: infer A) => infer B
    ? G extends (arg: B) => infer C
      ? (arg: A) => C
      : never
    : never

const add1 = (x: number) => x + 1
const toString = (x: number) => x.toString()

type Combined = Compose<typeof add1, typeof toString>
// (arg: number) => string
```

### Tuple to Union

```typescript
type TupleToUnion<T extends readonly any[]> = T[number]

type Numbers = TupleToUnion<[1, 2, 3]> // 1 | 2 | 3
type Strings = TupleToUnion<['a', 'b', 'c']> // 'a' | 'b' | 'c'
```

### Union to Intersection

```typescript
type UnionToIntersection<U> =
  (U extends any ? (k: U) => void : never) extends (k: infer I) => void
    ? I
    : never

type Union = { a: string } | { b: number }
type Intersection = UnionToIntersection<Union>
// { a: string } & { b: number }
```

### Get Required Keys

```typescript
type RequiredKeys<T> = {
  [K in keyof T]-?: {} extends Pick<T, K> ? never : K
}[keyof T]

interface User {
  id: string
  name: string
  email?: string
  age?: number
}

type Required = RequiredKeys<User> // 'id' | 'name'
```

### Get Optional Keys

```typescript
type OptionalKeys<T> = {
  [K in keyof T]-?: {} extends Pick<T, K> ? K : never
}[keyof T]

type Optional = OptionalKeys<User> // 'email' | 'age'
```
