# Advanced Patterns - React Hook Form

## Field Arrays

```typescript
import { useFieldArray } from 'react-hook-form';

const todoSchema = z.object({
  todos: z.array(z.object({
    title: z.string().min(1),
    completed: z.boolean(),
  })).min(1),
});

export function TodoListForm() {
  const form = useForm<TodoFormData>({
    resolver: zodResolver(todoSchema),
  });

  const { fields, append, remove } = useFieldArray({
    control: form.control,
    name: 'todos',
  });

  return (
    <form>
      {fields.map((field, index) => (
        <div key={field.id}>
          <input {...form.register(`todos.${index}.title`)} />
          <button onClick={() => remove(index)}>Remove</button>
        </div>
      ))}
      <button onClick={() => append({ title: '', completed: false })}>Add</button>
    </form>
  );
}
```

## Controlled Components

```typescript
import { Controller } from 'react-hook-form';

<Controller
  control={form.control}
  name="category"
  render={({ field }) => (
    <Select value={field.value} onValueChange={field.onChange}>
      <option value="tech">Technology</option>
    </Select>
  )}
/>
```

## Complex Validation

```typescript
const profileSchema = z.object({
  username: z.string().min(3).max(20).regex(/^[a-zA-Z0-9_]+$/),
  email: z.string().email(),
  age: z.number().min(18).max(120),
  password: z.string().min(8)
    .refine((val) => /[A-Z]/.test(val), 'Must contain uppercase')
    .refine((val) => /[0-9]/.test(val), 'Must contain number'),
  confirmPassword: z.string(),
}).refine((data) => data.password === data.confirmPassword, {
  message: "Passwords don't match",
  path: ['confirmPassword'],
});
```
