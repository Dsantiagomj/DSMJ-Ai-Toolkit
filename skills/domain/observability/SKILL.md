---
name: observability
description: >
  Observability patterns for metrics, logging, distributed tracing, and error tracking.
  Trigger: When setting up monitoring, when implementing logging, when adding error tracking,
  when configuring distributed tracing, when building health checks, when creating dashboards.
tags: [observability, monitoring, logging, tracing, metrics, sentry, datadog, prometheus]
author: dsmj-ai-toolkit
metadata:
  version: "1.0"
  last_updated: "2026-01-19"
  category: domain
  auto_invoke: "When implementing observability or monitoring"
  stack_category: devops
  progressive_disclosure: true
references:
  - name: Metrics Patterns
    url: ./references/metrics.md
    type: local
---

# Observability - Monitoring, Logging & Tracing

**Production patterns for the three pillars: metrics, logs, and traces**

---

## When to Use This Skill

**Use this skill when**:
- Setting up application monitoring
- Implementing structured logging
- Adding error tracking (Sentry, Bugsnag)
- Configuring distributed tracing
- Building health check endpoints
- Creating alerting rules

**Don't use this skill when**:
- Development/local debugging only
- Using managed platforms with built-in observability

---

## Critical Patterns

### Pattern 1: Structured Logging

**When**: Creating queryable, parseable logs

```typescript
// ✅ GOOD: Structured logging with pino
import pino from 'pino';

const logger = pino({
  level: process.env.LOG_LEVEL || 'info',
  formatters: {
    level: (label) => ({ level: label }),
    bindings: (bindings) => ({
      pid: bindings.pid,
      hostname: bindings.hostname,
      service: process.env.SERVICE_NAME,
    }),
  },
  timestamp: pino.stdTimeFunctions.isoTime,
});

// Create request-scoped logger
function createRequestLogger(requestId: string, userId?: string) {
  return logger.child({
    requestId,
    userId,
  });
}

// Usage in handlers
async function handleRequest(req: Request) {
  const log = createRequestLogger(req.id, req.user?.id);

  log.info({ path: req.url, method: req.method }, 'Request started');

  try {
    const result = await processRequest(req);
    log.info({ duration: Date.now() - req.startTime }, 'Request completed');
    return result;
  } catch (error) {
    log.error({
      error: error.message,
      stack: error.stack,
      duration: Date.now() - req.startTime,
    }, 'Request failed');
    throw error;
  }
}

// ❌ BAD: Unstructured console.log
console.log('User ' + userId + ' did ' + action); // Can't query!
console.log(error); // Object won't serialize properly
```

### Pattern 2: Error Tracking

**When**: Capturing and analyzing production errors

```typescript
// ✅ GOOD: Sentry integration
import * as Sentry from '@sentry/node';

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  environment: process.env.NODE_ENV,
  release: process.env.GIT_SHA,
  tracesSampleRate: 0.1, // 10% of transactions
  integrations: [
    new Sentry.Integrations.Http({ tracing: true }),
    new Sentry.Integrations.Prisma({ client: prisma }),
  ],
  beforeSend(event, hint) {
    // Filter out expected errors
    const error = hint.originalException;
    if (error instanceof AppError && error.isOperational) {
      return null; // Don't send operational errors
    }
    return event;
  },
});

// Capture with context
function captureError(error: Error, context?: Record<string, any>) {
  Sentry.withScope((scope) => {
    if (context) {
      scope.setExtras(context);
    }
    if (context?.userId) {
      scope.setUser({ id: context.userId });
    }
    Sentry.captureException(error);
  });
}

// Usage in error handler
app.use((err, req, res, next) => {
  captureError(err, {
    requestId: req.id,
    userId: req.user?.id,
    path: req.path,
    method: req.method,
    body: req.body,
  });

  res.status(500).json({ error: 'Internal server error' });
});

// ❌ BAD: No error tracking
app.use((err, req, res, next) => {
  console.error(err); // Lost when container restarts!
  res.status(500).json({ error: err.message }); // Exposes internals
});
```

### Pattern 3: Health Checks

**When**: Monitoring application and dependency health

```typescript
// ✅ GOOD: Comprehensive health check
// app/api/health/route.ts
import { NextResponse } from 'next/server';

interface HealthCheck {
  status: 'healthy' | 'degraded' | 'unhealthy';
  checks: Record<string, CheckResult>;
  version: string;
  uptime: number;
}

interface CheckResult {
  status: 'pass' | 'fail';
  latency?: number;
  message?: string;
}

async function checkDatabase(): Promise<CheckResult> {
  const start = Date.now();
  try {
    await prisma.$queryRaw`SELECT 1`;
    return { status: 'pass', latency: Date.now() - start };
  } catch (error) {
    return { status: 'fail', message: error.message };
  }
}

async function checkRedis(): Promise<CheckResult> {
  const start = Date.now();
  try {
    await redis.ping();
    return { status: 'pass', latency: Date.now() - start };
  } catch (error) {
    return { status: 'fail', message: error.message };
  }
}

async function checkExternalAPI(): Promise<CheckResult> {
  const start = Date.now();
  try {
    const res = await fetch(process.env.EXTERNAL_API_URL + '/health', {
      signal: AbortSignal.timeout(5000),
    });
    return {
      status: res.ok ? 'pass' : 'fail',
      latency: Date.now() - start,
    };
  } catch (error) {
    return { status: 'fail', message: error.message };
  }
}

export async function GET() {
  const checks = {
    database: await checkDatabase(),
    redis: await checkRedis(),
    externalApi: await checkExternalAPI(),
  };

  const allPassing = Object.values(checks).every(c => c.status === 'pass');
  const anyFailing = Object.values(checks).some(c => c.status === 'fail');

  const health: HealthCheck = {
    status: allPassing ? 'healthy' : anyFailing ? 'unhealthy' : 'degraded',
    checks,
    version: process.env.GIT_SHA || 'unknown',
    uptime: process.uptime(),
  };

  return NextResponse.json(health, {
    status: health.status === 'healthy' ? 200 : 503,
  });
}

// ❌ BAD: Simple health check that always passes
export async function GET() {
  return NextResponse.json({ status: 'ok' }); // Doesn't check anything!
}
```

### Pattern 4: Distributed Tracing

**When**: Tracking requests across services

```typescript
// ✅ GOOD: OpenTelemetry tracing
import { NodeSDK } from '@opentelemetry/sdk-node';
import { getNodeAutoInstrumentations } from '@opentelemetry/auto-instrumentations-node';
import { OTLPTraceExporter } from '@opentelemetry/exporter-trace-otlp-http';

const sdk = new NodeSDK({
  traceExporter: new OTLPTraceExporter({
    url: process.env.OTEL_EXPORTER_OTLP_ENDPOINT,
  }),
  instrumentations: [getNodeAutoInstrumentations()],
  serviceName: process.env.SERVICE_NAME,
});

sdk.start();

// Manual span creation
import { trace, SpanStatusCode } from '@opentelemetry/api';

const tracer = trace.getTracer('my-service');

async function processOrder(orderId: string) {
  return tracer.startActiveSpan('processOrder', async (span) => {
    span.setAttribute('order.id', orderId);

    try {
      // Child spans are automatically linked
      const order = await fetchOrder(orderId);
      span.setAttribute('order.total', order.total);

      await tracer.startActiveSpan('validateInventory', async (childSpan) => {
        await validateInventory(order.items);
        childSpan.end();
      });

      await tracer.startActiveSpan('processPayment', async (childSpan) => {
        await processPayment(order);
        childSpan.end();
      });

      span.setStatus({ code: SpanStatusCode.OK });
      return order;
    } catch (error) {
      span.setStatus({
        code: SpanStatusCode.ERROR,
        message: error.message,
      });
      span.recordException(error);
      throw error;
    } finally {
      span.end();
    }
  });
}

// Propagate trace context to external services
async function callExternalService(data: any) {
  const headers: Record<string, string> = {};

  // Inject trace context into headers
  propagation.inject(context.active(), headers);

  return fetch(EXTERNAL_SERVICE_URL, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      ...headers, // Includes traceparent header
    },
    body: JSON.stringify(data),
  });
}
```

### Pattern 5: Metrics Collection

**When**: Measuring application performance and business metrics

```typescript
// ✅ GOOD: Prometheus metrics
import { Registry, Counter, Histogram, Gauge } from 'prom-client';

const registry = new Registry();

// HTTP request metrics
const httpRequestsTotal = new Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'path', 'status'],
  registers: [registry],
});

const httpRequestDuration = new Histogram({
  name: 'http_request_duration_seconds',
  help: 'HTTP request duration in seconds',
  labelNames: ['method', 'path'],
  buckets: [0.01, 0.05, 0.1, 0.5, 1, 5],
  registers: [registry],
});

// Business metrics
const ordersTotal = new Counter({
  name: 'orders_total',
  help: 'Total number of orders',
  labelNames: ['status'],
  registers: [registry],
});

const activeUsers = new Gauge({
  name: 'active_users',
  help: 'Number of currently active users',
  registers: [registry],
});

// Middleware to track requests
app.use((req, res, next) => {
  const start = Date.now();

  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    const path = req.route?.path || req.path;

    httpRequestsTotal.inc({
      method: req.method,
      path,
      status: res.statusCode,
    });

    httpRequestDuration.observe(
      { method: req.method, path },
      duration
    );
  });

  next();
});

// Expose metrics endpoint
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', registry.contentType);
  res.send(await registry.metrics());
});

// Track business events
async function createOrder(data: CreateOrderInput) {
  const order = await db.order.create({ data });
  ordersTotal.inc({ status: 'created' });
  return order;
}
```

---

## Code Examples

For complete, production-ready examples, see [references/examples.md](./references/examples.md):
- Request Logging Middleware
- Dashboard Alerts Configuration (Prometheus)
- Error Boundary with Reporting
- Custom Metrics (Prometheus)

---

## Anti-Patterns

### Don't: Log Sensitive Data

```typescript
// ❌ BAD: Logging passwords, tokens, PII
logger.info({ user: { email, password } }, 'User login');
logger.info({ authorization: req.headers.authorization }, 'Request');

// ✅ GOOD: Redact sensitive fields
logger.info({ userId: user.id, email: user.email }, 'User login');
logger.info({ hasAuth: !!req.headers.authorization }, 'Request');
```

### Don't: Sample Everything at 100%

```typescript
// ❌ BAD: Trace every request
tracesSampleRate: 1.0, // Very expensive at scale!

// ✅ GOOD: Sample appropriately
tracesSampleRate: 0.1, // 10% of transactions
// Or use dynamic sampling based on endpoint
```

### Don't: Ignore Alert Fatigue

```typescript
// ❌ BAD: Alert on every error
if (error) sendAlert(error); // Gets ignored due to noise

// ✅ GOOD: Alert on actionable thresholds
// Only alert when error rate exceeds 5% for 5 minutes
```

---

## Quick Reference

| Pillar | Tool | Use Case |
|--------|------|----------|
| Logs | Pino, Winston | Structured application logs |
| Metrics | Prometheus | Request counts, latencies |
| Traces | OpenTelemetry | Distributed request flow |
| Errors | Sentry | Exception tracking |
| APM | Datadog, New Relic | Full observability suite |

---

## Resources

**Related Skills**:
- **error-handling**: Exception patterns
- **performance**: Optimization metrics
- **ci-cd**: Deployment monitoring

---

## Keywords

`observability`, `monitoring`, `logging`, `tracing`, `metrics`, `sentry`, `prometheus`, `opentelemetry`, `health-check`, `alerting`
