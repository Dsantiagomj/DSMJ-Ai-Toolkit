---
name: testing-frameworks
domain: testing
description: >
  Testing patterns for Jest, Vitest, and Pytest. Covers test structure (AAA pattern), mocking strategies, fixtures, assertions, and testing best practices.
  Trigger: When writing tests, when setting up test frameworks, when implementing mocks, when creating test fixtures, when following TDD practices.
version: 1.0.0
tags: [testing, jest, vitest, pytest, mocking, fixtures, tdd]
metadata:
  version: "1.0"
  last_updated: "2026-01-17"
  category: domain
  progressive_disclosure: true
references:
  - name: Jest & Vitest Guide
    url: ./references/jest-vitest.md
    type: local
  - name: Pytest Guide
    url: ./references/pytest.md
    type: local
  - name: Jest Documentation
    url: https://jestjs.io/docs/getting-started
    type: documentation
  - name: Vitest Documentation
    url: https://vitest.dev/guide/
    type: documentation
  - name: Pytest Documentation
    url: https://docs.pytest.org/
    type: documentation
---

# Testing Frameworks - Jest, Vitest, Pytest

**Write maintainable, reliable tests with proper structure and mocking**

---

## When to Use This Skill

Use this skill when:
- Writing unit, integration, or end-to-end tests
- Setting up test frameworks
- Implementing mocks and fixtures
- Following TDD practices

---

## Critical Patterns

### Pattern 1: AAA Pattern

**When**: Structuring all tests

**Good**:
```typescript
test('should apply 10% discount for orders over $100', () => {
  // Arrange
  const order = { items: [{ price: 120 }], discount: 0.1 };

  // Act
  const total = calculateTotal(order);

  // Assert
  expect(total).toBe(108);
});
```

**Why**: AAA (Arrange, Act, Assert) makes tests clear and maintainable.

---

### Pattern 2: Mocking Dependencies

**When**: Isolating units under test

**Good** (Jest):
```typescript
import { getUserById } from './userService';
import { fetchUser } from './api';

jest.mock('./api');

test('should fetch and return user', async () => {
  // Arrange
  const mockUser = { id: 1, name: 'Alice' };
  (fetchUser as jest.Mock).mockResolvedValue(mockUser);

  // Act
  const user = await getUserById(1);

  // Assert
  expect(fetchUser).toHaveBeenCalledWith(1);
  expect(user).toEqual(mockUser);
});
```

**Good** (Pytest):
```python
def test_get_user(mocker):
    # Arrange
    mock_get = mocker.patch('requests.get')
    mock_get.return_value.json.return_value = {"id": 1, "name": "Alice"}

    # Act
    user = get_user(1)

    # Assert
    assert user["name"] == "Alice"
```

**Why**: Mocking isolates the unit under test and makes tests fast and reliable.

---

### Pattern 3: Test Organization

**When**: Grouping related tests

**Good**:
```typescript
describe('calculateTotal', () => {
  test('applies discount for orders over $100', () => {
    expect(calculateTotal({ price: 120, discount: 0.1 })).toBe(108);
  });

  test('handles zero discount', () => {
    expect(calculateTotal({ price: 50, discount: 0 })).toBe(50);
  });

  test('throws error for negative prices', () => {
    expect(() => calculateTotal({ price: -10 })).toThrow();
  });
});
```

**Why**: Grouping related tests improves organization and readability.

---

### Pattern 4: Async Testing

**When**: Testing asynchronous code

**Good**:
```typescript
// async/await
test('should fetch user data', async () => {
  const data = await fetchUser(1);
  expect(data.name).toBe('Alice');
});

// .resolves/.rejects
test('should fetch user data', () => {
  return expect(fetchUser(1)).resolves.toHaveProperty('name', 'Alice');
});

test('should handle errors', () => {
  return expect(fetchUser(999)).rejects.toThrow('User not found');
});
```

**Why**: Properly handling async ensures tests wait for operations to complete.

---

### Pattern 5: Fixtures (Pytest)

**When**: Reusing test data

**Good**:
```python
@pytest.fixture
def user():
    return {"id": 1, "name": "Alice"}

@pytest.fixture
def database():
    db = Database()
    db.connect()
    yield db
    db.disconnect()

def test_save_user(database, user):
    database.save(user)
    assert database.count() == 1
```

**Why**: Fixtures provide reusable setup and teardown logic.

---

## Best Practices

### One Assertion Per Test
```typescript
// ✅ Good: Separate tests
test('user has correct name', () => {
  expect(user.name).toBe('Alice');
});

test('user email is valid', () => {
  expect(user.email).toContain('@');
});

// ❌ Bad: Multiple unrelated assertions
test('user validation', () => {
  expect(user.name).toBe('Alice');
  expect(user.email).toContain('@');
  expect(user.age).toBeGreaterThan(0);
});
```

---

## Quick Reference

### Jest/Vitest Commands
```bash
npm test                    # Run all tests
npm test -- --watch         # Watch mode
npm test -- --coverage      # Coverage report
```

### Pytest Commands
```bash
pytest                      # Run all tests
pytest -v                   # Verbose
pytest --cov=myapp          # Coverage
pytest -k "user"            # Run tests matching "user"
```

---

## Progressive Disclosure

For detailed implementations:
- **[Jest & Vitest Guide](./references/jest-vitest.md)** - Matchers, mocking, setup/teardown
- **[Pytest Guide](./references/pytest.md)** - Fixtures, parametrized tests, mocking

---

## References

- [Jest & Vitest Guide](./references/jest-vitest.md)
- [Pytest Guide](./references/pytest.md)
- [Jest Documentation](https://jestjs.io/docs/getting-started)
- [Vitest Documentation](https://vitest.dev/guide/)
- [Pytest Documentation](https://docs.pytest.org/)

---

_Maintained by dsmj-ai-toolkit_
