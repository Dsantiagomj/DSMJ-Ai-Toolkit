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
references:
  - name: WCAG 2.2 Guidelines
    url: https://www.w3.org/TR/WCAG22/
    type: documentation
  - name: WCAG Quick Reference
    url: https://www.w3.org/WAI/WCAG22/quickref/
    type: documentation
  - name: ARIA Authoring Practices
    url: https://www.w3.org/WAI/ARIA/apg/
    type: documentation
---

# Accessibility - WCAG Compliance & A11y Best Practices

**Build inclusive web experiences for all users**

---

## What This Skill Covers

This skill provides guidance on:
- **WCAG 2.2** compliance levels (A, AA, AAA)
- **ARIA** attributes and roles
- **Keyboard navigation** patterns
- **Screen reader** compatibility
- **Color contrast** requirements
- **Semantic HTML** for accessibility
- **Form accessibility** and error handling
- **Focus management**

---

## WCAG Conformance Levels

**Level A** (Minimum):
- Essential accessibility features
- Legal requirement in many jurisdictions
- **Must pass** for any public website

**Level AA** (Recommended):
- Target for most websites
- Covers most common accessibility barriers
- **Industry standard**

**Level AAA** (Enhanced):
- Highest level of accessibility
- Not possible for all content
- Apply where feasible

**Note**: You must pass ALL Level A criteria to conform at any level.

---

## Semantic HTML

**Use correct HTML elements** for their purpose:

```html
<!-- ❌ Bad: Divs for everything -->
<div class="header">
  <div class="nav">
    <div onclick="navigate()">Home</div>
    <div onclick="navigate()">About</div>
  </div>
</div>
<div class="main-content">
  <div class="article">
    <div class="title">Article Title</div>
    <div class="content">Article content...</div>
  </div>
</div>

<!-- ✅ Good: Semantic elements -->
<header>
  <nav>
    <a href="/">Home</a>
    <a href="/about">About</a>
  </nav>
</header>
<main>
  <article>
    <h1>Article Title</h1>
    <p>Article content...</p>
  </article>
</main>
```

**Benefits**:
- Screen readers understand document structure
- Keyboard navigation works automatically
- SEO benefits
- Clearer code

---

## Keyboard Navigation

**All interactive elements must be keyboard accessible**:

```html
<!-- ❌ Bad: Non-focusable div -->
<div onclick="handleClick()">Click me</div>

<!-- ✅ Good: Button is focusable -->
<button onClick={handleClick}>Click me</button>

<!-- ✅ Good: Div with tabindex and role -->
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

**Tab order** (tabindex):
```html
<!-- Natural tab order (use this when possible) -->
<button>First</button>
<button>Second</button>
<button>Third</button>

<!-- tabindex="0" - Adds to natural tab order -->
<div tabIndex={0}>Focusable div</div>

<!-- tabindex="-1" - Programmatically focusable only -->
<div tabIndex={-1} ref={skipLinkRef}>Skip to main content</div>

<!-- ❌ Bad: tabindex > 0 (disrupts natural order) -->
<button tabIndex={5}>Don't do this</button>
```

**Keyboard shortcuts**:
```
Tab           - Move to next focusable element
Shift + Tab   - Move to previous focusable element
Enter         - Activate button/link
Space         - Activate button, toggle checkbox
Arrow keys    - Navigate within components (tabs, menus, etc.)
Escape        - Close modal/dropdown
```

**Example** (React modal):
```typescript
function Modal({ isOpen, onClose, children }) {
  const modalRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (isOpen) {
      // Focus first focusable element
      modalRef.current?.focus();

      // Trap focus inside modal
      const handleKeyDown = (e: KeyboardEvent) => {
        if (e.key === 'Escape') {
          onClose();
        }
      };

      document.addEventListener('keydown', handleKeyDown);
      return () => document.removeEventListener('keydown', handleKeyDown);
    }
  }, [isOpen, onClose]);

  if (!isOpen) return null;

  return (
    <div
      ref={modalRef}
      role="dialog"
      aria-modal="true"
      tabIndex={-1}
      className="modal"
    >
      <button onClick={onClose} aria-label="Close modal">
        ×
      </button>
      {children}
    </div>
  );
}
```

---

## ARIA Attributes

**Use ARIA to enhance semantics when HTML isn't enough**.

### Roles

```html
<!-- Landmark roles (use semantic HTML instead when possible) -->
<div role="banner"><!-- Use <header> instead --></div>
<div role="navigation"><!-- Use <nav> instead --></div>
<div role="main"><!-- Use <main> instead --></div>
<div role="complementary"><!-- Use <aside> instead --></div>
<div role="contentinfo"><!-- Use <footer> instead --></div>

<!-- Widget roles (when building custom components) -->
<div role="button" tabIndex={0}>Custom button</div>
<div role="checkbox" aria-checked="false">Custom checkbox</div>
<div role="tab" aria-selected="true">Tab 1</div>
<div role="tabpanel">Tab content</div>
<div role="dialog" aria-modal="true">Modal content</div>
<div role="alert">Error message</div>
```

### aria-label and aria-labelledby

```html
<!-- aria-label: Provide text label -->
<button aria-label="Close dialog">
  <svg><!-- X icon --></svg>
</button>

<input type="search" aria-label="Search products" />

<!-- aria-labelledby: Reference existing element -->
<h2 id="dialog-title">Confirm Delete</h2>
<div role="dialog" aria-labelledby="dialog-title">
  <p>Are you sure you want to delete this item?</p>
</div>

<!-- aria-describedby: Additional description -->
<input
  type="password"
  aria-label="Password"
  aria-describedby="password-requirements"
/>
<div id="password-requirements">
  Must be at least 8 characters
</div>
```

### aria-hidden

```html
<!-- Hide decorative elements from screen readers -->
<button>
  <svg aria-hidden="true"><!-- Decorative icon --></svg>
  Save
</button>

<!-- ⚠️ Never hide interactive elements -->
<!-- ❌ Bad -->
<button aria-hidden="true">Click me</button>
```

### aria-live (Dynamic Content)

```html
<!-- Announce dynamic updates to screen readers -->

<!-- polite: Announce when user is idle -->
<div aria-live="polite" aria-atomic="true">
  {statusMessage}
</div>

<!-- assertive: Announce immediately -->
<div aria-live="assertive" role="alert">
  {errorMessage}
</div>

<!-- Example: Loading state -->
<div aria-live="polite" aria-busy={isLoading}>
  {isLoading ? 'Loading...' : 'Content loaded'}
</div>
```

### aria-expanded and aria-controls

```html
<!-- Expandable sections -->
<button
  aria-expanded={isOpen}
  aria-controls="content-section"
  onClick={() => setIsOpen(!isOpen)}
>
  Toggle Section
</button>
<div id="content-section" hidden={!isOpen}>
  Content goes here
</div>
```

---

## Form Accessibility

### Labels and Input Association

```html
<!-- ✅ Good: Explicit label -->
<label htmlFor="email">Email address *</label>
<input
  id="email"
  type="email"
  aria-required="true"
  aria-invalid={hasError}
  aria-describedby={hasError ? "email-error" : undefined}
/>
{hasError && (
  <div id="email-error" role="alert">
    Please enter a valid email address
  </div>
)}

<!-- ✅ Good: Implicit label -->
<label>
  Email address *
  <input type="email" required />
</label>

<!-- ❌ Bad: No label -->
<input type="email" placeholder="Email" />
```

### Required Fields

```html
<!-- Visual indicator + programmatic -->
<label htmlFor="username">
  Username <span aria-hidden="true">*</span>
</label>
<input
  id="username"
  type="text"
  aria-required="true"
  required
/>

<!-- Or use aria-label -->
<input
  type="text"
  aria-label="Username (required)"
  required
/>
```

### Error Messages

```html
<!-- Example: React form with validation -->
function EmailInput({ value, onChange, error }) {
  const errorId = 'email-error';

  return (
    <div>
      <label htmlFor="email">Email *</label>
      <input
        id="email"
        type="email"
        value={value}
        onChange={onChange}
        aria-required="true"
        aria-invalid={!!error}
        aria-describedby={error ? errorId : undefined}
      />
      {error && (
        <div id={errorId} role="alert" className="error">
          {error}
        </div>
      )}
    </div>
  );
}
```

### Fieldsets and Legends

```html
<!-- Group related inputs -->
<fieldset>
  <legend>Shipping Address</legend>
  <label htmlFor="street">Street</label>
  <input id="street" type="text" />

  <label htmlFor="city">City</label>
  <input id="city" type="text" />

  <label htmlFor="zip">ZIP Code</label>
  <input id="zip" type="text" />
</fieldset>

<!-- Radio buttons -->
<fieldset>
  <legend>Select payment method</legend>
  <label>
    <input type="radio" name="payment" value="card" />
    Credit Card
  </label>
  <label>
    <input type="radio" name="payment" value="paypal" />
    PayPal
  </label>
</fieldset>
```

---

## Color Contrast

**WCAG 2.2 Requirements**:

**Text**:
- Level AA: 4.5:1 contrast ratio (normal text)
- Level AA: 3:1 contrast ratio (large text - 18pt+ or 14pt+ bold)
- Level AAA: 7:1 contrast ratio (normal text)
- Level AAA: 4.5:1 contrast ratio (large text)

**UI Components** (buttons, form borders):
- Level AA: 3:1 contrast ratio
- Against adjacent colors

```css
/* ❌ Bad: Insufficient contrast */
.text {
  color: #777777; /* 4.5:1 against white - fails AA */
  background: #ffffff;
}

/* ✅ Good: Meets AA */
.text {
  color: #595959; /* 7:1 against white - passes AAA */
  background: #ffffff;
}

/* ✅ Good: Large text meets AA */
.heading {
  color: #767676; /* 4.6:1 - passes AA for large text */
  font-size: 24px;
  font-weight: bold;
}

/* UI component contrast */
.button {
  background: #0066cc;
  border: 2px solid #004080; /* 3:1 contrast with background */
}
```

**Tools**:
- [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/)
- Browser DevTools (Chrome, Firefox have built-in checkers)

---

## Focus Indicators

**All focusable elements must have visible focus indicator**:

```css
/* ❌ Bad: Removing outline */
button:focus {
  outline: none; /* Don't do this! */
}

/* ✅ Good: Custom focus style with sufficient contrast */
button:focus-visible {
  outline: 2px solid #0066cc;
  outline-offset: 2px;
}

/* ✅ Good: High contrast focus ring */
a:focus-visible {
  outline: 3px solid #000;
  outline-offset: 3px;
}

/* Focus within (for containers) */
.card:focus-within {
  box-shadow: 0 0 0 3px rgba(0, 102, 204, 0.5);
}
```

**WCAG 2.2 Requirement**: Focus indicator must have 3:1 contrast against adjacent colors.

---

## Screen Reader Support

### Skip Links

```html
<!-- Allow keyboard users to skip to main content -->
<a href="#main-content" className="skip-link">
  Skip to main content
</a>

<header>
  <!-- Navigation -->
</header>

<main id="main-content" tabIndex={-1}>
  <!-- Main content -->
</main>

<style>
  .skip-link {
    position: absolute;
    top: -40px;
    left: 0;
    background: #000;
    color: #fff;
    padding: 8px;
    z-index: 100;
  }

  .skip-link:focus {
    top: 0;
  }
</style>
```

### Heading Hierarchy

```html
<!-- ✅ Good: Logical heading structure -->
<h1>Page Title</h1>
  <h2>Section 1</h2>
    <h3>Subsection 1.1</h3>
    <h3>Subsection 1.2</h3>
  <h2>Section 2</h2>
    <h3>Subsection 2.1</h3>

<!-- ❌ Bad: Skipping levels -->
<h1>Page Title</h1>
  <h3>Should be h2</h3>
  <h2>Out of order</h2>
```

### Image Alt Text

```html
<!-- ✅ Good: Descriptive alt text -->
<img src="chart.png" alt="Bar chart showing sales increased 25% in Q4" />

<!-- ✅ Good: Decorative image (empty alt) -->
<img src="decorative-border.png" alt="" />

<!-- ✅ Good: Icon with text -->
<button>
  <img src="save-icon.png" alt="" aria-hidden="true" />
  Save
</button>

<!-- ❌ Bad: No alt attribute -->
<img src="photo.png" />

<!-- ❌ Bad: Redundant alt text -->
<img src="photo.png" alt="Image of photo" />
```

### Announcements

```typescript
// Custom hook for screen reader announcements
function useAnnounce() {
  const announce = (message: string, priority: 'polite' | 'assertive' = 'polite') => {
    const announcement = document.createElement('div');
    announcement.setAttribute('role', 'status');
    announcement.setAttribute('aria-live', priority);
    announcement.setAttribute('aria-atomic', 'true');
    announcement.className = 'sr-only';
    announcement.textContent = message;

    document.body.appendChild(announcement);

    setTimeout(() => {
      document.body.removeChild(announcement);
    }, 1000);
  };

  return announce;
}

// Usage
function ProductList() {
  const announce = useAnnounce();

  const handleAddToCart = (product) => {
    addToCart(product);
    announce(`${product.name} added to cart`, 'polite');
  };

  return (
    <button onClick={() => handleAddToCart(product)}>
      Add to Cart
    </button>
  );
}

// CSS for sr-only (screen reader only)
.sr-only {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
  border-width: 0;
}
```

---

## Common Patterns

### Accessible Button

```typescript
interface ButtonProps {
  children: React.ReactNode;
  onClick: () => void;
  disabled?: boolean;
  ariaLabel?: string;
  type?: 'button' | 'submit' | 'reset';
}

function AccessibleButton({
  children,
  onClick,
  disabled = false,
  ariaLabel,
  type = 'button',
}: ButtonProps) {
  return (
    <button
      type={type}
      onClick={onClick}
      disabled={disabled}
      aria-label={ariaLabel}
      aria-disabled={disabled}
    >
      {children}
    </button>
  );
}
```

### Accessible Modal

```typescript
function AccessibleModal({ isOpen, onClose, title, children }) {
  const modalRef = useRef<HTMLDivElement>(null);
  const previousFocus = useRef<HTMLElement | null>(null);

  useEffect(() => {
    if (isOpen) {
      // Save current focus
      previousFocus.current = document.activeElement as HTMLElement;

      // Focus modal
      modalRef.current?.focus();

      // Prevent body scroll
      document.body.style.overflow = 'hidden';
    } else {
      // Restore focus
      previousFocus.current?.focus();

      // Restore body scroll
      document.body.style.overflow = '';
    }
  }, [isOpen]);

  if (!isOpen) return null;

  return (
    <div
      className="modal-overlay"
      onClick={onClose}
      role="presentation"
    >
      <div
        ref={modalRef}
        role="dialog"
        aria-modal="true"
        aria-labelledby="modal-title"
        tabIndex={-1}
        onClick={(e) => e.stopPropagation()}
        onKeyDown={(e) => {
          if (e.key === 'Escape') onClose();
        }}
      >
        <h2 id="modal-title">{title}</h2>
        <button
          onClick={onClose}
          aria-label="Close dialog"
        >
          ×
        </button>
        {children}
      </div>
    </div>
  );
}
```

---

## Testing Accessibility

### Automated Tools
- **axe DevTools** (browser extension)
- **Lighthouse** (Chrome DevTools)
- **WAVE** (browser extension)
- **ESLint plugin**: `eslint-plugin-jsx-a11y`

### Manual Testing
1. **Keyboard navigation**: Tab through entire page
2. **Screen reader**: Use NVDA (Windows), JAWS (Windows), VoiceOver (Mac/iOS)
3. **Zoom**: Test at 200% zoom
4. **Color blindness**: Use browser extensions to simulate
5. **Contrast**: Check with contrast checker tools

### Example Test Checklist
```
✅ All interactive elements keyboard accessible
✅ Focus indicators visible
✅ Logical tab order
✅ All images have alt text
✅ Form inputs have labels
✅ Color contrast meets AA
✅ Headings in logical order
✅ ARIA attributes used correctly
✅ Modal traps focus
✅ Error messages announced
```

---

## Quick Reference

**Minimum Requirements (WCAG AA)**:
- ✅ 4.5:1 text contrast (3:1 for large text)
- ✅ 3:1 UI component contrast
- ✅ All functionality keyboard accessible
- ✅ Visible focus indicators
- ✅ Text resizable to 200%
- ✅ All form inputs labeled
- ✅ Meaningful alt text for images
- ✅ Logical heading structure
- ✅ Error messages clear and announced
- ✅ No reliance on color alone

---

## References

- [WCAG 2.2 Guidelines](https://www.w3.org/TR/WCAG22/)
- [WCAG Quick Reference](https://www.w3.org/WAI/WCAG22/quickref/)
- [ARIA Authoring Practices](https://www.w3.org/WAI/ARIA/apg/)

---

_Maintained by dsmj-ai-toolkit_
