---
name: testing-frameworks
domain: testing
description: Testing patterns for Jest, Vitest, and Pytest. Covers test structure (AAA pattern), mocking strategies, fixtures, assertions, and testing best practices for JavaScript/TypeScript and Python.
version: 1.0.0
tags: [testing, jest, vitest, pytest, mocking, fixtures, tdd]
references:
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

## What This Skill Covers

This skill provides guidance on:
- **AAA pattern** (Arrange, Act, Assert)
- **Jest** testing patterns (JavaScript/TypeScript)
- **Vitest** testing patterns (modern, fast alternative to Jest)
- **Pytest** testing patterns (Python)
- **Mocking strategies** for external dependencies
- **Test organization** and best practices

---

## Test Structure - AAA Pattern

All tests should follow the **Arrange, Act, Assert** pattern:

1. **Arrange**: Set up test data and dependencies
2. **Act**: Execute the code being tested
3. **Assert**: Verify the result

**Example** (Jest/TypeScript):
```typescript
describe('calculateTotal', () => {
  test('should apply 10% discount for orders over $100', () => {
    // Arrange
    const order = { items: [{ price: 120 }], discount: 0.1 };

    // Act
    const total = calculateTotal(order);

    // Assert
    expect(total).toBe(108); // 120 - (120 * 0.1)
  });
});
```

---

## Jest - JavaScript/TypeScript Testing

### Basic Test Structure

```typescript
// sum.test.ts
import { sum } from './sum';

describe('sum function', () => {
  test('adds 1 + 2 to equal 3', () => {
    expect(sum(1, 2)).toBe(3);
  });

  test('adds negative numbers', () => {
    expect(sum(-1, -2)).toBe(-3);
  });
});
```

**Key functions**:
- `describe()`: Group related tests
- `test()` or `it()`: Define a test case
- `expect()`: Make assertions

---

### Common Jest Matchers

```typescript
// Equality
expect(value).toBe(4);              // Strict equality (===)
expect(value).toEqual({ a: 1 });    // Deep equality (objects/arrays)

// Truthiness
expect(value).toBeTruthy();         // Truthy value
expect(value).toBeFalsy();          // Falsy value
expect(value).toBeNull();           // Exactly null
expect(value).toBeUndefined();      // Exactly undefined
expect(value).toBeDefined();        // Not undefined

// Numbers
expect(value).toBeGreaterThan(3);
expect(value).toBeGreaterThanOrEqual(3.5);
expect(value).toBeLessThan(5);
expect(value).toBeLessThanOrEqual(4.5);
expect(value).toBeCloseTo(0.3);     // Floating point

// Strings
expect(value).toMatch(/pattern/);

// Arrays/Iterables
expect(array).toContain('item');
expect(array).toHaveLength(3);

// Objects
expect(obj).toHaveProperty('key');
expect(obj).toHaveProperty('key', 'value');

// Exceptions
expect(() => fn()).toThrow();
expect(() => fn()).toThrow(Error);
expect(() => fn()).toThrow('error message');

// Functions called
expect(mockFn).toHaveBeenCalled();
expect(mockFn).toHaveBeenCalledTimes(2);
expect(mockFn).toHaveBeenCalledWith(arg1, arg2);
```

---

### Setup and Teardown

```typescript
describe('Database tests', () => {
  // Runs once before all tests in this describe block
  beforeAll(async () => {
    await database.connect();
  });

  // Runs before each test
  beforeEach(() => {
    database.clear();
  });

  // Runs after each test
  afterEach(() => {
    // Clean up
  });

  // Runs once after all tests
  afterAll(async () => {
    await database.disconnect();
  });

  test('should save user', async () => {
    const user = await database.save({ name: 'Alice' });
    expect(user.id).toBeDefined();
  });
});
```

---

### Mocking with Jest

**Mock functions**:
```typescript
// Create mock function
const mockFn = jest.fn();

// Mock implementation
const mockFn = jest.fn((x) => x * 2);

// Mock return value
mockFn.mockReturnValue(42);
mockFn.mockReturnValueOnce(1).mockReturnValueOnce(2);

// Mock resolved/rejected promises
mockFn.mockResolvedValue({ data: 'success' });
mockFn.mockRejectedValue(new Error('Failed'));

// Check how function was called
expect(mockFn).toHaveBeenCalled();
expect(mockFn).toHaveBeenCalledTimes(2);
expect(mockFn).toHaveBeenCalledWith('arg1', 'arg2');
expect(mockFn).toHaveBeenLastCalledWith('arg3');

// Access call information
expect(mockFn.mock.calls.length).toBe(2);
expect(mockFn.mock.calls[0][0]).toBe('first arg');
expect(mockFn.mock.results[0].value).toBe(42);
```

**Mock modules**:
```typescript
// userService.test.ts
import { getUserById } from './userService';
import { fetchUser } from './api';

// Mock entire module
jest.mock('./api');

describe('getUserById', () => {
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
});
```

**Partial mocking**:
```typescript
jest.mock('./utils', () => ({
  ...jest.requireActual('./utils'),
  formatDate: jest.fn(() => '2024-01-01'), // Override only this function
}));
```

**Spy on methods**:
```typescript
const user = { save: () => Promise.resolve() };
const saveSpy = jest.spyOn(user, 'save');

await user.save();

expect(saveSpy).toHaveBeenCalled();
saveSpy.mockRestore(); // Restore original implementation
```

---

### Async Testing

```typescript
// Promises
test('should fetch user data', async () => {
  const data = await fetchUser(1);
  expect(data.name).toBe('Alice');
});

// Or using .resolves/.rejects
test('should fetch user data', () => {
  return expect(fetchUser(1)).resolves.toHaveProperty('name', 'Alice');
});

test('should handle errors', () => {
  return expect(fetchUser(999)).rejects.toThrow('User not found');
});

// Callbacks
test('callback should be called', (done) => {
  function callback(data) {
    expect(data).toBe('done');
    done();
  }

  fetchData(callback);
});
```

---

## Vitest - Modern Testing Framework

Vitest is Jest-compatible but faster. Most Jest patterns work in Vitest.

### Basic Test Structure (Identical to Jest)

```typescript
// sum.test.ts
import { describe, test, expect } from 'vitest';
import { sum } from './sum';

describe('sum function', () => {
  test('adds 1 + 2 to equal 3', () => {
    expect(sum(1, 2)).toBe(3);
  });
});
```

---

### Mocking with Vitest

**Use `vi` instead of `jest`**:

```typescript
import { describe, test, expect, vi, beforeEach, afterEach } from 'vitest';
import { getUserById } from './userService';
import * as api from './api';

// Mock module
vi.mock('./api');

describe('getUserById', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  test('should fetch user', async () => {
    // Arrange
    const mockUser = { id: 1, name: 'Alice' };
    vi.spyOn(api, 'fetchUser').mockResolvedValue(mockUser);

    // Act
    const user = await getUserById(1);

    // Assert
    expect(api.fetchUser).toHaveBeenCalledWith(1);
    expect(user).toEqual(mockUser);
  });
});
```

**Mock timers**:
```typescript
import { vi, test, expect, beforeEach, afterEach } from 'vitest';

beforeEach(() => {
  vi.useFakeTimers();
});

afterEach(() => {
  vi.restoreAllMocks();
});

test('should delay execution', () => {
  const callback = vi.fn();

  setTimeout(callback, 1000);

  expect(callback).not.toHaveBeenCalled();

  vi.advanceTimersByTime(1000);

  expect(callback).toHaveBeenCalled();
});
```

---

### Vitest Configuration

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: true,        // Use global test functions (no imports needed)
    environment: 'node',  // or 'jsdom' for browser environment
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
    },
  },
});
```

---

## Pytest - Python Testing

### Basic Test Structure

```python
# test_calculator.py
def sum(a, b):
    return a + b

def test_sum_positive_numbers():
    # Arrange
    a, b = 2, 3

    # Act
    result = sum(a, b)

    # Assert
    assert result == 5

def test_sum_negative_numbers():
    assert sum(-1, -2) == -3
```

**Key conventions**:
- Test files: `test_*.py` or `*_test.py`
- Test functions: `test_*()`
- Test classes: `Test*` with methods `test_*()`

---

### Pytest Assertions

```python
# Basic assertions
assert value == 4
assert value != 5
assert value > 3
assert value >= 4
assert value < 10
assert value <= 10

# Membership
assert 'item' in collection
assert 'item' not in collection

# Identity
assert value is None
assert value is not None

# Boolean
assert value
assert not value

# Exceptions
import pytest

def test_raises_error():
    with pytest.raises(ValueError):
        int('invalid')

    with pytest.raises(ValueError, match='invalid literal'):
        int('invalid')

# Approximate comparison (floating point)
assert 0.1 + 0.2 == pytest.approx(0.3)
```

---

### Fixtures

Fixtures provide reusable test data and setup.

```python
# conftest.py (shared fixtures)
import pytest

@pytest.fixture
def user():
    """Provides a test user."""
    return {"id": 1, "name": "Alice", "email": "alice@example.com"}

@pytest.fixture
def database():
    """Set up and tear down database."""
    db = Database()
    db.connect()
    yield db  # Test runs here
    db.disconnect()  # Teardown

# test_user.py
def test_user_name(user):
    assert user["name"] == "Alice"

def test_save_user(database, user):
    database.save(user)
    assert database.count() == 1
```

**Fixture scopes**:
```python
@pytest.fixture(scope="function")  # Default: run before each test
def func_fixture():
    pass

@pytest.fixture(scope="class")  # Run once per test class
def class_fixture():
    pass

@pytest.fixture(scope="module")  # Run once per module
def module_fixture():
    pass

@pytest.fixture(scope="session")  # Run once per session
def session_fixture():
    pass
```

---

### Parametrized Tests

Run same test with different inputs:

```python
import pytest

@pytest.mark.parametrize("a,b,expected", [
    (2, 3, 5),
    (0, 0, 0),
    (-1, 1, 0),
    (10, 20, 30),
])
def test_sum(a, b, expected):
    assert sum(a, b) == expected

# More readable with pytest.param
@pytest.mark.parametrize("input,expected", [
    pytest.param("hello", "HELLO", id="lowercase"),
    pytest.param("HELLO", "HELLO", id="already_uppercase"),
    pytest.param("Hello", "HELLO", id="mixed_case"),
])
def test_uppercase(input, expected):
    assert input.upper() == expected
```

---

### Mocking in Pytest

**Using unittest.mock**:
```python
from unittest.mock import Mock, patch
import requests

def get_user(user_id):
    response = requests.get(f"https://api.example.com/users/{user_id}")
    return response.json()

def test_get_user():
    # Mock the requests.get function
    with patch('requests.get') as mock_get:
        # Arrange
        mock_response = Mock()
        mock_response.json.return_value = {"id": 1, "name": "Alice"}
        mock_get.return_value = mock_response

        # Act
        user = get_user(1)

        # Assert
        mock_get.assert_called_once_with("https://api.example.com/users/1")
        assert user["name"] == "Alice"
```

**Using pytest-mock (cleaner)**:
```python
# pip install pytest-mock

def test_get_user(mocker):
    # Arrange
    mock_get = mocker.patch('requests.get')
    mock_get.return_value.json.return_value = {"id": 1, "name": "Alice"}

    # Act
    user = get_user(1)

    # Assert
    mock_get.assert_called_once_with("https://api.example.com/users/1")
    assert user["name"] == "Alice"
```

---

### Markers

Organize and control test execution:

```python
import pytest

@pytest.mark.slow
def test_slow_operation():
    # Slow test
    pass

@pytest.mark.integration
def test_api_integration():
    # Integration test
    pass

@pytest.mark.skip(reason="Not implemented yet")
def test_future_feature():
    pass

@pytest.mark.skipif(sys.version_info < (3, 10), reason="Requires Python 3.10+")
def test_new_syntax():
    pass

@pytest.mark.xfail(reason="Known bug #123")
def test_known_bug():
    pass
```

**Run tests by marker**:
```bash
pytest -m slow              # Run only slow tests
pytest -m "not slow"        # Skip slow tests
pytest -m "integration"     # Run only integration tests
```

---

## Testing Best Practices

### 1. One Assertion Per Test (Ideal)

```typescript
// ❌ Bad: Multiple unrelated assertions
test('user validation', () => {
  expect(user.name).toBe('Alice');
  expect(user.email).toContain('@');
  expect(user.age).toBeGreaterThan(0);
});

// ✅ Good: Separate tests
test('user has correct name', () => {
  expect(user.name).toBe('Alice');
});

test('user email is valid', () => {
  expect(user.email).toContain('@');
});

test('user age is positive', () => {
  expect(user.age).toBeGreaterThan(0);
});
```

### 2. Test Behavior, Not Implementation

```typescript
// ❌ Bad: Testing implementation details
test('should call helper function twice', () => {
  const spy = jest.spyOn(utils, 'helperFn');
  processUser(user);
  expect(spy).toHaveBeenCalledTimes(2);
});

// ✅ Good: Testing behavior/outcome
test('should process user correctly', () => {
  const result = processUser(user);
  expect(result.status).toBe('active');
  expect(result.processedAt).toBeDefined();
});
```

### 3. Descriptive Test Names

```typescript
// ❌ Bad
test('test 1', () => { /* ... */ });

// ✅ Good
test('should return 404 when user not found', () => { /* ... */ });
test('should apply 10% discount for orders over $100', () => { /* ... */ });
test('should throw error when email is invalid', () => { /* ... */ });
```

### 4. Avoid Test Interdependence

```typescript
// ❌ Bad: Tests depend on execution order
let userId;

test('create user', () => {
  userId = createUser({ name: 'Alice' });
});

test('get user', () => {
  const user = getUser(userId); // Depends on previous test!
  expect(user.name).toBe('Alice');
});

// ✅ Good: Each test is independent
test('create user', () => {
  const userId = createUser({ name: 'Alice' });
  expect(userId).toBeDefined();
});

test('get user', () => {
  const userId = createUser({ name: 'Alice' }); // Create own data
  const user = getUser(userId);
  expect(user.name).toBe('Alice');
});
```

### 5. Keep Tests Fast

```typescript
// ❌ Bad: Slow test
test('process large dataset', async () => {
  const data = generateMillionRecords();
  await processAllRecords(data); // Takes 10 seconds
});

// ✅ Good: Use smaller dataset or mock
test('process records', async () => {
  const data = generateRecords(10); // Small sample
  await processAllRecords(data);
});
```

### 6. Test Edge Cases

```typescript
describe('divide', () => {
  test('divides positive numbers', () => {
    expect(divide(10, 2)).toBe(5);
  });

  test('divides negative numbers', () => {
    expect(divide(-10, 2)).toBe(-5);
  });

  test('throws error when dividing by zero', () => {
    expect(() => divide(10, 0)).toThrow('Division by zero');
  });

  test('handles decimal results', () => {
    expect(divide(5, 2)).toBeCloseTo(2.5);
  });
});
```

---

## Quick Reference

### Jest/Vitest Commands
```bash
npm test                    # Run all tests
npm test -- --watch         # Watch mode
npm test -- --coverage      # Coverage report
npm test -- path/to/test    # Run specific test
npm test -- -t "pattern"    # Run tests matching pattern
```

### Pytest Commands
```bash
pytest                      # Run all tests
pytest -v                   # Verbose output
pytest -k "user"            # Run tests matching "user"
pytest -m "slow"            # Run tests with marker "slow"
pytest --cov=myapp          # Coverage report
pytest -x                   # Stop on first failure
pytest --lf                 # Run last failed tests
```

---

## References

- [Jest Documentation](https://jestjs.io/docs/getting-started)
- [Vitest Documentation](https://vitest.dev/guide/)
- [Pytest Documentation](https://docs.pytest.org/)

---

_Maintained by dsmj-ai-toolkit_
