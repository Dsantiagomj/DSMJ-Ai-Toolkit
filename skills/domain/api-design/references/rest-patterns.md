# REST API Patterns - Detailed Implementation Guide

Complete reference for RESTful API design patterns including pagination, versioning, filtering, and advanced techniques.

---

## HTTP Methods - Complete Reference

### GET - Retrieve Resources

```typescript
// Single resource
GET /api/users/123
Response: { "id": 123, "name": "Alice", "email": "alice@example.com" }

// Collection
GET /api/users
Response: [
  { "id": 1, "name": "Alice" },
  { "id": 2, "name": "Bob" }
]

// With query parameters
GET /api/users?role=admin&status=active
```

**Properties**:
- Safe: Does not modify data
- Idempotent: Multiple identical requests = same result
- Cacheable: Responses can be cached

### POST - Create Resources

```typescript
POST /api/users
Body: { "name": "Alice", "email": "alice@example.com" }
Response: 201 Created
{
  "id": 123,
  "name": "Alice",
  "email": "alice@example.com",
  "createdAt": "2024-01-15T10:00:00Z"
}
```

**Properties**:
- Not safe
- Not idempotent: Each request creates new resource

### PUT - Replace Entire Resource

```typescript
PUT /api/users/123
Body: {
  "name": "Alice Smith",
  "email": "alice.smith@example.com",
  "role": "admin"
}
```

**Properties**:
- Not safe
- Idempotent: Multiple identical requests = same result

### PATCH - Partial Update

```typescript
PATCH /api/users/123
Body: { "role": "admin" }
```

**Properties**:
- Not safe
- Not idempotent (in practice, often idempotent)

### DELETE - Remove Resource

```typescript
DELETE /api/users/123
Response: 204 No Content
```

**Properties**:
- Not safe
- Idempotent: Deleting same resource multiple times = same result

---

## Pagination Patterns

### Cursor-Based Pagination (Recommended)

**Best for**: Real-time feeds, large datasets, consistent ordering

```typescript
// Request
GET /api/posts?cursor=abc123&limit=20

// Response
{
  "data": [
    { "id": 10, "title": "Post 10" },
    { "id": 9, "title": "Post 9" },
    // ... 18 more items
  ],
  "pagination": {
    "nextCursor": "xyz789",
    "prevCursor": "def456",
    "hasMore": true
  }
}

// Implementation (Next.js)
export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const cursor = searchParams.get('cursor');
  const limit = parseInt(searchParams.get('limit') || '20');

  const posts = await db.post.findMany({
    take: limit + 1,
    ...(cursor && {
      cursor: { id: cursor },
      skip: 1, // Skip cursor item
    }),
    orderBy: { id: 'desc' },
  });

  const hasMore = posts.length > limit;
  const data = hasMore ? posts.slice(0, -1) : posts;
  const nextCursor = hasMore ? data[data.length - 1].id : null;

  return NextResponse.json({
    data,
    pagination: {
      nextCursor,
      hasMore,
    },
  });
}
```

**Advantages**:
- Consistent results even with new insertions
- Efficient for large datasets
- No page drift

**Disadvantages**:
- Can't jump to specific page
- Harder to implement "total pages"

### Offset-Based Pagination (Simple)

**Best for**: Admin panels, small datasets, when page numbers needed

```typescript
// Request
GET /api/users?page=2&limit=20

// Response
{
  "data": [...],
  "pagination": {
    "page": 2,
    "limit": 20,
    "total": 150,
    "totalPages": 8,
    "hasNext": true,
    "hasPrev": true
  }
}

// Implementation
export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const page = parseInt(searchParams.get('page') || '1');
  const limit = parseInt(searchParams.get('limit') || '20');
  const offset = (page - 1) * limit;

  const [users, total] = await Promise.all([
    db.user.findMany({
      skip: offset,
      take: limit,
    }),
    db.user.count(),
  ]);

  return NextResponse.json({
    data: users,
    pagination: {
      page,
      limit,
      total,
      totalPages: Math.ceil(total / limit),
      hasNext: page < Math.ceil(total / limit),
      hasPrev: page > 1,
    },
  });
}
```

**Advantages**:
- Simple to implement
- Can jump to specific page
- Easy to show total pages

**Disadvantages**:
- Inefficient for large offsets
- Results can shift if data changes during pagination

### Keyset Pagination (Alternative)

**Best for**: Time-based data, when you need stable pagination

```typescript
// Request
GET /api/posts?since=2024-01-15T10:00:00Z&limit=20

// Response
{
  "data": [...],
  "pagination": {
    "oldest": "2024-01-14T12:00:00Z",
    "newest": "2024-01-15T09:59:59Z"
  }
}

// Implementation
export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const since = searchParams.get('since');
  const limit = parseInt(searchParams.get('limit') || '20');

  const posts = await db.post.findMany({
    where: since ? { createdAt: { lt: new Date(since) } } : {},
    take: limit,
    orderBy: { createdAt: 'desc' },
  });

  return NextResponse.json({
    data: posts,
    pagination: {
      oldest: posts[posts.length - 1]?.createdAt,
      newest: posts[0]?.createdAt,
    },
  });
}
```

---

## Filtering and Sorting

### Query Parameter Patterns

```typescript
// Filtering
GET /api/products?category=electronics&price_min=100&price_max=500&inStock=true

// Sorting
GET /api/products?sort=price&order=asc
GET /api/products?sort=-price  // Descending (with minus prefix)

// Multiple sort fields
GET /api/products?sort=category,-price,name

// Search
GET /api/products?search=laptop

// Combined
GET /api/products?category=electronics&search=laptop&sort=price&order=desc&page=1&limit=20
```

### Implementation Example

```typescript
export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);

  // Parse filters
  const category = searchParams.get('category');
  const priceMin = searchParams.get('price_min');
  const priceMax = searchParams.get('price_max');
  const inStock = searchParams.get('inStock');
  const search = searchParams.get('search');

  // Parse sort
  const sortField = searchParams.get('sort') || 'createdAt';
  const order = searchParams.get('order') || 'desc';

  // Build where clause
  const where: any = {};

  if (category) {
    where.category = category;
  }

  if (priceMin || priceMax) {
    where.price = {};
    if (priceMin) where.price.gte = parseFloat(priceMin);
    if (priceMax) where.price.lte = parseFloat(priceMax);
  }

  if (inStock !== null) {
    where.inStock = inStock === 'true';
  }

  if (search) {
    where.OR = [
      { name: { contains: search, mode: 'insensitive' } },
      { description: { contains: search, mode: 'insensitive' } },
    ];
  }

  // Query database
  const products = await db.product.findMany({
    where,
    orderBy: { [sortField]: order },
  });

  return NextResponse.json(products);
}
```

---

## API Versioning Strategies

### URL Versioning (Recommended)

**Most explicit and discoverable**

```
GET /api/v1/users
GET /api/v2/users
```

**Next.js Structure**:
```
app/
├── api/
│   ├── v1/
│   │   └── users/
│   │       └── route.ts
│   └── v2/
│       └── users/
│           └── route.ts
```

### Header Versioning

**Keeps URLs clean**

```
GET /api/users
Header: Accept-Version: v2
```

```typescript
export async function GET(request: Request) {
  const version = request.headers.get('Accept-Version') || 'v1';

  if (version === 'v2') {
    // V2 implementation
    return NextResponse.json({ users: await getUsersV2() });
  }

  // V1 implementation
  return NextResponse.json({ users: await getUsersV1() });
}
```

### Accept Header Versioning

**RESTful approach**

```
GET /api/users
Header: Accept: application/vnd.myapp.v2+json
```

### Breaking vs Non-Breaking Changes

**Non-breaking** (no version bump needed):
```typescript
// ✅ Add new endpoint
GET /api/v1/posts  // Existing
GET /api/v1/tags   // New

// ✅ Add optional parameter
GET /api/v1/users?includeDeleted=true  // New optional param

// ✅ Add new field to response
{
  "id": 1,
  "name": "Alice",
  "email": "alice@example.com",
  "bio": "New field"  // Clients ignore unknown fields
}
```

**Breaking** (requires new version):
```typescript
// ❌ Remove endpoint
GET /api/v1/legacy  // Removed

// ❌ Remove field from response
{
  "id": 1,
  "name": "Alice"
  // email field removed - clients may expect it
}

// ❌ Rename field
{
  "id": 1,
  "fullName": "Alice"  // Was "name"
}

// ❌ Change field type
{
  "id": "123"  // Was number, now string
}

// ❌ Make optional field required
POST /api/users
Body: {
  "name": "Alice",
  "email": "required@now.com"  // Was optional
}
```

---

## Error Handling Best Practices

### Consistent Error Response Format

```typescript
interface ApiError {
  error: {
    code: string;
    message: string;
    details?: Array<{
      field: string;
      message: string;
    }>;
    timestamp?: string;
    requestId?: string;
  };
}

// Example errors
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "details": [
      { "field": "email", "message": "Invalid email format" },
      { "field": "age", "message": "Must be at least 18" }
    ],
    "timestamp": "2024-01-15T10:00:00Z",
    "requestId": "req_abc123"
  }
}

{
  "error": {
    "code": "NOT_FOUND",
    "message": "User not found",
    "timestamp": "2024-01-15T10:00:00Z",
    "requestId": "req_def456"
  }
}
```

### Error Response Helper

```typescript
// lib/api-errors.ts
export class ApiError extends Error {
  constructor(
    public statusCode: number,
    public code: string,
    message: string,
    public details?: Array<{ field: string; message: string }>
  ) {
    super(message);
  }
}

export function errorResponse(error: ApiError | Error, requestId?: string) {
  const statusCode = error instanceof ApiError ? error.statusCode : 500;
  const code = error instanceof ApiError ? error.code : 'INTERNAL_ERROR';
  const details = error instanceof ApiError ? error.details : undefined;

  return NextResponse.json(
    {
      error: {
        code,
        message: error.message,
        ...(details && { details }),
        timestamp: new Date().toISOString(),
        requestId,
      },
    },
    { status: statusCode }
  );
}

// Usage
export async function POST(request: Request) {
  const requestId = crypto.randomUUID();

  try {
    const body = await request.json();

    const errors = validateUser(body);
    if (errors.length > 0) {
      throw new ApiError(400, 'VALIDATION_ERROR', 'Invalid input', errors);
    }

    const user = await db.user.create({ data: body });
    return NextResponse.json(user, { status: 201 });
  } catch (error) {
    return errorResponse(error, requestId);
  }
}
```

### Common Error Codes

```typescript
export const ErrorCodes = {
  // Client errors (4xx)
  BAD_REQUEST: 'BAD_REQUEST',
  VALIDATION_ERROR: 'VALIDATION_ERROR',
  UNAUTHORIZED: 'UNAUTHORIZED',
  FORBIDDEN: 'FORBIDDEN',
  NOT_FOUND: 'NOT_FOUND',
  CONFLICT: 'CONFLICT',
  DUPLICATE_RESOURCE: 'DUPLICATE_RESOURCE',
  RATE_LIMIT_EXCEEDED: 'RATE_LIMIT_EXCEEDED',

  // Server errors (5xx)
  INTERNAL_ERROR: 'INTERNAL_ERROR',
  SERVICE_UNAVAILABLE: 'SERVICE_UNAVAILABLE',
  DATABASE_ERROR: 'DATABASE_ERROR',
} as const;
```

---

## Rate Limiting

### Token Bucket Implementation

```typescript
// lib/rate-limiter.ts
interface RateLimitConfig {
  maxRequests: number;
  windowMs: number;
}

const store = new Map<string, { count: number; resetAt: number }>();

export function rateLimit(config: RateLimitConfig) {
  return async (request: Request) => {
    const ip = request.headers.get('x-forwarded-for') || 'unknown';
    const now = Date.now();

    const record = store.get(ip);

    // Reset if window expired
    if (!record || now > record.resetAt) {
      store.set(ip, {
        count: 1,
        resetAt: now + config.windowMs,
      });
      return { allowed: true, remaining: config.maxRequests - 1 };
    }

    // Increment counter
    record.count++;

    if (record.count > config.maxRequests) {
      return {
        allowed: false,
        remaining: 0,
        resetAt: record.resetAt,
      };
    }

    return {
      allowed: true,
      remaining: config.maxRequests - record.count,
    };
  };
}

// Usage
const limiter = rateLimit({ maxRequests: 10, windowMs: 60000 }); // 10 req/min

export async function POST(request: Request) {
  const result = await limiter(request);

  if (!result.allowed) {
    return NextResponse.json(
      { error: 'Rate limit exceeded' },
      {
        status: 429,
        headers: {
          'X-RateLimit-Limit': '10',
          'X-RateLimit-Remaining': '0',
          'X-RateLimit-Reset': String(result.resetAt),
        },
      }
    );
  }

  // Process request
  return NextResponse.json({ success: true });
}
```

---

## HATEOAS (Hypermedia as the Engine of Application State)

Advanced REST pattern for discoverable APIs:

```typescript
// Response includes links to related resources
{
  "id": 123,
  "name": "Alice",
  "email": "alice@example.com",
  "_links": {
    "self": { "href": "/api/users/123" },
    "posts": { "href": "/api/users/123/posts" },
    "followers": { "href": "/api/users/123/followers" },
    "update": { "href": "/api/users/123", "method": "PUT" },
    "delete": { "href": "/api/users/123", "method": "DELETE" }
  }
}
```

Implementation:

```typescript
function addLinks(user: User, baseUrl: string) {
  return {
    ...user,
    _links: {
      self: { href: `${baseUrl}/api/users/${user.id}` },
      posts: { href: `${baseUrl}/api/users/${user.id}/posts` },
      followers: { href: `${baseUrl}/api/users/${user.id}/followers` },
      update: { href: `${baseUrl}/api/users/${user.id}`, method: 'PUT' },
      delete: { href: `${baseUrl}/api/users/${user.id}`, method: 'DELETE' },
    },
  };
}
```

---

_Complete REST API patterns reference for progressive disclosure_
