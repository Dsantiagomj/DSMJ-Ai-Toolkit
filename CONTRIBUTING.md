# Contributing to dsmj-ai-toolkit

Thank you for wanting to contribute! This document explains how to submit your contributions to the project.

## Table of Contents

- [Conventional Commits](#conventional-commits)
- [Contributing Skills](#contributing-skills)
- [Contributing Agents](#contributing-agents)
- [Development Workflow](#development-workflow)
- [Quality Standards](#quality-standards)

---

## Conventional Commits

**All commit messages MUST follow the [Conventional Commits](https://www.conventionalcommits.org/) specification.**

This is enforced automatically via GitHub Actions on all pull requests.

### Format

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

### Types

| Type | Description | Example |
|------|-------------|---------|
| `feat` | New feature | `feat(skills): add react-19 skill` |
| `fix` | Bug fix | `fix(agents): correct spawn logic` |
| `docs` | Documentation only | `docs(readme): update installation` |
| `style` | Code style (formatting, etc.) | `style(skills): fix markdown formatting` |
| `refactor` | Code refactoring | `refactor(skills): simplify structure` |
| `perf` | Performance improvements | `perf(agents): optimize file reading` |
| `test` | Add/update tests | `test(skills): add validation tests` |
| `build` | Build system changes | `build: update dependencies` |
| `ci` | CI/CD changes | `ci: add skill validation workflow` |
| `chore` | Other changes | `chore: update .gitignore` |
| `revert` | Revert previous commit | `revert: revert feat(skills): add x` |

### Scopes

Common scopes include:

- `skills` - Changes to skills
- `agents` - Changes to agents
- `templates` - Changes to templates
- `docs` - Changes to documentation
- `core` - Changes to core functionality
- `cli` - Changes to CLI tool
- `config` - Configuration changes
- `workflows` - GitHub Actions workflows
- `deps` - Dependency updates

### Examples

✅ **Good commit messages:**
```
feat(skills): add typescript skill with strict mode patterns
fix(agents): resolve code-writer context loss issue
docs(skills): update GUIDE with YAML frontmatter requirements
refactor(templates): simplify CLAUDE.md template structure
test(skills): add unit tests for skill validation
chore(deps): update dependencies to latest versions
```

❌ **Bad commit messages:**
```
Added new skill
Fixed bug
Update README
WIP
asdf
```

### Rules

- **Header max length**: 72 characters
- **Subject**: Start with lowercase (after type/scope)
- **Subject**: No period at the end
- **Body**: Optional, max 100 characters per line
- **Footer**: Optional, for breaking changes or issue references

### Breaking Changes

For breaking changes, use `!` after the type/scope or add a `BREAKING CHANGE:` footer:

```
feat(skills)!: change YAML frontmatter structure

BREAKING CHANGE: All skills must now include version field in metadata
```

### How to Fix Invalid Commits

If your commits don't follow the convention:

1. **Rebase and reword**:
   ```bash
   git rebase -i HEAD~n  # where n = number of commits to fix
   ```

2. **Change `pick` to `reword` for commits to fix**

3. **Save and update commit messages** following the format

4. **Force push**:
   ```bash
   git push --force-with-lease
   ```

---

## Contributing Skills

Skills are specialized instruction sets that teach Claude how to work with specific frameworks and patterns.

### Skill Requirements

Your skill must:

- [ ] Follow the [skill template](skills/TEMPLATE.md)
- [ ] Include valid YAML frontmatter
- [ ] Have clear trigger conditions
- [ ] Include 3+ critical patterns
- [ ] Include 3+ code examples
- [ ] Include anti-patterns section
- [ ] Include keywords for searchability
- [ ] Be focused on ONE technology/framework
- [ ] Be 100-500 lines (concise, not encyclopedic)
- [ ] Use conventional commits

### Submitting a Skill

1. **Fork the repository**

2. **Create your skill** following the template:
   ```bash
   mkdir -p skills/stack/your-skill-name
   cp skills/TEMPLATE.md skills/stack/your-skill-name/SKILL.md
   # Edit the file
   ```

3. **Commit with conventional commits**:
   ```bash
   git add skills/stack/your-skill-name
   git commit -m "feat(skills): add your-skill-name skill"
   ```

4. **Push and create PR**:
   ```bash
   git push origin your-branch
   # Create PR on GitHub
   ```

5. **Automated validation will run** - Fix any issues reported

### Skill Categories

Place your skill in the appropriate category:

- `skills/stack/` - Framework/library-specific skills (React, Next.js, Django)
- `skills/domain/` - Domain knowledge skills (Security, Accessibility, API Design)
- `skills/meta/` - Meta skills (Context monitoring, Skill creation)

---

## Contributing Agents

Agents are specialized AI assistants for focused tasks.

### Agent Requirements

- [ ] Follow the [agent template](agents/TEMPLATE.md)
- [ ] Single, clear responsibility
- [ ] Non-overlapping with existing agents
- [ ] Include complete examples
- [ ] Include quality checks
- [ ] Use conventional commits

### Submitting an Agent

1. **Create your agent**:
   ```bash
   cp agents/TEMPLATE.md agents/your-agent.md
   # Edit the file
   ```

2. **Commit**:
   ```bash
   git add agents/your-agent.md
   git commit -m "feat(agents): add your-agent specialist"
   ```

3. **Submit PR**

---

## Development Workflow

### 1. Fork and Clone

```bash
git clone https://github.com/YOUR_USERNAME/dsmj-ai-toolkit.git
cd dsmj-ai-toolkit
```

### 2. Create Branch

```bash
git checkout -b feat/your-feature-name
# or
git checkout -b fix/bug-description
```

### 3. Make Changes

- Follow existing code style
- Update relevant documentation
- Test your changes locally

### 4. Commit with Conventional Commits

```bash
git add .
git commit -m "feat(scope): description"
```

### 5. Push and Create PR

```bash
git push origin your-branch
```

Then create a Pull Request on GitHub.

### 6. Address Review Comments

- Make requested changes
- Commit with conventional commits
- Push to update the PR

---

## Quality Standards

### Code Quality

- **Consistency**: Follow existing patterns
- **Clarity**: Clear, descriptive names
- **Comments**: Explain WHY, not WHAT
- **Examples**: Include working examples

### Documentation

- **Completeness**: All sections filled out
- **Accuracy**: Verified and tested
- **Clarity**: Easy to understand
- **Examples**: Real-world use cases

### Testing

- **Skills**: Test with Claude Code
- **Agents**: Verify spawn behavior
- **Templates**: Ensure placeholders are clear

---

## Questions?

- Open an issue with the `question` label
- Check existing issues and discussions
- Read the [documentation](docs/)

---

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to dsmj-ai-toolkit! 🚀
