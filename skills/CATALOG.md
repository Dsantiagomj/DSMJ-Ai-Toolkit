# Skills Catalog - Community Skills Reference

**161+ skills for Claude Code agents** (19 local + 142 community)

This catalog includes local stack-specific skills and organizes community skills from the [awesome-claude-skills](https://github.com/VoltAgent/awesome-claude-skills) ecosystem.

---

## How to Use This Catalog

### Skill Status

- **✅ Verified**: Tested with dsmj-ai-toolkit
- **⚠️ Untested**: Not yet tested, may work
- **📝 Reference**: Use as reference, create local version

### Installation

```bash
# Install from catalog (Phase 3 - coming soon)
dsmj-ai skills install <skill-name>

# Install from GitHub (manual)
cd .claude/skills/
git clone https://github.com/<org>/<skill-name>
```

---

## Local Skills (Pre-installed)

These skills are maintained locally and pre-installed in your toolkit. They focus on modern full-stack development patterns.

### Stack Skills

**API & Backend**:
- **trpc** - Type-safe APIs with tRPC (Context7: /websites/trpc_io)
  - End-to-end typesafe APIs without code generation
  - React Query integration, middleware, Zod validation
  - For: code-writer, planner

- **vercel-ai-sdk** - AI integration with Vercel AI SDK (Context7: /websites/ai-sdk_dev)
  - Streaming responses, function calling, structured outputs
  - React hooks (useChat, useCompletion, useAssistant)
  - For: code-writer, planner

**Frontend**:
- **react-hook-form** - Form management (Context7: /react-hook-form/documentation)
  - Performant forms with Zod validation
  - Field arrays, controlled components, shadcn integration
  - For: code-writer, qa

- **zustand** - State management (Context7: /websites/zustand_pmnd_rs)
  - Minimalist, fast state management
  - Middleware (persist, devtools, immer), TypeScript patterns
  - For: code-writer

- **radix-ui** - Headless UI components (Context7: /websites/radix-ui)
  - Accessible, unstyled primitives
  - Dialog, Dropdown, Select, Tabs, etc.
  - For: code-writer, qa

**Database & Infrastructure**:
- **prisma** - Prisma ORM (Context7: /websites/prisma_io)
  - Type-safe database access and migrations
  - PostgreSQL, MySQL, SQLite support
  - For: code-writer, planner

- **docker** - Containerization (Context7: /websites/docker)
  - Dockerfile and docker-compose patterns
  - Development and production workflows
  - For: code-writer, planner, devops

All local skills include Context7 references for up-to-date documentation.

### Domain Skills

**Security & Quality**:
- **security** - Security best practices and OWASP guidelines
  - Input validation, authentication, authorization patterns
  - SQL injection, XSS, CSRF prevention
  - For: code-writer, code-reviewer, planner

- **testing-frameworks** - Testing patterns and best practices
  - Unit, integration, e2e testing strategies
  - Mocking, fixtures, test organization
  - For: code-writer, qa

- **performance** - Performance optimization patterns
  - N+1 query prevention, caching strategies
  - Bundle optimization, lazy loading
  - For: code-writer, code-reviewer, planner

**Architecture & Design**:
- **api-design** - RESTful and GraphQL API design
  - Endpoint structure, versioning, pagination
  - Error handling, status codes
  - For: code-writer, planner

- **patterns** - Design patterns and architectural principles
  - SOLID, DRY, YAGNI principles
  - Common design patterns (Factory, Strategy, Observer)
  - For: code-writer, planner

- **database-migrations** - Database schema evolution
  - Migration strategies, rollback patterns
  - Zero-downtime migrations
  - For: code-writer, planner, devops

**User Experience**:
- **ui-ux** - UI/UX design principles and modern patterns
  - Visual hierarchy, component states, responsive design
  - Dark mode, design systems, microinteractions
  - Trending patterns (glassmorphism, bento grids, animations)
  - For: code-writer, qa, planner

- **accessibility** - WCAG compliance and a11y patterns
  - ARIA labels, keyboard navigation, screen readers
  - Color contrast, focus management
  - For: code-writer, qa

- **i18n** - Internationalization and localization
  - Translation management, RTL support
  - Locale handling, number/date formatting
  - For: code-writer, planner

### Meta Skills

**Toolkit Workflows**:
- **skill-creator** - Interactive skill creation guide
  - Step-by-step skill development workflow
  - Validation checklists, frontmatter templates
  - Decision frameworks for skill eligibility
  - For: All agents when creating new skills

- **context-monitor** - Context usage monitoring
  - Track context window usage
  - Optimize skill and agent loading
  - For: All agents

---

## Community Skills by Agent

### Code Writer (Implementation)

**General Development**:
- [getsentry/general](https://github.com/getsentry/general) - General development guidance
- [fvadicamo/dev-agent-skills](https://github.com/fvadicamo/dev-agent-skills) - Software development best practices
- [aaronsteers/software-dev](https://github.com/aaronsteers/software-dev) - Software engineering patterns

**Framework-Specific**:
- [anthropics/react](https://github.com/anthropics/react) - React development patterns ⭐ Official
- [getsentry/sentry-react](https://github.com/getsentry/sentry-react) - Sentry + React integration
- [alexrudall/ruby-on-rails](https://github.com/alexrudall/ruby-on-rails) - Rails development
- [pablodiaz/laravel](https://github.com/pablodiaz/laravel) - Laravel PHP framework
- [janpio/flutter](https://github.com/janpio/flutter) - Flutter mobile development
- [frostbite-software/drupal-php](https://github.com/frostbite-software/drupal-php) - Drupal CMS

**UI/UX**:
- [anthropics/tailwind-css](https://github.com/anthropics/tailwind-css) - Tailwind styling ⭐ Official
- [anthropics/shadcn](https://github.com/anthropics/shadcn) - shadcn/ui components ⭐ Official
- [ilyagru/react-aria](https://github.com/ilyagru/react-aria) - Adobe React Aria
- [NestorLiao/gsap](https://github.com/NestorLiao/gsap) - GSAP animations
- [BanditsGroup/react-three-fiber](https://github.com/BanditsGroup/react-three-fiber) - 3D with React

**Backend**:
- [anthropics/supabase](https://github.com/anthropics/supabase) - Supabase backend ⭐ Official
- [aaronsteers/postgres-development](https://github.com/aaronsteers/postgres-development) - PostgreSQL
- [aaronsteers/airbyte-connector-dev](https://github.com/aaronsteers/airbyte-connector-dev) - Airbyte connectors
- [getsentry/fastapi](https://github.com/getsentry/fastapi) - FastAPI Python
- [khaston10/appwrite-backend](https://github.com/khaston10/appwrite-backend) - Appwrite backend

**Mobile**:
- [janpio/expo](https://github.com/janpio/expo) - Expo React Native
- [lathama/ios-development](https://github.com/lathama/ios-development) - iOS Swift
- [kamileo242/kotlin-android-development](https://github.com/kamileo242/kotlin-android-development) - Android Kotlin
- [MobileAWS/swiftui](https://github.com/MobileAWS/swiftui) - SwiftUI

**Testing**:
- [anthropics/webapp-testing](https://github.com/anthropics/webapp-testing) - Web app testing ⭐ Official
- [obra/test-driven-development](https://github.com/obra/test-driven-development) - TDD practices
- [trailofbits/sharp-edges](https://github.com/trailofbits/sharp-edges) - Edge case testing

**Specialized**:
- [ilyagru/electron-vite-ts](https://github.com/ilyagru/electron-vite-ts) - Electron desktop apps
- [Gippsman/godot](https://github.com/Gippsman/godot) - Godot game engine
- [chuckwagoncomputing/kicad-parts](https://github.com/chuckwagoncomputing/kicad-parts) - KiCad PCB design
- [graysonarts/rust-development](https://github.com/graysonarts/rust-development) - Rust programming
- [aaronsteers/langchain-dev](https://github.com/aaronsteers/langchain-dev) - LangChain AI apps

---

### Code Reviewer (Quality & Security)

**Code Review**:
- [getsentry/code-review](https://github.com/getsentry/code-review) - Comprehensive code reviews
- [getsentry/lint](https://github.com/getsentry/lint) - Linting best practices
- [obra/testing-anti-patterns](https://github.com/obra/testing-anti-patterns) - What NOT to do
- [jworl99/security-auditor](https://github.com/jworl99/security-auditor) - Security audits

**Security**:
- [trailofbits/static-analysis](https://github.com/trailofbits/static-analysis) - Static analysis
- [SHADOWPR0/security-bluebook-builder](https://github.com/SHADOWPR0/security-bluebook-builder) - Security blueprints
- [jonathandturner/penetration-testing](https://github.com/jonathandturner/penetration-testing) - Pen testing
- [hacker1001101/hacking](https://github.com/hacker1001101/hacking) - Ethical hacking

**Performance**:
- [NestorLiao/web-performance](https://github.com/NestorLiao/web-performance) - Web optimization
- [aaronsteers/performance-testing](https://github.com/aaronsteers/performance-testing) - Load testing

---

### Planner (Architecture & Research)

**Software Architecture**:
- [getsentry/high-level-design](https://github.com/getsentry/high-level-design) - System design
- [fvadicamo/architectural-patterns](https://github.com/fvadicamo/architectural-patterns) - Architecture patterns
- [Lykon/software-architecture](https://github.com/Lykon/software-architecture) - Architecture principles

**Research & Analysis**:
- [Lykon/scientific-research](https://github.com/Lykon/scientific-research) - Research methods
- [ilyagru/competitive-programming](https://github.com/ilyagru/competitive-programming) - Algorithm design
- [work-leonid/mathematics](https://github.com/work-leonid/mathematics) - Mathematical foundations

**Documentation**:
- [getsentry/technical-writing](https://github.com/getsentry/technical-writing) - Tech writing
- [anthropics/c4-diagrams](https://github.com/anthropics/c4-diagrams) - Architecture diagrams ⭐ Official

---

### Git-Docs (Version Control & Documentation)

**Git Workflow**:
- [getsentry/commit](https://github.com/getsentry/commit) - Commit message standards
- [getsentry/create-pr](https://github.com/getsentry/create-pr) - Pull request creation
- [fvadicamo/dev-agent-skills](https://github.com/fvadicamo/dev-agent-skills) - Git workflows

**Documentation**:
- [getsentry/technical-writing](https://github.com/getsentry/technical-writing) - Writing docs
- [aaronsteers/markdown](https://github.com/aaronsteers/markdown) - Markdown formatting
- [anthropics/c4-diagrams](https://github.com/anthropics/c4-diagrams) - Diagrams ⭐ Official
- [lathama/graphviz](https://github.com/lathama/graphviz) - Graphviz diagrams
- [imalsky/scientific-plotting](https://github.com/imalsky/scientific-plotting) - Data visualization

---

### QA (Testing & Accessibility)

**Testing**:
- [anthropics/webapp-testing](https://github.com/anthropics/webapp-testing) - Web testing ⭐ Official
- [obra/test-driven-development](https://github.com/obra/test-driven-development) - TDD
- [obra/testing-anti-patterns](https://github.com/obra/testing-anti-patterns) - Anti-patterns
- [aaronsteers/performance-testing](https://github.com/aaronsteers/performance-testing) - Performance

**Accessibility**:
- [ilyagru/react-aria](https://github.com/ilyagru/react-aria) - ARIA patterns
- [anthropics/tailwind-css](https://github.com/anthropics/tailwind-css) - Accessible styling ⭐ Official

**Quality Assurance**:
- [getsentry/code-review](https://github.com/getsentry/code-review) - Code quality
- [jworl99/security-auditor](https://github.com/jworl99/security-auditor) - Security QA

---

### DevOps (Deployment & Operations)

**Cloud Platforms**:
- [vercel-labs/vercel-deploy-claimable](https://github.com/vercel-labs/vercel-deploy-claimable) - Vercel ⭐ Official
- [zxkane/aws-skills](https://github.com/zxkane/aws-skills) - AWS deployment
- [dmmulroy/cloudflare-skill](https://github.com/dmmulroy/cloudflare-skill) - Cloudflare
- [khaston10/appwrite-backend](https://github.com/khaston10/appwrite-backend) - Appwrite

**CI/CD**:
- [getsentry/github-actions](https://github.com/getsentry/github-actions) - GitHub Actions
- [fvadicamo/dev-agent-skills](https://github.com/fvadicamo/dev-agent-skills) - CI/CD patterns

**Infrastructure**:
- [chuckwagoncomputing/terraform](https://github.com/chuckwagoncomputing/terraform) - Terraform IaC
- [aaronsteers/docker-development](https://github.com/aaronsteers/docker-development) - Docker
- [joelklint/ansible](https://github.com/joelklint/ansible) - Ansible automation

**Monitoring**:
- [getsentry/sentry-react](https://github.com/getsentry/sentry-react) - Error tracking
- [NestorLiao/web-performance](https://github.com/NestorLiao/web-performance) - Performance monitoring

---

## Skills by Category

### Web Development

**Frontend Frameworks**:
- React: anthropics/react, getsentry/sentry-react ⭐
- Next.js: (use built-in stack/nextjs skill)
- Vue: (create local skill as needed)
- Angular: (create local skill as needed)

**Styling**:
- anthropics/tailwind-css ⭐
- anthropics/shadcn ⭐
- NestorLiao/gsap

**Backend**:
- anthropics/supabase ⭐
- getsentry/fastapi
- alexrudall/ruby-on-rails
- pablodiaz/laravel

### Mobile Development

- janpio/expo - Expo React Native
- janpio/flutter - Flutter
- lathama/ios-development - iOS Swift
- MobileAWS/swiftui - SwiftUI
- kamileo242/kotlin-android-development - Android Kotlin

### Databases

- aaronsteers/postgres-development - PostgreSQL
- anthropics/supabase - Supabase (Postgres + Auth) ⭐
- (MongoDB - create local skill)
- (Redis - create local skill)

### Testing

- anthropics/webapp-testing ⭐
- obra/test-driven-development
- obra/testing-anti-patterns
- trailofbits/sharp-edges
- aaronsteers/performance-testing

### DevOps & Cloud

**Platforms**:
- vercel-labs/vercel-deploy-claimable ⭐
- zxkane/aws-skills
- dmmulroy/cloudflare-skill

**Tools**:
- getsentry/github-actions
- chuckwagoncomputing/terraform
- aaronsteers/docker-development
- joelklint/ansible

### Security

- trailofbits/static-analysis
- trailofbits/sharp-edges
- SHADOWPR0/security-bluebook-builder
- jworl99/security-auditor
- jonathandturner/penetration-testing

### AI & Machine Learning

- aaronsteers/langchain-dev - LangChain apps
- aaronsteers/airbyte-connector-dev - Data connectors
- (ML frameworks - create local skills)

### Gaming & Graphics

- Gippsman/godot - Godot engine
- BanditsGroup/react-three-fiber - 3D React
- NestorLiao/gsap - Animations

### Specialized

- chuckwagoncomputing/kicad-parts - PCB design
- ilyagru/electron-vite-ts - Desktop apps
- lathama/graphviz - Diagrams
- imalsky/scientific-plotting - Scientific viz

---

## Installation Guide

### Prerequisites

```bash
# Ensure dsmj-ai-toolkit is initialized
dsmj-ai init
```

### Method 1: Manual Installation (Current)

```bash
# Navigate to skills directory
cd .claude/skills/

# Clone community skill
git clone https://github.com/<org>/<skill-name>

# Example: Install Sentry code review skill
git clone https://github.com/getsentry/code-review
```

### Method 2: CLI Installation (Phase 3 - Coming Soon)

```bash
# List available skills
dsmj-ai skills list

# Search for skill
dsmj-ai skills search react

# Install skill
dsmj-ai skills install anthropics/react

# Install multiple skills
dsmj-ai skills install anthropics/react anthropics/tailwind-css

# Uninstall skill
dsmj-ai skills uninstall anthropics/react
```

---

## Creating Custom Skills

Want to create your own skill? See:
- [skills/TEMPLATE.md](./TEMPLATE.md) - Skill template
- [skills/GUIDE.md](./GUIDE.md) - Creation guide
- [skills/examples/](./examples/) - Example skills

---

## Compatibility Matrix

### ✅ Verified Compatible

These skills have been tested with dsmj-ai-toolkit:
- anthropics/* (all official Anthropic skills)
- getsentry/* (Sentry maintained skills)
- vercel-labs/* (Vercel maintained skills)

### ⚠️ Untested

Most community skills are untested but should work with minor adjustments.

### 📝 Use as Reference

Some skills are better used as references to create your own local version:
- Framework-specific skills that need customization
- Company-specific workflows
- Proprietary patterns

---

## Contributing Skills

Want to add your skill to this catalog?

1. Create skill following [TEMPLATE.md](./TEMPLATE.md)
2. Test with dsmj-ai-toolkit agents
3. Submit PR to awesome-claude-skills
4. Update this catalog

---

## Skill Statistics

**Total Skills**: 142+
**Official Anthropic**: 7 (marked with ⭐)
**Categories**: 15
**Agents Covered**: All 6

**Most Popular Categories**:
1. Web Development (40+ skills)
2. Testing & QA (15+ skills)
3. DevOps & Cloud (12+ skills)
4. Security (10+ skills)
5. Mobile Development (8+ skills)

---

## Resources

- [awesome-claude-skills](https://github.com/VoltAgent/awesome-claude-skills) - Full community list
- [Agent Skills Standard](https://agentskills.io) - Skill format specification
- [Claude Code Docs](https://docs.anthropic.com/claude/docs/claude-code) - Official docs

---

_Last updated: 2026-01-15_
_Maintained by dsmj-ai-toolkit_
