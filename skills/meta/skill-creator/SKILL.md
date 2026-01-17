---
name: skill-creator
description: >
  Guides creation of new skills following dsmj-ai-toolkit v2.0 format with validation.
  Trigger: When creating new skills, when user says "create skill", when adding domain knowledge,
  when documenting patterns, when building skill for framework or technology.
tags: [meta, skill-creation, validation, templates, workflow]
author: dsmj-ai-toolkit
metadata:
  version: "1.0"
  last_updated: "2026-01-17"
  category: meta
  auto_invoke: "Creating new skills or documenting patterns"
  stack_category: meta
  progressive_disclosure: true
references:
  - name: Skill Template
    url: ../../TEMPLATE.md
    type: local
  - name: Skill Guide
    url: ../../GUIDE.md
    type: local
---

# Skill Creator - Skill Development Workflow

**Interactive guide for creating high-quality skills following v2.0 format standards**

---

## When to Use This Skill

**Use this skill when**:
- Creating a new skill for a framework, library, or technology
- Documenting domain knowledge (security, accessibility, performance)
- Building meta skills for workflow or process guidance
- User explicitly says "create a skill" or "add skill for X"
- Need to standardize patterns across the project

**Don't use this skill when**:
- Skill already exists (check skills/ directory first)
- Pattern is trivial or one-off use
- Better suited as agent documentation
- Content belongs in README or project docs

---

## Critical Decision: Do You Need a Skill?

Before creating, validate the need:

### ✅ Create a Skill When:
- **Reusable patterns**: Used across multiple files/components
- **Framework-specific**: Technology requires specific patterns (React, Next.js, tRPC)
- **Complex workflows**: Multi-step processes need guidance
- **Domain expertise**: Security, accessibility, performance best practices
- **Decision frameworks**: Architectural choices with tradeoffs

### ❌ Don't Create a Skill When:
- **Already exists**: Check `skills/` directory first
- **One-off task**: Only used once, no reuse value
- **Trivial pattern**: Self-explanatory or widely known
- **Project-specific**: Belongs in project docs, not toolkit
- **Better as agent**: Workflow belongs in agent, not skill

---

## Skill Creation Workflow

### Phase 1: Requirements Gathering

**Ask yourself**:
1. What technology/domain does this skill cover?
2. What specific patterns or practices should be documented?
3. Who will use this skill? (developers, AI agents, both?)
4. What's the scope? (narrow focus vs broad overview)

**Determine category**:
- `stack/` - Framework or library specific (React, Django, Docker)
- `domain/` - Cross-cutting concerns (security, testing, performance)
- `meta/` - Toolkit workflows (skill creation, context monitoring)

**Choose name**:
- Generic: `{technology}` (typescript, prisma, docker)
- Domain: `{concern}` (security, performance, accessibility)
- Workflow: `{action}-{target}` (database-migrations, api-design)

### Phase 2: Structure Creation

**Directory structure**:
```
skills/{category}/{skill-name}/
├── SKILL.md (required)
├── references/ (optional - detailed guides)
│   ├── advanced-patterns.md
│   └── best-practices.md
└── assets/ (optional - templates, schemas)
    └── template.example
```

**Create directory**:
```bash
mkdir -p skills/{category}/{skill-name}
```

### Phase 3: YAML Frontmatter

**Required fields**:
```yaml
---
name: skill-name
description: >
  Brief description of what this skill covers (1-2 sentences).
  Trigger: When [condition 1], when [condition 2], when [condition 3].
tags: [tag1, tag2, tag3, tag4]
author: dsmj-ai-toolkit
metadata:
  version: "1.0"
  last_updated: "YYYY-MM-DD"
  category: stack|domain|meta
  auto_invoke: "When working with [technology]"
  stack_category: frontend|backend|database|devops|meta
  progressive_disclosure: true
references:
  - name: Reference Name
    url: ./references/file.md
    type: local
---
```

**Validation checklist**:
- [ ] Name is lowercase, hyphen-separated
- [ ] Description includes "Trigger:" clause with 3+ conditions
- [ ] Tags are relevant and specific (5-10 tags)
- [ ] Category matches directory path
- [ ] Last updated is current date
- [ ] References use local paths only

### Phase 4: Content Sections

**Required sections** (in order):

#### 1. Title & Tagline
```markdown
# Skill Name - One-Line Purpose

**Brief tagline describing what this skill provides**
```

#### 2. When to Use This Skill
```markdown
## When to Use This Skill

**Use this skill when**:
- Specific scenario 1
- Specific scenario 2
- Specific scenario 3

**Don't use this skill when**:
- Alternative scenario 1
- Alternative scenario 2
```

#### 3. Critical Patterns
```markdown
## Critical Patterns

### Pattern 1: Name

**When**: When to use this pattern

**Example**:
\`\`\`language
// Good example
\`\`\`

**Why**: Explanation of benefits

**Avoid**:
\`\`\`language
// Bad example
\`\`\`

**Why avoid**: Explanation of problems
```

**Minimum**: 3 critical patterns
**Format**: Good vs Bad examples with explanations

#### 4. Code Examples
```markdown
## Code Examples

### Example 1: Common Use Case

\`\`\`language
// Complete, working example
\`\`\`

**Explanation**: What this does and why
```

**Minimum**: 3 complete examples
**Quality**: Must be copy-paste ready

#### 5. Anti-Patterns
```markdown
## Anti-Patterns

### ❌ Anti-Pattern 1: Name

**Don't do this**:
\`\`\`language
// Bad code
\`\`\`

**Why it's bad**: Explanation

**Do this instead**:
\`\`\`language
// Good code
\`\`\`
```

**Minimum**: 3 anti-patterns

#### 6. Quick Reference
```markdown
## Quick Reference

| Pattern | Use Case | Example |
|---------|----------|---------|
| Pattern 1 | When to use | `code snippet` |
| Pattern 2 | When to use | `code snippet` |
```

#### 7. Resources
```markdown
## Resources

**Official Documentation**:
- [Doc Name](https://official-docs-url.com)

**Related Skills**:
- **skill-name**: When you need related functionality

**References** (if using progressive disclosure):
- [Advanced Patterns](./references/advanced-patterns.md)
- [Best Practices](./references/best-practices.md)
```

### Phase 5: Validation

**Before finalizing, check**:

✅ **Frontmatter**:
- [ ] Valid YAML with all required fields
- [ ] "Trigger:" clause with 3+ conditions
- [ ] Correct category for directory path
- [ ] Current last_updated date

✅ **Content**:
- [ ] All required sections present
- [ ] 3+ critical patterns (good vs bad)
- [ ] 3+ code examples (working, copy-paste ready)
- [ ] 3+ anti-patterns with explanations
- [ ] Quick reference table
- [ ] Resources section with relevant links

✅ **Quality**:
- [ ] Code examples compile/work
- [ ] Explanations are clear and concise
- [ ] No generic placeholders
- [ ] Examples show real-world use cases
- [ ] Follows project conventions

✅ **Scope**:
- [ ] Focused on one technology/domain
- [ ] Not overlapping with existing skills
- [ ] 100-500 lines (concise, not encyclopedic)
- [ ] Uses progressive disclosure for details

### Phase 6: Testing

**Test the skill**:
1. Reference it in a sample agent
2. Verify trigger conditions work
3. Ensure examples are accurate
4. Check references link correctly

**Validation command**:
```bash
# Check YAML frontmatter
head -n 30 skills/{category}/{skill-name}/SKILL.md

# Validate required sections
grep -E "^## (When to Use|Critical Patterns|Code Examples|Anti-Patterns|Quick Reference|Resources)" skills/{category}/{skill-name}/SKILL.md
```

### Phase 7: Registration

**Update catalog** (if exists):
```markdown
# skills/CATALOG.md

## Stack Skills

### {skill-name}
**Path**: `skills/stack/{skill-name}/SKILL.md`
**Description**: Brief description
**Tags**: tag1, tag2, tag3
```

**Commit**:
```bash
git add skills/{category}/{skill-name}
git commit -m "feat(skills): add {skill-name} skill

- Added {skill-name} skill for {technology/domain}
- Includes critical patterns and anti-patterns
- Provides code examples and quick reference
"
```

---

## Code Examples

### Example 1: Creating Stack Skill (React)

**Input**: "I need to create a skill for React Server Components"

**Workflow**:
```
1. Validate need: ✅ New React 19 patterns need documentation
2. Category: stack (framework-specific)
3. Name: react-server-components
4. Directory: skills/stack/react-server-components/

5. Frontmatter:
---
name: react-server-components
description: >
  React Server Components patterns for Next.js 15+ applications.
  Trigger: When using server components, when building RSC apps,
  when optimizing React server rendering.
tags: [react, server-components, nextjs, rsc, streaming]
author: dsmj-ai-toolkit
metadata:
  version: "1.0"
  last_updated: "2026-01-17"
  category: stack
  auto_invoke: "When working with React Server Components"
  stack_category: frontend
  progressive_disclosure: true
---

6. Content sections (3+ patterns, 3+ examples, 3+ anti-patterns)
7. Validate checklist
8. Test with code-writer agent
9. Register in CATALOG.md
10. Commit with conventional format
```

### Example 2: Creating Domain Skill (Caching)

**Input**: "Create a skill for caching strategies"

**Workflow**:
```
1. Validate need: ✅ Caching is cross-cutting, complex
2. Category: domain (applies across stack)
3. Name: caching-strategies
4. Directory: skills/domain/caching-strategies/

5. Frontmatter with domain category
6. Patterns: Cache invalidation, TTL strategies, cache-aside, write-through
7. Examples: Redis, in-memory, HTTP cache headers
8. Anti-patterns: Cache stampede, stale data, over-caching
9. Quick reference with strategy comparison table
10. Register and commit
```

### Example 3: Creating Meta Skill (This One!)

**Input**: "Create a skill for skill creation"

**Workflow**:
```
1. Validate need: ✅ Need standardized skill creation process
2. Category: meta (toolkit workflow)
3. Name: skill-creator
4. Directory: skills/meta/skill-creator/

5. Content: Interactive workflow guide
6. Patterns: Decision frameworks, validation checklists
7. Examples: Stack skill, domain skill, meta skill creation
8. Quick reference: Frontmatter template, section checklist
9. Self-validates using its own checklist
10. Register and commit
```

---

## Anti-Patterns

### ❌ Anti-Pattern 1: Creating Without Validation

**Don't do this**:
```
User: "Create a skill for authentication"
Agent: *immediately creates skill without checking*
```

**Why it's bad**: May duplicate existing security skill, wrong category

**Do this instead**:
```
1. Check: grep -r "authentication" skills/
2. Found: skills/domain/security/SKILL.md covers auth
3. Response: "Authentication patterns are in security skill. Want to enhance it?"
```

### ❌ Anti-Pattern 2: Generic, Vague Content

**Don't do this**:
```markdown
## Critical Patterns

Use the framework correctly. Follow best practices.
```

**Why it's bad**: No actionable guidance, no examples

**Do this instead**:
```markdown
## Critical Patterns

### Pattern 1: Component Composition

**When**: Building reusable UI components

**Example**:
\`\`\`tsx
// Good: Composition over inheritance
<Card>
  <CardHeader>Title</CardHeader>
  <CardContent>Content</CardContent>
</Card>
\`\`\`

**Why**: Flexible, composable, testable
```

### ❌ Anti-Pattern 3: Encyclopedic Content

**Don't do this**:
- 2000+ line skill file
- Covers every possible scenario
- Duplicate official docs

**Why it's bad**: AI can't load entire content, slow, unmaintainable

**Do this instead**:
- 100-500 lines main content
- Progressive disclosure for details
- Link to official docs for comprehensive coverage

### ❌ Anti-Pattern 4: Missing Trigger Conditions

**Don't do this**:
```yaml
description: TypeScript skill for type safety
```

**Why it's bad**: AI doesn't know when to invoke

**Do this instead**:
```yaml
description: >
  TypeScript patterns for type-safe development.
  Trigger: When writing TypeScript, when defining types,
  when fixing type errors, when using generics.
```

### ❌ Anti-Pattern 5: No Code Examples

**Don't do this**:
```markdown
## Critical Patterns

Use async/await for asynchronous operations.
Use proper error handling.
```

**Why it's bad**: No actionable examples to follow

**Do this instead**:
```markdown
## Critical Patterns

### Async/Await with Error Handling

**Good**:
\`\`\`typescript
try {
  const data = await fetchUser(id);
  return data;
} catch (error) {
  if (error instanceof NotFoundError) {
    return null;
  }
  throw error;
}
\`\`\`

**Bad**:
\`\`\`typescript
const data = await fetchUser(id); // Unhandled errors
return data;
\`\`\`
```

---

## Quick Reference

### Frontmatter Template

```yaml
---
name: skill-name
description: >
  Brief description.
  Trigger: When [cond1], when [cond2], when [cond3].
tags: [tag1, tag2, tag3]
author: dsmj-ai-toolkit
metadata:
  version: "1.0"
  last_updated: "YYYY-MM-DD"
  category: stack|domain|meta
  auto_invoke: "When working with X"
  stack_category: frontend|backend|database|devops|meta
  progressive_disclosure: true
---
```

### Section Checklist

| Section | Required | Min Count | Format |
|---------|----------|-----------|--------|
| Title & Tagline | ✅ | 1 | # + ** |
| When to Use | ✅ | 1 | Use when / Don't use when |
| Critical Patterns | ✅ | 3+ | Good vs Bad examples |
| Code Examples | ✅ | 3+ | Working code blocks |
| Anti-Patterns | ✅ | 3+ | ❌ with explanations |
| Quick Reference | ✅ | 1 | Table format |
| Resources | ✅ | 1 | Links + related skills |

### Category Decision Tree

```
Is it framework/library specific?
├─ Yes → stack/
│   ├─ Frontend framework? → stack/{name}/
│   ├─ Backend framework? → stack/{name}/
│   ├─ Database/ORM? → stack/{name}/
│   └─ DevOps tool? → stack/{name}/
│
└─ No → Is it cross-cutting concern?
    ├─ Yes → domain/
    │   ├─ Security/Auth? → domain/security/
    │   ├─ Performance? → domain/performance/
    │   ├─ Testing? → domain/testing-frameworks/
    │   └─ Other domain? → domain/{name}/
    │
    └─ No → Is it toolkit workflow?
        └─ Yes → meta/
            ├─ Skill creation? → meta/skill-creator/
            ├─ Context mgmt? → meta/context-monitor/
            └─ Other meta? → meta/{name}/
```

---

## Resources

**Official Documentation**:
- [Claude Code Agent Skills](https://code.claude.com/docs/en/agent-skills)
- [Conventional Commits](https://www.conventionalcommits.org/)

**Related Skills**:
- **context-monitor**: When managing skill loading and context usage
- **patterns**: When documenting design patterns

**Toolkit Resources**:
- [Skill Template](../../TEMPLATE.md) - Complete skill template
- [Skill Guide](../../GUIDE.md) - Comprehensive skill creation guide
- [Contributing Guide](../../../CONTRIBUTING.md) - Contribution requirements

**Inspiration**:
- [Gentleman-Skills](https://github.com/Gentleman-Programming/Gentleman-Skills) - Skill best practices

---

## Remember

Creating a skill is about **teaching AI the patterns it needs**:
- ✅ Focus on what AI MUST know (critical patterns)
- ✅ Provide copy-paste examples (working code)
- ✅ Show good vs bad (anti-patterns)
- ✅ Keep it concise (100-500 lines)
- ✅ Validate thoroughly (use checklist)

**"A skill is not documentation. It's actionable guidance."**
