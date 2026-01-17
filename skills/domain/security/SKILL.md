---
name: security
version: 1.0.0
description: >
  Security best practices covering OWASP Top 10, authentication, authorization, and common vulnerabilities.
  Trigger: When implementing authentication, when handling user input, when storing sensitive data, when building APIs, when conducting security reviews, when implementing authorization.
tags: [security, owasp, authentication, authorization, encryption, vulnerabilities]
author: dsmj-ai-toolkit
metadata:
  auto_invoke: "Implementing authentication, handling user input, storing sensitive data, API security, or security reviews"
  domain_category: security
  progressive_disclosure: true
  version: "1.0"
  last_updated: "2026-01-17"
  category: domain
---

# Security Skill

Comprehensive security practices based on OWASP Top 10 and industry standards.

---

## When to Use This Skill

**Auto-invoke when**:
- Implementing authentication/authorization
- Handling user input or form data
- Storing or processing sensitive data
- Building API endpoints
- Working with databases
- Implementing file uploads
- Code reviews for security issues
- Configuring CORS or CSP

---

## OWASP Top 10 (2021)

### 1. Broken Access Control

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

  // Only return data for authenticated user
  const data = await db.user.findUnique({
    where: { id: session.userId }
  })
  return Response.json(data)
}

// ✅ Role-based access control
export async function DELETE(req: Request, { params }: { params: { id: string } }) {
  const session = await getSession(req)

  // Check authentication
  if (!session) {
    return new Response('Unauthorized', { status: 401 })
  }

  // Check authorization (admin only)
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
- ✅ Implement proper RBAC (Role-Based Access Control)

### 2. Cryptographic Failures

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

// Verify password
const isValid = await bcrypt.compare(inputPassword, user.password)

// ❌ Storing API keys in code or git
const API_KEY = 'sk_live_abc123' // NEVER DO THIS

// ✅ Use environment variables
const API_KEY = process.env.API_KEY
if (!API_KEY) {
  throw new Error('API_KEY not configured')
}

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
- ✅ Use bcrypt/argon2 for password hashing (never MD5/SHA1)
- ✅ Store secrets in environment variables, never in code
- ✅ Use HTTPS for all data in transit
- ✅ Encrypt sensitive data at rest (SSN, credit cards, etc.)
- ✅ Use secure key management (AWS KMS, HashiCorp Vault)

### 3. Injection

**Problem**: Untrusted data sent to interpreter as command/query

#### SQL Injection

```ts
// ❌ VULNERABLE: String concatenation
const userId = req.query.id
const query = `SELECT * FROM users WHERE id = ${userId}`
await db.execute(query) // SQL Injection risk!

// User sends: ?id=1 OR 1=1
// Query becomes: SELECT * FROM users WHERE id = 1 OR 1=1
// Returns ALL users!

// ✅ Use parameterized queries
const userId = req.query.id
await db.user.findUnique({
  where: { id: userId } // ORM handles escaping
})

// ✅ Or with raw SQL, use parameters
await db.$queryRaw`SELECT * FROM users WHERE id = ${userId}`
// Prisma automatically parameterizes

// ✅ For other SQL drivers
await pool.query('SELECT * FROM users WHERE id = $1', [userId])
```

#### Command Injection

```ts
// ❌ VULNERABLE: exec with user input
import { exec } from 'child_process'

const filename = req.query.file
exec(`cat ${filename}`, (error, stdout) => {
  // User sends: ?file=test.txt; rm -rf /
  // Executes: cat test.txt; rm -rf /
})

// ✅ Validate and sanitize input
const filename = req.query.file as string
const allowedPattern = /^[a-zA-Z0-9_-]+\.txt$/

if (!allowedPattern.test(filename)) {
  return new Response('Invalid filename', { status: 400 })
}

// ✅ Use safe alternatives (read file directly)
import fs from 'fs/promises'
const content = await fs.readFile(`./files/${filename}`, 'utf-8')
```

#### NoSQL Injection

```ts
// ❌ VULNERABLE: MongoDB with user input
const email = req.body.email
await db.users.findOne({ email }) // Could receive { $gt: "" }

// ✅ Validate input types
import { z } from 'zod'

const schema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
})

const { email, password } = schema.parse(req.body)
await db.users.findOne({ email })
```

**Prevention**:
- ✅ Use ORMs (Prisma, TypeORM, etc.) with parameterized queries
- ✅ NEVER concatenate user input into SQL
- ✅ Validate and sanitize ALL user input
- ✅ Use prepared statements for raw SQL
- ✅ Avoid `exec`, `eval`, and similar dangerous functions

### 4. Insecure Design

**Problem**: Missing or ineffective security controls by design

```ts
// ❌ Insecure design: Password reset without verification
async function resetPassword(email: string, newPassword: string) {
  const user = await db.user.findUnique({ where: { email } })
  if (!user) return { error: 'User not found' }

  await db.user.update({
    where: { id: user.id },
    data: { password: await hash(newPassword) }
  })
  return { success: true } // Anyone can reset anyone's password!
}

// ✅ Secure design: Token-based reset flow
async function requestPasswordReset(email: string) {
  const user = await db.user.findUnique({ where: { email } })
  if (!user) {
    // Don't reveal if email exists
    return { message: 'If email exists, reset link sent' }
  }

  const token = crypto.randomBytes(32).toString('hex')
  const expires = new Date(Date.now() + 3600000) // 1 hour

  await db.passwordReset.create({
    data: { userId: user.id, token, expires }
  })

  await sendEmail(email, `Reset link: /reset?token=${token}`)
  return { message: 'If email exists, reset link sent' }
}

async function resetPasswordWithToken(token: string, newPassword: string) {
  const reset = await db.passwordReset.findUnique({
    where: { token },
    include: { user: true }
  })

  if (!reset || reset.expires < new Date()) {
    return { error: 'Invalid or expired token' }
  }

  await db.user.update({
    where: { id: reset.userId },
    data: { password: await hash(newPassword) }
  })

  await db.passwordReset.delete({ where: { token } })
  return { success: true }
}
```

**Prevention**:
- ✅ Threat model your application
- ✅ Implement defense in depth (multiple security layers)
- ✅ Use security patterns (rate limiting, token expiry, etc.)
- ✅ Fail securely (errors don't expose information)
- ✅ Validate security requirements during design phase

### 5. Security Misconfiguration

**Problem**: Insecure default configurations, incomplete setup

```ts
// ❌ CORS misconfiguration: Allow all origins
app.use(cors({
  origin: '*', // Allows any site to make requests
  credentials: true // With credentials! Dangerous combo
}))

// ✅ Restrictive CORS
app.use(cors({
  origin: ['https://yourapp.com', 'https://admin.yourapp.com'],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
}))

// ❌ Verbose error messages in production
app.get('/api/user/:id', async (req, res) => {
  try {
    const user = await db.query('SELECT * FROM users WHERE id = $1', [req.params.id])
    res.json(user)
  } catch (error) {
    // Exposes database structure and queries!
    res.status(500).json({ error: error.message, stack: error.stack })
  }
})

// ✅ Generic errors in production, detailed logs server-side
app.get('/api/user/:id', async (req, res) => {
  try {
    const user = await db.query('SELECT * FROM users WHERE id = $1', [req.params.id])
    res.json(user)
  } catch (error) {
    console.error('Database error:', error) // Log details server-side
    res.status(500).json({ error: 'Internal server error' }) // Generic client message
  }
})

// ✅ Security headers (use helmet)
import helmet from 'helmet'
app.use(helmet()) // Sets multiple security headers

// Specific headers
app.use(helmet.contentSecurityPolicy({
  directives: {
    defaultSrc: ["'self'"],
    scriptSrc: ["'self'", "'unsafe-inline'"],
    styleSrc: ["'self'", "'unsafe-inline'"],
    imgSrc: ["'self'", "data:", "https:"],
  }
}))
```

**Prevention**:
- ✅ Use security headers (CSP, HSTS, X-Frame-Options)
- ✅ Disable directory listing and unnecessary services
- ✅ Keep all dependencies updated
- ✅ Use environment-specific configs (dev vs prod)
- ✅ Remove default credentials and test accounts
- ✅ Configure CORS restrictively

### 6. Vulnerable and Outdated Components

**Problem**: Using libraries with known vulnerabilities

```bash
# ❌ Outdated dependencies
npm install express@4.16.0 # Version from 2018 with vulnerabilities

# ✅ Check for vulnerabilities
npm audit
npm audit fix

# ✅ Keep dependencies updated
npm update
npm outdated

# ✅ Use Dependabot or Renovate for automation
# (GitHub Security tab → Enable Dependabot)

# ✅ Monitor CVE databases
# Check: https://nvd.nist.gov/
```

**Prevention**:
- ✅ Regularly update dependencies
- ✅ Use `npm audit` or `yarn audit`
- ✅ Enable automated dependency updates (Dependabot, Renovate)
- ✅ Subscribe to security advisories for critical packages
- ✅ Remove unused dependencies

### 7. Identification and Authentication Failures

**Problem**: Broken authentication mechanisms

```ts
// ❌ Weak password requirements
const passwordSchema = z.string().min(6) // Too weak!

// ✅ Strong password requirements
const passwordSchema = z.string()
  .min(12, 'Password must be at least 12 characters')
  .regex(/[A-Z]/, 'Must contain uppercase letter')
  .regex(/[a-z]/, 'Must contain lowercase letter')
  .regex(/[0-9]/, 'Must contain number')
  .regex(/[^A-Za-z0-9]/, 'Must contain special character')

// ❌ No rate limiting
app.post('/login', async (req, res) => {
  const { email, password } = req.body
  // Attacker can try millions of passwords
  const user = await authenticateUser(email, password)
  res.json({ token: user.token })
})

// ✅ Rate limiting
import rateLimit from 'express-rate-limit'

const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // 5 attempts per window
  message: 'Too many login attempts, try again later'
})

app.post('/login', loginLimiter, async (req, res) => {
  const { email, password } = req.body
  const user = await authenticateUser(email, password)
  res.json({ token: user.token })
})

// ✅ Implement MFA (Multi-Factor Authentication)
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
  window: 2 // Allow 2-step tolerance for time drift
})
```

**Prevention**:
- ✅ Implement rate limiting on auth endpoints
- ✅ Require strong passwords (12+ chars, complexity)
- ✅ Use MFA for sensitive operations
- ✅ Implement account lockout after failed attempts
- ✅ Use secure session management
- ✅ Hash passwords with bcrypt/argon2 (salt rounds ≥ 12)

### 8. Software and Data Integrity Failures

**Problem**: Insecure CI/CD, unsigned code, untrusted sources

```ts
// ❌ Insecure deserialization
app.post('/api/data', (req, res) => {
  const data = JSON.parse(req.body) // User controls this
  eval(data.code) // NEVER DO THIS
})

// ✅ Validate data structure
import { z } from 'zod'

const dataSchema = z.object({
  id: z.string().uuid(),
  name: z.string().max(100),
  value: z.number().min(0).max(1000)
})

app.post('/api/data', (req, res) => {
  const data = dataSchema.parse(req.body) // Throws if invalid
  // Safe to use data
})

// ❌ Loading scripts from untrusted CDNs
<script src="https://random-cdn.com/library.js"></script>

// ✅ Use Subresource Integrity (SRI)
<script
  src="https://cdn.example.com/library.js"
  integrity="sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC"
  crossorigin="anonymous"
></script>

// ✅ Self-host critical dependencies
// npm install library
// import from 'library' (bundled with your code)
```

**Prevention**:
- ✅ Use SRI for external scripts
- ✅ Verify signatures of downloaded packages
- ✅ Use code signing for deployments
- ✅ Implement secure CI/CD pipelines
- ✅ Never use `eval()`, `Function()`, or similar with user input

### 9. Security Logging and Monitoring Failures

**Problem**: Insufficient logging, delayed breach detection

```ts
// ❌ No logging
app.post('/login', async (req, res) => {
  const user = await authenticateUser(req.body.email, req.body.password)
  res.json({ token: user.token })
  // No record of who logged in when
})

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
  const { email } = req.body
  try {
    const user = await authenticateUser(email, req.body.password)

    logger.info('User login successful', {
      userId: user.id,
      email: user.email,
      ip: req.ip,
      userAgent: req.get('user-agent'),
      timestamp: new Date().toISOString()
    })

    res.json({ token: user.token })
  } catch (error) {
    logger.warn('Failed login attempt', {
      email, // Log attempt for security monitoring
      ip: req.ip,
      reason: error.message,
      timestamp: new Date().toISOString()
    })

    res.status(401).json({ error: 'Invalid credentials' })
  }
})

// ✅ Alert on suspicious patterns
async function checkSuspiciousActivity(userId: string) {
  const recentLogins = await db.loginLog.findMany({
    where: {
      userId,
      timestamp: { gte: new Date(Date.now() - 3600000) } // Last hour
    }
  })

  // Multiple logins from different IPs
  const uniqueIPs = new Set(recentLogins.map(l => l.ip))
  if (uniqueIPs.size > 3) {
    await sendSecurityAlert(userId, 'Multiple IPs detected')
  }
}
```

**Prevention**:
- ✅ Log all authentication events (success/failure)
- ✅ Log access to sensitive data
- ✅ Log privilege changes
- ✅ Monitor for suspicious patterns
- ✅ Set up alerts for security events
- ✅ Use centralized logging (CloudWatch, DataDog, etc.)

### 10. Server-Side Request Forgery (SSRF)

**Problem**: Server makes requests to attacker-controlled URLs

```ts
// ❌ VULNERABLE: Fetching user-provided URLs
app.get('/proxy', async (req, res) => {
  const url = req.query.url as string
  const response = await fetch(url) // User sends url=http://localhost:6379 (Redis)
  const data = await response.text()
  res.send(data) // Exposes internal services!
})

// ✅ Whitelist allowed domains
const ALLOWED_DOMAINS = ['api.example.com', 'cdn.example.com']

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
  const data = await response.text()
  res.send(data)
})
```

**Prevention**:
- ✅ Whitelist allowed URLs/domains
- ✅ Block requests to private IP ranges
- ✅ Disable URL redirects or validate redirect targets
- ✅ Use network segmentation (services can't reach internal network)

---

## Authentication Patterns

### JWT (JSON Web Tokens)

```ts
import jwt from 'jsonwebtoken'

const JWT_SECRET = process.env.JWT_SECRET!

// Generate token
function generateToken(userId: string, role: string) {
  return jwt.sign(
    { userId, role },
    JWT_SECRET,
    { expiresIn: '7d' } // Token expires in 7 days
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
  const payload = verifyToken(token)
  return payload
}

// Usage
export async function GET(req: Request) {
  const { userId } = requireAuth(req) // Throws if not authenticated
  const data = await db.user.findUnique({ where: { id: userId } })
  return Response.json(data)
}
```

### Session-Based Auth

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
    secure: true, // HTTPS only
    httpOnly: true, // No JavaScript access
    maxAge: 1000 * 60 * 60 * 24 * 7, // 7 days
    sameSite: 'strict' // CSRF protection
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

function requireSession(req: Request, res: Response, next: Function) {
  if (!req.session.userId) {
    return res.status(401).json({ error: 'Unauthorized' })
  }
  next()
}
```

---

## Input Validation

### Use Validation Libraries

```ts
import { z } from 'zod'

// Define schema
const userSchema = z.object({
  email: z.string().email().max(255),
  password: z.string().min(12).max(128),
  age: z.number().int().min(18).max(120),
  role: z.enum(['user', 'admin']),
  website: z.string().url().optional()
})

// Validate
try {
  const validData = userSchema.parse(req.body)
  // Safe to use validData
} catch (error) {
  if (error instanceof z.ZodError) {
    return res.status(400).json({ errors: error.errors })
  }
}
```

### Sanitize HTML Input

```ts
import DOMPurify from 'isomorphic-dompurify'

// User-generated content
const userComment = req.body.comment

// ❌ Directly rendering user HTML
<div dangerouslySetInnerHTML={{ __html: userComment }} /> // XSS!

// ✅ Sanitize first
const cleanComment = DOMPurify.sanitize(userComment)
<div dangerouslySetInnerHTML={{ __html: cleanComment }} />
```

---

## Progressive Disclosure

For detailed information, see `/references`:
- `owasp-detailed.md` - Complete OWASP Top 10 analysis
- `authentication.md` - Deep dive into auth patterns (OAuth, SAML, etc.)
- `encryption.md` - Cryptography best practices
- `penetration-testing.md` - Security testing strategies
- `compliance.md` - GDPR, HIPAA, SOC 2 compliance guides

---

## Quick Reference Checklist

**Before deploying**:
- [ ] All secrets in environment variables (not code)
- [ ] Passwords hashed with bcrypt/argon2 (rounds ≥ 12)
- [ ] Input validation on all user inputs
- [ ] Parameterized queries (no string concatenation in SQL)
- [ ] HTTPS enforced
- [ ] CORS configured restrictively
- [ ] Security headers configured (CSP, HSTS, etc.)
- [ ] Rate limiting on auth endpoints
- [ ] Logging for security events
- [ ] Dependencies updated (npm audit clean)
- [ ] Authentication on all protected routes
- [ ] Authorization checks before operations
- [ ] Error messages don't leak information

---

_This skill covers security fundamentals. Always stay updated with latest OWASP guidelines and security best practices._
