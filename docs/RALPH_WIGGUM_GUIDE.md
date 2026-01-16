# Ralph Wiggum - Iterative Completion Guide

**"Iteration trumps perfection. Persistence prevails."**

Ralph Wiggum is an optional iterative specialist agent that keeps working on a task until completion criteria are met.

## What is Ralph Wiggum?

Named after The Simpsons character, Ralph embodies persistence over perfection. Instead of trying to get everything right on the first attempt, Ralph:

1. **Attempts** the task
2. **Verifies** completion (tests, builds, checks)
3. **Analyzes** failures
4. **Learns** and adjusts approach
5. **Repeats** until done or stuck

## When to Use Ralph

### ✅ Perfect For

**Test-Driven Development (TDD)**
```
Task: "Implement user registration with passing tests"

Ralph will:
- Write initial implementation
- Run tests → failures
- Fix issues based on test errors
- Run tests again
- Repeat until all tests pass
- Output: TESTS_PASSING
```

**Overnight Greenfield Projects**
```
Task: "Build CRUD API for blog posts with complete test coverage"

Ralph will:
- Create models, routes, tests
- Iterate on failures
- Work through the night
- Wake up to working API
- Output: API_COMPLETE
```

**Build Error Resolution**
```
Task: "Fix all TypeScript errors and get clean build"

Ralph will:
- Fix errors
- Run build
- New errors appear
- Fix those
- Repeat until build succeeds
- Output: BUILD_SUCCESS
```

**Refactoring with Safety**
```
Task: "Refactor auth system while keeping tests passing"

Ralph will:
- Refactor incrementally
- Run tests after each change
- If tests fail, revert or fix
- Continue until refactor complete
- Output: REFACTOR_COMPLETE
```

### ❌ NOT Good For

- **Exploratory work** - No clear "done" state
- **Creative tasks** - Subjective completion
- **User decision points** - Ralph needs autonomy
- **Quick changes** - Overhead not worth it
- **Unclear requirements** - Needs objective verification

## Installation

### Enable During Project Init

```bash
cd your-project
dsmj-ai init

# When prompted:
Ralph Wiggum - Iterative Specialist (Optional)
Keeps working until task completion. Best for:
  - Overnight builds / TDD
  - Well-defined tasks with clear completion criteria
  - Iterative refinement until tests pass

Include Ralph Wiggum agent? (y/N): y
```

### Add to Existing Project

```bash
# Manual link
ln -s ~/.dsmj-ai-toolkit/agents/ralph-wiggum.md .claude/agents/ralph-wiggum.md
```

## How to Use Ralph

### Method 1: Via CLI (Recommended for Setup)

```bash
# Generate prompt file
dsmj-ai ralph "Fix all TypeScript errors" 20 BUILD_SUCCESS

# This creates .ralph-prompt.md with:
# - Task description
# - Max iterations (20)
# - Completion phrase (BUILD_SUCCESS)
# - Instructions for Ralph
```

Then in Claude Code:
```
You: Use the Task tool to spawn ralph-wiggum agent
You: Give it the prompt from .ralph-prompt.md
```

### Method 2: Direct Spawn (Quick)

In Claude Code conversation:
```
You: "Spawn ralph-wiggum agent with this task:
     Implement JWT authentication with all tests passing.
     Keep iterating until complete.
     Output 'AUTH_COMPLETE' when done.
     Max 30 iterations."
```

### Method 3: Manual Iterative

For hands-on control:
```
You: "Spawn ralph-wiggum to implement feature X"
[Ralph works, outputs status]

If not complete:
You: "Continue where you left off"
[Ralph resumes]

Repeat until completion phrase appears
```

## Crafting Effective Prompts

### Good Prompt Structure

```markdown
## Task
[Clear, specific goal]

## Completion Criteria
- [Objective criterion 1: tests pass]
- [Objective criterion 2: build succeeds]
- [Objective criterion 3: specific file created]

## Completion Phrase
[EXACT_PHRASE_TO_OUTPUT]

## Max Iterations
[Number, typically 20-50]
```

### Example: Good Prompts

**TDD Example**:
```
Task: Implement password reset flow

Completion Criteria:
- All tests in tests/auth/password-reset.test.ts pass
- Email sending integration works
- Token expiry logic implemented
- Security best practices followed (from security skill)

Completion Phrase: PASSWORD_RESET_COMPLETE
Max Iterations: 30
```

**Build Example**:
```
Task: Migrate to TypeScript strict mode

Completion Criteria:
- tsconfig.json has "strict": true
- npm run build succeeds with no errors
- All type errors resolved
- No @ts-ignore or @ts-expect-error used

Completion Phrase: STRICT_MODE_COMPLETE
Max Iterations: 40
```

**Refactoring Example**:
```
Task: Extract auth logic into separate module

Completion Criteria:
- New lib/auth.ts module created
- All auth code moved from scattered locations
- All existing tests still pass
- No duplicate code remains

Completion Phrase: AUTH_EXTRACTED
Max Iterations: 25
```

### Example: Bad Prompts

```
❌ Too vague:
"Make the app better"
→ No objective completion criteria

❌ Too subjective:
"Improve the UI to look nice"
→ "Nice" is subjective, can't verify

❌ Requires decisions:
"Add authentication"
→ Which type? JWT? Sessions? OAuth?

❌ No verification:
"Implement feature X"
→ How will Ralph verify it works?
```

## Completion Phrases

### Standard Phrases

Use these for common scenarios:

| Phrase | Use Case |
|--------|----------|
| `TESTS_PASSING` | All tests pass |
| `BUILD_SUCCESS` | Build completes without errors |
| `IMPLEMENTATION_DONE` | Feature implemented and verified |
| `REFACTOR_COMPLETE` | Refactoring done, tests still pass |
| `ERRORS_FIXED` | All errors resolved |
| `MIGRATION_COMPLETE` | Data/code migration successful |

### Custom Phrases

Make them specific and obvious:
```
✅ Good:
- AUTH_IMPLEMENTATION_COMPLETE
- USER_CRUD_API_WORKING
- TYPESCRIPT_STRICT_ENABLED

❌ Bad:
- DONE (too generic)
- OK (ambiguous)
- FINISHED (could mean anything)
```

## Understanding Ralph's Output

### Iteration Updates

```
Iteration 1: Implementing auth routes...
Running tests... 3 failures detected.
Analyzing failures...

Iteration 2: Fixed password hashing issue.
Running tests... 1 failure detected.
Analyzing...

Iteration 3: Added token expiry.
Running tests... All passing!
Verifying build... Success!

✅ Task Complete

AUTH_IMPLEMENTATION_COMPLETE
```

### Stuck/Blocked Output

```
⚠️ Stuck after 8 iterations with no progress

Issue: Tests failing with same error repeatedly
Attempted:
- Tried fixing validation 3 times
- Tried different hashing approach
- Tried adjusting test expectations

Recommendation:
The test error suggests database schema mismatch.
Manual review of schema needed before continuing.

BLOCKED
```

### Max Iterations Reached

```
⚠️ Max iterations reached (30)

Progress Summary:
✅ Completed:
- Basic auth routes implemented
- Password hashing working
- Token generation working

⚠️ Remaining Issues:
- 2 tests still failing (token refresh)
- Build succeeds but with warnings

Last Error:
"RefreshToken is not assignable to string"

Recommendation:
Fix type definition for RefreshToken, then re-run Ralph

INCOMPLETE
```

## Best Practices

### 1. Set Realistic Max Iterations

```
Small tasks (quick fixes): 10-15 iterations
Medium tasks (features): 20-30 iterations
Large tasks (greenfield): 40-50 iterations

Start conservative, increase if needed
```

### 2. Use with Test Suites

Ralph works best when there's automated verification:
```
✅ Has tests → Ralph can verify objectively
❌ No tests → Ralph has to guess if done
```

### 3. Review First Iteration

Don't go overnight immediately:
```
1. Run Ralph for 5 iterations
2. Check progress and approach
3. If good, let it run overnight
4. If problematic, adjust prompt
```

### 4. Combine with Code Review

After Ralph completes:
```
1. Ralph outputs: TASK_COMPLETE
2. You spawn code-reviewer
3. Reviewer checks quality
4. If issues found, give Ralph refinement task
```

### 5. Break Large Tasks

```
❌ Don't:
"Build entire e-commerce platform"
(Too large, unclear completion)

✅ Do:
1. Ralph: "Implement product CRUD with tests" → PRODUCT_CRUD_COMPLETE
2. Ralph: "Implement cart functionality with tests" → CART_COMPLETE
3. Ralph: "Implement checkout flow with tests" → CHECKOUT_COMPLETE

Multiple focused Ralph runs > one massive run
```

## Real-World Examples

### Example 1: Overnight TDD

**Friday 6pm**:
```bash
dsmj-ai ralph "Implement user profile editing with complete test coverage. \
All tests must pass. Reference security skill for input validation." \
50 PROFILE_FEATURE_COMPLETE
```

**Saturday 8am**:
```
Wake up to:
✅ Task Complete
- 15 tests written and passing
- Profile editing routes implemented
- Input validation following security skill
- Build successful

PROFILE_FEATURE_COMPLETE
```

### Example 2: Build Error Marathon

**Monday morning** (after dependency update broke build):
```
You: Spawn ralph-wiggum with:
"Fix all TypeScript errors after dependency update.
Build must succeed with zero errors.
Max 40 iterations."

[Go to meetings]

2 hours later:
✅ BUILD_SUCCESS
- Fixed 23 type errors
- Updated deprecated APIs
- Build clean
```

### Example 3: Refactoring Safety

```
You: "Refactor authentication to use new library while keeping all 47 tests passing"

Ralph iterations:
1-5: Replace auth logic incrementally
6-10: Fix breaking tests
11-15: Update remaining files
16: All tests passing!

REFACTOR_COMPLETE
```

## Troubleshooting

### Ralph Keeps Failing Same Way

**Symptom**: Same error for 3+ iterations

**Solution**: Ralph might be stuck in local minimum
- Stop Ralph
- Review the error manually
- Provide more specific guidance
- Or break into smaller subtask

### Ralph Completes Too Early

**Symptom**: Outputs completion phrase but not actually done

**Solution**: Make completion criteria more specific
```
Before: "Implement auth"
After: "Implement auth AND all tests in tests/auth/ pass AND build succeeds"
```

### Ralph Never Completes

**Symptom**: Hits max iterations without success

**Solutions**:
- Task too large → Break into smaller tasks
- Tests too strict → Review test expectations
- Dependencies missing → Install manually first
- Requirements unclear → Refine prompt

## Advanced: Custom Completion Logic

For complex verification, you can specify custom checks:

```markdown
Task: Implement API endpoint

Completion Criteria:
1. Endpoint responds to POST /api/users
2. Returns 201 status with user object
3. Validates email format
4. Hashes password with bcrypt
5. Tests pass: npm test -- users.test.ts
6. Manual curl test succeeds:
   curl -X POST http://localhost:3000/api/users \
   -H "Content-Type: application/json" \
   -d '{"email":"test@example.com","password":"test123"}'

Completion Phrase: API_ENDPOINT_VERIFIED
```

Ralph will work through each criterion systematically.

## FAQ

**Q: Can Ralph work on multiple tasks simultaneously?**
A: No. Ralph focuses on one task at a time until completion.

**Q: Does Ralph save progress if stopped?**
A: Yes, code changes are saved. You can resume by spawning Ralph again with same prompt.

**Q: Can I use Ralph for creative/design work?**
A: Not recommended. Ralph needs objective completion criteria.

**Q: How much does Ralph cost in API calls?**
A: Depends on iterations. Estimate: ~$0.01-0.05 per iteration (Claude Sonnet). A 30-iteration task might cost $0.30-1.50.

**Q: Can Ralph spawn other agents?**
A: Yes! Ralph can spawn code-reviewer for checks, or other specialists if needed.

**Q: What if my tests are flaky?**
A: Ralph will struggle. Fix flaky tests first, then use Ralph.

**Q: Can I run multiple Ralph instances?**
A: Technically yes (different projects), but they'd be independent and might conflict if touching same files.

## Comparison: Ralph vs Manual vs Other Agents

| Aspect | Ralph Wiggum | code-writer | Manual Coding |
|--------|--------------|-------------|---------------|
| **Iterations** | Automatic until done | Single attempt | Manual iterations |
| **Verification** | Runs tests/builds automatically | Returns summary | Manual verification |
| **Best for** | TDD, overnight tasks | One-off implementations | Complex decisions |
| **Completion** | Objective (tests pass) | Subjective (looks done) | You decide |
| **Cost** | Higher (multiple iterations) | Lower (one pass) | Your time |

## Resources

- [awesomeclaude.ai/ralph-wiggum](https://awesomeclaude.ai/ralph-wiggum) - Original concept
- Agent file: `~/.dsmj-ai-toolkit/agents/ralph-wiggum.md`
- Enable during: `dsmj-ai init`

---

**"I'm going to keep trying until it works!"** - Ralph Wiggum philosophy ✨
