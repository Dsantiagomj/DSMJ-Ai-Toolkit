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
references:
  - name: OWASP Top 10 Details
    url: ./references/owasp-top-10.md
    type: local
  - name: Authentication Patterns
    url: ./references/authentication.md
    type: local
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

## Critical Security Patterns

### Pattern 1: Authentication & Authorization

**When**: Protecting routes and resources

**Good**:
```tsx
// ✅ Proper auth check
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

// ✅ Role-based access
export async function DELETE(req: Request, { params }) {
  const session = await getSession(req)

  if (!session) {
    return new Response('Unauthorized', { status: 401 })
  }

  if (session.role !== 'admin') {
    return new Response('Forbidden', { status: 403 })
  }

  await db.user.delete({ where: { id: params.id } })
  return new Response(null, { status: 204 })
}
```

**Bad**:
```tsx
// ❌ No auth check
export async function GET(req: Request) {
  const userId = req.headers.get('user-id')
  const data = await db.user.findUnique({ where: { id: userId } })
  return Response.json(data) // Returns ANY user's data!
}
```

**Why**: Always verify authentication before accessing protected resources. Check authorization (role/ownership) before operations.

---

### Pattern 2: Password Security

**When**: Storing and verifying passwords

**Good**:
```ts
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
```

**Bad**:
```ts
// ❌ NEVER store plain text passwords
await db.user.create({
  data: {
    email,
    password: password, // NEVER DO THIS
  }
})
```

**Why**: Passwords must be hashed with bcrypt/argon2 (minimum 12 rounds). Never store plain text.

---

### Pattern 3: SQL Injection Prevention

**When**: Executing database queries

**Good**:
```ts
// ✅ Use parameterized queries
const userId = req.query.id
await db.user.findUnique({
  where: { id: userId } // ORM handles escaping
})

// ✅ Or with raw SQL, use parameters
await db.$queryRaw`SELECT * FROM users WHERE id = ${userId}`
```

**Bad**:
```ts
// ❌ VULNERABLE: String concatenation
const userId = req.query.id
const query = `SELECT * FROM users WHERE id = ${userId}`
await db.execute(query) // SQL Injection risk!
```

**Why**: Never concatenate user input into SQL. Use ORMs or parameterized queries.

---

### Pattern 4: Input Validation

**When**: Handling user input

**Good**:
```ts
// ✅ Validate all input
import { z } from 'zod'

const userSchema = z.object({
  email: z.string().email(),
  password: z.string().min(12),
  age: z.number().int().min(18)
})

export async function POST(request: Request) {
  const body = await request.json()

  const result = userSchema.safeParse(body)
  if (!result.success) {
    return NextResponse.json(
      { error: result.error.format() },
      { status: 400 }
    )
  }

  const user = await db.user.create({ data: result.data })
  return NextResponse.json(user, { status: 201 })
}
```

**Bad**:
```ts
// ❌ No validation
export async function POST(request: Request) {
  const body = await request.json()
  const user = await db.user.create({ data: body })
  return NextResponse.json(user)
}
```

**Why**: Always validate and sanitize user input. Never trust client data.

---

### Pattern 5: CORS Configuration

**When**: Setting up API access

**Good**:
```ts
// ✅ Restrictive CORS
app.use(cors({
  origin: ['https://yourapp.com', 'https://admin.yourapp.com'],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
}))
```

**Bad**:
```ts
// ❌ Allow all origins with credentials
app.use(cors({
  origin: '*',
  credentials: true
}))
```

**Why**: Restrictive CORS prevents unauthorized cross-origin requests.

---

### Pattern 6: Error Handling

**When**: Returning error messages

**Good**:
```ts
// ✅ Generic errors in production
app.get('/api/user/:id', async (req, res) => {
  try {
    const user = await db.query('SELECT * FROM users WHERE id = $1', [req.params.id])
    res.json(user)
  } catch (error) {
    console.error('Database error:', error) // Log server-side
    res.status(500).json({ error: 'Internal server error' })
  }
})
```

**Bad**:
```ts
// ❌ Exposes implementation details
app.get('/api/user/:id', async (req, res) => {
  try {
    const user = await db.query('SELECT * FROM users WHERE id = $1', [req.params.id])
    res.json(user)
  } catch (error) {
    res.status(500).json({ error: error.message, stack: error.stack })
  }
})
```

**Why**: Never expose stack traces or internal details in production.

---

## Code Examples

### Example 1: Secure Authentication Endpoint

```typescript
import bcrypt from 'bcryptjs';
import { z } from 'zod';

const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(12),
});

export async function POST(request: Request) {
  const body = await request.json();

  const result = loginSchema.safeParse(body);
  if (!result.success) {
    return new Response('Invalid input', { status: 400 });
  }

  const user = await db.user.findUnique({
    where: { email: result.data.email }
  });

  if (!user || !(await bcrypt.compare(result.data.password, user.password))) {
    return new Response('Invalid credentials', { status: 401 });
  }

  const session = await createSession(user.id);
  return NextResponse.json({ session });
}
```

### Example 2: Input Validation with Zod

```typescript
const userSchema = z.object({
  name: z.string().min(2).max(100),
  email: z.string().email(),
  age: z.number().int().min(18).max(120),
  role: z.enum(['USER', 'ADMIN']),
});

export async function POST(request: Request) {
  const body = await request.json();
  const result = userSchema.safeParse(body);

  if (!result.success) {
    return NextResponse.json(
      { error: result.error.format() },
      { status: 400 }
    );
  }

  const user = await db.user.create({ data: result.data });
  return NextResponse.json(user, { status: 201 });
}
```

For comprehensive examples and detailed implementations, see the [references/](./references/) folder.

---

## Quick Security Checklist

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

## Progressive Disclosure

For detailed information, see:
- **[OWASP Top 10 Details](./references/owasp-top-10.md)** - Complete OWASP Top 10 analysis with examples
- **[Authentication Patterns](./references/authentication.md)** - JWT, sessions, MFA, input validation

---

## References

- [OWASP Top 10 Details](./references/owasp-top-10.md)
- [Authentication Patterns](./references/authentication.md)

---

_This skill covers security fundamentals. Always stay updated with latest OWASP guidelines and security best practices._
