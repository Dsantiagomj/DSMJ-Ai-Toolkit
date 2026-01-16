# Advanced Queries - Prisma

## Pagination

### Offset-Based

```typescript
async function getPosts(page: number, pageSize: number) {
  const [posts, total] = await Promise.all([
    prisma.post.findMany({
      skip: (page - 1) * pageSize,
      take: pageSize,
      orderBy: { createdAt: 'desc' },
    }),
    prisma.post.count(),
  ]);

  return { posts, total, totalPages: Math.ceil(total / pageSize) };
}
```

### Cursor-Based

```typescript
async function getPostsCursor(cursor?: string, limit = 10) {
  const posts = await prisma.post.findMany({
    take: limit,
    ...(cursor && {
      skip: 1,
      cursor: { id: cursor },
    }),
    orderBy: { createdAt: 'desc' },
  });

  return {
    posts,
    nextCursor: posts.length === limit ? posts[posts.length - 1].id : null,
  };
}
```

## Filtering & Sorting

```typescript
const posts = await prisma.post.findMany({
  where: {
    AND: [
      { published: true },
      {
        OR: [
          { title: { contains: 'TypeScript', mode: 'insensitive' } },
          { content: { contains: 'TypeScript', mode: 'insensitive' } },
        ],
      },
    ],
    author: {
      posts: {
        some: { published: true },
      },
    },
    createdAt: {
      gte: new Date('2024-01-01'),
      lte: new Date('2024-12-31'),
    },
  },
  orderBy: [
    { published: 'desc' },
    { createdAt: 'desc' },
  ],
});
```

## Aggregations

```typescript
// Count, sum, avg, min, max
const stats = await prisma.post.aggregate({
  where: { published: true },
  _count: true,
  _avg: { viewCount: true },
  _sum: { viewCount: true },
  _min: { createdAt: true },
  _max: { createdAt: true },
});

// Group by
const userStats = await prisma.post.groupBy({
  by: ['authorId'],
  _count: { id: true },
  _avg: { viewCount: true },
  where: { published: true },
  orderBy: { _count: { id: 'desc' } },
});
```

## Transactions

```typescript
// Sequential operations
const result = await prisma.$transaction(async (tx) => {
  const user = await tx.user.create({
    data: { email: 'alice@example.com', name: 'Alice' },
  });

  const post = await tx.post.create({
    data: {
      title: 'First Post',
      authorId: user.id,
    },
  });

  return { user, post };
});

// Batch operations
const [deleteResult, createResult] = await prisma.$transaction([
  prisma.post.deleteMany({ where: { published: false } }),
  prisma.user.create({ data: { email: 'new@example.com' } }),
]);
```
