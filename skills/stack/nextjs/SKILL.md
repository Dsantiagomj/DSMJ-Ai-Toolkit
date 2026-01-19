---
name: nextjs
description: >
  Next.js 15 patterns for App Router, Server Components, streaming, and modern React applications.
  Trigger: When building Next.js apps, when using App Router, when implementing Server Components,
  when setting up API routes, when configuring middleware, when optimizing Next.js performance.
tags: [nextjs, react, app-router, server-components, streaming, rsc, ssr, ssg, middleware]
author: dsmj-ai-toolkit
metadata:
  version: "1.0"
  last_updated: "2026-01-19"
  category: stack
  auto_invoke: "When working with Next.js applications"
  stack_category: frontend
  progressive_disclosure: true
references:
  - name: App Router Patterns
    url: ./references/app-router.md
    type: local
  - name: Data Fetching
    url: ./references/data-fetching.md
    type: local
---

# Next.js - App Router & Server Components

**Modern patterns for Next.js 15 with App Router, Server Components, and streaming**

---

## When to Use This Skill

**Use this skill when**:
- Building Next.js 15+ applications with App Router
- Implementing Server Components and Client Components
- Setting up API routes (Route Handlers)
- Configuring middleware for auth, redirects, or rewrites
- Optimizing performance with streaming and suspense
- Implementing data fetching patterns

**Don't use this skill when**:
- Using Pages Router (legacy pattern)
- Building pure React SPA (no Next.js)
- Working with other frameworks (Remix, Astro)

---

## Critical Patterns

### Pattern 1: Server Components vs Client Components

**When**: Deciding where to render components

```tsx
// ✅ GOOD: Server Component (default) - no "use client"
// app/products/page.tsx
async function ProductsPage() {
  const products = await db.product.findMany(); // Direct DB access

  return (
    <div>
      {products.map(p => <ProductCard key={p.id} product={p} />)}
    </div>
  );
}

// ✅ GOOD: Client Component - only when needed
// components/add-to-cart.tsx
"use client";

import { useState } from 'react';

export function AddToCart({ productId }: { productId: string }) {
  const [loading, setLoading] = useState(false);

  async function handleClick() {
    setLoading(true);
    await addToCart(productId);
    setLoading(false);
  }

  return <button onClick={handleClick} disabled={loading}>Add to Cart</button>;
}

// ❌ BAD: Adding "use client" unnecessarily
"use client"; // Don't add this if component doesn't use hooks/events
export function ProductCard({ product }) {
  return <div>{product.name}</div>;
}
```

**Rule of thumb**: Keep components Server by default. Only add `"use client"` when you need:
- `useState`, `useEffect`, or other hooks
- Event handlers (`onClick`, `onChange`)
- Browser-only APIs (`window`, `localStorage`)

### Pattern 2: Route Handlers (API Routes)

**When**: Building API endpoints in App Router

```tsx
// ✅ GOOD: app/api/products/route.ts
import { NextResponse } from 'next/server';

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const category = searchParams.get('category');

  const products = await db.product.findMany({
    where: category ? { category } : undefined
  });

  return NextResponse.json(products);
}

export async function POST(request: Request) {
  const body = await request.json();

  // Validate input
  const validated = productSchema.safeParse(body);
  if (!validated.success) {
    return NextResponse.json(
      { error: validated.error.flatten() },
      { status: 400 }
    );
  }

  const product = await db.product.create({ data: validated.data });
  return NextResponse.json(product, { status: 201 });
}

// ❌ BAD: Using pages/api pattern in app directory
// pages/api/products.ts - This is the old pattern!
export default function handler(req, res) {
  res.json({ products: [] });
}
```

### Pattern 3: Streaming with Suspense

**When**: Loading data progressively for better UX

```tsx
// ✅ GOOD: Stream slow data with Suspense
// app/dashboard/page.tsx
import { Suspense } from 'react';

export default function DashboardPage() {
  return (
    <div>
      <h1>Dashboard</h1>

      {/* Fast content renders immediately */}
      <QuickStats />

      {/* Slow content streams in with loading state */}
      <Suspense fallback={<RevenueChartSkeleton />}>
        <RevenueChart />
      </Suspense>

      <Suspense fallback={<RecentOrdersSkeleton />}>
        <RecentOrders />
      </Suspense>
    </div>
  );
}

// Server Component with slow data fetch
async function RevenueChart() {
  const data = await fetchRevenueData(); // Slow API call
  return <Chart data={data} />;
}

// ❌ BAD: Blocking entire page on slow data
async function DashboardPage() {
  const [stats, revenue, orders] = await Promise.all([
    fetchStats(),
    fetchRevenueData(), // Slow!
    fetchRecentOrders() // Also slow!
  ]);

  // User waits for ALL data before seeing anything
  return <div>...</div>;
}
```

### Pattern 4: Middleware for Auth & Redirects

**When**: Protecting routes or modifying requests

```tsx
// ✅ GOOD: middleware.ts (root of project)
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

export function middleware(request: NextRequest) {
  const token = request.cookies.get('auth-token');
  const isAuthPage = request.nextUrl.pathname.startsWith('/login');
  const isProtectedRoute = request.nextUrl.pathname.startsWith('/dashboard');

  // Redirect to login if not authenticated
  if (isProtectedRoute && !token) {
    return NextResponse.redirect(new URL('/login', request.url));
  }

  // Redirect to dashboard if already logged in
  if (isAuthPage && token) {
    return NextResponse.redirect(new URL('/dashboard', request.url));
  }

  return NextResponse.next();
}

export const config = {
  matcher: ['/dashboard/:path*', '/login'],
};

// ❌ BAD: Checking auth in every page component
async function DashboardPage() {
  const session = await getSession();
  if (!session) redirect('/login'); // Too late, page already loaded
  // ...
}
```

### Pattern 5: Server Actions

**When**: Mutating data from Server Components

```tsx
// ✅ GOOD: Server Action in separate file
// app/actions/products.ts
"use server";

import { revalidatePath } from 'next/cache';
import { z } from 'zod';

const schema = z.object({
  name: z.string().min(1),
  price: z.number().positive(),
});

export async function createProduct(formData: FormData) {
  const validated = schema.safeParse({
    name: formData.get('name'),
    price: Number(formData.get('price')),
  });

  if (!validated.success) {
    return { error: validated.error.flatten() };
  }

  await db.product.create({ data: validated.data });
  revalidatePath('/products');
  return { success: true };
}

// Usage in Server Component
// app/products/new/page.tsx
import { createProduct } from '@/app/actions/products';

export default function NewProductPage() {
  return (
    <form action={createProduct}>
      <input name="name" required />
      <input name="price" type="number" required />
      <button type="submit">Create</button>
    </form>
  );
}

// ❌ BAD: API route for simple mutations
// Don't create /api/products POST just to call from form
```

---

## Code Examples

### Example 1: Dynamic Route with Params

```tsx
// app/products/[id]/page.tsx
import { notFound } from 'next/navigation';

interface Props {
  params: Promise<{ id: string }>;
}

export default async function ProductPage({ params }: Props) {
  const { id } = await params;

  const product = await db.product.findUnique({ where: { id } });

  if (!product) {
    notFound(); // Renders not-found.tsx
  }

  return (
    <div>
      <h1>{product.name}</h1>
      <p>${product.price}</p>
    </div>
  );
}

// Generate static params for SSG
export async function generateStaticParams() {
  const products = await db.product.findMany({ select: { id: true } });
  return products.map(p => ({ id: p.id }));
}
```

### Example 2: Parallel Routes with Loading States

```tsx
// app/dashboard/layout.tsx
export default function DashboardLayout({
  children,
  analytics,
  team,
}: {
  children: React.ReactNode;
  analytics: React.ReactNode;
  team: React.ReactNode;
}) {
  return (
    <div className="grid grid-cols-2 gap-4">
      <div>{children}</div>
      <div>{analytics}</div>
      <div className="col-span-2">{team}</div>
    </div>
  );
}

// app/dashboard/@analytics/page.tsx
export default async function AnalyticsSlot() {
  const data = await fetchAnalytics();
  return <AnalyticsChart data={data} />;
}

// app/dashboard/@analytics/loading.tsx
export default function AnalyticsLoading() {
  return <Skeleton className="h-64" />;
}
```

### Example 3: Error Handling

```tsx
// app/products/error.tsx
"use client";

export default function ProductsError({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  return (
    <div className="p-4 border border-red-500 rounded">
      <h2>Something went wrong!</h2>
      <p>{error.message}</p>
      <button onClick={reset}>Try again</button>
    </div>
  );
}

// app/products/not-found.tsx
export default function ProductNotFound() {
  return (
    <div className="p-4">
      <h2>Product Not Found</h2>
      <p>The product you're looking for doesn't exist.</p>
    </div>
  );
}
```

---

## Anti-Patterns

### Don't: Fetch Data in Client Components

```tsx
// ❌ BAD: Fetching in Client Component
"use client";

export function ProductList() {
  const [products, setProducts] = useState([]);

  useEffect(() => {
    fetch('/api/products').then(r => r.json()).then(setProducts);
  }, []);

  return <div>{/* render products */}</div>;
}

// ✅ GOOD: Fetch in Server Component, pass to Client
async function ProductsPage() {
  const products = await db.product.findMany();
  return <ProductList products={products} />;
}
```

### Don't: Pass Functions to Client Components

```tsx
// ❌ BAD: Passing server function directly
async function Page() {
  async function handleSubmit() {
    "use server";
    await db.product.create({ data });
  }

  return <ClientForm onSubmit={handleSubmit} />; // Won't work!
}

// ✅ GOOD: Use Server Actions properly
import { createProduct } from '@/app/actions';

function Page() {
  return <form action={createProduct}>...</form>;
}
```

### Don't: Over-use "use client"

```tsx
// ❌ BAD: Making everything a Client Component
"use client"; // at the top of every file

// ✅ GOOD: Push "use client" to leaf components
// Keep pages and layouts as Server Components
// Only add "use client" to interactive parts
```

---

## Quick Reference

| Task | Pattern | Example |
|------|---------|---------|
| Protected route | Middleware | `middleware.ts` with matcher |
| API endpoint | Route Handler | `app/api/x/route.ts` |
| Form submission | Server Action | `"use server"` function |
| Loading state | Suspense | `<Suspense fallback={...}>` |
| 404 page | not-found.tsx | `notFound()` function |
| Error handling | error.tsx | Client Component with reset |
| Dynamic route | [param] folder | `app/posts/[id]/page.tsx` |
| Parallel data | Parallel routes | `@slot` folders |

---

## Resources

**Official Documentation**:
- [Next.js App Router](https://nextjs.org/docs/app)
- [Server Components](https://nextjs.org/docs/app/building-your-application/rendering/server-components)

**Related Skills**:
- **react**: React patterns and hooks
- **typescript**: Type safety patterns
- **api-design**: API route design

**References**:
- [App Router Patterns](./references/app-router.md)
- [Data Fetching Patterns](./references/data-fetching.md)

---

## Keywords

`nextjs`, `next.js`, `app-router`, `server-components`, `rsc`, `streaming`, `suspense`, `middleware`, `route-handlers`, `server-actions`, `ssr`, `ssg`, `isr`
