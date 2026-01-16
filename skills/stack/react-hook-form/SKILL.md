---
name: react-hook-form
domain: frontend
description: Performant form management with React Hook Form. Covers form state, validation with Zod, field arrays, form submission, and error handling.
version: 1.0.0
tags: [forms, react-hook-form, validation, zod, typescript, react]
references:
  - name: React Hook Form Documentation
    url: https://react-hook-form.com/
    type: documentation
  - name: React Hook Form GitHub
    url: https://github.com/react-hook-form/react-hook-form
    type: repository
---

# React Hook Form - Performant Form Management

**Build performant, flexible forms with easy validation**

---

## What This Skill Covers

This skill provides guidance on:
- **Form registration** and state management
- **Validation** with Zod resolver
- **Field arrays** for dynamic forms
- **Form submission** and error handling
- **Form modes** (onChange, onBlur, onSubmit)
- **Integration** with UI libraries (shadcn/ui, Radix UI)

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
      <div>
        <label htmlFor="email">Email</label>
        <input
          id="email"
          type="email"
          {...register('email')}
        />
        {errors.email && (
          <span className="error">{errors.email.message}</span>
        )}
      </div>

      <div>
        <label htmlFor="password">Password</label>
        <input
          id="password"
          type="password"
          {...register('password')}
        />
        {errors.password && (
          <span className="error">{errors.password.message}</span>
        )}
      </div>

      <button type="submit" disabled={isSubmitting}>
        {isSubmitting ? 'Logging in...' : 'Login'}
      </button>
    </form>
  );
}
```

---

## Zod Validation

### Complex Schema

```typescript
import { z } from 'zod';

const profileSchema = z.object({
  // String validation
  username: z.string()
    .min(3, 'Username must be at least 3 characters')
    .max(20, 'Username must be less than 20 characters')
    .regex(/^[a-zA-Z0-9_]+$/, 'Username can only contain letters, numbers, and underscores'),

  // Email
  email: z.string().email('Invalid email address'),

  // Optional field
  bio: z.string().max(500).optional(),

  // Number
  age: z.number()
    .min(18, 'Must be at least 18 years old')
    .max(120, 'Invalid age'),

  // Enum
  role: z.enum(['admin', 'user', 'guest']),

  // Boolean
  acceptTerms: z.boolean().refine(val => val === true, {
    message: 'You must accept the terms and conditions',
  }),

  // Date
  birthDate: z.date().max(new Date(), 'Birth date cannot be in the future'),

  // Array
  hobbies: z.array(z.string()).min(1, 'Select at least one hobby'),

  // Object
  address: z.object({
    street: z.string(),
    city: z.string(),
    zipCode: z.string().regex(/^\d{5}$/, 'Invalid zip code'),
  }),

  // URL
  website: z.string().url('Invalid URL').optional(),

  // Custom validation
  password: z.string()
    .min(8)
    .refine(
      (val) => /[A-Z]/.test(val),
      'Password must contain at least one uppercase letter'
    )
    .refine(
      (val) => /[0-9]/.test(val),
      'Password must contain at least one number'
    ),

  // Confirm password
  confirmPassword: z.string(),
}).refine((data) => data.password === data.confirmPassword, {
  message: "Passwords don't match",
  path: ['confirmPassword'],
});

type ProfileFormData = z.infer<typeof profileSchema>;
```

---

## Form with shadcn/ui

```typescript
'use client';

import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import {
  Form,
  FormControl,
  FormDescription,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from '@/components/ui/form';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';

const formSchema = z.object({
  name: z.string().min(2).max(50),
  email: z.string().email(),
});

type FormData = z.infer<typeof formSchema>;

export function UserForm() {
  const form = useForm<FormData>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      name: '',
      email: '',
    },
  });

  const onSubmit = (data: FormData) => {
    console.log(data);
  };

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
        <FormField
          control={form.control}
          name="name"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Name</FormLabel>
              <FormControl>
                <Input placeholder="John Doe" {...field} />
              </FormControl>
              <FormDescription>Your full name</FormDescription>
              <FormMessage />
            </FormItem>
          )}
        />

        <FormField
          control={form.control}
          name="email"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Email</FormLabel>
              <FormControl>
                <Input type="email" placeholder="john@example.com" {...field} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />

        <Button type="submit" disabled={form.formState.isSubmitting}>
          Submit
        </Button>
      </form>
    </Form>
  );
}
```

---

## Field Arrays (Dynamic Fields)

```typescript
import { useFieldArray } from 'react-hook-form';

const todoSchema = z.object({
  todos: z.array(
    z.object({
      title: z.string().min(1, 'Title is required'),
      completed: z.boolean(),
    })
  ).min(1, 'Add at least one todo'),
});

type TodoFormData = z.infer<typeof todoSchema>;

export function TodoListForm() {
  const form = useForm<TodoFormData>({
    resolver: zodResolver(todoSchema),
    defaultValues: {
      todos: [{ title: '', completed: false }],
    },
  });

  const { fields, append, remove } = useFieldArray({
    control: form.control,
    name: 'todos',
  });

  return (
    <form onSubmit={form.handleSubmit(onSubmit)}>
      {fields.map((field, index) => (
        <div key={field.id}>
          <input
            {...form.register(`todos.${index}.title`)}
            placeholder="Todo title"
          />

          <input
            type="checkbox"
            {...form.register(`todos.${index}.completed`)}
          />

          <button type="button" onClick={() => remove(index)}>
            Remove
          </button>

          {form.formState.errors.todos?.[index]?.title && (
            <span>{form.formState.errors.todos[index]?.title?.message}</span>
          )}
        </div>
      ))}

      <button
        type="button"
        onClick={() => append({ title: '', completed: false })}
      >
        Add Todo
      </button>

      <button type="submit">Save All</button>
    </form>
  );
}
```

---

## Form Modes

```typescript
const form = useForm({
  mode: 'onBlur',        // Validate on blur (default: onSubmit)
  reValidateMode: 'onChange', // Re-validate on change after first submission
  resolver: zodResolver(schema),
});

// Mode options:
// - onChange: Validate on every change (more re-renders)
// - onBlur: Validate when field loses focus
// - onSubmit: Validate only on submit (default)
// - onTouched: Validate on first blur, then on change
// - all: Validate on change and blur
```

---

## Controlled Components

```typescript
import { Controller } from 'react-hook-form';
import { Select } from '@/components/ui/select';

export function ControlledForm() {
  const form = useForm<FormData>({
    resolver: zodResolver(schema),
  });

  return (
    <form>
      {/* Controller for custom components */}
      <Controller
        control={form.control}
        name="category"
        render={({ field }) => (
          <Select
            value={field.value}
            onValueChange={field.onChange}
          >
            <option value="tech">Technology</option>
            <option value="business">Business</option>
          </Select>
        )}
      />

      {/* Or use Controller with any controlled component */}
      <Controller
        control={form.control}
        name="rating"
        render={({ field }) => (
          <RatingPicker
            rating={field.value}
            onChange={field.onChange}
          />
        )}
      />
    </form>
  );
}
```

---

## Watch Values

```typescript
export function WatchExample() {
  const form = useForm<FormData>();

  // Watch specific field
  const email = form.watch('email');

  // Watch multiple fields
  const [name, age] = form.watch(['name', 'age']);

  // Watch all fields
  const allValues = form.watch();

  // Watch with callback
  useEffect(() => {
    const subscription = form.watch((value, { name, type }) => {
      console.log('Field changed:', name, value);
    });

    return () => subscription.unsubscribe();
  }, [form.watch]);

  return (
    <div>
      <input {...form.register('email')} />
      <p>Current email: {email}</p>
    </div>
  );
}
```

---

## Set Values Programmatically

```typescript
const form = useForm<FormData>();

// Set single value
form.setValue('email', 'john@example.com');

// Set with validation
form.setValue('email', 'invalid', {
  shouldValidate: true, // Trigger validation
  shouldDirty: true,    // Mark as dirty
  shouldTouch: true,    // Mark as touched
});

// Reset form
form.reset();

// Reset with new values
form.reset({
  email: 'new@example.com',
  name: 'New Name',
});

// Reset specific field
form.resetField('email');
```

---

## Error Handling

```typescript
export function FormWithErrors() {
  const form = useForm<FormData>({
    resolver: zodResolver(schema),
  });

  const onSubmit = async (data: FormData) => {
    try {
      await api.post.create.mutate(data);
    } catch (error) {
      // Set server-side errors
      form.setError('email', {
        type: 'server',
        message: 'This email is already taken',
      });

      // Set root error (form-level error)
      form.setError('root', {
        type: 'server',
        message: 'Failed to create account. Please try again.',
      });
    }
  };

  return (
    <form onSubmit={form.handleSubmit(onSubmit)}>
      <input {...form.register('email')} />
      {form.formState.errors.email && (
        <span>{form.formState.errors.email.message}</span>
      )}

      {/* Display root error */}
      {form.formState.errors.root && (
        <div className="error">
          {form.formState.errors.root.message}
        </div>
      )}

      <button type="submit">Submit</button>
    </form>
  );
}
```

---

## Form State

```typescript
const {
  formState: {
    errors,           // Validation errors
    isSubmitting,     // Is form submitting
    isSubmitted,      // Has form been submitted
    isSubmitSuccessful, // Was last submission successful
    isDirty,          // Has any field been modified
    dirtyFields,      // Which fields have been modified
    touchedFields,    // Which fields have been touched
    isValid,          // Is form valid (mode must not be onSubmit)
    isValidating,     // Is validation running
    submitCount,      // Number of times submitted
  },
} = useForm();
```

---

## Async Validation

```typescript
const schema = z.object({
  username: z.string()
    .min(3)
    .refine(async (username) => {
      // Check if username is available
      const response = await fetch(`/api/check-username?username=${username}`);
      const { available } = await response.json();
      return available;
    }, 'Username is already taken'),
});

// Or use custom async validator
const form = useForm({
  resolver: async (values) => {
    const isUsernameAvailable = await checkUsername(values.username);

    if (!isUsernameAvailable) {
      return {
        values: {},
        errors: {
          username: {
            type: 'manual',
            message: 'Username is already taken',
          },
        },
      };
    }

    return { values, errors: {} };
  },
});
```

---

## File Upload

```typescript
const schema = z.object({
  avatar: z.instanceof(FileList)
    .refine((files) => files.length > 0, 'Image is required')
    .refine((files) => files[0]?.size <= 5000000, 'Max file size is 5MB')
    .refine(
      (files) => ['image/jpeg', 'image/png'].includes(files[0]?.type),
      'Only .jpg and .png formats are supported'
    ),
});

type FormData = z.infer<typeof schema>;

export function FileUploadForm() {
  const form = useForm<FormData>({
    resolver: zodResolver(schema),
  });

  const onSubmit = async (data: FormData) => {
    const formData = new FormData();
    formData.append('avatar', data.avatar[0]);

    await fetch('/api/upload', {
      method: 'POST',
      body: formData,
    });
  };

  return (
    <form onSubmit={form.handleSubmit(onSubmit)}>
      <input
        type="file"
        accept="image/jpeg,image/png"
        {...form.register('avatar')}
      />
      {form.formState.errors.avatar && (
        <span>{form.formState.errors.avatar.message}</span>
      )}
      <button type="submit">Upload</button>
    </form>
  );
}
```

---

## Best Practices

### Default Values

```typescript
// ✅ Good: Provide default values
const form = useForm<FormData>({
  defaultValues: {
    name: '',
    email: '',
    role: 'user',
  },
});

// ❌ Bad: No default values (can cause uncontrolled/controlled warnings)
const form = useForm<FormData>();
```

### Type Safety

```typescript
// ✅ Good: Infer types from Zod schema
const schema = z.object({ name: z.string() });
type FormData = z.infer<typeof schema>;

const form = useForm<FormData>({
  resolver: zodResolver(schema),
});

// ❌ Bad: Manual types (can drift from schema)
type FormData = { name: string };
```

### Performance

```typescript
// ✅ Good: Use mode: 'onBlur' for large forms
const form = useForm({
  mode: 'onBlur', // Less re-renders
});

// ✅ Good: Memoize expensive operations
const memoizedSchema = useMemo(() => z.object({...}), []);

// ❌ Bad: mode: 'onChange' for large forms (too many re-renders)
```

---

## Quick Reference

```typescript
// Create form
const form = useForm<FormData>({
  resolver: zodResolver(schema),
  defaultValues: { name: '' },
  mode: 'onBlur',
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

// Reset form
form.reset()

// Field array
const { fields, append, remove } = useFieldArray({
  control: form.control,
  name: 'items',
});
```

---

## References

- [React Hook Form Documentation](https://react-hook-form.com/)
- [React Hook Form GitHub](https://github.com/react-hook-form/react-hook-form)

---

_Maintained by dsmj-ai-toolkit_
