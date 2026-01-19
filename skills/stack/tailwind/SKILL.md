---
name: tailwind
description: >
  Tailwind CSS patterns for utility-first styling, responsive design, and component composition.
  Trigger: When styling with Tailwind CSS, when implementing responsive designs, when building UI components,
  when configuring Tailwind, when using Tailwind with React or Next.js.
tags: [tailwind, css, styling, responsive, utility-first, design, ui, components]
author: dsmj-ai-toolkit
metadata:
  version: "1.0"
  last_updated: "2026-01-19"
  category: stack
  auto_invoke: "When working with Tailwind CSS"
  stack_category: frontend
  progressive_disclosure: true
references:
  - name: Component Patterns
    url: ./references/components.md
    type: local
---

# Tailwind CSS - Utility-First Styling

**Patterns for Tailwind CSS v4, responsive design, and component composition**

---

## When to Use This Skill

**Use this skill when**:
- Styling applications with Tailwind CSS
- Building responsive layouts
- Creating reusable UI components
- Configuring Tailwind themes
- Implementing dark mode
- Optimizing for production

**Don't use this skill when**:
- Using CSS-in-JS libraries (styled-components, Emotion)
- Writing traditional CSS/SCSS
- Using other utility frameworks (UnoCSS, Windi)

---

## Critical Patterns

### Pattern 1: Responsive Design

**When**: Building mobile-first responsive layouts

```tsx
// ✅ GOOD: Mobile-first responsive design
<div className="
  flex flex-col gap-4
  md:flex-row md:gap-6
  lg:gap-8
">
  {/* Stack on mobile, row on md+, larger gap on lg+ */}
  <aside className="w-full md:w-64 lg:w-80">
    <Sidebar />
  </aside>
  <main className="flex-1">
    <Content />
  </main>
</div>

// ✅ GOOD: Responsive typography
<h1 className="text-2xl sm:text-3xl md:text-4xl lg:text-5xl font-bold">
  Responsive Heading
</h1>

// ✅ GOOD: Responsive grid
<div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
  {products.map(p => <ProductCard key={p.id} product={p} />)}
</div>

// ❌ BAD: Desktop-first (harder to maintain)
<div className="flex-row md:flex-col"> {/* Confusing! */}
```

**Breakpoints** (Tailwind defaults):
- `sm`: 640px
- `md`: 768px
- `lg`: 1024px
- `xl`: 1280px
- `2xl`: 1536px

### Pattern 2: Component Composition with CVA

**When**: Building variant-based components

```tsx
// ✅ GOOD: Using class-variance-authority (CVA)
import { cva, type VariantProps } from 'class-variance-authority';
import { cn } from '@/lib/utils';

const buttonVariants = cva(
  // Base styles
  'inline-flex items-center justify-center rounded-md font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 disabled:pointer-events-none disabled:opacity-50',
  {
    variants: {
      variant: {
        default: 'bg-primary text-primary-foreground hover:bg-primary/90',
        destructive: 'bg-destructive text-destructive-foreground hover:bg-destructive/90',
        outline: 'border border-input bg-background hover:bg-accent hover:text-accent-foreground',
        secondary: 'bg-secondary text-secondary-foreground hover:bg-secondary/80',
        ghost: 'hover:bg-accent hover:text-accent-foreground',
        link: 'text-primary underline-offset-4 hover:underline',
      },
      size: {
        default: 'h-10 px-4 py-2',
        sm: 'h-9 px-3 text-sm',
        lg: 'h-11 px-8 text-lg',
        icon: 'h-10 w-10',
      },
    },
    defaultVariants: {
      variant: 'default',
      size: 'default',
    },
  }
);

interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {}

export function Button({ className, variant, size, ...props }: ButtonProps) {
  return (
    <button
      className={cn(buttonVariants({ variant, size, className }))}
      {...props}
    />
  );
}

// Usage
<Button variant="destructive" size="lg">Delete</Button>
<Button variant="outline">Cancel</Button>

// ❌ BAD: Prop-based conditional classes without system
<button className={`
  px-4 py-2 rounded
  ${variant === 'primary' ? 'bg-blue-500' : ''}
  ${variant === 'secondary' ? 'bg-gray-500' : ''}
  ${size === 'large' ? 'text-lg px-6' : ''}
`}>
```

### Pattern 3: Dark Mode

**When**: Implementing light/dark themes

```tsx
// ✅ GOOD: Class-based dark mode (recommended)
// tailwind.config.ts
export default {
  darkMode: 'class', // or 'media' for system preference
  // ...
}

// Component with dark mode support
<div className="bg-white dark:bg-gray-900 text-gray-900 dark:text-gray-100">
  <h1 className="text-2xl font-bold">Dashboard</h1>
  <p className="text-gray-600 dark:text-gray-400">
    Welcome back
  </p>
</div>

// ✅ GOOD: CSS variables for theming
// globals.css
@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 222.2 84% 4.9%;
    --primary: 222.2 47.4% 11.2%;
  }

  .dark {
    --background: 222.2 84% 4.9%;
    --foreground: 210 40% 98%;
    --primary: 210 40% 98%;
  }
}

// tailwind.config.ts
theme: {
  extend: {
    colors: {
      background: 'hsl(var(--background))',
      foreground: 'hsl(var(--foreground))',
      primary: 'hsl(var(--primary))',
    },
  },
}

// Usage - automatically adapts to theme
<div className="bg-background text-foreground">
  <button className="bg-primary text-primary-foreground">Click</button>
</div>

// ❌ BAD: Hardcoded colors without dark mode
<div className="bg-white text-black"> {/* No dark mode! */}
```

### Pattern 4: Utility Function for Class Merging

**When**: Combining conditional classes safely

```tsx
// ✅ GOOD: cn() utility with tailwind-merge
// lib/utils.ts
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

// Usage - handles conflicts correctly
<div className={cn(
  'px-4 py-2 rounded',
  isActive && 'bg-blue-500',
  className // Allow override from props
)}>

// twMerge resolves conflicts:
cn('px-4', 'px-6') // → 'px-6' (not 'px-4 px-6')
cn('text-red-500', 'text-blue-500') // → 'text-blue-500'

// ❌ BAD: String concatenation (doesn't resolve conflicts)
className={`px-4 ${className}`} // px-4 and px-6 would both apply!

// ❌ BAD: Just clsx without twMerge
clsx('px-4', 'px-6') // → 'px-4 px-6' (both apply, undefined behavior)
```

### Pattern 5: Layout Patterns

**When**: Building common layout structures

```tsx
// ✅ GOOD: Centered container with max-width
<div className="container mx-auto px-4 sm:px-6 lg:px-8">
  <Content />
</div>

// ✅ GOOD: Sticky header with content scroll
<div className="flex h-screen flex-col">
  <header className="sticky top-0 z-50 border-b bg-background/95 backdrop-blur">
    <Nav />
  </header>
  <main className="flex-1 overflow-auto">
    <Content />
  </main>
  <footer className="border-t">
    <Footer />
  </footer>
</div>

// ✅ GOOD: Sidebar layout
<div className="flex h-screen">
  <aside className="w-64 border-r bg-muted/50 overflow-y-auto">
    <Sidebar />
  </aside>
  <main className="flex-1 overflow-y-auto">
    <Content />
  </main>
</div>

// ✅ GOOD: Card grid with equal heights
<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
  {items.map(item => (
    <div key={item.id} className="flex flex-col rounded-lg border p-6">
      <h3 className="text-lg font-semibold">{item.title}</h3>
      <p className="flex-1 text-muted-foreground">{item.description}</p>
      <button className="mt-4">Learn more</button>
    </div>
  ))}
</div>
```

---

## Code Examples

### Example 1: Form Styling

```tsx
export function LoginForm() {
  return (
    <form className="space-y-4 w-full max-w-sm">
      <div className="space-y-2">
        <label htmlFor="email" className="text-sm font-medium">
          Email
        </label>
        <input
          id="email"
          type="email"
          className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring disabled:cursor-not-allowed disabled:opacity-50"
          placeholder="you@example.com"
        />
      </div>

      <div className="space-y-2">
        <label htmlFor="password" className="text-sm font-medium">
          Password
        </label>
        <input
          id="password"
          type="password"
          className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
        />
      </div>

      <button
        type="submit"
        className="w-full rounded-md bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90 focus-visible:outline-none focus-visible:ring-2"
      >
        Sign in
      </button>
    </form>
  );
}
```

### Example 2: Responsive Navigation

```tsx
export function Navigation() {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <nav className="border-b">
      <div className="container mx-auto flex h-16 items-center justify-between px-4">
        <Logo />

        {/* Desktop nav */}
        <div className="hidden md:flex items-center gap-6">
          <NavLink href="/products">Products</NavLink>
          <NavLink href="/about">About</NavLink>
          <NavLink href="/contact">Contact</NavLink>
          <Button>Sign in</Button>
        </div>

        {/* Mobile menu button */}
        <button
          className="md:hidden p-2"
          onClick={() => setIsOpen(!isOpen)}
          aria-label="Toggle menu"
        >
          <MenuIcon className="h-6 w-6" />
        </button>
      </div>

      {/* Mobile nav */}
      {isOpen && (
        <div className="md:hidden border-t p-4 space-y-4">
          <NavLink href="/products" className="block">Products</NavLink>
          <NavLink href="/about" className="block">About</NavLink>
          <NavLink href="/contact" className="block">Contact</NavLink>
          <Button className="w-full">Sign in</Button>
        </div>
      )}
    </nav>
  );
}
```

### Example 3: Animation with Tailwind

```tsx
// Hover and focus animations
<button className="transform transition-all duration-200 hover:scale-105 hover:shadow-lg active:scale-95">
  Animated Button
</button>

// Fade in on mount (with Tailwind + React)
<div className="animate-in fade-in duration-500">
  Content fades in
</div>

// Custom animation in config
// tailwind.config.ts
theme: {
  extend: {
    keyframes: {
      'slide-in': {
        '0%': { transform: 'translateX(-100%)' },
        '100%': { transform: 'translateX(0)' },
      },
    },
    animation: {
      'slide-in': 'slide-in 0.3s ease-out',
    },
  },
}

// Usage
<div className="animate-slide-in">Slides in from left</div>
```

---

## Anti-Patterns

### Don't: Duplicate Class Strings

```tsx
// ❌ BAD: Copy-pasting the same classes
<button className="px-4 py-2 rounded bg-blue-500 text-white hover:bg-blue-600">Save</button>
<button className="px-4 py-2 rounded bg-blue-500 text-white hover:bg-blue-600">Submit</button>
<button className="px-4 py-2 rounded bg-blue-500 text-white hover:bg-blue-600">Send</button>

// ✅ GOOD: Extract to component or CVA
const Button = ({ children }) => (
  <button className="px-4 py-2 rounded bg-blue-500 text-white hover:bg-blue-600">
    {children}
  </button>
);
```

### Don't: Over-customize in Config

```tsx
// ❌ BAD: Adding every possible value
theme: {
  extend: {
    spacing: {
      '13': '3.25rem',
      '15': '3.75rem',
      '17': '4.25rem',
      // ...endless custom values
    },
  },
}

// ✅ GOOD: Use arbitrary values when needed
<div className="mt-[3.25rem]">Arbitrary value</div>

// Or stick to the default scale
<div className="mt-12 lg:mt-16">Uses default scale</div>
```

### Don't: Ignore Accessibility

```tsx
// ❌ BAD: Low contrast, no focus states
<button className="bg-gray-200 text-gray-400">Hard to read</button>

// ✅ GOOD: Proper contrast and focus states
<button className="bg-gray-900 text-white focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-2">
  Accessible
</button>
```

---

## Quick Reference

| Task | Classes | Example |
|------|---------|---------|
| Center content | `flex items-center justify-center` | Container centering |
| Responsive hide | `hidden md:block` | Show only on md+ |
| Truncate text | `truncate` | Single line ellipsis |
| Aspect ratio | `aspect-video` | 16:9 ratio |
| Gradient | `bg-gradient-to-r from-blue-500 to-purple-500` | Horizontal gradient |
| Shadow | `shadow-md hover:shadow-lg` | Elevation effect |
| Ring focus | `focus:ring-2 focus:ring-offset-2` | Focus indicator |

---

## Resources

**Official Documentation**:
- [Tailwind CSS](https://tailwindcss.com/docs)
- [Tailwind UI](https://tailwindui.com/)

**Related Skills**:
- **react**: React component patterns
- **accessibility**: WCAG compliance
- **ui-ux**: Design principles

---

## Keywords

`tailwind`, `tailwindcss`, `css`, `styling`, `responsive`, `utility-first`, `dark-mode`, `components`, `design-system`
