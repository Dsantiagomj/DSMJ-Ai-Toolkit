---
name: error-handling
description: >
  Error handling patterns for try-catch, error boundaries, structured logging, and exception strategies.
  Trigger: When implementing error handling, when building error boundaries, when setting up logging,
  when designing error responses, when handling async errors, when creating custom error classes.
tags: [errors, exceptions, logging, error-boundaries, try-catch, debugging, production]
author: dsmj-ai-toolkit
metadata:
  version: "1.0"
  last_updated: "2026-01-19"
  category: domain
  auto_invoke: "When implementing error handling or logging"
  stack_category: backend
  progressive_disclosure: true
references:
  - name: Logging Patterns
    url: ./references/logging.md
    type: local
---

# Error Handling - Exception & Logging Patterns

**Production patterns for error handling, boundaries, structured logging, and recovery**

---

## When to Use This Skill

**Use this skill when**:
- Implementing try-catch error handling
- Building React error boundaries
- Setting up structured logging
- Designing API error responses
- Handling async/Promise errors
- Creating custom error classes
- Implementing graceful degradation

**Don't use this skill when**:
- Building happy path only (always handle errors!)
- Using framework-specific patterns (check stack skills first)

---

## Critical Patterns

### Pattern 1: Custom Error Classes

**When**: Creating typed, structured errors

```typescript
// ✅ GOOD: Hierarchical error classes
// src/errors/base.ts
export class AppError extends Error {
  public readonly isOperational: boolean;
  public readonly statusCode: number;
  public readonly code: string;

  constructor(
    message: string,
    statusCode: number = 500,
    code: string = 'INTERNAL_ERROR',
    isOperational: boolean = true
  ) {
    super(message);
    this.name = this.constructor.name;
    this.statusCode = statusCode;
    this.code = code;
    this.isOperational = isOperational;

    Error.captureStackTrace(this, this.constructor);
  }
}

// Specific error types
export class NotFoundError extends AppError {
  constructor(resource: string = 'Resource') {
    super(`${resource} not found`, 404, 'NOT_FOUND');
  }
}

export class ValidationError extends AppError {
  constructor(
    message: string,
    public readonly details?: Record<string, string[]>
  ) {
    super(message, 400, 'VALIDATION_ERROR');
  }
}

export class UnauthorizedError extends AppError {
  constructor(message: string = 'Unauthorized') {
    super(message, 401, 'UNAUTHORIZED');
  }
}

export class ConflictError extends AppError {
  constructor(message: string = 'Resource already exists') {
    super(message, 409, 'CONFLICT');
  }
}

// ❌ BAD: Throwing plain strings or generic errors
throw 'Something went wrong'; // No type, no stack trace
throw new Error('Not found'); // No status code, no classification
```

### Pattern 2: Async Error Handling

**When**: Handling errors in async operations

```typescript
// ✅ GOOD: Centralized async error wrapper
type AsyncFunction<T> = (...args: any[]) => Promise<T>;

function handleAsync<T>(fn: AsyncFunction<T>) {
  return async (...args: any[]): Promise<T> => {
    try {
      return await fn(...args);
    } catch (error) {
      // Log the error
      logger.error('Async operation failed', { error, args });

      // Re-throw operational errors
      if (error instanceof AppError && error.isOperational) {
        throw error;
      }

      // Wrap unknown errors
      throw new AppError('An unexpected error occurred', 500, 'INTERNAL_ERROR', false);
    }
  };
}

// Usage
const createUser = handleAsync(async (data: CreateUserInput) => {
  const existing = await db.user.findUnique({ where: { email: data.email } });
  if (existing) {
    throw new ConflictError('Email already registered');
  }
  return db.user.create({ data });
});

// ✅ GOOD: Promise.allSettled for parallel operations
async function processItems(items: Item[]) {
  const results = await Promise.allSettled(
    items.map(item => processItem(item))
  );

  const successful = results
    .filter((r): r is PromiseFulfilledResult<Item> => r.status === 'fulfilled')
    .map(r => r.value);

  const failed = results
    .filter((r): r is PromiseRejectedResult => r.status === 'rejected')
    .map(r => r.reason);

  if (failed.length > 0) {
    logger.warn(`${failed.length} items failed to process`, { failed });
  }

  return { successful, failed };
}

// ❌ BAD: Unhandled promise rejection
async function riskyOperation() {
  const data = await fetchData(); // If this throws, app crashes!
  return data;
}
```

### Pattern 3: React Error Boundaries

**When**: Catching render errors in React

```tsx
// ✅ GOOD: Error boundary component
"use client";

import { Component, ReactNode } from 'react';

interface Props {
  children: ReactNode;
  fallback?: ReactNode;
  onError?: (error: Error, errorInfo: React.ErrorInfo) => void;
}

interface State {
  hasError: boolean;
  error: Error | null;
}

export class ErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = { hasError: false, error: null };
  }

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    // Log to error reporting service
    console.error('Error boundary caught:', error, errorInfo);
    this.props.onError?.(error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      return this.props.fallback || (
        <div className="p-4 border border-red-500 rounded">
          <h2>Something went wrong</h2>
          <button onClick={() => this.setState({ hasError: false, error: null })}>
            Try again
          </button>
        </div>
      );
    }

    return this.props.children;
  }
}

// Usage
<ErrorBoundary
  fallback={<ErrorFallback />}
  onError={(error) => reportToSentry(error)}
>
  <Dashboard />
</ErrorBoundary>

// ❌ BAD: No error boundary (entire app crashes on render error)
function App() {
  return <Dashboard />; // If Dashboard throws, white screen!
}
```

### Pattern 4: Structured Logging

**When**: Creating queryable, parseable logs

```typescript
// ✅ GOOD: Structured logger with context
import pino from 'pino';

const logger = pino({
  level: process.env.LOG_LEVEL || 'info',
  formatters: {
    level: (label) => ({ level: label }),
  },
  base: {
    service: process.env.SERVICE_NAME,
    environment: process.env.NODE_ENV,
  },
});

// Create child logger with request context
function createRequestLogger(req: Request) {
  return logger.child({
    requestId: req.headers.get('x-request-id'),
    path: new URL(req.url).pathname,
    method: req.method,
  });
}

// Usage
app.use((req, res, next) => {
  req.log = createRequestLogger(req);
  req.log.info('Request started');

  res.on('finish', () => {
    req.log.info('Request completed', {
      statusCode: res.statusCode,
      duration: Date.now() - req.startTime,
    });
  });

  next();
});

// In handlers
async function getUser(req, res) {
  req.log.info('Fetching user', { userId: req.params.id });

  try {
    const user = await userService.findById(req.params.id);
    req.log.info('User found', { userId: user.id });
    res.json(user);
  } catch (error) {
    req.log.error('Failed to fetch user', {
      userId: req.params.id,
      error: error.message,
      stack: error.stack,
    });
    throw error;
  }
}

// ❌ BAD: Console.log with no structure
console.log('User not found: ' + userId); // Can't query, no context
console.log(error); // Object might not serialize properly
```

### Pattern 5: Graceful Degradation

**When**: Maintaining functionality when components fail

```typescript
// ✅ GOOD: Fallback values and graceful degradation
async function getDashboardData(userId: string) {
  const [userResult, statsResult, recentResult] = await Promise.allSettled([
    getUserProfile(userId),
    getAnalyticsStats(userId),
    getRecentActivity(userId),
  ]);

  return {
    user: userResult.status === 'fulfilled'
      ? userResult.value
      : { name: 'Unknown', error: true },

    stats: statsResult.status === 'fulfilled'
      ? statsResult.value
      : { error: true, message: 'Stats unavailable' },

    recent: recentResult.status === 'fulfilled'
      ? recentResult.value
      : [],
  };
}

// ✅ GOOD: Circuit breaker pattern
class CircuitBreaker {
  private failures = 0;
  private lastFailure: number = 0;
  private state: 'closed' | 'open' | 'half-open' = 'closed';

  constructor(
    private threshold: number = 5,
    private timeout: number = 30000
  ) {}

  async execute<T>(fn: () => Promise<T>): Promise<T> {
    if (this.state === 'open') {
      if (Date.now() - this.lastFailure > this.timeout) {
        this.state = 'half-open';
      } else {
        throw new Error('Circuit breaker is open');
      }
    }

    try {
      const result = await fn();
      this.onSuccess();
      return result;
    } catch (error) {
      this.onFailure();
      throw error;
    }
  }

  private onSuccess() {
    this.failures = 0;
    this.state = 'closed';
  }

  private onFailure() {
    this.failures++;
    this.lastFailure = Date.now();
    if (this.failures >= this.threshold) {
      this.state = 'open';
    }
  }
}

// ❌ BAD: All or nothing approach
async function getDashboard(userId: string) {
  const user = await getUserProfile(userId); // If this fails, entire dashboard fails
  const stats = await getStats(userId);
  const recent = await getRecent(userId);
  return { user, stats, recent };
}
```

---

## Code Examples

For complete, production-ready examples, see [references/examples.md](./references/examples.md):
- API Error Handler Middleware
- React Query Error Handling
- Error Reporting Integration (Sentry)
- Error Boundary with Recovery

---

## Anti-Patterns

### Don't: Swallow Errors Silently

```typescript
// ❌ BAD: Silent error swallowing
try {
  await riskyOperation();
} catch (error) {
  // Nothing happens - bug is hidden!
}

// ✅ GOOD: At minimum, log the error
try {
  await riskyOperation();
} catch (error) {
  logger.error('Operation failed', { error });
  // Decide: rethrow, return fallback, or handle
}
```

### Don't: Expose Internal Details

```typescript
// ❌ BAD: Leaking implementation details
res.status(500).json({
  error: error.message, // "Cannot read property 'x' of undefined"
  stack: error.stack, // Full stack trace!
});

// ✅ GOOD: Safe error response
res.status(500).json({
  error: 'An unexpected error occurred',
  requestId: req.id, // For support lookup
});
```

### Don't: Use Generic Catch-All

```typescript
// ❌ BAD: Catching everything the same way
try {
  await processPayment();
} catch (error) {
  return { error: 'Failed' }; // Lost all context!
}

// ✅ GOOD: Handle specific errors differently
try {
  await processPayment();
} catch (error) {
  if (error instanceof PaymentDeclinedError) {
    return { error: 'Payment declined', code: 'DECLINED' };
  }
  if (error instanceof NetworkError) {
    return { error: 'Please try again', code: 'NETWORK' };
  }
  throw error; // Unknown error - let it bubble up
}
```

---

## Quick Reference

| Scenario | Pattern | Example |
|----------|---------|---------|
| HTTP errors | Custom error classes | `throw new NotFoundError()` |
| Async errors | try-catch + wrapper | `handleAsync(fn)` |
| React errors | Error boundary | `<ErrorBoundary>` |
| Parallel failures | Promise.allSettled | `Promise.allSettled([...])` |
| Logging | Structured logger | `logger.error('msg', { context })` |
| External service | Circuit breaker | `breaker.execute(fn)` |

---

## Resources

**Related Skills**:
- **observability**: Monitoring and tracing
- **security**: Secure error messages
- **api-design**: Error response formats

---

## Keywords

`error-handling`, `exceptions`, `try-catch`, `error-boundary`, `logging`, `structured-logging`, `graceful-degradation`, `circuit-breaker`, `pino`, `sentry`
