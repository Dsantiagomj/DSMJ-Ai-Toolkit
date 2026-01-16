---
name: i18n
domain: frontend
description: Internationalization (i18n) patterns for multi-language applications. Covers next-intl, ICU message syntax, pluralization, date/number formatting, RTL support, and locale management.
version: 1.0.0
tags: [i18n, internationalization, localization, next-intl, translations, rtl]
references:
  - name: next-intl Documentation
    url: https://next-intl-docs.vercel.app/
    type: documentation
  - name: ICU Message Format
    url: https://unicode-org.github.io/icu/userguide/format_parse/messages/
    type: documentation
---

# Internationalization (i18n) - Multi-Language Applications

**Build applications that speak your users' language**

---

## What This Skill Covers

This skill provides guidance on:
- **next-intl** setup and usage (Next.js)
- **ICU message syntax** for complex translations
- **Pluralization** rules for different languages
- **Date and number** formatting per locale
- **RTL (right-to-left)** language support
- **Locale routing** and switching
- **Translation file** organization
- **Dynamic content** translation

---

## Setup (Next.js with next-intl)

### Installation

```bash
npm install next-intl
```

### Directory Structure

```
app/
├── [locale]/
│   ├── layout.tsx
│   ├── page.tsx
│   └── products/
│       └── page.tsx
messages/
├── en.json
├── es.json
├── de.json
├── ar.json
└── ja.json
middleware.ts
next.config.js
```

### Middleware (Locale Detection)

```typescript
// middleware.ts
import createMiddleware from 'next-intl/middleware';

export default createMiddleware({
  // Supported locales
  locales: ['en', 'es', 'de', 'ar', 'ja'],

  // Default locale
  defaultLocale: 'en',

  // Locale detection strategy
  localeDetection: true, // Auto-detect from Accept-Language header
});

export const config = {
  // Match all pathnames except static assets
  matcher: ['/((?!api|_next|_vercel|.*\\..*).*)'],
};
```

### Root Layout

```typescript
// app/[locale]/layout.tsx
import { NextIntlClientProvider } from 'next-intl';
import { notFound } from 'next/navigation';

export function generateStaticParams() {
  return [{ locale: 'en' }, { locale: 'es' }, { locale: 'de' }];
}

export default async function LocaleLayout({
  children,
  params: { locale },
}: {
  children: React.ReactNode;
  params: { locale: string };
}) {
  let messages;
  try {
    messages = (await import(`@/messages/${locale}.json`)).default;
  } catch (error) {
    notFound();
  }

  return (
    <html lang={locale} dir={locale === 'ar' ? 'rtl' : 'ltr'}>
      <body>
        <NextIntlClientProvider locale={locale} messages={messages}>
          {children}
        </NextIntlClientProvider>
      </body>
    </html>
  );
}
```

---

## Translation Files

### Basic Translations

```json
// messages/en.json
{
  "common": {
    "welcome": "Welcome",
    "save": "Save",
    "cancel": "Cancel",
    "delete": "Delete",
    "loading": "Loading..."
  },
  "nav": {
    "home": "Home",
    "products": "Products",
    "about": "About Us"
  },
  "homepage": {
    "title": "Welcome to Our Store",
    "subtitle": "Find the best products at great prices"
  }
}
```

```json
// messages/es.json
{
  "common": {
    "welcome": "Bienvenido",
    "save": "Guardar",
    "cancel": "Cancelar",
    "delete": "Eliminar",
    "loading": "Cargando..."
  },
  "nav": {
    "home": "Inicio",
    "products": "Productos",
    "about": "Acerca de Nosotros"
  },
  "homepage": {
    "title": "Bienvenido a Nuestra Tienda",
    "subtitle": "Encuentra los mejores productos a excelentes precios"
  }
}
```

### Using Translations

```typescript
// app/[locale]/page.tsx
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

// Client Component
'use client';
import { useTranslations } from 'next-intl';

export function WelcomeBanner() {
  const t = useTranslations('common');

  return (
    <div>
      <h2>{t('welcome')}</h2>
      <button>{t('save')}</button>
    </div>
  );
}
```

---

## ICU Message Syntax

### Variables

```json
// messages/en.json
{
  "welcome": "Welcome, {username}!",
  "itemCount": "You have {count} items in your cart",
  "profile": "Hello {firstName} {lastName}"
}
```

```typescript
const t = useTranslations();

<p>{t('welcome', { username: 'Alice' })}</p>
// Output: "Welcome, Alice!"

<p>{t('itemCount', { count: 5 })}</p>
// Output: "You have 5 items in your cart"

<p>{t('profile', { firstName: 'John', lastName: 'Doe' })}</p>
// Output: "Hello John Doe"
```

### Rich Text / HTML

```json
{
  "terms": "By continuing, you agree to our <link>Terms of Service</link>",
  "alert": "This is <bold>important</bold> information"
}
```

```typescript
const t = useTranslations();

<p>{t.rich('terms', {
  link: (chunks) => <a href="/terms">{chunks}</a>
})}</p>
// Output: "By continuing, you agree to our <a>Terms of Service</a>"

<p>{t.rich('alert', {
  bold: (chunks) => <strong>{chunks}</strong>
})}</p>
// Output: "This is <strong>important</strong> information"
```

---

## Pluralization

### Simple Plural

```json
// messages/en.json
{
  "items": "{count, plural, =0 {No items} =1 {1 item} other {# items}}"
}
```

```typescript
<p>{t('items', { count: 0 })}</p>  // "No items"
<p>{t('items', { count: 1 })}</p>  // "1 item"
<p>{t('items', { count: 5 })}</p>  // "5 items"
```

### Complex Plural Rules

```json
// messages/en.json
{
  "likes": "{count, plural, =0 {No one likes this} =1 {1 person likes this} other {# people like this}}"
}

// messages/es.json (Spanish has different plural rules)
{
  "likes": "{count, plural, =0 {A nadie le gusta esto} =1 {A 1 persona le gusta esto} other {A # personas les gusta esto}}"
}
```

### Select (Gender)

```json
{
  "invitation": "{gender, select, male {He invited you} female {She invited you} other {They invited you}}"
}
```

```typescript
<p>{t('invitation', { gender: 'male' })}</p>   // "He invited you"
<p>{t('invitation', { gender: 'female' })}</p> // "She invited you"
<p>{t('invitation', { gender: 'other' })}</p>  // "They invited you"
```

### Combined Plural + Select

```json
{
  "message": "{gender, select, male {{count, plural, =0 {He has no messages} =1 {He has 1 message} other {He has # messages}}} female {{count, plural, =0 {She has no messages} =1 {She has 1 message} other {She has # messages}}} other {{count, plural, =0 {They have no messages} =1 {They have 1 message} other {They have # messages}}}}"
}
```

---

## Date and Number Formatting

### Dates

```typescript
import { useFormatter } from 'next-intl';

export function EventDate({ date }: { date: Date }) {
  const format = useFormatter();

  return (
    <div>
      {/* Full date: "January 15, 2024" */}
      <p>{format.dateTime(date, { dateStyle: 'long' })}</p>

      {/* Short date: "1/15/24" */}
      <p>{format.dateTime(date, { dateStyle: 'short' })}</p>

      {/* Custom format */}
      <p>{format.dateTime(date, {
        year: 'numeric',
        month: 'long',
        day: 'numeric',
        weekday: 'long',
      })}</p>
      {/* Output: "Monday, January 15, 2024" */}

      {/* Relative time */}
      <p>{format.relativeTime(date)}</p>
      {/* Output: "2 days ago" */}
    </div>
  );
}
```

### Numbers

```typescript
import { useFormatter } from 'next-intl';

export function Price({ amount }: { amount: number }) {
  const format = useFormatter();

  return (
    <div>
      {/* Currency: "$99.99" (en-US), "99,99 €" (de-DE) */}
      <p>{format.number(amount, {
        style: 'currency',
        currency: 'USD',
      })}</p>

      {/* Percent: "75%" */}
      <p>{format.number(0.75, { style: 'percent' })}</p>

      {/* Compact: "1.2K", "1.2M" */}
      <p>{format.number(1234, { notation: 'compact' })}</p>

      {/* Formatted number: "1,234.56" (en), "1.234,56" (de) */}
      <p>{format.number(1234.56)}</p>
    </div>
  );
}
```

### Time Zones

```typescript
const format = useFormatter();

// Convert to user's timezone
<p>{format.dateTime(date, {
  timeZone: 'America/New_York',
  dateStyle: 'short',
  timeStyle: 'short',
})}</p>

// Show relative time with specific timezone
<p>{format.relativeTime(date, {
  now: new Date(),
  unit: 'day',
})}</p>
```

---

## Locale Switching

### Locale Switcher Component

```typescript
'use client';

import { useLocale } from 'next-intl';
import { useRouter, usePathname } from 'next/navigation';

const locales = [
  { code: 'en', name: 'English', flag: '🇺🇸' },
  { code: 'es', name: 'Español', flag: '🇪🇸' },
  { code: 'de', name: 'Deutsch', flag: '🇩🇪' },
  { code: 'ar', name: 'العربية', flag: '🇸🇦' },
];

export function LocaleSwitcher() {
  const locale = useLocale();
  const router = useRouter();
  const pathname = usePathname();

  const handleChange = (newLocale: string) => {
    // Remove current locale from pathname
    const pathWithoutLocale = pathname.replace(`/${locale}`, '');

    // Navigate to new locale
    router.push(`/${newLocale}${pathWithoutLocale}`);
  };

  return (
    <select value={locale} onChange={(e) => handleChange(e.target.value)}>
      {locales.map(({ code, name, flag }) => (
        <option key={code} value={code}>
          {flag} {name}
        </option>
      ))}
    </select>
  );
}
```

---

## RTL (Right-to-Left) Support

### CSS for RTL

```css
/* Automatic RTL with logical properties */
.card {
  /* Use margin-inline-start instead of margin-left */
  margin-inline-start: 1rem;

  /* Use padding-inline-end instead of padding-right */
  padding-inline-end: 2rem;

  /* Use inset-inline-start instead of left */
  inset-inline-start: 0;
}

/* Manual RTL handling */
[dir='rtl'] .arrow {
  transform: scaleX(-1); /* Flip horizontal */
}

[dir='rtl'] .text-align-start {
  text-align: right;
}
```

### Tailwind CSS with RTL

```typescript
// tailwind.config.ts
export default {
  plugins: [
    require('tailwindcss-rtl'),
  ],
};

// Usage
<div className="ms-4 me-8">
  {/* ms-4 = margin-inline-start: 1rem */}
  {/* me-8 = margin-inline-end: 2rem */}
  {/* Automatically flips for RTL */}
</div>

<div className="text-start">
  {/* text-start = text-align: start (left in LTR, right in RTL) */}
</div>
```

---

## Translation Organization

### Namespacing

```json
// messages/en.json
{
  "common": {
    "actions": {
      "save": "Save",
      "cancel": "Cancel",
      "delete": "Delete"
    },
    "validation": {
      "required": "This field is required",
      "email": "Invalid email address"
    }
  },
  "products": {
    "title": "Products",
    "empty": "No products found",
    "filter": {
      "category": "Category",
      "price": "Price Range",
      "apply": "Apply Filters"
    }
  },
  "checkout": {
    "title": "Checkout",
    "steps": {
      "shipping": "Shipping",
      "payment": "Payment",
      "review": "Review"
    }
  }
}
```

```typescript
// Use namespaces
const t = useTranslations('products.filter');

<button>{t('apply')}</button>
// Output: "Apply Filters"
```

### Shared Translations

```json
// messages/common.json (shared across locales)
{
  "countries": {
    "US": "United States",
    "CA": "Canada",
    "MX": "Mexico"
  },
  "currencies": {
    "USD": "$",
    "EUR": "€",
    "GBP": "£"
  }
}
```

---

## Dynamic Content Translation

### Server-Side Translation

```typescript
// app/[locale]/products/[id]/page.tsx
import { getTranslations } from 'next-intl/server';

export default async function ProductPage({
  params: { locale, id },
}: {
  params: { locale: string; id: string };
}) {
  const t = await getTranslations('products');
  const product = await getProduct(id, locale);

  return (
    <div>
      <h1>{product.name}</h1>
      <p>{product.description}</p>
      <button>{t('addToCart')}</button>
    </div>
  );
}
```

### Translation Keys from Database

```typescript
// Store translation keys in database
const product = {
  id: 1,
  nameKey: 'products.laptop.name',
  descriptionKey: 'products.laptop.description',
};

// messages/en.json
{
  "products": {
    "laptop": {
      "name": "Laptop Computer",
      "description": "High-performance laptop for professionals"
    }
  }
}

// Render
const t = useTranslations();

<h1>{t(product.nameKey)}</h1>
<p>{t(product.descriptionKey)}</p>
```

---

## Testing Translations

### Check for Missing Keys

```typescript
// scripts/check-translations.ts
import en from './messages/en.json';
import es from './messages/es.json';
import de from './messages/de.json';

function flattenKeys(obj: any, prefix = ''): string[] {
  return Object.keys(obj).reduce((keys: string[], key) => {
    const path = prefix ? `${prefix}.${key}` : key;
    if (typeof obj[key] === 'object' && obj[key] !== null) {
      return [...keys, ...flattenKeys(obj[key], path)];
    }
    return [...keys, path];
  }, []);
}

const enKeys = new Set(flattenKeys(en));
const esKeys = new Set(flattenKeys(es));
const deKeys = new Set(flattenKeys(de));

// Check for missing keys
const missingInEs = [...enKeys].filter(key => !esKeys.has(key));
const missingInDe = [...enKeys].filter(key => !deKeys.has(key));

if (missingInEs.length > 0) {
  console.error('Missing in es.json:', missingInEs);
}

if (missingInDe.length > 0) {
  console.error('Missing in de.json:', missingInDe);
}
```

---

## Best Practices

### Do's
- ✅ Extract all user-facing text to translation files
- ✅ Use ICU syntax for complex messages (plurals, gender)
- ✅ Test with long German text (30% longer than English)
- ✅ Test RTL languages (Arabic, Hebrew)
- ✅ Use logical CSS properties (margin-inline-start)
- ✅ Format dates/numbers with locale-aware formatters
- ✅ Provide context in translation keys (`products.addToCart` not just `add`)
- ✅ Include translator comments for ambiguous strings

### Don'ts
- ❌ Don't hardcode strings in components
- ❌ Don't concatenate translated strings (`t('hello') + ' ' + name`)
- ❌ Don't use locale for business logic (use separate settings)
- ❌ Don't assume text direction (use logical properties)
- ❌ Don't translate programmatic values (IDs, codes)
- ❌ Don't forget to handle text expansion (buttons, menus)

---

## Common Patterns

### Loading State

```typescript
const t = useTranslations('common');

{isLoading ? t('loading') : t('ready')}
```

### Error Messages

```json
{
  "errors": {
    "network": "Network error. Please try again.",
    "notFound": "The requested resource was not found.",
    "unauthorized": "You must be logged in to access this page."
  }
}
```

### Form Validation

```typescript
const t = useTranslations('validation');

const schema = z.object({
  email: z.string().email(t('email')),
  password: z.string().min(8, t('passwordLength', { min: 8 })),
});
```

---

## Quick Reference

```typescript
// Get translator
const t = useTranslations('namespace');

// Simple translation
t('key')

// With variables
t('key', { name: 'Alice' })

// Rich text
t.rich('key', { bold: (chunks) => <strong>{chunks}</strong> })

// Plurals
t('items', { count: 5 })

// Dates
const format = useFormatter();
format.dateTime(date, { dateStyle: 'long' })

// Numbers
format.number(amount, { style: 'currency', currency: 'USD' })

// Current locale
const locale = useLocale();
```

---

## References

- [next-intl Documentation](https://next-intl-docs.vercel.app/)
- [ICU Message Format](https://unicode-org.github.io/icu/userguide/format_parse/messages/)

---

_Maintained by dsmj-ai-toolkit_
