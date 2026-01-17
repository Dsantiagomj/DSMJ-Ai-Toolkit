---
name: i18n
domain: frontend
description: >
  Internationalization (i18n) patterns for multi-language applications. Covers next-intl, ICU message syntax, pluralization, date/number formatting, RTL support, and locale management.
  Trigger: When implementing translations, when supporting multiple languages, when formatting dates or numbers for different locales, when handling RTL languages.
version: 1.0.0
tags: [i18n, internationalization, localization, next-intl, translations, rtl]
metadata:
  version: "1.0"
  last_updated: "2026-01-17"
  category: domain
  progressive_disclosure: true
references:
  - name: next-intl Setup
    url: ./references/next-intl-setup.md
    type: local
  - name: ICU Patterns
    url: ./references/icu-patterns.md
    type: local
  - name: next-intl Documentation
    url: https://next-intl-docs.vercel.app/
    type: documentation
  - name: ICU Message Format
    url: https://unicode-org.github.io/icu/userguide/format_parse/messages/
    type: documentation
---

# Internationalization (i18n)

**Build applications that speak your users' language**

---

## When to Use This Skill

Use this skill when:
- Implementing multi-language support
- Formatting dates/numbers for different locales
- Handling RTL languages
- Managing translation files

---

## Critical Patterns

### Pattern 1: Basic Translation

**When**: Displaying translated text

**Good**:
```typescript
// useTranslations hook
import { useTranslations } from 'next-intl';

export default function HomePage() {
  const t = useTranslations('homepage');

  return (
    <div>
      <h1>{t('title')}</h1>
      <p>{t('subtitle')}</p>
    </div>
  );
}

// Translation file
// messages/en.json
{
  "homepage": {
    "title": "Welcome to Our Store",
    "subtitle": "Find the best products"
  }
}
```

**Why**: Centralized translations make it easy to support multiple languages.

---

### Pattern 2: Variables in Translations

**When**: Including dynamic values

**Good**:
```json
{
  "welcome": "Welcome, {username}!",
  "itemCount": "You have {count} items"
}
```

```typescript
<p>{t('welcome', { username: 'Alice' })}</p>
<p>{t('itemCount', { count: 5 })}</p>
```

**Why**: ICU syntax allows flexible variable interpolation.

---

### Pattern 3: Pluralization

**When**: Handling singular/plural forms

**Good**:
```json
{
  "items": "{count, plural, =0 {No items} =1 {1 item} other {# items}}"
}
```

```typescript
<p>{t('items', { count: 0 })}</p>  // "No items"
<p>{t('items', { count: 1 })}</p>  // "1 item"
<p>{t('items', { count: 5 })}</p>  // "5 items"
```

**Why**: Different languages have different pluralization rules.

---

### Pattern 4: Date/Number Formatting

**When**: Displaying locale-specific formats

**Good**:
```typescript
import { useFormatter } from 'next-intl';

export default function EventDate({ date, amount }) {
  const format = useFormatter();

  return (
    <div>
      {/* Date: "January 15, 2024" (en), "15 janvier 2024" (fr) */}
      <p>{format.dateTime(date, { dateStyle: 'long' })}</p>

      {/* Currency: "$99.99" (en-US), "99,99 €" (de-DE) */}
      <p>{format.number(amount, {
        style: 'currency',
        currency: 'USD'
      })}</p>
    </div>
  );
}
```

**Why**: Date and number formats vary by locale.

---

### Pattern 5: RTL Support

**When**: Supporting Arabic, Hebrew, etc.

**Good**:
```css
/* Use logical properties */
.card {
  margin-inline-start: 1rem;  /* Left in LTR, right in RTL */
  padding-inline-end: 2rem;
}

/* Manual RTL handling */
[dir='rtl'] .arrow {
  transform: scaleX(-1);
}
```

```typescript
// Set dir attribute
<html lang={locale} dir={locale === 'ar' ? 'rtl' : 'ltr'}>
```

**Why**: RTL languages need flipped layouts.

---

## Best Practices

**Do's**:
- ✅ Extract all user-facing text to translation files
- ✅ Use ICU syntax for complex messages
- ✅ Test with long German text (30% longer)
- ✅ Test RTL languages
- ✅ Format dates/numbers with locale-aware formatters
- ✅ Provide context in translation keys

**Don'ts**:
- ❌ Don't hardcode strings
- ❌ Don't concatenate translations
- ❌ Don't use locale for business logic
- ❌ Don't forget text expansion

---

## Progressive Disclosure

For detailed implementations:
- **[next-intl Setup](./references/next-intl-setup.md)** - Installation, middleware, layouts
- **[ICU Patterns](./references/icu-patterns.md)** - Variables, pluralization, rich text, formatting

---

## References

- [next-intl Setup](./references/next-intl-setup.md)
- [ICU Patterns](./references/icu-patterns.md)
- [next-intl Documentation](https://next-intl-docs.vercel.app/)
- [ICU Message Format](https://unicode-org.github.io/icu/userguide/format_parse/messages/)

---

_Maintained by dsmj-ai-toolkit_
