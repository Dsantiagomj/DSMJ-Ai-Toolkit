# Skill Creation Guide

**Complete guide to creating effective Claude Agent Skills for dsmj-ai-toolkit**

---

## Table of Contents

1. [Quick Start](#quick-start)
2. [YAML Frontmatter](#yaml-frontmatter)
3. [Skill Structure](#skill-structure)
4. [Progressive Disclosure](#progressive-disclosure)
5. [Best Practices](#best-practices)
6. [Content Guidelines](#content-guidelines)
7. [Skill Categories](#skill-categories)
8. [Quality Standards](#quality-standards)
9. [Common Pitfalls](#common-pitfalls)
10. [Examples](#examples)

---

## Quick Start

### 1. Copy the Template

```bash
cp skills/TEMPLATE.md skills/category/your-skill/SKILL.md
```

### 2. Fill in YAML Frontmatter

```yaml
---
name: your-skill
description: What it does and when to use it
tags: [typescript, react, frontend]
---
```

### 3. Add Domain Knowledge

- Core concepts
- Patterns and best practices
- Common scenarios
- Anti-patterns

### 4. Test

Start Claude Code and verify skill loads correctly.

---

## YAML Frontmatter

### Required Fields

#### `name` (required)

**Rules**:
- Maximum 64 characters
- Lowercase letters, numbers, hyphens only
- No XML tags, no reserved words
- Use kebab-case: `react-19`, not `React 19`
- Gerund form recommended: `testing-patterns`, `api-designing`

**Best practices**:
- Descriptive: `typescript-patterns` not `ts`
- Version-specific if relevant: `react-19`, `nextjs-15`
- Domain-clear: `security`, `accessibility`

**Examples**:
```yaml
✅ name: react-19
✅ name: testing-patterns
✅ name: api-design

❌ name: React-19 (uppercase)
❌ name: react_19 (underscore)
❌ name: r19 (not descriptive)
```

#### `description` (required)

**Rules**:
- Maximum 1024 characters
- Non-empty
- No XML tags
- **This is the PRIMARY triggering mechanism**

**Best practices**:
- Include BOTH what the skill provides AND when to use it
- Be specific about domains covered
- Front-load important information
- Include version if version-specific

**Examples**:
```yaml
✅ description: React 19 patterns with Server Components, Actions, and modern hooks. Use when writing React components, JSX files, or working with React-specific features.

✅ description: OWASP Top 10 security best practices, auth patterns, and secure coding guidelines. Use when implementing authentication, handling user input, or dealing with sensitive data.

❌ description: React stuff (too vague)
❌ description: Security (missing when to use)
```

### Optional Fields

#### `tags`

**Purpose**: Categorize the skill for discovery

**Format**: Array of lowercase strings

**Examples**:
```yaml
tags: [react, frontend, javascript, typescript, ui]
tags: [security, owasp, authentication, authorization]
tags: [python, django, backend, orm]
```

#### `author`

**Purpose**: Attribute skill creator

**Examples**:
```yaml
author: dsmj-ai-toolkit
author: anthropic
author: your-name
```

#### `metadata`

**Purpose**: Additional information for skill behavior

**Fields**:
- `auto_invoke`: When skill should auto-trigger
- `category`: stack|domain|meta
- `progressive_disclosure`: true|false
- `version`: Skill version

**Examples**:
```yaml
metadata:
  auto_invoke: "Writing React components, JSX files, hooks, or React-specific code"
  category: stack
  progressive_disclosure: true
  version: 1.0.0
```

### Complete Frontmatter Examples

**Stack Skill** (React):
```yaml
---
name: react-19
version: 19.0.0
description: React 19 patterns with Server Components, Actions, and modern hooks. Use when writing React components, JSX files, or working with React-specific features.
tags: [react, frontend, javascript, typescript, ui, components]
author: dsmj-ai-toolkit
metadata:
  auto_invoke: "Writing React components, JSX files, hooks, or React-specific code"
  stack_category: frontend
  progressive_disclosure: true
---
```

**Domain Skill** (Security):
```yaml
---
name: security
version: 1.0.0
description: OWASP Top 10 security best practices, auth patterns, and secure coding. Use when implementing authentication, handling user input, or dealing with sensitive data.
tags: [security, owasp, authentication, authorization, validation]
author: dsmj-ai-toolkit
metadata:
  auto_invoke: "Implementing auth, handling user input, or working with sensitive data"
  category: domain
  progressive_disclosure: true
---
```

**Meta Skill** (Context Monitor):
```yaml
---
name: context-monitor
description: Detects conversation drift and suggests refocusing. Use when conversation exceeds 50 messages or multiple topics are mixed.
tags: [meta, monitoring, workflow]
author: dsmj-ai-toolkit
metadata:
  category: meta
  progressive_disclosure: false
---
```

---

## Skill Structure

### Core Sections (Required)

Every skill must have:

#### 1. Title & Tagline
```markdown
# Skill Name - One-Line Purpose

**Brief tagline describing domain knowledge**
```

#### 2. Overview
```markdown
## Overview

**What this skill provides**: [Brief description]
**When to use**: [Specific scenarios]
**Key concepts**: [Core knowledge areas]
```

#### 3. Core Concepts
```markdown
## Core Concepts

### Concept 1: [Name]
**What it is**: Explanation
**Best practices**: Do's and don'ts
**Example**: Code demonstrating concept
```

Typically 3-5 core concepts.

#### 4. Patterns & Best Practices
```markdown
## Patterns & Best Practices

### Pattern 1: [Pattern Name]
**Use when**: Scenario
**Implementation**: Working code example
**Why this works**: Explanation
```

Actionable patterns with code examples.

#### 5. Common Scenarios
```markdown
## Common Scenarios

### Scenario 1: [Description]
**Problem**: What user is trying to accomplish
**Solution**: Step-by-step code example
**Explanation**: Why this approach
```

Real-world use cases.

#### 6. Quick Reference
```markdown
## Quick Reference

| Operation | Code Pattern | Notes |
|-----------|-------------|-------|
| Common task | `code` | When to use |
```

Cheat sheet for quick lookup.

### Optional Sections

Add these if relevant:

- **Anti-Patterns**: What NOT to do (highly recommended)
- **Edge Cases & Gotchas**: Tricky scenarios
- **Version Information**: What versions skill covers
- **Progressive Disclosure**: Links to detailed references
- **Resources**: Official docs, community resources

---

## Progressive Disclosure

### Core Principle

**Keep SKILL.md under 500 lines**. If longer, use progressive disclosure.

### Structure

```
skill-name/
├── SKILL.md                  # Main content (~400 lines, 80% use cases)
└── references/               # Detailed docs (loaded as needed)
    ├── advanced-patterns.md  # Complex scenarios
    ├── api-reference.md      # Complete API docs
    ├── migrations.md         # Version upgrades
    └── examples/             # Working code examples
```

### In SKILL.md

```markdown
## Progressive Disclosure

> **Note**: This skill uses progressive disclosure. Main content covers 80% of use cases.

**For detailed information, see**:
- `references/advanced-patterns.md` - Complex scenarios
- `references/api-reference.md` - Complete API docs
- `references/migrations.md` - Version upgrade guides

**Load these only when**:
- Facing complex scenario not covered here
- Need complete API documentation
- Migrating between versions
```

### How It Works

1. **Metadata pre-loaded**: Frontmatter (name, description) always loaded (~100 tokens)
2. **Main content on-demand**: SKILL.md loaded when skill triggered (~5k tokens)
3. **References as needed**: Claude reads reference files only when mentioned

**Example flow**:
```
User: "Implement React Server Components"
→ Claude loads react-19/SKILL.md (main patterns)
→ User: "How to handle streaming?"
→ Claude loads react-19/references/server-components.md (detailed)
```

---

## Best Practices

### 1. Single Domain Focus

Each skill covers ONE domain.

**Good**:
- `react-19`: React-specific patterns
- `security`: Security best practices
- `accessibility`: WCAG compliance

**Bad**:
- `frontend`: Too broad (React + Vue + Angular)
- `web-dev`: Too vague (frontend + backend)

### 2. Pattern-Based, Not Tutorial

Skills provide **reference patterns**, not step-by-step tutorials.

**Good**:
```markdown
### Server Component Data Fetching

**Use when**: Fetching data in React Server Components

**Pattern**:
```tsx
async function PostList() {
  const posts = await db.post.findMany();
  return <div>{posts.map(post => <Post key={post.id} post={post} />)}</div>;
}
```

**Why**: Server Components can async/await directly
```

**Bad**:
```markdown
### Tutorial: Building Your First Server Component

Step 1: Create a new file...
Step 2: Import React...
Step 3: ...
```
(Too tutorial-like, not pattern reference)

### 3. Code-Heavy with Context

Show code first, explain after.

**Good**:
```markdown
### Form Validation

```tsx
const schema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
});

const validated = schema.parse(formData);
```

**Why Zod**: Type-safe, runtime validation, TypeScript inference
```

**Bad**:
```markdown
### Form Validation

You should use validation libraries. Zod is a good choice because it provides type safety and runtime validation. Here's how to use it...
```
(Too much preamble, not enough code)

### 4. Version-Specific

Specify versions when patterns differ between versions.

**Good**:
```markdown
### Server Actions (React 19+)

```tsx
'use server';

export async function createPost(formData: FormData) {
  // Server-side logic
}
```

**Note**: Server Actions are React 19+ feature
```

**Bad**:
```markdown
### Server Actions

[No version mentioned]
```

### 5. Anti-Patterns Section

Always include what NOT to do.

**Good**:
```markdown
## Anti-Patterns

### Don't Use useEffect for Data Fetching

❌ **Don't do this**:
```tsx
function Posts() {
  const [posts, setPosts] = useState([]);

  useEffect(() => {
    fetch('/api/posts').then(r => r.json()).then(setPosts);
  }, []);
}
```

✅ **Do this instead** (Server Component):
```tsx
async function Posts() {
  const posts = await fetch('/api/posts').then(r => r.json());
  return <PostList posts={posts} />;
}
```
```

### 6. Real Examples

Use realistic, production-ready examples.

**Good**:
```tsx
// Real-world authentication check
async function ProtectedPage() {
  const session = await getSession();

  if (!session) {
    redirect('/login');
  }

  return <DashboardContent user={session.user} />;
}
```

**Bad**:
```tsx
// Contrived example
function Example() {
  console.log('hello');
}
```

### 7. Quick Reference Table

Include cheat sheet for common operations.

**Example**:
```markdown
## Quick Reference

| Operation | Pattern | When to Use |
|-----------|---------|------------|
| Fetch data | `await db.query()` | Server Components |
| Handle form | `<form action={serverAction}>` | React 19 forms |
| Validate input | `schema.parse(data)` | User input |
```

### 8. Current Information

Keep skills current (2024-2026 best practices).

**Include**:
- Version numbers
- "Last Updated" date
- "Deprecated" warnings for old patterns

**Example**:
```markdown
## Version Information

**Current Version**: React 19.0
**Last Updated**: 2026-01-15
**Compatible With**: Next.js 15+

### Deprecated Patterns

❌ **getServerSideProps** (Pages Router) - Use Server Components instead
❌ **useEffect for data fetching** - Use Server Components or React Query
```

### 9. Security Awareness

Flag security concerns prominently.

**Example**:
```markdown
### User Input Handling

⚠️ **Security**: ALWAYS validate user input

```tsx
// Validate before database query
const validated = userSchema.parse(req.body);
await db.user.create({ data: validated });
```

**Why**: Prevents SQL injection, XSS, and malformed data
```

### 10. Cross-Skill References

Reference other skills when relevant.

**Example**:
```markdown
### Form Validation

[Implementation example]

**See also**:
- `security` skill - Input validation patterns
- `typescript` skill - Type-safe form schemas
```

---

## Content Guidelines

### What to Include

✅ **Core concepts**: Fundamental knowledge
✅ **Patterns**: Reusable code patterns
✅ **Best practices**: Recommended approaches
✅ **Anti-patterns**: What to avoid
✅ **Common scenarios**: Real-world use cases
✅ **Examples**: Working code
✅ **Quick reference**: Cheat sheet

### What to Exclude

❌ **Step-by-step tutorials**: Skills are references, not courses
❌ **Complete API docs**: Use progressive disclosure
❌ **Framework installation**: Assume environment is set up
❌ **Verbose explanations**: Show code first, explain concisely
❌ **Outdated patterns**: Keep current (2024-2026)

### Length Guidelines

- **SKILL.md**: 300-500 lines (main content)
- **Maximum**: 500 lines before splitting
- **If longer**: Use progressive disclosure with references/

### Code Examples

**Every pattern needs**:
- Complete working example (not pseudocode)
- Imports if necessary
- Type annotations (if TypeScript)
- Comments for clarity (not excessive)

**Good example**:
```tsx
import { z } from 'zod';

const userSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
});

// Validate form data
const validated = userSchema.parse(formData);
```

**Bad example**:
```tsx
// Validate somehow
validateData(data);
```
(Too vague, not actionable)

---

## Skill Categories

### Stack Skills (`skills/stack/`)

Technology-specific patterns for frameworks and languages.

**Examples**:
- `react-19/` - React 19 patterns
- `nextjs-15/` - Next.js 15 App Router
- `python-312/` - Python 3.12 best practices
- `typescript/` - TypeScript patterns
- `vue-3/` - Vue 3 Composition API
- `django-5/` - Django 5 ORM and views

**Characteristics**:
- Version-specific (include version in name)
- Framework/language patterns
- Auto-invoke when working with that stack
- Progressive disclosure common (large API surfaces)

**Metadata**:
```yaml
metadata:
  category: stack
  auto_invoke: "Writing [framework] code"
  progressive_disclosure: true
```

### Domain Skills (`skills/domain/`)

Cross-technology domain knowledge.

**Examples**:
- `security/` - OWASP Top 10, auth patterns
- `accessibility/` - WCAG compliance, ARIA
- `i18n/` - Internationalization patterns
- `testing-frameworks/` - Test patterns (Jest, Pytest)
- `api-design/` - RESTful/GraphQL patterns
- `performance/` - Optimization techniques

**Characteristics**:
- Technology-agnostic (applies across stacks)
- Domain expertise
- Cross-cutting concerns
- Referenced by multiple agents

**Metadata**:
```yaml
metadata:
  category: domain
  auto_invoke: "Handling [domain concern]"
```

### Meta Skills (`skills/meta/`)

Workflow and process guidance.

**Examples**:
- `context-monitor/` - Drift detection
- `debugging-strategies/` - Debugging approaches
- `code-review-checklist/` - Review guidelines

**Characteristics**:
- Not code-specific
- Process and workflow
- Usually shorter (<300 lines)
- No progressive disclosure needed

**Metadata**:
```yaml
metadata:
  category: meta
  progressive_disclosure: false
```

---

## Quality Standards

### Validation Checklist

Before finalizing skill:

✅ **YAML Frontmatter**:
- name: Valid format (kebab-case, <64 chars)
- description: Clear triggers + capabilities (<1024 chars)
- tags: Relevant categories
- metadata: auto_invoke specified

✅ **Structure**:
- Title & tagline
- Overview section
- Core Concepts (3-5)
- Patterns & Best Practices
- Common Scenarios
- Quick Reference table

✅ **Content**:
- All patterns have working code examples
- Anti-patterns section included
- Version information specified
- Cross-skill references where relevant

✅ **Length**:
- SKILL.md under 500 lines
- If longer, uses progressive disclosure
- references/ directory if needed

✅ **Quality**:
- Current best practices (2024-2026)
- Production-ready examples
- Security concerns flagged
- No outdated patterns

---

## Common Pitfalls

### ❌ Pitfall 1: Too Broad

**Bad**:
```yaml
name: web-development
description: Everything about web dev
```

**Good**:
```yaml
name: react-19
description: React 19 patterns with Server Components and modern hooks
```

**Fix**: Focus on single domain

### ❌ Pitfall 2: Tutorial Instead of Reference

**Bad**:
```markdown
## Tutorial: Your First Component

Step 1: Open your editor
Step 2: Create a file
Step 3: Type this code...
```

**Good**:
```markdown
## Server Component Pattern

```tsx
async function PostList() {
  const posts = await db.post.findMany();
  return <PostList posts={posts} />;
}
```

**Use when**: Fetching data in Server Components
```

**Fix**: Show patterns, not step-by-step

### ❌ Pitfall 3: No Code Examples

**Bad**:
```markdown
## Data Fetching

You should fetch data in Server Components. This is better for performance.
```

**Good**:
```markdown
## Data Fetching

```tsx
async function Posts() {
  const posts = await db.post.findMany();
  return <div>{posts.map(p => <Post key={p.id} post={p} />)}</div>;
}
```

**Why**: Server Components eliminate client-side fetching overhead
```

**Fix**: Always include working code

### ❌ Pitfall 4: Vague Description

**Bad**:
```yaml
description: React patterns
```

**Good**:
```yaml
description: React 19 patterns with Server Components, Actions, and modern hooks. Use when writing React components, JSX files, or working with React-specific features.
```

**Fix**: Specify what AND when

### ❌ Pitfall 5: Outdated Information

**Bad**:
```markdown
### Class Components (Best Practice)

class MyComponent extends React.Component {
  // ...
}
```

**Good**:
```markdown
### Functional Components (Current Best Practice)

```tsx
function MyComponent() {
  // Function components with hooks (React 16.8+)
}
```

❌ **Deprecated**: Class components (use function components)
```

**Fix**: Keep current, mark deprecated patterns

### ❌ Pitfall 6: Missing Anti-Patterns

**Bad**:
```markdown
[Only shows good patterns]
```

**Good**:
```markdown
## Anti-Patterns

❌ **Don't use useEffect for data fetching**
✅ **Use Server Components instead**
```

**Fix**: Always include anti-patterns section

### ❌ Pitfall 7: No Version Information

**Bad**:
```markdown
### Server Components

[No version mentioned]
```

**Good**:
```markdown
### Server Components (React 19+)

**Version**: React 19.0+
**Last Updated**: 2026-01-15
```

**Fix**: Specify versions

---

## Examples

See `skills/examples/` directory for complete skill examples:

- `examples/stack-skill.md` - Stack skill pattern (React-like)
- `examples/domain-skill.md` - Domain skill pattern (Security-like)
- `examples/meta-skill.md` - Meta skill pattern (Workflow)
- `examples/minimal-skill.md` - Simplest possible skill

---

## Testing Your Skill

### 1. Validate Structure

```bash
# Check YAML frontmatter
head -n 10 skills/your-category/your-skill/SKILL.md

# Verify required fields
grep "^name:" skills/your-category/your-skill/SKILL.md
grep "^description:" skills/your-category/your-skill/SKILL.md
```

### 2. Test in Claude Code

```bash
# Start Claude Code
claude-code

# Verify skill loads
# (Check that description shows in skill list)
```

### 3. Test Auto-Invoke

Create scenario that should trigger skill:
```
# For react-19 skill
You: "Create a Server Component that fetches posts"

# Should reference react-19 skill automatically
```

### 4. Test Progressive Disclosure

```
You: "How to handle streaming in Server Components?"

# Should read references/server-components.md if main content references it
```

---

## Checklist for Production-Ready Skill

**YAML Frontmatter**:
- [ ] name: Valid kebab-case, <64 chars
- [ ] description: Clear triggers + capabilities, <1024 chars
- [ ] tags: Relevant categories
- [ ] metadata: auto_invoke specified if applicable

**Structure**:
- [ ] Title & tagline
- [ ] Overview section
- [ ] Core Concepts (3-5)
- [ ] Patterns & Best Practices
- [ ] Common Scenarios
- [ ] Anti-Patterns section
- [ ] Quick Reference table

**Content Quality**:
- [ ] All patterns have working code examples
- [ ] Examples are production-ready (not contrived)
- [ ] Version information specified
- [ ] Current best practices (2024-2026)
- [ ] Security concerns flagged
- [ ] Under 500 lines (or uses progressive disclosure)

**Testing**:
- [ ] Tested in Claude Code
- [ ] Auto-invoke works (if applicable)
- [ ] Examples are copy-paste ready
- [ ] Cross-skill references work

**Documentation**:
- [ ] Clear when to use vs other skills
- [ ] Progressive disclosure documented (if used)
- [ ] Resources linked (official docs)

---

## Resources

**Official Documentation**:
- [Agent Skills Overview](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview)
- [Skill Authoring Best Practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices)
- [How to Create Custom Skills](https://support.claude.com/en/articles/12512198-how-to-create-custom-skills)
- [Claude Code Skills Docs](https://code.claude.com/docs/en/skills)

**Toolkit Resources**:
- `skills/TEMPLATE.md` - Template to copy
- `skills/examples/` - Complete working examples
- `../docs/ARCHITECTURE.md` - How skills fit in toolkit

**Official Examples**:
- [Anthropic Skills Repository](https://github.com/anthropics/skills)
- [Agent Skills Standard](https://agentskills.io)

---

**Questions?** Open an issue at https://github.com/dsantiagomj/dsmj-ai-toolkit/issues

---

**Version**: 1.0
**Last Updated**: 2026-01-15
