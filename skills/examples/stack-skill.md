---
name: vue-3-composition
version: 3.4.0
description: Vue 3 Composition API patterns with Reactivity Transform and script setup. Use when writing Vue 3 components, composables, or working with reactive state.
tags: [vue, frontend, javascript, typescript, ui, composition-api]
author: dsmj-ai-toolkit
metadata:
  auto_invoke: "Writing Vue 3 components, .vue files, composables, or reactive state"
  category: stack
  progressive_disclosure: true
---

# Vue 3 Composition API - Modern Vue Patterns

**Composition API, Reactivity, and TypeScript patterns for Vue 3**

---

## Overview

**What this skill provides**: Vue 3 Composition API best practices
**When to use**: Writing Vue 3 components and composables
**Key concepts**: `<script setup>`, reactivity, composables, lifecycle hooks

---

## Core Concepts

### Concept 1: `<script setup>` Syntax

**What it is**: Simplified component syntax (Vue 3.2+)

**Best practices**:
✅ Use `<script setup>` as default
✅ Auto-exposes bindings to template
✅ Better TypeScript inference
❌ Don't use Options API for new components

**Example**:
```vue
<script setup lang="ts">
import { ref, computed } from 'vue'

const count = ref(0)
const doubled = computed(() => count.value * 2)

function increment() {
  count.value++
}
</script>

<template>
  <button @click="increment">
    Count: {{ count }} (doubled: {{ doubled }})
  </button>
</template>
```

### Concept 2: Reactivity

**What it is**: Vue's reactive state system

**Primitives**:
- `ref()`: Reactive primitive or object
- `reactive()`: Reactive object (deeply)
- `computed()`: Derived reactive value
- `watch()`: Side effects on reactive changes

**Example**:
```ts
import { ref, reactive, computed, watch } from 'vue'

// Primitives use ref
const count = ref(0)
const message = ref('Hello')

// Objects use reactive
const user = reactive({
  name: 'John',
  email: 'john@example.com'
})

// Computed for derived values
const fullName = computed(() => `${user.name} - ${user.email}`)

// Watch for side effects
watch(count, (newValue, oldValue) => {
  console.log(`Count changed from ${oldValue} to ${newValue}`)
})
```

### Concept 3: Composables

**What it is**: Reusable stateful logic

**Pattern**:
```ts
// composables/useCounter.ts
import { ref, computed } from 'vue'

export function useCounter(initial = 0) {
  const count = ref(initial)
  const doubled = computed(() => count.value * 2)

  function increment() {
    count.value++
  }

  function decrement() {
    count.value--
  }

  return {
    count,
    doubled,
    increment,
    decrement
  }
}
```

**Usage**:
```vue
<script setup lang="ts">
import { useCounter } from '@/composables/useCounter'

const { count, doubled, increment, decrement } = useCounter(10)
</script>

<template>
  <div>
    <p>Count: {{ count }}</p>
    <p>Doubled: {{ doubled }}</p>
    <button @click="increment">+</button>
    <button @click="decrement">-</button>
  </div>
</template>
```

---

## Patterns & Best Practices

### Pattern 1: Component Props & Emits

**Use when**: Passing data and events between components

**Implementation**:
```vue
<script setup lang="ts">
interface Props {
  title: string
  count?: number
}

interface Emits {
  (e: 'update', value: number): void
  (e: 'delete'): void
}

const props = withDefaults(defineProps<Props>(), {
  count: 0
})

const emit = defineEmits<Emits>()

function handleUpdate() {
  emit('update', props.count + 1)
}
</script>

<template>
  <div>
    <h2>{{ title }}</h2>
    <p>Count: {{ count }}</p>
    <button @click="handleUpdate">Update</button>
    <button @click="emit('delete')">Delete</button>
  </div>
</template>
```

**Why this works**:
- TypeScript inference for props and emits
- Default values handled by `withDefaults`
- Type-safe event emissions

### Pattern 2: Async Data Fetching

**Use when**: Loading data in components

**Implementation**:
```vue
<script setup lang="ts">
import { ref, onMounted } from 'vue'

interface Post {
  id: number
  title: string
  body: string
}

const posts = ref<Post[]>([])
const loading = ref(false)
const error = ref<Error | null>(null)

async function fetchPosts() {
  loading.value = true
  error.value = null

  try {
    const response = await fetch('/api/posts')
    if (!response.ok) throw new Error('Failed to fetch')
    posts.value = await response.json()
  } catch (e) {
    error.value = e as Error
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  fetchPosts()
})
</script>

<template>
  <div>
    <div v-if="loading">Loading...</div>
    <div v-else-if="error">Error: {{ error.message }}</div>
    <div v-else>
      <article v-for="post in posts" :key="post.id">
        <h2>{{ post.title }}</h2>
        <p>{{ post.body }}</p>
      </article>
    </div>
  </div>
</template>
```

### Pattern 3: Form Handling with v-model

**Use when**: Two-way binding for forms

**Implementation**:
```vue
<script setup lang="ts">
import { reactive, computed } from 'vue'

interface FormData {
  email: string
  password: string
  remember: boolean
}

const form = reactive<FormData>({
  email: '',
  password: '',
  remember: false
})

const isValid = computed(() => {
  return form.email.includes('@') && form.password.length >= 8
})

async function handleSubmit() {
  if (!isValid.value) return

  const response = await fetch('/api/login', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(form)
  })

  // Handle response
}
</script>

<template>
  <form @submit.prevent="handleSubmit">
    <input v-model="form.email" type="email" placeholder="Email" />
    <input v-model="form.password" type="password" placeholder="Password" />
    <label>
      <input v-model="form.remember" type="checkbox" />
      Remember me
    </label>
    <button :disabled="!isValid">Login</button>
  </form>
</template>
```

---

## Common Scenarios

### Scenario 1: Shared State (Global Store)

**Problem**: Multiple components need shared state

**Solution**:
```ts
// stores/user.ts
import { ref, computed } from 'vue'

const user = ref<User | null>(null)
const isAuthenticated = computed(() => user.value !== null)

export function useUserStore() {
  function login(userData: User) {
    user.value = userData
  }

  function logout() {
    user.value = null
  }

  return {
    user,
    isAuthenticated,
    login,
    logout
  }
}
```

**Usage**:
```vue
<script setup lang="ts">
import { useUserStore } from '@/stores/user'

const { user, isAuthenticated, logout } = useUserStore()
</script>
```

### Scenario 2: Lifecycle Hooks

**Problem**: Need to run code at specific lifecycle points

**Solution**:
```vue
<script setup lang="ts">
import { onMounted, onUnmounted, ref } from 'vue'

const intervalId = ref<number>()

onMounted(() => {
  console.log('Component mounted')
  intervalId.value = setInterval(() => {
    console.log('Tick')
  }, 1000)
})

onUnmounted(() => {
  console.log('Component unmounted')
  if (intervalId.value) {
    clearInterval(intervalId.value)
  }
})
</script>
```

---

## Anti-Patterns

### Anti-Pattern 1: Mutating Props

❌ **Don't do this**:
```vue
<script setup lang="ts">
const props = defineProps<{ count: number }>()

function increment() {
  props.count++ // ERROR: Props are read-only!
}
</script>
```

✅ **Do this instead**:
```vue
<script setup lang="ts">
const props = defineProps<{ count: number }>()
const emit = defineEmits<{ (e: 'update', value: number): void }>()

function increment() {
  emit('update', props.count + 1)
}
</script>
```

### Anti-Pattern 2: Forgetting `.value` with `ref()`

❌ **Don't do this**:
```ts
const count = ref(0)
console.log(count) // { value: 0 }
count++ // ERROR
```

✅ **Do this instead**:
```ts
const count = ref(0)
console.log(count.value) // 0
count.value++
```

**Note**: In templates, `.value` is automatically unwrapped

---

## Quick Reference

| Operation | Code Pattern | Notes |
|-----------|-------------|-------|
| Reactive primitive | `const x = ref(0)` | Use `.value` in script |
| Reactive object | `const obj = reactive({})` | No `.value` needed |
| Computed value | `const y = computed(() => x.value * 2)` | Auto-tracks dependencies |
| Watch changes | `watch(x, (newVal) => {})` | Side effects |
| Lifecycle hook | `onMounted(() => {})` | Component mounted |
| Two-way binding | `v-model="value"` | Form inputs |
| Props (TypeScript) | `defineProps<{ x: number }>()` | Type-safe props |
| Emits (TypeScript) | `defineEmits<{ (e: 'foo'): void }>()` | Type-safe events |

---

## Progressive Disclosure

> **Note**: This skill covers common Vue 3 Composition API patterns.

**For detailed information, see**:
- `references/advanced-composables.md` - Complex composable patterns
- `references/typescript-patterns.md` - Advanced TypeScript integration
- `references/performance.md` - Optimization techniques
- `examples/` - Complete working applications

**Load these only when**:
- Building complex composables with lifecycle management
- Need advanced TypeScript patterns
- Optimizing performance for large applications

---

## Version Information

**Current Version**: Vue 3.4
**Last Updated**: 2026-01-15
**Compatible With**: Vite 5+, TypeScript 5+

### Deprecated Patterns

❌ **Options API** - Use Composition API (`<script setup>`)
❌ **Reactivity Transform** - Deprecated in Vue 3.4

---

## Resources

**Official Documentation**:
- [Vue 3 Composition API](https://vuejs.org/guide/extras/composition-api-faq.html)
- [TypeScript with Composition API](https://vuejs.org/guide/typescript/composition-api.html)

---

_This skill demonstrates stack skill pattern with version-specific patterns and progressive disclosure._
