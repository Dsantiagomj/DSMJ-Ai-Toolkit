# Git Docs Complete Workflow Examples

## Complete Git Workflow Example

**User Request**: "Commit the authentication changes and create a PR"

### Agent Response:

```
Acknowledged. I'll commit the authentication changes and create a pull request.

Phase 1: Assess Changes

→ Running git status...
→ Running git diff...
→ Reading recent commits for style consistency...

Changes detected:
- app/api/auth/refresh/route.ts (new file - 45 lines)
- lib/auth/refresh.ts (new file - 67 lines)
- __tests__/auth/refresh.test.ts (new file - 89 lines)
- docs/api/auth.md (modified - added refresh endpoint docs)

Change nature: New feature (JWT token refresh)
No sensitive files detected ✅
Follows existing project patterns ✅

Phase 2: Draft Commit Message

Following Conventional Commits format:
→ Type: feat (new feature)
→ Scope: auth
→ Subject: add JWT token refresh endpoint

Commit message:
feat(auth): add JWT token refresh endpoint

Users were being logged out after token expiry with no way to
refresh without re-authenticating. This adds /auth/refresh
endpoint that issues new tokens using refresh token cookie.

- Automatic token renewal on API calls
- Secure rotation prevents token theft
- Expires refresh tokens after 30 days

Closes #123

Phase 3: Create Commits

Creating feature commit:
→ Staging implementation files...
→ git add app/api/auth/refresh/ lib/auth/refresh.ts __tests__/auth/

✅ Commit created: a1b2c3d
   feat(auth): add JWT token refresh endpoint

Creating documentation commit:
→ Staging documentation files...
→ git add docs/api/auth.md

✅ Commit created: e4f5g6h
   docs(auth): document token refresh endpoint

Phase 4: Update Documentation

Updated docs/api/auth.md:
→ Added POST /api/auth/refresh endpoint specification
→ Included request/response examples
→ Documented error cases

Updated CHANGELOG.md:
→ Added to [Unreleased] section:
  - Added: JWT token refresh endpoint
  - Added: Automatic token renewal
  - Changed: Session duration extended to 24 hours

Phase 5: Create Pull Request

Checking branch status:
→ Current branch: feature/auth-refresh
→ Base branch: main
→ Commits ahead: 2
→ Pushing to remote...

✅ Pushed to origin/feature/auth-refresh

Creating PR with gh CLI:
→ Title: feat(auth): add JWT token refresh
→ Generating comprehensive PR description...

PR Description:
## Summary
- Added JWT token refresh endpoint for session management
- Prevents forced logout after token expiry
- Automatic token renewal on authenticated API calls

## Changes
- Added: POST /api/auth/refresh endpoint
- Added: Token refresh logic with secure rotation
- Added: Comprehensive test coverage (15 tests)
- Updated: API documentation with examples

## Testing
- [x] Unit tests passing (15/15)
- [x] Integration tests passing (5/5)
- [x] Manual: Token refresh verified in browser
- [x] Manual: Tested expiry and renewal flow

## Breaking Changes
None - backward compatible addition

## Checklist
- [x] Tests added and passing
- [x] Documentation updated
- [x] No breaking changes
- [x] Follows project conventions
- [x] No secrets in code

✅ PR created: https://github.com/user/repo/pull/124

Complete! Summary:

Commits created:
1. a1b2c3d - feat(auth): add JWT token refresh endpoint
2. e4f5g6h - docs(auth): document token refresh endpoint

Documentation updated:
- docs/api/auth.md (API reference)
- CHANGELOG.md (unreleased section)

Pull request:
- URL: https://github.com/user/repo/pull/124
- Title: feat(auth): add JWT token refresh
- Status: Ready for review

Next steps:
1. Request code review from team
2. Address any review feedback
3. Merge after approval
```

## Multiple Commits for Large Change

When breaking down a large feature:

```bash
# Commit 1: Database migration
git add prisma/migrations/ prisma/schema.prisma
git commit -m "feat(auth): add refresh tokens table"

# Commit 2: Backend API
git add app/api/auth/refresh/
git commit -m "feat(auth): implement token refresh endpoint"

# Commit 3: Frontend integration
git add components/auth/
git commit -m "feat(auth): add auto-refresh to auth context"

# Commit 4: Tests
git add __tests__/
git commit -m "test(auth): add refresh token tests"

# Commit 5: Documentation
git add docs/ README.md
git commit -m "docs(auth): document token refresh flow"
```

## Breaking Changes Commit

When changes break existing API:

```
feat(api)!: change authentication to JWT

BREAKING CHANGE: Session-based auth removed in favor of JWT.

Migration:
1. Update login calls to receive token
2. Store token in localStorage/cookie
3. Send token in Authorization header

See MIGRATION.md for complete migration guide

Closes #456
```

## Release Workflow

```bash
# Update version
npm version 1.2.0 --no-git-tag-version

# Update CHANGELOG
echo "## [1.2.0] - $(date +%Y-%m-%d)" > CHANGELOG.tmp
echo "" >> CHANGELOG.tmp
git log --pretty=format:"- %s" v1.1.0..HEAD >> CHANGELOG.tmp
echo "" >> CHANGELOG.tmp
cat CHANGELOG.md >> CHANGELOG.tmp
mv CHANGELOG.tmp CHANGELOG.md

# Commit changes
git add package.json CHANGELOG.md
git commit -m "chore: release v1.2.0"

# Create tag
git tag -a "v1.2.0" -m "Release v1.2.0

## Features
- JWT token refresh
- Auto token renewal

## Fixes
- Session expiry issues
- Token rotation security

## Documentation
- API docs updated
- Migration guide added
"

# Push
git push && git push --tags
```

## PR Description Templates

### Feature PR

```markdown
## Summary
- Added JWT token refresh endpoint for session management
- Prevents forced logout after token expiry

## Changes
- Added: POST /api/auth/refresh endpoint
- Added: Token refresh logic with secure rotation
- Added: Comprehensive test coverage (15 tests)
- Updated: API documentation

## Testing
- [x] Unit tests passing (15/15)
- [x] Integration tests passing (5/5)
- [x] Manual testing completed

## Breaking Changes
None - backward compatible

## Checklist
- [x] Tests added/updated
- [x] Documentation updated
- [x] No breaking changes
- [x] Follows conventions
```

### Bug Fix PR

```markdown
## Summary
- Fixed session timeout not updating on activity
- Prevents premature logout for active users

## Root Cause
Timer wasn't reset on user activity, causing logout despite active usage

## Changes
- Fixed: Activity listener now properly resets timeout
- Added: Tests for timeout reset behavior
- Updated: Session middleware

## Testing
- [x] Unit tests passing
- [x] Manual: Verified timeout resets on activity
- [x] Manual: Verified logout after true inactivity

## Checklist
- [x] Tests added
- [x] No breaking changes
- [x] Bug verified fixed
```

### Refactoring PR

```markdown
## Summary
- Refactored authentication logic for better maintainability
- No functional changes

## Changes
- Extracted token validation to separate utility
- Simplified auth middleware
- Improved type safety
- No behavior changes

## Testing
- [x] All existing tests still passing (25/25)
- [x] No new tests needed (refactor only)
- [x] Manual testing confirms same behavior

## Checklist
- [x] No functional changes
- [x] Tests still passing
- [x] Code cleaner and more maintainable
```
