---
name: ui-ux
description: >
  UI/UX design principles for beautiful, accessible, user-centered interfaces.
  Trigger: When designing components, when implementing UI, when reviewing visual design,
  when suggesting design improvements, when validating user experience, when choosing design patterns.
tags: [ui, ux, design, visual-design, accessibility, responsive, components, design-systems, user-experience]
author: dsmj-ai-toolkit
metadata:
  version: "1.0"
  last_updated: "2026-01-17"
  category: domain
  auto_invoke: "When implementing or reviewing UI/UX design"
  stack_category: frontend
  progressive_disclosure: true
references:
  - name: Design Systems
    url: ./references/design-systems.md
    type: local
  - name: Component Patterns
    url: ./references/component-patterns.md
    type: local
  - name: Interaction Patterns
    url: ./references/interaction-patterns.md
    type: local
  - name: Trending Patterns
    url: ./references/trending-patterns.md
    type: local
---

# UI/UX - Design Principles & Implementation

**Create beautiful, functional interfaces that delight users**

---

## When to Use This Skill

**Use this skill when**:
- Designing new components or interfaces
- Implementing UI elements (buttons, forms, cards, modals)
- Reviewing visual design and user experience
- Suggesting design improvements or alternatives
- Validating component states and interactions
- Creating responsive layouts
- Implementing dark mode or themes
- Building design systems or component libraries

**Don't use this skill when**:
- Only implementing backend logic (no UI)
- Working with pure data processing
- Technical accessibility fixes (use accessibility skill for WCAG)
- Performance optimization without visual impact

---

## Critical Patterns

### Pattern 1: Visual Hierarchy

**When**: Organizing information and guiding user attention

**Good**:
```tsx
// Clear hierarchy with size, weight, color
<div className="space-y-4">
  {/* Primary: Large, bold, high contrast */}
  <h1 className="text-4xl font-bold text-gray-900">
    Create Your Account
  </h1>

  {/* Secondary: Medium, regular, medium contrast */}
  <p className="text-lg text-gray-600">
    Get started with a free 14-day trial
  </p>

  {/* Tertiary: Small, light, low contrast */}
  <span className="text-sm text-gray-400">
    No credit card required
  </span>
</div>
```

**Bad**:
```tsx
// ❌ No hierarchy - everything same size/weight
<div>
  <h1 className="text-base">Create Your Account</h1>
  <p className="text-base">Get started with a free 14-day trial</p>
  <span className="text-base">No credit card required</span>
</div>
```

**Why**: Visual hierarchy guides user attention through size, weight, and contrast. Primary content should dominate, supporting content should recede.

---

### Pattern 2: Comprehensive Component States

**When**: Implementing interactive components

**Good**:
```tsx
const Button = ({ variant = 'primary', isLoading, disabled }) => {
  return (
    <button
      disabled={disabled || isLoading}
      className={cn(
        // Base styles
        "px-4 py-2 rounded-lg font-medium transition-all",

        // Variant styles
        variant === 'primary' && "bg-blue-600 text-white",
        variant === 'secondary' && "bg-gray-200 text-gray-900",

        // Interactive states
        !disabled && !isLoading && "hover:opacity-90 active:scale-95",

        // Focus state (keyboard navigation)
        "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-blue-500 focus-visible:ring-offset-2",

        // Disabled state
        disabled && "opacity-50 cursor-not-allowed",

        // Loading state
        isLoading && "cursor-wait"
      )}
    >
      {isLoading && <Spinner className="mr-2" />}
      {children}
    </button>
  );
};
```

**Bad**:
```tsx
// ❌ Only handles default state
const Button = ({ children }) => {
  return (
    <button className="px-4 py-2 bg-blue-600 text-white rounded">
      {children}
    </button>
  );
};
```

**Why**: Users need visual feedback for all interactions. Missing states create confusion and poor UX.

**Required States**:
- Default
- Hover (mouse users)
- Focus (keyboard users)
- Active/Pressed
- Disabled
- Loading
- Error (if applicable)

---

### Pattern 3: Responsive Design with Mobile-First

**When**: Creating layouts that work across devices

**Good**:
```tsx
// Mobile-first: start with mobile, enhance for desktop
<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
  {/* Cards stack on mobile, 2 cols on tablet, 3 on desktop */}
  {products.map(product => (
    <Card key={product.id}>
      <img
        src={product.image}
        className="w-full h-48 object-cover"
        alt={product.name}
      />
      <div className="p-4">
        <h3 className="text-lg font-semibold">{product.name}</h3>
        <p className="text-sm text-gray-600 mt-2">{product.description}</p>
      </div>
    </Card>
  ))}
</div>
```

**Bad**:
```tsx
// ❌ Desktop-only, breaks on mobile
<div className="grid grid-cols-3 gap-4">
  {products.map(product => (
    <Card>{/* Content */}</Card>
  ))}
</div>
```

**Why**: Mobile-first ensures core experience works everywhere, then progressively enhances for larger screens.

**Touch Targets**: Minimum 44x44px for mobile (48x48px recommended)
```tsx
// ✅ Good touch target
<button className="min-h-[44px] min-w-[44px] p-3">
  <Icon />
</button>

// ❌ Too small for touch
<button className="p-1">
  <Icon />
</button>
```

---

### Pattern 4: Dark Mode Implementation

**When**: Supporting light and dark themes

**Good**:
```tsx
// Using CSS variables for theme switching
// globals.css
:root {
  --background: 0 0% 100%;
  --foreground: 222.2 84% 4.9%;
  --card: 0 0% 100%;
  --card-foreground: 222.2 84% 4.9%;
  --primary: 221.2 83.2% 53.3%;
  --primary-foreground: 210 40% 98%;
}

.dark {
  --background: 222.2 84% 4.9%;
  --foreground: 210 40% 98%;
  --card: 222.2 84% 4.9%;
  --card-foreground: 210 40% 98%;
  --primary: 217.2 91.2% 59.8%;
  --primary-foreground: 222.2 47.4% 11.2%;
}

// Components use CSS variables
<div className="bg-background text-foreground">
  <div className="bg-card text-card-foreground p-6 rounded-lg">
    <button className="bg-primary text-primary-foreground">
      Click me
    </button>
  </div>
</div>
```

**Bad**:
```tsx
// ❌ Hardcoded colors, no dark mode support
<div className="bg-white text-gray-900">
  <div className="bg-white text-black p-6 rounded-lg">
    <button className="bg-blue-600 text-white">
      Click me
    </button>
  </div>
</div>
```

**Why**: CSS variables allow instant theme switching. Hardcoded colors require conditional classes everywhere.

**Dark Mode Considerations**:
- Use semantic color names (`background`, `foreground`, not `white`, `black`)
- Reduce white (#FFF → #F9F9F9) to prevent eye strain
- Adjust shadows (use lighter shadows or borders in dark mode)
- Maintain contrast ratios (WCAG 4.5:1 minimum)

---

### Pattern 5: Consistent Spacing System

**When**: Creating balanced, rhythmic layouts

**Good**:
```tsx
// Use design tokens (spacing scale: 4px base)
const spacing = {
  xs: '0.25rem',  // 4px
  sm: '0.5rem',   // 8px
  md: '1rem',     // 16px
  lg: '1.5rem',   // 24px
  xl: '2rem',     // 32px
  '2xl': '3rem',  // 48px
};

<div className="space-y-8">
  {/* Consistent 32px vertical rhythm */}
  <section className="p-8">
    <h2 className="mb-4">Section Title</h2>
    <p className="mb-6">Description text</p>
    <div className="grid gap-4">
      {/* Cards with consistent 16px gap */}
    </div>
  </section>
</div>
```

**Bad**:
```tsx
// ❌ Inconsistent, random spacing
<div style={{ marginBottom: '13px' }}>
  <section style={{ padding: '17px' }}>
    <h2 style={{ marginBottom: '9px' }}>Title</h2>
    <p style={{ marginBottom: '21px' }}>Text</p>
  </section>
</div>
```

**Why**: Consistent spacing creates visual rhythm and professional polish. Use multiples of 4px or 8px.

---

### Pattern 6: Microinteractions for Feedback

**When**: Providing immediate user feedback

**Good**:
```tsx
// Optimistic UI with animations
const LikeButton = ({ postId }) => {
  const [isLiked, setIsLiked] = useState(false);
  const [count, setCount] = useState(0);

  const handleLike = async () => {
    // Optimistic update
    setIsLiked(!isLiked);
    setCount(prev => isLiked ? prev - 1 : prev + 1);

    try {
      await likePost(postId);
    } catch (error) {
      // Rollback on error
      setIsLiked(!isLiked);
      setCount(prev => isLiked ? prev + 1 : prev - 1);
      toast.error('Failed to like post');
    }
  };

  return (
    <button
      onClick={handleLike}
      className="group flex items-center gap-2 transition-all"
    >
      <Heart
        className={cn(
          "w-5 h-5 transition-all",
          isLiked && "fill-red-500 text-red-500 scale-110",
          !isLiked && "text-gray-400 group-hover:text-red-400"
        )}
      />
      <span className={cn(
        "transition-all",
        isLiked && "text-red-500 font-medium"
      )}>
        {count}
      </span>
    </button>
  );
};
```

**Bad**:
```tsx
// ❌ No feedback, waits for server response
const LikeButton = ({ postId }) => {
  const [count, setCount] = useState(0);

  const handleLike = async () => {
    const result = await likePost(postId);
    setCount(result.count);
  };

  return (
    <button onClick={handleLike}>
      Like {count}
    </button>
  );
};
```

**Why**: Immediate feedback feels responsive. Optimistic updates provide instant gratification while server processes.

---

## Anti-Patterns

### ❌ Anti-Pattern 1: Inconsistent Component Variants

**Don't do this**:
```tsx
// ❌ Inconsistent button styles across app
<button className="bg-blue-500 px-6 py-3 rounded">Save</button>
<button className="bg-blue-600 px-4 py-2 rounded-lg">Submit</button>
<button className="bg-indigo-500 px-5 py-2.5 rounded-md">Continue</button>
```

**Why it's bad**: Inconsistency looks unprofessional and confuses users.

**Do this instead**:
```tsx
// ✅ Use a Button component with defined variants
<Button variant="primary">Save</Button>
<Button variant="primary">Submit</Button>
<Button variant="primary">Continue</Button>

// Button component enforces consistency
const Button = ({ variant = 'primary', size = 'md', children }) => {
  const styles = {
    primary: 'bg-blue-600 text-white hover:bg-blue-700',
    secondary: 'bg-gray-200 text-gray-900 hover:bg-gray-300',
  };

  const sizes = {
    sm: 'px-3 py-1.5 text-sm',
    md: 'px-4 py-2 text-base',
    lg: 'px-6 py-3 text-lg',
  };

  return (
    <button className={cn(styles[variant], sizes[size], 'rounded-lg transition')}>
      {children}
    </button>
  );
};
```

---

### ❌ Anti-Pattern 2: Poor Empty States

**Don't do this**:
```tsx
// ❌ Just shows nothing
{products.length === 0 ? null : (
  <ProductGrid products={products} />
)}
```

**Why it's bad**: Users don't know if it's loading, an error, or intentionally empty.

**Do this instead**:
```tsx
// ✅ Helpful empty state with action
{products.length === 0 ? (
  <div className="flex flex-col items-center justify-center py-12 text-center">
    <ShoppingBag className="w-16 h-16 text-gray-300 mb-4" />
    <h3 className="text-lg font-medium text-gray-900 mb-2">
      No products yet
    </h3>
    <p className="text-gray-500 mb-6">
      Get started by adding your first product
    </p>
    <Button onClick={() => router.push('/products/new')}>
      Add Product
    </Button>
  </div>
) : (
  <ProductGrid products={products} />
)}
```

---

### ❌ Anti-Pattern 3: Ignoring Loading States

**Don't do this**:
```tsx
// ❌ No loading indicator
const Dashboard = () => {
  const { data } = useQuery('stats');

  return (
    <div>
      <h1>Dashboard</h1>
      <Stats data={data} />
    </div>
  );
};
```

**Why it's bad**: User sees broken/empty UI while loading, or worse, errors.

**Do this instead**:
```tsx
// ✅ Proper loading and error states
const Dashboard = () => {
  const { data, isLoading, error } = useQuery('stats');

  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <Spinner className="w-8 h-8" />
      </div>
    );
  }

  if (error) {
    return (
      <div className="p-4 bg-red-50 border border-red-200 rounded-lg">
        <p className="text-red-800">Failed to load dashboard</p>
        <Button onClick={() => refetch()} className="mt-2">
          Try Again
        </Button>
      </div>
    );
  }

  return (
    <div>
      <h1>Dashboard</h1>
      <Stats data={data} />
    </div>
  );
};
```

---

### ❌ Anti-Pattern 4: Tiny Touch Targets on Mobile

**Don't do this**:
```tsx
// ❌ 24px icon button - too small for fingers
<button className="p-1">
  <X className="w-4 h-4" />
</button>
```

**Why it's bad**: Users will miss tap targets, causing frustration.

**Do this instead**:
```tsx
// ✅ Minimum 44x44px touch target
<button className="p-3 min-w-[44px] min-h-[44px] flex items-center justify-center">
  <X className="w-5 h-5" />
</button>
```

**Rule**: 44x44px minimum (iOS), 48x48px recommended (Material Design)

---

### ❌ Anti-Pattern 5: Poor Form Error Handling

**Don't do this**:
```tsx
// ❌ Generic error, no field-specific feedback
<form onSubmit={handleSubmit}>
  <input name="email" />
  <input name="password" />
  {error && <p>Error: {error}</p>}
  <button type="submit">Submit</button>
</form>
```

**Why it's bad**: User doesn't know which field has the problem.

**Do this instead**:
```tsx
// ✅ Field-specific errors with helpful messages
<form onSubmit={handleSubmit}>
  <div className="space-y-1">
    <input
      name="email"
      className={cn(
        "border rounded-lg px-3 py-2",
        errors.email && "border-red-500"
      )}
    />
    {errors.email && (
      <p className="text-sm text-red-600 flex items-center gap-1">
        <AlertCircle className="w-4 h-4" />
        {errors.email.message}
      </p>
    )}
  </div>

  <div className="space-y-1">
    <input
      name="password"
      className={cn(
        "border rounded-lg px-3 py-2",
        errors.password && "border-red-500"
      )}
    />
    {errors.password && (
      <p className="text-sm text-red-600 flex items-center gap-1">
        <AlertCircle className="w-4 h-4" />
        {errors.password.message}
      </p>
    )}
  </div>

  <button type="submit" disabled={isSubmitting}>
    {isSubmitting ? 'Submitting...' : 'Submit'}
  </button>
</form>
```

---

### ❌ Anti-Pattern 6: Overwhelming Modals

**Don't do this**:
```tsx
// ❌ Modal with 20 fields, long form
<Dialog>
  <DialogContent className="max-w-4xl">
    <form>
      {/* 20+ input fields */}
      <input name="field1" />
      <input name="field2" />
      {/* ... 18 more fields */}
    </form>
  </DialogContent>
</Dialog>
```

**Why it's bad**: Cognitive overload, users abandon complex modals.

**Do this instead**:
```tsx
// ✅ Multi-step wizard for complex forms
<Dialog>
  <DialogContent>
    <div className="mb-4">
      <div className="flex gap-2">
        <div className={cn("h-1 flex-1 rounded", step >= 1 && "bg-blue-600")} />
        <div className={cn("h-1 flex-1 rounded", step >= 2 && "bg-blue-600")} />
        <div className={cn("h-1 flex-1 rounded", step >= 3 && "bg-blue-600")} />
      </div>
      <p className="text-sm text-gray-500 mt-2">Step {step} of 3</p>
    </div>

    {step === 1 && <BasicInfoFields />}
    {step === 2 && <ContactFields />}
    {step === 3 && <PreferencesFields />}

    <div className="flex justify-between mt-6">
      {step > 1 && <Button onClick={prevStep}>Back</Button>}
      <Button onClick={nextStep}>
        {step === 3 ? 'Submit' : 'Continue'}
      </Button>
    </div>
  </DialogContent>
</Dialog>
```

---

## Quick Reference

### Visual Hierarchy Scale

| Element | Size | Weight | Color |
|---------|------|--------|-------|
| Primary Heading | text-4xl (36px) | font-bold (700) | text-gray-900 |
| Secondary Heading | text-2xl (24px) | font-semibold (600) | text-gray-800 |
| Body Large | text-lg (18px) | font-normal (400) | text-gray-700 |
| Body | text-base (16px) | font-normal (400) | text-gray-600 |
| Small | text-sm (14px) | font-normal (400) | text-gray-500 |
| Caption | text-xs (12px) | font-normal (400) | text-gray-400 |

### Component States Checklist

- [ ] Default
- [ ] Hover (`:hover`)
- [ ] Focus (`:focus-visible`)
- [ ] Active (`:active`)
- [ ] Disabled (`disabled`, `opacity-50`)
- [ ] Loading (`cursor-wait`, spinner)
- [ ] Error (`border-red-500`, error message)
- [ ] Success (if applicable)

### Spacing Scale (Tailwind)

```tsx
// 4px base scale
gap-1  = 4px
gap-2  = 8px
gap-4  = 16px
gap-6  = 24px
gap-8  = 32px
gap-12 = 48px
gap-16 = 64px
```

### Responsive Breakpoints

```tsx
sm:  640px   // Small tablets
md:  768px   // Tablets
lg:  1024px  // Laptops
xl:  1280px  // Desktops
2xl: 1536px  // Large desktops
```

### Color Contrast Ratios (WCAG)

| Level | Normal Text | Large Text |
|-------|-------------|------------|
| AA | 4.5:1 | 3:1 |
| AAA | 7:1 | 4.5:1 |

---

## Resources

**Design Systems**:
- [Tailwind CSS](https://tailwindcss.com/) - Utility-first CSS framework
- [shadcn/ui](https://ui.shadcn.com/) - Re-usable components built with Radix UI and Tailwind
- [Radix UI](https://www.radix-ui.com/) - Unstyled, accessible components
- [Material Design](https://m3.material.io/) - Google's design system

**Component Libraries**:
- [Headless UI](https://headlessui.com/) - Unstyled, accessible components
- [Ark UI](https://ark-ui.com/) - Headless UI for React, Vue, Solid

**Design Tools**:
- [Figma](https://www.figma.com/) - Collaborative design tool
- [Contrast Checker](https://webaim.org/resources/contrastchecker/) - WCAG contrast validation

**Related Skills**:
- **accessibility**: WCAG compliance, ARIA, keyboard navigation
- **react**: Component implementation patterns
- **radix-ui**: Headless component primitives
- **patterns**: Design patterns and principles

**References** (Progressive Disclosure):
- [Design Systems](./references/design-systems.md) - Tokens, theming, component libraries
- [Component Patterns](./references/component-patterns.md) - Buttons, forms, cards, modals
- [Interaction Patterns](./references/interaction-patterns.md) - Navigation, feedback, animations
- [Trending Patterns](./references/trending-patterns.md) - Glassmorphism, neumorphism, modern UI trends

---

_Maintained by dsmj-ai-toolkit. Inspired by modern design systems and user-centered design principles._
