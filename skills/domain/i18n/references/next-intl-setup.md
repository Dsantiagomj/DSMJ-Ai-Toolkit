# next-intl Setup and Configuration

Complete setup guide for next-intl in Next.js applications.

---

## Installation

```bash
npm install next-intl
```

---

## Directory Structure

```
app/
├── [locale]/
│   ├── layout.tsx
│   ├── page.tsx
│   └── products/
messages/
├── en.json
├── es.json
├── de.json
middleware.ts
```

---

## Middleware

```typescript
// middleware.ts
import createMiddleware from 'next-intl/middleware';

export default createMiddleware({
  locales: ['en', 'es', 'de', 'ar'],
  defaultLocale: 'en',
  localeDetection: true,
});

export const config = {
  matcher: ['/((?!api|_next|_vercel|.*\\..*).*)'],
};
```

---

## Root Layout

```typescript
// app/[locale]/layout.tsx
import { NextIntlClientProvider } from 'next-intl';

export default async function LocaleLayout({
  children,
  params: { locale },
}) {
  const messages = (await import(`@/messages/${locale}.json`)).default;

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

```json
// messages/en.json
{
  "common": {
    "welcome": "Welcome",
    "save": "Save",
    "cancel": "Cancel"
  },
  "homepage": {
    "title": "Welcome to Our Store",
    "subtitle": "Find the best products"
  }
}
```

---

## Using Translations

```typescript
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
```

---

_Maintained by dsmj-ai-toolkit_
