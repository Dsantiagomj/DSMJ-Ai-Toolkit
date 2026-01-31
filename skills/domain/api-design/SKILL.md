---
name: api-design
domain: backend
description: >
  REST and GraphQL API design patterns. Covers HTTP methods, status codes, versioning, pagination, error handling, schema design, mutations, and API best practices.
  Trigger: When designing APIs, when creating REST endpoints, when implementing GraphQL schemas, when handling API versioning, when designing pagination.
version: 1.0.0
tags: [api, rest, graphql, http, backend, api-versioning, pagination]
author: dsmj-ai-toolkit
metadata:
  version: "1.0"
  last_updated: "2026-01-17"
  category: domain
  progressive_disclosure: true
references:
  - name: REST Patterns
    url: ./references/rest-patterns.md
    type: local
  - name: GraphQL Design
    url: ./references/graphql.md
    type: local
  - name: GraphQL Documentation
    url: https://graphql.org/learn/
    type: documentation
  - name: REST API Tutorial
    url: https://restfulapi.net/
    type: documentation
---

# API Design - REST & GraphQL

**Design consistent, intuitive APIs that scale**

---

## When to Use This Skill

Use this skill when:
- Designing new API endpoints (REST or GraphQL)
- Creating HTTP routes and handlers
- Implementing pagination, filtering, or sorting
- Versioning APIs for backward compatibility
- Handling API errors and validation
- Designing GraphQL schemas and resolvers
- Optimizing API performance (N+1 queries, caching)

Don't use this skill for:
- Frontend-only work with no API involvement
- Direct database queries without an API layer
- Internal function calls (not exposed as API)

---

## Critical Patterns

### Pattern 1: HTTP Methods and Status Codes

**When**: Building RESTful endpoints

**Good**:
```typescript
// Correct HTTP methods and status codes
export async function GET(request: Request) {
  const users = await db.user.findMany();
  return NextResponse.json(users, { status: 200 });
}

export async function POST(request: Request) {
  const body = await request.json();

  if (!body.email || !body.name) {
    return NextResponse.json(
      { error: 'Email and name are required' },
      { status: 400 }  // Bad Request
    );
  }

  const user = await db.user.create({ data: body });
  return NextResponse.json(user, { status: 201 });  // Created
}

export async function DELETE(request: Request) {
  await db.user.delete({ where: { id: '123' } });
  return new Response(null, { status: 204 });  // No Content
}
```

**Bad**:
```typescript
// ❌ Wrong: Using POST for everything
export async function POST(request: Request) {
  const { action, userId } = await request.json();

  if (action === 'get') {
    const user = await db.user.findUnique({ where: { id: userId } });
    return NextResponse.json(user);  // Should be GET
  }

  if (action === 'delete') {
    await db.user.delete({ where: { id: userId } });
    return NextResponse.json({ success: true });  // Should be DELETE
  }
}

// ❌ Wrong: Always returning 200
export async function GET(request: Request) {
  const user = await db.user.findUnique({ where: { id: '999' } });
  if (!user) {
    return NextResponse.json({ error: 'Not found' }, { status: 200 });  // Should be 404
  }
  return NextResponse.json(user);
}
```

**Why**: Correct HTTP methods and status codes make APIs predictable and RESTful. Clients can rely on standard semantics.

**HTTP Methods Quick Reference**:
```
GET     - Retrieve (Safe, Idempotent, Cacheable)
POST    - Create (Not safe, Not idempotent)
PUT     - Replace entire resource (Not safe, Idempotent)
PATCH   - Partial update (Not safe, Usually idempotent)
DELETE  - Remove (Not safe, Idempotent)
```

**Status Codes Quick Reference**:
```
2xx Success:
  200 OK            - Successful GET, PUT, PATCH, DELETE
  201 Created       - Successful POST (resource created)
  204 No Content    - Successful DELETE (no response body)

4xx Client Errors:
  400 Bad Request   - Invalid request data
  401 Unauthorized  - Authentication required
  403 Forbidden     - Authenticated but not authorized
  404 Not Found     - Resource doesn't exist
  409 Conflict      - Resource conflict (duplicate)
  422 Unprocessable - Validation errors

5xx Server Errors:
  500 Internal      - Unexpected server error
  503 Unavailable   - Server temporarily unavailable
```

---

### Pattern 2: Resource Naming and Nesting

**When**: Designing API URL structure

**Good**:
```typescript
// ✅ Use nouns, not verbs
GET /api/users
POST /api/users
GET /api/users/123
DELETE /api/users/123

// ✅ Plural nouns for collections
GET /api/products
GET /api/orders

// ✅ Nested resources (max 2 levels)
GET /api/users/123/posts
POST /api/users/123/posts
GET /api/users/123/posts/456
```

**Bad**:
```typescript
// ❌ Wrong: Verbs in URLs
GET /api/getUsers
POST /api/createUser
DELETE /api/deleteUser/123

// ❌ Wrong: Singular for collections
GET /api/user
GET /api/product

// ❌ Wrong: Too deeply nested (3+ levels)
GET /api/users/123/posts/456/comments/789/likes
```

**Why**: Nouns represent resources, verbs are implied by HTTP methods. Avoid deep nesting to keep URLs simple and predictable.

**Nested Resources Pattern**:
```
GET /api/users/123/posts           - Get all posts by user 123
GET /api/users/123/posts/456       - Get specific post by user 123
POST /api/users/123/posts          - Create post for user 123

// ⚠️ For deep relationships, use query params instead:
GET /api/comments?postId=456
GET /api/likes?commentId=789
```

---

### Pattern 3: Pagination

**When**: Returning large collections

**Good - Cursor-based** (recommended for large datasets):
```typescript
export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const cursor = searchParams.get('cursor');
  const limit = parseInt(searchParams.get('limit') || '20');

  const users = await db.user.findMany({
    take: limit + 1,
    ...(cursor && { cursor: { id: cursor }, skip: 1 }),
    orderBy: { id: 'asc' },
  });

  const hasMore = users.length > limit;
  const data = hasMore ? users.slice(0, -1) : users;

  return NextResponse.json({
    data,
    pagination: {
      nextCursor: hasMore ? data[data.length - 1].id : null,
      hasMore,
    },
  });
}
```

**Good - Offset-based** (simpler, for admin panels):
```typescript
export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const page = parseInt(searchParams.get('page') || '1');
  const limit = parseInt(searchParams.get('limit') || '20');

  const [users, total] = await Promise.all([
    db.user.findMany({
      skip: (page - 1) * limit,
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
    },
  });
}
```

**Bad**:
```typescript
// ❌ No pagination - returns all records
export async function GET() {
  const users = await db.user.findMany();  // Could be millions!
  return NextResponse.json(users);
}
```

**Why**: Pagination prevents performance issues and timeouts. Cursor-based is more efficient for large datasets, offset-based is simpler for small datasets.

---

### Pattern 4: API Versioning

**When**: Making breaking changes to existing APIs

**Good - URL versioning** (most explicit):
```
GET /api/v1/users
GET /api/v2/users
```

```typescript
// app/api/v1/users/route.ts
export async function GET() {
  const users = await db.user.findMany();
  return NextResponse.json(users);  // Old format
}

// app/api/v2/users/route.ts
export async function GET() {
  const users = await db.user.findMany({
    include: { profile: true },  // New: Include related data
  });
  return NextResponse.json(users);
}
```

**Breaking vs Non-Breaking Changes**:
```typescript
// ✅ Non-breaking (no version bump needed):
// - Add new endpoint
// - Add optional field to request
// - Add new field to response

// ❌ Breaking (requires new version):
// - Remove endpoint
// - Remove field from response
// - Rename field
// - Change field type
// - Make optional field required
```

**Why**: Versioning allows backward compatibility while evolving the API. Existing clients continue working while new clients use improved versions.

---

### Pattern 5: Consistent Error Handling

**When**: Handling errors and validation

**Good**:
```typescript
interface ApiError {
  code: string;
  message: string;
  details?: Array<{ field: string; message: string }>;
}

function errorResponse(status: number, error: ApiError) {
  return NextResponse.json({ error }, { status });
}

export async function POST(request: Request) {
  try {
    const body = await request.json();

    const errors = validateUser(body);
    if (errors.length > 0) {
      return errorResponse(400, {
        code: 'VALIDATION_ERROR',
        message: 'Invalid input data',
        details: errors,
      });
    }

    const user = await db.user.create({ data: body });
    return NextResponse.json(user, { status: 201 });
  } catch (error) {
    if (error.code === 'P2002') {
      return errorResponse(409, {
        code: 'DUPLICATE_EMAIL',
        message: 'Email already exists',
      });
    }

    return errorResponse(500, {
      code: 'INTERNAL_ERROR',
      message: 'An unexpected error occurred',
    });
  }
}
```

**Bad**:
```typescript
// ❌ Inconsistent error formats
export async function POST(request: Request) {
  try {
    const body = await request.json();

    if (!body.email) {
      return NextResponse.json('Email required');  // Plain string
    }

    const user = await db.user.create({ data: body });
    return NextResponse.json(user);
  } catch (error) {
    return NextResponse.json({
      message: error.message,  // Inconsistent format
      stack: error.stack,      // Leaks implementation details
    });
  }
}
```

**Why**: Consistent error format makes client error handling predictable. Never expose stack traces or internal details in production.

---

## GraphQL Critical Patterns

### Pattern 1: Schema Design with Types and Relationships

**Good**:
```graphql
type User {
  id: ID!
  name: String!
  email: String!
  role: UserRole!
  posts: [Post!]!
  createdAt: DateTime!
}

enum UserRole {
  ADMIN
  USER
  GUEST
}

type Post {
  id: ID!
  title: String!
  content: String!
  author: User!
  published: Boolean!
}

type Query {
  user(id: ID!): User
  users(limit: Int, cursor: String): UserConnection!
}

type Mutation {
  createUser(input: CreateUserInput!): User!
  updateUser(id: ID!, input: UpdateUserInput!): User!
}

input CreateUserInput {
  name: String!
  email: String!
  role: UserRole
}
```

**Why**: Clear types, non-null fields (the `!` suffix), and input types make the API self-documenting and type-safe.

---

### Pattern 2: Solving N+1 Queries with DataLoader

**Problem**:
```typescript
// ❌ N+1 queries: 1 for users + N for posts
const resolvers = {
  User: {
    posts: async (parent, _args, context) => {
      return context.db.post.findMany({
        where: { authorId: parent.id },
      });
    },
  },
};
// Querying 100 users = 101 database queries!
```

**Solution**:
```typescript
// ✅ DataLoader batches queries
import DataLoader from 'dataloader';

const postLoader = new DataLoader(async (userIds: readonly string[]) => {
  const posts = await db.post.findMany({
    where: { authorId: { in: [...userIds] } },
  });

  const postsByUserId = userIds.map(userId =>
    posts.filter(post => post.authorId === userId)
  );

  return postsByUserId;
});

const resolvers = {
  User: {
    posts: (parent, _args, context) => {
      return context.loaders.post.load(parent.id);
    },
  },
};
// Querying 100 users = 2 queries (users + batched posts)!
```

**Why**: DataLoader batches and caches database queries, solving the N+1 problem and dramatically improving performance.

---

## Anti-Patterns

### ❌ Anti-Pattern 1: Exposing Database Structure Directly

**Don't do this**:
```typescript
// ❌ API mirrors database exactly
GET /api/users
Response: {
  id: 123,
  password_hash: "bcrypt...",  // Exposing sensitive data!
  created_at: "2024-01-15",
  internal_notes: "VIP customer"
}
```

**Do this instead**:
```typescript
// ✅ API has its own contract
GET /api/users/123
Response: {
  id: 123,
  name: "Alice",
  email: "alice@example.com",
  role: "admin",
  joinedAt: "2024-01-15T10:00:00Z"
}

// Server-side: Transform before sending
export async function GET(request: Request, { params }) {
  const user = await db.user.findUnique({ where: { id: params.id } });

  return NextResponse.json({
    id: user.id,
    name: user.name,
    email: user.email,
    role: user.role,
    joinedAt: user.createdAt,
  });
}
```

---

### ❌ Anti-Pattern 2: No Input Validation

**Don't do this**:
```typescript
// ❌ Trusting all input
export async function POST(request: Request) {
  const body = await request.json();
  const user = await db.user.create({ data: body });
  return NextResponse.json(user);
}
```

**Do this instead**:
```typescript
// ✅ Validate all input
import { z } from 'zod';

const userSchema = z.object({
  name: z.string().min(2).max(100),
  email: z.string().email(),
  age: z.number().int().min(18).max(120),
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

---

### ❌ Anti-Pattern 3: Ignoring Authentication

**Don't do this**:
```typescript
// ❌ No auth checks
export async function DELETE(request: Request) {
  const { id } = await request.json();
  await db.user.delete({ where: { id } });
  return NextResponse.json({ success: true });
}
```

**Do this instead**:
```typescript
// ✅ Check authentication and authorization
export async function DELETE(request: Request) {
  const session = await getSession(request);

  if (!session) {
    return new Response('Unauthorized', { status: 401 });
  }

  if (session.role !== 'ADMIN') {
    return new Response('Forbidden', { status: 403 });
  }

  const { id } = await request.json();
  await db.user.delete({ where: { id } });
  return new Response(null, { status: 204 });
}
```

---

## Code Examples

### Example 1: RESTful CRUD Endpoint

```typescript
// app/api/users/[id]/route.ts
export async function GET(request: Request, { params }: { params: { id: string } }) {
  const user = await db.user.findUnique({ where: { id: params.id } });

  if (!user) {
    return new Response('User not found', { status: 404 });
  }

  return NextResponse.json(user);
}

export async function PATCH(request: Request, { params }: { params: { id: string } }) {
  const body = await request.json();
  const user = await db.user.update({
    where: { id: params.id },
    data: body,
  });

  return NextResponse.json(user);
}
```

### Example 2: GraphQL Resolver with DataLoader

```typescript
const resolvers = {
  Query: {
    users: async (_parent, { limit = 20, cursor }, context) => {
      const users = await context.db.user.findMany({
        take: limit + 1,
        ...(cursor && { cursor: { id: cursor }, skip: 1 }),
      });

      const hasMore = users.length > limit;
      const data = hasMore ? users.slice(0, -1) : users;

      return {
        edges: data.map(user => ({ node: user, cursor: user.id })),
        pageInfo: {
          hasNextPage: hasMore,
          endCursor: hasMore ? data[data.length - 1].id : null,
        },
      };
    },
  },
  User: {
    posts: (parent, _args, context) => {
      return context.loaders.posts.load(parent.id);
    },
  },
};
```

For comprehensive examples and detailed implementations, see the [references/](./references/) folder.

---

## Quick Reference

### REST Checklist
- [ ] Use appropriate HTTP methods (GET, POST, PUT, PATCH, DELETE)
- [ ] Return correct status codes (2xx, 4xx, 5xx)
- [ ] Use nouns for resources, not verbs
- [ ] Implement pagination for collections
- [ ] Version API for breaking changes
- [ ] Validate all input
- [ ] Return consistent error format
- [ ] Add authentication/authorization checks

### GraphQL Checklist
- [ ] Design clear schema with types and relationships
- [ ] Use DataLoader to prevent N+1 queries
- [ ] Validate inputs with Zod or similar
- [ ] Return meaningful error codes in extensions
- [ ] Implement authentication via context
- [ ] Use connection pattern for pagination
- [ ] Keep mutations simple and focused

---

## Progressive Disclosure

For detailed implementations, see:
- **[REST Patterns](./references/rest-patterns.md)** - Pagination, filtering, versioning, rate limiting, HATEOAS
- **[GraphQL Design](./references/graphql.md)** - Resolvers, DataLoader, subscriptions, directives, input validation

---

## References

- [REST Patterns Reference](./references/rest-patterns.md)
- [GraphQL Design Reference](./references/graphql.md)
- [GraphQL Documentation](https://graphql.org/learn/)
- [REST API Tutorial](https://restfulapi.net/)

---

_Maintained by dsmj-ai-toolkit_
