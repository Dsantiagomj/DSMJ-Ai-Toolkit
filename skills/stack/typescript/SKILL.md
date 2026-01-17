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
