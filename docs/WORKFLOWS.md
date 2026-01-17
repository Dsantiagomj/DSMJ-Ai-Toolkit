# Workflow Examples

This guide shows real-world workflows using dsmj-ai-toolkit agents for different development scenarios.

## Table of Contents

- [The Vibe Loop](#the-vibe-loop)
- [Complete Feature Implementation](#complete-feature-implementation)
- [Quick Bug Fix](#quick-bug-fix)
- [Code Review Workflow](#code-review-workflow)
- [Planning New Architecture](#planning-new-architecture)
- [QA Testing Workflow](#qa-testing-workflow)
- [DevOps Deployment](#devops-deployment)
- [Git and Documentation](#git-and-documentation)

## The Vibe Loop

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

## Complete Feature Implementation

### Scenario: Add User Profile Editing with Accessibility Support

```
User: "Add user profile editing with accessibility support"

─────────────────────────────────────────────────────────────
PHASE 1: PLANNING
─────────────────────────────────────────────────────────────

Main Claude (Orchestrator):
  1. Analyzes request
  2. Spawns planner for requirements and planning

planner:
  1. Gathers requirements (acceptance criteria, edge cases)
  2. Explores codebase for existing patterns
  3. References relevant skills:
     - react (for component patterns)
     - accessibility (for WCAG compliance)
     - security (for input validation)
  4. Creates implementation plan with task breakdown:
     ✓ Create ProfileEditForm component
     ✓ Add API endpoint for profile updates
     ✓ Implement validation with react-hook-form + zod
     ✓ Add accessibility features (ARIA, keyboard nav)
     ✓ Write unit and E2E tests
  5. Returns structured plan

Main Claude:
  1. Reviews plan with user, gets approval
  2. Spawns code-writer for implementation

─────────────────────────────────────────────────────────────
PHASE 2: IMPLEMENTATION
─────────────────────────────────────────────────────────────

code-writer:
  1. References skills:
     - react (for hooks and component patterns)
     - react-hook-form (for form management)
     - accessibility (for ARIA patterns)
     - security (for input validation)
  2. Implements:
     - ProfileEditForm.tsx (form component)
     - /app/api/profile/route.ts (API endpoint)
     - Validation schema with Zod
     - Accessible form controls
  3. Returns summary with file references:
     - components/ProfileEditForm.tsx:1
     - app/api/profile/route.ts:1
     - lib/validations/profile.ts:1

Main Claude:
  1. Spawns code-reviewer for quality check

─────────────────────────────────────────────────────────────
PHASE 3: CODE REVIEW
─────────────────────────────────────────────────────────────

code-reviewer:
  1. Reviews code quality and security
  2. Runs automated tests (unit, integration)
  3. Checks against best practices:
     ✓ Input validation present
     ✓ ARIA labels correct
     ✓ Error handling implemented
     ✓ Tests cover edge cases
  4. Returns review report:
     - Security: ✓ Pass
     - Patterns: ✓ Pass
     - Test Coverage: 85% (✓ Pass)
     - Accessibility: ⚠️ Missing focus management

Main Claude:
  1. Spawns code-writer to fix accessibility issue
  2. Once fixed, spawns qa for acceptance testing

─────────────────────────────────────────────────────────────
PHASE 4: QA TESTING
─────────────────────────────────────────────────────────────

qa:
  1. Tests user flows:
     ✓ User can edit profile
     ✓ Changes save correctly
     ✓ Validation shows errors
  2. Checks accessibility (WCAG, keyboard nav, screen readers):
     ✓ Keyboard navigation works
     ✓ Screen reader announces errors
     ✓ Focus management correct
  3. Tests edge cases:
     ✓ Empty states handled
     ✓ Long text truncated properly
     ✓ Network errors shown to user
  4. Returns QA report: All checks pass ✓

Main Claude:
  1. All approvals received, spawns git-docs for commit

─────────────────────────────────────────────────────────────
PHASE 5: COMMIT & DOCUMENTATION
─────────────────────────────────────────────────────────────

git-docs:
  1. Creates conventional commit:
     feat(profile): add user profile editing with accessibility

     - Implement ProfileEditForm with react-hook-form
     - Add API endpoint with Zod validation
     - Ensure WCAG AA compliance
     - Add E2E tests for critical flows

  2. Updates API documentation
  3. Updates CHANGELOG.md
  4. (Optional) Creates PR if requested

─────────────────────────────────────────────────────────────
RESULT
─────────────────────────────────────────────────────────────

✓ Complete feature implemented
✓ Code reviewed and tested
✓ Accessibility validated
✓ Documentation updated
✓ Ready for merge
```

## Quick Bug Fix

### Scenario: Fix Password Validation Bug

```
User: "Fix the password validation bug"

─────────────────────────────────────────────────────────────
Main Claude:
  1. Spawns code-writer for quick fix

code-writer:
  1. Investigates issue:
     - Reads lib/validations/auth.ts:42
     - Identifies regex error in password validation
  2. References security skill for password requirements
  3. Fixes validation logic:
     OLD: /^(?=.*[a-z])(?=.*[A-Z]).{6,}$/
     NEW: /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$/
  4. Returns summary:
     - Fixed: lib/validations/auth.ts:42
     - Added: number requirement, increased min length

Main Claude:
  1. Spawns code-reviewer for verification

code-reviewer:
  1. Reviews fix:
     ✓ Follows security best practices
     ✓ Regex tested with edge cases
  2. Runs tests:
     ✓ All auth tests pass
     ✓ No regressions detected
  3. Confirms fix is safe

Main Claude:
  1. Spawns git-docs for commit

git-docs:
  1. Creates commit:
     fix(auth): strengthen password validation requirements

     - Require at least one number
     - Increase minimum length from 6 to 8 characters
     - Update validation error messages

─────────────────────────────────────────────────────────────
RESULT
─────────────────────────────────────────────────────────────

✓ Bug fixed
✓ Tests verified
✓ Committed
```

## Code Review Workflow

### Scenario: Review Pull Request Before Merge

```
User: "Review PR #42 - new authentication flow"

─────────────────────────────────────────────────────────────
Main Claude:
  1. Spawns code-reviewer for comprehensive review

code-reviewer:
  1. Fetches PR diff (git-docs can assist)
  2. Analyzes changes:
     - 8 files changed
     - 342 additions, 127 deletions

  3. Reviews code quality:
     ✓ Code follows project conventions
     ✓ TypeScript types are strict
     ⚠️ One function has high complexity (15)

  4. Security audit (references security skill):
     ✓ Passwords hashed with bcrypt
     ✓ JWT tokens properly signed
     ⚠️ Missing rate limiting on login endpoint
     ✗ Session tokens stored in localStorage (use httpOnly cookies)

  5. Runs automated tests:
     ✓ Unit tests: 47/47 pass
     ✓ Integration tests: 12/12 pass
     ⚠️ Coverage dropped from 87% to 82%

  6. Returns detailed review:

     BLOCKERS (must fix):
     - Move session storage from localStorage to httpOnly cookies

     HIGH PRIORITY:
     - Add rate limiting to /api/auth/login
     - Reduce complexity in validateCredentials()
     - Add missing test coverage

     SUGGESTIONS:
     - Consider using refresh tokens
     - Add logging for failed login attempts

Main Claude:
  1. Shares review with user
  2. User acknowledges fixes needed
  3. Spawns code-writer to fix blockers

code-writer:
  1. Implements fixes:
     - Switches to httpOnly cookies
     - Adds rate limiting middleware
     - Refactors complex function
     - Adds missing tests
  2. Returns updated changes

Main Claude:
  1. Spawns code-reviewer again for re-review

code-reviewer:
  1. Re-reviews changes:
     ✓ All blockers resolved
     ✓ Security issues fixed
     ✓ Test coverage back to 87%
  2. Approves PR ✓

─────────────────────────────────────────────────────────────
RESULT
─────────────────────────────────────────────────────────────

✓ PR reviewed comprehensively
✓ Security issues caught and fixed
✓ Code quality maintained
✓ Ready to merge
```

## Planning New Architecture

### Scenario: Plan Microservices Migration

```
User: "We need to split our monolith into microservices for the payment system"

─────────────────────────────────────────────────────────────
Main Claude:
  1. Spawns planner for architecture design

planner:
  1. Analyzes current architecture:
     - Reads codebase structure
     - Identifies payment-related code
     - Maps dependencies

  2. References relevant skills:
     - api-design (for service boundaries)
     - patterns (for microservice patterns)
     - database-migrations (for data separation)
     - docker (for containerization)

  3. Designs migration plan:

     PROPOSED ARCHITECTURE:

     Payment Service:
     - Handles: Stripe integration, payment processing, refunds
     - API: REST endpoints + webhooks
     - Database: Dedicated PostgreSQL (payments, transactions)
     - Tech: Node.js + Express + Prisma

     Communication:
     - Sync: REST API for order creation
     - Async: RabbitMQ for payment events
     - Auth: Shared JWT validation

     MIGRATION PHASES:

     Phase 1: Create new service (2 weeks)
     - Set up payment service repo
     - Implement core payment API
     - Set up database and migrations
     - Containerize with Docker

     Phase 2: Dual-write period (1 week)
     - Write to both old and new systems
     - Validate data consistency
     - Monitor for issues

     Phase 3: Read migration (1 week)
     - Switch reads to new service
     - Keep writes dual
     - Performance testing

     Phase 4: Full cutover (3 days)
     - Switch all traffic to new service
     - Decommission old code
     - Update documentation

     RISKS & MITIGATION:
     - Data consistency → Implement transaction outbox pattern
     - Service downtime → Blue-green deployment
     - Breaking changes → Versioned APIs

  4. Returns comprehensive plan with:
     - Architecture diagrams
     - File structure for new service
     - Database schema changes
     - API contract definitions
     - Testing strategy
     - Rollback plan

Main Claude:
  1. Reviews plan with user
  2. User approves Phase 1
  3. Spawns code-writer to start implementation

─────────────────────────────────────────────────────────────
RESULT
─────────────────────────────────────────────────────────────

✓ Architecture planned thoroughly
✓ Migration strategy defined
✓ Risks identified and mitigated
✓ Ready to begin implementation
```

## QA Testing Workflow

### Scenario: UAT for New Feature

```
User: "QA the new dashboard before we ship it"

─────────────────────────────────────────────────────────────
Main Claude:
  1. Spawns qa for user acceptance testing

qa:
  1. Functional testing:

     User Stories:
     ✓ User can view dashboard on login
     ✓ Data loads within 3 seconds
     ✓ Charts render correctly
     ⚠️ Refresh button sometimes double-clicks
     ✗ Export to CSV generates empty file

  2. Accessibility audit (references accessibility skill):
     ✓ Keyboard navigation works
     ✓ ARIA labels present
     ⚠️ Color contrast 4.2:1 (needs 4.5:1 for AA)
     ✗ Screen reader doesn't announce chart data

  3. Browser testing:
     ✓ Chrome 120: Works
     ✓ Firefox 121: Works
     ✓ Safari 17: Works
     ⚠️ Edge: Minor CSS layout issue

  4. Edge cases:
     ✓ Handles no data gracefully
     ✓ Shows loading states
     ⚠️ Long usernames overflow
     ✗ Crashes with > 10,000 data points

  5. Returns QA report:

     BLOCKERS (can't ship):
     - CSV export broken
     - Crash with large datasets
     - Screen reader accessibility

     HIGH PRIORITY:
     - Color contrast issue
     - Username overflow

     NICE TO HAVE:
     - Edge CSS issue
     - Double-click prevention

Main Claude:
  1. Spawns code-writer to fix blockers
  2. After fixes, spawns qa again

qa (second round):
  1. Re-tests blockers:
     ✓ CSV export works
     ✓ Large datasets handled (virtualization added)
     ✓ Screen reader support added
  2. Verifies fixes didn't break anything
  3. Approves for release ✓

─────────────────────────────────────────────────────────────
RESULT
─────────────────────────────────────────────────────────────

✓ Feature thoroughly tested
✓ Accessibility validated
✓ Critical bugs fixed
✓ Ready to ship
```

## DevOps Deployment

### Scenario: Set Up CI/CD Pipeline

```
User: "Set up GitHub Actions for automated testing and deployment"

─────────────────────────────────────────────────────────────
Main Claude:
  1. Spawns devops for pipeline configuration

devops:
  1. Analyzes project:
     - Stack: Next.js, TypeScript, Prisma
     - Hosting: Vercel
     - Database: PostgreSQL (Supabase)

  2. References skills:
     - docker (for containerization)
     - testing-frameworks (for test commands)

  3. Creates workflows:

     .github/workflows/ci.yml:
     - Runs on every push and PR
     - Jobs: lint, typecheck, test, build
     - Caching for faster runs

     .github/workflows/deploy-staging.yml:
     - Runs on push to main
     - Deploys to Vercel staging
     - Runs E2E tests against staging

     .github/workflows/deploy-production.yml:
     - Runs on git tags (v1.0.0)
     - Deploys to Vercel production
     - Requires manual approval

  4. Sets up monitoring:
     - Vercel Analytics integration
     - Sentry for error tracking
     - Health check endpoint

  5. Documents required secrets:
     - VERCEL_TOKEN
     - VERCEL_ORG_ID
     - VERCEL_PROJECT_ID
     - DATABASE_URL (staging and prod)
     - SENTRY_DSN

  6. Returns setup guide:
     - How to add GitHub secrets
     - How to trigger deployments
     - How to rollback if needed
     - Monitoring dashboards

Main Claude:
  1. Reviews setup with user
  2. User adds secrets to GitHub
  3. Spawns devops to test pipeline

devops:
  1. Creates test commit
  2. Verifies workflow runs:
     ✓ CI passes
     ✓ Staging deployment successful
     ✓ E2E tests pass on staging
  3. Confirms setup is working

─────────────────────────────────────────────────────────────
RESULT
─────────────────────────────────────────────────────────────

✓ CI/CD pipeline configured
✓ Automated testing enabled
✓ Staging + production workflows ready
✓ Monitoring set up
```

## Git and Documentation

### Scenario: Create Release and Documentation

```
User: "Prepare v2.0.0 release with all changes from last month"

─────────────────────────────────────────────────────────────
Main Claude:
  1. Spawns git-docs for release preparation

git-docs:
  1. Analyzes git history:
     - Reviews commits since v1.5.0
     - Categorizes changes (features, fixes, breaking)
     - Identifies 23 commits to include

  2. Generates CHANGELOG.md:

     ## [2.0.0] - 2026-01-20

     ### Breaking Changes
     - API: Changed authentication to use JWT instead of sessions
     - Database: Renamed `user_profile` table to `profiles`

     ### Added
     - Dashboard with real-time analytics
     - Export data to CSV/PDF
     - Dark mode support
     - Multi-language support (EN, ES, FR)

     ### Fixed
     - Performance issue with large datasets
     - Memory leak in WebSocket connections
     - Accessibility bugs in forms

  3. Creates migration guide:

     MIGRATION_v2.md:
     - How to migrate from v1.x to v2.0
     - Database migration SQL scripts
     - API changes with code examples
     - Environment variable updates

  4. Updates documentation:
     - README.md (new features)
     - API.md (endpoint changes)
     - DEPLOYMENT.md (new env vars)

  5. Creates git tag and release notes:

     git tag v2.0.0

     Release Notes:
     - Summary of major changes
     - Breaking changes highlighted
     - Migration instructions link
     - Credits to contributors

  6. Returns release checklist:
     ☐ Review CHANGELOG.md
     ☐ Verify migration guide
     ☐ Update version in package.json
     ☐ Run full test suite
     ☐ Create git tag
     ☐ Push to GitHub
     ☐ Publish release
     ☐ Update documentation site

Main Claude:
  1. User reviews and approves
  2. git-docs executes release

─────────────────────────────────────────────────────────────
RESULT
─────────────────────────────────────────────────────────────

✓ Release notes generated
✓ CHANGELOG updated
✓ Migration guide created
✓ Documentation updated
✓ v2.0.0 released
```

## Tips for Effective Workflows

### 1. Always Start with Planning
For non-trivial features, spawn the planner first to:
- Gather requirements
- Identify potential issues
- Create clear implementation plan

### 2. Use Code Review for Every Change
Even small fixes benefit from code-reviewer:
- Catches security issues
- Ensures test coverage
- Validates patterns

### 3. QA Before Shipping
Use qa agent for user-facing changes:
- Functional testing
- Accessibility validation
- Browser compatibility
- Edge cases

### 4. Document as You Go
Use git-docs to:
- Create meaningful commits
- Update relevant documentation
- Maintain CHANGELOG

### 5. Leverage Skills
Reference skills proactively:
- Faster than re-explaining patterns
- Consistent guidance
- Up-to-date best practices

## Related Documentation

- [Architecture](ARCHITECTURE.md) - How the toolkit works
- [Configuration](CONFIGURATION.md) - Customize CLAUDE.md
- [MCP Safety](MCP_SAFETY.md) - Integration safety

---

Need help with a specific workflow? Check the [main README](../README.md) or explore [agent guides](../agents/GUIDE.md).
