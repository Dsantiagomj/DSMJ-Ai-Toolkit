---
name: performance
domain: frontend
description: >
  Web performance optimization and Core Web Vitals. Covers LCP, FID, CLS, code splitting, lazy loading, caching strategies, image optimization, and performance monitoring.
  Trigger: When optimizing performance, when improving Core Web Vitals, when implementing code splitting, when optimizing images, when setting up caching.
version: 1.0.0
tags: [performance, core-web-vitals, optimization, caching, lazy-loading, bundle-optimization]
metadata:
  version: "1.0"
  last_updated: "2026-01-17"
  category: domain
  progressive_disclosure: true
references:
  - name: Core Web Vitals
    url: ./references/core-web-vitals.md
    type: local
  - name: Optimization Techniques
    url: ./references/optimization-techniques.md
    type: local
  - name: Web.dev Performance
    url: https://web.dev/learn/performance
    type: documentation
  - name: Core Web Vitals Guide
    url: https://web.dev/vitals/
    type: documentation
---

# Performance - Web Optimization

**Build fast, responsive web experiences**

---

## When to Use This Skill

Use this skill when:
- Optimizing Core Web Vitals (LCP, INP, CLS)
- Implementing code splitting and lazy loading
- Optimizing images and assets
- Setting up caching strategies
- Monitoring performance metrics

---

## Critical Patterns

### Pattern 1: Optimize LCP

**When**: Improving largest contentful paint

**Good**:
```html
<!-- Prioritize LCP image -->
<img
  src="/hero.jpg"
  fetchpriority="high"
  loading="eager"
/>

<!-- Preload critical resources -->
<link rel="preload" href="/hero.jpg" as="image" />
```

```typescript
// Next.js optimization
<Image
  src="/hero.jpg"
  width={1200}
  height={600}
  priority
/>
```

**Target**: < 2.5 seconds

---

### Pattern 2: Reduce INP

**When**: Improving interaction responsiveness

**Good**:
```javascript
// Break up long tasks
function processChunk(data, index = 0) {
  if (index >= data.length) return;

  processItem(data[index]);
  setTimeout(() => processChunk(data, index + 1), 0);
}

// Debounce expensive operations
const handleSearch = debounce((query) => {
  fetchResults(query);
}, 300);
```

**Target**: < 200ms

---

### Pattern 3: Prevent CLS

**When**: Ensuring visual stability

**Good**:
```html
<!-- Always specify dimensions -->
<img src="/image.jpg" width="800" height="600" />

<!-- Reserve space for dynamic content -->
<div style="min-height: 250px;">
  <!-- Ad or dynamic content -->
</div>
```

```typescript
// Show skeleton while loading
if (isLoading) {
  return <div className="skeleton" style={{ height: '300px' }} />;
}
```

**Target**: < 0.1

---

### Pattern 4: Code Splitting

**When**: Reducing initial bundle size

**Good**:
```typescript
// Dynamic imports
const HeavyComponent = lazy(() => import('./HeavyComponent'));

function App() {
  return (
    <Suspense fallback={<div>Loading...</div>}>
      {showChart && <HeavyComponent />}
    </Suspense>
  );
}
```

**Why**: Load code only when needed, reducing initial load time.

---

### Pattern 5: Image Optimization

**When**: Optimizing images

**Good**:
```html
<!-- Modern formats with fallbacks -->
<picture>
  <source srcset="/image.avif" type="image/avif" />
  <source srcset="/image.webp" type="image/webp" />
  <img src="/image.jpg" alt="Description" />
</picture>

<!-- Lazy loading -->
<img src="/image.jpg" loading="lazy" width="800" height="600" />
```

**Why**: Modern formats are 30-50% smaller than JPEG.

---

## Quick Checklist

**Images**:
- ✅ Use WebP/AVIF with fallbacks
- ✅ Lazy load below-the-fold images
- ✅ Specify width and height
- ✅ Set fetchpriority="high" on LCP image

**JavaScript**:
- ✅ Code split by route
- ✅ Lazy load heavy components
- ✅ Tree shake unused code
- ✅ Defer non-critical scripts

**Caching**:
- ✅ Set Cache-Control headers
- ✅ Use CDN for static assets
- ✅ Implement service worker

---

## Progressive Disclosure

For detailed implementations:
- **[Core Web Vitals](./references/core-web-vitals.md)** - LCP, INP, CLS optimization strategies
- **[Optimization Techniques](./references/optimization-techniques.md)** - Code splitting, image optimization, caching

---

## References

- [Core Web Vitals](./references/core-web-vitals.md)
- [Optimization Techniques](./references/optimization-techniques.md)
- [Web.dev Performance](https://web.dev/learn/performance)
- [Core Web Vitals Guide](https://web.dev/vitals/)

---

_Maintained by dsmj-ai-toolkit_
