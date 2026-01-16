# Agent Creation Guide

**Complete guide to creating effective Claude Code subagents for dsmj-ai-toolkit**

---

## Table of Contents

1. [Quick Start](#quick-start)
2. [YAML Frontmatter](#yaml-frontmatter)
3. [Agent Structure](#agent-structure)
4. [Tool Permissions](#tool-permissions)
5. [Best Practices](#best-practices)
6. [Skill Integration](#skill-integration)
7. [Communication Patterns](#communication-patterns)
8. [Quality Standards](#quality-standards)
9. [Common Pitfalls](#common-pitfalls)
10. [Examples](#examples)

---

## Quick Start

### 1. Copy the Template

```bash
cp agents/TEMPLATE.md agents/your-agent.md
```

### 2. Fill in YAML Frontmatter

```yaml
---
name: your-agent
description: When to invoke and what it does
tools: [Read, Write, Edit]
model: sonnet
---
```

### 3. Define Core Identity

- Purpose (one sentence)
- Best use cases
- Workflow phases

### 4. Test

```bash
# Symlink to test project
ln -s ~/.dsmj-ai-toolkit/agents/your-agent.md ~/test-project/.claude/agents/

# Start Claude Code and test invocation
claude-code
```

---

## YAML Frontmatter

### Required Fields

#### `name` (required)
**Rules**:
- Maximum 64 characters
- Lowercase letters, numbers, hyphens only
- No XML tags
- No reserved words
- Use kebab-case: `code-writer`, not `Code Writer`

**Best practices**:
- Descriptive: `qa` not `q`
- Role-based: `code-reviewer` not `reviewer1`
- Consistent: Follow existing naming patterns

**Examples**:
```yaml
✅ name: code-writer
✅ name: git-docs
✅ name: qa

❌ name: Code-Writer (uppercase)
❌ name: code_writer (underscore)
❌ name: wr (not descriptive)
```

#### `description` (required)
**Rules**:
- Maximum 1024 characters
- Non-empty
- No XML tags
- This is the PRIMARY triggering mechanism

**Best practices**:
- Include BOTH what the agent does AND when to use it
- Be specific: "Reviews code for security vulnerabilities and runs automated tests" not "Reviews code"
- Include triggers: "Use when analyzing code quality, checking OWASP compliance, or running test suites"
- Front-load important info (first 100 chars most impactful)

**Examples**:
```yaml
✅ description: Quality assurance specialist. Reviews code quality, runs automated tests (unit, integration, e2e), checks OWASP security vulnerabilities, and validates patterns. Use when code needs quality review, security audit, or test verification.

✅ description: Git workflow and documentation specialist. Handles commits with conventional commit format, creates PRs, updates documentation (README, API docs), and maintains CHANGELOG. Use when code is ready to commit or documentation needs updating.

❌ description: Reviews code (too vague, no triggers)
❌ description: Does stuff with git (unprofessional, unclear)
```

### Optional Fields

#### `tools`
**Purpose**: Restricts which tools the agent can use (allowlist)

**Default**: If omitted, inherits all tools from main conversation

**Best practices**:
- **Principle of least privilege**: Only grant tools actually needed
- Review-only agents: `[Read, Grep, Glob]`
- Implementation agents: `[Read, Write, Edit, Grep, Glob, Bash]`
- Research agents: `[Read, Grep, Glob, WebFetch, WebSearch]`

**Tool categories**:
```yaml
# Read-only (reviewers, analyzers)
tools: [Read, Grep, Glob]

# Code writers (implementation)
tools: [Read, Write, Edit, Grep, Glob, Bash]

# Git workflow (commits, PRs)
tools: [Read, Bash]

# Documentation (writing docs)
tools: [Read, Write, Edit, Grep, Glob]

# Planning (read-only exploration)
tools: [Read, Grep, Glob]

# QA (testing, manual checks)
tools: [Read, Bash]

# DevOps (operations)
tools: [Read, Bash]

# Full access (iterative agents)
tools: [Read, Write, Edit, Grep, Glob, Bash, Task]
```

#### `model`
**Purpose**: Which Claude model to use

**Options**:
- `sonnet` (default, recommended for most agents)
- `opus` (most capable, expensive - use for complex planning/architecture)
- `haiku` (fastest, cheapest - use for simple tasks)
- `inherit` (use same model as main conversation)

**Best practices**:
```yaml
✅ model: sonnet    # Most agents (balanced performance/cost)
✅ model: opus      # Complex reasoning (planner, architect)
✅ model: haiku     # Simple tasks (formatters, linters)
```

#### `permissionMode`
**Purpose**: How to handle permission prompts

**Options**:
- Omit (inherits from main conversation - recommended)
- `bypassPermissions` (skips all prompts - use with extreme caution)

**Best practices**:
- **Don't use `bypassPermissions`** unless absolutely necessary
- Let agents inherit permission mode from main conversation
- If you must bypass, document WHY in agent description

#### `disallowedTools`
**Purpose**: Block specific tools (denylist approach)

**When to use**: Rare - prefer allowlist via `tools` field

**Example**:
```yaml
# Allow most tools but prevent write operations
disallowedTools: [Write, Edit]
```

### Complete Frontmatter Examples

**Read-only reviewer**:
```yaml
---
name: code-reviewer
description: Quality assurance specialist. Reviews code quality, runs automated tests (unit, integration, e2e), checks OWASP security vulnerabilities, and validates patterns. Use when code needs quality review, security audit, or test verification.
tools: [Read, Grep, Glob, Bash]
model: sonnet
---
```

**Implementation specialist**:
```yaml
---
name: code-writer
description: Implementation specialist. Writes production-quality code following project patterns, handles database migrations, creates API endpoints. Use when implementing features, fixing bugs, or refactoring code. Does NOT commit or test.
tools: [Read, Write, Edit, Grep, Glob, Bash, Task]
model: sonnet
---
```

**Planning specialist**:
```yaml
---
name: planner
description: Requirements and planning specialist. Gathers requirements, creates user stories, makes architecture decisions, evaluates technical approaches, and breaks tasks into implementation steps. Use before starting implementation to plan approach and identify risks.
tools: [Read, Grep, Glob]
model: opus
---
```

---

## Agent Structure

### Core Sections (Required)

Every agent must have these sections:

#### 1. Title & Tagline
```markdown
# Agent Name - One-Line Purpose

**Brief tagline describing core function**
```

#### 2. Core Identity
```markdown
## Core Identity

**Purpose**: Single sentence
**Best for**: List of ideal use cases
```

#### 3. Critical Rules
```markdown
## Critical Rules (Inherited from CLAUDE.md)

> ⚠️ You inherit ALL core operating rules

**Key rules for your work**:
1. **Rule Name**: How it applies to you
```

Select 3-5 most relevant from the 9 core rules.

#### 4. Your Workflow
```markdown
## Your Workflow

### Phase 1: [Step Name]
**What to do**: Actions
**Reference skills**: Which skills to use
**Output**: What this produces

### Phase 2: [Step Name]
...
```

Break work into clear phases (2-5 phases typical).

#### 5. Quality Checks
```markdown
## Quality Checks

Before completing, verify:
✅ Check 1
✅ Check 2
```

#### 6. What You Do vs Don't Do
```markdown
## What You Do vs What You Don't Do

**✅ You DO**: Your responsibilities
**❌ You DON'T**: What's outside scope
```

#### 7. Example
```markdown
## Example: [Concrete Scenario]

**User Request**: "..."

**Your Response**:
[Step-by-step walkthrough]
```

Always include at least one complete example.

### Optional Sections

Add these if relevant:

- **Special Cases**: Scenarios requiring different approach
- **Communication Style**: Professional vs Maestro mode
- **When to Stop and Ask**: Conditions requiring user input
- **Philosophy**: Guiding principle (optional)

---

## Tool Permissions

### Security-First Approach

**Principle**: Start from deny-all, allowlist only what's needed.

### Tool Categories by Risk

**Low Risk** (read-only):
- `Read`: Read files
- `Grep`: Search content
- `Glob`: Find files by pattern

**Medium Risk** (modification):
- `Write`: Create new files
- `Edit`: Modify existing files

**High Risk** (execution):
- `Bash`: Run shell commands
- `Task`: Spawn other agents

**Research** (external):
- `WebFetch`: Fetch URLs
- `WebSearch`: Search web

### Tool Assignment Matrix

| Agent Type | Tools | Rationale |
|------------|-------|-----------|
| **Reviewer** | Read, Grep, Glob, Bash* | Read code, search, run tests |
| **Writer** | Read, Write, Edit, Grep, Glob, Bash, Task | Full implementation access |
| **Planner** | Read, Grep, Glob | Explore codebase only |
| **Git** | Read, Bash | Read code, run git commands |
| **QA** | Read, Bash | Read code, run manual tests |
| **DevOps** | Read, Bash | Read configs, run ops commands |
| **Research** | Read, Grep, Glob, WebFetch, WebSearch | Read + external research |

*Bash for running tests only, not arbitrary commands

### Examples by Role

**Code Reviewer** (read + test):
```yaml
tools: [Read, Grep, Glob, Bash]
```
Needs Bash to run `npm test`, `pytest`, etc.

**Code Writer** (full implementation):
```yaml
tools: [Read, Write, Edit, Grep, Glob, Bash, Task]
```
Can spawn code-reviewer via Task for review.

**Planner** (pure analysis):
```yaml
tools: [Read, Grep, Glob]
```
No modification, just exploration.

**Documentation** (write docs):
```yaml
tools: [Read, Write, Edit, Grep, Glob]
```
No Bash needed, just file operations.

---

## Best Practices

### 1. Single Responsibility Principle

Each agent should do ONE thing well.

**Good**:
- `code-writer`: Implements code
- `code-reviewer`: Reviews code + runs tests
- `git-docs`: Git workflow + documentation

**Bad**:
- `dev-agent`: Does everything (too broad)
- `writer-reviewer-tester`: Three jobs (too many responsibilities)

### 2. Clear Boundaries

Define what agent DOES and DON'T DO.

**Example** (code-writer):
```markdown
**✅ You DO**:
- Write production-quality code
- Database migrations
- API implementations

**❌ You DON'T**:
- Commit code (that's git-docs)
- Run tests (that's code-reviewer)
- Make architecture decisions (that's planner)
```

### 3. Workflow Structure

Break work into phases (2-5 typical):

**Good structure**:
```markdown
### Phase 1: Understand Requirements
[What to do]

### Phase 2: Implement Solution
[What to do]

### Phase 3: Verify & Return
[What to do]
```

**Bad structure**:
```markdown
## Do everything
- Step 1
- Step 2
- ... (20 steps)
```

### 4. Skill References

Reference skills when needed, explain WHEN and WHY:

**Good**:
```markdown
**Reference skills**:
- **security**: When handling auth, user input, or sensitive data
- **react-19**: When creating components or using hooks
- **api-design**: When designing REST endpoints
```

**Bad**:
```markdown
**Reference skills**: security, react-19, api-design
```
(No context on when/why)

### 5. Progressive Disclosure

Keep main agent content under 500 lines. If longer, split into:
- Main agent file (core workflow)
- `references/` directory (detailed examples)

**Example**:
```
agents/code-writer.md        # 400 lines - core workflow
agents/code-writer/
  references/
    database-migrations.md   # Detailed migration guide
    api-patterns.md          # API examples
```

### 6. Quality Checks

Always include verification checklist:

```markdown
## Quality Checks

Before completing, verify:
✅ **Security**: No hardcoded secrets, input validated
✅ **Testing**: All tests passing
✅ **Patterns**: Follows project conventions
✅ **Documentation**: Code comments where needed
```

### 7. Real Examples

Include at least one complete example showing:
- User request
- Your thought process
- Step-by-step actions
- Final output

**Good example**:
```markdown
## Example: Add Email Validation

**User Request**: "Add email validation to registration"

**Your Response**:

Phase 1: Understand Requirements
→ Check existing validation patterns in codebase
→ Reference security skill for input validation

Phase 2: Implement
→ Add email regex validation
→ Add error messages
→ Update tests

Phase 3: Verify
→ Run tests: All passing
→ Check edge cases: Empty, invalid format, SQL injection

**Final Output**:
"Email validation added in auth/validation.ts:42
Tests updated in auth/validation.test.ts:78
All 12 tests passing ✅"
```

### 8. Error Handling

Define what to do when stuck:

```markdown
## When to Stop and Ask

**STOP if**:
- Requirements unclear or contradictory
- Breaking changes without user confirmation
- Security implications not understood

**ASK the user**:
- "Should this handle [edge case]?"
- "Breaking change detected - proceed?"
```

### 9. Communication Modes

Support both professional and Maestro modes:

```markdown
## Communication Style

**Professional**:
"I've implemented the authentication system. Tests passing."

**Maestro Mode**:
"Dale, auth system is listo! Tests passing, chévere!"

**Key**: Professional = default, Maestro = optional friendly style
```

### 10. Model Selection

Choose appropriate model:

- **sonnet**: Most agents (balanced)
- **opus**: Complex reasoning (planner, architect)
- **haiku**: Simple tasks (formatters, validators)

---

## Skill Integration

### When to Reference Skills

Skills provide domain knowledge. Reference them:
- **Stack skills**: When using specific technology
- **Domain skills**: When handling specialized concerns
- **Meta skills**: For workflow concerns

### How to Reference Skills

**In workflow phases**:
```markdown
### Phase 2: Implement Auth

**Reference skills**:
- **security**: For OWASP Top 10 compliance, password hashing
- **api-design**: For RESTful endpoint structure
- **testing-frameworks**: For test structure
```

**In skill references section (frontmatter-style)**:
```yaml
---
skills: [security, react-19, testing-frameworks, api-design]
---
```

### Skill Progressive Disclosure

Skills have main content + references. Tell agents:

```markdown
**Reference security skill**:
- Main content for common patterns
- Load `references/owasp-top-10.md` if needed
- Load `references/auth-patterns.md` for detailed auth examples
```

---

## Communication Patterns

### Professional Mode (Default)

**Characteristics**:
- Clear, concise, technical
- Structured output
- No emojis or slang
- Formal tone

**Example**:
```
I've reviewed the authentication implementation.

Security Analysis:
✅ Password hashing uses bcrypt with proper salt rounds
✅ JWT tokens have expiry
⚠️  CORS not configured - recommend adding to prevent XSS

Recommendation: Add CORS middleware before deployment.
```

### Maestro Mode (Optional)

**Activated by**: `/maestro` or "use maestro mode" in main conversation

**Characteristics**:
- Casual, friendly
- Spanish slangs: ojo, chévere, dale, bacano, listo
- English slangs: bet, lowkey, ngl, fr, valid
- Still technical and accurate

**Example**:
```
Dale, I checked the auth code!

Security vibes:
✅ Password hashing looking good, chévere
✅ JWT tokens expire, bet
⚠️  Ojo - no CORS configured, that's risky fr

Lowkey recommend adding CORS before we ship this, listo?
```

**CRITICAL**: Maestro changes ONLY communication style. All rules, quality gates, and technical standards still apply.

### Status Updates

Keep users informed during long tasks:

```markdown
**During work**:
"Analyzing 47 files for security vulnerabilities..."
"Found 3 issues, reviewing each..."
"All issues documented, preparing report..."

**On completion**:
"✅ Security review complete
- 3 Critical issues found (must fix)
- 5 Medium issues (recommend fixing)
- Details in review below"
```

---

## Quality Standards

### Agent Length

**Target**: 300-500 lines (main content)
**Maximum**: 500 lines before splitting

**If longer**:
- Move detailed examples to `references/`
- Keep core workflow in main file
- Use progressive disclosure

### Validation Checklist

Before finalizing agent:

✅ **YAML Frontmatter**:
- name: Valid format (kebab-case, <64 chars)
- description: Clear triggers + capabilities (<1024 chars)
- tools: Minimal necessary permissions
- model: Appropriate choice (sonnet default)

✅ **Structure**:
- Core Identity section
- Critical Rules section
- Workflow phases (2-5)
- Quality Checks section
- What You Do vs Don't Do
- At least one complete example

✅ **Content**:
- Single responsibility
- Clear boundaries
- Skill references explained
- Error handling defined
- Both communication modes shown

✅ **Practical**:
- Solves real problem
- Non-overlapping with other agents
- Works with toolkit architecture
- Testable workflow

---

## Common Pitfalls

### ❌ Pitfall 1: Too Many Responsibilities

**Bad**:
```yaml
name: dev-agent
description: Writes code, reviews it, commits, deploys
```

**Good**:
```yaml
name: code-writer
description: Implementation specialist. Writes code only.
```

**Fix**: Split into focused agents (code-writer, code-reviewer, git-docs, devops)

### ❌ Pitfall 2: Vague Description

**Bad**:
```yaml
description: Reviews code
```

**Good**:
```yaml
description: Quality specialist. Reviews code quality, runs automated tests (unit, integration, e2e), checks OWASP security vulnerabilities. Use when code needs quality review or security audit.
```

**Fix**: Add specific triggers and capabilities

### ❌ Pitfall 3: Excessive Tool Access

**Bad**:
```yaml
# Reviewer with full write access
tools: [Read, Write, Edit, Bash, Task]
```

**Good**:
```yaml
# Reviewer with read-only + test execution
tools: [Read, Grep, Glob, Bash]
```

**Fix**: Grant only necessary tools (least privilege)

### ❌ Pitfall 4: No Examples

**Bad**:
```markdown
## Workflow
Do this, then that, then verify.
```

**Good**:
```markdown
## Example: Add Authentication

**User**: "Add JWT auth"

**Your Response**:
Phase 1: Research existing patterns
Phase 2: Implement JWT routes
Phase 3: Verify with tests

[Complete walkthrough]
```

**Fix**: Always include concrete examples

### ❌ Pitfall 5: Unclear Boundaries

**Bad**:
```markdown
You write code and maybe test it sometimes.
```

**Good**:
```markdown
**✅ You DO**: Write production-quality code
**❌ You DON'T**: Run tests (code-reviewer does this)
```

**Fix**: Explicitly state what you DO and DON'T do

### ❌ Pitfall 6: No Quality Checks

**Bad**:
```markdown
## Workflow
Write code. Done.
```

**Good**:
```markdown
## Quality Checks

Before completing:
✅ Security: No hardcoded secrets
✅ Testing: All tests passing
✅ Patterns: Follows conventions
```

**Fix**: Add verification checklist

### ❌ Pitfall 7: Ignoring Core Rules

**Bad**:
```markdown
# No mention of CLAUDE.md core rules
```

**Good**:
```markdown
## Critical Rules (Inherited from CLAUDE.md)

> ⚠️ You inherit ALL core operating rules

**Key rules for your work**:
1. **Verification First**: Check before confirming
2. **User Questions**: Stop and wait, never assume
```

**Fix**: Reference inherited rules

---

## Examples

See `agents/examples/` directory for complete agent examples:

- `agents/examples/read-only-reviewer.md` - Security auditor (read-only)
- `agents/examples/code-implementer.md` - Feature builder (full access)
- `agents/examples/research-specialist.md` - Documentation researcher (read + web)
- `agents/examples/minimal-agent.md` - Simplest possible agent
- `agents/examples/advanced-agent.md` - Complex multi-phase agent

---

## Testing Your Agent

### 1. Validate Structure

```bash
# Check YAML frontmatter
head -n 10 agents/your-agent.md

# Verify required fields
grep "^name:" agents/your-agent.md
grep "^description:" agents/your-agent.md
```

### 2. Test Locally

```bash
# Symlink to test project
ln -s ~/.dsmj-ai-toolkit/agents/your-agent.md ~/test-project/.claude/agents/

# Start Claude Code
cd ~/test-project
claude-code
```

### 3. Test Invocation

In Claude Code:
```
You: "Use your-agent to [task]"
```

Verify:
- Agent spawns correctly
- Tools work as expected
- Output matches expected format
- Quality checks happen

### 4. Test Edge Cases

- Ambiguous requirements (should ask questions)
- Error conditions (should handle gracefully)
- Maestro mode (if supported)

---

## Checklist for Production-Ready Agent

Before adding agent to toolkit:

**YAML Frontmatter**:
- [ ] name: Valid kebab-case, <64 chars
- [ ] description: Clear triggers + capabilities, <1024 chars
- [ ] tools: Minimal necessary permissions listed
- [ ] model: Appropriate choice (or omitted for default)

**Structure**:
- [ ] Title & tagline
- [ ] Core Identity section
- [ ] Critical Rules (references CLAUDE.md)
- [ ] Workflow with phases
- [ ] Quality Checks section
- [ ] What You Do vs Don't Do
- [ ] At least one complete example

**Content Quality**:
- [ ] Single, clear responsibility
- [ ] Non-overlapping with other agents
- [ ] Skill references with context
- [ ] Error handling defined
- [ ] Both communication modes (if relevant)
- [ ] Under 500 lines (or split with references/)

**Testing**:
- [ ] Tested with real scenarios
- [ ] Tools work as expected
- [ ] Quality checks execute
- [ ] Edge cases handled

**Documentation**:
- [ ] Clear when to use vs other agents
- [ ] Examples are realistic
- [ ] Integrates with toolkit workflow

---

## Resources

**Official Documentation**:
- [Claude Code Subagents Docs](https://code.claude.com/docs/en/sub-agents)
- [Agent Skills Best Practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices)
- [Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)

**Toolkit Resources**:
- `agents/TEMPLATE.md` - Template to copy
- `agents/examples/` - Complete working examples
- `../docs/ARCHITECTURE.md` - How agents fit together
- `PLANNING.md` - Design decisions

**Community Examples**:
- [VoltAgent/awesome-claude-code-subagents](https://github.com/VoltAgent/awesome-claude-code-subagents) - 100+ specialized agents
- [PubNub: Best practices for Claude Code subagents](https://www.pubnub.com/blog/best-practices-for-claude-code-sub-agents/)

---

**Questions?** Open an issue at https://github.com/dsantiagomj/dsmj-ai-toolkit/issues

---

**Version**: 1.0
**Last Updated**: 2026-01-15
