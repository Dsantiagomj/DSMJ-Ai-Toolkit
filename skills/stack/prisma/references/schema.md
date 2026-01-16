# Schema & Relations - Prisma

## Field Types

```prisma
model Example {
  // String types
  string     String
  optString  String?
  email      String        @unique
  slug       String        @db.VarChar(100)

  // Number types
  int        Int
  bigInt     BigInt
  float      Float
  decimal    Decimal

  // Boolean
  isActive   Boolean       @default(false)

  // DateTime
  createdAt  DateTime      @default(now())
  updatedAt  DateTime      @updatedAt

  // JSON
  metadata   Json?

  // Enums
  role       Role          @default(USER)

  // Arrays (PostgreSQL)
  tags       String[]
}

enum Role {
  USER
  ADMIN
  MODERATOR
}
```

## Relations

### One-to-One

```prisma
model User {
  id      String   @id @default(cuid())
  profile Profile?
}

model Profile {
  id     String @id @default(cuid())
  bio    String?
  user   User   @relation(fields: [userId], references: [id], onDelete: Cascade)
  userId String @unique
}
```

### One-to-Many

```prisma
model User {
  id    String @id @default(cuid())
  posts Post[]
}

model Post {
  id       String @id @default(cuid())
  author   User   @relation(fields: [authorId], references: [id])
  authorId String
  
  @@index([authorId])
}
```

### Many-to-Many (Explicit)

```prisma
model Post {
  id   String     @id @default(cuid())
  tags PostTag[]
}

model Tag {
  id    String    @id @default(cuid())
  posts PostTag[]
}

model PostTag {
  post   Post   @relation(fields: [postId], references: [id], onDelete: Cascade)
  postId String
  tag    Tag    @relation(fields: [tagId], references: [id], onDelete: Cascade)
  tagId  String
  
  @@id([postId, tagId])
}
```

### Many-to-Many (Implicit)

```prisma
model Post {
  id   String @id @default(cuid())
  tags Tag[]
}

model Tag {
  id    String @id @default(cuid())
  posts Post[]
}
```
