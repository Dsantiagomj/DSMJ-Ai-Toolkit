# Optimization Techniques

Complete guide to code splitting, lazy loading, and caching.

---

## Code Splitting

```typescript
// Dynamic imports
const HeavyComponent = lazy(() => import('./HeavyComponent'));

function App() {
  return (
    <Suspense fallback={<div>Loading...</div>}>
      <HeavyComponent />
    </Suspense>
  );
}

// Route-based splitting (Next.js automatic)
// app/products/page.tsx - separate bundle
```

---

## Image Optimization

```html
<!-- Native lazy loading -->
<img src="/image.jpg" loading="lazy" width="800" height="600" />

<!-- Modern formats with fallbacks -->
<picture>
  <source srcset="/image.avif" type="image/avif" />
  <source srcset="/image.webp" type="image/webp" />
  <img src="/image.jpg" alt="Description" />
</picture>

<!-- Responsive images -->
<img
  srcset="/small.jpg 400w, /medium.jpg 800w, /large.jpg 1200w"
  sizes="(max-width: 600px) 400px, (max-width: 1000px) 800px, 1200px"
  src="/medium.jpg"
/>
```

---

## Bundle Optimization

```javascript
// ❌ Import entire library
import _ from 'lodash';

// ✅ Import only what you need
import debounce from 'lodash/debounce';

// ✅ Dynamic imports for heavy libraries
const Chart = lazy(() => import('chart.js'));
```

---

## Caching Strategies

```typescript
// HTTP Cache headers
export async function GET() {
  return new Response(JSON.stringify(data), {
    headers: {
      'Cache-Control': 'public, max-age=3600, s-maxage=86400',
    },
  });
}

// Client-side caching with SWR
import useSWR from 'swr';

const { data } = useSWR('/api/user', fetcher, {
  revalidateOnFocus: false,
  dedupingInterval: 60000,
});
```

---

_Maintained by dsmj-ai-toolkit_
