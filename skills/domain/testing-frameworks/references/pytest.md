# Pytest Testing Guide

Complete guide to Python testing with pytest.

---

## Basic Assertions

```python
assert value == 4
assert value > 3
assert 'item' in collection
assert value is None
```

---

## Fixtures

```python
# conftest.py
import pytest

@pytest.fixture
def user():
    return {"id": 1, "name": "Alice"}

@pytest.fixture
def database():
    db = Database()
    db.connect()
    yield db
    db.disconnect()

# test_user.py
def test_user_name(user):
    assert user["name"] == "Alice"

def test_save_user(database, user):
    database.save(user)
    assert database.count() == 1
```

---

## Parametrized Tests

```python
@pytest.mark.parametrize("a,b,expected", [
    (2, 3, 5),
    (0, 0, 0),
    (-1, 1, 0),
])
def test_sum(a, b, expected):
    assert sum(a, b) == expected
```

---

## Mocking

```python
from unittest.mock import Mock, patch

def test_get_user(mocker):
    mock_get = mocker.patch('requests.get')
    mock_get.return_value.json.return_value = {"id": 1, "name": "Alice"}

    user = get_user(1)
    assert user["name"] == "Alice"
```

---

_Maintained by dsmj-ai-toolkit_
