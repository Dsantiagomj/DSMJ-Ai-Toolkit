# Node.js Patterns - TypeScript

## Express.js

### Basic Setup

```typescript
import express, { Request, Response, NextFunction } from 'express'

const app = express()

app.use(express.json())

app.get('/health', (req: Request, res: Response) => {
  res.json({ status: 'ok' })
})

app.listen(3000, () => {
  console.log('Server running on port 3000')
})
```

### Typed Routes

```typescript
interface User {
  id: string
  name: string
  email: string
}

// Route with typed params
app.get('/users/:id', (req: Request<{ id: string }>, res: Response<User>) => {
  const userId = req.params.id
  const user: User = { id: userId, name: 'John', email: 'john@example.com' }
  res.json(user)
})

// Route with typed body
interface CreateUserBody {
  name: string
  email: string
}

app.post('/users', (req: Request<{}, {}, CreateUserBody>, res: Response<User>) => {
  const { name, email } = req.body
  const user: User = { id: '123', name, email }
  res.status(201).json(user)
})

// Route with typed query
interface SearchQuery {
  q?: string
  limit?: string
}

app.get('/search', (req: Request<{}, {}, {}, SearchQuery>, res: Response) => {
  const query = req.query.q || ''
  const limit = parseInt(req.query.limit || '10')
  res.json({ query, limit })
})
```

### Custom Request Types

```typescript
// Extend Express Request type
declare global {
  namespace Express {
    interface Request {
      user?: User
      sessionId?: string
    }
  }
}

// Usage in middleware
const authMiddleware = (req: Request, res: Response, next: NextFunction) => {
  const token = req.headers.authorization

  if (!token) {
    return res.status(401).json({ error: 'Unauthorized' })
  }

  // Verify token and attach user
  req.user = { id: '123', name: 'John', email: 'john@example.com' }
  next()
}

app.use(authMiddleware)

app.get('/profile', (req: Request, res: Response) => {
  if (!req.user) {
    return res.status(401).json({ error: 'Unauthorized' })
  }

  res.json(req.user)
})
```

### Error Handling

```typescript
// Custom error class
class HttpError extends Error {
  constructor(
    public statusCode: number,
    message: string
  ) {
    super(message)
    this.name = 'HttpError'
  }
}

// Async route handler wrapper
type AsyncHandler = (
  req: Request,
  res: Response,
  next: NextFunction
) => Promise<any>

const asyncHandler = (fn: AsyncHandler) => {
  return (req: Request, res: Response, next: NextFunction) => {
    Promise.resolve(fn(req, res, next)).catch(next)
  }
}

// Usage
app.get('/users/:id', asyncHandler(async (req, res) => {
  const user = await db.user.findUnique({ where: { id: req.params.id } })

  if (!user) {
    throw new HttpError(404, 'User not found')
  }

  res.json(user)
}))

// Error middleware
app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
  if (err instanceof HttpError) {
    return res.status(err.statusCode).json({ error: err.message })
  }

  console.error(err)
  res.status(500).json({ error: 'Internal server error' })
})
```

---

## Prisma

### Type-Safe Queries

```typescript
import { PrismaClient, User, Post, Prisma } from '@prisma/client'

const prisma = new PrismaClient()

// Basic queries (fully typed)
async function getUser(id: string): Promise<User | null> {
  return prisma.user.findUnique({
    where: { id }
  })
}

async function getUsers(): Promise<User[]> {
  return prisma.user.findMany()
}

// Query with relations
type UserWithPosts = Prisma.UserGetPayload<{
  include: { posts: true }
}>

async function getUserWithPosts(id: string): Promise<UserWithPosts | null> {
  return prisma.user.findUnique({
    where: { id },
    include: { posts: true }
  })
}

// Query with select
type UserPreview = Prisma.UserGetPayload<{
  select: { id: true; name: true; email: true }
}>

async function getUserPreview(id: string): Promise<UserPreview | null> {
  return prisma.user.findUnique({
    where: { id },
    select: { id: true, name: true, email: true }
  })
}
```

### Create and Update

```typescript
// Create with type inference
async function createUser(data: Prisma.UserCreateInput): Promise<User> {
  return prisma.user.create({ data })
}

// Update with type safety
async function updateUser(
  id: string,
  data: Prisma.UserUpdateInput
): Promise<User> {
  return prisma.user.update({
    where: { id },
    data
  })
}

// Upsert
async function upsertUser(
  id: string,
  create: Prisma.UserCreateInput,
  update: Prisma.UserUpdateInput
): Promise<User> {
  return prisma.user.upsert({
    where: { id },
    create,
    update
  })
}
```

### Complex Queries

```typescript
// Nested writes
async function createPostWithAuthor(
  title: string,
  content: string,
  authorEmail: string
): Promise<Post> {
  return prisma.post.create({
    data: {
      title,
      content,
      author: {
        connectOrCreate: {
          where: { email: authorEmail },
          create: {
            email: authorEmail,
            name: 'New User'
          }
        }
      }
    }
  })
}

// Aggregations
async function getUserStats(userId: string) {
  const [user, postCount, avgViews] = await Promise.all([
    prisma.user.findUnique({ where: { id: userId } }),
    prisma.post.count({ where: { authorId: userId } }),
    prisma.post.aggregate({
      where: { authorId: userId },
      _avg: { views: true }
    })
  ])

  return {
    user,
    stats: {
      postCount,
      avgViews: avgViews._avg.views || 0
    }
  }
}

// Transactions
async function transferPosts(fromUserId: string, toUserId: string) {
  return prisma.$transaction(async (tx) => {
    // Update all posts
    await tx.post.updateMany({
      where: { authorId: fromUserId },
      data: { authorId: toUserId }
    })

    // Update user stats
    await tx.user.update({
      where: { id: toUserId },
      data: { postCount: { increment: 1 } }
    })
  })
}
```

### Type Utilities

```typescript
// Extract model type
type User = Prisma.UserGetPayload<{}>

// Extract create input
type CreateUserInput = Prisma.UserCreateInput

// Extract update input
type UpdateUserInput = Prisma.UserUpdateInput

// Extract where input
type UserWhereInput = Prisma.UserWhereInput

// Custom validator type
type ValidUserInput = Pick<Prisma.UserCreateInput, 'name' | 'email'>

function validateUser(data: ValidUserInput): boolean {
  return data.name.length > 0 && data.email.includes('@')
}
```

---

## tRPC

### Router Definition

```typescript
import { initTRPC } from '@trpc/server'
import { z } from 'zod'

const t = initTRPC.create()

const appRouter = t.router({
  // Query
  getUser: t.procedure
    .input(z.object({ id: z.string() }))
    .query(async ({ input }) => {
      return prisma.user.findUnique({
        where: { id: input.id }
      })
    }),

  // Mutation
  createUser: t.procedure
    .input(z.object({
      name: z.string(),
      email: z.string().email()
    }))
    .mutation(async ({ input }) => {
      return prisma.user.create({
        data: input
      })
    }),

  // List
  listUsers: t.procedure
    .input(z.object({
      limit: z.number().min(1).max(100).default(10),
      cursor: z.string().optional()
    }))
    .query(async ({ input }) => {
      const users = await prisma.user.findMany({
        take: input.limit + 1,
        cursor: input.cursor ? { id: input.cursor } : undefined
      })

      let nextCursor: string | undefined = undefined
      if (users.length > input.limit) {
        const nextItem = users.pop()
        nextCursor = nextItem!.id
      }

      return { users, nextCursor }
    })
})

export type AppRouter = typeof appRouter
```

### Context and Middleware

```typescript
import { inferAsyncReturnType } from '@trpc/server'
import { CreateNextContextOptions } from '@trpc/server/adapters/next'

// Create context
export async function createContext(opts: CreateNextContextOptions) {
  const session = await getSession(opts.req, opts.res)

  return {
    session,
    prisma
  }
}

type Context = inferAsyncReturnType<typeof createContext>

// Initialize tRPC with context
const t = initTRPC.context<Context>().create()

// Auth middleware
const isAuthed = t.middleware(({ ctx, next }) => {
  if (!ctx.session?.user) {
    throw new Error('Unauthorized')
  }

  return next({
    ctx: {
      session: ctx.session
    }
  })
})

// Protected procedure
const protectedProcedure = t.procedure.use(isAuthed)

// Router with protected routes
const appRouter = t.router({
  // Public
  getUser: t.procedure
    .input(z.object({ id: z.string() }))
    .query(({ input }) => {
      return prisma.user.findUnique({ where: { id: input.id } })
    }),

  // Protected
  updateProfile: protectedProcedure
    .input(z.object({
      name: z.string().optional(),
      email: z.string().email().optional()
    }))
    .mutation(async ({ ctx, input }) => {
      return prisma.user.update({
        where: { id: ctx.session.user.id },
        data: input
      })
    })
})
```

---

## Zod Validation

### Schema Definition

```typescript
import { z } from 'zod'

// Basic schema
const userSchema = z.object({
  name: z.string().min(2).max(50),
  email: z.string().email(),
  age: z.number().min(18).max(120),
  role: z.enum(['admin', 'user', 'guest'])
})

// Infer type from schema
type User = z.infer<typeof userSchema>

// Validate
const result = userSchema.safeParse({
  name: 'John',
  email: 'john@example.com',
  age: 30,
  role: 'user'
})

if (result.success) {
  console.log(result.data) // Type-safe User
} else {
  console.error(result.error.issues)
}
```

### Complex Schemas

```typescript
// Nested objects
const addressSchema = z.object({
  street: z.string(),
  city: z.string(),
  country: z.string(),
  zipCode: z.string().regex(/^\d{5}$/)
})

const userWithAddressSchema = z.object({
  name: z.string(),
  email: z.string().email(),
  address: addressSchema
})

// Arrays
const usersSchema = z.array(userSchema)

// Unions
const idSchema = z.union([z.string().uuid(), z.number().int()])

// Discriminated unions
const eventSchema = z.discriminatedUnion('type', [
  z.object({ type: z.literal('click'), x: z.number(), y: z.number() }),
  z.object({ type: z.literal('keypress'), key: z.string() })
])

// Optional and nullable
const optionalSchema = z.object({
  name: z.string(),
  email: z.string().optional(),
  phone: z.string().nullable()
})

// Transformations
const dateSchema = z.string().transform((str) => new Date(str))

// Refinements
const passwordSchema = z.string()
  .min(8)
  .refine((val) => /[A-Z]/.test(val), 'Must contain uppercase')
  .refine((val) => /[0-9]/.test(val), 'Must contain number')
```

---

## Environment Variables

### Type-Safe Env

```typescript
// env.ts
import { z } from 'zod'

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']),
  DATABASE_URL: z.string().url(),
  NEXTAUTH_SECRET: z.string().min(32),
  NEXTAUTH_URL: z.string().url(),
  PORT: z.string().transform((val) => parseInt(val, 10)).default('3000')
})

export const env = envSchema.parse(process.env)

// Usage (type-safe)
console.log(env.DATABASE_URL) // string
console.log(env.PORT) // number
```

---

## File Operations

### Type-Safe File Reading

```typescript
import { promises as fs } from 'fs'
import { z } from 'zod'

// JSON schema
const configSchema = z.object({
  apiUrl: z.string().url(),
  timeout: z.number(),
  retries: z.number().default(3)
})

type Config = z.infer<typeof configSchema>

// Type-safe file reader
async function readConfig(path: string): Promise<Config> {
  const content = await fs.readFile(path, 'utf-8')
  const json = JSON.parse(content)
  return configSchema.parse(json)
}

// Type-safe file writer
async function writeConfig(path: string, config: Config): Promise<void> {
  const validated = configSchema.parse(config)
  await fs.writeFile(path, JSON.stringify(validated, null, 2))
}
```

---

## WebSocket

### Typed WebSocket

```typescript
import { WebSocket, WebSocketServer } from 'ws'

// Message types
type ClientMessage =
  | { type: 'subscribe'; channel: string }
  | { type: 'unsubscribe'; channel: string }
  | { type: 'message'; content: string }

type ServerMessage =
  | { type: 'subscribed'; channel: string }
  | { type: 'message'; channel: string; content: string }
  | { type: 'error'; error: string }

// Typed WebSocket wrapper
class TypedWebSocket {
  constructor(private ws: WebSocket) {
    this.ws.on('message', (data) => {
      try {
        const message = JSON.parse(data.toString()) as ClientMessage
        this.handleMessage(message)
      } catch (error) {
        this.send({ type: 'error', error: 'Invalid message' })
      }
    })
  }

  send(message: ServerMessage) {
    this.ws.send(JSON.stringify(message))
  }

  private handleMessage(message: ClientMessage) {
    switch (message.type) {
      case 'subscribe':
        // Handle subscribe
        this.send({ type: 'subscribed', channel: message.channel })
        break
      case 'message':
        // Handle message
        break
    }
  }
}
```

---

## Testing

### Vitest with TypeScript

```typescript
import { describe, it, expect, beforeEach, vi } from 'vitest'

interface User {
  id: string
  name: string
  email: string
}

interface UserService {
  getUser(id: string): Promise<User>
  updateUser(id: string, data: Partial<User>): Promise<User>
}

describe('UserService', () => {
  let userService: UserService

  beforeEach(() => {
    userService = {
      getUser: vi.fn(),
      updateUser: vi.fn()
    }
  })

  it('should get user by id', async () => {
    const mockUser: User = {
      id: '123',
      name: 'John',
      email: 'john@example.com'
    }

    vi.mocked(userService.getUser).mockResolvedValue(mockUser)

    const user = await userService.getUser('123')

    expect(user).toEqual(mockUser)
    expect(userService.getUser).toHaveBeenCalledWith('123')
  })
})
```

---

## Database Migrations

### Prisma Migrations

```typescript
// prisma/seed.ts
import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()

async function main() {
  // Type-safe seeding
  await prisma.user.createMany({
    data: [
      {
        name: 'John',
        email: 'john@example.com',
        role: 'admin'
      },
      {
        name: 'Jane',
        email: 'jane@example.com',
        role: 'user'
      }
    ]
  })
}

main()
  .catch((e) => {
    console.error(e)
    process.exit(1)
  })
  .finally(async () => {
    await prisma.$disconnect()
  })
```

---

## CLI Tools

### Type-Safe CLI

```typescript
import { Command } from 'commander'

const program = new Command()

program
  .name('my-cli')
  .description('CLI tool')
  .version('1.0.0')

program
  .command('create')
  .description('Create a new user')
  .requiredOption('-n, --name <name>', 'User name')
  .requiredOption('-e, --email <email>', 'User email')
  .option('-r, --role <role>', 'User role', 'user')
  .action(async (options: { name: string; email: string; role: string }) => {
    const user = await createUser({
      name: options.name,
      email: options.email,
      role: options.role
    })
    console.log('Created user:', user)
  })

program.parse()
```
