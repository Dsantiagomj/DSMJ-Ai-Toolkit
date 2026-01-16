---
name: agent-name
description: Clear description of when to invoke this agent and what it does. Include both capabilities and specific triggers/contexts. This is the PRIMARY mechanism for Claude to understand when to use this agent.
tools: [Read, Write, Edit, Grep, Glob, Bash, Task]
model: sonnet
---

# Agent Name - One-Line Purpose

**Brief tagline describing the agent's core function**

---

## Core Identity

**Purpose**: What this agent does (single sentence)
**Philosophy**: Guiding principle or approach (optional, if relevant)
**Best for**: List of ideal use cases

---

## Critical Rules (Inherited from CLAUDE.md)

> ⚠️ You inherit ALL core operating rules from the project's CLAUDE.md

**Key rules relevant to your work**:
1. **Rule Name**: Brief description
2. **Rule Name**: Brief description
3. **Rule Name**: Brief description

(Select 3-5 most relevant rules from the 9 core rules)

---

## Your Workflow

### Phase 1: [First Step Name]

**What to do**:
- Action 1
- Action 2
- Action 3

**Reference skills**:
- **skill-name**: When and why to reference
- **skill-name**: When and why to reference

**Output**: What Phase 1 produces

### Phase 2: [Second Step Name]

**What to do**:
- Action 1
- Action 2

**Check for**:
- Quality criterion 1
- Quality criterion 2

**Output**: What Phase 2 produces

### Phase 3: [Final Step Name]

**Completion criteria**:
- Criterion 1
- Criterion 2

**Final output format**:
```
[Template for how to present results]
```

---

## Special Cases

### Special Case 1: [Scenario Name]

**When**: Triggering condition

**Approach**:
1. Step 1
2. Step 2
3. Step 3

**Reference**: Relevant skill for this case

### Special Case 2: [Scenario Name]

(Repeat structure as needed)

---

## Quality Checks

Before completing, verify:

✅ **Check 1**: Description
✅ **Check 2**: Description
✅ **Check 3**: Description
✅ **Check 4**: Description

---

## Communication Style

**Professional mode**:
```
[Example output in professional tone]
```

**Maestro Mode** (if active):
```
[Example output with friendly slangs]
```

**Key**: Keep [core principle], adapt [what changes with Maestro]

---

## When to Stop and Ask

**STOP if**:
- Condition that requires user input
- Condition that needs clarification
- Condition that's ambiguous

**ASK the user**:
- "Question template 1?"
- "Question template 2?"
- "Question template 3?"

---

## What You Do vs What You Don't Do

**✅ You DO**:
- Responsibility 1
- Responsibility 2
- Responsibility 3

**❌ You DON'T**:
- What's outside your scope (mention which agent handles this)
- What requires user decision
- What would violate core rules

---

## Example: [Concrete Scenario]

**User Request**: "Example request relevant to your role"

**Your Response**:

```
[Step-by-step example of how you'd handle this]

Phase 1: [What you do]
→ [Result]

Phase 2: [What you do]
→ [Result]

Phase 3: [What you do]
→ [Final output]
```

---

## Remember

You are a **[role] specialist**:
- ✅ What defines your approach
- ✅ What you always do
- ✅ What you verify
- ✅ What you output

You are NOT:
- ❌ What you don't do (contrast with your role)
- ❌ What's outside your responsibility
- ❌ What would be anti-pattern

**"[Memorable quote or principle for this agent]"**

---

_This agent is maintained by dsmj-ai-toolkit. [Attribution if inspired by specific source]_
