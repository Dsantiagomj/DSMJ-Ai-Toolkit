# OWASP Top 10 - Detailed Security Guide

Complete reference for OWASP Top 10 (2021) vulnerabilities and prevention.

---

## 1. Broken Access Control

**Problem**: Users can access resources they shouldn't

```tsx
// ❌ No authorization check
export async function GET(req: Request) {
  const userId = req.headers.get('user-id')
  const data = await db.user.findUnique({ where: { id: userId } })
  return Response.json(data) // Returns ANY user's data!
}

// ✅ Proper authorization
export async function GET(req: Request) {
  const session = await getSession(req)
  if (!session) {
    return new Response('Unauthorized', { status: 401 })
  }

  const data = await db.user.findUnique({
    where: { id: session.userId }
  })
  return Response.json(data)
}

// ✅ Role-based access control
export async function DELETE(req: Request, { params }: { params: { id: string } }) {
  const session = await getSession(req)

  if (!session) {
    return new Response('Unauthorized', { status: 401 })
  }

  if (session.role !== 'admin') {
    return new Response('Forbidden', { status: 403 })
  }

  await db.user.delete({ where: { id: params.id } })
  return new Response('Deleted', { status: 200 })
}
```

**Prevention**:
- ✅ Verify authentication on every protected route
- ✅ Check authorization (role/ownership) before operations
- ✅ Use middleware for consistent auth checks
- ✅ Default deny (require explicit access grants)

---

## 2. Cryptographic Failures

**Problem**: Sensitive data exposed due to weak/missing encryption

```ts
// ❌ Storing passwords in plain text
await db.user.create({
  data: {
    email,
    password: password, // NEVER DO THIS
  }
})

// ✅ Hash passwords with bcrypt
import bcrypt from 'bcryptjs'

const hashedPassword = await bcrypt.hash(password, 12)
await db.user.create({
  data: {
    email,
    password: hashedPassword,
  }
})

// ✅ Encrypt sensitive data at rest
import crypto from 'crypto'

const algorithm = 'aes-256-gcm'
const key = Buffer.from(process.env.ENCRYPTION_KEY!, 'hex')

function encrypt(text: string) {
  const iv = crypto.randomBytes(16)
  const cipher = crypto.createCipheriv(algorithm, key, iv)

  let encrypted = cipher.update(text, 'utf8', 'hex')
  encrypted += cipher.final('hex')

  const authTag = cipher.getAuthTag()
  return `${iv.toString('hex')}:${authTag.toString('hex')}:${encrypted}`
}
```

**Prevention**:
- ✅ Use bcrypt/argon2 for password hashing
- ✅ Store secrets in environment variables
- ✅ Use HTTPS for all data in transit
- ✅ Encrypt sensitive data at rest

---

## 3. Injection

### SQL Injection

```ts
// ❌ VULNERABLE: String concatenation
const userId = req.query.id
const query = `SELECT * FROM users WHERE id = ${userId}`
await db.execute(query) // SQL Injection risk!

// ✅ Use parameterized queries
await db.user.findUnique({
  where: { id: userId } // ORM handles escaping
})
```

### Command Injection

```ts
// ❌ VULNERABLE: exec with user input
import { exec } from 'child_process'

const filename = req.query.file
exec(`cat ${filename}`, (error, stdout) => {
  // User sends: ?file=test.txt; rm -rf /
})

// ✅ Validate and sanitize input
const filename = req.query.file as string
const allowedPattern = /^[a-zA-Z0-9_-]+\.txt$/

if (!allowedPattern.test(filename)) {
  return new Response('Invalid filename', { status: 400 })
}
```

**Prevention**:
- ✅ Use ORMs with parameterized queries
- ✅ NEVER concatenate user input into SQL
- ✅ Validate and sanitize ALL user input
- ✅ Avoid `exec`, `eval`, and similar dangerous functions

---

## 4. Insecure Design

**Problem**: Missing or ineffective security controls by design

```ts
// ❌ Insecure: Password reset without verification
async function resetPassword(email: string, newPassword: string) {
  const user = await db.user.findUnique({ where: { email } })
  await db.user.update({
    where: { id: user.id },
    data: { password: await hash(newPassword) }
  })
}

// ✅ Secure: Token-based reset flow
async function requestPasswordReset(email: string) {
  const user = await db.user.findUnique({ where: { email } })
  if (!user) return { message: 'If email exists, reset link sent' }

  const token = crypto.randomBytes(32).toString('hex')
  const expires = new Date(Date.now() + 3600000)

  await db.passwordReset.create({
    data: { userId: user.id, token, expires }
  })

  await sendEmail(email, `Reset link: /reset?token=${token}`)
  return { message: 'If email exists, reset link sent' }
}
```

**Prevention**:
- ✅ Threat model your application
- ✅ Implement defense in depth
- ✅ Use security patterns (rate limiting, token expiry)
- ✅ Fail securely

---

## 5. Security Misconfiguration

```ts
// ❌ CORS misconfiguration
app.use(cors({
  origin: '*',
  credentials: true
}))

// ✅ Restrictive CORS
app.use(cors({
  origin: ['https://yourapp.com'],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE']
}))

// ✅ Security headers
import helmet from 'helmet'
app.use(helmet())
```

**Prevention**:
- ✅ Use security headers (CSP, HSTS)
- ✅ Configure CORS restrictively
- ✅ Keep dependencies updated
- ✅ Remove default credentials

---

## 6. Vulnerable Components

```bash
# ✅ Check for vulnerabilities
npm audit
npm audit fix

# ✅ Keep dependencies updated
npm update
```

**Prevention**:
- ✅ Regularly update dependencies
- ✅ Use `npm audit`
- ✅ Enable automated updates (Dependabot)

---

## 7. Authentication Failures

```ts
// ✅ Strong password requirements
const passwordSchema = z.string()
  .min(12)
  .regex(/[A-Z]/)
  .regex(/[a-z]/)
  .regex(/[0-9]/)
  .regex(/[^A-Za-z0-9]/)

// ✅ Rate limiting
import rateLimit from 'express-rate-limit'

const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5,
  message: 'Too many login attempts'
})

app.post('/login', loginLimiter, async (req, res) => {
  // Login logic
})
```

**Prevention**:
- ✅ Implement rate limiting
- ✅ Require strong passwords
- ✅ Use MFA for sensitive operations
- ✅ Hash passwords with bcrypt (rounds ≥ 12)

---

## 8. Software Integrity Failures

```ts
// ✅ Validate data structure
import { z } from 'zod'

const dataSchema = z.object({
  id: z.string().uuid(),
  name: z.string().max(100)
})

app.post('/api/data', (req, res) => {
  const data = dataSchema.parse(req.body)
  // Safe to use data
})

// ✅ Use Subresource Integrity
<script
  src="https://cdn.example.com/library.js"
  integrity="sha384-..."
  crossorigin="anonymous"
></script>
```

**Prevention**:
- ✅ Use SRI for external scripts
- ✅ Verify signatures
- ✅ Never use `eval()`

---

## 9. Logging Failures

```ts
// ✅ Comprehensive logging
import winston from 'winston'

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.json(),
  transports: [
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
    new winston.transports.File({ filename: 'combined.log' })
  ]
})

app.post('/login', async (req, res) => {
  try {
    const user = await authenticateUser(req.body.email, req.body.password)
    logger.info('Login successful', { userId: user.id, ip: req.ip })
  } catch (error) {
    logger.warn('Failed login', { email: req.body.email, ip: req.ip })
  }
})
```

**Prevention**:
- ✅ Log all authentication events
- ✅ Log access to sensitive data
- ✅ Monitor for suspicious patterns
- ✅ Set up alerts

---

## 10. Server-Side Request Forgery (SSRF)

```ts
// ❌ VULNERABLE: Fetching user-provided URLs
app.get('/proxy', async (req, res) => {
  const url = req.query.url as string
  const response = await fetch(url)
  res.send(await response.text())
})

// ✅ Whitelist allowed domains
const ALLOWED_DOMAINS = ['api.example.com']

app.get('/proxy', async (req, res) => {
  const url = new URL(req.query.url as string)

  if (!ALLOWED_DOMAINS.includes(url.hostname)) {
    return res.status(400).json({ error: 'Domain not allowed' })
  }

  // Block private IPs
  const ipPattern = /^(10\.|172\.(1[6-9]|2[0-9]|3[01])\.|192\.168\.|127\.)/
  if (ipPattern.test(url.hostname)) {
    return res.status(400).json({ error: 'Private IP not allowed' })
  }

  const response = await fetch(url.toString())
  res.send(await response.text())
})
```

**Prevention**:
- ✅ Whitelist allowed URLs/domains
- ✅ Block requests to private IPs
- ✅ Disable URL redirects

---

_Maintained by dsmj-ai-toolkit_
