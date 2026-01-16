# Migrations & Best Practices - Prisma

## Migration Workflows

### Development

```bash
# Create migration
npx prisma migrate dev --name add_user_role

# Reset database
npx prisma migrate reset

# Generate client
npx prisma generate

# Push without migration (prototyping)
npx prisma db push
```

### Production

```bash
# Deploy migrations
npx prisma migrate deploy

# Check status
npx prisma migrate status
```

## Database Seeding

```typescript
// prisma/seed.ts
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  const alice = await prisma.user.upsert({
    where: { email: 'alice@example.com' },
    update: {},
    create: {
      email: 'alice@example.com',
      name: 'Alice',
      posts: {
        create: [
          { title: 'First Post', published: true },
        ],
      },
    },
  });
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
```

```json
// package.json
{
  "prisma": {
    "seed": "tsx prisma/seed.ts"
  }
}
```

## Best Practices

### Avoid N+1 Queries

```typescript
// ❌ Bad
const users = await prisma.user.findMany();
for (const user of users) {
  const posts = await prisma.post.findMany({ where: { authorId: user.id } });
}

// ✅ Good
const users = await prisma.user.findMany({
  include: { posts: true },
});
```

### Select Only Needed Fields

```typescript
// ✅ Good
const user = await prisma.user.findUnique({
  where: { id: userId },
  select: {
    id: true,
    name: true,
    email: true,
  },
});
```

### Error Handling

```typescript
import { Prisma } from '@prisma/client';

try {
  await prisma.user.create({ data });
} catch (error) {
  if (error instanceof Prisma.PrismaClientKnownRequestError) {
    if (error.code === 'P2002') {
      throw new Error('Email already exists');
    }
  }
  throw error;
}
```

### Performance

```prisma
// Add indexes
model Post {
  id        String   @id @default(cuid())
  authorId  String
  published Boolean
  
  @@index([authorId])
  @@index([published])
  @@index([authorId, published])
}
```
