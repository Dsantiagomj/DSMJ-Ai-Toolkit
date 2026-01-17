# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-01-16

### Added

#### Core Features
- Complete AI toolkit for Claude Code with specialist-first architecture
- 6 specialized agents: code-writer, code-reviewer, planner, qa, git-docs, devops
- 18 skills across stack/domain/meta categories
- Symlink-based global installation with per-project configurations
- Auto-stack detection for intelligent skill loading
- Progressive disclosure pattern for efficient context management

#### Agents
- **code-writer**: Implementation specialist with focused coding context
- **code-reviewer**: Quality assurance with security checks and automated testing
- **planner**: Requirements gathering and architecture decisions
- **qa**: Functional QA, UAT, accessibility, and i18n testing
- **git-docs**: Git workflows, commits, PRs, and documentation
- **devops**: CI/CD, monitoring, publishing, and SRE operations

#### Stack Skills (9)
- React 19 with Server Components and modern patterns
- TypeScript for fullstack type-safe development
- Docker containerization and deployment
- Prisma ORM for type-safe database access
- tRPC for end-to-end typesafe APIs
- Radix UI for accessible headless components
- React Hook Form for performant form management
- Zustand for minimalist state management
- Vercel AI SDK for AI-powered applications

#### Domain Skills (8)
- Security: OWASP Top 10, auth patterns, secure coding
- Accessibility: WCAG compliance, ARIA patterns
- API Design: RESTful and GraphQL best practices
- Database Migrations: Schema versioning and rollbacks
- i18n: Internationalization and localization
- Design Patterns: Architectural patterns and best practices
- Performance: Web optimization and Core Web Vitals
- Testing Frameworks: Jest, Vitest, Playwright strategies

#### Meta Skills (1)
- Context Monitor: Detects conversation drift and maintains focus

#### CLI Tool
- `dsmj-ai install`: Global installation to ~/.dsmj-ai-toolkit
- `dsmj-ai init`: Initialize project with auto-stack detection
- `dsmj-ai status`: Show installation and project status
- `dsmj-ai version`: Display toolkit version
- Complete bash CLI with symlink management

#### Distribution
- One-command curl installation script
- Homebrew formula for `brew install`
- GitHub Actions automated releases
- Uninstall script for clean removal
- MCP-safe installation (preserves existing configs)

#### Documentation
- Comprehensive README with quick start guide
- Agent creation guide with templates and examples
- Skill creation guide with templates and examples
- Architecture documentation
- MCP safety documentation
- Skills planning documentation

#### Features
- CLAUDE.md template with Prompt DNA system
- Maestro Mode for casual communication style
- Quality gates workflow (Frame → Scope → Generate → Review → Verify)
- Skills catalog with community and official skills
- Progressive disclosure for efficient context usage
- Vibe Coding principles integration

### Changed
- N/A (Initial release)

### Deprecated
- N/A (Initial release)

### Removed
- N/A (Initial release)

### Fixed
- N/A (Initial release)

### Security
- Built-in security best practices in all agents
- Security skill with OWASP Top 10 patterns
- MCP-safe installation preserves user configurations
- No credential storage or sensitive data collection

---

## Release Notes

### v1.0.0 - Initial Public Release

This is the first stable release of dsmj-ai-toolkit, a production-quality AI toolkit for Claude Code.

**Installation:**
```bash
# Quick install
curl -fsSL https://raw.githubusercontent.com/dsantiagomj/dsmj-ai-toolkit/main/install.sh | bash

# Or via Homebrew
brew install dsantiagomj/dsmj-ai-toolkit/dsmj-ai-toolkit
```

**Key Highlights:**
- 🎯 Specialist-first architecture for better context and quality
- 🧩 18 modular skills following Agent Skills open standard
- 🔄 Auto-stack detection for intelligent configuration
- 🔗 Symlink-based updates (update once, all projects benefit)
- 📋 Quality gates integrated (review, test, verify)
- 🛡️ Security-first with OWASP patterns built-in

**Getting Started:**
```bash
# Initialize in your project
cd my-project
dsmj-ai init

# Start Claude Code
claude-code
```

For full documentation, see [README.md](README.md).

---

[1.0.0]: https://github.com/dsantiagomj/dsmj-ai-toolkit/releases/tag/v1.0.0
