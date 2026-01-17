---
name: accessibility
domain: frontend
description: >
  Web accessibility (a11y) patterns and WCAG compliance. Covers WCAG 2.2 Level A/AA/AAA, ARIA attributes, keyboard navigation, screen reader support, color contrast, and semantic HTML.
  Trigger: When implementing accessibility features, when building accessible components, when ensuring WCAG compliance, when adding ARIA attributes, when handling keyboard navigation.
version: 1.0.0
tags: [accessibility, a11y, wcag, aria, keyboard-navigation, screen-readers]
metadata:
  version: "1.0"
  last_updated: "2026-01-17"
  category: domain
  progressive_disclosure: true
references:
  - name: WCAG Compliance
    url: ./references/wcag-compliance.md
    type: local
  - name: Keyboard Navigation
    url: ./references/keyboard-navigation.md
    type: local
  - name: WCAG 2.2 Guidelines
    url: https://www.w3.org/TR/WCAG22/
    type: documentation
  - name: ARIA Authoring Practices
    url: https://www.w3.org/WAI/ARIA/apg/
    type: documentation
---

# Accessibility - WCAG Compliance & A11y Best Practices

**Build inclusive web experiences for all users**

---

## When to Use This Skill

Use this skill when:
- Implementing accessible components
- Ensuring WCAG compliance
- Adding ARIA attributes
- Handling keyboard navigation
- Supporting screen readers
- Checking color contrast

---

## Critical Patterns

### Pattern 1: Semantic HTML

**When**: Building accessible structure

**Good**:
```html
<!-- ✅ Semantic elements -->
<header>
  <nav>
    <a href="/">Home</a>
    <a href="/about">About</a>
  </nav>
</header>
<main>
  <article>
    <h1>Article Title</h1>
    <p>Content...</p>
  </article>
</main>
```

**Bad**:
```html
<!-- ❌ Divs for everything -->
<div class="header">
  <div class="nav">
    <div onclick="navigate()">Home</div>
  </div>
</div>
```

**Why**: Semantic HTML provides structure for screen readers and enables automatic keyboard navigation.

---

### Pattern 2: Keyboard Navigation

**When**: Making interactive elements accessible

**Good**:
```html
<!-- ✅ Button is focusable -->
<button onClick={handleClick}>Click me</button>

<!-- ✅ Div with proper keyboard support -->
<div
  role="button"
  tabIndex={0}
  onClick={handleClick}
  onKeyDown={(e) => {
    if (e.key === 'Enter' || e.key === ' ') {
      handleClick();
    }
  }}
>
  Click me
</div>
```

**Bad**:
```html
<!-- ❌ Non-focusable div -->
<div onclick="handleClick()">Click me</div>
```

**Why**: All interactive elements must be keyboard accessible. Use native elements when possible.

---

### Pattern 3: ARIA Labels

**When**: Providing accessible names

**Good**:
```html
<!-- ✅ aria-label for icon buttons -->
<button aria-label="Close dialog">
  <svg><!-- X icon --></svg>
</button>

<!-- ✅ aria-labelledby for dialogs -->
<h2 id="dialog-title">Confirm Delete</h2>
<div role="dialog" aria-labelledby="dialog-title">
  <p>Are you sure?</p>
</div>
```

**Bad**:
```html
<!-- ❌ No accessible name -->
<button>
  <svg><!-- X icon --></svg>
</button>
```

**Why**: Screen readers need text labels to understand interactive elements.

---

### Pattern 4: Form Accessibility

**When**: Building accessible forms

**Good**:
```html
<!-- ✅ Explicit label association -->
<label htmlFor="email">Email *</label>
<input
  id="email"
  type="email"
  aria-required="true"
  aria-invalid={hasError}
  aria-describedby={hasError ? "email-error" : undefined}
/>
{hasError && (
  <div id="email-error" role="alert">
    Please enter a valid email
  </div>
)}
```

**Bad**:
```html
<!-- ❌ No label -->
<input type="email" placeholder="Email" />
```

**Why**: Labels are required for screen readers. Error messages must be announced.

---

### Pattern 5: Color Contrast

**When**: Ensuring readability

**Good**:
```css
/* ✅ Meets AA (7:1) */
.text {
  color: #595959;
  background: #ffffff;
}
```

**Bad**:
```css
/* ❌ Fails AA (4.5:1) */
.text {
  color: #777777;
  background: #ffffff;
}
```

**Why**: WCAG AA requires 4.5:1 for normal text, 3:1 for large text.

---

## Code Examples

### Example 1: Accessible Form with Validation

```tsx
export function SignupForm() {
  const [errors, setErrors] = useState<Record<string, string>>({});

  return (
    <form onSubmit={handleSubmit}>
      <div className="space-y-1">
        <label htmlFor="email" className="block text-sm font-medium">
          Email Address *
        </label>
        <input
          id="email"
          type="email"
          aria-required="true"
          aria-invalid={!!errors.email}
          aria-describedby={errors.email ? 'email-error' : undefined}
          className={cn(
            'border rounded-lg px-3 py-2',
            errors.email && 'border-red-500'
          )}
        />
        {errors.email && (
          <p id="email-error" role="alert" className="text-sm text-red-600">
            {errors.email}
          </p>
        )}
      </div>

      <button type="submit" className="px-4 py-2 bg-blue-600 text-white rounded-lg">
        Sign Up
      </button>
    </form>
  );
}
```

### Example 2: Keyboard-Accessible Custom Dropdown

```tsx
export function Dropdown({ items, onSelect }: DropdownProps) {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <div>
      <button
        onClick={() => setIsOpen(!isOpen)}
        onKeyDown={(e) => {
          if (e.key === 'Enter' || e.key === ' ') {
            e.preventDefault();
            setIsOpen(!isOpen);
          }
        }}
        aria-haspopup="listbox"
        aria-expanded={isOpen}
      >
        Select Option
      </button>

      {isOpen && (
        <ul role="listbox" tabIndex={-1}>
          {items.map((item, index) => (
            <li
              key={item.id}
              role="option"
              tabIndex={0}
              onClick={() => onSelect(item)}
              onKeyDown={(e) => {
                if (e.key === 'Enter') onSelect(item);
              }}
            >
              {item.label}
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
```

For comprehensive examples and detailed implementations, see the [references/](./references/) folder.

---

## Quick Reference

### WCAG AA Requirements
- ✅ 4.5:1 text contrast (3:1 for large text)
- ✅ 3:1 UI component contrast
- ✅ All functionality keyboard accessible
- ✅ Visible focus indicators
- ✅ Text resizable to 200%
- ✅ Form inputs labeled
- ✅ Meaningful alt text
- ✅ Logical heading structure

### Component States
- [ ] Default
- [ ] Hover
- [ ] Focus (keyboard)
- [ ] Active
- [ ] Disabled
- [ ] Error

---

## Progressive Disclosure

For detailed implementations:
- **[WCAG Compliance](./references/wcag-compliance.md)** - Complete WCAG 2.2 requirements, ARIA patterns, form accessibility
- **[Keyboard Navigation](./references/keyboard-navigation.md)** - Tab order, focus management, keyboard shortcuts

---

## References

- [WCAG Compliance](./references/wcag-compliance.md)
- [Keyboard Navigation](./references/keyboard-navigation.md)
- [WCAG 2.2 Guidelines](https://www.w3.org/TR/WCAG22/)
- [ARIA Authoring Practices](https://www.w3.org/WAI/ARIA/apg/)

---

_Maintained by dsmj-ai-toolkit_
