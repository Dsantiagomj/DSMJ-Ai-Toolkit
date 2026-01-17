# GraphQL API Design - Complete Guide

Comprehensive reference for GraphQL schema design, resolvers, performance optimization, and best practices.

---

## Schema Design Patterns

### Type Definitions

```graphql
# Scalar types
type User {
  id: ID!           # Non-null ID
  name: String!     # Non-null String
  email: String!
  age: Int          # Nullable Int
  height: Float
  isActive: Boolean!
}

# Enum types
enum UserRole {
  ADMIN
  MODERATOR
  USER
  GUEST
}

enum OrderStatus {
  PENDING
  PROCESSING
  SHIPPED
  DELIVERED
  CANCELLED
}

# Object types with relationships
type User {
  id: ID!
  name: String!
  email: String!
  role: UserRole!
  posts: [Post!]!          # Non-null array of non-null Posts
  comments: [Comment!]!
  followers: [User!]!
  following: [User!]!
  createdAt: DateTime!
  updatedAt: DateTime!
}

type Post {
  id: ID!
  title: String!
  content: String!
  published: Boolean!
  author: User!              # Non-null relationship
  comments: [Comment!]!
  tags: [Tag!]!
  viewCount: Int!
  createdAt: DateTime!
  updatedAt: DateTime!
}

type Comment {
  id: ID!
  content: String!
  author: User!
  post: Post!
  parent: Comment            # Nullable for nested comments
  replies: [Comment!]!
  createdAt: DateTime!
}

type Tag {
  id: ID!
  name: String!
  posts: [Post!]!
}

# Custom scalar
scalar DateTime
```

### Input Types

```graphql
# Input types for mutations
input CreateUserInput {
  name: String!
  email: String!
  password: String!
  role: UserRole = USER     # Default value
}

input UpdateUserInput {
  name: String
  email: String
  bio: String
  # All fields optional for partial updates
}

input CreatePostInput {
  title: String!
  content: String!
  published: Boolean = false
  tagIds: [ID!]!
}

input UpdatePostInput {
  title: String
  content: String
  published: Boolean
  tagIds: [ID!]
}

# Pagination input
input PaginationInput {
  cursor: String
  limit: Int = 20
}

# Filter input
input PostFilterInput {
  authorId: ID
  published: Boolean
  tagIds: [ID!]
  search: String
  dateFrom: DateTime
  dateTo: DateTime
}

# Sort input
enum PostSortField {
  CREATED_AT
  UPDATED_AT
  TITLE
  VIEW_COUNT
}

enum SortOrder {
  ASC
  DESC
}

input PostSortInput {
  field: PostSortField!
  order: SortOrder = DESC
}
```

### Queries

```graphql
type Query {
  # Single resources
  user(id: ID!): User
  post(id: ID!): Post
  me: User!                 # Current user (requires auth)

  # Collections
  users(
    limit: Int = 20
    cursor: String
  ): UserConnection!

  posts(
    filter: PostFilterInput
    sort: PostSortInput
    pagination: PaginationInput
  ): PostConnection!

  # Search
  searchPosts(query: String!): [Post!]!
  searchUsers(query: String!): [User!]!
}
```

### Mutations

```graphql
type Mutation {
  # User mutations
  createUser(input: CreateUserInput!): User!
  updateUser(id: ID!, input: UpdateUserInput!): User!
  deleteUser(id: ID!): Boolean!

  # Post mutations
  createPost(input: CreatePostInput!): Post!
  updatePost(id: ID!, input: UpdatePostInput!): Post!
  deletePost(id: ID!): Boolean!
  publishPost(id: ID!): Post!

  # Relationship mutations
  followUser(userId: ID!): User!
  unfollowUser(userId: ID!): User!
  likePost(postId: ID!): Post!
  unlikePost(postId: ID!): Post!

  # Comment mutations
  createComment(postId: ID!, content: String!, parentId: ID): Comment!
  updateComment(id: ID!, content: String!): Comment!
  deleteComment(id: ID!): Boolean!
}
```

### Subscriptions

```graphql
type Subscription {
  # Real-time updates
  postCreated: Post!
  postUpdated(postId: ID!): Post!
  commentAdded(postId: ID!): Comment!

  # User-specific
  notificationReceived: Notification!
}
```

### Connection Pattern (Relay-style Pagination)

```graphql
type UserConnection {
  edges: [UserEdge!]!
  pageInfo: PageInfo!
  totalCount: Int!
}

type UserEdge {
  node: User!
  cursor: String!
}

type PageInfo {
  hasNextPage: Boolean!
  hasPreviousPage: Boolean!
  startCursor: String
  endCursor: String
}

# Same pattern for other types
type PostConnection {
  edges: [PostEdge!]!
  pageInfo: PageInfo!
  totalCount: Int!
}

type PostEdge {
  node: Post!
  cursor: String!
}
```

---

## Resolver Implementation

### Basic Resolvers

```typescript
// graphql/resolvers.ts
import { GraphQLError } from 'graphql';
import { Context } from './context';

export const resolvers = {
  Query: {
    user: async (_parent, { id }: { id: string }, context: Context) => {
      const user = await context.db.user.findUnique({
        where: { id },
      });

      if (!user) {
        throw new GraphQLError('User not found', {
          extensions: { code: 'NOT_FOUND' },
        });
      }

      return user;
    },

    users: async (
      _parent,
      { limit = 20, cursor }: { limit?: number; cursor?: string },
      context: Context
    ) => {
      const users = await context.db.user.findMany({
        take: limit + 1,
        ...(cursor && {
          cursor: { id: cursor },
          skip: 1,
        }),
        orderBy: { createdAt: 'desc' },
      });

      const hasNextPage = users.length > limit;
      const edges = (hasNextPage ? users.slice(0, -1) : users).map(user => ({
        node: user,
        cursor: user.id,
      }));

      return {
        edges,
        pageInfo: {
          hasNextPage,
          hasPreviousPage: !!cursor,
          startCursor: edges[0]?.cursor,
          endCursor: edges[edges.length - 1]?.cursor,
        },
        totalCount: await context.db.user.count(),
      };
    },

    me: async (_parent, _args, context: Context) => {
      if (!context.user) {
        throw new GraphQLError('Unauthorized', {
          extensions: { code: 'UNAUTHORIZED' },
        });
      }

      return context.user;
    },
  },

  Mutation: {
    createUser: async (
      _parent,
      { input }: { input: CreateUserInput },
      context: Context
    ) => {
      // Validate input
      const validation = validateUserInput(input);
      if (!validation.success) {
        throw new GraphQLError('Validation failed', {
          extensions: {
            code: 'VALIDATION_ERROR',
            errors: validation.errors,
          },
        });
      }

      // Hash password
      const hashedPassword = await hashPassword(input.password);

      // Create user
      try {
        const user = await context.db.user.create({
          data: {
            ...input,
            password: hashedPassword,
          },
        });

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

    updateUser: async (
      _parent,
      { id, input }: { id: string; input: UpdateUserInput },
      context: Context
    ) => {
      // Check authorization
      if (!context.user || context.user.id !== id) {
        throw new GraphQLError('Forbidden', {
          extensions: { code: 'FORBIDDEN' },
        });
      }

      const user = await context.db.user.update({
        where: { id },
        data: input,
      });

      return user;
    },

    deleteUser: async (
      _parent,
      { id }: { id: string },
      context: Context
    ) => {
      // Check authorization (admin only)
      if (!context.user || context.user.role !== 'ADMIN') {
        throw new GraphQLError('Forbidden', {
          extensions: { code: 'FORBIDDEN' },
        });
      }

      await context.db.user.delete({ where: { id } });
      return true;
    },
  },

  User: {
    // Field resolver for posts
    posts: async (parent, _args, context: Context) => {
      return context.db.post.findMany({
        where: { authorId: parent.id },
      });
    },

    // Field resolver with DataLoader
    posts: async (parent, _args, context: Context) => {
      return context.loaders.postsByUserId.load(parent.id);
    },
  },
};
```

---

## N+1 Query Problem Solution

### The Problem

```typescript
// Query
query {
  users {
    id
    name
    posts {
      id
      title
    }
  }
}

// Without DataLoader: N+1 queries
// 1 query for users
// N queries for posts (one per user)
// Total: 1 + N queries
```

### Solution: DataLoader

```typescript
// lib/loaders.ts
import DataLoader from 'dataloader';
import { PrismaClient } from '@prisma/client';

export function createLoaders(db: PrismaClient) {
  // Posts by user ID
  const postsByUserId = new DataLoader(async (userIds: readonly string[]) => {
    const posts = await db.post.findMany({
      where: { authorId: { in: [...userIds] } },
    });

    const postsByUserId = new Map<string, Post[]>();
    for (const userId of userIds) {
      postsByUserId.set(userId, []);
    }

    for (const post of posts) {
      postsByUserId.get(post.authorId)!.push(post);
    }

    return userIds.map(userId => postsByUserId.get(userId) || []);
  });

  // User by ID
  const userById = new DataLoader(async (ids: readonly string[]) => {
    const users = await db.user.findMany({
      where: { id: { in: [...ids] } },
    });

    const usersById = new Map(users.map(user => [user.id, user]));
    return ids.map(id => usersById.get(id) || null);
  });

  // Comments by post ID
  const commentsByPostId = new DataLoader(async (postIds: readonly string[]) => {
    const comments = await db.comment.findMany({
      where: { postId: { in: [...postIds] } },
    });

    const commentsByPostId = new Map<string, Comment[]>();
    for (const postId of postIds) {
      commentsByPostId.set(postId, []);
    }

    for (const comment of comments) {
      commentsByPostId.get(comment.postId)!.push(comment);
    }

    return postIds.map(postId => commentsByPostId.get(postId) || []);
  });

  return {
    postsByUserId,
    userById,
    commentsByPostId,
  };
}

// graphql/context.ts
export async function createContext({ req }) {
  const user = await getUserFromRequest(req);

  return {
    user,
    db: prisma,
    loaders: createLoaders(prisma),
  };
}

// Resolvers using DataLoader
export const resolvers = {
  User: {
    posts: (parent, _args, context) => {
      return context.loaders.postsByUserId.load(parent.id);
    },
  },

  Post: {
    author: (parent, _args, context) => {
      return context.loaders.userById.load(parent.authorId);
    },
    comments: (parent, _args, context) => {
      return context.loaders.commentsByPostId.load(parent.id);
    },
  },
};
```

**Result**: 1 query for users + 1 batched query for all posts = 2 queries total!

---

## Input Validation

```typescript
import { z } from 'zod';
import { GraphQLError } from 'graphql';

// Define schemas
const createUserSchema = z.object({
  name: z.string().min(2).max(100),
  email: z.string().email(),
  password: z.string().min(8).max(128)
    .regex(/[A-Z]/, 'Must contain uppercase')
    .regex(/[a-z]/, 'Must contain lowercase')
    .regex(/[0-9]/, 'Must contain number'),
  role: z.enum(['ADMIN', 'USER', 'GUEST']).default('USER'),
});

const updateUserSchema = z.object({
  name: z.string().min(2).max(100).optional(),
  email: z.string().email().optional(),
  bio: z.string().max(500).optional(),
});

// Validation helper
function validate<T>(schema: z.ZodSchema<T>, data: unknown): T {
  const result = schema.safeParse(data);

  if (!result.success) {
    throw new GraphQLError('Validation failed', {
      extensions: {
        code: 'VALIDATION_ERROR',
        errors: result.error.format(),
      },
    });
  }

  return result.data;
}

// Use in resolvers
export const resolvers = {
  Mutation: {
    createUser: async (_parent, { input }, context) => {
      const validatedInput = validate(createUserSchema, input);

      const user = await context.db.user.create({
        data: validatedInput,
      });

      return user;
    },

    updateUser: async (_parent, { id, input }, context) => {
      const validatedInput = validate(updateUserSchema, input);

      const user = await context.db.user.update({
        where: { id },
        data: validatedInput,
      });

      return user;
    },
  },
};
```

---

## Authentication & Authorization

### Context-based Auth

```typescript
// graphql/context.ts
import { PrismaClient } from '@prisma/client';
import jwt from 'jsonwebtoken';

export async function createContext({ req }) {
  const token = req.headers.authorization?.replace('Bearer ', '');

  let user = null;
  if (token) {
    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET!);
      user = await prisma.user.findUnique({
        where: { id: decoded.userId },
      });
    } catch (error) {
      // Invalid token - user remains null
    }
  }

  return {
    user,
    db: prisma,
    loaders: createLoaders(prisma),
  };
}

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

  Mutation: {
    createPost: async (_parent, { input }, context) => {
      if (!context.user) {
        throw new GraphQLError('Unauthorized', {
          extensions: { code: 'UNAUTHORIZED' },
        });
      }

      const post = await context.db.post.create({
        data: {
          ...input,
          authorId: context.user.id,
        },
      });

      return post;
    },

    deletePost: async (_parent, { id }, context) => {
      if (!context.user) {
        throw new GraphQLError('Unauthorized', {
          extensions: { code: 'UNAUTHORIZED' },
        });
      }

      const post = await context.db.post.findUnique({ where: { id } });

      if (!post) {
        throw new GraphQLError('Post not found', {
          extensions: { code: 'NOT_FOUND' },
        });
      }

      // Check ownership or admin
      if (post.authorId !== context.user.id && context.user.role !== 'ADMIN') {
        throw new GraphQLError('Forbidden', {
          extensions: { code: 'FORBIDDEN' },
        });
      }

      await context.db.post.delete({ where: { id } });
      return true;
    },
  },
};
```

### Auth Directives

```graphql
directive @auth(requires: UserRole = USER) on FIELD_DEFINITION

type Mutation {
  createPost(input: CreatePostInput!): Post! @auth
  deleteUser(id: ID!): Boolean! @auth(requires: ADMIN)
}
```

```typescript
// Directive implementation
import { mapSchema, getDirective, MapperKind } from '@graphql-tools/utils';

export function authDirective(schema: GraphQLSchema) {
  return mapSchema(schema, {
    [MapperKind.OBJECT_FIELD]: (fieldConfig) => {
      const authDirective = getDirective(schema, fieldConfig, 'auth')?.[0];
      if (authDirective) {
        const { requires } = authDirective;
        const { resolve = defaultFieldResolver } = fieldConfig;

        fieldConfig.resolve = async (source, args, context, info) => {
          if (!context.user) {
            throw new GraphQLError('Unauthorized', {
              extensions: { code: 'UNAUTHORIZED' },
            });
          }

          if (requires && context.user.role !== requires) {
            throw new GraphQLError('Forbidden', {
              extensions: { code: 'FORBIDDEN' },
            });
          }

          return resolve(source, args, context, info);
        };
      }

      return fieldConfig;
    },
  });
}
```

---

## Error Handling

```typescript
export const ErrorCodes = {
  UNAUTHENTICATED: 'UNAUTHENTICATED',
  UNAUTHORIZED: 'UNAUTHORIZED',
  FORBIDDEN: 'FORBIDDEN',
  NOT_FOUND: 'NOT_FOUND',
  VALIDATION_ERROR: 'VALIDATION_ERROR',
  DUPLICATE_RESOURCE: 'DUPLICATE_RESOURCE',
  INTERNAL_ERROR: 'INTERNAL_ERROR',
} as const;

// Custom error class
export class AppError extends GraphQLError {
  constructor(message: string, code: string, data?: any) {
    super(message, {
      extensions: {
        code,
        ...(data && { data }),
      },
    });
  }
}

// Helper functions
export function throwNotFound(resource: string, id: string): never {
  throw new AppError(`${resource} not found`, ErrorCodes.NOT_FOUND, { id });
}

export function throwUnauthorized(message = 'Unauthorized'): never {
  throw new AppError(message, ErrorCodes.UNAUTHORIZED);
}

export function throwForbidden(message = 'Forbidden'): never {
  throw new AppError(message, ErrorCodes.FORBIDDEN);
}

// Usage in resolvers
export const resolvers = {
  Query: {
    user: async (_parent, { id }, context) => {
      const user = await context.db.user.findUnique({ where: { id } });
      if (!user) throwNotFound('User', id);
      return user;
    },
  },
};
```

---

## Subscriptions

```typescript
// graphql/schema.ts
import { createPubSub } from '@graphql-yoga/subscription';

const pubsub = createPubSub();

export const resolvers = {
  Mutation: {
    createPost: async (_parent, { input }, context) => {
      const post = await context.db.post.create({
        data: {
          ...input,
          authorId: context.user.id,
        },
      });

      // Publish event
      pubsub.publish('POST_CREATED', { postCreated: post });

      return post;
    },
  },

  Subscription: {
    postCreated: {
      subscribe: () => pubsub.subscribe('POST_CREATED'),
    },

    commentAdded: {
      subscribe: (_parent, { postId }) => {
        return pubsub.subscribe(`COMMENT_ADDED_${postId}`);
      },
    },
  },
};

// Client usage
subscription {
  postCreated {
    id
    title
    author {
      name
    }
  }
}
```

---

_Complete GraphQL API design reference for progressive disclosure_
