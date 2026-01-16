---
name: code-review-checklist
description: Code review best practices and quality checklist. Use when reviewing code, conducting peer reviews, or preparing code for review.
tags: [meta, workflow, quality, code-review]
author: dsmj-ai-toolkit
metadata:
  category: meta
  progressive_disclosure: false
---

# Code Review Checklist - Quality Assurance Workflow

**Systematic approach to code review for quality and consistency**

---

## Overview

**What this skill provides**: Code review checklist and best practices
**When to use**: Reviewing pull requests, pre-commit checks, quality gates
**Key concepts**: Systematic review, constructive feedback, quality standards

---

## Core Review Checklist

### 1. Functionality

**Questions to ask**:
- ✅ Does the code do what it's supposed to?
- ✅ Are all acceptance criteria met?
- ✅ Do tests pass?
- ✅ Have edge cases been considered?

**Red flags**:
- ❌ Code doesn't match requirements
- ❌ Tests failing or missing
- ❌ Edge cases not handled

### 2. Code Quality

**Questions to ask**:
- ✅ Is code readable and maintainable?
- ✅ Are functions/classes single-responsibility?
- ✅ Is naming clear and descriptive?
- ✅ Are there code comments where needed?

**Red flags**:
- ❌ Functions longer than 50 lines
- ❌ Unclear variable names (`x`, `temp`, `data`)
- ❌ Complex logic without comments
- ❌ Duplicate code (DRY violation)

### 3. Security

**Questions to ask**:
- ✅ Is user input validated?
- ✅ Are secrets/credentials hardcoded?
- ✅ Are SQL queries parameterized?
- ✅ Is authentication/authorization checked?

**Red flags**:
- ❌ Raw SQL with string concatenation
- ❌ API keys in code
- ❌ Missing auth checks on endpoints
- ❌ User input directly in database queries

### 4. Performance

**Questions to ask**:
- ✅ Are database queries optimized?
- ✅ Are loops efficient (no N+1 queries)?
- ✅ Is caching used appropriately?
- ✅ Are large files handled properly?

**Red flags**:
- ❌ Database queries in loops
- ❌ Loading entire dataset when paginating
- ❌ No caching on expensive operations
- ❌ Synchronous operations blocking async flow

### 5. Testing

**Questions to ask**:
- ✅ Are there unit tests for new code?
- ✅ Do tests cover edge cases?
- ✅ Are tests meaningful (not just for coverage)?
- ✅ Do integration tests cover user flows?

**Red flags**:
- ❌ No tests for new functionality
- ❌ Tests only test happy path
- ❌ Flaky or unreliable tests
- ❌ Mocking everything (no real integration tests)

### 6. Documentation

**Questions to ask**:
- ✅ Are complex algorithms commented?
- ✅ Is API documentation updated?
- ✅ Are breaking changes documented?
- ✅ Is README updated if needed?

**Red flags**:
- ❌ No comments on complex logic
- ❌ Outdated documentation
- ❌ Breaking changes not mentioned

---

## Review Severity Levels

Use these to categorize feedback:

### 🔴 Critical (Must Fix)

**Blocks merge**:
- Security vulnerabilities
- Broken functionality
- Failing tests
- Data loss risks

**Example comments**:
```markdown
🔴 **Critical**: SQL injection vulnerability on line 42
This query concatenates user input directly. Use parameterized queries.
```

### 🟠 High (Should Fix)

**Strong recommendation**:
- Performance issues
- Missing error handling
- Type safety issues
- Accessibility violations

**Example comments**:
```markdown
🟠 **High**: N+1 query in loop (lines 56-62)
Consider using a join or batching to reduce database calls.
```

### 🟡 Medium (Nice to Have)

**Suggestions for improvement**:
- Code duplication
- Unclear naming
- Missing edge case handling
- Could be simpler

**Example comments**:
```markdown
🟡 **Medium**: Function name unclear (line 89)
`processData` is vague. Consider `validateUserInput` to clarify intent.
```

### 🟢 Low (Optional)

**Minor improvements**:
- Stylistic preferences
- Minor optimizations
- Nitpicks

**Example comments**:
```markdown
🟢 **Low**: Consider extracting this to a constant (line 23)
Not required, but could improve readability.
```

---

## Constructive Feedback Patterns

### Pattern 1: Explain Why

❌ **Don't**: "This is wrong."
✅ **Do**: "This could cause issues because [reason]. Consider [alternative]."

**Example**:
```markdown
❌ "Don't use var"
✅ "Using `var` can lead to hoisting issues. Use `const` for immutable
   values or `let` for reassignable variables."
```

### Pattern 2: Suggest, Don't Demand

❌ **Don't**: "Change this immediately."
✅ **Do**: "What do you think about [alternative approach]?"

**Example**:
```markdown
❌ "This is bad. Use async/await."
✅ "This could be more readable with async/await. Something like:
   ```typescript
   async function fetchData() {
     const result = await fetch(url);
     return result.json();
   }
   ```
   What do you think?"
```

### Pattern 3: Acknowledge Good Work

❌ **Don't**: Only comment on problems
✅ **Do**: Also comment on good patterns

**Example**:
```markdown
✅ "Nice use of type guards here! Clean and type-safe."
✅ "Good separation of concerns in this module."
✅ "Love the comprehensive edge case handling."
```

---

## Common Scenarios

### Scenario 1: Large Pull Request

**Problem**: PR changes 50+ files, hard to review

**Approach**:
1. Ask for breakdown: "Could we split this into smaller PRs?"
2. Review architecture/approach first
3. Focus on critical files (business logic, security)
4. Accept that deep review of all files may not be feasible

**Comment template**:
```markdown
This is a large PR. To make review more effective:
1. Could we split into: [suggested breakdown]?
2. I'll focus on [critical areas]
3. For [non-critical areas], I'll trust test coverage

Let me know if splitting is possible!
```

### Scenario 2: Repeated Mistakes

**Problem**: Same developer makes same mistake repeatedly

**Approach**:
1. Reference previous feedback
2. Suggest pair programming or knowledge sharing
3. Consider documenting pattern in team guide

**Comment template**:
```markdown
This is similar to [previous PR #123]. We discussed using [pattern]
instead of [current approach]. Would it help to pair on this to
establish the pattern? Happy to schedule time.
```

### Scenario 3: Disagreement on Approach

**Problem**: Reviewer and author disagree on solution

**Approach**:
1. Discuss tradeoffs openly
2. Bring in third opinion if needed
3. Document decision for future reference
4. Accept that multiple valid approaches exist

**Comment template**:
```markdown
I see the tradeoff here. Your approach optimizes for [X] while mine
optimizes for [Y]. Both are valid. Let's discuss:
- Use cases favor which approach?
- What's our priority: [X] or [Y]?
- Should we document this decision?
```

---

## Anti-Patterns

### Anti-Pattern 1: Nitpicking Without Priority

❌ **Don't**:
```markdown
Comment 1: Missing semicolon
Comment 2: Extra space here
Comment 3: Use single quotes
[50 more stylistic comments]
```

✅ **Do**:
```markdown
🟢 **Low**: Some stylistic inconsistencies (quotes, spacing).
Consider running Prettier/ESLint to auto-fix. Not blocking.

🟠 **High**: [Focus on substantive issues]
```

### Anti-Pattern 2: Being Vague

❌ **Don't**: "This could be better"
✅ **Do**: "This could be more performant by caching the result"

### Anti-Pattern 3: Reviewing Without Testing

❌ **Don't**: Review code without pulling/testing
✅ **Do**: Check out branch, run tests, verify functionality

---

## Quick Reference

### Review Checklist (Copy-Paste)

```markdown
## Code Review Checklist

**Functionality**
- [ ] Meets acceptance criteria
- [ ] Tests pass
- [ ] Edge cases handled

**Code Quality**
- [ ] Readable and maintainable
- [ ] Single responsibility
- [ ] Clear naming
- [ ] No duplication

**Security**
- [ ] Input validation
- [ ] No hardcoded secrets
- [ ] Auth/authz checks
- [ ] Parameterized queries

**Performance**
- [ ] No N+1 queries
- [ ] Efficient loops
- [ ] Appropriate caching

**Testing**
- [ ] Unit tests for new code
- [ ] Edge cases tested
- [ ] Integration tests for flows

**Documentation**
- [ ] Complex logic commented
- [ ] API docs updated
- [ ] README current
```

---

## Resources

**Best Practices**:
- [Google Code Review Guide](https://google.github.io/eng-practices/review/)
- [Thoughtbot Code Review Guide](https://github.com/thoughtbot/guides/tree/main/code-review)

---

_This skill demonstrates meta skill pattern (process/workflow guidance with no code)._
