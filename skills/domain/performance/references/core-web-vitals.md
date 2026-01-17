# Core Web Vitals Guide

Complete guide to optimizing LCP, FID/INP, and CLS.

---

## LCP - Largest Contentful Paint

**Target**: < 2.5 seconds

**Optimization**:
```html
<!-- Prioritize LCP image -->
<img
  src="/hero.jpg"
  fetchpriority="high"
  loading="eager"
/>

<!-- Preload critical resources -->
<link rel="preload" href="/hero.jpg" as="image" />
<link rel="preload" href="/font.woff2" as="font" crossorigin />
```

```typescript
// Next.js: Optimize images
import Image from 'next/image';

<Image
  src="/hero.jpg"
  width={1200}
  height={600}
  priority
  quality={90}
/>
```

---

## FID/INP - Interaction to Next Paint

**Target**: < 200ms

**Optimization**:
```javascript
// Break up long tasks
function processLargeDataset(data) {
  const chunks = chunkArray(data, 100);

  function processChunk(index) {
    if (index >= chunks.length) return;

    chunks[index].forEach(item => processItem(item));
    setTimeout(() => processChunk(index + 1), 0);
  }

  processChunk(0);
}

// Debounce expensive operations
const handleSearch = debounce((query) => {
  fetchSearchResults(query);
}, 300);

// Use Web Workers
const worker = new Worker('/worker.js');
worker.postMessage({ data });
worker.onmessage = (event) => updateUI(event.data);
```

---

## CLS - Cumulative Layout Shift

**Target**: < 0.1

**Optimization**:
```html
<!-- Always specify dimensions -->
<img src="/image.jpg" width="800" height="600" />

<!-- Use aspect-ratio -->
<style>
  .image-container {
    aspect-ratio: 16 / 9;
    width: 100%;
  }
</style>

<!-- Reserve space for ads -->
<div style="min-height: 250px;">
  <!-- Ad slot -->
</div>

<!-- Preload fonts -->
<link rel="preload" href="/font.woff2" as="font" crossorigin />
```

```typescript
// Show skeleton while loading
if (isLoading) {
  return <div className="skeleton" style={{ height: '300px' }} />;
}
```

---

_Maintained by dsmj-ai-toolkit_
