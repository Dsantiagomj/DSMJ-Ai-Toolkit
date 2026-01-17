# Jest & Vitest Testing Guide

Complete guide to Jest and Vitest testing patterns.

---

## Jest/Vitest Matchers

```typescript
// Equality
expect(value).toBe(4)
expect(value).toEqual({ a: 1 })

// Truthiness
expect(value).toBeTruthy()
expect(value).toBeNull()
expect(value).toBeUndefined()

// Numbers
expect(value).toBeGreaterThan(3)
expect(value).toBeCloseTo(0.3)

// Strings
expect(value).toMatch(/pattern/)

// Arrays
expect(array).toContain('item')
expect(array).toHaveLength(3)

// Exceptions
expect(() => fn()).toThrow()
expect(() => fn()).toThrow('error message')

// Mock functions
expect(mockFn).toHaveBeenCalled()
expect(mockFn).toHaveBeenCalledTimes(2)
expect(mockFn).toHaveBeenCalledWith(arg1, arg2)
```

---

## Mocking with Jest

```typescript
// Mock function
const mockFn = jest.fn()
mockFn.mockReturnValue(42)
mockFn.mockResolvedValue({ data: 'success' })

// Mock module
jest.mock('./api')

// Spy on methods
const saveSpy = jest.spyOn(user, 'save')
await user.save()
expect(saveSpy).toHaveBeenCalled()
saveSpy.mockRestore()
```

---

## Vitest Specifics

```typescript
import { describe, test, expect, vi } from 'vitest'

// Use vi instead of jest
vi.mock('./api')
vi.spyOn(api, 'fetchUser').mockResolvedValue(mockUser)
vi.useFakeTimers()
vi.advanceTimersByTime(1000)
```

---

## Setup and Teardown

```typescript
describe('Database tests', () => {
  beforeAll(async () => {
    await database.connect()
  })

  beforeEach(() => {
    database.clear()
  })

  afterEach(() => {
    // Cleanup
  })

  afterAll(async () => {
    await database.disconnect()
  })
})
```

---

_Maintained by dsmj-ai-toolkit_
