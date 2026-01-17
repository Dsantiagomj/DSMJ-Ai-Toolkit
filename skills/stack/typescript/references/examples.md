# TypeScript Examples

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
