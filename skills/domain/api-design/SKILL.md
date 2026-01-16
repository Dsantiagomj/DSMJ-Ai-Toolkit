---
name: api-design
domain: backend
description: REST and GraphQL API design patterns. Covers HTTP methods, status codes, versioning, pagination, error handling, schema design, mutations, and API best practices.
version: 1.0.0
tags: [api, rest, graphql, http, backend, api-versioning, pagination]
references:
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

## What This Skill Covers

This skill provides guidance on:
- **REST API** design principles and patterns
- **GraphQL** schema design and best practices
- **HTTP methods** and status codes
- **API versioning** strategies
- **Pagination** patterns
- **Error handling** and validation
- **Authentication** and authorization patterns

---

## REST API Design

### HTTP Methods

Use HTTP methods correctly:

```
GET     - Retrieve resource(s)         (Safe, Idempotent)
POST    - Create new resource          (Not safe, Not idempotent)
PUT     - Replace entire resource      (Not safe, Idempotent)
PATCH   - Partially update resource    (Not safe, Not idempotent)
DELETE  - Remove resource              (Not safe, Idempotent)
```

**Examples**:
```typescript
// Get all users
GET /api/users

// Get specific user
GET /api/users/123

// Create new user
POST /api/users
Body: { "name": "Alice", "email": "alice@example.com" }

// Replace user (full update)
PUT /api/users/123
Body: { "name": "Alice", "email": "alice@example.com", "role": "admin" }

// Partial update
PATCH /api/users/123
Body: { "role": "admin" }

// Delete user
DELETE /api/users/123
```

---

### HTTP Status Codes

Return appropriate status codes:

**2xx Success**:
```
200 OK                - Successful GET, PUT, PATCH, DELETE
201 Created           - Successful POST (resource created)
204 No Content        - Successful DELETE (no response body)
```

**4xx Client Errors**:
```
400 Bad Request       - Invalid request data
401 Unauthorized      - Authentication required
403 Forbidden         - Authenticated but not authorized
404 Not Found         - Resource doesn't exist
409 Conflict          - Resource conflict (e.g., duplicate email)
422 Unprocessable     - Validation errors
429 Too Many Requests - Rate limit exceeded
```

**5xx Server Errors**:
```
500 Internal Server   - Unexpected server error
502 Bad Gateway       - Invalid upstream response
503 Service Unavail   - Server temporarily unavailable
```

**Example** (Next.js API Route):
```typescript
// app/api/users/route.ts
import { NextResponse } from 'next/server';

export async function GET() {
  try {
    const users = await db.user.findMany();
    return NextResponse.json(users, { status: 200 });
  } catch (error) {
    return NextResponse.json(
      { error: 'Failed to fetch users' },
      { status: 500 }
    );
  }
}

export async function POST(request: Request) {
  try {
    const body = await request.json();

    // Validation
    if (!body.email || !body.name) {
      return NextResponse.json(
        { error: 'Email and name are required' },
        { status: 400 }
      );
    }

    // Check for duplicate
    const existing = await db.user.findUnique({ where: { email: body.email } });
    if (existing) {
      return NextResponse.json(
        { error: 'Email already exists' },
        { status: 409 }
      );
    }

    const user = await db.user.create({ data: body });
    return NextResponse.json(user, { status: 201 });
  } catch (error) {
    return NextResponse.json(
      { error: 'Failed to create user' },
      { status: 500 }
    );
  }
}
```

---

### Resource Naming

**Use nouns, not verbs**:
```
✅ GET /api/users          (not /api/getUsers)
✅ POST /api/users         (not /api/createUser)
✅ GET /api/users/123      (not /api/getUserById/123)
```

**Use plural nouns**:
```
✅ GET /api/users          (not /api/user)
✅ GET /api/products       (not /api/product)
```

**Nested resources**:
```
GET /api/users/123/posts           - Get all posts by user 123
GET /api/users/123/posts/456       - Get post 456 by user 123
POST /api/users/123/posts          - Create post for user 123
```

**⚠️ Avoid deep nesting** (max 2 levels):
```
❌ GET /api/users/123/posts/456/comments/789/likes
✅ GET /api/comments/789/likes
```

---

### Pagination

**Cursor-based pagination** (recommended for large datasets):
```typescript
// Request
GET /api/users?cursor=abc123&limit=20

// Response
{
  "data": [...],
  "pagination": {
    "nextCursor": "xyz789",
    "hasMore": true
  }
}

// Implementation (Next.js)
export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const cursor = searchParams.get('cursor');
  const limit = parseInt(searchParams.get('limit') || '20');

  const users = await db.user.findMany({
    take: limit + 1, // Fetch one extra to check if more exist
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

**Offset-based pagination** (simpler, less efficient):
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
    "totalPages": 8
  }
}

// Implementation
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

---

### Filtering and Sorting

```typescript
// Filtering
GET /api/users?role=admin&status=active

// Sorting
GET /api/users?sort=name&order=asc

// Combined
GET /api/users?role=admin&sort=createdAt&order=desc&limit=20

// Implementation
export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const role = searchParams.get('role');
  const status = searchParams.get('status');
  const sort = searchParams.get('sort') || 'createdAt';
  const order = searchParams.get('order') || 'desc';

  const users = await db.user.findMany({
    where: {
      ...(role && { role }),
      ...(status && { status }),
    },
    orderBy: { [sort]: order },
  });

  return NextResponse.json(users);
}
```

---

### API Versioning

**Option 1: URL versioning** (recommended, most explicit):
```
GET /api/v1/users
GET /api/v2/users
```

**Option 2: Header versioning**:
```
GET /api/users
Header: Accept-Version: v2
```

**Breaking vs Non-Breaking Changes**:
```
✅ Non-breaking (no version bump needed):
- Add new endpoint
- Add optional field to request
- Add new field to response

❌ Breaking (requires new version):
- Remove endpoint
- Remove field from response
- Rename field
- Change field type
- Make optional field required
```

**Example** (Next.js):
```typescript
// app/api/v1/users/route.ts
export async function GET() {
  const users = await db.user.findMany();
  return NextResponse.json(users); // Old format
}

// app/api/v2/users/route.ts
export async function GET() {
  const users = await db.user.findMany({
    include: { profile: true }, // New: Include related data
  });
  return NextResponse.json(users);
}
```

---

### Error Handling

**Consistent error format**:
```typescript
// Error response structure
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "details": [
      {
        "field": "email",
        "message": "Invalid email format"
      },
      {
        "field": "age",
        "message": "Must be at least 18"
      }
    ]
  }
}

// Implementation
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
    if (error.code === 'P2002') { // Prisma unique constraint
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

---

## GraphQL API Design

### Schema Design

**Define types clearly**:
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
  createdAt: DateTime!
}

type Query {
  user(id: ID!): User
  users(limit: Int, cursor: String): UserConnection!
  post(id: ID!): Post
  posts(authorId: ID, published: Boolean): [Post!]!
}

type Mutation {
  createUser(input: CreateUserInput!): User!
  updateUser(id: ID!, input: UpdateUserInput!): User!
  deleteUser(id: ID!): Boolean!
  createPost(input: CreatePostInput!): Post!
}

input CreateUserInput {
  name: String!
  email: String!
  role: UserRole
}

input UpdateUserInput {
  name: String
  email: String
  role: UserRole
}

input CreatePostInput {
  title: String!
  content: String!
  authorId: ID!
  published: Boolean
}
```

---

### Resolvers

**Implement resolvers efficiently**:
```typescript
// graphql/resolvers.ts
import { GraphQLError } from 'graphql';

export const resolvers = {
  Query: {
    user: async (_parent, { id }, context) => {
      const user = await context.db.user.findUnique({ where: { id } });
      if (!user) {
        throw new GraphQLError('User not found', {
          extensions: { code: 'NOT_FOUND' },
        });
      }
      return user;
    },

    users: async (_parent, { limit = 20, cursor }, context) => {
      const users = await context.db.user.findMany({
        take: limit + 1,
        ...(cursor && { cursor: { id: cursor }, skip: 1 }),
      });

      const hasMore = users.length > limit;
      const edges = (hasMore ? users.slice(0, -1) : users).map(user => ({
        node: user,
        cursor: user.id,
      }));

      return {
        edges,
        pageInfo: {
          hasNextPage: hasMore,
          endCursor: edges[edges.length - 1]?.cursor,
        },
      };
    },
  },

  Mutation: {
    createUser: async (_parent, { input }, context) => {
      // Check authentication
      if (!context.user) {
        throw new GraphQLError('Unauthorized', {
          extensions: { code: 'UNAUTHORIZED' },
        });
      }

      // Check permissions
      if (context.user.role !== 'ADMIN') {
        throw new GraphQLError('Forbidden', {
          extensions: { code: 'FORBIDDEN' },
        });
      }

      try {
        const user = await context.db.user.create({ data: input });
        return user;
      } catch (error) {
        if (error.code === 'P2002') {
          throw new GraphQLError('Email already exists', {
            extensions: { code: 'DUPLICATE_EMAIL' },
          });
        }
        throw error;
      }
    },
  },

  User: {
    // Field resolver for posts
    posts: async (parent, _args, context) => {
      return context.db.post.findMany({
        where: { authorId: parent.id },
      });
    },
  },
};
```

---

### N+1 Query Problem

**Problem**: Fetching related data in loops causes N+1 queries.

```typescript
// ❌ Bad: N+1 queries
type Query {
  users: [User!]!
}

type User {
  posts: [Post!]!
}

// If you fetch 100 users, this makes:
// 1 query for users + 100 queries for posts = 101 queries!
```

**Solution: Use DataLoader**:
```typescript
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

export const resolvers = {
  User: {
    posts: (parent, _args, context) => {
      return context.loaders.post.load(parent.id);
    },
  },
};

// Now: 1 query for users + 1 batched query for all posts = 2 queries!
```

---

### Input Validation

```graphql
input CreateUserInput {
  name: String!
  email: String!
  age: Int!
}
```

```typescript
import { z } from 'zod';

const createUserSchema = z.object({
  name: z.string().min(2).max(100),
  email: z.string().email(),
  age: z.number().int().min(18).max(120),
});

export const resolvers = {
  Mutation: {
    createUser: async (_parent, { input }, context) => {
      // Validate input
      const result = createUserSchema.safeParse(input);
      if (!result.success) {
        throw new GraphQLError('Validation failed', {
          extensions: {
            code: 'VALIDATION_ERROR',
            errors: result.error.format(),
          },
        });
      }

      const user = await context.db.user.create({ data: result.data });
      return user;
    },
  },
};
```

---

### Error Handling in GraphQL

```typescript
import { GraphQLError } from 'graphql';

// Custom error codes
export const ErrorCodes = {
  UNAUTHENTICATED: 'UNAUTHENTICATED',
  FORBIDDEN: 'FORBIDDEN',
  NOT_FOUND: 'NOT_FOUND',
  VALIDATION_ERROR: 'VALIDATION_ERROR',
  INTERNAL_ERROR: 'INTERNAL_ERROR',
} as const;

// Helper function
function throwGraphQLError(message: string, code: string, data?: any) {
  throw new GraphQLError(message, {
    extensions: {
      code,
      ...(data && { data }),
    },
  });
}

export const resolvers = {
  Query: {
    user: async (_parent, { id }, context) => {
      const user = await context.db.user.findUnique({ where: { id } });
      if (!user) {
        throwGraphQLError('User not found', ErrorCodes.NOT_FOUND);
      }
      return user;
    },
  },
};

// Client receives:
// {
//   "errors": [{
//     "message": "User not found",
//     "extensions": {
//       "code": "NOT_FOUND"
//     }
//   }]
// }
```

---

## Authentication Patterns

### REST - JWT Bearer Token

```typescript
// Middleware
export function authMiddleware(request: Request) {
  const authHeader = request.headers.get('Authorization');
  if (!authHeader?.startsWith('Bearer ')) {
    return NextResponse.json(
      { error: 'Unauthorized' },
      { status: 401 }
    );
  }

  const token = authHeader.substring(7);
  try {
    const user = verifyJWT(token);
    return { user };
  } catch {
    return NextResponse.json(
      { error: 'Invalid token' },
      { status: 401 }
    );
  }
}

// Usage
export async function GET(request: Request) {
  const auth = authMiddleware(request);
  if (auth instanceof NextResponse) return auth; // Error response

  const users = await db.user.findMany();
  return NextResponse.json(users);
}
```

### GraphQL - Context-based Auth

```typescript
// server.ts
import { createYoga } from 'graphql-yoga';

const yoga = createYoga({
  schema,
  context: async ({ request }) => {
    const authHeader = request.headers.get('Authorization');
    let user = null;

    if (authHeader?.startsWith('Bearer ')) {
      const token = authHeader.substring(7);
      try {
        user = await verifyJWT(token);
      } catch {
        // Invalid token, user remains null
      }
    }

    return {
      db,
      user,
      loaders: createLoaders(),
    };
  },
});

// Resolvers check context.user
export const resolvers = {
  Query: {
    me: (_parent, _args, context) => {
      if (!context.user) {
        throw new GraphQLError('Unauthorized', {
          extensions: { code: 'UNAUTHORIZED' },
        });
      }
      return context.user;
    },
  },
};
```

---

## Best Practices Summary

### REST
- ✅ Use appropriate HTTP methods and status codes
- ✅ Use nouns for resources, not verbs
- ✅ Version your API (URL versioning recommended)
- ✅ Implement pagination for list endpoints
- ✅ Return consistent error formats
- ✅ Use cursor-based pagination for large datasets
- ✅ Nest resources max 2 levels deep

### GraphQL
- ✅ Design clear, descriptive schemas
- ✅ Use DataLoader to prevent N+1 queries
- ✅ Validate inputs with schema or validation library
- ✅ Return appropriate error codes in extensions
- ✅ Implement authentication via context
- ✅ Use connection pattern for pagination
- ✅ Keep mutations simple and focused

---

## References

- [GraphQL Documentation](https://graphql.org/learn/)
- [REST API Tutorial](https://restfulapi.net/)

---

_Maintained by dsmj-ai-toolkit_
