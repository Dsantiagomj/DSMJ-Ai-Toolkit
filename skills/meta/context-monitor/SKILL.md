---
name: context-monitor
version: 1.0.0
description: Detects context drift, conversation unfocus, and suggests refocusing strategies. Auto-invokes when conversations exceed thresholds or show patterns of confusion.
tags: [meta, context, monitoring, drift, focus]
author: dsmj-ai-toolkit
metadata:
  auto_invoke: "Conversation exceeds 50 messages, multiple topics mixed, repeated errors, or confusion patterns detected"
  category: meta
---

# Context Monitor Skill

Maintains conversation focus and detects when context becomes polluted or drifted.

---

## When to Use This Skill

**Auto-invoke when**:
- Conversation exceeds 50 messages without clear resolution
- Multiple unrelated topics discussed in same conversation
- Repeated errors or confusion patterns detected
- Circular discussions (same questions/issues recurring)
- User seems frustrated or conversation is stuck

---

## Drift Signals

### 1. Length-Based Drift

**Signal**: Conversation too long without progress

```
Threshold: 50+ messages in single conversation

Symptoms:
- Original goal unclear or lost
- Many tangents taken
- Difficulty referencing earlier context
- Repeated tool calls for same information

Action: Suggest summarizing and refocusing
```

**What to suggest**:
```
"This conversation has gotten quite long (60+ messages).

To maintain focus, I suggest:
1. Summarize what we've accomplished so far
2. Identify remaining tasks
3. Consider spawning fresh specialist for next task

This will ensure clean context and better results.

Should I proceed with summary?"
```

### 2. Topic Drift

**Signal**: Multiple unrelated topics mixed

```
Pattern:
- Started with authentication implementation
- Switched to database optimization
- Now discussing UI component styling
- All in same conversation

Problem: Loss of specialist focus, polluted context

Action: Suggest breaking into separate focused tasks
```

**What to suggest**:
```
"I've noticed we've covered multiple unrelated topics:
1. Authentication (messages 1-20)
2. Database optimization (messages 21-35)
3. UI styling (messages 36-current)

For better results, I suggest:
- Finish current UI styling task
- Then spawn fresh code-writer for next unrelated task

This keeps each specialist focused. Sound good?"
```

### 3. Error Loops

**Signal**: Same errors repeating

```
Pattern:
- Error encountered
- Fix attempted
- Same error returns
- Fix attempted again
- Error still present
(Repeated 3+ times)

Problem: Wrong diagnosis or approach

Action: Pause and reassess
```

**What to suggest**:
```
"I've attempted to fix this error 3 times without success:
[Error description]

Let me verify my understanding:
1. [What I think is causing this]
2. [What I've tried]
3. [Why it might not be working]

Before trying again, let me:
- Read relevant files more carefully
- Check for alternative causes
- Consult relevant skills for patterns

One moment..."
```

### 4. Clarification Loops

**Signal**: Asking same questions repeatedly

```
Pattern:
- User: "What about X?"
- Claude: "Can you clarify X?"
- User: "I mean X with Y"
- Claude: "Can you clarify Y?"
- User: [frustrated] "Just do Z"

Problem: Overcautious clarification

Action: Be more decisive or show options
```

**What to suggest**:
```
"I apologize for the repeated clarifications. Let me propose concrete options:

Option A: [Specific implementation]
Option B: [Alternative approach]
Option C: [Third option]

Which aligns with your goal? Or should I go with Option A (my recommendation)?"
```

### 5. Specialist Churn

**Signal**: Spawning many specialists without progress

```
Pattern:
- Spawn code-writer → incomplete result
- Spawn code-reviewer → finds issues
- Spawn code-writer again → different issues
- Spawn refactorer → creates new problems
(Without clear progress)

Problem: Unclear requirements or wrong approach

Action: Pause and plan
```

**What to suggest**:
```
"We've spawned multiple specialists without making clear progress.

Let me pause and:
1. Verify requirements are clear
2. Create focused plan
3. Identify potential blockers
4. Spawn appropriate specialist with full context

This should prevent more churn. Give me a moment to reassess..."
```

---

## Refocusing Strategies

### Strategy 1: Summarize and Continue

**When**: Conversation long but productive

```markdown
**Conversation Summary** (Message 1-60)

**Completed**:
- ✅ Implemented JWT authentication (messages 1-25)
- ✅ Added password hashing with bcrypt (messages 26-40)
- ✅ Created login API route (messages 41-55)

**In Progress**:
- 🔄 Adding logout functionality (messages 56-current)

**Remaining**:
- ⏳ Add refresh tokens
- ⏳ Implement rate limiting
- ⏳ Add security tests

**Current Focus**: Complete logout, then move to fresh task for refresh tokens.
```

### Strategy 2: Spawn Fresh Specialist

**When**: New unrelated task needed

```
"Previous work complete. For this new task (adding email notifications),
I'll spawn fresh code-writer specialist.

This gives clean context focused only on email functionality.

Spawning now..."
```

### Strategy 3: Break Down Complex Task

**When**: Task too large, causing confusion

```
"This task (complete authentication system) is quite large.

Let me break into focused subtasks:
1. Core auth logic (current - code-writer)
2. Email verification (next - fresh specialist)
3. OAuth integration (separate - fresh specialist)
4. Security review (final - code-reviewer)

Completing #1 now, then we'll tackle others with fresh context each time."
```

### Strategy 4: Verify Understanding

**When**: Confusion or misalignment detected

```
"Before continuing, let me verify my understanding:

**Goal**: [What I think we're building]
**Current State**: [What exists now]
**Next Step**: [What I plan to do]

Is this correct, or did I misunderstand something?"
```

### Strategy 5: Suggest Alternative Approach

**When**: Current approach repeatedly failing

```
"We've tried approach X three times without success.

Alternative approaches:
1. [Different technical solution]
2. [Simplified version]
3. [Use existing library instead]

I recommend trying #3 (using existing library) as it's battle-tested
and solves our specific problem. Agree?"
```

---

## Detection Metrics

### Conversation Health Indicators

**Green (Healthy)**:
- ✅ Clear goal and progress toward it
- ✅ Specialists used appropriately
- ✅ Few errors, quick resolution when occur
- ✅ User engaged and satisfied
- ✅ Each message adds value

**Yellow (Warning)**:
- ⚠️ Conversation approaching 40 messages
- ⚠️ 2-3 topics mixed
- ⚠️ Some repeated questions
- ⚠️ Minor confusion or misalignment
- ⚠️ Suggests reviewing and refocusing soon

**Red (Action Needed)**:
- 🔴 Conversation exceeds 60 messages
- 🔴 Multiple unrelated topics mixed
- 🔴 Repeated errors (3+ times same issue)
- 🔴 User frustration evident
- 🔴 Circular discussions
- 🔴 **Action**: Pause, summarize, refocus IMMEDIATELY

---

## How to Implement Monitoring

### Auto-Check Pattern

```
After every 10 messages:
1. Check total message count
2. Assess topic coherence
3. Count error repetitions
4. Evaluate progress

If any red flags:
- Proactively suggest refocusing
- Don't wait for user to notice drift
- Be specific about what's wrong and how to fix
```

### Example Monitoring Logic

```
Message 50 reached:
→ "We're at 50 messages. Making good progress on auth implementation.
   Suggest spawning fresh specialist for next feature (email verification)
   to maintain clean context. Agree?"

Message 60 + topic drift detected:
→ "Pausing to refocus. We've mixed auth + database + UI topics.
   Let me finish current UI task, then we'll handle others separately
   with fresh specialists. This prevents context pollution."

3rd occurrence of same error:
→ "This error has repeated 3 times. Let me step back and verify:
   [Understanding check + alternative approaches]
   Before proceeding, I want to ensure I'm addressing root cause."
```

---

## Conversation Patterns to Watch

### Anti-Pattern 1: The Wanderer

```
User: "Add authentication"
Claude: [Implements auth]
User: "Actually, make the button blue"
Claude: [Changes button]
User: "And optimize the database"
Claude: [Optimizes DB]

Problem: No focus, no completion
Solution: Finish auth first, then address others separately
```

### Anti-Pattern 2: The Perfectionist Loop

```
User: "Add feature X"
Claude: [Implements X]
User: "Refactor it"
Claude: [Refactors]
User: "But what about edge case Y?"
Claude: [Handles Y]
User: "And Z?"
[Never reaches done state]

Problem: Endless refinement without shipping
Solution: Define "done" criteria upfront
```

### Anti-Pattern 3: The Tool Spammer

```
Claude: [Reads file A]
Claude: [Reads file B]
Claude: [Reads file C]
Claude: [Reads A again]
Claude: [Reads B again]
[20+ Read tool calls]

Problem: Lost track of what's read, repeating work
Solution: Take notes, summarize findings, focus
```

### Anti-Pattern 4: The Assumption Chain

```
User: "The auth doesn't work"
Claude: "Let me fix the JWT"
User: "I'm not using JWT"
Claude: "Oh, let me fix sessions"
User: "It's OAuth"
Claude: "Which provider?"
User: [frustrated]

Problem: Guessing instead of verifying
Solution: Verify first (Rule #5), then act
```

---

## Proactive Monitoring Messages

### At Message 40

```
"📊 Quick check: We're at 40 messages working on [current task].

Progress looks good. After finishing [current], I suggest spawning
fresh specialist for next feature to maintain optimal context.

Continuing with current task now..."
```

### At Message 60

```
"⚠️ Context check: 60 messages reached.

Completed: [list]
Current: [current work]
Remaining: [remaining items]

To maintain quality, I strongly suggest:
1. Finish current item
2. Summarize conversation
3. Spawn fresh specialists for remaining work

This prevents context pollution. Should I proceed with summary after
current task completes?"
```

### On Topic Drift

```
"🎯 Focus check: I've noticed we've shifted from [original topic]
to [current topic].

To keep context clean:
- Finish [current topic] now
- Then spawn fresh specialist for next unrelated task

This ensures each specialist has focused, relevant context only."
```

### On Error Repetition

```
"🔄 Pattern detected: This error has occurred 3 times.

Pausing to reassess:
- Error: [description]
- Attempts: [what was tried]
- Hypothesis: [likely root cause]

Before trying again, let me [verify/read/check specific thing].

One moment for proper diagnosis..."
```

---

## Remember

**Purpose**: Keep conversations focused and productive

**When to activate**:
- Proactively at thresholds (40, 60 messages)
- Reactively when patterns detected
- Never wait for user to notice drift

**How to help**:
- Specific observations (not vague "seems long")
- Concrete suggestions (not just "maybe refocus")
- User-friendly (not preachy or interrupting)

**Balance**:
- ✅ Help without hindering
- ✅ Suggest without demanding
- ✅ Monitor without micro-managing

---

_This skill helps maintain conversation quality. It should be subtle, helpful, and user-focused._
