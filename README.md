# dsmj-ai-toolkit

A production-quality, reusable AI toolkit for Claude Code that adapts to different projects and tech stacks.

## Features

- 🎯 **Specialist-First Architecture**: Always uses focused specialists (code-writer, code-reviewer) for better context and quality
- 🧩 **Modular Skills**: Composable knowledge modules following the [Agent Skills](https://agentskills.io) open standard
- 🔄 **Auto-Stack Detection**: Automatically detects your tech stack and configures appropriate skills
- 🔗 **Symlink-Based Updates**: Global toolkit with per-project symlinks for easy updates
- 📋 **Quality Gates**: Vibe Coding principles integrated (Frame → Scope → Generate → Review → Verify)
- 🎨 **Maestro Mode**: Optional casual communication style (Spanish + English slangs)
- 🛡️ **Security-First**: Built-in security best practices (OWASP Top 10, auth patterns)

## Quick Start

### Installation

```bash
# Clone the repository
git clone https://github.com/dsantiagomj/dsmj-ai-toolkit.git
cd dsmj-ai-toolkit

# Install globally
./bin/dsmj-ai install

# Add to PATH (or restart terminal)
source ~/.zshrc  # or ~/.bashrc
```

### Initialize a Project

```bash
# Navigate to your project
cd my-project

# Initialize toolkit
dsmj-ai init

# This will:
# - Detect your stack (React, Next.js, Python, etc.)
# - Create .claude/ directory (if it doesn't exist)
# - Symlink relevant agents and skills
# - Generate customizable CLAUDE.md config (if it doesn't exist)
```

**⚠️ Safe with Existing MCP Configurations**:
The toolkit is **additive** and preserves existing configurations:
- ✅ Preserves existing `.claude/settings.json`, `.claude/mcp.json`, etc.
- ✅ Only adds `agents/` and `skills/` subdirectories
- ✅ Skips `CLAUDE.md` generation if file already exists
- ✅ Won't overwrite any existing MCP server configurations

If you have MCP servers already configured, they will continue working!

See [docs/MCP_SAFETY.md](docs/MCP_SAFETY.md) for detailed safety information.

### Start Using

```bash
# Start Claude Code in your project
claude-code

# The toolkit is now active!
# - Main Claude acts as orchestrator
# - Spawns specialists for focused work
# - Uses skills for domain knowledge
```

## Architecture

### The Vibe Loop

Our workflow follows this pattern:

```
Frame outcome → Scope change → Generate → Review diff → Verify
```

**In practice**:
1. **Main Claude (Orchestrator)**: Analyzes request, references skills
2. **Spawn Specialist**: code-writer for implementation, code-reviewer for reviews
3. **Focused Work**: Specialist works in isolated context with relevant skills
4. **Review & Verify**: Quality gates ensure code quality
5. **Return Summary**: Clear file references and next steps

### Agents (6 Total)

**Core Agents** (Always Available):
- **code-writer**: Implementation specialist - writes code only
- **code-reviewer**: Quality specialist - code review, security checks, runs automated tests
- **git-docs**: Git workflow specialist - commits, PRs, documentation, changelog

**Recommended Agents** (Most Projects):
- **planner**: Planning specialist - requirements gathering, architecture decisions, task breakdown
- **qa**: Quality assurance specialist - functional QA, UAT, accessibility, i18n, manual testing

**Optional Agents** (Specialized Needs):
- **devops**: Operations specialist - CI/CD, monitoring, publishing, releases, SRE

**Agent Usage by Project Type**:
| Project Type | Agents Needed | Count |
|--------------|---------------|-------|
| Backend API | code-writer, code-reviewer, git-docs, planner | 4 |
| Web App | + qa | 5 |
| With CI/CD | + devops | 6 |

### Skills

**Stack Skills** (auto-loaded based on detection):
- `react-19`: React 19 patterns with Server Components
- `nextjs-15`: Next.js 15 App Router patterns
- `python-312`: Python 3.12 best practices
- `typescript`: TypeScript patterns and types

**Domain Skills** (always loaded):
- `security`: OWASP Top 10, auth patterns, secure coding

**Meta Skills**:
- `context-monitor`: Detects conversation drift, suggests refocusing

## CLAUDE.md Configuration

The `.claude/CLAUDE.md` file is your **primary customization point**:

### Project Context (Prompt DNA)
```markdown
## Project Context
**Stack**: Next.js 15, React 19, TypeScript, Prisma
**Current State**: Building authentication system
**Architecture**: API routes in /app/api/, components in /components/

## Goals & Auto-Invoke Rules
- **React components** → Reference react-19 skill
- **API routes** → Reference nextjs-15 skill
- **Security concerns** → Reference security skill

## Non-Goals (Anti-Patterns)
- ❌ Don't use client components unless necessary
- ❌ Don't bypass auth middleware
```

### Communication Styles

**Default**: Professional, concise, technical

**Maestro Mode**: Casual, friendly, with slangs
```
Activate with: "/maestro" or "use maestro mode"

Spanish slangs: ojo, chévere, dale, bacano, listo
English slangs: bet, lowkey, ngl, fr, valid
```

**IMPORTANT**: Maestro only changes communication style. ALL core rules and quality gates still apply.

### Core Operating Rules

1. **Git Commits**: Never add AI attribution
2. **Build Process**: Never auto-build, let user decide
3. **Tooling**: Use bat/rg/fd/sd/eza (modern tools)
4. **User Questions**: STOP and WAIT, never assume
5. **Verification First**: "Déjame verificar" before confirming
6. **Being Wrong**: Explain with evidence or acknowledge
7. **Show Alternatives**: Present options with tradeoffs
8. **Technical Accuracy**: Verify before stating claims
9. **Quality Gates**: Review → Test → Verify before commit

## Directory Structure

### Global Installation
```
~/.dsmj-ai-toolkit/
├── templates/
│   └── CLAUDE.md.template
├── agents/
│   ├── code-writer.md         # Core: Implementation
│   ├── code-reviewer.md       # Core: Quality + tests
│   ├── git-docs.md            # Core: Git + documentation
│   ├── planner.md             # Recommended: Planning
│   ├── qa.md                  # Recommended: QA + UAT
│   └── devops.md              # Optional: Operations
├── skills/
│   ├── stack/
│   │   ├── react-19/
│   │   ├── nextjs-15/
│   │   └── python-312/
│   ├── domain/
│   │   └── security/
│   └── meta/
│       └── context-monitor/
└── bin/
    └── dsmj-ai
```

### Project Structure (after init)
```
my-project/
├── .claude/
│   ├── CLAUDE.md                 # User customizes THIS
│   ├── agents/                   # Symlinks to global (based on project needs)
│   │   ├── code-writer.md -> ~/.dsmj-ai-toolkit/agents/code-writer.md
│   │   ├── code-reviewer.md -> ~/.dsmj-ai-toolkit/agents/code-reviewer.md
│   │   ├── git-docs.md -> ~/.dsmj-ai-toolkit/agents/git-docs.md
│   │   ├── planner.md -> ~/.dsmj-ai-toolkit/agents/planner.md
│   │   ├── qa.md -> ~/.dsmj-ai-toolkit/agents/qa.md
│   │   └── devops.md -> ~/.dsmj-ai-toolkit/agents/devops.md
│   └── skills/                   # Symlinks to global
│       ├── react-19 -> ~/.dsmj-ai-toolkit/skills/stack/react-19
│       ├── security -> ~/.dsmj-ai-toolkit/skills/domain/security
│       └── context-monitor -> ~/.dsmj-ai-toolkit/skills/meta/context-monitor
└── [your project files]
```

## CLI Commands

```bash
# Install globally
dsmj-ai install

# Initialize current project
dsmj-ai init

# Show status
dsmj-ai status

# Update toolkit (WIP)
dsmj-ai update

# Resync skills (WIP)
dsmj-ai sync

# Show version
dsmj-ai version

# Show help
dsmj-ai help
```

## Quality Gates Workflow

Before ANY commit:

1. **Diff Review**: code-reviewer analyzes changes
2. **Run It**: Execute relevant tests (when applicable)
3. **Edge Checks**: Verify error handling, edge cases
4. **Stop If**:
   - Tests failing
   - Security vulnerabilities detected
   - User hasn't confirmed breaking changes
   - Build errors present

## Example Workflows

### Complete Feature Implementation
```
User: "Add user profile editing with accessibility support"

Main Claude (Orchestrator):
  1. Analyzes request
  2. Spawns planner for requirements and planning

planner:
  1. Gathers requirements (acceptance criteria, edge cases)
  2. Explores codebase for existing patterns
  3. Creates implementation plan with task breakdown
  4. Returns structured plan

Main Claude:
  1. Reviews plan with user, gets approval
  2. Spawns code-writer for implementation

code-writer:
  1. References react-19 + security skills
  2. Implements profile editing components and API
  3. Returns summary with file references

Main Claude:
  1. Spawns code-reviewer for quality check

code-reviewer:
  1. Reviews code quality and security
  2. Runs automated tests (unit, integration)
  3. Returns review (security, patterns, test coverage)

Main Claude:
  1. Spawns qa for user acceptance testing

qa:
  1. Tests user flows (edit profile, save, validation)
  2. Checks accessibility (WCAG, keyboard nav, screen readers)
  3. Tests edge cases (empty states, long text, errors)
  4. Returns QA report with issues found

Main Claude:
  1. If issues found, spawns code-writer to fix
  2. When approved, spawns git-docs

git-docs:
  1. Creates conventional commit
  2. Updates API documentation
  3. Updates CHANGELOG.md
  4. Creates PR (if requested)

Result: Complete, tested, documented feature ready for merge
```

### Quick Fix Workflow
```
User: "Fix the password validation bug"

Main Claude:
  1. Spawns code-writer for quick fix

code-writer:
  1. Fixes validation logic
  2. Returns summary

Main Claude:
  1. Spawns code-reviewer

code-reviewer:
  1. Reviews fix, runs tests
  2. Confirms no regressions

Main Claude:
  1. Spawns git-docs for commit

Result: Bug fixed, tested, committed
```

## Progressive Disclosure

Skills use progressive disclosure to minimize context:

```
skills/stack/react-19/
├── SKILL.md              # Main content (~500 lines)
└── references/           # Detailed docs (loaded as needed)
    ├── server-components.md
    ├── hooks-reference.md
    ├── performance.md
    └── testing.md
```

Main content is loaded automatically. References are loaded only when needed.

## Customization

### What to Customize
✅ `.claude/CLAUDE.md` (Project Context, Goals, Non-Goals, Conventions)

### What NOT to Change
❌ Agent files (toolkit maintains these, updates via symlinks)
❌ Skill files (toolkit maintains these, updates via symlinks)

### Creating Custom Agents

Want to create your own agents? We've got you covered!

**Quick Start**:
```bash
# Copy the template
cp agents/TEMPLATE.md agents/my-agent.md

# Edit and customize
# See agents/GUIDE.md for complete instructions
```

**Resources**:
- **[agents/TEMPLATE.md](agents/TEMPLATE.md)** - Blank template to copy
- **[agents/GUIDE.md](agents/GUIDE.md)** - Complete creation guide with best practices
- **[agents/examples/](agents/examples/)** - Working examples of different agent patterns:
  - `minimal-agent.md` - Simple specialist (formatter)
  - `read-only-reviewer.md` - Security auditor (read-only)
  - `code-implementer.md` - Full-stack builder (all tools)
  - `research-specialist.md` - Tech researcher (web access)

**See [agents/GUIDE.md](agents/GUIDE.md) for**:
- YAML frontmatter rules and best practices
- Tool permission patterns
- Workflow structure guidelines
- Quality standards
- Common pitfalls to avoid

### Advanced: Customize Existing Agents

```bash
dsmj-ai customize-agent code-writer
```

This breaks the symlink and creates a local copy you maintain.

⚠️ **Warning**: Custom agents won't receive toolkit updates!

### Creating Custom Skills

Want to create domain knowledge for your project? Skills system has you covered!

**Quick Start**:
```bash
# Copy the template
cp skills/TEMPLATE.md skills/domain/my-skill/SKILL.md

# Edit and customize
# See skills/GUIDE.md for complete instructions
```

**Resources**:
- **[skills/TEMPLATE.md](skills/TEMPLATE.md)** - Blank template to copy
- **[skills/GUIDE.md](skills/GUIDE.md)** - Complete creation guide with best practices
- **[skills/examples/](skills/examples/)** - Working examples of different skill patterns:
  - `minimal-skill.md` - Git conventions (simplest)
  - `stack-skill.md` - Vue 3 Composition API (framework patterns)
  - `domain-skill.md` - Testing patterns (cross-framework)
  - `meta-skill.md` - Code review checklist (workflow)

**See [skills/GUIDE.md](skills/GUIDE.md) for**:
- YAML frontmatter rules and validation
- Progressive disclosure patterns
- Content structure guidelines
- Stack vs Domain vs Meta categories
- Quality standards and best practices

## Philosophy & Principles

### Core Beliefs
1. **Specialists Over Generalists**: Focused context beats knowing everything
2. **Quality Over Speed**: Verify before acting, review before committing
3. **Clarity Over Cleverness**: Simple, clear code beats clever abstractions
4. **Security By Default**: Auth, validation, and error handling are not optional

### Vibe Coding Principles (Integrated)
- **Director Mindset**: Orchestrator coordinates, specialists implement
- **Small Scopes**: Each specialist handles focused subtask
- **Verify by Default**: Check before confirming, test before deploying
- **State Discipline**: Clean context, clear summaries, no pollution

## Roadmap

### ✅ Phase 1: Core Architecture (Complete)
- Main Claude orchestrator pattern
- 6 specialized agents (core + recommended + optional)
- 3 core agents: code-writer, code-reviewer, git-docs
- 2 recommended agents: planner, qa
- 1 optional agent: devops
- react-19 + security + context-monitor skills
- CLAUDE.md with Prompt DNA + Maestro mode
- Installation CLI with symlinks
- MCP-safe installation (preserves existing configs)

### 🔲 Phase 2: Expanded Skills & Polish
- Skills: 20+ stack skills (Vue, Angular, Django, FastAPI, Go, Rust, etc.)
- Domain skills: testing-frameworks, api-design, accessibility, i18n, performance
- Agent skill improvements (progressive disclosure)
- Context7 MCP integration examples
- Agent usage analytics and insights

### 🔲 Phase 3: Team & Distribution
- Team conventions sync
- Shared skill libraries across teams
- Multi-project management dashboard
- Homebrew distribution
- Project templates (backend, fullstack, mobile)

### 🔲 Phase 4: Advanced Features
- Custom skill creation wizard
- Visual agent workflow designer
- Performance analytics (agent usage, token costs)
- Integration marketplace
- AI-powered skill recommendations

## Contributing

Contributions welcome! This is an open-source toolkit.

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## License

MIT License - see [LICENSE](LICENSE) file for details

## Credits

Built by [dsantiagomj](https://github.com/dsantiagomj)

Inspired by:
- [Agent Skills](https://agentskills.io) open standard
- [Prowler](https://github.com/prowler-cloud/prowler) skills-based architecture
- [awesome-claude-code-subagents](https://github.com/VoltAgent/awesome-claude-code-subagents) agent patterns
- Vibe Coding principles for AI-directed development

## Support

- 📖 [Documentation](https://github.com/dsantiagomj/dsmj-ai-toolkit/wiki)
- 🐛 [Issue Tracker](https://github.com/dsantiagomj/dsmj-ai-toolkit/issues)
- 💬 [Discussions](https://github.com/dsantiagomj/dsmj-ai-toolkit/discussions)

---

**Built with Claude, for Claude** ✨
