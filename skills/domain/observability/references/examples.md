# Observability - Detailed Code Examples

## Example 1: Request Logging Middleware

```typescript
// src/middleware/logging.ts
import { NextRequest, NextResponse } from 'next/server';
import { logger } from '@/lib/logger';

export async function loggingMiddleware(request: NextRequest) {
  const requestId = crypto.randomUUID();
  const start = Date.now();

  logger.info({
    type: 'request',
    requestId,
    method: request.method,
    url: request.url,
    userAgent: request.headers.get('user-agent'),
    ip: request.headers.get('x-forwarded-for'),
  });

  const response = NextResponse.next();
  response.headers.set('x-request-id', requestId);

  const duration = Date.now() - start;
  logger.info({ type: 'response', requestId, duration });

  return response;
}
```

## Example 2: Dashboard Alerts Configuration

```yaml
# alertmanager.yml
groups:
  - name: application
    rules:
      - alert: HighErrorRate
        expr: |
          sum(rate(http_requests_total{status=~"5.."}[5m]))
          / sum(rate(http_requests_total[5m])) > 0.05
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High error rate detected"
          description: "Error rate is {{ $value | humanizePercentage }}"

      - alert: SlowResponses
        expr: |
          histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket[5m])) by (le))
          > 2
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Slow response times"

      - alert: HealthCheckFailing
        expr: up{job="my-app"} == 0
        for: 1m
        labels:
          severity: critical
```

## Example 3: Error Boundary with Reporting

```tsx
"use client";

import { Component, ReactNode } from 'react';
import * as Sentry from '@sentry/nextjs';

interface Props {
  children: ReactNode;
  fallback?: ReactNode;
}

interface State {
  hasError: boolean;
  eventId: string | null;
}

export class ErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = { hasError: false, eventId: null };
  }

  static getDerivedStateFromError(): State {
    return { hasError: true, eventId: null };
  }

  componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    const eventId = Sentry.captureException(error, {
      extra: { componentStack: errorInfo.componentStack },
    });
    this.setState({ eventId });
  }

  render() {
    if (this.state.hasError) {
      return this.props.fallback || (
        <div className="p-8 text-center">
          <h2>Something went wrong</h2>
          {this.state.eventId && <p>Reference: {this.state.eventId}</p>}
          <button onClick={() => this.setState({ hasError: false, eventId: null })}>
            Try again
          </button>
        </div>
      );
    }
    return this.props.children;
  }
}
```

## Example 4: Custom Metrics

```typescript
import { Registry, Counter, Histogram, Gauge } from 'prom-client';

const registry = new Registry();

export const httpRequestsTotal = new Counter({
  name: 'http_requests_total',
  help: 'Total HTTP requests',
  labelNames: ['method', 'path', 'status'],
  registers: [registry],
});

export const httpRequestDuration = new Histogram({
  name: 'http_request_duration_seconds',
  help: 'HTTP request duration',
  labelNames: ['method', 'path'],
  buckets: [0.01, 0.05, 0.1, 0.5, 1, 5],
  registers: [registry],
});

export const activeConnections = new Gauge({
  name: 'active_connections',
  help: 'Current active connections',
  registers: [registry],
});

// Expose endpoint
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', registry.contentType);
  res.send(await registry.metrics());
});
```
