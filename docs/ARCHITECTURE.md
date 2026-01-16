# Architecture - dsmj-ai-toolkit

## Design Philosophy

**Core Principle**: Simplicity over completeness. Better to have 7 well-designed agents than 20 overlapping ones.

### Key Decisions

1. **Main Claude = Orchestrator ONLY**
   - Never implements code
   - Never commits
   - Never runs tests directly
   - Only coordinates specialists

2. **Specialist Agents = Focused Responsibilities**
   - Each agent has clear, non-overlapping scope
   - Related responsibilities grouped together
   - Tools match responsibilities (read-only for reviewers, write for implementers)

3. **Skills = Domain Knowledge**
   - Reusable across agents
   - Progressive disclosure (main content + references/)
   - Stack skills auto-loaded based on detection

---

## Agent Architecture (7 Agents Total)

### Tier 1: Core Agents (Always Available)

These 3 agents handle the fundamental development cycle: write → review → commit.

#### 1. code-writer
**Purpose**: Implementation specialist
**Tools**: Read, Write, Edit, Grep, Glob, Bash, Task
**Responsibilities**:
- Write code (features, fixes, refactoring)
- Database migrations
- API implementations
- Component creation
- **Does NOT**: Commit, test, review, document

**Why separate from git**: Implementation and version control are separate concerns. Keeps code-writer focused on quality code, not commit messages.

#### 2. code-reviewer
**Purpose**: Quality assurance (technical)
**Tools**: Read, Grep, Glob, Bash (read-only + test execution)
**Responsibilities**:
- Code quality review (patterns, duplication, complexity)
- Security review (OWASP Top 10)
- Run automated tests (unit, integration, e2e)
- Interpret test results
- Performance analysis

**Merged from**: `tester` agent (testing is part of code review workflow)

**Why merged tester**: Testing and code review happen together in quality gates. Separate agents would create coordination overhead.

#### 3. git-docs
**Purpose**: Version control and documentation specialist
**Tools**: Read, Bash (for git commands), Write (for docs)
**Responsibilities**:
- Git commits (conventional commits format)
- Pull requests creation
- Branch management
- Documentation updates (README, API docs)
- CHANGELOG.md generation
- Release notes

**Merged from**: `git-helper` + `publisher` (documentation part)

**Why combined**: Git workflow and documentation naturally flow together. After code is approved, you commit AND document.

---

### Tier 2: Recommended Agents (Most Projects)

These 2 agents add planning and user-facing quality checks.

#### 4. planner
**Purpose**: Requirements and planning specialist
**Tools**: Read, Grep, Glob (read-only, no implementation)
**Responsibilities**:
- Requirements gathering (user stories, acceptance criteria)
- Codebase exploration (existing patterns)
- Architecture decisions (system design, API versioning)
- Technical approach evaluation (pros/cons)
- Task breakdown (actionable implementation steps)
- Risk identification

**Merged from**: Original `planner` + `architect`

**Why merged**: Requirements gathering → architecture decisions → planning flow together. Separating created artificial handoff.

**Workflow position**: BEFORE code-writer (planning before implementation)

#### 5. qa
**Purpose**: Quality assurance (user perspective)
**Tools**: Read, Bash (for manual testing)
**Responsibilities**:

**From original ui-ux-reviewer**:
- Accessibility (WCAG compliance, ARIA, keyboard nav)
- i18n/l10n (internationalization, locale support)
- Visual QA (design consistency, responsive design)

**NEW additions**:
- Functional QA (features work as expected)
- User Acceptance Testing (UAT - meets acceptance criteria)
- Cross-browser/device testing
- Edge case testing (empty states, error states)
- Usability testing (UX friction points)
- Manual testing scenarios

**Why expanded from ui-ux-reviewer**:
- "UI/UX reviewer" implied only for frontend projects
- "QA" useful for ALL projects (backend APIs need functional QA too)
- User perspective testing complements code-reviewer's technical testing

**Difference from code-reviewer**:
| Aspect | code-reviewer | qa |
|--------|---------------|-----|
| Perspective | Developer | End User |
| Testing | Automated (unit/integration) | Manual + UAT |
| Focus | Code quality | User experience |
| Tools | Run test suites | Use the app |

---

### Tier 3: Optional Agents (Specialized Needs)

#### 6. devops
**Purpose**: Operations and infrastructure specialist
**Tools**: Read, Bash
**Responsibilities**:

**From original devops**:
- CI/CD pipelines (GitHub Actions, CircleCI)
- Infrastructure (Docker, Kubernetes)
- Environment management (dev, staging, prod)
- Feature flags

**From site-reliability**:
- Monitoring setup (Datadog, Prometheus)
- Incident response
- Post-mortems
- SLOs/SLAs
- Performance monitoring

**From publisher**:
- Package publishing (Homebrew, npm, PyPI, RubyGems)
- Version bumping
- Distribution to registries
- Release verification

**Why merged all three**: All "operations" concerns. DevOps already handles deployment, natural to handle monitoring and publishing too.

**When to use**: Projects with CI/CD, infrastructure, or package publishing needs

#### 7. ralph-wiggum
**Purpose**: Iterative completion specialist
**Tools**: All tools (full access)
**Responsibilities**:
- TDD loops (iterate until tests pass)
- Overnight builds (unattended task completion)
- Well-defined tasks with objective completion criteria
- Iterative refinement

**Unique pattern**: Keeps working until completion phrase appears

**Why separate**: Fundamentally different workflow (iterative loop vs single-pass). Optional because not all projects use TDD or overnight builds.

---

## Agent Consolidation Summary

### From 11 Agents → 7 Agents

| Old Agent | New Agent | Reason |
|-----------|-----------|--------|
| code-writer | code-writer | ✅ Core, unchanged |
| code-reviewer | code-reviewer | ⬆️ Expanded with testing |
| **tester** | **code-reviewer** | Testing is part of quality review |
| **git-helper** | **git-docs** | Git + docs flow together |
| **publisher** (docs) | **git-docs** | Documentation part |
| planner | planner | ⬆️ Expanded with architecture |
| **architect** | **planner** | Architecture decisions during planning |
| **ui-ux-reviewer** | **qa** | Expanded to full QA role |
| devops | devops | ⬆️ Expanded with SRE + publishing |
| **site-reliability** | **devops** | SRE is operations concern |
| **publisher** (dist) | **devops** | Publishing is deployment concern |
| ralph-wiggum | ralph-wiggum | ✅ Unique pattern, unchanged |

**Result**: Same coverage, less coordination overhead, clearer responsibilities

---

## Workflow Examples

### Backend API Development

**Agents needed**: 4 (code-writer, code-reviewer, git-docs, planner)

```
1. planner → requirements + API design
2. code-writer → implement endpoints
3. code-reviewer → security review + run tests
4. qa → functional testing (API works, edge cases handled)
5. git-docs → commit + update API docs
```

### Full Web Application

**Agents needed**: 5 (+ qa for accessibility and UX)

```
1. planner → requirements + UI/UX considerations
2. code-writer → implement UI components + API
3. code-reviewer → code quality + automated tests
4. qa → accessibility (WCAG), i18n, user flows, edge cases
5. git-docs → commit + update docs
```

### With CI/CD Pipeline

**Agents needed**: 6 (+ devops)

```
1-5. Same as above
6. devops → CI/CD setup, monitoring, deployment
```

### TDD / Overnight Build

**Agents needed**: 7 (+ ralph-wiggum)

```
Option A: Use Ralph for iterative completion
ralph-wiggum → iterate until all tests pass

Option B: Traditional flow + Ralph for refinement
1-5. Normal workflow
6. ralph-wiggum → iterate on edge cases until complete
```

---

## Skills Architecture

### Stack Skills (Auto-loaded)
Detected based on project files (package.json, requirements.txt, go.mod, etc.)

**Current**:
- react
- nextjs
- python
- typescript

**Phase 2**:
- vue-3
- angular-18
- django
- fastapi
- express
- go
- rust

### Domain Skills (Always Loaded)
- security (OWASP Top 10)

**Phase 2**:
- testing-frameworks
- api-design
- accessibility
- i18n
- performance
- database-patterns

### Meta Skills
- context-monitor (drift detection)

---

## Design Tradeoffs

### What We Optimized For

✅ **Simplicity**: 7 agents, not 20
✅ **Clear boundaries**: No overlapping responsibilities
✅ **Practical workflows**: Matches actual dev process
✅ **Flexibility**: Core (3) + Recommended (2) + Optional (2)
✅ **Main Claude as orchestrator**: Never implements

### What We Avoided

❌ **Over-specialization**: "Security reviewer" separate from code reviewer
❌ **Artificial handoffs**: Requirements analyst → planner (now merged)
❌ **Coordination overhead**: Too many agents = context switching
❌ **One-size-fits-all**: Optional agents for specialized needs

---

## Future Considerations

### Potential Phase 3 Agents

If justified by demand:
- **mobile-specialist**: React Native, Flutter, SwiftUI specific patterns
- **data-engineer**: ETL pipelines, data modeling, warehouse optimization
- **ml-engineer**: Model training, inference, MLOps

**Criteria for new agents**:
1. Fundamentally different workflow (can't merge with existing)
2. Specialized tools/skills needed
3. Clear non-overlapping responsibility
4. Demanded by users (not theoretical)

### Agent Customization

Users can create custom agents:
```bash
dsmj-ai customize-agent code-writer
```

This breaks symlink, creates local copy. User maintains it (no auto-updates).

---

## Why This Architecture Works

1. **Matches Mental Model**: Requirements → Code → Review → Commit → Deploy
2. **Clear Handoffs**: Each agent returns to Main Claude, which coordinates next step
3. **Parallel When Possible**: code-reviewer + qa can run in parallel
4. **Scales Down**: Backend API = 4 agents, not all 7
5. **Scales Up**: Add devops + ralph-wiggum only when needed
6. **Main Claude Free**: Orchestrator focuses on coordination, not implementation

---

**Architecture Version**: 1.0
**Last Updated**: 2026-01-15
**Status**: Stable (Phase 1 Complete)
