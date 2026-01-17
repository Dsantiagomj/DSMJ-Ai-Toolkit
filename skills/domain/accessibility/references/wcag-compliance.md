# WCAG 2.2 Compliance Guide

Complete guide to WCAG conformance levels and requirements.

---

## Conformance Levels

**Level A** (Minimum):
- Essential accessibility features
- Legal requirement in many jurisdictions  
- Must pass for any public website

**Level AA** (Recommended):
- Industry standard target
- Covers most common accessibility barriers

**Level AAA** (Enhanced):
- Highest level
- Not possible for all content

---

## Color Contrast Requirements

**Text**:
- Level AA: 4.5:1 contrast ratio (normal text)
- Level AA: 3:1 contrast ratio (large text - 18pt+ or 14pt+ bold)
- Level AAA: 7:1 contrast ratio (normal text)

**UI Components**:
- Level AA: 3:1 contrast ratio against adjacent colors

```css
/* ✅ Good: Meets AA */
.text {
  color: #595959; /* 7:1 against white - passes AAA */
  background: #ffffff;
}

/* ❌ Bad: Insufficient contrast */
.text {
  color: #777777; /* 4.5:1 against white - fails AA */
  background: #ffffff;
}
```

---

## ARIA Attributes

### Landmark Roles
```html
<div role="banner"><!-- Use <header> instead --></div>
<div role="navigation"><!-- Use <nav> instead --></div>
<div role="main"><!-- Use <main> instead --></div>
```

### Widget Roles
```html
<div role="button" tabIndex={0}>Custom button</div>
<div role="dialog" aria-modal="true">Modal content</div>
<div role="alert">Error message</div>
```

### Labels
```html
<!-- aria-label -->
<button aria-label="Close dialog">
  <svg><!-- X icon --></svg>
</button>

<!-- aria-labelledby -->
<h2 id="dialog-title">Confirm Delete</h2>
<div role="dialog" aria-labelledby="dialog-title">
  <p>Are you sure?</p>
</div>

<!-- aria-describedby -->
<input
  type="password"
  aria-describedby="password-requirements"
/>
<div id="password-requirements">
  Must be at least 8 characters
</div>
```

### Dynamic Content
```html
<!-- polite: Announce when idle -->
<div aria-live="polite" aria-atomic="true">
  {statusMessage}
</div>

<!-- assertive: Announce immediately -->
<div aria-live="assertive" role="alert">
  {errorMessage}
</div>
```

---

## Form Accessibility

```html
<!-- ✅ Explicit label -->
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

<!-- ✅ Required fields -->
<label htmlFor="username">
  Username <span aria-hidden="true">*</span>
</label>
<input
  id="username"
  type="text"
  aria-required="true"
  required
/>
```

---

## Screen Reader Support

### Skip Links
```html
<a href="#main-content" className="skip-link">
  Skip to main content
</a>

<main id="main-content" tabIndex={-1}>
  <!-- Content -->
</main>
```

### Image Alt Text
```html
<!-- ✅ Descriptive alt -->
<img src="chart.png" alt="Bar chart showing 25% sales increase" />

<!-- ✅ Decorative (empty alt) -->
<img src="border.png" alt="" />

<!-- ❌ No alt -->
<img src="photo.png" />
```

---

_Maintained by dsmj-ai-toolkit_
