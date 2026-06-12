# Agent-Friendly Structure

A simple, practical tool for initializing AI-friendly project structures.

## Quick Start

**Standalone mode** (single project):
```bash
curl -sSL https://raw.githubusercontent.com/chentianming11/agent-friendly-structure/main/init-agent-structure.sh | bash
```

**Team mode** (shared rules across projects):
```bash
curl -sSL https://raw.githubusercontent.com/chentianming11/agent-friendly-structure/main/init-agent-structure.sh | bash -s -- --team https://github.com/your-team/agent-rules.git
```

Done. No other parameters needed.

## Two Modes

### Standalone Mode
Creates empty templates in your project. You fill in all rules yourself.

### Team Mode
Uses git submodule to link a shared team rules repository. Perfect when multiple projects share the same coding standards, testing practices, and security guidelines.

**Team mode creates:**
```
.
├── AGENTS.md                    ← Project-specific (you fill this)
├── .agent → submodule           ← Team shared rules (from your team repo)
│   ├── rules/
│   ├── skills/
│   └── examples/
└── .agent-project/
    └── rules/
        └── domain-glossary.md   ← Project-specific glossary
```

**Update team rules:**
```bash
git submodule update --remote .agent
git commit -am 'chore: update team agent rules'
```

## About AGENTS.md

AGENTS.md is a universal AI agent instruction file (OpenAI Codex standard). Depending on your AI coding tool, you may want to rename it:

| Tool | File name |
|------|-----------|
| OpenAI Codex | `AGENTS.md` (default) |
| Claude Code | `CLAUDE.md` |
| Cursor | `.cursorrules` |
| Windsurf | `.windsurfrules` |
| GitHub Copilot | `.github/copilot-instructions.md` |
| Cline | `.clinerules` |
| Aider | `CONVENTIONS.md` |

Just rename AGENTS.md after generation, or keep it if your tool supports it.

## What It Does

Creates the skeleton structure:

```
.
├── AGENTS.md                    ← Project entry point for AI agents
├── .agent/
│   ├── rules/                   ← Empty templates for your team rules
│   │   ├── coding-style.md
│   │   ├── testing.md
│   │   ├── security.md
│   │   ├── git-workflow.md
│   │   └── domain-glossary.md
│   ├── skills/                  ← Add your reusable skills here
│   └── examples/                ← Add good/bad code patterns here
│       ├── good/
│       └── bad/
```

All files are empty templates — you fill in the content that fits your project.

## Core Concepts

### AGENTS.md
- **Single entry point** for all AI agents
- Sections for project overview, build commands, boundaries, and links
- Keep it under 200 lines

### .agent/rules/
Five empty templates ready for your team's rules:
- **coding-style.md** — Code conventions and best practices
- **testing.md** — Testing standards and patterns
- **security.md** — Security guidelines and checklists
- **git-workflow.md** — Git conventions and PR process
- **domain-glossary.md** — Project-specific terminology

### .agent/skills/
Empty directory. Add reusable skill templates as you build them:
```
.agent/skills/
└── my-skill/
    ├── SKILL.md              # Metadata (name, description)
    ├── references/           # Detailed documentation
    ├── assets/               # Templates and code snippets
    └── scripts/              # Executable examples
```

### .agent/examples/
Empty directories for learning materials:
- **good/** — Code patterns to follow
- **bad/** — Anti-patterns to avoid

## Using It

### 1. Fill in AGENTS.md

Replace the placeholder comments with your project details:
```markdown
# Project Overview

An e-commerce API built with Node.js and PostgreSQL.

# Build & Test Commands

pnpm install
pnpm dev
pnpm test
```

### 2. Fill in Rule Files

Edit each file in `.agent/rules/`:
- `coding-style.md` — Your language-specific conventions
- `testing.md` — Your coverage targets and patterns
- `security.md` — Your security requirements
- `git-workflow.md` — Your branch/commit conventions
- `domain-glossary.md` — Your project-specific terms

### 3. Build Your Skills Library

Create skills in `.agent/skills/` as you discover repeatable patterns.

### 4. Add Examples

In `.agent/examples/good/` and `.agent/examples/bad/`, add real code from your project to teach AI agents what to follow and what to avoid.

## Best Practices

- **Keep AGENTS.md lean** — under 200 lines, link to detailed rules
- **One topic per rule file** — focused and easy to find
- **Grow skills over time** — add as you build
- **Add real examples** — from your actual codebase

## FAQ

**Q: Do I need to specify my tech stack?**
A: No. The templates are language-agnostic — fill them in for your stack.

**Q: Can I delete rule files I don't need?**
A: Yes. Remove any file and update the link in AGENTS.md.

**Q: Can I add more rule files?**
A: Yes. Create new `.md` files in `.agent/rules/` and link them from AGENTS.md.

## Repository

GitHub: https://github.com/chentianming11/agent-friendly-structure

---

**Simple. Practical. AI-Friendly.**
