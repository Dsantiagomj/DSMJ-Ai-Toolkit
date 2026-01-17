---
name: radix-ui
domain: frontend
description: >
  Accessible headless UI components with Radix UI - Unstyled, accessible components for building design systems.
  Trigger: When implementing UI primitives, when building accessible components, when using Dialog/Dropdown/Popover, when working with shadcn/ui.
version: 1.0.0
tags: [radix-ui, react, accessibility, headless-ui, components, a11y]
metadata:
  version: "1.0"
  last_updated: "2026-01-17"
  category: stack
references:
  - name: Radix UI Documentation
    url: https://www.radix-ui.com/
    type: documentation
  - name: Radix Primitives
    url: https://www.radix-ui.com/primitives
    type: documentation
  - name: Radix UI GitHub
    url: https://github.com/radix-ui/primitives
    type: repository
  - name: Radix UI Context7
    url: /websites/radix-ui
    type: context7
  - name: Components Reference
    url: ./references/components.md
    type: local
---

# Radix UI - Accessible Headless Components

**Build accessible design systems with unstyled, composable primitives**

---

## When to Use This Skill

**Use this skill when**:
- Building accessible UI components from scratch
- Working with shadcn/ui (which uses Radix primitives)
- Need keyboard navigation and ARIA support built-in
- Creating custom-styled dialogs, dropdowns, popovers
- Building design systems with consistent accessibility
- Want headless components that you can style freely

**Don't use this skill when**:
- Need pre-styled components (use Material-UI, Chakra UI)
- Building static content without interaction
- Simple HTML elements are sufficient (`<button>`, `<select>`)
- Working with non-React frameworks

---

## Critical Patterns

### Pattern 1: Composition with asChild

**When**: Passing custom components as triggers or content

**Good**:
```typescript
import * as Dialog from '@radix-ui/react-dialog';
import { Button } from './Button';

<Dialog.Root>
  <Dialog.Trigger asChild>
    <Button variant="primary">Open</Button>
  </Dialog.Trigger>
</Dialog.Root>
```

**Bad**:
```typescript
// ❌ Wrapper divs break accessibility
<Dialog.Root>
  <div onClick={() => setOpen(true)}>
    <Button>Open</Button>
  </div>
</Dialog.Root>
```

**Why**: `asChild` merges props into your component, maintaining accessibility attributes and event handlers without wrapper elements.

---

### Pattern 2: Portal for Overlays

**When**: Rendering modals, dialogs, popovers that need to escape parent containers

**Good**:
```typescript
<Dialog.Root>
  <Dialog.Portal>
    <Dialog.Overlay className="fixed inset-0 bg-black/50" />
    <Dialog.Content className="fixed top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2">
      {/* Content */}
    </Dialog.Content>
  </Dialog.Portal>
</Dialog.Root>
```

**Bad**:
```typescript
// ❌ No portal - overlay affected by parent overflow/z-index
<Dialog.Root>
  <Dialog.Overlay />
  <Dialog.Content>
    {/* Content */}
  </Dialog.Content>
</Dialog.Root>
```

**Why**: Portal renders overlay at document root, avoiding z-index issues and overflow clipping.

---

### Pattern 3: Controlled vs Uncontrolled State

**When**: Managing open/close state

**Good (Controlled)**:
```typescript
const [open, setOpen] = useState(false);

<Dialog.Root open={open} onOpenChange={setOpen}>
  {/* Now you can control externally */}
  <Dialog.Trigger asChild>
    <button>Open Dialog</button>
  </Dialog.Trigger>
</Dialog.Root>

// Programmatic control
<button onClick={() => setOpen(true)}>Open from outside</button>
```

**Good (Uncontrolled)**:
```typescript
// Radix manages state internally
<Dialog.Root>
  <Dialog.Trigger asChild>
    <button>Open Dialog</button>
  </Dialog.Trigger>
</Dialog.Root>
```

**When to use each**:
- **Controlled**: Need external control, analytics, complex state
- **Uncontrolled**: Simple toggle, no external dependencies

---

### Pattern 4: Styling with Tailwind

**When**: Applying styles to headless components

**Good**:
```typescript
<DropdownMenu.Content
  className="min-w-[220px] bg-white rounded-md shadow-lg p-1"
  sideOffset={5}
>
  <DropdownMenu.Item className="px-3 py-2 rounded hover:bg-gray-100 cursor-pointer outline-none">
    Profile
  </DropdownMenu.Item>
</DropdownMenu.Content>
```

**Bad**:
```typescript
// ❌ Inline styles, no focus states
<DropdownMenu.Content style={{ background: 'white', padding: '4px' }}>
  <DropdownMenu.Item style={{ padding: '8px' }}>
    Profile
  </DropdownMenu.Item>
</DropdownMenu.Content>
```

**Why**: Tailwind classes handle hover, focus, and responsive states. Always include `outline-none` and visible focus states for keyboard users.

---

## Anti-Patterns

### ❌ Anti-Pattern 1: Breaking Composition Structure

**Don't do this**:
```typescript
// ❌ Adding wrapper divs breaks keyboard navigation
<Dialog.Root>
  <div className="wrapper">
    <Dialog.Trigger>Open</Dialog.Trigger>
  </div>
  <div className="overlay-wrapper">
    <Dialog.Overlay />
  </div>
</Dialog.Root>
```

**Why it's bad**: Extra wrappers interfere with Radix's accessibility features, ARIA relationships, and keyboard navigation.

**Do this instead**:
```typescript
// ✅ Keep Radix components as direct children
<Dialog.Root>
  <Dialog.Trigger className="custom-styles">Open</Dialog.Trigger>
  <Dialog.Portal>
    <Dialog.Overlay className="custom-overlay-styles" />
  </Dialog.Portal>
</Dialog.Root>
```

---

### ❌ Anti-Pattern 2: Ignoring Portal

**Don't do this**:
```typescript
// ❌ No portal - will be clipped by overflow:hidden parents
<Dialog.Root>
  <Dialog.Overlay className="fixed inset-0 bg-black/50" />
  <Dialog.Content className="fixed top-1/2 left-1/2">
    Content
  </Dialog.Content>
</Dialog.Root>
```

**Why it's bad**: Parent containers with `overflow: hidden` will clip your modal, making it invisible.

**Do this instead**:
```typescript
// ✅ Always use Portal for overlays
<Dialog.Root>
  <Dialog.Portal>
    <Dialog.Overlay className="fixed inset-0 bg-black/50" />
    <Dialog.Content className="fixed top-1/2 left-1/2">
      Content
    </Dialog.Content>
  </Dialog.Portal>
</Dialog.Root>
```

---

### ❌ Anti-Pattern 3: Missing Keyboard Navigation Styles

**Don't do this**:
```typescript
// ❌ No visible focus state
<DropdownMenu.Item className="px-3 py-2 hover:bg-gray-100">
  Profile
</DropdownMenu.Item>
```

**Why it's bad**: Keyboard users can't see which item is focused, breaking accessibility.

**Do this instead**:
```typescript
// ✅ Include focus-visible styles
<DropdownMenu.Item className="px-3 py-2 hover:bg-gray-100 focus-visible:bg-blue-100 focus-visible:outline-none">
  Profile
</DropdownMenu.Item>
```

---

### ❌ Anti-Pattern 4: Not Using asChild for Custom Components

**Don't do this**:
```typescript
// ❌ Wrapper button loses Radix functionality
<Dialog.Trigger>
  <Button>Open</Button>
</Dialog.Trigger>
```

**Why it's bad**: Creates nested buttons (invalid HTML) and duplicates event handlers.

**Do this instead**:
```typescript
// ✅ asChild merges props into Button
<Dialog.Trigger asChild>
  <Button>Open</Button>
</Dialog.Trigger>
```

---

### ❌ Anti-Pattern 5: Hardcoding Animations

**Don't do this**:
```typescript
// ❌ Animations not synchronized with open state
const [open, setOpen] = useState(false);

<Dialog.Content className={open ? 'animate-in' : 'animate-out'}>
  Content
</Dialog.Content>
```

**Why it's bad**: Animation timing doesn't match Radix's state transitions.

**Do this instead**:
```typescript
// ✅ Use data attributes for state-based styling
<Dialog.Content className="data-[state=open]:animate-in data-[state=closed]:animate-out">
  Content
</Dialog.Content>
```

---

## What This Skill Covers

- **Primitive components** (Dialog, Dropdown, Popover, etc.)
- **Accessibility** built-in (ARIA, keyboard navigation)
- **Integration** with Tailwind CSS and shadcn/ui

For all components, see [references/](./references/).

---

## Dialog

```typescript
import * as Dialog from '@radix-ui/react-dialog';

export function DialogDemo() {
  return (
    <Dialog.Root>
      <Dialog.Trigger asChild>
        <button>Open Dialog</button>
      </Dialog.Trigger>

      <Dialog.Portal>
        <Dialog.Overlay className="fixed inset-0 bg-black/50" />
        <Dialog.Content className="fixed left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 bg-white p-6 rounded-lg">
          <Dialog.Title>Edit Profile</Dialog.Title>
          <Dialog.Description>Make changes here.</Dialog.Description>
          
          <Dialog.Close asChild>
            <button>Close</button>
          </Dialog.Close>
        </Dialog.Content>
      </Dialog.Portal>
    </Dialog.Root>
  );
}
```

---

## Dropdown Menu

```typescript
import * as DropdownMenu from '@radix-ui/react-dropdown-menu';

export function DropdownDemo() {
  return (
    <DropdownMenu.Root>
      <DropdownMenu.Trigger>Options</DropdownMenu.Trigger>

      <DropdownMenu.Portal>
        <DropdownMenu.Content className="bg-white rounded shadow-lg p-1">
          <DropdownMenu.Item className="px-3 py-2">Profile</DropdownMenu.Item>
          <DropdownMenu.Item className="px-3 py-2">Settings</DropdownMenu.Item>
          <DropdownMenu.Separator className="h-px bg-gray-200" />
          <DropdownMenu.Item className="px-3 py-2 text-red-600">Logout</DropdownMenu.Item>
        </DropdownMenu.Content>
      </DropdownMenu.Portal>
    </DropdownMenu.Root>
  );
}
```

---

## Quick Reference

```typescript
// Dialog
<Dialog.Root>
  <Dialog.Trigger />
  <Dialog.Portal>
    <Dialog.Overlay />
    <Dialog.Content>
      <Dialog.Title />
      <Dialog.Description />
      <Dialog.Close />
    </Dialog.Content>
  </Dialog.Portal>
</Dialog.Root>

// Dropdown
<DropdownMenu.Root>
  <DropdownMenu.Trigger />
  <DropdownMenu.Content>
    <DropdownMenu.Item />
  </DropdownMenu.Content>
</DropdownMenu.Root>
```

---

## Learn More

- **Components Reference**: [references/components.md](./references/components.md) - Select, Checkbox, Radio, Tabs, Accordion, Popover

---

## External References

- [Radix UI Documentation](https://www.radix-ui.com/)
- [Radix Primitives](https://www.radix-ui.com/primitives)

---

_Maintained by dsmj-ai-toolkit_
