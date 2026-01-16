# Skills System Plan: Hybrid + Lazy Installation

**Combined Approach 3 + 5**: Core local skills + curated external catalog with CLI installation

---

## Architecture Overview

### Two-Tier Skills System

```
┌─────────────────────────────────────────────────────────┐
│                    SKILLS ECOSYSTEM                      │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  TIER 1: CORE SKILLS (Local, Auto-Installed)           │
│  ├── Domain Skills (7)                                  │
│  │   ├── patterns           (all agents)                │
│  │   ├── testing-frameworks (code-reviewer, qa)         │
│  │   ├── api-design        (planner, code-writer)       │
│  │   ├── accessibility     (qa)                         │
│  │   ├── performance       (code-reviewer)              │
│  │   ├── database-migrations (planner, devops)          │
│  │   └── i18n              (qa)                         │
│  │                                                       │
│  ├── Stack Skills (3 - already created)                 │
│  │   ├── react-19                                       │
│  │   ├── nextjs-15                                      │
│  │   └── python-312                                     │
│  │                                                       │
│  └── Meta Skills (1)                                    │
│      └── context-monitor                                │
│                                                          │
│  TIER 2: COMMUNITY SKILLS (External, Opt-In)           │
│  ├── Documented in SKILLS_CATALOG.md                   │
│  ├── Installed via CLI: dsmj-ai skills install <name>  │
│  ├── References awesome-claude-skills                   │
│  └── Curated, categorized, compatibility-noted          │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

## Core Skills to Create (Priority)

### Priority 1: Critical (Agents depend on these)

#### 1. patterns (Domain)
**Location**: `skills/domain/patterns/SKILL.md`
**Why**: All agents reference design patterns
**Covers**:
- SOLID principles (Single Responsibility, Open/Closed, Liskov, Interface Segregation, Dependency Inversion)
- DRY, KISS, YAGNI
- Common design patterns (Factory, Observer, Strategy, Decorator, Singleton)
- Anti-patterns (God Object, Spaghetti Code, Copy-Paste)
- Code smells (Long Method, Large Class, Feature Envy)

**Referenced by**: All agents (especially planner, code-writer, code-reviewer)
**Lines**: ~450 lines main + references/

**Reference sources to find**:
- Refactoring Guru patterns
- Clean Code principles
- Gang of Four patterns adapted to modern JS/Python

---

#### 2. testing-frameworks (Domain)
**Location**: `skills/domain/testing-frameworks/SKILL.md`
**Why**: code-reviewer runs tests, qa needs testing knowledge
**Covers**:
- Jest (JavaScript/TypeScript): describe, test, expect, mocking
- Vitest (Vite-based): similar to Jest but faster
- Pytest (Python): fixtures, parametrize, markers, plugins
- Testing patterns: AAA (Arrange-Act-Assert), Given-When-Then
- Mocking strategies: mocks vs stubs vs spies
- Test organization: unit, integration, e2e
- Coverage tools: c8, nyc, coverage.py

**Referenced by**: code-reviewer, qa
**Lines**: ~500 lines (already have example at skills/examples/domain-skill.md)

**Reference sources to find**:
- Jest/Vitest official docs
- Pytest documentation
- Testing best practices guides

---

#### 3. api-design (Domain)
**Location**: `skills/domain/api-design/SKILL.md`
**Why**: planner needs for API planning, code-writer for implementation
**Covers**:
- **REST**: Resources, HTTP methods, status codes, HATEOAS
- **GraphQL**: Schema design, queries, mutations, subscriptions, N+1 problem
- **API Versioning**: URL (/v1/), header, media type
- **Pagination**: Offset, cursor, keyset
- **Error handling**: Error response format, error codes
- **Authentication**: JWT, OAuth2, API keys
- **Rate limiting**: Token bucket, sliding window
- **Documentation**: OpenAPI/Swagger, GraphQL introspection

**Referenced by**: planner, code-writer, code-reviewer
**Lines**: ~500 lines main + references/

**Reference sources to find**:
- REST API Design Rulebook
- GraphQL best practices
- OpenAPI specification

---

### Priority 2: Important (Enhance agent capabilities)

#### 4. accessibility (Domain)
**Location**: `skills/domain/accessibility/SKILL.md`
**Why**: qa agent checks WCAG compliance
**Covers**:
- **WCAG levels**: A (minimum), AA (target), AAA (enhanced)
- **Keyboard navigation**: Tab order, focus management, skip links
- **Screen readers**: ARIA labels, roles, states, live regions
- **Visual**: Color contrast (4.5:1 text, 3:1 UI), text resize, focus indicators
- **Semantic HTML**: Headings hierarchy, landmarks, forms
- **Testing tools**: axe, WAVE, Lighthouse, NVDA, VoiceOver
- **Common issues**: Missing alt text, poor contrast, keyboard traps, unlabeled forms

**Referenced by**: qa, code-writer
**Lines**: ~450 lines main + references/

**Reference sources to find**:
- WCAG 2.1 guidelines
- A11y Project resources
- WebAIM guides

---

#### 5. performance (Domain)
**Location**: `skills/domain/performance/SKILL.md`
**Why**: code-reviewer checks for performance issues
**Covers**:
- **Frontend**: Code splitting, lazy loading, tree shaking, bundle analysis
- **Images**: Responsive images, WebP/AVIF, lazy loading, CDN
- **Caching**: Browser cache, service workers, CDN, Redis
- **Database**: Query optimization, indexes, N+1 prevention, connection pooling
- **Core Web Vitals**: LCP, FID, CLS
- **Metrics**: TTFB, FCP, TTI
- **Tools**: Lighthouse, WebPageTest, Chrome DevTools

**Referenced by**: code-reviewer, code-writer
**Lines**: ~450 lines main + references/

**Reference sources to find**:
- Web.dev performance guides
- Next.js optimization docs
- Database indexing guides

---

#### 6. database-migrations (Domain)
**Location**: `skills/domain/database-migrations/SKILL.md`
**Why**: planner plans schema changes, devops deploys them safely
**Covers**:
- **Prisma**: prisma migrate dev/deploy, schema.prisma syntax
- **TypeORM**: migrations generate/run, entities
- **Alembic** (Python): autogenerate, upgrade/downgrade
- **Backward compatibility**: Additive changes, multi-step migrations
- **Strategies**: Blue-green migrations, online schema changes
- **Safety**: Backups, rollback plans, testing in staging
- **Common patterns**: Add nullable column → backfill → make non-null

**Referenced by**: planner, devops
**Lines**: ~400 lines main + references/

**Reference sources to find**:
- Prisma migration docs
- TypeORM migration guide
- Database migration best practices

---

#### 7. i18n (Domain)
**Location**: `skills/domain/i18n/SKILL.md`
**Why**: qa verifies internationalization
**Covers**:
- **React**: react-i18next, next-intl, FormatJS
- **Translation files**: JSON, YAML, gettext (.po)
- **Pluralization**: Different rules per language (en: 2 forms, ar: 6 forms)
- **Date/time**: Intl.DateTimeFormat, date-fns, day.js with locales
- **Numbers**: Intl.NumberFormat, currency, units
- **RTL support**: Arabic, Hebrew layout
- **String extraction**: i18next-parser, formatjs extract
- **Testing**: Verify translations loaded, layout doesn't break

**Referenced by**: qa, code-writer
**Lines**: ~400 lines main + references/

**Reference sources to find**:
- react-i18next docs
- next-intl documentation
- i18n best practices

---

## Skills Catalog Structure

### SKILLS_CATALOG.md Format

```markdown
# Skills Catalog

Community skills from awesome-claude-skills and other sources.

## How to Use

**Install a skill**:
```bash
dsmj-ai skills install <skill-name>
```

**List installed skills**:
```bash
dsmj-ai skills list
```

**Search for skills**:
```bash
dsmj-ai skills search <keyword>
```

---

## Skills by Agent

### For code-reviewer

#### getsentry/code-review
- **Category**: Development
- **What it does**: Perform comprehensive code reviews
- **Install**: `dsmj-ai skills install getsentry/code-review`
- **Compatibility**: ✅ Works with dsmj-ai-toolkit
- **Source**: https://github.com/getsentry/...

#### trailofbits/differential-review
- **Category**: Security
- **What it does**: Security-focused diff review with git history analysis
- **Install**: `dsmj-ai skills install trailofbits/differential-review`
- **Compatibility**: ✅ Works with dsmj-ai-toolkit
- **Source**: https://github.com/trailofbits/...

[Continue for all skills...]

---

## Skills by Category

### Testing & QA
- anthropics/webapp-testing
- obra/test-driven-development
- obra/testing-anti-patterns

### Git & Version Control
- getsentry/commit
- getsentry/create-pr
- fvadicamo/dev-agent-skills

### Security
- trailofbits/static-analysis
- trailofbits/sharp-edges
- SHADOWPR0/security-bluebook-builder

### Deployment
- vercel-labs/vercel-deploy-claimable
- zxkane/aws-skills
- dmmulroy/cloudflare-skill

[Continue...]

---

## Installing Custom Skills

### From GitHub
```bash
dsmj-ai skills install https://github.com/username/skill-name
```

### From Local Directory
```bash
dsmj-ai skills install ./path/to/skill
```

---

## Compatibility Notes

**✅ Fully Compatible**: Tested with dsmj-ai-toolkit agents
**⚠️ Partial**: May require additional setup
**❌ Incompatible**: Known issues with our toolkit
```

---

## CLI Commands Design

### New Commands in bin/dsmj-ai

```bash
# List available skills (from catalog)
dsmj-ai skills list [--installed]

# Search skills by keyword
dsmj-ai skills search <keyword>

# Show skill details
dsmj-ai skills info <skill-name>

# Install skill from catalog
dsmj-ai skills install <skill-name>

# Install skill from URL
dsmj-ai skills install <github-url>

# Uninstall skill
dsmj-ai skills uninstall <skill-name>

# Update all installed skills
dsmj-ai skills update [skill-name]
```

### Implementation Details

**Skills database**: `.dsmj-ai/skills-catalog.json`
```json
{
  "skills": [
    {
      "name": "getsentry/code-review",
      "category": "development",
      "description": "Perform comprehensive code reviews",
      "source": "https://github.com/getsentry/...",
      "compatibility": "full",
      "agents": ["code-reviewer"],
      "installed": false,
      "version": "1.0.0"
    }
  ]
}
```

**Installation flow**:
1. User runs `dsmj-ai skills install getsentry/code-review`
2. CLI looks up skill in catalog
3. Downloads skill from GitHub (or clones repo)
4. Extracts to `.claude/skills/`
5. Creates symlink if needed
6. Updates catalog with `installed: true`
7. Shows success message

---

## Implementation Phases

### Phase 1: Core Skills (Week 1)
**Goal**: Agents work out-of-box

**Tasks**:
1. Create 7 core domain skills
2. Update agents to reference core skills
3. Test all agent workflows
4. Update README with skills documentation

**Deliverable**: v1.0 with working toolkit

---

### Phase 2: Skills Catalog (Week 2)
**Goal**: Document ecosystem

**Tasks**:
1. Create SKILLS_CATALOG.md
2. Organize awesome-claude-skills by agent
3. Add compatibility notes
4. Add installation instructions
5. Create .dsmj-ai/skills-catalog.json database

**Deliverable**: v1.1 with catalog

---

### Phase 3: CLI Installation (Week 3)
**Goal**: Easy skill installation

**Tasks**:
1. Implement `dsmj-ai skills list`
2. Implement `dsmj-ai skills search`
3. Implement `dsmj-ai skills install`
4. Implement `dsmj-ai skills uninstall`
5. Add progress indicators, error handling
6. Test installation flow

**Deliverable**: v1.2 with lazy installation

---

## File Structure

```
dsmj-ai-toolkit/
├── skills/
│   ├── TEMPLATE.md
│   ├── GUIDE.md
│   ├── CATALOG.md                    # NEW: Community skills catalog
│   ├── domain/
│   │   ├── patterns/                 # NEW: Design patterns
│   │   │   ├── SKILL.md
│   │   │   └── references/
│   │   ├── testing-frameworks/       # NEW
│   │   │   ├── SKILL.md
│   │   │   └── references/
│   │   ├── api-design/               # NEW
│   │   │   ├── SKILL.md
│   │   │   └── references/
│   │   ├── accessibility/            # NEW
│   │   │   ├── SKILL.md
│   │   │   └── references/
│   │   ├── performance/              # NEW
│   │   │   ├── SKILL.md
│   │   │   └── references/
│   │   ├── database-migrations/      # NEW
│   │   │   ├── SKILL.md
│   │   │   └── references/
│   │   ├── i18n/                     # NEW
│   │   │   ├── SKILL.md
│   │   │   └── references/
│   │   └── security/                 # EXISTING
│   ├── stack/
│   │   ├── react-19/                 # EXISTING
│   │   ├── nextjs-15/                # EXISTING
│   │   └── python-312/               # EXISTING
│   └── meta/
│       └── context-monitor/          # EXISTING
├── .dsmj-ai/
│   └── skills-catalog.json           # NEW: Skills database
└── bin/
    └── dsmj-ai                        # UPDATE: Add skills commands
```

---

## User Workflows

### Workflow 1: New User (Out-of-Box)

```bash
# Install toolkit
git clone https://github.com/dsantiagomj/dsmj-ai-toolkit.git
cd dsmj-ai-toolkit
./bin/dsmj-ai install

# Initialize project
cd ~/my-project
dsmj-ai init

# Start using - all core skills auto-installed ✅
claude-code
```

**Skills available**:
- ✅ patterns (all agents use)
- ✅ testing-frameworks (code-reviewer, qa)
- ✅ api-design (planner, code-writer)
- ✅ accessibility (qa)
- ✅ performance (code-reviewer)
- ✅ database-migrations (planner, devops)
- ✅ i18n (qa)
- ✅ react-19, nextjs-15, python-312 (stack)
- ✅ security (domain)
- ✅ context-monitor (meta)

**Total**: 11 skills working immediately

---

### Workflow 2: User Wants Advanced Code Review

```bash
# Search for code review skills
dsmj-ai skills search "code review"

# Output:
# Found 3 skills:
# 1. getsentry/code-review - Comprehensive code reviews
# 2. trailofbits/differential-review - Security-focused reviews
# 3. trailofbits/static-analysis - CodeQL, Semgrep, SARIF

# Install specific skill
dsmj-ai skills install getsentry/code-review

# Output:
# ✓ Downloading getsentry/code-review...
# ✓ Installing to .claude/skills/
# ✓ Skill installed successfully
#
# Now available to code-reviewer agent!

# Use in Claude Code
claude-code
# code-reviewer agent now has access to getsentry/code-review patterns
```

---

### Workflow 3: User Wants Deployment Skills

```bash
# Browse catalog
dsmj-ai skills list

# Install Vercel deployment
dsmj-ai skills install vercel-labs/vercel-deploy-claimable

# Install AWS patterns
dsmj-ai skills install zxkane/aws-skills

# Check installed
dsmj-ai skills list --installed

# Output:
# Core Skills (11):
#   ✓ patterns
#   ✓ testing-frameworks
#   ... [all core skills]
#
# Community Skills (2):
#   ✓ vercel-labs/vercel-deploy-claimable
#   ✓ zxkane/aws-skills
```

---

## Documentation Strategy

### README.md Updates

Add section after "Skills":

```markdown
### Skills (11 Core + Community Ecosystem)

**Core Skills** (Included by default):

**Domain Skills**:
- `patterns`: SOLID, DRY, design patterns, anti-patterns
- `testing-frameworks`: Jest, Vitest, Pytest patterns
- `api-design`: REST, GraphQL, versioning, pagination
- `accessibility`: WCAG AA/AAA compliance
- `performance`: Optimization, caching, Core Web Vitals
- `database-migrations`: Prisma, TypeORM, Alembic
- `i18n`: Internationalization and localization
- `security`: OWASP Top 10, auth patterns

**Stack Skills**:
- `react-19`: React 19 with Server Components
- `nextjs-15`: Next.js 15 App Router patterns
- `python-312`: Python 3.12 best practices

**Meta Skills**:
- `context-monitor`: Context management

**Community Skills** (Optional, install via CLI):

Browse the [Skills Catalog](skills/CATALOG.md) for 142+ community skills.

```bash
# Install community skills
dsmj-ai skills search <keyword>
dsmj-ai skills install <skill-name>
```

See [Skills Catalog](skills/CATALOG.md) for complete list.
```

---

## Benefits of This Approach

### ✅ For Users
1. **Works immediately**: 11 core skills out-of-box
2. **Extensible**: 142+ community skills available
3. **Discoverable**: CLI search/browse
4. **Low friction**: One command to install
5. **Offline-capable**: Core works offline
6. **Progressive**: Start simple, add as needed

### ✅ For Maintainers
1. **Focused**: Maintain 7 core skills well
2. **Scalable**: Community maintains external skills
3. **Clear boundaries**: Core vs community
4. **Lower burden**: Don't maintain everything
5. **Flexible**: Easy to add/remove catalog entries

### ✅ For Ecosystem
1. **Compatibility layer**: Catalog provides compatibility info
2. **Discovery**: awesome-claude-skills gets more visibility
3. **Quality signal**: Curated catalog implies vetting
4. **Contribution path**: Community can submit catalog entries

---

## Success Metrics

### Phase 1 (Core Skills)
- ✅ All 6 agents have satisfied skill references
- ✅ No broken skill links in agents
- ✅ Skills follow progressive disclosure (<500 lines main)
- ✅ Test coverage for skill references

### Phase 2 (Catalog)
- ✅ 50+ community skills documented
- ✅ Organized by agent (6 sections)
- ✅ Compatibility notes for each skill
- ✅ Installation instructions clear

### Phase 3 (CLI)
- ✅ `skills list` shows catalog
- ✅ `skills search` finds skills by keyword
- ✅ `skills install` works for GitHub URLs
- ✅ Error handling (network issues, invalid URLs)

---

## Next Steps

1. **Approve plan** ✓ (waiting for user)
2. **Find references** for each core skill
3. **Create core skills** (7 skills, ~3,500 lines)
4. **Update agents** to reference core skills
5. **Create catalog** (SKILLS_CATALOG.md)
6. **Build CLI** (skills commands)
7. **Document** (README, guides)
8. **Test** (integration testing)
9. **Release v1.0** 🚀

---

Ready to proceed with finding references for the 7 core skills?
