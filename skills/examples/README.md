# Skill Examples

This directory contains complete, working examples of different skill patterns. Use these as references when creating your own skills.

---

## Quick Reference

| Example | Pattern | Category | Complexity | Use As Template For |
|---------|---------|----------|------------|---------------------|
| [minimal-skill.md](minimal-skill.md) | Simplest skill | Meta | ⭐ Simple | Checklists, conventions, simple patterns |
| [stack-skill.md](stack-skill.md) | Framework patterns | Stack | ⭐⭐⭐ Complex | React, Vue, Angular, Django, FastAPI |
| [domain-skill.md](domain-skill.md) | Cross-framework knowledge | Domain | ⭐⭐ Medium | Testing, security, performance, API design |
| [meta-skill.md](meta-skill.md) | Process/workflow | Meta | ⭐⭐ Medium | Code review, debugging, workflows |

---

## Examples Overview

### 1. minimal-skill.md - Git Conventional Commits

**Pattern**: Simplest possible skill structure

**What it demonstrates**:
- Minimal YAML frontmatter (required fields only)
- Single core pattern
- Quick reference table
- Anti-patterns section
- ~80 lines total

**Key features**:
- No progressive disclosure needed
- One main concept (commit format)
- Simple examples
- No version-specific content

**Use this template for**:
- Conventions and standards (Git, code style)
- Checklists (deployment, review)
- Simple patterns (formatting, linting)
- Quick reference guides

**Example use case**:
```
User: "Create a git commit"
→ Claude references git-conventional-commits skill
→ Suggests: "feat: add user authentication"
```

---

### 2. stack-skill.md - Vue 3 Composition API

**Pattern**: Technology-specific framework knowledge

**What it demonstrates**:
- Version-specific content (Vue 3.4)
- Multiple core concepts (5 concepts)
- Progressive disclosure structure
- Version deprecation warnings
- Comprehensive examples
- Quick reference table

**Key features**:
- Stack category metadata
- Auto-invoke pattern
- References to advanced docs
- Anti-patterns section
- TypeScript integration

**Use this template for**:
- Frontend frameworks (React, Vue, Angular, Svelte)
- Backend frameworks (Django, FastAPI, Express)
- Languages (Python, TypeScript, Go, Rust)
- ORMs (Prisma, TypeORM, SQLAlchemy)

**Example use case**:
```
User: "Create a Vue component that fetches data"
→ Claude references vue-3-composition skill
→ Suggests async Server Component pattern with onMounted
```

**Why version-specific**:
- Patterns change between Vue 2 and Vue 3
- Composition API is Vue 3+
- Reactivity Transform deprecated in 3.4
- Keeps examples current and accurate

---

### 3. domain-skill.md - Testing Patterns

**Pattern**: Cross-framework domain expertise

**What it demonstrates**:
- Framework-agnostic patterns
- Multiple framework examples (Jest, Vitest, Pytest)
- AAA pattern (Arrange-Act-Assert)
- Mocking strategies
- Test organization
- Progressive disclosure for advanced topics

**Key features**:
- Domain category metadata
- Applicable across stacks
- Side-by-side framework examples
- Common scenarios
- Anti-patterns (flaky tests)

**Use this template for**:
- Testing strategies (unit, integration, e2e)
- Security best practices (OWASP, auth patterns)
- Performance optimization (caching, queries)
- API design (REST, GraphQL)
- Accessibility (WCAG, ARIA)
- Internationalization (i18n, l10n)

**Example use case**:
```
User: "Write tests for authentication flow"
→ Claude references testing-patterns skill
→ Suggests AAA pattern, mock external services, test error cases
→ Works whether using Jest, Vitest, or Pytest
```

**Why cross-framework**:
- Testing principles are universal
- AAA pattern applies everywhere
- Mocking concepts transfer across tools
- Allows skill reuse across projects

---

### 4. meta-skill.md - Code Review Checklist

**Pattern**: Process and workflow guidance

**What it demonstrates**:
- Non-code skill (workflow/process)
- Checklist structure
- Severity levels (Critical, High, Medium, Low)
- Constructive feedback patterns
- Common scenarios handling
- No progressive disclosure needed (complete in ~300 lines)

**Key features**:
- Meta category metadata
- Process guidance, not code patterns
- Communication templates
- Practical scenarios
- Copy-paste checklist

**Use this template for**:
- Code review guidelines
- Debugging strategies
- Deployment checklists
- Incident response procedures
- Onboarding processes
- Architecture decision records (ADRs)

**Example use case**:
```
User: "Review this pull request"
→ Claude references code-review-checklist skill
→ Systematically checks: functionality, quality, security, performance
→ Provides severity-categorized feedback
→ Uses constructive feedback patterns
```

**Why meta skill**:
- Not technology-specific
- Process applies across all projects
- Shorter than stack/domain skills
- No code examples needed (guidance only)

---

## Comparison: When to Use Each Pattern

### Use **minimal-skill** when:
- ✅ Simple, well-defined pattern
- ✅ No version variations
- ✅ Quick reference is sufficient
- ✅ <100 lines of content

**Examples**: Git conventions, code style, simple checklists

### Use **stack-skill** when:
- ✅ Framework/language-specific
- ✅ Version matters (patterns change between versions)
- ✅ Large API surface area
- ✅ Progressive disclosure needed
- ✅ Auto-invoke when working with that stack

**Examples**: React 19, Next.js 15, Django 5, Python 3.12

### Use **domain-skill** when:
- ✅ Applies across multiple frameworks
- ✅ Domain expertise (not tech-specific)
- ✅ Cross-cutting concern
- ✅ Referenced by multiple agents

**Examples**: Security, testing, performance, API design, accessibility

### Use **meta-skill** when:
- ✅ Process or workflow (not code)
- ✅ Applies to all projects
- ✅ Guidance and checklists
- ✅ Communication patterns

**Examples**: Code review, debugging, deployment, incident response

---

## Content Length Patterns

### Minimal Skill (<100 lines)
```
- One core concept
- Quick reference
- Minimal examples
- No progressive disclosure
```
**Example**: git-conventional-commits (80 lines)

### Medium Skill (100-300 lines)
```
- 2-3 core concepts
- Common scenarios
- Anti-patterns
- Quick reference
- No progressive disclosure needed
```
**Example**: code-review-checklist (280 lines)

### Medium-Complex Skill (300-500 lines)
```
- 3-5 core concepts
- Multiple patterns
- Common scenarios
- Anti-patterns
- Quick reference
- May use progressive disclosure
```
**Example**: testing-patterns (450 lines)

### Complex Skill (500+ lines)
```
- 5+ core concepts
- Many patterns and scenarios
- MUST use progressive disclosure
- Main skill ~400-500 lines
- References in references/ directory
```
**Example**: vue-3-composition (main + references/)

---

## Progressive Disclosure Examples

### Stack Skill Structure (Complex)
```
vue-3-composition/
├── SKILL.md                      # Main content (~400 lines)
└── references/                   # Loaded as needed
    ├── advanced-composables.md   # Complex patterns
    ├── typescript-patterns.md    # TypeScript integration
    ├── performance.md            # Optimizations
    └── examples/                 # Complete apps
        ├── todo-app/
        └── blog/
```

### Domain Skill Structure (Medium-Complex)
```
testing-patterns/
├── SKILL.md                      # Main content (~450 lines)
└── references/                   # Loaded as needed
    ├── e2e-testing.md           # Playwright, Cypress
    ├── mocking-strategies.md     # Advanced mocking
    └── test-coverage.md          # Coverage tools
```

### Meta Skill (No Progressive Disclosure)
```
code-review-checklist/
└── SKILL.md                      # Complete (~280 lines)
```

---

## YAML Frontmatter Patterns

### Minimal Skill
```yaml
---
name: git-conventional-commits
description: Conventional Commits specification patterns. Use when creating git commits.
tags: [git, workflow, conventions]
author: dsmj-ai-toolkit
---
```

### Stack Skill
```yaml
---
name: vue-3-composition
version: 3.4.0
description: Vue 3 Composition API patterns. Use when writing Vue 3 components, composables, or reactive state.
tags: [vue, frontend, javascript, typescript]
author: dsmj-ai-toolkit
metadata:
  auto_invoke: "Writing Vue 3 components, .vue files, composables"
  category: stack
  progressive_disclosure: true
---
```

### Domain Skill
```yaml
---
name: testing-patterns
version: 1.0.0
description: Testing best practices across frameworks. Use when writing tests or implementing TDD.
tags: [testing, tdd, jest, vitest, pytest]
author: dsmj-ai-toolkit
metadata:
  auto_invoke: "Writing tests, implementing TDD, or ensuring test coverage"
  category: domain
  progressive_disclosure: true
---
```

### Meta Skill
```yaml
---
name: code-review-checklist
description: Code review best practices and quality checklist. Use when reviewing code or preparing for review.
tags: [meta, workflow, quality, code-review]
author: dsmj-ai-toolkit
metadata:
  category: meta
  progressive_disclosure: false
---
```

---

## Common Sections Reference

### Required Sections (All Skills)
1. **YAML Frontmatter** - name, description (required)
2. **Title & Tagline** - H1 with brief description
3. **Overview** - What/When/Key concepts
4. **Core Concepts** - 1-5 main concepts (depends on skill complexity)
5. **Quick Reference** - Cheat sheet table

### Recommended Sections
- **Patterns & Best Practices** - Actionable patterns with code
- **Common Scenarios** - Real-world use cases
- **Anti-Patterns** - What NOT to do (highly recommended)

### Optional Sections
- **Progressive Disclosure** - Links to references/ (if skill >500 lines)
- **Version Information** - Current version, deprecations (stack skills)
- **Resources** - Official docs, community links

---

## How to Use These Examples

### 1. Find Similar Pattern

Match your skill to closest example:
- Simple convention? → **minimal-skill**
- Framework-specific? → **stack-skill**
- Cross-framework domain? → **domain-skill**
- Process/workflow? → **meta-skill**

### 2. Copy Template

```bash
# For new stack skill
cp skills/examples/stack-skill.md skills/stack/your-framework/SKILL.md

# For domain skill
cp skills/examples/domain-skill.md skills/domain/your-domain/SKILL.md

# For meta skill
cp skills/examples/meta-skill.md skills/meta/your-workflow/SKILL.md
```

### 3. Customize

- Update YAML frontmatter
- Replace framework/domain examples
- Adjust core concepts (1-5)
- Update patterns for your domain
- Modify quick reference

### 4. Test

Start Claude Code and verify:
- Skill loads correctly
- Auto-invoke works (if applicable)
- Examples are accurate
- References load (if using progressive disclosure)

---

## Best Practices from Examples

### 1. Code-Heavy (from stack-skill, domain-skill)
- Show code first, explain after
- Working examples (not pseudocode)
- Include imports and types
- Comment for clarity, not excessively

### 2. Anti-Patterns Section (all examples)
- Every skill should have anti-patterns
- Show bad example → good example
- Explain why it's wrong

### 3. Quick Reference (all examples)
- Table format for scanning
- Most common operations
- Copy-paste ready

### 4. Progressive Disclosure (stack-skill, domain-skill)
- Main content <500 lines
- Complex topics in references/
- Document when to load references

### 5. Version-Specific (stack-skill)
- Include version in name if relevant
- Mark deprecated patterns
- Note "Version X+" for new features

### 6. Cross-Framework Examples (domain-skill)
- Show multiple frameworks side-by-side
- Universal principles first
- Framework-specific details second

### 7. Constructive Language (meta-skill)
- Templates for communication
- Explain why, not just what
- Acknowledge tradeoffs

---

## Validation Checklist

Use this to verify your skill against examples:

**YAML Frontmatter**:
- [ ] name: kebab-case, descriptive
- [ ] description: what + when to use
- [ ] tags: relevant categories
- [ ] metadata: auto_invoke (if applicable), category

**Structure** (compare to examples):
- [ ] Matches appropriate pattern (minimal/stack/domain/meta)
- [ ] Has required sections
- [ ] Core concepts count appropriate (1 for minimal, 3-5 for complex)

**Content Quality**:
- [ ] Code examples are working (not pseudocode)
- [ ] Anti-patterns section included
- [ ] Quick reference table present
- [ ] Length appropriate (<500 lines or uses progressive disclosure)

**Pattern-Specific**:
- [ ] Stack: Version specified, auto-invoke set
- [ ] Domain: Cross-framework if applicable
- [ ] Meta: Process guidance, not code-specific

---

## Creating Your Own Examples

Have a well-tested skill? Consider contributing it as an example:

1. **Generalize**: Remove project-specific details
2. **Document**: Explain the pattern it demonstrates
3. **Complete**: Ensure all required sections present
4. **Test**: Verify it works as standalone example
5. **Submit**: PR to dsmj-ai-toolkit

**Good candidates**:
- Unique domain expertise
- Emerging framework/technology
- Specialized workflow pattern
- Fills gap in current examples

---

## Resources

- [skills/TEMPLATE.md](../TEMPLATE.md) - Blank template to copy
- [skills/GUIDE.md](../GUIDE.md) - Complete creation guide
- [../../docs/ARCHITECTURE.md](../../docs/ARCHITECTURE.md) - How skills fit in toolkit

**Official Docs**:
- [Agent Skills Overview](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview)
- [Skill Authoring Best Practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices)
- [Anthropic Skills Repository](https://github.com/anthropics/skills)

---

**Questions?** Open an issue at https://github.com/dsantiagomj/dsmj-ai-toolkit/issues
