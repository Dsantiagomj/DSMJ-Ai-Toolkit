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
