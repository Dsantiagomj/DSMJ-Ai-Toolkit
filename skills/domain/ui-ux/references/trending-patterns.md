# Trending UI/UX Patterns

Modern visual trends and contemporary design patterns.

---

## Glassmorphism

**What**: Frosted glass effect with blur and transparency

**When to use**: Hero sections, cards over images, modern dashboards

```tsx
<div className="relative">
  {/* Background image */}
  <img src="/hero.jpg" className="absolute inset-0 w-full h-full object-cover" />

  {/* Glassmorphic card */}
  <div className="relative backdrop-blur-lg bg-white/10 border border-white/20 rounded-2xl p-8 shadow-2xl">
    <h2 className="text-2xl font-bold text-white">
      Modern Dashboard
    </h2>
    <p className="text-white/80 mt-2">
      Beautiful glassmorphic design
    </p>
  </div>
</div>
```

**CSS**:
```css
.glass {
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.2);
}
```

**Performance**: Use sparingly - backdrop-filter is GPU-intensive

---

## Neumorphism (Soft UI)

**What**: Soft, extruded UI elements with subtle shadows

**When to use**: Modern apps, minimalist interfaces (use with caution - accessibility concerns)

```tsx
<div className="bg-gray-100 p-8">
  <button className="px-6 py-3 rounded-xl bg-gray-100 shadow-neumorphic hover:shadow-neumorphic-inset transition-all">
    Click me
  </button>
</div>
```

```css
/* Tailwind config */
{
  boxShadow: {
    'neumorphic': '6px 6px 12px #d1d1d1, -6px -6px 12px #ffffff',
    'neumorphic-inset': 'inset 6px 6px 12px #d1d1d1, inset -6px -6px 12px #ffffff',
  }
}
```

**⚠️ Accessibility Warning**: Low contrast - ensure text meets WCAG AA (4.5:1)

---

## Bento Grids

**What**: Asymmetric grid layouts inspired by Japanese bento boxes

**When to use**: Feature showcases, dashboards, portfolio sections

```tsx
<div className="grid grid-cols-4 grid-rows-3 gap-4">
  {/* Large featured item */}
  <div className="col-span-2 row-span-2 bg-gradient-to-br from-purple-500 to-pink-500 rounded-2xl p-6">
    <h3 className="text-white text-2xl font-bold">Featured</h3>
  </div>

  {/* Smaller items */}
  <div className="col-span-2 row-span-1 bg-blue-100 rounded-2xl p-4">
    <h4>Feature 1</h4>
  </div>
  <div className="col-span-1 row-span-2 bg-green-100 rounded-2xl p-4">
    <h4>Feature 2</h4>
  </div>
  <div className="col-span-1 row-span-2 bg-yellow-100 rounded-2xl p-4">
    <h4>Feature 3</h4>
  </div>
  <div className="col-span-2 row-span-1 bg-red-100 rounded-2xl p-4">
    <h4>Feature 4</h4>
  </div>
</div>
```

**Mobile**: Stack vertically or use simpler 2-column grid

---

## Gradient Mesh Backgrounds

**What**: Multi-color gradient backgrounds with noise/grain texture

**When to use**: Hero sections, landing pages, marketing sites

```tsx
<div className="relative min-h-screen overflow-hidden">
  {/* Gradient mesh background */}
  <div className="absolute inset-0 bg-gradient-to-br from-purple-600 via-pink-600 to-blue-600 opacity-90" />

  {/* Noise texture overlay */}
  <div
    className="absolute inset-0 opacity-20"
    style={{
      backgroundImage: `url("data:image/svg+xml,%3Csvg viewBox='0 0 400 400' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noise'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' /%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noise)' /%3E%3C/svg%3E")`,
    }}
  />

  {/* Content */}
  <div className="relative z-10">
    <h1 className="text-white text-6xl font-bold">
      Beautiful Gradients
    </h1>
  </div>
</div>
```

**Tools**:
- [Mesh Gradients](https://www.meshgradients.design/)
- [Gradient Hunt](https://gradienthunt.com/)

---

## Morphing Shapes & Blob Animations

**What**: Organic, animated SVG shapes

**When to use**: Hero sections, decorative elements, loading states

```tsx
<svg
  viewBox="0 0 200 200"
  className="w-64 h-64"
  xmlns="http://www.w3.org/2000/svg"
>
  <path
    fill="#FF6B9D"
    d="M44.7,-76.4C58.8,-69.2,71.8,-59.1,79.6,-45.8C87.4,-32.6,90,-16.3,88.5,-0.9C87,14.6,81.4,29.2,73.1,42.3C64.8,55.4,53.8,67,40.4,74.7C27,82.4,11.2,86.2,-3.9,84.6C-19,83,-38,76,-52.6,65.4C-67.2,54.8,-77.4,40.6,-82.8,24.7C-88.2,8.8,-88.8,-8.8,-84.2,-25.3C-79.6,-41.8,-69.8,-57.2,-56.4,-64.8C-43,-72.4,-26,-72.2,-10.7,-75.8C4.6,-79.4,30.6,-83.6,44.7,-76.4Z"
    className="animate-blob"
  />
</svg>
```

```css
@keyframes blob {
  0%, 100% {
    d: path("M44.7,-76.4C58.8,-69.2,71.8,-59.1,79.6,-45.8...");
  }
  50% {
    d: path("M39.8,-65.9C54.2,-59.8,70.1,-53.3,77.9,-42.1...");
  }
}

.animate-blob {
  animation: blob 8s ease-in-out infinite;
}
```

**Tools**: [Blobmaker](https://www.blobmaker.app/)

---

## Micro-animations & Page Transitions

**What**: Subtle animations that enhance UX

**When to use**: Route changes, interactive elements, feedback

```tsx
// Using Framer Motion
import { motion } from 'framer-motion';

// Page transition
<motion.div
  initial={{ opacity: 0, y: 20 }}
  animate={{ opacity: 1, y: 0 }}
  exit={{ opacity: 0, y: -20 }}
  transition={{ duration: 0.3 }}
>
  {children}
</motion.div>

// Staggered list
<motion.ul>
  {items.map((item, i) => (
    <motion.li
      key={item.id}
      initial={{ opacity: 0, x: -20 }}
      animate={{ opacity: 1, x: 0 }}
      transition={{ delay: i * 0.1 }}
    >
      {item.name}
    </motion.li>
  ))}
</motion.ul>

// Hover scale
<motion.button
  whileHover={{ scale: 1.05 }}
  whileTap={{ scale: 0.95 }}
>
  Click me
</motion.button>
```

**Performance**: Use `transform` and `opacity` (GPU-accelerated) instead of `width`, `height`, `top`, `left`

---

## Skeleton Loading

**What**: Placeholder UI that mimics actual content layout

**When to use**: Data fetching, improving perceived performance

```tsx
const SkeletonCard = () => (
  <div className="border rounded-lg p-4 animate-pulse">
    {/* Image skeleton */}
    <div className="w-full h-48 bg-gray-200 rounded mb-4" />

    {/* Text skeletons */}
    <div className="h-6 bg-gray-200 rounded w-3/4 mb-2" />
    <div className="h-4 bg-gray-200 rounded w-1/2 mb-4" />

    {/* Button skeleton */}
    <div className="h-10 bg-gray-200 rounded w-24" />
  </div>
);

// Usage
{isLoading ? (
  <SkeletonCard />
) : (
  <Card data={data} />
)}
```

**Why better than spinners**: Shows expected content structure, reduces perceived load time

---

## 3D Cards & Parallax

**What**: Cards with 3D tilt effect on hover

**When to use**: Product cards, feature showcases, CTAs

```tsx
import { useMotionValue, useTransform, motion } from 'framer-motion';

const Card3D = ({ children }) => {
  const x = useMotionValue(0);
  const y = useMotionValue(0);

  const rotateX = useTransform(y, [-100, 100], [15, -15]);
  const rotateY = useTransform(x, [-100, 100], [-15, 15]);

  return (
    <motion.div
      style={{ rotateX, rotateY, transformStyle: 'preserve-3d' }}
      onMouseMove={(e) => {
        const rect = e.currentTarget.getBoundingClientRect();
        x.set(e.clientX - rect.left - rect.width / 2);
        y.set(e.clientY - rect.top - rect.height / 2);
      }}
      onMouseLeave={() => {
        x.set(0);
        y.set(0);
      }}
      className="p-6 bg-white rounded-xl shadow-xl"
    >
      {children}
    </motion.div>
  );
};
```

---

## Dark Mode Toggle with Smooth Transition

**What**: Animated dark mode switch

```tsx
'use client';

import { useTheme } from 'next-themes';
import { Moon, Sun } from 'lucide-react';

const ThemeToggle = () => {
  const { theme, setTheme } = useTheme();

  return (
    <button
      onClick={() => setTheme(theme === 'dark' ? 'light' : 'dark')}
      className="relative w-14 h-7 bg-gray-200 dark:bg-gray-700 rounded-full transition-colors duration-300"
    >
      <div
        className={cn(
          "absolute top-0.5 left-0.5 w-6 h-6 bg-white rounded-full shadow-md transition-transform duration-300 flex items-center justify-center",
          theme === 'dark' && "translate-x-7"
        )}
      >
        {theme === 'dark' ? (
          <Moon className="w-4 h-4 text-gray-700" />
        ) : (
          <Sun className="w-4 h-4 text-yellow-500" />
        )}
      </div>
    </button>
  );
};
```

**CSS for smooth color transitions**:
```css
* {
  transition: background-color 0.3s ease, color 0.3s ease, border-color 0.3s ease;
}
```

---

## Floating Action Button (FAB) with Menu

**What**: Fixed action button with expandable menu

```tsx
const FAB = () => {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <div className="fixed bottom-8 right-8 z-50">
      {/* Menu items */}
      <AnimatePresence>
        {isOpen && (
          <motion.div
            initial={{ opacity: 0, scale: 0.8 }}
            animate={{ opacity: 1, scale: 1 }}
            exit={{ opacity: 0, scale: 0.8 }}
            className="absolute bottom-16 right-0 flex flex-col gap-3"
          >
            <button className="w-12 h-12 bg-white shadow-lg rounded-full flex items-center justify-center">
              <Share className="w-5 h-5" />
            </button>
            <button className="w-12 h-12 bg-white shadow-lg rounded-full flex items-center justify-center">
              <Heart className="w-5 h-5" />
            </button>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Main FAB */}
      <motion.button
        onClick={() => setIsOpen(!isOpen)}
        animate={{ rotate: isOpen ? 45 : 0 }}
        className="w-14 h-14 bg-blue-600 text-white shadow-2xl rounded-full flex items-center justify-center"
      >
        <Plus className="w-6 h-6" />
      </motion.button>
    </div>
  );
};
```

---

**Related**: See [Component Patterns](./component-patterns.md) for detailed component examples
