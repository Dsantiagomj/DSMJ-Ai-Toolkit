# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.1.0] - 2026-01-17

### Added
- **skill-creator meta skill**: Interactive 7-phase workflow for creating new skills with validation
  - Requirements gathering with decision frameworks
  - Structure creation with references/ support
  - Complete YAML frontmatter templates
  - Content section guidelines
  - 4-level validation checklists
  - Testing and registration workflows
- **ui-ux domain skill**: UI/UX design principles and modern patterns
  - 6 critical patterns (visual hierarchy, component states, responsive design, dark mode, spacing, microinteractions)
  - 6 anti-patterns with solutions
  - Quick reference tables for hierarchy, states, spacing, breakpoints, contrast
  - Trending patterns reference (glassmorphism, neumorphism, bento grids, gradient mesh, animations)
- **Code Examples sections**: Added to all 9 domain skills for validation compliance
  - Practical, concise examples demonstrating core concepts
  - References to detailed implementations in references/ folders

### Changed
- **Progressive disclosure implementation**: Modularized 23 files (6 agents, 8 stack skills, 9 domain skills)
  - Main files reduced to 300-700 lines for better scannability
  - Detailed content moved to references/ folders
  - Overall reduction of ~4,200 lines (23%)
  - 21+ reference files created with detailed implementations
- **Enhanced stack skills**: Added critical patterns and anti-patterns to all stack skills
  - typescript, vercel-ai-sdk, zustand, prisma, react, trpc, docker, react-hook-form
  - Each skill now includes 3-6 critical patterns with good vs bad examples
  - Each skill includes 3-6 anti-patterns with solutions
- **Agent integration**: Updated qa, code-writer, and planner agents to reference ui-ux skill
  - QA agent validates UI/UX design patterns and component states
  - Code-writer implements UI components with design principles
  - Planner includes UI/UX considerations in planning user flows

### Improved
- **Skill catalog**: Updated to 161+ skills (19 local + 142 community)
- **File organization**: Consistent structure across all agents and skills
- **Documentation**: All skills follow progressive disclosure pattern
- **Validation**: All skills pass validation requirements

### Technical
- Main files now 300-700 lines (ideal scannable range)
- References/ folders for detailed content
- Maintained backward compatibility with v2.0 format
- Clean commit history (removed AI attribution)

## [2.0.0] - 2026-01-17

### Breaking Changes
- Standardized agent and skill format with YAML frontmatter
- All agents and skills require metadata section
- Description field must include "Trigger:" clause

### Added
- Agent v2.0 format with enhanced frontmatter
- Skill v2.0 format with progressive disclosure
- Validation workflows for agents and skills
- Conventional commits enforcement

## [1.0.0] - Initial Release

### Added
- 7-agent architecture
- Core skills framework
- Community skills catalog
- CLI tools for skill management
- Homebrew formula distribution
