# Authentication & Authorization Patterns

Comprehensive guide to secure authentication and authorization.

---

## JWT (JSON Web Tokens)

```ts
import jwt from 'jsonwebtoken'

const JWT_SECRET = process.env.JWT_SECRET!

// Generate token
function generateToken(userId: string, role: string) {
  return jwt.sign(
    { userId, role },
    JWT_SECRET,
    { expiresIn: '7d' }
  )
}

// Verify token
function verifyToken(token: string) {
  try {
    return jwt.verify(token, JWT_SECRET) as { userId: string; role: string }
  } catch (error) {
    throw new Error('Invalid token')
  }
}

// Middleware
function requireAuth(req: Request) {
  const authHeader = req.headers.get('authorization')
  if (!authHeader?.startsWith('Bearer ')) {
    throw new Error('No token provided')
  }

  const token = authHeader.substring(7)
  return verifyToken(token)
}

// Usage
export async function GET(req: Request) {
  const { userId } = requireAuth(req)
  const data = await db.user.findUnique({ where: { id: userId } })
  return Response.json(data)
}
```

---

## Session-Based Auth

```ts
import session from 'express-session'
import RedisStore from 'connect-redis'
import { createClient } from 'redis'

const redisClient = createClient()

app.use(session({
  store: new RedisStore({ client: redisClient }),
  secret: process.env.SESSION_SECRET!,
  resave: false,
  saveUninitialized: false,
  cookie: {
    secure: true,
    httpOnly: true,
    maxAge: 1000 * 60 * 60 * 24 * 7,
    sameSite: 'strict'
  }
}))

// Login
app.post('/login', async (req, res) => {
  const user = await authenticateUser(req.body.email, req.body.password)
  req.session.userId = user.id
  req.session.role = user.role
  res.json({ success: true })
})

// Protected route
app.get('/api/profile', requireSession, async (req, res) => {
  const user = await db.user.findUnique({
    where: { id: req.session.userId }
  })
  res.json(user)
})
```

---

## Multi-Factor Authentication (MFA)

```ts
import speakeasy from 'speakeasy'

// Generate MFA secret
const secret = speakeasy.generateSecret({ name: 'YourApp' })
await db.user.update({
  where: { id: userId },
  data: { mfaSecret: secret.base32 }
})

// Verify MFA token
const verified = speakeasy.totp.verify({
  secret: user.mfaSecret,
  encoding: 'base32',
  token: req.body.mfaToken,
  window: 2
})
```

---

## Input Validation

```ts
import { z } from 'zod'

// Define schema
const userSchema = z.object({
  email: z.string().email().max(255),
  password: z.string().min(12).max(128),
  age: z.number().int().min(18).max(120)
})

// Validate
try {
  const validData = userSchema.parse(req.body)
} catch (error) {
  if (error instanceof z.ZodError) {
    return res.status(400).json({ errors: error.errors })
  }
}
```

---

## Sanitize HTML Input

```ts
import DOMPurify from 'isomorphic-dompurify'

// Sanitize user content
const cleanComment = DOMPurify.sanitize(userComment)
<div dangerouslySetInnerHTML={{ __html: cleanComment }} />
```

---

_Maintained by dsmj-ai-toolkit_
