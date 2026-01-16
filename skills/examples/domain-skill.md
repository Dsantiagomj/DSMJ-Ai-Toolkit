---
name: testing-patterns
version: 1.0.0
description: Testing best practices and patterns across frameworks (Jest, Vitest, Pytest). Use when writing tests, test-driven development, or implementing test coverage.
tags: [testing, tdd, jest, vitest, pytest, quality]
author: dsmj-ai-toolkit
metadata:
  auto_invoke: "Writing tests, implementing TDD, or ensuring test coverage"
  category: domain
  progressive_disclosure: true
---

# Testing Patterns - Cross-Framework Testing Best Practices

**Test patterns, strategies, and best practices for modern testing**

---

## Overview

**What this skill provides**: Testing patterns applicable across frameworks
**When to use**: Writing unit/integration/e2e tests
**Key concepts**: AAA pattern, mocking, fixtures, assertions, test organization

---

## Core Concepts

### Concept 1: AAA Pattern (Arrange-Act-Assert)

**What it is**: Standard test structure for clarity

**Best practices**:
✅ Arrange: Set up test data and conditions
✅ Act: Execute the code being tested
✅ Assert: Verify the results
❌ Don't mix phases or skip comments

**Example** (Jest/Vitest):
```typescript
describe('Calculator', () => {
  test('adds two numbers correctly', () => {
    // Arrange
    const calculator = new Calculator()
    const a = 5
    const b = 3

    // Act
    const result = calculator.add(a, b)

    // Assert
    expect(result).toBe(8)
  })
})
```

**Example** (Pytest):
```python
def test_calculator_adds_numbers():
    # Arrange
    calculator = Calculator()
    a, b = 5, 3

    # Act
    result = calculator.add(a, b)

    # Assert
    assert result == 8
```

### Concept 2: Test Isolation

**What it is**: Each test is independent

**Best practices**:
✅ Tests don't depend on execution order
✅ Clean up after each test
✅ Fresh state for every test
❌ Don't share mutable state between tests

**Example** (Jest):
```typescript
describe('UserService', () => {
  let userService: UserService
  let mockDb: jest.Mocked<Database>

  beforeEach(() => {
    // Fresh instance for each test
    mockDb = createMockDatabase()
    userService = new UserService(mockDb)
  })

  afterEach(() => {
    // Cleanup if needed
    jest.clearAllMocks()
  })

  test('creates user', async () => {
    await userService.createUser({ name: 'John' })
    expect(mockDb.insert).toHaveBeenCalledWith({ name: 'John' })
  })

  test('deletes user', async () => {
    await userService.deleteUser(1)
    expect(mockDb.delete).toHaveBeenCalledWith(1)
  })
})
```

### Concept 3: Mocking vs Integration

**What it is**: Unit tests mock dependencies, integration tests use real dependencies

**Unit Test** (with mocks):
```typescript
test('sends welcome email when user registers', async () => {
  // Mock email service
  const mockEmailService = {
    send: jest.fn().mockResolvedValue(true)
  }

  const userService = new UserService(mockEmailService)
  await userService.register({ email: 'test@example.com' })

  expect(mockEmailService.send).toHaveBeenCalledWith({
    to: 'test@example.com',
    subject: 'Welcome!'
  })
})
```

**Integration Test** (real dependencies):
```typescript
test('user registration flow works end-to-end', async () => {
  // Real database (test DB)
  const db = new Database(testDbConfig)
  // Real email service (with test mode)
  const emailService = new EmailService({ testMode: true })

  const userService = new UserService(db, emailService)
  const user = await userService.register({
    email: 'test@example.com',
    password: 'secure123'
  })

  // Verify user in database
  const savedUser = await db.users.findOne({ email: 'test@example.com' })
  expect(savedUser).toBeDefined()
  expect(savedUser.email).toBe('test@example.com')

  // Verify email sent
  const sentEmails = await emailService.getSentEmails()
  expect(sentEmails).toContainEqual(
    expect.objectContaining({ to: 'test@example.com' })
  )
})
```

---

## Patterns & Best Practices

### Pattern 1: Test Data Factories

**Use when**: Creating test data repeatedly

**Implementation**:
```typescript
// test/factories/userFactory.ts
export function createUser(overrides = {}) {
  return {
    id: Math.random(),
    name: 'Test User',
    email: 'test@example.com',
    createdAt: new Date(),
    ...overrides
  }
}

// Usage in tests
test('user profile displays name', () => {
  const user = createUser({ name: 'John Doe' })
  const profile = new UserProfile(user)

  expect(profile.displayName).toBe('John Doe')
})
```

**Why this works**:
- Reduces duplication
- Easy to override specific fields
- Maintains consistency across tests

### Pattern 2: Testing Async Code

**Use when**: Testing promises, async/await

**Implementation**:
```typescript
// ✅ Good: Use async/await
test('fetches user data', async () => {
  const data = await fetchUserData(1)
  expect(data.name).toBe('John')
})

// ✅ Good: Reject with error
test('throws on invalid user ID', async () => {
  await expect(fetchUserData(-1)).rejects.toThrow('Invalid ID')
})

// ❌ Bad: Forgetting await (test passes even if it should fail)
test('fetches user data', () => {
  fetchUserData(1) // Missing await!
  expect(data.name).toBe('John') // data is undefined
})
```

### Pattern 3: Testing Error Cases

**Use when**: Validating error handling

**Implementation**:
```typescript
describe('UserService.register', () => {
  test('throws on duplicate email', async () => {
    const service = new UserService(mockDb)

    // First registration succeeds
    await service.register({ email: 'test@example.com' })

    // Second registration should fail
    await expect(
      service.register({ email: 'test@example.com' })
    ).rejects.toThrow('Email already exists')
  })

  test('throws on invalid email format', async () => {
    const service = new UserService(mockDb)

    await expect(
      service.register({ email: 'invalid-email' })
    ).rejects.toThrow('Invalid email format')
  })
})
```

### Pattern 4: Parameterized Tests

**Use when**: Testing same logic with different inputs

**Implementation** (Jest):
```typescript
describe.each([
  [1, 1, 2],
  [2, 3, 5],
  [5, 10, 15],
  [-1, 1, 0]
])('Calculator.add(%i, %i)', (a, b, expected) => {
  test(`returns ${expected}`, () => {
    const calc = new Calculator()
    expect(calc.add(a, b)).toBe(expected)
  })
})
```

**Implementation** (Pytest):
```python
import pytest

@pytest.mark.parametrize("a,b,expected", [
    (1, 1, 2),
    (2, 3, 5),
    (5, 10, 15),
    (-1, 1, 0)
])
def test_calculator_add(a, b, expected):
    calc = Calculator()
    assert calc.add(a, b) == expected
```

---

## Common Scenarios

### Scenario 1: Testing React Components

**Problem**: Test UI components effectively

**Solution** (React Testing Library):
```typescript
import { render, screen, fireEvent } from '@testing-library/react'
import { Counter } from './Counter'

test('increments counter on button click', () => {
  // Arrange
  render(<Counter initialCount={0} />)

  // Act
  const button = screen.getByRole('button', { name: /increment/i })
  fireEvent.click(button)

  // Assert
  expect(screen.getByText('Count: 1')).toBeInTheDocument()
})

test('shows initial count', () => {
  render(<Counter initialCount={5} />)
  expect(screen.getByText('Count: 5')).toBeInTheDocument()
})
```

### Scenario 2: Testing API Endpoints

**Problem**: Test HTTP endpoints

**Solution** (Supertest + Express):
```typescript
import request from 'supertest'
import { app } from '../app'

describe('POST /api/users', () => {
  test('creates user and returns 201', async () => {
    const response = await request(app)
      .post('/api/users')
      .send({ name: 'John', email: 'john@example.com' })
      .expect(201)

    expect(response.body).toMatchObject({
      name: 'John',
      email: 'john@example.com'
    })
    expect(response.body.id).toBeDefined()
  })

  test('returns 400 for invalid email', async () => {
    const response = await request(app)
      .post('/api/users')
      .send({ name: 'John', email: 'invalid' })
      .expect(400)

    expect(response.body.error).toContain('Invalid email')
  })
})
```

### Scenario 3: Mocking External Services

**Problem**: Don't hit real APIs in tests

**Solution**:
```typescript
// Mock fetch globally
global.fetch = jest.fn()

test('fetches user from API', async () => {
  // Setup mock response
  (fetch as jest.Mock).mockResolvedValueOnce({
    ok: true,
    json: async () => ({ id: 1, name: 'John' })
  })

  const service = new UserService()
  const user = await service.fetchUser(1)

  expect(fetch).toHaveBeenCalledWith('/api/users/1')
  expect(user.name).toBe('John')
})
```

---

## Anti-Patterns

### Anti-Pattern 1: Testing Implementation Details

❌ **Don't do this**:
```typescript
test('Counter uses useState', () => {
  const wrapper = shallow(<Counter />)
  expect(wrapper.find('useState')).toBeDefined() // Testing React internals
})
```

✅ **Do this instead**:
```typescript
test('increments counter on button click', () => {
  render(<Counter />)
  fireEvent.click(screen.getByRole('button'))
  expect(screen.getByText('Count: 1')).toBeInTheDocument() // Testing behavior
})
```

### Anti-Pattern 2: Huge Test Files

❌ **Don't do this**:
```typescript
// userService.test.ts (2000 lines!)
describe('UserService', () => {
  // 50+ tests in one file
})
```

✅ **Do this instead**:
```typescript
// userService.create.test.ts
describe('UserService.create', () => {
  // 10 tests focused on create
})

// userService.update.test.ts
describe('UserService.update', () => {
  // 10 tests focused on update
})
```

### Anti-Pattern 3: Flaky Tests

❌ **Don't do this**:
```typescript
test('loads data eventually', done => {
  setTimeout(() => {
    expect(getData()).toBeDefined()
    done()
  }, 1000) // Flaky: might take longer
})
```

✅ **Do this instead**:
```typescript
test('loads data eventually', async () => {
  await waitFor(() => {
    expect(getData()).toBeDefined()
  }, { timeout: 5000 })
})
```

---

## Quick Reference

| Pattern | Code | Framework |
|---------|------|-----------|
| Basic test | `test('desc', () => {})` | Jest/Vitest |
| Basic test | `def test_function():` | Pytest |
| Async test | `test('desc', async () => {})` | Jest/Vitest |
| Mock function | `jest.fn()` | Jest |
| Mock module | `vi.mock('./module')` | Vitest |
| Fixture | `@pytest.fixture` | Pytest |
| Before each | `beforeEach(() => {})` | Jest/Vitest |
| Setup | `def setup_method(self):` | Pytest |
| Assert equal | `expect(x).toBe(y)` | Jest/Vitest |
| Assert equal | `assert x == y` | Pytest |
| Assert throw | `expect(() => {}).toThrow()` | Jest/Vitest |
| Assert raise | `with pytest.raises(Exception):` | Pytest |

---

## Progressive Disclosure

> **Note**: This skill covers common testing patterns.

**For detailed information, see**:
- `references/e2e-testing.md` - End-to-end testing strategies
- `references/mocking-strategies.md` - Advanced mocking patterns
- `references/test-coverage.md` - Coverage analysis and improvement
- `examples/` - Complete test suites

---

## Version Information

**Last Updated**: 2026-01-15
**Compatible With**: Jest 29+, Vitest 1+, Pytest 7+

---

## Resources

**Official Documentation**:
- [Jest](https://jestjs.io/)
- [Vitest](https://vitest.dev/)
- [Pytest](https://docs.pytest.org/)
- [Testing Library](https://testing-library.com/)

---

_This skill demonstrates domain skill pattern (cross-framework testing knowledge)._
