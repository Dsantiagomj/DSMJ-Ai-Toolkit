---
name: performance
domain: frontend
description: >
  Web performance optimization and Core Web Vitals. Covers LCP, FID, CLS, code splitting, lazy loading, caching strategies, image optimization, and performance monitoring.
  Trigger: When optimizing performance, when improving Core Web Vitals, when implementing code splitting, when optimizing images, when setting up caching, when monitoring performance metrics.
version: 1.0.0
tags: [performance, core-web-vitals, optimization, caching, lazy-loading, bundle-optimization]
metadata:
  version: "1.0"
  last_updated: "2026-01-17"
  category: domain
references:
  - name: Web.dev Learn Performance
    url: https://web.dev/learn/performance
    type: documentation
  - name: Web Vitals
    url: https://github.com/GoogleChrome/web-vitals
    type: documentation
  - name: Core Web Vitals
    url: https://web.dev/vitals/
    type: documentation
---

# Performance - Web Optimization & Core Web Vitals

**Build fast, responsive web experiences**

---

## What This Skill Covers

This skill provides guidance on:
- **Core Web Vitals** (LCP, FID/INP, CLS)
- **Code splitting** and lazy loading
- **Image optimization** and lazy loading
- **Caching strategies** (browser, CDN, service workers)
- **Bundle optimization** (tree shaking, minification)
- **Performance monitoring** and measurement
- **Resource hints** (preload, prefetch, preconnect)

---

## Core Web Vitals

Google's Core Web Vitals are key metrics for user experience:

### LCP - Largest Contentful Paint

**What**: Time until largest content element is rendered.
**Target**: < 2.5 seconds (Good), < 4.0 seconds (Needs Improvement)

**Common LCP elements**:
- Hero images
- Large text blocks
- Video thumbnails

**How to optimize**:

```html
<!-- 1. Prioritize LCP image loading -->
<img
  src="/hero.jpg"
  alt="Hero image"
  fetchpriority="high"
  loading="eager"
/>

<!-- 2. Preload critical resources -->
<link rel="preload" href="/hero.jpg" as="image" />
<link rel="preload" href="/critical.css" as="style" />
<link rel="preload" href="/font.woff2" as="font" type="font/woff2" crossorigin />

<!-- 3. Use responsive images -->
<picture>
  <source
    media="(min-width: 1200px)"
    srcset="/hero-large.webp"
    type="image/webp"
  />
  <source
    media="(min-width: 768px)"
    srcset="/hero-medium.webp"
    type="image/webp"
  />
  <img
    src="/hero-small.jpg"
    alt="Hero image"
    width="800"
    height="600"
    fetchpriority="high"
  />
</picture>
```

**Server-side**:
```typescript
// Optimize server response time
// Use CDN for static assets
// Enable compression (gzip/brotli)
// Implement caching headers

// Next.js example: Optimize images
import Image from 'next/image';

function Hero() {
  return (
    <Image
      src="/hero.jpg"
      alt="Hero image"
      width={1200}
      height={600}
      priority // Preload this image
      quality={90}
    />
  );
}
```

---

### FID/INP - First Input Delay / Interaction to Next Paint

**FID (being replaced by INP)**:
- **What**: Time from first interaction to browser response
- **Target**: < 100ms (Good), < 300ms (Needs Improvement)

**INP (new metric)**:
- **What**: Latency of ALL interactions throughout page lifecycle
- **Target**: < 200ms (Good), < 500ms (Needs Improvement)

**How to optimize**:

```javascript
// 1. Break up long tasks (use setTimeout or requestIdleCallback)
function processLargeDataset(data) {
  const chunks = chunkArray(data, 100);

  function processChunk(index) {
    if (index >= chunks.length) return;

    // Process one chunk
    chunks[index].forEach(item => processItem(item));

    // Schedule next chunk
    setTimeout(() => processChunk(index + 1), 0);
  }

  processChunk(0);
}

// 2. Debounce expensive operations
function debounce(func, wait) {
  let timeout;
  return function executedFunction(...args) {
    clearTimeout(timeout);
    timeout = setTimeout(() => func(...args), wait);
  };
}

const handleSearch = debounce((query) => {
  fetchSearchResults(query);
}, 300);

// 3. Use Web Workers for heavy computation
const worker = new Worker('/worker.js');

worker.postMessage({ data: largeDataset });

worker.onmessage = (event) => {
  const result = event.data;
  updateUI(result);
};

// worker.js
self.onmessage = (event) => {
  const result = processData(event.data.data);
  self.postMessage(result);
};

// 4. Optimize event handlers
// Use event delegation instead of many listeners
document.getElementById('list').addEventListener('click', (e) => {
  if (e.target.matches('button')) {
    handleButtonClick(e.target);
  }
});
```

---

### CLS - Cumulative Layout Shift

**What**: Measure of visual stability (unexpected layout shifts).
**Target**: < 0.1 (Good), < 0.25 (Needs Improvement)

**Common causes**:
- Images without dimensions
- Ads, embeds, iframes without reserved space
- FOIT/FOUT (Flash of Invisible/Unstyled Text)
- Dynamically injected content

**How to optimize**:

```html
<!-- 1. Always specify image dimensions -->
<img
  src="/image.jpg"
  alt="Description"
  width="800"
  height="600"
/>

<!-- 2. Use aspect-ratio for responsive images -->
<style>
  .image-container {
    aspect-ratio: 16 / 9;
    width: 100%;
  }

  .image-container img {
    width: 100%;
    height: 100%;
    object-fit: cover;
  }
</style>

<!-- 3. Reserve space for ads/embeds -->
<div style="min-height: 250px;">
  <!-- Ad slot -->
</div>

<!-- 4. Preload fonts to avoid FOIT -->
<link
  rel="preload"
  href="/fonts/font.woff2"
  as="font"
  type="font/woff2"
  crossorigin
/>

<style>
  /* Use font-display to control font loading */
  @font-face {
    font-family: 'CustomFont';
    src: url('/fonts/font.woff2') format('woff2');
    font-display: swap; /* Show fallback immediately, swap when loaded */
  }
</style>

<!-- 5. Avoid inserting content above existing content -->
```

```typescript
// React: Avoid layout shifts when loading data
function ProductList() {
  const [products, setProducts] = useState([]);
  const [isLoading, setIsLoading] = useState(true);

  // ❌ Bad: Content jumps when data loads
  if (isLoading) return null;

  // ✅ Good: Show skeleton/placeholder
  if (isLoading) {
    return (
      <div className="grid">
        {[...Array(6)].map((_, i) => (
          <div key={i} className="skeleton" style={{ height: '300px' }} />
        ))}
      </div>
    );
  }

  return (
    <div className="grid">
      {products.map(product => (
        <ProductCard key={product.id} product={product} />
      ))}
    </div>
  );
}
```

---

## Code Splitting and Lazy Loading

### Dynamic Imports

```typescript
// ❌ Bad: Load everything upfront
import HeavyComponent from './HeavyComponent';
import ChartLibrary from './ChartLibrary';

// ✅ Good: Load on demand
const HeavyComponent = lazy(() => import('./HeavyComponent'));
const ChartLibrary = lazy(() => import('./ChartLibrary'));

function App() {
  const [showChart, setShowChart] = useState(false);

  return (
    <div>
      <Suspense fallback={<div>Loading...</div>}>
        {showChart && <ChartLibrary />}
      </Suspense>
    </div>
  );
}
```

### Route-based Code Splitting

```typescript
// Next.js: Automatic code splitting per route
// Each page is a separate bundle

// app/products/page.tsx - Only loaded when visiting /products
export default function ProductsPage() {
  return <div>Products</div>;
}

// React Router: Manual code splitting
import { lazy, Suspense } from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';

const Home = lazy(() => import('./pages/Home'));
const Products = lazy(() => import('./pages/Products'));
const About = lazy(() => import('./pages/About'));

function App() {
  return (
    <BrowserRouter>
      <Suspense fallback={<div>Loading...</div>}>
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/products" element={<Products />} />
          <Route path="/about" element={<About />} />
        </Routes>
      </Suspense>
    </BrowserRouter>
  );
}
```

---

## Image Optimization

### Lazy Loading Images

```html
<!-- Native lazy loading -->
<img
  src="/image.jpg"
  alt="Description"
  loading="lazy"
  width="800"
  height="600"
/>

<!-- Intersection Observer (more control) -->
<img
  data-src="/image.jpg"
  alt="Description"
  class="lazy"
/>

<script>
  const imageObserver = new IntersectionObserver((entries, observer) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        const img = entry.target;
        img.src = img.dataset.src;
        img.classList.add('loaded');
        observer.unobserve(img);
      }
    });
  });

  document.querySelectorAll('img.lazy').forEach(img => {
    imageObserver.observe(img);
  });
</script>
```

### Modern Image Formats

```html
<!-- Use WebP/AVIF with fallbacks -->
<picture>
  <source srcset="/image.avif" type="image/avif" />
  <source srcset="/image.webp" type="image/webp" />
  <img src="/image.jpg" alt="Description" />
</picture>

<!-- Next.js Image component (automatic optimization) -->
<Image
  src="/image.jpg"
  alt="Description"
  width={800}
  height={600}
  quality={85}
  placeholder="blur"
  blurDataURL="data:image/jpeg;base64,..."
/>
```

### Responsive Images

```html
<!-- srcset for different screen densities -->
<img
  srcset="/image-1x.jpg 1x, /image-2x.jpg 2x"
  src="/image-1x.jpg"
  alt="Description"
/>

<!-- sizes for different viewport widths -->
<img
  srcset="/small.jpg 400w, /medium.jpg 800w, /large.jpg 1200w"
  sizes="(max-width: 600px) 400px, (max-width: 1000px) 800px, 1200px"
  src="/medium.jpg"
  alt="Description"
/>
```

---

## Bundle Optimization

### Tree Shaking

```javascript
// ❌ Bad: Import entire library
import _ from 'lodash';
const result = _.debounce(fn, 300);

// ✅ Good: Import only what you need
import debounce from 'lodash/debounce';
const result = debounce(fn, 300);

// ❌ Bad: Import all icons
import * as Icons from 'react-icons/fa';

// ✅ Good: Import specific icons
import { FaHome, FaUser } from 'react-icons/fa';
```

### Code Splitting Libraries

```typescript
// Use dynamic imports for heavy libraries
function ChartComponent({ data }) {
  const [Chart, setChart] = useState(null);

  useEffect(() => {
    import('chart.js').then(module => {
      setChart(() => module.default);
    });
  }, []);

  if (!Chart) return <div>Loading chart...</div>;

  return <Chart data={data} />;
}
```

### Analyze Bundle Size

```bash
# Next.js bundle analyzer
npm install @next/bundle-analyzer
```

```javascript
// next.config.js
const withBundleAnalyzer = require('@next/bundle-analyzer')({
  enabled: process.env.ANALYZE === 'true',
});

module.exports = withBundleAnalyzer({
  // Next.js config
});

// Run: ANALYZE=true npm run build
```

---

## Caching Strategies

### Browser Cache (HTTP Headers)

```typescript
// Next.js API Route: Set cache headers
export async function GET() {
  const data = await fetchData();

  return new Response(JSON.stringify(data), {
    headers: {
      'Content-Type': 'application/json',
      'Cache-Control': 'public, max-age=3600, s-maxage=86400, stale-while-revalidate=604800',
    },
  });
}

// Cache-Control directives:
// - public: Can be cached by CDN
// - max-age=3600: Browser cache for 1 hour
// - s-maxage=86400: CDN cache for 1 day
// - stale-while-revalidate: Serve stale while fetching fresh
```

### Service Worker Caching

```javascript
// sw.js - Cache First strategy
self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request).then((cachedResponse) => {
      // Return cached response if found
      if (cachedResponse) {
        return cachedResponse;
      }

      // Otherwise fetch from network
      return fetch(event.request).then((response) => {
        // Cache for next time
        return caches.open('v1').then((cache) => {
          cache.put(event.request, response.clone());
          return response;
        });
      });
    })
  );
});

// Network First strategy (for dynamic data)
self.addEventListener('fetch', (event) => {
  event.respondWith(
    fetch(event.request)
      .then((response) => {
        // Update cache with fresh data
        caches.open('v1').then((cache) => {
          cache.put(event.request, response.clone());
        });
        return response;
      })
      .catch(() => {
        // Fallback to cache if network fails
        return caches.match(event.request);
      })
  );
});
```

### React Query / SWR (Client-side caching)

```typescript
// Using SWR for client-side caching
import useSWR from 'swr';

function Profile() {
  const { data, error, isLoading } = useSWR('/api/user', fetcher, {
    revalidateOnFocus: false,
    revalidateOnReconnect: true,
    dedupingInterval: 60000, // Dedupe requests within 60s
  });

  if (isLoading) return <div>Loading...</div>;
  if (error) return <div>Error</div>;

  return <div>{data.name}</div>;
}
```

---

## Resource Hints

```html
<!-- DNS Prefetch: Resolve DNS early -->
<link rel="dns-prefetch" href="https://fonts.googleapis.com" />

<!-- Preconnect: Establish connection early (DNS + TCP + TLS) -->
<link rel="preconnect" href="https://api.example.com" />

<!-- Preload: High-priority resource needed for current page -->
<link rel="preload" href="/critical.css" as="style" />
<link rel="preload" href="/hero.jpg" as="image" />
<link rel="preload" href="/font.woff2" as="font" type="font/woff2" crossorigin />

<!-- Prefetch: Low-priority resource for future navigation -->
<link rel="prefetch" href="/next-page.html" as="document" />
<link rel="prefetch" href="/product-image.jpg" as="image" />

<!-- Prerender: Fully render page in background (use sparingly) -->
<link rel="prerender" href="/next-page.html" />
```

---

## Performance Monitoring

### Measuring Core Web Vitals

```typescript
// Using web-vitals library
import { onCLS, onFID, onLCP, onINP } from 'web-vitals';

function sendToAnalytics(metric) {
  // Send to your analytics service
  console.log(metric);
}

onCLS(sendToAnalytics);
onFID(sendToAnalytics);
onLCP(sendToAnalytics);
onINP(sendToAnalytics);

// Next.js built-in support
export function reportWebVitals(metric) {
  if (metric.label === 'web-vital') {
    console.log(metric); // { name, value, id, label }
  }
}
```

### Performance API

```javascript
// Measure custom timings
performance.mark('process-start');

// ... expensive operation

performance.mark('process-end');
performance.measure('process-duration', 'process-start', 'process-end');

const measure = performance.getEntriesByName('process-duration')[0];
console.log(`Process took ${measure.duration}ms`);

// Navigation timing
const navTiming = performance.getEntriesByType('navigation')[0];
console.log('DOM Load:', navTiming.domContentLoadedEventEnd);
console.log('Full Load:', navTiming.loadEventEnd);
console.log('TTFB:', navTiming.responseStart - navTiming.requestStart);
```

---

## Best Practices Checklist

**Images**:
- ✅ Use WebP/AVIF formats with fallbacks
- ✅ Lazy load below-the-fold images
- ✅ Specify width and height attributes
- ✅ Use responsive images (srcset/sizes)
- ✅ Set fetchpriority="high" on LCP image

**JavaScript**:
- ✅ Code split by route
- ✅ Lazy load heavy components
- ✅ Tree shake unused code
- ✅ Defer non-critical scripts
- ✅ Use Web Workers for heavy computation

**CSS**:
- ✅ Inline critical CSS
- ✅ Defer non-critical CSS
- ✅ Remove unused CSS
- ✅ Minify and compress

**Fonts**:
- ✅ Preload critical fonts
- ✅ Use font-display: swap
- ✅ Subset fonts (remove unused glyphs)
- ✅ Use system fonts when appropriate

**Caching**:
- ✅ Set appropriate Cache-Control headers
- ✅ Use CDN for static assets
- ✅ Implement service worker for offline support
- ✅ Use SWR/React Query for API caching

**Monitoring**:
- ✅ Track Core Web Vitals
- ✅ Set performance budgets
- ✅ Monitor bundle size
- ✅ Use Lighthouse CI

---

## Performance Budgets

```javascript
// lighthouse-budget.json
{
  "resourceSizes": [
    {
      "resourceType": "script",
      "budget": 300 // KB
    },
    {
      "resourceType": "image",
      "budget": 500
    },
    {
      "resourceType": "stylesheet",
      "budget": 50
    },
    {
      "resourceType": "total",
      "budget": 1000
    }
  ],
  "timings": [
    {
      "metric": "interactive",
      "budget": 3000 // ms
    },
    {
      "metric": "first-contentful-paint",
      "budget": 1500
    }
  ]
}
```

---

## References

- [Web.dev Learn Performance](https://web.dev/learn/performance)
- [Web Vitals](https://github.com/GoogleChrome/web-vitals)
- [Core Web Vitals](https://web.dev/vitals/)

---

_Maintained by dsmj-ai-toolkit_
