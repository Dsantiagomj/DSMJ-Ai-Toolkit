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

## When to Use

Use React Hook Form when you need:
- **Form validation** with schema-based validation (Zod, Yup)
- **Performance** - minimizes re-renders with uncontrolled inputs
- **Complex forms** with field arrays, nested objects, or conditional fields
- **Developer experience** - TypeScript support and minimal boilerplate
- **Integration** with UI libraries like shadcn/ui, Material UI

Choose alternatives when:
- Simple forms with 1-2 fields (native HTML might suffice)
- You need full controlled inputs for every keystroke (use useState)
- Building non-React forms

---

## Critical Patterns

### Pattern 1: Schema-First Validation

```typescript
// ✅ Good: Define schema first, infer types
const formSchema = z.object({
  email: z.string().email('Invalid email'),
  age: z.number().min(18, 'Must be 18+'),
  role: z.enum(['admin', 'user']),
});

type FormData = z.infer<typeof formSchema>;

const form = useForm<FormData>({
  resolver: zodResolver(formSchema),
  defaultValues: { email: '', age: 0, role: 'user' },
});

// ❌ Bad: Manual type definitions, sync issues
interface FormData {
  email: string;
  age: number;
}

const form = useForm<FormData>();

const validate = (data: FormData) => {
  const errors: Record<string, string> = {};
  if (!data.email.includes('@')) errors.email = 'Invalid';
  return errors;
};
```

**Why**: Schema-first ensures single source of truth, better type safety, and automatic validation.

---

### Pattern 2: Proper Error Display

```typescript
// ✅ Good: Check existence before displaying
{errors.email && (
  <span className="text-red-500 text-sm">
    {errors.email.message}
  </span>
)}

// ✅ Good: With shadcn/ui FormMessage handles it
<FormField
  control={form.control}
  name="email"
  render={({ field }) => (
    <FormItem>
      <FormLabel>Email</FormLabel>
      <FormControl>
        <Input {...field} />
      </FormControl>
      <FormMessage /> {/* Automatically shows errors */}
    </FormItem>
  )}
/>

// ❌ Bad: No null check, crashes if no error
<span>{errors.email.message}</span>

// ❌ Bad: Generic error message loses context
{errors.email && <span>Error occurred</span>}
```

**Why**: Proper error checking prevents runtime errors; specific messages improve UX.

---

### Pattern 3: Field Arrays for Dynamic Lists

```typescript
// ✅ Good: Use useFieldArray for dynamic fields
import { useFieldArray } from 'react-hook-form';

const formSchema = z.object({
  items: z.array(z.object({
    name: z.string().min(1),
    quantity: z.number().min(1),
  })).min(1, 'At least one item required'),
});

function ItemsForm() {
  const form = useForm<FormData>({
    resolver: zodResolver(formSchema),
  });

  const { fields, append, remove } = useFieldArray({
    control: form.control,
    name: 'items',
  });

  return (
    <>
      {fields.map((field, index) => (
        <div key={field.id}>
          <input {...form.register(`items.${index}.name`)} />
          <input {...form.register(`items.${index}.quantity`, { valueAsNumber: true })} />
          <button onClick={() => remove(index)}>Remove</button>
        </div>
      ))}
      <button onClick={() => append({ name: '', quantity: 0 })}>Add Item</button>
    </>
  );
}

// ❌ Bad: Manual state management loses integration
const [items, setItems] = useState([]);

const addItem = () => setItems([...items, { name: '', quantity: 0 }]);
```

**Why**: useFieldArray integrates with validation, tracks changes, and handles re-renders efficiently.

---

### Pattern 4: Controlled vs Uncontrolled

```typescript
// ✅ Good: Uncontrolled (default) - best performance
<input {...register('email')} />

// ✅ Good: Controlled when you need the value reactively
const email = watch('email');

useEffect(() => {
  console.log('Email changed:', email);
}, [email]);

// ✅ Good: Controller for third-party components
import { Controller } from 'react-hook-form';

<Controller
  name="date"
  control={form.control}
  render={({ field }) => (
    <DatePicker
      selected={field.value}
      onChange={field.onChange}
    />
  )}
/>

// ❌ Bad: Making all fields controlled unnecessarily
const email = watch('email');
<input 
  value={email} 
  onChange={(e) => setValue('email', e.target.value)} 
/>

// ❌ Bad: Third-party component without Controller
<DatePicker {...register('date')} />
```

**Why**: Uncontrolled inputs minimize re-renders; use controlled only when necessary; Controller properly integrates third-party components.

---

### Pattern 5: Form Submission with Loading States

```typescript
// ✅ Good: Use isSubmitting, handle errors, show feedback
const onSubmit = async (data: FormData) => {
  try {
    await api.createUser(data);
    toast.success('User created successfully');
    form.reset();
  } catch (error) {
    toast.error('Failed to create user');
    // Optionally set form errors
    form.setError('root', {
      message: 'Server error occurred',
    });
  }
};

<form onSubmit={form.handleSubmit(onSubmit)}>
  {/* fields */}
  <button 
    type="submit" 
    disabled={form.formState.isSubmitting}
  >
    {form.formState.isSubmitting ? 'Creating...' : 'Create User'}
  </button>
</form>

// ❌ Bad: No loading state, no error handling
const onSubmit = async (data: FormData) => {
  await api.createUser(data);
};

<button type="submit">Submit</button>

// ❌ Bad: Manual loading state, out of sync
const [loading, setLoading] = useState(false);

const onSubmit = async (data: FormData) => {
  setLoading(true);
  await api.createUser(data);
  setLoading(false);
};
```

**Why**: Built-in isSubmitting syncs with form state; proper error handling improves reliability.

---

## Anti-Patterns

### Anti-Pattern 1: Not Using defaultValues

```typescript
// ❌ Problem: Uncontrolled inputs without defaults cause issues
const form = useForm<FormData>({
  resolver: zodResolver(formSchema),
  // No defaultValues
});

// Form state is undefined, causes bugs with reset, dirty checking
```

**Why it's wrong**: React Hook Form tracks changes from initial state; without defaults, `isDirty`, `reset()`, and validation may behave unexpectedly.

**Solution**:
```typescript
// ✅ Always provide defaultValues
const form = useForm<FormData>({
  resolver: zodResolver(formSchema),
  defaultValues: {
    email: '',
    name: '',
    age: 0,
    role: 'user',
  },
});

// ✅ Or use async defaultValues for fetched data
const form = useForm<FormData>({
  resolver: zodResolver(formSchema),
  defaultValues: async () => {
    const user = await fetchUser();
    return user;
  },
});
```

---

### Anti-Pattern 2: Destructuring register

```typescript
// ❌ Problem: Destructuring breaks the ref
const { onChange, onBlur, name } = register('email');
<input onChange={onChange} onBlur={onBlur} name={name} />

// ❌ Problem: Spreading twice loses the ref
<input {...form.register('email')} {...otherProps} />
```

**Why it's wrong**: register returns a ref that must be attached; destructuring or overriding loses the connection.

**Solution**:
```typescript
// ✅ Spread register directly
<input {...register('email')} />

// ✅ Add props before register spread
<input placeholder="Email" {...register('email')} />

// ✅ For custom props that might conflict, use register options
<input 
  {...register('email', {
    onChange: (e) => {
      // custom logic
    },
  })} 
/>
```

---

### Anti-Pattern 3: Validation in onChange

```typescript
// ❌ Problem: Triggering validation on every keystroke
<input 
  {...register('email')} 
  onChange={(e) => {
    form.trigger('email'); // Validates on every key
  }}
/>
```

**Why it's wrong**: Creates poor UX (errors show immediately) and performance issues.

**Solution**:
```typescript
// ✅ Use mode configuration for validation timing
const form = useForm<FormData>({
  resolver: zodResolver(formSchema),
  mode: 'onBlur', // Validate on blur, not onChange
  reValidateMode: 'onChange', // Re-validate onChange after first error
});

// ✅ Manual trigger only when needed (e.g., dependent fields)
const password = watch('password');

useEffect(() => {
  if (form.formState.touchedFields.confirmPassword) {
    form.trigger('confirmPassword');
  }
}, [password]);
```

---

### Anti-Pattern 4: Using setState Instead of setValue

```typescript
// ❌ Problem: External state doesn't sync with form
const [email, setEmail] = useState('');

<input 
  value={email}
  onChange={(e) => setEmail(e.target.value)}
/>

// Form doesn't know about the value
```

**Why it's wrong**: Form state and React state diverge; validation and submission use wrong data.

**Solution**:
```typescript
// ✅ Use setValue to update form state
const updateEmail = (newEmail: string) => {
  form.setValue('email', newEmail, {
    shouldValidate: true, // Trigger validation
    shouldDirty: true,    // Mark as dirty
    shouldTouch: true,    // Mark as touched
  });
};

// ✅ Or use watch to read value reactively
const email = watch('email');

// Use email in your logic, but form state is source of truth
```

---

### Anti-Pattern 5: Ignoring Form State

```typescript
// ❌ Problem: Not using formState for UI feedback
<button type="submit">Submit</button>

// No loading state, no validation feedback
```

**Why it's wrong**: Poor UX; users don't know form status or what's wrong.

**Solution**:
```typescript
// ✅ Use formState for comprehensive feedback
const { isSubmitting, isValid, isDirty, errors } = form.formState;

<form onSubmit={form.handleSubmit(onSubmit)}>
  {/* Show global errors */}
  {errors.root && (
    <Alert variant="destructive">
      {errors.root.message}
    </Alert>
  )}

  {/* Fields */}
  
  <button 
    type="submit"
    disabled={isSubmitting || !isDirty || !isValid}
  >
    {isSubmitting ? 'Saving...' : 'Save Changes'}
  </button>
  
  {isDirty && (
    <p className="text-sm text-muted-foreground">
      You have unsaved changes
    </p>
  )}
</form>
```

---

### Anti-Pattern 6: Not Resetting After Success

```typescript
// ❌ Problem: Form keeps old values after submission
const onSubmit = async (data: FormData) => {
  await api.createUser(data);
  // Form still shows old data
};
```

**Why it's wrong**: Confusing UX; users think submission failed; resubmission causes duplicates.

**Solution**:
```typescript
// ✅ Reset after successful submission
const onSubmit = async (data: FormData) => {
  await api.createUser(data);
  form.reset(); // Reset to defaultValues
  
  // Or reset to specific values
  form.reset({
    email: '',
    name: '',
  });
};

// ✅ Reset dirty state without clearing values
form.reset(form.getValues()); // Marks form as pristine
```

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
