# dsmj-ai-toolkit

A production-quality AI toolkit for Claude Code with specialized agents, modular skills, and intelligent stack detection. Built for professional development workflows with security and quality gates integrated.

## Features

- **🎯 Specialist Agents**: 6 focused agents (code-writer, code-reviewer, planner, qa, git-docs, devops)
- **🧩 18 Modular Skills**: Stack-specific knowledge (React, TypeScript, Docker, Prisma, etc.) + domain expertise (security, accessibility, performance)
- **🔄 Auto-Stack Detection**: Automatically configures skills based on your project
- **🔗 Symlink Architecture**: Global installation, per-project configuration
- **🛡️ Security First**: OWASP patterns and quality gates built-in

## Quick Start

### Installation

**Option 1: Quick Install (Recommended)**
```bash
curl -fsSL https://raw.githubusercontent.com/dsantiagomj/dsmj-ai-toolkit/main/install.sh | bash
source ~/.zshrc  # or ~/.bashrc
```

**Option 2: Homebrew**
```bash
brew install dsantiagomj/dsmj-ai-toolkit/dsmj-ai-toolkit
```

**Option 3: Manual**
```bash
git clone https://github.com/dsantiagomj/dsmj-ai-toolkit.git
cd dsmj-ai-toolkit
./bin/dsmj-ai install
```

### Initialize Your Project

```bash
cd your-project
dsmj-ai init  # Auto-detects stack, links agents & skills
claude-code   # Start Claude Code
```

### Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/dsantiagomj/dsmj-ai-toolkit/main/uninstall.sh | bash
```

## What You Get

### 6 Specialized Agents

| Agent | Purpose | Use When |
|-------|---------|----------|
| **code-writer** | Implementation | Writing features, fixing bugs |
| **code-reviewer** | Quality + Security | Reviewing code, running tests |
| **planner** | Architecture | Planning features, gathering requirements |
| **qa** | Testing | UAT, accessibility, functional testing |
| **git-docs** | Git + Docs | Commits, PRs, documentation |
| **devops** | Operations | CI/CD, deployment, monitoring |

### 18 Skills

**Stack** (9): React, TypeScript, Docker, Prisma, tRPC, Radix UI, React Hook Form, Zustand, Vercel AI SDK

**Domain** (8): Security, Accessibility, API Design, Database Migrations, i18n, Design Patterns, Performance, Testing Frameworks

**Meta** (1): Context Monitor

[See full skills list →](skills/CATALOG.md)

### How It Works

```
┌─────────────────────────────────────────────────────┐
│  Your Project                                       │
├─────────────────────────────────────────────────────┤
│  .claude/                                           │
│  ├── CLAUDE.md          ← Your customization       │
│  ├── agents/            ← Symlinks to global       │
│  └── skills/            ← Auto-selected by stack   │
└─────────────────────────────────────────────────────┘
                    ↓ (symlinks)
┌─────────────────────────────────────────────────────┐
│  Global: ~/.dsmj-ai-toolkit/                        │
├─────────────────────────────────────────────────────┤
│  ├── agents/            ← 6 specialist agents      │
│  ├── skills/            ← 18 knowledge modules     │
│  ├── templates/         ← CLAUDE.md template       │
│  └── bin/dsmj-ai        ← CLI tool                 │
└─────────────────────────────────────────────────────┘

Update toolkit once → All projects benefit immediately
```

## CLI Commands

```bash
dsmj-ai install      # Install globally
dsmj-ai init         # Initialize current project
dsmj-ai status       # Show installation status
dsmj-ai version      # Show version
dsmj-ai help         # Show help
```

## Customization

Edit `.claude/CLAUDE.md` to customize for your project:

- **Project Context**: Stack, architecture, current state
- **Auto-Invoke Rules**: When to reference which skills
- **Non-Goals**: Anti-patterns to avoid
- **Communication Style**: Professional or Maestro mode (casual)

[→ Full Configuration Guide](docs/CONFIGURATION.md)

### Creating Custom Agents

```bash
cp agents/TEMPLATE.md agents/my-agent.md
# Edit and customize
```

[→ Agent Creation Guide](agents/GUIDE.md)

### Creating Custom Skills

```bash
cp skills/TEMPLATE.md skills/domain/my-skill/SKILL.md
# Edit and customize
```

[→ Skill Creation Guide](skills/GUIDE.md)

## Documentation

- **[Configuration Guide](docs/CONFIGURATION.md)** - Customize CLAUDE.md for your project
- **[Workflow Examples](docs/WORKFLOWS.md)** - Real-world usage patterns
- **[Architecture](docs/ARCHITECTURE.md)** - How the toolkit works
- **[MCP Safety](docs/MCP_SAFETY.md)** - Safe with existing MCP configs
- **[Agent Guide](agents/GUIDE.md)** - Create custom agents
- **[Skill Guide](skills/GUIDE.md)** - Create custom skills

## Example Workflow

```
User: "Add user authentication with security best practices"

Main Claude:
  → Spawns planner (gathers requirements, creates plan)
  → Spawns code-writer (implements feature with security skill)
  → Spawns code-reviewer (security audit, runs tests)
  → Spawns qa (tests user flows, accessibility)
  → Spawns git-docs (commits, updates docs)

Result: Complete, tested, secure feature ready to ship
```

[→ See more workflow examples](docs/WORKFLOWS.md)

## Philosophy

- **Specialists > Generalists**: Focused context beats knowing everything
- **Quality > Speed**: Verify before acting, review before committing
- **Security by Default**: Auth, validation, error handling built-in
- **Progressive Disclosure**: Load knowledge only when needed

## Roadmap

### ✅ Phase 1: Core Architecture (Complete)
- 6 specialized agents
- 18 skills with progressive disclosure
- CLI tool with auto-stack detection
- MCP-safe installation

### ✅ Phase 2: Skills & Polish (Complete)
- Stack skills (React, TypeScript, Docker, etc.)
- Domain skills (security, accessibility, performance)
- Comprehensive guides and templates

### ✅ Phase 3: Distribution (Complete)
- curl installation script
- Homebrew formula
- GitHub Actions releases
- Uninstall script

### 🔲 Phase 4: Community & Ecosystem
- Community skill marketplace
- VS Code extension
- Skill recommendations based on codebase
- Team conventions sync

## Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## Support

- 📖 [Full Documentation](docs/)
- 🐛 [Issue Tracker](https://github.com/dsantiagomj/dsmj-ai-toolkit/issues)
- 💬 [Discussions](https://github.com/dsantiagomj/dsmj-ai-toolkit/discussions)
- 🔒 [Security Policy](SECURITY.md)

## License

MIT License - see [LICENSE](LICENSE) file

## Credits

Built by [David Santiago M.](https://github.com/dsantiagomj)

Inspired by:
- [Agent Skills](https://agentskills.io) open standard
- [Prowler](https://github.com/prowler-cloud/prowler) skills-based architecture
- Vibe Coding principles for AI-directed development

---

**Built with Claude, for Claude** ✨
