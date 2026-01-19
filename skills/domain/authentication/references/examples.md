# Authentication - Detailed Code Examples

## Example 1: Auth Middleware

```typescript
// src/middleware/auth.ts
import { NextRequest, NextResponse } from 'next/server';
import { verifyAccessToken } from '@/lib/auth';

export async function authMiddleware(request: NextRequest) {
  const authHeader = request.headers.get('authorization');

  if (!authHeader?.startsWith('Bearer ')) {
    return NextResponse.json(
      { error: 'Missing authorization header' },
      { status: 401 }
    );
  }

  const token = authHeader.split(' ')[1];

  try {
    const payload = verifyAccessToken(token);

    const headers = new Headers(request.headers);
    headers.set('x-user-id', payload.userId);
    headers.set('x-user-role', payload.role);

    return NextResponse.next({ headers });
  } catch {
    return NextResponse.json(
      { error: 'Invalid or expired token' },
      { status: 401 }
    );
  }
}
```

## Example 2: Rate-Limited Login

```typescript
import { Ratelimit } from '@upstash/ratelimit';
import { Redis } from '@upstash/redis';

const ratelimit = new Ratelimit({
  redis: Redis.fromEnv(),
  limiter: Ratelimit.slidingWindow(5, '15 m'),
  prefix: 'login',
});

async function login(request: Request) {
  const ip = request.headers.get('x-forwarded-for') || 'unknown';
  const { email, password } = await request.json();

  const { success } = await ratelimit.limit(`${ip}:${email}`);

  if (!success) {
    throw new TooManyRequestsError('Too many login attempts');
  }

  const user = await validateCredentials(email, password);
  return generateTokens(user);
}
```

## Example 3: MFA with TOTP

```typescript
import { authenticator } from 'otplib';
import QRCode from 'qrcode';

async function setupMFA(userId: string) {
  const user = await db.user.findUnique({ where: { id: userId } });
  const secret = authenticator.generateSecret();

  await db.user.update({
    where: { id: userId },
    data: { mfaSecret: encrypt(secret) },
  });

  const otpauth = authenticator.keyuri(user.email, 'MyApp', secret);
  const qrCode = await QRCode.toDataURL(otpauth);

  return { qrCode, secret };
}

async function verifyAndEnableMFA(userId: string, code: string) {
  const user = await db.user.findUnique({ where: { id: userId } });
  const secret = decrypt(user.mfaSecret);

  const isValid = authenticator.verify({ token: code, secret });

  if (!isValid) {
    throw new ValidationError('Invalid verification code');
  }

  await db.user.update({
    where: { id: userId },
    data: { mfaEnabled: true },
  });
}

async function verifyMFACode(userId: string, code: string) {
  const user = await db.user.findUnique({ where: { id: userId } });
  const secret = decrypt(user.mfaSecret);
  return authenticator.verify({ token: code, secret });
}
```

## Example 4: Refresh Token Rotation

```typescript
async function refreshAccessToken(refreshToken: string) {
  const tokenHash = hashToken(refreshToken);

  const storedToken = await db.refreshToken.findFirst({
    where: { tokenHash, expiresAt: { gt: new Date() }, revokedAt: null },
    include: { user: true },
  });

  if (!storedToken) {
    throw new UnauthorizedError('Invalid refresh token');
  }

  // Rotate: revoke old token, issue new pair
  const newRefreshToken = generateSecureToken();

  await db.$transaction([
    db.refreshToken.update({
      where: { id: storedToken.id },
      data: { revokedAt: new Date() },
    }),
    db.refreshToken.create({
      data: {
        userId: storedToken.userId,
        tokenHash: hashToken(newRefreshToken),
        expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
      },
    }),
  ]);

  return {
    accessToken: generateAccessToken(storedToken.user),
    refreshToken: newRefreshToken,
  };
}
```
