# Component Reference - Radix UI

## Select

```typescript
import * as Select from '@radix-ui/react-select';

<Select.Root defaultValue="apple">
  <Select.Trigger>
    <Select.Value placeholder="Select..." />
  </Select.Trigger>
  <Select.Portal>
    <Select.Content>
      <Select.Item value="apple">Apple</Select.Item>
      <Select.Item value="banana">Banana</Select.Item>
    </Select.Content>
  </Select.Portal>
</Select.Root>
```

## Checkbox

```typescript
import * as Checkbox from '@radix-ui/react-checkbox';

<Checkbox.Root id="terms" className="...">
  <Checkbox.Indicator>✓</Checkbox.Indicator>
</Checkbox.Root>
```

## Tabs

```typescript
import * as Tabs from '@radix-ui/react-tabs';

<Tabs.Root defaultValue="account">
  <Tabs.List>
    <Tabs.Trigger value="account">Account</Tabs.Trigger>
    <Tabs.Trigger value="password">Password</Tabs.Trigger>
  </Tabs.List>
  <Tabs.Content value="account">Account content</Tabs.Content>
  <Tabs.Content value="password">Password content</Tabs.Content>
</Tabs.Root>
```

## Accordion

```typescript
import * as Accordion from '@radix-ui/react-accordion';

<Accordion.Root type="single" collapsible>
  <Accordion.Item value="item-1">
    <Accordion.Header>
      <Accordion.Trigger>Is it accessible?</Accordion.Trigger>
    </Accordion.Header>
    <Accordion.Content>Yes. It adheres to the WAI-ARIA design pattern.</Accordion.Content>
  </Accordion.Item>
</Accordion.Root>
```
