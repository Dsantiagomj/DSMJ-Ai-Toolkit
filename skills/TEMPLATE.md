---
name: skill-name
description: >
  Brief description of what this skill covers.
  Trigger: When working with [technology], when building [type of app], when using [library].
metadata:
  author: your-github-username
  version: "1.0"
  category: stack|domain|meta
  last_updated: YYYY-MM-DD
---

# Skill Name

> Brief tagline describing the skill's domain knowledge

## When to Use

Load this skill when:
- [Condition 1, e.g., "Working with React Server Components"]
- [Condition 2, e.g., "Building Next.js 15 applications"]
- [Condition 3, e.g., "Using App Router patterns"]

## Critical Patterns

### Pattern 1: [Name]

[Brief explanation of the pattern and why it matters]

```typescript
// ✅ GOOD: Correct implementation
const example = () => {
  // Implementation following best practices
};

// ❌ BAD: Common mistake to avoid
const badExample = () => {
  // What NOT to do
};
```

**When to use**: [Specific scenario]

### Pattern 2: [Name]

[Explanation]

```typescript
// ✅ GOOD: Recommended approach
const correctWay = () => {
  // Your code here
};

// ❌ BAD: Anti-pattern
const wrongWay = () => {
  // What to avoid
};
```

**When to use**: [Specific scenario]

### Pattern 3: [Name]

[Explanation]

```typescript
// ✅ GOOD
// Example

// ❌ BAD
// Example
```

## Code Examples

### Example 1: [Common Use Case]

**Scenario**: [What user is trying to accomplish]

```typescript
// Complete working example showing the pattern in action
import { something } from 'library';

function CompleteExample() {
  // Full implementation
  return result;
}
```

**Key points**:
- Point 1 explaining the code
- Point 2 highlighting best practice
- Point 3 noting important detail

### Example 2: [Another Use Case]

**Scenario**: [Description]

```typescript
// Another complete example
function AnotherExample() {
  // Implementation
}
```

### Example 3: [Edge Case or Advanced Usage]

**Scenario**: [Description]

```typescript
// Edge case handling
function EdgeCaseExample() {
  // Implementation
}
```

## Anti-Patterns

### Don't: [Anti-pattern Name]

**Why this is bad**:
- Reason 1 (e.g., "Causes unnecessary re-renders")
- Reason 2 (e.g., "Breaks React's rules")
- Reason 3 (e.g., "Poor performance")

```typescript
// ❌ BAD - Don't do this
function BadPattern() {
  // What NOT to do
}
```

**Instead, do this**:
```typescript
// ✅ GOOD - Correct approach
function GoodPattern() {
  // Proper implementation
}
```

### Don't: [Another Anti-pattern]

**Why this is bad**: [Explanation]

```typescript
// ❌ BAD
// Example

// ✅ GOOD
// Alternative
```

## Quick Reference

| Task | Pattern | Notes |
|------|---------|-------|
| [Common task 1] | `code snippet` | When to use this |
| [Common task 2] | `code snippet` | Important gotcha |
| [Common task 3] | `code snippet` | Best practice tip |

## Edge Cases & Gotchas

### Edge Case 1: [Name]

**When this happens**: [Scenario]

**Solution**:
```typescript
// How to handle this edge case
```

### Gotcha 1: [Name]

**Watch out for**: [Common mistake]

**Fix**:
```typescript
// Correct approach
```

## Progressive Disclosure

> **Note**: This template covers 80% of common use cases. For detailed information:

**Advanced topics** (load when needed):
- `references/advanced-patterns.md` - Complex scenarios
- `references/api-reference.md` - Complete API documentation
- `references/migrations.md` - Version upgrade guides
- `examples/` - Additional working examples

**When to load references**:
- Facing a complex scenario not covered above
- Need complete API documentation
- Migrating between major versions
- Building advanced features

## Keywords

[technology-name], [framework], [pattern-1], [pattern-2], [use-case], [version]

## Resources

- [Official Documentation](https://example.com)
- [Migration Guide](https://example.com/migration)
- [Community Resources](https://example.com/community)

---

## Validation Checklist

Before submitting this skill:

### Required Frontmatter
- [ ] Has `name:` field (lowercase, hyphens only)
- [ ] Has `description:` with "Trigger:" included
- [ ] Has `metadata:` with `author:` and `version:`
- [ ] Has `category:` (stack/domain/meta)

### Required Sections
- [ ] Has `## When to Use` section with 3+ conditions
- [ ] Has `## Critical Patterns` with 3+ patterns
- [ ] Has `## Code Examples` with 3+ complete examples
- [ ] Has `## Anti-Patterns` section
- [ ] Has `## Keywords` section

### Code Quality
- [ ] At least 6 code blocks total (3 patterns + 3 examples minimum)
- [ ] Each pattern shows both ✅ GOOD and ❌ BAD examples
- [ ] Examples are complete and runnable
- [ ] Code uses proper syntax highlighting (```typescript, ```python, etc.)

### Content Quality
- [ ] Skill is focused on ONE technology/framework
- [ ] Total length is 100-500 lines (concise, not encyclopedic)
- [ ] Triggers are specific and clear
- [ ] Examples solve real-world problems
- [ ] Anti-patterns explain WHY they're bad

### Git Requirements
- [ ] All commits use conventional commits format
  - Example: `feat(skills): add skill-name skill`
  - Types: feat, fix, docs, refactor, test, chore

---

_Skill template based on Gentleman-Skills format. Maintained by dsmj-ai-toolkit._
