---
name: authentication
description: >
  Authentication patterns for JWT, sessions, OAuth, MFA, and secure auth flows.
  Trigger: When implementing authentication, when setting up JWT tokens, when building login flows,
  when integrating OAuth providers, when implementing password reset, when adding MFA.
tags: [authentication, jwt, sessions, oauth, mfa, login, security, passwords]
author: dsmj-ai-toolkit
metadata:
  version: "1.0"
  last_updated: "2026-01-19"
  category: domain
  auto_invoke: "When implementing authentication or authorization"
  stack_category: backend
  progressive_disclosure: true
references:
  - name: OAuth Patterns
    url: ./references/oauth.md
    type: local
  - name: Session Management
    url: ./references/sessions.md
    type: local
---

# Authentication - Secure Auth Patterns

**Production patterns for JWT, sessions, OAuth, password handling, and MFA**

---

## When to Use This Skill

**Use this skill when**:
- Implementing JWT authentication
- Building session-based auth
- Integrating OAuth providers (Google, GitHub)
- Implementing password reset flows
- Adding multi-factor authentication
- Securing API endpoints

**Don't use this skill when**:
- Using managed auth services (Auth0, Clerk) - follow their docs
- Building public APIs without auth
- Authorization logic (see `security` skill)

---

## Critical Patterns

### Pattern 1: Password Hashing

**When**: Storing user passwords securely

```typescript
// ✅ GOOD: Using bcrypt or argon2
import bcrypt from 'bcrypt';

const SALT_ROUNDS = 12; // Adjust based on hardware

async function hashPassword(password: string): Promise<string> {
  return bcrypt.hash(password, SALT_ROUNDS);
}

async function verifyPassword(password: string, hash: string): Promise<boolean> {
  return bcrypt.compare(password, hash);
}

// Registration
async function register(email: string, password: string) {
  // Validate password strength
  if (!isStrongPassword(password)) {
    throw new ValidationError('Password too weak');
  }

  const hashedPassword = await hashPassword(password);

  return db.user.create({
    data: {
      email,
      password: hashedPassword,
    },
  });
}

// Login
async function login(email: string, password: string) {
  const user = await db.user.findUnique({ where: { email } });

  // Use constant-time comparison message
  if (!user || !(await verifyPassword(password, user.password))) {
    throw new UnauthorizedError('Invalid credentials'); // Same message for both!
  }

  return user;
}

// ❌ BAD: Storing plain passwords or using weak hashing
await db.user.create({ data: { password } }); // Plain text!
const hash = crypto.createHash('md5').update(password).digest('hex'); // MD5 is broken!
```

### Pattern 2: JWT Authentication

**When**: Stateless API authentication

```typescript
// ✅ GOOD: JWT with proper configuration
import jwt from 'jsonwebtoken';

interface TokenPayload {
  userId: string;
  email: string;
  role: string;
}

const ACCESS_TOKEN_SECRET = process.env.JWT_SECRET!;
const REFRESH_TOKEN_SECRET = process.env.JWT_REFRESH_SECRET!;
const ACCESS_TOKEN_EXPIRY = '15m';
const REFRESH_TOKEN_EXPIRY = '7d';

function generateTokens(user: User) {
  const payload: TokenPayload = {
    userId: user.id,
    email: user.email,
    role: user.role,
  };

  const accessToken = jwt.sign(payload, ACCESS_TOKEN_SECRET, {
    expiresIn: ACCESS_TOKEN_EXPIRY,
  });

  const refreshToken = jwt.sign(
    { userId: user.id },
    REFRESH_TOKEN_SECRET,
    { expiresIn: REFRESH_TOKEN_EXPIRY }
  );

  return { accessToken, refreshToken };
}

function verifyAccessToken(token: string): TokenPayload {
  try {
    return jwt.verify(token, ACCESS_TOKEN_SECRET) as TokenPayload;
  } catch {
    throw new UnauthorizedError('Invalid or expired token');
  }
}

// ✅ GOOD: Store refresh token securely
async function login(email: string, password: string) {
  const user = await validateCredentials(email, password);
  const { accessToken, refreshToken } = generateTokens(user);

  // Store refresh token hash in database (for revocation)
  await db.refreshToken.create({
    data: {
      userId: user.id,
      tokenHash: await hashToken(refreshToken),
      expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
    },
  });

  return { accessToken, refreshToken };
}

// ❌ BAD: Long-lived access tokens
jwt.sign(payload, secret, { expiresIn: '30d' }); // Too long for access token!

// ❌ BAD: Storing sensitive data in JWT
jwt.sign({ password: user.password, ssn: user.ssn }, secret); // Never!
```

### Pattern 3: Secure Cookie Sessions

**When**: Server-side session management

```typescript
// ✅ GOOD: Secure session cookies
import { cookies } from 'next/headers';
import { SignJWT, jwtVerify } from 'jose';

const SESSION_SECRET = new TextEncoder().encode(process.env.SESSION_SECRET);
const SESSION_DURATION = 60 * 60 * 24 * 7; // 7 days

interface SessionPayload {
  userId: string;
  expiresAt: number;
}

async function createSession(userId: string) {
  const expiresAt = Date.now() + SESSION_DURATION * 1000;

  const token = await new SignJWT({ userId, expiresAt })
    .setProtectedHeader({ alg: 'HS256' })
    .setExpirationTime(expiresAt)
    .sign(SESSION_SECRET);

  (await cookies()).set('session', token, {
    httpOnly: true,           // Not accessible via JavaScript
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'lax',          // CSRF protection
    maxAge: SESSION_DURATION,
    path: '/',
  });
}

async function getSession(): Promise<SessionPayload | null> {
  const token = (await cookies()).get('session')?.value;

  if (!token) return null;

  try {
    const { payload } = await jwtVerify(token, SESSION_SECRET);
    return payload as unknown as SessionPayload;
  } catch {
    return null;
  }
}

async function deleteSession() {
  (await cookies()).delete('session');
}

// ❌ BAD: Insecure cookie settings
cookies().set('session', token, {
  httpOnly: false, // XSS vulnerable!
  secure: false,   // Sent over HTTP!
  sameSite: 'none', // CSRF vulnerable without secure!
});
```

### Pattern 4: OAuth Integration

**When**: Allowing sign-in with external providers

```typescript
// ✅ GOOD: OAuth 2.0 flow with PKCE
// Step 1: Redirect to provider
async function initiateOAuth(provider: 'google' | 'github') {
  const state = generateSecureRandom(32);
  const codeVerifier = generateSecureRandom(64);
  const codeChallenge = await generateCodeChallenge(codeVerifier);

  // Store state and verifier in session
  await setOAuthSession({ state, codeVerifier });

  const authUrl = new URL(OAUTH_ENDPOINTS[provider].authorize);
  authUrl.searchParams.set('client_id', OAUTH_CONFIG[provider].clientId);
  authUrl.searchParams.set('redirect_uri', OAUTH_CONFIG[provider].redirectUri);
  authUrl.searchParams.set('response_type', 'code');
  authUrl.searchParams.set('scope', OAUTH_CONFIG[provider].scopes);
  authUrl.searchParams.set('state', state);
  authUrl.searchParams.set('code_challenge', codeChallenge);
  authUrl.searchParams.set('code_challenge_method', 'S256');

  return authUrl.toString();
}

// Step 2: Handle callback
async function handleOAuthCallback(code: string, state: string) {
  const session = await getOAuthSession();

  // Verify state to prevent CSRF
  if (state !== session.state) {
    throw new UnauthorizedError('Invalid state parameter');
  }

  // Exchange code for tokens
  const tokens = await exchangeCodeForTokens(code, session.codeVerifier);

  // Get user info from provider
  const providerUser = await getProviderUserInfo(tokens.accessToken);

  // Find or create user
  let user = await db.user.findUnique({
    where: { email: providerUser.email },
  });

  if (!user) {
    user = await db.user.create({
      data: {
        email: providerUser.email,
        name: providerUser.name,
        emailVerified: true, // OAuth emails are verified
      },
    });
  }

  // Create session
  await createSession(user.id);

  return user;
}

// ❌ BAD: Not validating state parameter
async function handleCallback(code: string) {
  const tokens = await exchangeCode(code); // CSRF attack possible!
}
```

### Pattern 5: Password Reset Flow

**When**: Allowing users to reset forgotten passwords

```typescript
// ✅ GOOD: Secure password reset
import crypto from 'crypto';

async function requestPasswordReset(email: string) {
  const user = await db.user.findUnique({ where: { email } });

  // Always respond the same way (prevent email enumeration)
  if (!user) {
    // Log attempt but don't reveal if email exists
    logger.info('Password reset requested for unknown email');
    return; // Same response as success
  }

  // Generate secure token
  const token = crypto.randomBytes(32).toString('hex');
  const tokenHash = crypto.createHash('sha256').update(token).digest('hex');

  // Store hashed token with expiry
  await db.passwordReset.create({
    data: {
      userId: user.id,
      tokenHash,
      expiresAt: new Date(Date.now() + 60 * 60 * 1000), // 1 hour
    },
  });

  // Send email with unhashed token
  await sendEmail({
    to: user.email,
    template: 'password-reset',
    data: {
      resetUrl: `${process.env.APP_URL}/reset-password?token=${token}`,
    },
  });
}

async function resetPassword(token: string, newPassword: string) {
  const tokenHash = crypto.createHash('sha256').update(token).digest('hex');

  const reset = await db.passwordReset.findFirst({
    where: {
      tokenHash,
      expiresAt: { gt: new Date() },
      usedAt: null,
    },
    include: { user: true },
  });

  if (!reset) {
    throw new UnauthorizedError('Invalid or expired reset token');
  }

  // Update password and mark token as used
  await db.$transaction([
    db.user.update({
      where: { id: reset.userId },
      data: { password: await hashPassword(newPassword) },
    }),
    db.passwordReset.update({
      where: { id: reset.id },
      data: { usedAt: new Date() },
    }),
    // Invalidate all sessions (logout everywhere)
    db.session.deleteMany({ where: { userId: reset.userId } }),
  ]);
}

// ❌ BAD: Predictable tokens or long expiry
const token = `reset-${user.id}-${Date.now()}`; // Predictable!
expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000); // 7 days is too long!
```

---

## Code Examples

For complete, production-ready examples, see [references/examples.md](./references/examples.md):
- Auth Middleware with JWT
- Rate-Limited Login (brute force protection)
- MFA with TOTP
- Refresh Token Rotation

---

## Anti-Patterns

### Don't: Reveal User Existence

```typescript
// ❌ BAD: Different messages reveal if email exists
if (!user) throw new Error('Email not found');
if (!passwordMatch) throw new Error('Wrong password');

// ✅ GOOD: Same message for both
if (!user || !passwordMatch) {
  throw new UnauthorizedError('Invalid credentials');
}
```

### Don't: Store Tokens in localStorage

```typescript
// ❌ BAD: XSS vulnerable
localStorage.setItem('token', accessToken);

// ✅ GOOD: httpOnly cookie (for sessions)
// Or: Keep access token in memory, refresh token in httpOnly cookie
```

### Don't: Skip Token Revocation

```typescript
// ❌ BAD: No way to logout from all devices
function logout() {
  // Just delete local token - other sessions still valid!
}

// ✅ GOOD: Track sessions server-side
async function logout(userId: string) {
  await db.session.deleteMany({ where: { userId } });
}
```

---

## Quick Reference

| Scenario | Pattern | Key Points |
|----------|---------|------------|
| Password storage | bcrypt/argon2 | 12+ salt rounds |
| API auth | JWT | Short-lived access tokens |
| Web sessions | httpOnly cookies | Secure, SameSite |
| Third-party login | OAuth 2.0 + PKCE | Validate state |
| Password reset | Hashed tokens | 1 hour expiry |
| Brute force | Rate limiting | By IP + email |

---

## Resources

**Related Skills**:
- **security**: OWASP, input validation
- **caching**: Session storage
- **api-design**: Protected endpoints

---

## Keywords

`authentication`, `jwt`, `sessions`, `oauth`, `mfa`, `totp`, `password-hashing`, `bcrypt`, `login`, `logout`, `refresh-token`
