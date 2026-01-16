# Agent Examples

This directory contains complete, working examples of different agent patterns. Use these as references when creating your own agents.

---

## Quick Reference

| Example | Pattern | Tools | Complexity | Use As Template For |
|---------|---------|-------|------------|---------------------|
| [minimal-agent.md](minimal-agent.md) | Simple specialist | Read, Write, Edit | ⭐ Simple | Formatters, validators, simple transformations |
| [read-only-reviewer.md](read-only-reviewer.md) | Read-only analyzer | Read, Grep, Glob | ⭐⭐ Medium | Reviewers, auditors, analyzers |
| [code-implementer.md](code-implementer.md) | Full-stack builder | All tools | ⭐⭐⭐ Complex | Feature builders, implementers |
| [research-specialist.md](research-specialist.md) | Web research | Read + Web | ⭐⭐ Medium | Documentation researchers, library evaluators |

---

## Examples Overview

### 1. minimal-agent.md - Code Formatter

**Pattern**: Simplest possible agent structure

**What it demonstrates**:
- Minimal YAML frontmatter (just required fields)
- Simple 3-phase workflow
- Clear "What You Do vs Don't Do" section
- Single concrete example

**Key features**:
- Only 5 tool permissions
- No web access
- No bash execution (safe)
- ~150 lines total

**Use this template for**:
- Code formatters (Prettier, Black, gofmt)
- Linters (ESLint, Pylint)
- Simple validators
- File transformations

**Example use case**:
```
User: "Format all TypeScript files"
formatter: Detects Prettier config → Formats files → Verifies no logic changes
```

---

### 2. read-only-reviewer.md - Security Auditor

**Pattern**: Read-only analysis with no modifications

**What it demonstrates**:
- Read-only tool permissions (Read, Grep, Glob only)
- Multi-phase workflow (4 phases)
- Special cases section
- Severity-categorized output
- Evidence-based findings

**Key features**:
- NO write/edit access (safe for audits)
- References security skill
- OWASP Top 10 checklist
- Structured report format

**Use this template for**:
- Security auditors
- Code quality reviewers
- Pattern analyzers
- Compliance checkers
- Performance analyzers (read-only)

**Example use case**:
```
User: "Audit the payment API for security issues"
security-auditor:
  → Scopes to payment files
  → Checks OWASP Top 10
  → Generates severity-categorized report
  → No code modifications
```

**Why read-only**:
- Prevents accidental changes during audit
- Ensures audit integrity
- Safer for security-sensitive reviews

---

### 3. code-implementer.md - Feature Builder

**Pattern**: Full-stack implementation with all permissions

**What it demonstrates**:
- Complete tool access (Read, Write, Edit, Bash, Task)
- Complex 5-phase workflow
- Integration with multiple skills
- Quality gates throughout
- Can spawn other agents (Task tool)
- Both professional and Maestro communication modes

**Key features**:
- Full implementation access
- Backend + Frontend + Tests
- Security checks embedded
- Accessibility checks
- Can spawn code-reviewer for quality checks

**Use this template for**:
- Feature builders
- Full-stack implementers
- Greenfield project work
- Complex refactoring

**Example use case**:
```
User: "Implement user profile editing"
feature-builder:
  Phase 1: Explore codebase for patterns
  Phase 2: Build backend API
  Phase 3: Build frontend UI
  Phase 4: Write tests
  Phase 5: Document & spawn code-reviewer
```

**Safety notes**:
- Has full write access (powerful but risky)
- Includes quality checks to prevent issues
- Recommends spawning code-reviewer after implementation
- Still doesn't commit (that's git-docs)

---

### 4. research-specialist.md - Tech Researcher

**Pattern**: Research with web access

**What it demonstrates**:
- Web access (WebFetch, WebSearch)
- Research methodology (official docs first)
- Citation requirements (source everything)
- Version-aware research
- Comparison tables
- Cross-referencing multiple sources

**Key features**:
- Read + Web tools
- Structured research output
- Source citations mandatory
- Version-specific information
- Alternatives presented with tradeoffs

**Use this template for**:
- Documentation researchers
- Library comparisons
- Best practices research
- Migration guides
- Technology evaluations

**Example use case**:
```
User: "Research React Server Components best practices"
tech-researcher:
  → Searches official Next.js docs
  → Cross-references React docs
  → Verifies with Vercel guides
  → Presents best practices with examples
  → Cites all sources
```

**Key principle**:
- Official docs first
- Verify with multiple sources
- Always cite sources
- Version-specific information

---

## Comparison: When to Use Each Pattern

### Use **minimal-agent** when:
- ✅ Simple, focused task
- ✅ No complex decision-making
- ✅ Clear input → output transformation
- ✅ Minimal tool needs

**Examples**: Formatters, linters, validators

### Use **read-only-reviewer** when:
- ✅ Analysis only (no modifications)
- ✅ Audit or review workflow
- ✅ Safety is critical
- ✅ Need to prevent accidental changes

**Examples**: Security auditors, code reviewers, compliance checkers

### Use **code-implementer** when:
- ✅ Full feature implementation needed
- ✅ Spans multiple files/layers
- ✅ Requires backend + frontend + tests
- ✅ Quality gates important

**Examples**: Feature builders, full-stack work

### Use **research-specialist** when:
- ✅ Need current documentation
- ✅ Evaluating libraries/frameworks
- ✅ Finding best practices
- ✅ Comparing alternatives

**Examples**: Tech research, library evaluation, migration planning

---

## Tool Permission Patterns

### Pattern 1: Read-Only
```yaml
tools: [Read, Grep, Glob]
```
**For**: Reviewers, auditors, analyzers

**Safe because**: Cannot modify anything

### Pattern 2: File Manipulation
```yaml
tools: [Read, Write, Edit, Grep, Glob]
```
**For**: Code writers (no execution)

**Safe because**: No shell execution

### Pattern 3: File + Execution
```yaml
tools: [Read, Write, Edit, Grep, Glob, Bash]
```
**For**: Implementers who need to run tests

**Risk**: Can execute shell commands (needs trust)

### Pattern 4: Research
```yaml
tools: [Read, Grep, Glob, WebFetch, WebSearch]
```
**For**: Documentation researchers

**Safe because**: Read-only with web access for research

### Pattern 5: Full Access
```yaml
tools: [Read, Write, Edit, Grep, Glob, Bash, Task]
```
**For**: Feature builders, orchestrators

**Risk**: Full system access (highest trust needed)

---

## Common Sections Reference

All agents should have:

### Required Sections
1. **YAML Frontmatter** - name, description, tools
2. **Core Identity** - Purpose, best use cases
3. **Critical Rules** - Inherited from CLAUDE.md
4. **Your Workflow** - Phases with clear steps
5. **Quality Checks** - Verification checklist
6. **What You Do vs Don't Do** - Clear boundaries
7. **Example** - At least one complete scenario

### Optional Sections
- **Special Cases** - Scenarios needing different approach
- **Communication Style** - Professional + Maestro
- **When to Stop and Ask** - Clarification triggers
- **Spawning Other Agents** - When to delegate

---

## How to Use These Examples

### 1. Find Similar Pattern

Match your agent to closest example:
- Simple transformation? → **minimal-agent**
- Analysis only? → **read-only-reviewer**
- Full implementation? → **code-implementer**
- Web research? → **research-specialist**

### 2. Copy Template

```bash
cp agents/examples/[closest-example].md agents/your-agent.md
```

### 3. Customize

- Update YAML frontmatter (name, description, tools)
- Modify Core Identity (purpose, use cases)
- Adapt workflow phases
- Update examples to match your domain
- Adjust quality checks

### 4. Test

```bash
# Symlink to test project
ln -s ~/.dsmj-ai-toolkit/agents/your-agent.md ~/test-project/.claude/agents/

# Test in Claude Code
cd ~/test-project
claude-code
```

---

## Best Practices from Examples

### 1. Tool Permissions (from all examples)
- **Least privilege**: Grant only necessary tools
- **Read-only when possible**: Safer for reviewers
- **Justify Bash**: Only if execution truly needed

### 2. Workflow Structure (from code-implementer)
- Break into clear phases (2-5)
- Each phase has inputs, actions, outputs
- Quality checks within phases

### 3. Examples Matter (from all)
- Every agent has at least one complete example
- Examples show real user requests
- Show step-by-step execution
- Include final output format

### 4. Boundaries (from all)
- Clear "What You Do vs Don't Do"
- Specify which agent handles related tasks
- Prevents overlap and confusion

### 5. Citations (from research-specialist)
- Always cite sources for external information
- Include URLs
- Note version numbers
- Mark official vs community sources

### 6. Quality Gates (from code-implementer)
- Embedded throughout workflow
- Not just at the end
- Specific, checkable criteria

### 7. Communication Modes (from code-implementer, research-specialist)
- Support both professional and Maestro
- Show examples of each
- Keep technical accuracy in both modes

---

## Validation Checklist

Before using an agent in production, verify against examples:

**Structure**:
- [ ] YAML frontmatter matches examples (valid format)
- [ ] Has all required sections
- [ ] Workflow has clear phases

**Tools**:
- [ ] Minimal necessary permissions (like examples)
- [ ] Justified any Bash access
- [ ] Read-only for review agents

**Content**:
- [ ] At least one complete example (like all examples)
- [ ] Clear boundaries (inspired by examples)
- [ ] Quality checks specific and actionable

**Safety**:
- [ ] Can't accidentally break things
- [ ] User confirmation for risky operations
- [ ] References inherited core rules

---

## Creating Your Own Examples

Have a well-tested agent? Consider contributing it as an example:

1. **Generalize**: Remove project-specific details
2. **Document**: Explain the pattern it demonstrates
3. **Complete**: Ensure all required sections present
4. **Test**: Verify it works as standalone example
5. **Submit**: PR to dsmj-ai-toolkit

**Good candidates**:
- Unique tool permission pattern
- Novel workflow structure
- Specialized domain (mobile, data, ML)
- Solves common problem

---

## Resources

- [AGENT_TEMPLATE.md](../AGENT_TEMPLATE.md) - Blank template to copy
- [AGENT_CREATION_GUIDE.md](../AGENT_CREATION_GUIDE.md) - Complete creation guide
- [ARCHITECTURE.md](../../docs/ARCHITECTURE.md) - How agents fit in toolkit

**Official Docs**:
- [Claude Code Subagents](https://code.claude.com/docs/en/sub-agents)
- [Agent Skills Best Practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices)

---

**Questions?** Open an issue at https://github.com/dsantiagomj/dsmj-ai-toolkit/issues
