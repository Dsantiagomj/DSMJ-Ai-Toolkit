# ICU Message Syntax Patterns

Complete guide to ICU message format for complex translations.

---

## Variables

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

---

## Rich Text

```json
{
  "terms": "By continuing, you agree to our <link>Terms</link>"
}
```

```typescript
<p>{t.rich('terms', {
  link: (chunks) => <a href="/terms">{chunks}</a>
})}</p>
```

---

## Pluralization

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

---

## Select (Gender)

```json
{
  "invitation": "{gender, select, male {He invited you} female {She invited you} other {They invited you}}"
}
```

---

## Date/Number Formatting

```typescript
import { useFormatter } from 'next-intl';

const format = useFormatter();

// Dates
format.dateTime(date, { dateStyle: 'long' })
format.relativeTime(date)

// Numbers
format.number(amount, { style: 'currency', currency: 'USD' })
format.number(0.75, { style: 'percent' })
```

---

_Maintained by dsmj-ai-toolkit_
