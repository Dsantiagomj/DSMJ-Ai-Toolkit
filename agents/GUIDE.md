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
description: >
  Clear description of what this agent does.
  Trigger: When [condition 1], when [condition 2], when [condition 3].
tools:
  - Read
  - Write
  - Edit
model: sonnet
metadata:
  author: your-github-username
  version: "1.0"
  category: implementation|review|planning|testing|devops|docs
  last_updated: YYYY-MM-DD
  spawnable: true
  permissions: full|read-only|limited
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
- **MUST include "Trigger:" clause with 3+ specific conditions**

**Best practices**:
- Include BOTH what the agent does AND when to use it
- Be specific: "Reviews code for security vulnerabilities and runs automated tests" not "Reviews code"
- **Start with main description, then add "Trigger:" clause**
- Include 3-5 specific trigger conditions after "Trigger:"
- Front-load important info (first 100 chars most impactful)

**Format**:
```yaml
description: >
  [What the agent does - clear, concise description].
  Trigger: When [condition 1], when [condition 2], when [condition 3].
```

**Examples**:
```yaml
✅ description: >
  Quality assurance specialist. Reviews code quality, runs automated tests, checks security.
  Trigger: When code needs review, when running tests, when checking OWASP compliance,
  when validating patterns, when user requests QA.

✅ description: >
  Git workflow and documentation specialist. Handles commits, PRs, and docs.
  Trigger: When code is ready to commit, when creating pull requests,
  when updating documentation, when user says "commit" or "document".

❌ description: Reviews code (too vague, no triggers, missing Trigger: clause)
❌ description: Does stuff with git (unprofessional, unclear, no Trigger: clause)
❌ description: Code writer. Trigger: when needed (vague trigger conditions)
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

#### `metadata` (required)
**Purpose**: Structured metadata for tracking and validation

**Required fields**:
- `author`: GitHub username or organization
- `version`: Semantic version (e.g., "1.0", "2.1")
- `category`: Agent category (implementation, review, planning, testing, devops, docs)
- `last_updated`: Date in YYYY-MM-DD format
- `spawnable`: Boolean indicating if agent can be spawned
- `permissions`: Permission level (full, read-only, limited)

**Best practices**:
```yaml
✅ metadata:
     author: your-github-username
     version: "1.0"
     category: implementation
     last_updated: 2026-01-17
     spawnable: true
     permissions: full

✅ metadata:
     author: dsmj-ai-toolkit
     version: "2.0"
     category: review
     last_updated: 2026-01-17
     spawnable: true
     permissions: read-only

❌ metadata:
     author: ""  # Empty author
     version: 1.0  # Not quoted
     category: other  # Invalid category
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
description: >
  Quality assurance specialist. Reviews code quality, runs automated tests, checks security.
  Trigger: When code needs review, when running tests, when checking OWASP compliance,
  when validating patterns, when user requests QA.
tools:
  - Read
  - Grep
  - Glob
  - Bash
model: sonnet
metadata:
  author: dsmj-ai-toolkit
  version: "2.0"
  category: review
  last_updated: 2026-01-17
  spawnable: true
  permissions: read-only
---
```

**Implementation specialist**:
```yaml
---
name: code-writer
description: >
  Implementation specialist with full write access for production-quality code.
  Trigger: When implementing features, when writing new code, when modifying existing code,
  when user requests code implementation, when orchestrator assigns implementation task.
tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash
  - Task
model: sonnet
metadata:
  author: dsmj-ai-toolkit
  version: "2.0"
  category: implementation
  last_updated: 2026-01-17
  spawnable: true
  permissions: full
---
```

**Planning specialist**:
```yaml
---
name: planner
description: >
  Requirements and planning specialist. Creates architecture, evaluates approaches.
  Trigger: When planning implementation, when making architecture decisions,
  when evaluating technical approaches, when user needs requirements gathering,
  when breaking tasks into implementation steps.
tools:
  - Read
  - Grep
  - Glob
model: opus
metadata:
  author: dsmj-ai-toolkit
  version: "2.0"
  category: planning
  last_updated: 2026-01-17
  spawnable: true
  permissions: read-only
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

#### 2. When to Spawn This Agent
```markdown
## When to Spawn This Agent

**Spawn this agent when**:
- ✅ Specific condition or scenario 1
- ✅ Specific condition or scenario 2
- ✅ Specific condition or scenario 3

**Don't spawn this agent when**:
- ❌ Different scenario better handled by another agent
- ❌ Task is too simple or requires different approach

**Example triggers**:
- "User request pattern 1"
- "User request pattern 2"
```

#### 3. Core Identity
```markdown
## Core Identity

**Purpose**: Single sentence
**Best for**: List of ideal use cases
```

#### 4. Critical Rules
```markdown
## Critical Rules (Inherited from CLAUDE.md)

> ⚠️ You inherit ALL core operating rules

**Key rules for your work**:
1. **Rule Name**: How it applies to you
```

Select 3-5 most relevant from the 9 core rules.

#### 5. Your Workflow
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

#### 6. Response Examples
```markdown
## Response Examples

### ✅ GOOD: Effective Agent Response

**User Request**: "Realistic example request"

**Agent Response**:
[Clear, structured response showing the agent following its workflow]

**Why this is good**:
- Specific reasons

### ❌ BAD: Ineffective Agent Response

**User Request**: "Same example request"

**Agent Response**:
[Example of poor response]

**Why this is bad**:
- Specific reasons
```

#### 7. Anti-Patterns
```markdown
## Anti-Patterns

**What NOT to do**:

❌ **Anti-Pattern 1: [Name]**
- Description of what the bad practice looks like
- Why it's problematic
- What to do instead
```

Include at least 3 anti-patterns.

#### 8. Quality Checks
```markdown
## Quality Checks

Before completing, verify:
✅ Check 1
✅ Check 2
```

#### 9. Performance Guidelines
```markdown
## Performance Guidelines

**For optimal results**:
- Guideline 1: Specific advice for this agent's performance
- Guideline 2: How to handle edge cases

**Model recommendations**:
- Use **haiku** for: Simple tasks
- Use **sonnet** for: Standard tasks (default)
- Use **opus** for: Complex tasks requiring deep analysis
```

#### 10. Success Criteria
```markdown
## Success Criteria

**This agent succeeds when**:
- ✅ Success criterion 1
- ✅ Success criterion 2

**This agent fails when**:
- ❌ Failure scenario 1
- ❌ Failure scenario 2
```

#### 11. What You Do vs Don't Do
```markdown
## What You Do vs What You Don't Do

**✅ You DO**: Your responsibilities
**❌ You DON'T**: What's outside scope
```

#### 12. Keywords
```markdown
## Keywords

`keyword1`, `keyword2`, `keyword3`, `keyword4`, `keyword5`
```

Include 5-10 keywords that help identify when this agent should be used.

#### 13. Example
```markdown
## Example: [Concrete Scenario]

**User Request**: "..."

**Your Response**:
[Step-by-step walkthrough]
```

Always include at least one complete example.

#### 14. Validation Checklist
```markdown
## Validation Checklist

**Frontmatter**:
- [ ] Valid YAML frontmatter with all required fields
- [ ] Description includes "Trigger:" clause with 3+ specific conditions
- [ ] Metadata complete

**Content Structure**:
- [ ] "When to Spawn This Agent" with ✅ and ❌ conditions
- [ ] Clear workflow with 3+ phases
- [ ] Response Examples showing ✅ GOOD vs ❌ BAD
- [ ] Anti-Patterns section with 3+ patterns
```

### Optional Sections

Add these if relevant:

- **Special Cases**: Scenarios requiring different approach
- **Communication Style**: Tone and style adaptations
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
- **react**: When creating components or using hooks
- **api-design**: When designing REST endpoints
```

**Bad**:
```markdown
**Reference skills**: security, react, api-design
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

### 9. Communication Style

Agents should adapt to the communication style specified in the main CLAUDE.md file:

```markdown
## Communication Style

The agent respects the communication style set in `.claude/CLAUDE.md`.
All responses should maintain technical accuracy while adapting tone as configured.

Example (Professional - default):
"I've implemented the authentication system. Tests passing."
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
skills: [security, react, testing-frameworks, api-design]
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
- description: Clear triggers + capabilities (<1024 chars) with "Trigger:" clause
- tools: Minimal necessary permissions
- model: Appropriate choice (sonnet default)
- metadata: All required fields (author, version, category, last_updated, spawnable, permissions)

✅ **Structure**:
- When to Spawn This Agent section (with ✅ and ❌ conditions)
- Core Identity section
- Critical Rules section
- Workflow phases (2-5)
- Response Examples (✅ GOOD vs ❌ BAD)
- Anti-Patterns section (3+ patterns)
- Quality Checks section
- Performance Guidelines section
- Success Criteria section
- What You Do vs Don't Do
- Keywords section (5-10 keywords)
- At least one complete example
- Validation Checklist section

✅ **Content**:
- Single responsibility
- Clear boundaries
- Skill references explained
- Error handling defined
- Communication style adaptable
- Explicit trigger conditions in frontmatter

✅ **Practical**:
- Solves real problem
- Non-overlapping with other agents
- Works with toolkit architecture
- Testable workflow
- Follows validation workflow

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
- Different communication styles (if supported)

---

## Checklist for Production-Ready Agent

Before adding agent to toolkit:

**YAML Frontmatter**:
- [ ] name: Valid kebab-case, <64 chars
- [ ] description: Clear triggers + capabilities, <1024 chars, includes "Trigger:" clause
- [ ] tools: Minimal necessary permissions listed
- [ ] model: Appropriate choice (sonnet default)
- [ ] metadata: All fields complete (author, version, category, last_updated, spawnable, permissions)

**Structure**:
- [ ] Title & tagline
- [ ] When to Spawn This Agent section
- [ ] Core Identity section
- [ ] Critical Rules (references CLAUDE.md)
- [ ] Workflow with phases (2-5)
- [ ] Response Examples (✅ GOOD vs ❌ BAD)
- [ ] Anti-Patterns section (3+ patterns)
- [ ] Quality Checks section
- [ ] Performance Guidelines section
- [ ] Success Criteria section
- [ ] What You Do vs Don't Do
- [ ] Keywords section (5-10 keywords)
- [ ] At least one complete example
- [ ] Validation Checklist section

**Content Quality**:
- [ ] Single, clear responsibility
- [ ] Non-overlapping with other agents
- [ ] Skill references with context
- [ ] Error handling defined
- [ ] Communication style adaptable
- [ ] Explicit trigger conditions
- [ ] Under 500 lines (or split with references/)

**Testing**:
- [ ] Tested with real scenarios
- [ ] Tools work as expected
- [ ] Quality checks execute
- [ ] Edge cases handled
- [ ] Trigger conditions validated

**Documentation**:
- [ ] Clear when to use vs other agents
- [ ] Examples are realistic
- [ ] Integrates with toolkit workflow
- [ ] Validation checklist complete

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

**Version**: 2.0
**Last Updated**: 2026-01-17
