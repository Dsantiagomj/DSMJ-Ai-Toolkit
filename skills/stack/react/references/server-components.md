# Server Components - React

## Server Components Architecture

**React 19 philosophy**: Server Components by default, Client Components only when needed.

### When to Use Server Components

**Use Server Components for**:
- ✅ Data fetching
- ✅ Direct database access
- ✅ Reading from filesystem
- ✅ Static content rendering
- ✅ SEO-critical content
- ✅ Backend API calls

**Benefits**:
- Zero JavaScript sent to client
- Direct backend access (no API layer needed)
- Better performance
- Automatic code splitting
- Reduced bundle size

### Basic Server Component

```tsx
// app/dashboard/page.tsx
export default async function Dashboard() {
  const data = await fetchData() // Direct data fetching
  return <DashboardUI data={data} />
}
```

---

## Data Fetching Patterns

### Parallel Data Fetching

```tsx
export default async function ProductPage({ params }: { params: { id: string } }) {
  // Parallel data fetching
  const [product, reviews, recommendations] = await Promise.all([
    fetchProduct(params.id),
    fetchReviews(params.id),
    fetchRecommendations(params.id),
  ])

  return (
    <>
      <ProductDetails product={product} />
      <ReviewsList reviews={reviews} />
      <Recommendations items={recommendations} />
    </>
  )
}
```

### Sequential Data Fetching

```tsx
export default async function UserPage({ params }: { params: { id: string } }) {
  // First fetch user
  const user = await fetchUser(params.id)

  // Then fetch user-specific data
  const posts = await fetchUserPosts(user.id)

  return (
    <div>
      <UserProfile user={user} />
      <PostsList posts={posts} />
    </div>
  )
}
```

---

## Streaming with Suspense

### Basic Streaming

```tsx
import { Suspense } from 'react'

export default function Page() {
  return (
    <>
      <Header /> {/* Fast content renders immediately */}

      <Suspense fallback={<ProductSkeleton />}>
        <ProductDetails /> {/* Streams in when ready */}
      </Suspense>

      <Suspense fallback={<ReviewsSkeleton />}>
        <Reviews /> {/* Streams in independently */}
      </Suspense>
    </>
  )
}

async function ProductDetails() {
  const product = await fetchProduct() // Can be slow
  return <div>{product.name}</div>
}

async function Reviews() {
  const reviews = await fetchReviews() // Can be slow
  return <ReviewsList reviews={reviews} />
}
```

### Nested Suspense

```tsx
export default function DashboardPage() {
  return (
    <Suspense fallback={<PageSkeleton />}>
      <Dashboard />
    </Suspense>
  )
}

async function Dashboard() {
  const user = await fetchUser()

  return (
    <div>
      <UserHeader user={user} />

      <Suspense fallback={<StatsSkeleton />}>
        <Stats userId={user.id} />
      </Suspense>

      <Suspense fallback={<ActivitySkeleton />}>
        <Activity userId={user.id} />
      </Suspense>
    </div>
  )
}
```

---

## Server Actions

### Basic Server Action

```tsx
// app/actions.ts
'use server'

export async function createPost(formData: FormData) {
  const title = formData.get('title') as string
  const content = formData.get('content') as string

  await db.posts.create({ title, content })
  revalidatePath('/posts')
  redirect('/posts')
}

// app/posts/new/page.tsx
import { createPost } from '../actions'

export default function NewPost() {
  return (
    <form action={createPost}>
      <input name="title" required />
      <textarea name="content" required />
      <button type="submit">Create Post</button>
    </form>
  )
}
```

### Server Action with Client Component

```tsx
// app/actions.ts
'use server'

export async function updateUser(id: string, data: UserData) {
  await db.users.update(id, data)
  revalidatePath(`/users/${id}`)
}

// app/users/[id]/edit-form.tsx
'use client'

import { updateUser } from '@/app/actions'
import { useState, useTransition } from 'react'

export function EditForm({ user }: { user: User }) {
  const [name, setName] = useState(user.name)
  const [isPending, startTransition] = useTransition()

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    startTransition(async () => {
      await updateUser(user.id, { name })
    })
  }

  return (
    <form onSubmit={handleSubmit}>
      <input value={name} onChange={(e) => setName(e.target.value)} />
      <button disabled={isPending}>
        {isPending ? 'Saving...' : 'Save'}
      </button>
    </form>
  )
}
```

### Server Action with Validation

```tsx
'use server'

import { z } from 'zod'

const userSchema = z.object({
  name: z.string().min(2).max(50),
  email: z.string().email(),
  age: z.number().min(18).max(120),
})

export async function createUser(formData: FormData) {
  const rawData = {
    name: formData.get('name'),
    email: formData.get('email'),
    age: Number(formData.get('age')),
  }

  // Validate
  const result = userSchema.safeParse(rawData)
  if (!result.success) {
    return { error: result.error.flatten() }
  }

  // Create user
  const user = await db.users.create(result.data)
  revalidatePath('/users')
  return { success: true, user }
}
```

---

## Client/Server Composition

### Passing Server Components to Client Components

```tsx
// ✅ Good: Pass Server Component as children
'use client'

export function ClientWrapper({ children }: { children: React.ReactNode }) {
  const [isOpen, setIsOpen] = useState(false)

  return (
    <div onClick={() => setIsOpen(!isOpen)}>
      {isOpen && children}
    </div>
  )
}

// Usage in Server Component
export default async function Page() {
  const data = await fetchData()

  return (
    <ClientWrapper>
      {/* This remains a Server Component */}
      <ServerDataDisplay data={data} />
    </ClientWrapper>
  )
}
```

### Sharing Data Between Components

```tsx
// ❌ Bad: Prop drilling
export default async function Page() {
  const user = await fetchUser()

  return (
    <Layout user={user}>
      <Content user={user}>
        <Profile user={user} />
      </Content>
    </Layout>
  )
}

// ✅ Good: Fetch where needed
export default function Page() {
  return (
    <Layout>
      <Content>
        <Profile />
      </Content>
    </Layout>
  )
}

async function Profile() {
  const user = await fetchUser() // Cached automatically
  return <div>{user.name}</div>
}
```

---

## Caching and Revalidation

### Fetch Caching

```tsx
// Cached by default
const data = await fetch('https://api.example.com/data')

// Opt out of caching
const data = await fetch('https://api.example.com/data', {
  cache: 'no-store'
})

// Revalidate after 60 seconds
const data = await fetch('https://api.example.com/data', {
  next: { revalidate: 60 }
})

// Tag-based revalidation
const data = await fetch('https://api.example.com/data', {
  next: { tags: ['products'] }
})
```

### Revalidation Patterns

```tsx
'use server'

import { revalidatePath, revalidateTag } from 'next/cache'

// Revalidate specific path
export async function updateProduct(id: string, data: ProductData) {
  await db.products.update(id, data)
  revalidatePath(`/products/${id}`)
}

// Revalidate all product pages
export async function createProduct(data: ProductData) {
  await db.products.create(data)
  revalidatePath('/products')
}

// Revalidate by tag
export async function updateInventory() {
  await updateDatabase()
  revalidateTag('products')
}
```

---

## Loading and Error States

### Loading UI

```tsx
// app/dashboard/loading.tsx
export default function Loading() {
  return <DashboardSkeleton />
}

// app/dashboard/page.tsx
export default async function Dashboard() {
  const data = await fetchData() // Loading.tsx shows while this loads
  return <DashboardUI data={data} />
}
```

### Error Boundaries

```tsx
// app/dashboard/error.tsx
'use client'

export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  return (
    <div>
      <h2>Something went wrong!</h2>
      <p>{error.message}</p>
      <button onClick={() => reset()}>Try again</button>
    </div>
  )
}

// app/dashboard/page.tsx
export default async function Dashboard() {
  const data = await fetchData() // Errors caught by error.tsx
  return <DashboardUI data={data} />
}
```

---

## Common Patterns

### Database Queries

```tsx
import { prisma } from '@/lib/prisma'

export default async function UsersPage() {
  const users = await prisma.user.findMany({
    include: { posts: true },
    orderBy: { createdAt: 'desc' },
  })

  return <UsersList users={users} />
}
```

### Authentication

```tsx
import { auth } from '@/lib/auth'
import { redirect } from 'next/navigation'

export default async function ProtectedPage() {
  const session = await auth()

  if (!session) {
    redirect('/login')
  }

  return <div>Protected content for {session.user.name}</div>
}
```

### Dynamic Metadata

```tsx
export async function generateMetadata({ params }: { params: { id: string } }) {
  const product = await fetchProduct(params.id)

  return {
    title: product.name,
    description: product.description,
    openGraph: {
      images: [product.image],
    },
  }
}

export default async function ProductPage({ params }: { params: { id: string } }) {
  const product = await fetchProduct(params.id)
  return <ProductDetails product={product} />
}
```

---

## Migration Tips

### From useEffect to Server Components

```tsx
// ❌ Before: Client-side fetching
'use client'
import { useEffect, useState } from 'react'

export default function Posts() {
  const [posts, setPosts] = useState([])

  useEffect(() => {
    fetch('/api/posts')
      .then(res => res.json())
      .then(setPosts)
  }, [])

  return <PostsList posts={posts} />
}

// ✅ After: Server Component
export default async function Posts() {
  const posts = await fetchPosts()
  return <PostsList posts={posts} />
}
```

### From API Routes to Server Actions

```tsx
// ❌ Before: API route
// app/api/users/route.ts
export async function POST(request: Request) {
  const data = await request.json()
  const user = await db.users.create(data)
  return Response.json(user)
}

// Client component
const response = await fetch('/api/users', {
  method: 'POST',
  body: JSON.stringify(data)
})

// ✅ After: Server Action
'use server'

export async function createUser(data: UserData) {
  const user = await db.users.create(data)
  revalidatePath('/users')
  return user
}

// Usage
import { createUser } from './actions'
await createUser(data)
```
