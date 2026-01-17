---
name: react-hook-form
domain: frontend
description: >
  Performant form management with React Hook Form. Covers form state, validation with Zod, field arrays, form submission, and error handling.
  Trigger: When building forms, when implementing form validation, when handling form submissions, when using Zod schema validation.
version: 1.0.0
tags: [forms, react-hook-form, validation, zod, typescript, react]
metadata:
  version: "1.0"
  last_updated: "2026-01-17"
  category: stack
references:
  - name: React Hook Form Documentation
    url: https://react-hook-form.com/
    type: documentation
  - name: React Hook Form GitHub
    url: https://github.com/react-hook-form/react-hook-form
    type: repository
  - name: Advanced Patterns
    url: ./references/advanced.md
    type: local
---

# React Hook Form - Performant Form Management

**Build performant, flexible forms with easy validation**

---

## What This Skill Covers

- **Form registration** and state management
- **Validation** with Zod resolver
- **Field arrays** for dynamic forms
- **Form submission** and error handling

For advanced patterns, see [references/](./references/).

---

## Basic Form

```typescript
'use client';

import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';

const formSchema = z.object({
  email: z.string().email('Invalid email address'),
  password: z.string().min(8, 'Password must be at least 8 characters'),
});

type FormData = z.infer<typeof formSchema>;

export function LoginForm() {
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<FormData>({
    resolver: zodResolver(formSchema),
  });

  const onSubmit = async (data: FormData) => {
    await fetch('/api/login', {
      method: 'POST',
      body: JSON.stringify(data),
    });
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input {...register('email')} />
      {errors.email && <span>{errors.email.message}</span>}
      
      <input type="password" {...register('password')} />
      {errors.password && <span>{errors.password.message}</span>}
      
      <button type="submit" disabled={isSubmitting}>Login</button>
    </form>
  );
}
```

---

## With shadcn/ui

```typescript
import { Form, FormField, FormItem, FormLabel, FormControl, FormMessage } from '@/components/ui/form';

export function UserForm() {
  const form = useForm<FormData>({
    resolver: zodResolver(formSchema),
  });

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)}>
        <FormField
          control={form.control}
          name="name"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Name</FormLabel>
              <FormControl>
                <Input {...field} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />
      </form>
    </Form>
  );
}
```

---

## Quick Reference

```typescript
// Create form
const form = useForm<FormData>({
  resolver: zodResolver(schema),
  defaultValues: { name: '' },
});

// Register input
<input {...form.register('name')} />

// Handle submit
form.handleSubmit(onSubmit)

// Get errors
form.formState.errors.name?.message

// Set value
form.setValue('name', 'John')

// Watch value
const name = form.watch('name')
```

---

## Learn More

- **Advanced Patterns**: [references/advanced.md](./references/advanced.md) - Field arrays, controlled components, complex validation

---

## External References

- [React Hook Form Documentation](https://react-hook-form.com/)
- [React Hook Form GitHub](https://github.com/react-hook-form/react-hook-form)

---

_Maintained by dsmj-ai-toolkit_
