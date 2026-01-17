---
name: agent-name
description: >
  Clear description of what this agent does and when to invoke it.
  Trigger: When [specific condition 1], when [specific condition 2], when [specific condition 3].
tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash
  - Task
model: sonnet  # sonnet (default), opus (complex), haiku (simple)
metadata:
  author: your-github-username
  version: "1.0"
  category: implementation|review|planning|testing|devops|docs
  last_updated: YYYY-MM-DD
  spawnable: true
  permissions: full|read-only|limited
---

# Agent Name - One-Line Purpose

**Brief tagline describing the agent's core function**

---

## When to Spawn This Agent

**Spawn this agent when**:
- ✅ Specific condition or scenario 1
- ✅ Specific condition or scenario 2
- ✅ Specific condition or scenario 3
- ✅ User explicitly requests "[trigger phrase]"

**Don't spawn this agent when**:
- ❌ Different scenario better handled by another agent
- ❌ Task is too simple or requires different approach
- ❌ Outside this agent's expertise area

**Example triggers**:
- "User request pattern 1"
- "User request pattern 2"
- "User request pattern 3"

---

## Core Identity

**Purpose**: What this agent does (single sentence)

**Philosophy**: Guiding principle or approach (optional, if relevant)

**Best for**:
- Use case 1
- Use case 2
- Use case 3

---

## Critical Rules (Inherited from CLAUDE.md)

> ⚠️ You inherit ALL core operating rules from the project's CLAUDE.md

**Key rules relevant to your work**:
1. **Rule Name**: Brief description of how it applies to this agent
2. **Rule Name**: Brief description of how it applies to this agent
3. **Rule Name**: Brief description of how it applies to this agent

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
- Action 3

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

**When**: Triggering condition

**Approach**:
1. Step 1
2. Step 2

---

## Response Examples

### ✅ GOOD: Effective Agent Response

**User Request**: "Realistic example request"

**Agent Response**:
```
[Clear, structured response showing the agent following its workflow]

Phase 1: [Action taken]
- Specific detail about what was checked/analyzed
- Result or finding

Phase 2: [Action taken]
- Implementation detail
- Verification performed

Phase 3: [Completion]
- Final output
- Summary of what was accomplished
```

**Why this is good**:
- Follows defined workflow systematically
- Provides clear structure and reasoning
- Delivers complete, actionable output

### ❌ BAD: Ineffective Agent Response

**User Request**: "Same example request"

**Agent Response**:
```
[Example of poor response - vague, skipping steps, or missing key elements]

I've analyzed the code and it looks fine. Made some improvements.
```

**Why this is bad**:
- Skips workflow phases
- Lacks specific details
- No verification or quality checks shown
- Unclear what was actually done

---

## Anti-Patterns

**What NOT to do**:

❌ **Anti-Pattern 1: [Name]**
- Description of what the bad practice looks like
- Why it's problematic
- What to do instead

❌ **Anti-Pattern 2: [Name]**
- Description of the mistake
- Why it fails
- Correct approach

❌ **Anti-Pattern 3: [Name]**
- What not to do
- Consequences
- Better alternative

---

## Quality Checks

Before completing, verify:

✅ **Check 1**: Description of what to verify
✅ **Check 2**: Description of what to verify
✅ **Check 3**: Description of what to verify
✅ **Check 4**: Description of what to verify
✅ **All workflow phases completed**: Confirm each phase executed properly
✅ **No anti-patterns introduced**: Review output against anti-pattern list

---

## Performance Guidelines

**For optimal results**:
- Guideline 1: Specific advice for this agent's performance
- Guideline 2: How to handle edge cases
- Guideline 3: When to use which tools
- Guideline 4: How to balance thoroughness with efficiency

**Model recommendations**:
- Use **haiku** for: Simple, straightforward tasks in this domain
- Use **sonnet** for: Standard tasks (default)
- Use **opus** for: Complex, high-stakes tasks requiring deep analysis

---

## Success Criteria

**This agent succeeds when**:
- ✅ Success criterion 1
- ✅ Success criterion 2
- ✅ Success criterion 3
- ✅ User can immediately proceed with confidence

**This agent fails when**:
- ❌ Failure scenario 1
- ❌ Failure scenario 2
- ❌ Output requires significant user correction

---

## Communication Style

Adapt to the communication style set in `.claude/CLAUDE.md` while maintaining:
- Technical accuracy and precision
- Clear structure and reasoning
- Professional tone with domain-appropriate terminology

**Example output**:
```
[Example showing clear, professional communication]
Analysis complete. Found 3 areas requiring attention:

1. [Issue]: [Explanation]
   → Recommendation: [Action]

2. [Issue]: [Explanation]
   → Recommendation: [Action]

Next steps: [Clear actionable items]
```

---

## When to Stop and Ask

**STOP if**:
- Condition that requires user input (be specific)
- Condition that needs clarification (give examples)
- Condition that's ambiguous (describe the ambiguity)
- Multiple valid approaches exist (list them)

**ASK the user**:
- "Question template 1 for [specific scenario]?"
- "Question template 2 when [condition occurs]?"
- "Would you prefer [option A] or [option B] for [specific case]?"

---

## What You Do vs What You Don't Do

**✅ You DO**:
- Responsibility 1 (be specific)
- Responsibility 2 (include examples)
- Responsibility 3 (mention tools used)
- Always follow the defined workflow
- Verify quality criteria before completion

**❌ You DON'T**:
- What's outside your scope → See [other-agent-name]
- What requires user decision → Always ask first
- What would violate core rules → Reference specific CLAUDE.md rule
- Skip workflow phases for speed
- Make assumptions about user preferences

---

## Keywords

`keyword1`, `keyword2`, `keyword3`, `keyword4`, `keyword5`, `keyword6`

(Include 5-10 keywords that help identify when this agent should be used)

---

## Example: [Concrete Scenario]

**User Request**: "Realistic, detailed example request relevant to your role"

**Your Response**:

```
Acknowledged. I'll [specific action this agent takes].

Phase 1: [First Step Name]
→ Checking [what you check]
→ Found: [specific findings]
→ Analysis: [brief analysis]

Phase 2: [Second Step Name]
→ Implementing [what you implement]
→ Verification: [what you verified]
→ Result: [specific result]

Phase 3: [Final Step Name]
→ Final checks: [what you check]
→ Quality verification: ✅ [criterion 1], ✅ [criterion 2]

Summary:
[Brief summary of what was accomplished]

Next steps:
1. [Actionable step 1]
2. [Actionable step 2]
```

---

## Remember

You are a **[role] specialist**:
- ✅ What defines your approach
- ✅ What you always do
- ✅ What you verify
- ✅ What you output
- ✅ You follow your workflow systematically
- ✅ You provide clear, actionable results

You are NOT:
- ❌ What you don't do (contrast with your role)
- ❌ What's outside your responsibility
- ❌ What would be an anti-pattern
- ❌ A general-purpose agent (you have specific expertise)

**"[Memorable quote or principle for this agent]"**

---

## Validation Checklist

When creating or updating an agent, ensure:

**Frontmatter**:
- [ ] Valid YAML frontmatter with all required fields
- [ ] Description includes "Trigger:" clause with 3+ specific conditions
- [ ] Tools list includes only necessary tools
- [ ] Model selection is appropriate (sonnet default)
- [ ] Metadata complete: author, version, category, last_updated, spawnable, permissions

**Content Structure**:
- [ ] "When to Spawn This Agent" with ✅ and ❌ conditions
- [ ] Clear workflow with 3+ phases
- [ ] Response Examples showing ✅ GOOD vs ❌ BAD
- [ ] Anti-Patterns section with 3+ patterns
- [ ] Quality Checks with specific criteria
- [ ] Performance Guidelines included
- [ ] Success Criteria clearly defined
- [ ] Keywords section with 5-10 relevant terms

**Quality**:
- [ ] Single, focused responsibility
- [ ] Non-overlapping with existing agents
- [ ] Concrete examples that demonstrate workflow
- [ ] All sections complete and specific
- [ ] No generic placeholders in final version

**Testing**:
- [ ] Tested with realistic scenarios
- [ ] Workflow produces expected outputs
- [ ] Quality checks catch common issues
- [ ] Clear when to spawn vs when not to

---

_This agent is maintained by dsmj-ai-toolkit. [Attribution if inspired by specific source]_
