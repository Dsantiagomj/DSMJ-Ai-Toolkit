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
const items: number[] = [1, 2, 3] // unnecessary

// ❌ Missing function parameter types
function processUser(id, options) { // any, any - loses type safety
  return { id, name: 'John' }
}

// ❌ Missing return types on exported functions
export function fetchUser(id: string) { // return type unclear
  return fetch(`/api/users/${id}`).then(r => r.json())
}
```

**Why**: Let TypeScript infer simple types to reduce noise. Add explicit types for function signatures to improve documentation and catch errors. Always type function parameters and return types for exported functions.

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
  // TypeScript knows which fields exist based on status
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
      return Math.PI * shape.radius ** 2 // ✅ radius available
    case 'rectangle':
      return shape.width * shape.height // ✅ width, height available
    case 'square':
      return shape.size ** 2 // ✅ size available
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
  // ❌ Hard to know which state we're in
}

// ❌ Using strings without type safety
function calculateArea(shape: any) {
  if (shape.type === 'cirlce') { // ❌ Typo not caught
    return Math.PI * shape.r ** 2 // ❌ Wrong property name
  }
}
```

**Why**: Discriminated unions provide exhaustive type checking and make illegal states unrepresentable. TypeScript can narrow types based on the discriminator field.

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

// ✅ Multiple type parameters with constraints
function merge<T extends object, U extends object>(obj1: T, obj2: U): T & U {
  return { ...obj1, ...obj2 }
}

const result = merge({ name: 'John' }, { age: 30 }) // { name: string, age: number }

// ✅ Conditional types for advanced patterns
type UnwrapPromise<T> = T extends Promise<infer U> ? U : T

type A = UnwrapPromise<Promise<string>> // string
type B = UnwrapPromise<number> // number

// ✅ keyof constraint
function getProperty<T, K extends keyof T>(obj: T, key: K): T[K] {
  return obj[key] // ✅ Type-safe property access
}

const user = { name: 'John', age: 30 }
const name = getProperty(user, 'name') // string
const age = getProperty(user, 'age') // number
// getProperty(user, 'invalid') // ❌ Error: invalid not in keyof user
```

**Bad**:
```typescript
// ❌ Generic without constraints
function findById<T>(items: T[], id: string): T | undefined {
  return items.find(item => item.id === id) // ❌ Error: Property 'id' does not exist on type 'T'
}

// ❌ Using any loses type safety
function merge(obj1: any, obj2: any): any {
  return { ...obj1, ...obj2 } // ❌ Lost all type information
}

// ❌ String property access
function getProperty(obj: any, key: string): any {
  return obj[key] // ❌ No type safety
}
```

**Why**: Generic constraints ensure type safety while maintaining flexibility. They catch errors at compile time and provide better IntelliSense.

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
// { id: string, name: string }

// ✅ Omit for excluding sensitive data
type PublicUser = Omit<User, 'password'>
// { id, name, email, role, createdAt }

// ✅ Partial for optional updates
type UserUpdate = Partial<User>
// All properties optional

function updateUser(id: string, updates: Partial<User>) {
  // ✅ Can update any subset of user fields
}

// ✅ Required for making all properties required
type RequiredUser = Required<Partial<User>>
// All properties required

// ✅ Readonly for immutable data
type ImmutableUser = Readonly<User>
const user: ImmutableUser = { /* ... */ }
// user.name = 'Jane' // ❌ Error: readonly property

// ✅ Record for maps/dictionaries
type UserMap = Record<string, User>
const users: UserMap = {
  'user1': { id: '1', name: 'John', /* ... */ },
  'user2': { id: '2', name: 'Jane', /* ... */ }
}

// ✅ ReturnType to extract function return type
function getUser() {
  return { id: '1', name: 'John', email: 'john@example.com' }
}

type UserType = ReturnType<typeof getUser>
// { id: string, name: string, email: string }
```

**Bad**:
```typescript
// ❌ Manually duplicating types
type UserPreview = {
  id: string // ❌ Duplicated from User
  name: string // ❌ Duplicated from User
}

// ❌ Allowing all properties in updates
function updateUser(id: string, updates: User) {
  // ❌ Forces providing all fields, including password
}

// ❌ No type for dictionaries
const users: any = {} // ❌ Lost type safety
users.user1 = { wrong: 'shape' } // ❌ No error
```

**Why**: Utility types keep types DRY (Don't Repeat Yourself), automatically sync with source types, and provide common type transformations.

---

## Anti-Patterns

### ❌ Anti-Pattern 1: Overusing `any`

**Don't do this**:
```typescript
// ❌ Using any defeats the purpose of TypeScript
function processData(data: any): any {
  return data.map((item: any) => item.value) // No type safety
}

const result: any = await fetch('/api/users').then(r => r.json())
// ❌ Lost all type information

// ❌ any in interfaces
interface ApiResponse {
  data: any // ❌ Could be anything
  error: any // ❌ Could be anything
}
```

**Why it's bad**: Disables TypeScript's type checking, loses IntelliSense, allows runtime errors, makes refactoring dangerous.

**Do this instead**:
```typescript
// ✅ Use specific types or generics
function processData<T extends { value: any }>(data: T[]): any[] {
  return data.map(item => item.value)
}

// ✅ Define API response types
interface User {
  id: string
  name: string
  email: string
}

const result: User[] = await fetch('/api/users').then(r => r.json())

// ✅ Generic interfaces
interface ApiResponse<T> {
  data: T
  error: string | null
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

// ❌ Double assertion
const value = ('hello' as any) as number // ❌ Completely unsafe

// ❌ Non-null assertion without checking
function getUser(id?: string) {
  const userId = id! // ❌ Asserts non-null without checking
  return fetchUser(userId) // ❌ Runtime error if id is undefined
}
```

**Why it's bad**: Type assertions bypass type checking, can cause runtime errors, make code less safe than vanilla JavaScript.

**Do this instead**:
```typescript
// ✅ Type guards for runtime validation
function isUser(data: unknown): data is User {
  return (
    typeof data === 'object' &&
    data !== null &&
    'id' in data &&
    'name' in data &&
    'email' in data
  )
}

function processUser(data: unknown) {
  if (isUser(data)) {
    console.log(data.name.toUpperCase()) // ✅ Type-safe
  }
}

// ✅ Validation libraries (Zod)
import { z } from 'zod'

const UserSchema = z.object({
  id: z.string(),
  name: z.string(),
  email: z.string().email()
})

type User = z.infer<typeof UserSchema>

function processUser(data: unknown) {
  const user = UserSchema.parse(data) // ✅ Runtime validation
  console.log(user.name.toUpperCase()) // ✅ Type-safe
}

// ✅ Check before using
function getUser(id?: string) {
  if (!id) {
    throw new Error('ID required')
  }
  return fetchUser(id) // ✅ Type narrowed to string
}
```

---

### ❌ Anti-Pattern 3: Ignoring Strict Mode

**Don't do this**:
```typescript
// tsconfig.json
{
  "compilerOptions": {
    "strict": false, // ❌ Disables all strict checks
    "strictNullChecks": false // ❌ Allows null/undefined anywhere
  }
}

// This allows dangerous code
function getLength(str: string): number {
  return str.length // ❌ Runtime error if str is null
}

getLength(null) // ❌ No TypeScript error, runtime crash
```

**Why it's bad**: Disables TypeScript's most valuable features, allows null/undefined bugs, makes migration harder, reduces code quality.

**Do this instead**:
```typescript
// tsconfig.json
{
  "compilerOptions": {
    "strict": true, // ✅ Enable all strict checks
    "noUncheckedIndexedAccess": true, // ✅ Extra safety for arrays
    "noImplicitOverride": true // ✅ Explicit override keyword
  }
}

// Write safer code
function getLength(str: string | null): number {
  if (!str) return 0 // ✅ Handle null explicitly
  return str.length
}

// ✅ Or use optional chaining
function getLength(str?: string): number {
  return str?.length ?? 0
}
```

---

### ❌ Anti-Pattern 4: Excessive Type Complexity

**Don't do this**:
```typescript
// ❌ Overly complex mapped types
type DeepPartial<T> = T extends object
  ? { [P in keyof T]?: DeepPartial<T[P]> }
  : T

type DeepReadonly<T> = T extends object
  ? { readonly [P in keyof T]: DeepReadonly<T[P]> }
  : T

type DeepRequired<T> = T extends object
  ? { [P in keyof T]-?: DeepRequired<T[P]> }
  : T

// ❌ Using complex types that are hard to understand
type ComplexType<T> = DeepPartial<DeepReadonly<DeepRequired<T>>>

// ❌ Overly nested conditional types
type Unwrap<T> = T extends Promise<infer U>
  ? U extends Promise<infer V>
    ? V extends Promise<infer W>
      ? W
      : V
    : U
  : T
```

**Why it's bad**: Hard to understand, difficult to debug, slow compilation, confusing error messages, maintenance nightmare.

**Do this instead**:
```typescript
// ✅ Keep types simple and focused
type UserUpdate = Partial<Pick<User, 'name' | 'email'>>

// ✅ Break complex types into smaller pieces
type BaseUser = Pick<User, 'id' | 'name' | 'email'>
type UserWithRole = BaseUser & { role: string }
type AdminUser = UserWithRole & { permissions: string[] }

// ✅ Use utility types appropriately
type PartialUser = Partial<User> // Simple and clear

// ✅ Add type aliases for clarity
type UserId = string
type UserEmail = string
type UserRole = 'admin' | 'user' | 'guest'

interface User {
  id: UserId
  email: UserEmail
  role: UserRole
}
```

---

## What This Skill Covers

- **Type annotations** and type inference
- **Interfaces** and type aliases
- **Generics** for reusable code
- **Utility types** for type transformations
- **Configuration** for different environments

For advanced patterns, configuration details, and Node.js integration, see [references/](./references/).

---

## Basic Types

### Primitives

```typescript
// Type inference (TypeScript infers the type)
let name = 'John' // string
let age = 30 // number
let isActive = true // boolean

// Explicit type annotations
let username: string = 'John'
let userAge: number = 30
let userActive: boolean = true

// Arrays
let numbers: number[] = [1, 2, 3]
let names: Array<string> = ['John', 'Jane']

// Tuples
let user: [string, number] = ['John', 30]

// Any (avoid when possible)
let anything: any = 'hello'
anything = 42 // OK but loses type safety

// Unknown (safer than any)
let value: unknown = 'hello'
if (typeof value === 'string') {
  console.log(value.toUpperCase()) // Type guard required
}

// Void (no return value)
function logMessage(message: string): void {
  console.log(message)
}

// Never (function never returns)
function throwError(message: string): never {
  throw new Error(message)
}
```

---

## Interfaces and Types

### Interfaces

```typescript
interface User {
  id: string
  name: string
  email: string
  age?: number // Optional property
  readonly createdAt: Date // Read-only
}

const user: User = {
  id: '123',
  name: 'John',
  email: 'john@example.com',
  createdAt: new Date()
}

// user.createdAt = new Date() // Error: readonly property
```

### Type Aliases

```typescript
type ID = string | number

type Status = 'idle' | 'loading' | 'success' | 'error'

type Point = {
  x: number
  y: number
}

type ApiResponse<T> = {
  data: T
  error: string | null
  status: Status
}
```

### Extending Interfaces

```typescript
interface Person {
  name: string
  age: number
}

interface Employee extends Person {
  employeeId: string
  department: string
}

const employee: Employee = {
  name: 'John',
  age: 30,
  employeeId: 'E123',
  department: 'Engineering'
}
```

---

## Functions

### Function Types

```typescript
// Function declaration
function add(a: number, b: number): number {
  return a + b
}

// Arrow function
const multiply = (a: number, b: number): number => a * b

// Optional parameters
function greet(name: string, greeting?: string): string {
  return `${greeting || 'Hello'}, ${name}`
}

// Default parameters
function createUser(name: string, role: string = 'user'): User {
  return { id: '123', name, role }
}

// Rest parameters
function sum(...numbers: number[]): number {
  return numbers.reduce((total, n) => total + n, 0)
}
```

### Function Type Signatures

```typescript
// Function type
type MathOperation = (a: number, b: number) => number

const divide: MathOperation = (a, b) => a / b

// Callback types
function fetchData(callback: (data: string) => void): void {
  callback('data')
}

// Promise types
async function getUser(id: string): Promise<User> {
  const response = await fetch(`/api/users/${id}`)
  return response.json()
}
```

---

## Generics

### Generic Functions

```typescript
// Generic function
function identity<T>(value: T): T {
  return value
}

const num = identity<number>(42) // number
const str = identity<string>('hello') // string
const inferred = identity(true) // boolean (inferred)

// Generic with constraints
function getProperty<T, K extends keyof T>(obj: T, key: K): T[K] {
  return obj[key]
}

const user = { name: 'John', age: 30 }
const name = getProperty(user, 'name') // string
const age = getProperty(user, 'age') // number
```

### Generic Interfaces

```typescript
interface Response<T> {
  data: T
  status: number
  error: string | null
}

const userResponse: Response<User> = {
  data: { id: '123', name: 'John' },
  status: 200,
  error: null
}

const usersResponse: Response<User[]> = {
  data: [{ id: '123', name: 'John' }],
  status: 200,
  error: null
}
```

### Generic Classes

```typescript
class DataStore<T> {
  private data: T[] = []

  add(item: T): void {
    this.data.push(item)
  }

  get(index: number): T | undefined {
    return this.data[index]
  }

  getAll(): T[] {
    return this.data
  }
}

const userStore = new DataStore<User>()
userStore.add({ id: '123', name: 'John' })
```

---

## Utility Types

### Common Utility Types

```typescript
interface User {
  id: string
  name: string
  email: string
  password: string
}

// Partial - All properties optional
type PartialUser = Partial<User>
const update: PartialUser = { name: 'John' }

// Required - All properties required
type RequiredUser = Required<PartialUser>

// Readonly - All properties read-only
type ReadonlyUser = Readonly<User>

// Pick - Select specific properties
type UserPreview = Pick<User, 'id' | 'name'>
const preview: UserPreview = { id: '123', name: 'John' }

// Omit - Exclude specific properties
type PublicUser = Omit<User, 'password'>
const publicUser: PublicUser = { id: '123', name: 'John', email: 'john@example.com' }

// Record - Create object type with specific keys
type UserRoles = Record<string, string[]>
const roles: UserRoles = {
  admin: ['read', 'write', 'delete'],
  user: ['read']
}

// NonNullable - Remove null and undefined
type MaybeString = string | null | undefined
type DefiniteString = NonNullable<MaybeString> // string

// ReturnType - Extract return type of function
function getUser() {
  return { id: '123', name: 'John' }
}
type UserType = ReturnType<typeof getUser> // { id: string; name: string }

// Parameters - Extract parameters as tuple
type GetUserParams = Parameters<typeof getUser> // []
```

---

## Type Guards and Narrowing

### Type Guards

```typescript
// typeof guard
function printValue(value: string | number) {
  if (typeof value === 'string') {
    console.log(value.toUpperCase()) // string
  } else {
    console.log(value.toFixed(2)) // number
  }
}

// instanceof guard
class Dog {
  bark() { console.log('Woof!') }
}

class Cat {
  meow() { console.log('Meow!') }
}

function makeSound(animal: Dog | Cat) {
  if (animal instanceof Dog) {
    animal.bark()
  } else {
    animal.meow()
  }
}

// Custom type guard
interface Fish {
  swim: () => void
}

interface Bird {
  fly: () => void
}

function isFish(animal: Fish | Bird): animal is Fish {
  return (animal as Fish).swim !== undefined
}

function move(animal: Fish | Bird) {
  if (isFish(animal)) {
    animal.swim()
  } else {
    animal.fly()
  }
}
```

### Discriminated Unions

```typescript
interface SuccessResponse {
  type: 'success'
  data: any
}

interface ErrorResponse {
  type: 'error'
  error: string
}

type ApiResponse = SuccessResponse | ErrorResponse

function handleResponse(response: ApiResponse) {
  if (response.type === 'success') {
    console.log(response.data) // TypeScript knows this is SuccessResponse
  } else {
    console.log(response.error) // TypeScript knows this is ErrorResponse
  }
}
```

---

## Classes

### Class Basics

```typescript
class User {
  // Properties
  private id: string
  public name: string
  protected email: string
  readonly createdAt: Date

  // Constructor
  constructor(id: string, name: string, email: string) {
    this.id = id
    this.name = name
    this.email = email
    this.createdAt = new Date()
  }

  // Method
  public getInfo(): string {
    return `${this.name} (${this.email})`
  }

  // Private method
  private validateEmail(): boolean {
    return this.email.includes('@')
  }
}

// Shorthand constructor
class Product {
  constructor(
    public id: string,
    public name: string,
    public price: number
  ) {}
}

const product = new Product('1', 'Laptop', 999)
```

### Abstract Classes

```typescript
abstract class Animal {
  constructor(public name: string) {}

  abstract makeSound(): void

  move(): void {
    console.log(`${this.name} is moving`)
  }
}

class Dog extends Animal {
  makeSound(): void {
    console.log('Woof!')
  }
}

const dog = new Dog('Buddy')
dog.makeSound() // Woof!
dog.move() // Buddy is moving
```

---

## Enums

### Numeric Enums

```typescript
enum Status {
  Pending,
  Approved,
  Rejected
}

const status: Status = Status.Approved // 1
```

### String Enums

```typescript
enum LogLevel {
  Error = 'ERROR',
  Warning = 'WARNING',
  Info = 'INFO',
  Debug = 'DEBUG'
}

function log(level: LogLevel, message: string) {
  console.log(`[${level}] ${message}`)
}

log(LogLevel.Error, 'Something went wrong')
```

### Const Enums (Better Performance)

```typescript
const enum Direction {
  Up = 'UP',
  Down = 'DOWN',
  Left = 'LEFT',
  Right = 'RIGHT'
}

const move = Direction.Up // Inlined at compile time
```

---

## TypeScript with Node.js

### Express Example

```typescript
import express, { Request, Response, NextFunction } from 'express'

const app = express()

interface User {
  id: string
  name: string
  email: string
}

// Typed route handler
app.get('/users/:id', (req: Request, res: Response) => {
  const userId: string = req.params.id
  const user: User = { id: userId, name: 'John', email: 'john@example.com' }
  res.json(user)
})

// Typed middleware
const logger = (req: Request, res: Response, next: NextFunction) => {
  console.log(`${req.method} ${req.path}`)
  next()
}

app.use(logger)
```

### Prisma Example

```typescript
import { PrismaClient, User, Post } from '@prisma/client'

const prisma = new PrismaClient()

// Type-safe database queries
async function getUser(id: string): Promise<User | null> {
  return prisma.user.findUnique({
    where: { id }
  })
}

async function createPost(userId: string, title: string): Promise<Post> {
  return prisma.post.create({
    data: {
      title,
      userId
    }
  })
}

// Type-safe relations
async function getUserWithPosts(id: string) {
  return prisma.user.findUnique({
    where: { id },
    include: { posts: true }
  })
}
```

---

## TypeScript with React

### Component Props

```typescript
interface ButtonProps {
  label: string
  onClick: () => void
  variant?: 'primary' | 'secondary'
  disabled?: boolean
}

export function Button({ label, onClick, variant = 'primary', disabled = false }: ButtonProps) {
  return (
    <button onClick={onClick} disabled={disabled} className={variant}>
      {label}
    </button>
  )
}
```

### useState with Types

```typescript
import { useState } from 'react'

interface User {
  id: string
  name: string
}

function UserComponent() {
  const [user, setUser] = useState<User | null>(null)
  const [users, setUsers] = useState<User[]>([])

  return <div>{user?.name}</div>
}
```

---

## Quick Reference

```typescript
// Type annotations
let name: string = 'John'
let age: number = 30
let active: boolean = true
let numbers: number[] = [1, 2, 3]

// Interfaces
interface User {
  id: string
  name: string
  email?: string
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

// Type guards
typeof value === 'string'
value instanceof Class
```

---

## Learn More

- **Configuration**: [references/configuration.md](./references/configuration.md) - tsconfig.json, compiler options, paths
- **Advanced Types**: [references/advanced-types.md](./references/advanced-types.md) - Mapped types, conditional types, template literals
- **Best Practices**: [references/best-practices.md](./references/best-practices.md) - Code organization, naming conventions, type safety
- **Node.js Patterns**: [references/nodejs.md](./references/nodejs.md) - Express, Prisma, tRPC, error handling

---

## External References

- [TypeScript Documentation](https://www.typescriptlang.org/)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/)

---

_Maintained by dsmj-ai-toolkit_
