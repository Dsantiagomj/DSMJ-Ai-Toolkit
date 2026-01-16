---
name: radix-ui
domain: frontend
description: Accessible headless UI components with Radix UI - Unstyled, accessible components for building design systems. Covers primitives, composition, accessibility, and integration with Tailwind/shadcn.
version: 1.0.0
tags: [radix-ui, react, accessibility, headless-ui, components, a11y]
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
---

# Radix UI - Accessible Headless Components

**Build accessible design systems with unstyled, composable primitives**

---

## What This Skill Covers

This skill provides guidance on:
- **Primitive components** (Dialog, Dropdown, Popover, etc.)
- **Accessibility** built-in (ARIA, keyboard navigation)
- **Composition patterns** for custom components
- **Integration** with Tailwind CSS and shadcn/ui
- **Form components** (Select, Checkbox, Radio, Switch)
- **Overlay components** (Dialog, AlertDialog, Sheet)
- **Navigation components** (Tabs, Accordion, NavigationMenu)

---

## Core Concepts

### Headless UI

Radix UI provides unstyled components focused on:
- **Accessibility**: Full keyboard navigation, ARIA attributes, screen reader support
- **Behavior**: Complex interactions handled for you
- **Flexibility**: Bring your own styles (Tailwind, CSS-in-JS, etc.)
- **Composition**: Build custom components from primitives

### Installation

```bash
# Install specific primitives
npm install @radix-ui/react-dialog
npm install @radix-ui/react-dropdown-menu
npm install @radix-ui/react-popover

# Or install all primitives (not recommended)
npm install @radix-ui/react-*
```

---

## Dialog

```typescript
import * as Dialog from '@radix-ui/react-dialog';

export function DialogDemo() {
  return (
    <Dialog.Root>
      <Dialog.Trigger asChild>
        <button className="btn-primary">Open Dialog</button>
      </Dialog.Trigger>

      <Dialog.Portal>
        <Dialog.Overlay className="fixed inset-0 bg-black/50" />

        <Dialog.Content className="fixed left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 bg-white p-6 rounded-lg shadow-xl max-w-md w-full">
          <Dialog.Title className="text-lg font-semibold mb-2">
            Edit Profile
          </Dialog.Title>

          <Dialog.Description className="text-sm text-gray-600 mb-4">
            Make changes to your profile here. Click save when you're done.
          </Dialog.Description>

          <form>
            <div className="mb-4">
              <label htmlFor="name" className="block text-sm font-medium mb-1">
                Name
              </label>
              <input
                id="name"
                type="text"
                className="w-full px-3 py-2 border rounded"
                placeholder="John Doe"
              />
            </div>

            <div className="flex justify-end gap-2">
              <Dialog.Close asChild>
                <button type="button" className="btn-secondary">
                  Cancel
                </button>
              </Dialog.Close>
              <button type="submit" className="btn-primary">
                Save
              </button>
            </div>
          </form>

          <Dialog.Close asChild>
            <button
              className="absolute top-4 right-4 text-gray-400 hover:text-gray-600"
              aria-label="Close"
            >
              ✕
            </button>
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
      <DropdownMenu.Trigger asChild>
        <button className="btn-secondary">
          Options
          <ChevronDownIcon />
        </button>
      </DropdownMenu.Trigger>

      <DropdownMenu.Portal>
        <DropdownMenu.Content
          className="bg-white rounded-lg shadow-lg p-1 min-w-[220px]"
          sideOffset={5}
        >
          <DropdownMenu.Item className="px-3 py-2 rounded hover:bg-gray-100 cursor-pointer outline-none">
            Profile
            <DropdownMenu.RightSlot>⌘P</DropdownMenu.RightSlot>
          </DropdownMenu.Item>

          <DropdownMenu.Item className="px-3 py-2 rounded hover:bg-gray-100 cursor-pointer outline-none">
            Settings
            <DropdownMenu.RightSlot>⌘S</DropdownMenu.RightSlot>
          </DropdownMenu.Item>

          <DropdownMenu.Separator className="h-px bg-gray-200 my-1" />

          <DropdownMenu.Sub>
            <DropdownMenu.SubTrigger className="px-3 py-2 rounded hover:bg-gray-100 cursor-pointer outline-none">
              More Options
              <RightArrowIcon />
            </DropdownMenu.SubTrigger>

            <DropdownMenu.Portal>
              <DropdownMenu.SubContent
                className="bg-white rounded-lg shadow-lg p-1 min-w-[220px]"
                sideOffset={8}
              >
                <DropdownMenu.Item className="px-3 py-2 rounded hover:bg-gray-100 cursor-pointer">
                  Export
                </DropdownMenu.Item>
                <DropdownMenu.Item className="px-3 py-2 rounded hover:bg-gray-100 cursor-pointer">
                  Import
                </DropdownMenu.Item>
              </DropdownMenu.SubContent>
            </DropdownMenu.Portal>
          </DropdownMenu.Sub>

          <DropdownMenu.Separator className="h-px bg-gray-200 my-1" />

          <DropdownMenu.Item
            className="px-3 py-2 rounded hover:bg-red-100 text-red-600 cursor-pointer outline-none"
            onSelect={() => console.log('Logout')}
          >
            Logout
          </DropdownMenu.Item>

          <DropdownMenu.Arrow className="fill-white" />
        </DropdownMenu.Content>
      </DropdownMenu.Portal>
    </DropdownMenu.Root>
  );
}
```

---

## Popover

```typescript
import * as Popover from '@radix-ui/react-popover';

export function PopoverDemo() {
  return (
    <Popover.Root>
      <Popover.Trigger asChild>
        <button className="btn-secondary">Open Popover</button>
      </Popover.Trigger>

      <Popover.Portal>
        <Popover.Content
          className="bg-white rounded-lg shadow-lg p-4 w-80"
          sideOffset={5}
        >
          <div className="space-y-2">
            <h3 className="font-semibold">Dimensions</h3>
            <p className="text-sm text-gray-600">
              Set the dimensions for the layer.
            </p>

            <div className="grid gap-2">
              <div className="grid grid-cols-3 items-center gap-4">
                <label htmlFor="width" className="text-sm">
                  Width
                </label>
                <input
                  id="width"
                  defaultValue="100%"
                  className="col-span-2 px-2 py-1 border rounded"
                />
              </div>
              <div className="grid grid-cols-3 items-center gap-4">
                <label htmlFor="height" className="text-sm">
                  Height
                </label>
                <input
                  id="height"
                  defaultValue="25px"
                  className="col-span-2 px-2 py-1 border rounded"
                />
              </div>
            </div>
          </div>

          <Popover.Close
            className="absolute top-2 right-2 text-gray-400 hover:text-gray-600"
            aria-label="Close"
          >
            ✕
          </Popover.Close>

          <Popover.Arrow className="fill-white" />
        </Popover.Content>
      </Popover.Portal>
    </Popover.Root>
  );
}
```

---

## Select

```typescript
import * as Select from '@radix-ui/react-select';

export function SelectDemo() {
  return (
    <Select.Root defaultValue="apple">
      <Select.Trigger className="inline-flex items-center justify-between rounded px-4 py-2 text-sm bg-white border gap-2 min-w-[200px]">
        <Select.Value placeholder="Select a fruit..." />
        <Select.Icon>
          <ChevronDownIcon />
        </Select.Icon>
      </Select.Trigger>

      <Select.Portal>
        <Select.Content className="bg-white rounded-lg shadow-lg overflow-hidden">
          <Select.ScrollUpButton className="flex items-center justify-center h-6 bg-white text-gray-700 cursor-default">
            <ChevronUpIcon />
          </Select.ScrollUpButton>

          <Select.Viewport className="p-1">
            <Select.Group>
              <Select.Label className="px-6 py-2 text-xs text-gray-500">
                Fruits
              </Select.Label>

              <SelectItem value="apple">Apple</SelectItem>
              <SelectItem value="banana">Banana</SelectItem>
              <SelectItem value="orange">Orange</SelectItem>
            </Select.Group>

            <Select.Separator className="h-px bg-gray-200 m-1" />

            <Select.Group>
              <Select.Label className="px-6 py-2 text-xs text-gray-500">
                Vegetables
              </Select.Label>

              <SelectItem value="carrot">Carrot</SelectItem>
              <SelectItem value="potato">Potato</SelectItem>
            </Select.Group>
          </Select.Viewport>

          <Select.ScrollDownButton className="flex items-center justify-center h-6 bg-white text-gray-700 cursor-default">
            <ChevronDownIcon />
          </Select.ScrollDownButton>
        </Select.Content>
      </Select.Portal>
    </Select.Root>
  );
}

function SelectItem({ children, ...props }: Select.SelectItemProps) {
  return (
    <Select.Item
      className="relative flex items-center px-6 py-2 rounded text-sm outline-none cursor-pointer hover:bg-gray-100 data-[highlighted]:bg-gray-100"
      {...props}
    >
      <Select.ItemText>{children}</Select.ItemText>
      <Select.ItemIndicator className="absolute left-2">
        <CheckIcon />
      </Select.ItemIndicator>
    </Select.Item>
  );
}
```

---

## Form Components

### Checkbox

```typescript
import * as Checkbox from '@radix-ui/react-checkbox';

export function CheckboxDemo() {
  return (
    <div className="flex items-center gap-2">
      <Checkbox.Root
        id="terms"
        className="flex h-5 w-5 items-center justify-center rounded border border-gray-300 bg-white hover:bg-gray-50 data-[state=checked]:bg-blue-600 data-[state=checked]:border-blue-600"
      >
        <Checkbox.Indicator className="text-white">
          <CheckIcon />
        </Checkbox.Indicator>
      </Checkbox.Root>

      <label htmlFor="terms" className="text-sm cursor-pointer">
        Accept terms and conditions
      </label>
    </div>
  );
}
```

### Radio Group

```typescript
import * as RadioGroup from '@radix-ui/react-radio-group';

export function RadioGroupDemo() {
  return (
    <RadioGroup.Root defaultValue="1" className="space-y-2">
      <div className="flex items-center gap-2">
        <RadioGroup.Item
          value="1"
          id="option-1"
          className="h-5 w-5 rounded-full border border-gray-300 bg-white hover:bg-gray-50 data-[state=checked]:border-blue-600"
        >
          <RadioGroup.Indicator className="flex items-center justify-center w-full h-full relative after:content-[''] after:block after:w-2.5 after:h-2.5 after:rounded-full after:bg-blue-600" />
        </RadioGroup.Item>
        <label htmlFor="option-1" className="text-sm cursor-pointer">
          Option 1
        </label>
      </div>

      <div className="flex items-center gap-2">
        <RadioGroup.Item
          value="2"
          id="option-2"
          className="h-5 w-5 rounded-full border border-gray-300 bg-white hover:bg-gray-50 data-[state=checked]:border-blue-600"
        >
          <RadioGroup.Indicator className="flex items-center justify-center w-full h-full relative after:content-[''] after:block after:w-2.5 after:h-2.5 after:rounded-full after:bg-blue-600" />
        </RadioGroup.Item>
        <label htmlFor="option-2" className="text-sm cursor-pointer">
          Option 2
        </label>
      </div>
    </RadioGroup.Root>
  );
}
```

### Switch

```typescript
import * as Switch from '@radix-ui/react-switch';

export function SwitchDemo() {
  return (
    <div className="flex items-center gap-2">
      <Switch.Root
        id="airplane-mode"
        className="w-11 h-6 bg-gray-200 rounded-full relative data-[state=checked]:bg-blue-600 outline-none cursor-pointer"
      >
        <Switch.Thumb className="block w-5 h-5 bg-white rounded-full transition-transform duration-100 translate-x-0.5 will-change-transform data-[state=checked]:translate-x-[22px]" />
      </Switch.Root>

      <label htmlFor="airplane-mode" className="text-sm cursor-pointer">
        Airplane mode
      </label>
    </div>
  );
}
```

---

## Navigation Components

### Tabs

```typescript
import * as Tabs from '@radix-ui/react-tabs';

export function TabsDemo() {
  return (
    <Tabs.Root defaultValue="account" className="w-full">
      <Tabs.List className="flex border-b border-gray-200">
        <Tabs.Trigger
          value="account"
          className="px-4 py-2 text-sm font-medium text-gray-600 hover:text-gray-900 data-[state=active]:text-blue-600 data-[state=active]:border-b-2 data-[state=active]:border-blue-600"
        >
          Account
        </Tabs.Trigger>

        <Tabs.Trigger
          value="password"
          className="px-4 py-2 text-sm font-medium text-gray-600 hover:text-gray-900 data-[state=active]:text-blue-600 data-[state=active]:border-b-2 data-[state=active]:border-blue-600"
        >
          Password
        </Tabs.Trigger>
      </Tabs.List>

      <Tabs.Content value="account" className="p-4">
        <p className="text-sm">Make changes to your account here.</p>
      </Tabs.Content>

      <Tabs.Content value="password" className="p-4">
        <p className="text-sm">Change your password here.</p>
      </Tabs.Content>
    </Tabs.Root>
  );
}
```

### Accordion

```typescript
import * as Accordion from '@radix-ui/react-accordion';

export function AccordionDemo() {
  return (
    <Accordion.Root type="single" collapsible className="w-full">
      <Accordion.Item value="item-1" className="border-b">
        <Accordion.Header>
          <Accordion.Trigger className="flex w-full items-center justify-between py-4 text-sm font-medium hover:underline">
            Is it accessible?
            <ChevronDownIcon className="transition-transform duration-200 data-[state=open]:rotate-180" />
          </Accordion.Trigger>
        </Accordion.Header>

        <Accordion.Content className="overflow-hidden text-sm data-[state=open]:animate-slideDown data-[state=closed]:animate-slideUp">
          <div className="pb-4 pt-0">
            Yes. It adheres to the WAI-ARIA design pattern.
          </div>
        </Accordion.Content>
      </Accordion.Item>

      <Accordion.Item value="item-2" className="border-b">
        <Accordion.Header>
          <Accordion.Trigger className="flex w-full items-center justify-between py-4 text-sm font-medium hover:underline">
            Is it styled?
            <ChevronDownIcon className="transition-transform duration-200 data-[state=open]:rotate-180" />
          </Accordion.Trigger>
        </Accordion.Header>

        <Accordion.Content className="overflow-hidden text-sm">
          <div className="pb-4 pt-0">
            No. It's unstyled by default, giving you full control.
          </div>
        </Accordion.Content>
      </Accordion.Item>
    </Accordion.Root>
  );
}
```

---

## Integration with shadcn/ui

shadcn/ui is built on top of Radix UI primitives. When using shadcn:

```bash
# Install shadcn component (uses Radix under the hood)
npx shadcn@latest add dialog
npx shadcn@latest add dropdown-menu
npx shadcn@latest add select
```

### Using shadcn Components

```typescript
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/components/ui/dialog';

export function DialogExample() {
  return (
    <Dialog>
      <DialogTrigger asChild>
        <button>Open Dialog</button>
      </DialogTrigger>

      <DialogContent>
        <DialogHeader>
          <DialogTitle>Edit Profile</DialogTitle>
          <DialogDescription>
            Make changes to your profile here.
          </DialogDescription>
        </DialogHeader>

        {/* Your form here */}
      </DialogContent>
    </Dialog>
  );
}
```

---

## Accessibility Features

### Built-in ARIA

All Radix components have proper ARIA attributes:

```typescript
// Radix automatically adds:
// - aria-expanded
// - aria-haspopup
// - aria-controls
// - role attributes
// - aria-labelledby
// - aria-describedby
```

### Keyboard Navigation

```typescript
// Dialog: Escape to close, Tab to cycle focus
// Dropdown: Arrow keys to navigate, Enter/Space to select
// Select: Arrow keys to navigate, Enter to select
// Tabs: Arrow keys to switch tabs
// Accordion: Arrow keys to navigate, Enter/Space to toggle
```

### Focus Management

```typescript
import * as Dialog from '@radix-ui/react-dialog';

// Radix automatically:
// - Traps focus inside dialogs
// - Restores focus when closed
// - Manages focus order
```

---

## Controlled vs Uncontrolled

### Uncontrolled (Default)

```typescript
<Dialog.Root>
  <Dialog.Trigger>Open</Dialog.Trigger>
  <Dialog.Content>{/* Content */}</Dialog.Content>
</Dialog.Root>
```

### Controlled

```typescript
const [open, setOpen] = useState(false);

<Dialog.Root open={open} onOpenChange={setOpen}>
  <Dialog.Trigger>Open</Dialog.Trigger>
  <Dialog.Content>{/* Content */}</Dialog.Content>
</Dialog.Root>
```

---

## Best Practices

### Composition with asChild

```typescript
// ✅ Good: Use asChild to merge props
<Dialog.Trigger asChild>
  <button className="custom-button">Open</button>
</Dialog.Trigger>

// ❌ Bad: Creates wrapper element
<Dialog.Trigger>
  <button className="custom-button">Open</button>
</Dialog.Trigger>
```

### Portal for Overlays

```typescript
// ✅ Good: Use Portal for dialogs/popovers
<Dialog.Portal>
  <Dialog.Overlay />
  <Dialog.Content />
</Dialog.Portal>

// ❌ Bad: No portal (z-index issues)
<Dialog.Overlay />
<Dialog.Content />
```

### Accessible Labels

```typescript
// ✅ Good: Always provide labels
<Dialog.Title>Edit Profile</Dialog.Title>
<Dialog.Description>Make changes here.</Dialog.Description>

// ❌ Bad: Missing accessibility labels
<div>Edit Profile</div>
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

// Dropdown Menu
<DropdownMenu.Root>
  <DropdownMenu.Trigger />
  <DropdownMenu.Portal>
    <DropdownMenu.Content>
      <DropdownMenu.Item />
      <DropdownMenu.Separator />
    </DropdownMenu.Content>
  </DropdownMenu.Portal>
</DropdownMenu.Root>

// Select
<Select.Root>
  <Select.Trigger>
    <Select.Value />
  </Select.Trigger>
  <Select.Portal>
    <Select.Content>
      <Select.Item />
    </Select.Content>
  </Select.Portal>
</Select.Root>

// Checkbox
<Checkbox.Root>
  <Checkbox.Indicator />
</Checkbox.Root>

// Tabs
<Tabs.Root>
  <Tabs.List>
    <Tabs.Trigger />
  </Tabs.List>
  <Tabs.Content />
</Tabs.Root>
```

---

## References

- [Radix UI Documentation](https://www.radix-ui.com/)
- [Radix Primitives](https://www.radix-ui.com/primitives)
- [Radix UI GitHub](https://github.com/radix-ui/primitives)

---

_Maintained by dsmj-ai-toolkit_
