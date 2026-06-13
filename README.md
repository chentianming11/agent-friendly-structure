# Agent-Friendly Structure

[中文文档](./README_CN.md)

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
Uses **git subtree** to vendor a shared team rules repository into `.agents/`. Perfect when multiple projects share the same coding standards, testing practices, and security guidelines. Unlike submodules, the rules are real files in your repo — a plain `git clone` ships them, no `git submodule init` needed.

**Team mode creates:**
```
.
├── AGENTS.md                    ← Project entry point (Cursor/Copilot auto-load; you fill this)
├── CLAUDE.md                    ← One-line bridge `@AGENTS.md` so Claude Code reads AGENTS.md
├── .agents/                     ← Team shared rules vendored via git subtree (real files, not a pointer)
│   ├── rules/                   ← Shared rule files (changes should go to the team repo, then `subtree pull`)
│   ├── skills/                  ← Shared reusable skill templates
│   └── examples/                ← Shared good/bad code patterns
└── .agents-project/             ← Project-specific overrides (lives in this repo)
    └── rules/
        └── domain-glossary.md   ← Project-specific terminology (you fill this)
```

**Pull updates from the team repo:**
```bash
git subtree pull --prefix=.agents <team-repo-url> <branch> --squash
```

## What It Does

Creates the skeleton structure:

```
.
├── AGENTS.md                    ← Project entry point for AI agents (Cursor, Copilot, etc. auto-load)
├── CLAUDE.md                    ← One-line bridge for Claude Code: `@AGENTS.md`
├── .agents/                     ← Everything agents need to know about your project
│   ├── rules/                   ← Authoritative project rules (read on demand)
│   │   ├── coding-style.md      ← Code conventions and style
│   │   ├── testing.md           ← Testing standards and patterns
│   │   ├── security.md          ← Security requirements and checklists
│   │   ├── git-workflow.md      ← Branching, commits, PR conventions
│   │   └── domain-glossary.md   ← Project-specific terminology
│   ├── skills/                  ← Reusable skill templates (load on demand when matching task)
│   └── examples/                ← Real code patterns from your project
│       ├── good/                ← Patterns to follow
│       └── bad/                 ← Anti-patterns to avoid
```

All files are empty templates — you fill in the content that fits your project.

## Core Concepts

### AGENTS.md
- **Single entry point** for all AI agents (cross-tool standard)
- Sections for project overview, build commands, boundaries, and pointers to `.agents/rules/` and `.agents/skills/`
- Keep it under 200 lines
- Does **not** hardcode every rule filename — agents read `.agents/rules/` on demand, so you can add or remove rule files without editing AGENTS.md

### CLAUDE.md
- A single-line file: `@AGENTS.md`
- Claude Code does not auto-load `AGENTS.md` natively — `CLAUDE.md` with the `@import` syntax brings the same content into Claude Code's session context at launch
- Cursor, GitHub Copilot, and other agents read `AGENTS.md` directly and ignore `CLAUDE.md`

### .agents/rules/
Five empty templates ready for your team's rules:
- **coding-style.md** — Code conventions and best practices
- **testing.md** — Testing standards and patterns
- **security.md** — Security guidelines and checklists
- **git-workflow.md** — Git conventions and PR process
- **domain-glossary.md** — Project-specific terminology

### .agents/skills/
Empty directory. Add reusable skill templates as you build them:
```
.agents/skills/
└── my-skill/                    ← One directory per skill
    ├── SKILL.md                 ← Skill metadata (name, when to use, description)
    ├── references/              ← Detailed documentation the skill cites
    ├── assets/                  ← Templates and code snippets the skill applies
    └── scripts/                 ← Executable helpers / runnable examples
```

### .agents/examples/
Empty directories for real code examples from your project:
- **good/** — Actual code that demonstrates best practices
- **bad/** — Actual code that shows anti-patterns to avoid

**What to put here:** Real source files (not markdown) that AI agents can learn from. Include a brief comment at the top explaining why it's good or bad.

**Example - good/error-handling.ts:**
```typescript
// Good: Proper error handling with meaningful messages
export async function fetchUser(id: string): Promise<User> {
  const user = await db.users.findById(id);
  if (!user) {
    throw new UserNotFoundError(`User ${id} not found`);
  }
  return user;
}
```

**Example - bad/error-handling.ts:**
```typescript
// Bad: Silent failure makes debugging impossible
export async function fetchUser(id: string): Promise<User> {
  try {
    return await db.users.findById(id);
  } catch (e) {
    return null;
  }
}
```

## Best Practices

- **Keep AGENTS.md lean** — under 200 lines, link to detailed rules
- **One topic per rule file** — focused and easy to find
- **Grow skills over time** — add as you build
- **Add real examples** — from your actual codebase

### How agents decide to load `.agents/rules/*.md`

Files under `.agents/rules/` are **not** preloaded into the agent's context at session start. Both Claude Code and Cursor read them **on demand**, and the agent's decision relies on two signals:

1. **The pointer in `AGENTS.md`** — the script writes a clear instruction telling the agent to treat `.agents/rules/` as authoritative project rules. Don't water it down.
2. **The filename itself** — the agent matches the current task against the filename to decide whether to open the file.

Practical implications:

- ✅ **Use self-describing filenames**: `coding-style.md`, `testing.md`, `pr-review.md`, `kafka-conventions.md`. Generic names like `rules1.md`, `notes.md`, or `misc.md` rarely get read because nothing tells the model when they apply.
- ✅ **Put domain-specific rules in topic-named files**, not buried in a catch-all.
- ⚠️ **Want a rule loaded every single session?** Inline it in `AGENTS.md` itself — that's the only thing both tools auto-load.

## FAQ

**Q: Do I need to specify my tech stack?**
A: No. The templates are language-agnostic — fill them in for your stack.

**Q: Can I delete rule files I don't need?**
A: Yes. Just remove the file. AGENTS.md points at the `.agents/rules/` directory as a whole, so no AGENTS.md edit is needed.

**Q: Can I add more rule files?**
A: Yes. Drop new `.md` files into `.agents/rules/`. Agents read the directory on demand — AGENTS.md does not need to list each file.

**Q: Why is there a `CLAUDE.md` with just `@AGENTS.md`?**
A: Claude Code does not auto-load `AGENTS.md` ([official docs](https://code.claude.com/docs/en/memory)). The `@AGENTS.md` import is the official way to make Claude Code pick it up. Cursor, Copilot, and other agents read `AGENTS.md` directly and ignore `CLAUDE.md`.

## Repository

GitHub: https://github.com/chentianming11/agent-friendly-structure

---

**Simple. Practical. AI-Friendly.**
