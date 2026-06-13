#!/bin/bash

# Agent-friendly project structure initialization script
# Usage:
#   bash init-agent-structure.sh                     # standalone mode
#   bash init-agent-structure.sh --team <git-url>    # with team shared rules
# Run in your project root directory

set -e

PROJECT_NAME=$(basename "$(pwd)")
TEAM_REPO=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --team)
      TEAM_REPO="$2"
      shift 2
      ;;
    --help|-h)
      echo "Usage: bash init-agent-structure.sh [--team <git-url>]"
      echo ""
      echo "Options:"
      echo "  --team <git-url>  Vendor team shared rules into .agents/ via git subtree"
      echo "                    Example: --team https://github.com/your-team/agent-rules.git"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Use --help for usage information"
      exit 1
      ;;
  esac
done

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m'

if [ -n "$TEAM_REPO" ]; then
  echo -e "${BLUE}🚀 Initializing agent-friendly project structure for: $PROJECT_NAME${NC}"
  echo -e "${YELLOW}   Team mode: $TEAM_REPO${NC}"
else
  echo -e "${BLUE}🚀 Initializing agent-friendly project structure for: $PROJECT_NAME${NC}"
fi
echo ""

# Create AGENTS.md
cat > AGENTS.md << 'AGENTS_EOF'
# Project Overview

<!-- Describe: What is this project? Tech stack? Key services? -->

# Build & Test Commands

<!-- List your project commands, e.g.: -->
<!-- pnpm install / pnpm dev / pnpm test / pnpm lint -->

# Boundaries

**Always do:**
<!-- Add your rules -->

**Ask first:**
<!-- Add your rules -->

**Never do:**
<!-- Add your rules -->

# Project Rules

Detailed development rules live in `.agents/rules/`. Read every `.md` file
under that directory as authoritative project rules and follow them when
handling related tasks.

# Skills

Reusable skill templates live in `.agents/skills/`. Read them on demand
when a task matches a skill's purpose.

# Examples

Reference code lives in `.agents/examples/good/` (patterns to follow) and
`.agents/examples/bad/` (anti-patterns to avoid).

# Non-Obvious Gotchas

<!-- Add project-specific gotchas -->
AGENTS_EOF

echo -e "${GREEN}✓ Created AGENTS.md${NC}"

# Create CLAUDE.md bridge so Claude Code reads AGENTS.md.
# Claude Code does not auto-load AGENTS.md; @import pulls it into context.
cat > CLAUDE.md << 'CLAUDE_EOF'
@AGENTS.md
CLAUDE_EOF

echo -e "${GREEN}✓ Created CLAUDE.md (bridges AGENTS.md for Claude Code)${NC}"

if [ -n "$TEAM_REPO" ]; then
  # Team mode: use git subtree (vendors team rules into this repo so a plain
  # `git clone` ships them — no submodule init, no .gitmodules).

  # Ensure we're in a git repo
  if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠ Not a git repo, initializing...${NC}"
    git init
    echo -e "${GREEN}✓ Initialized git repository${NC}"
  fi

  # Detect the remote's default branch so we don't hardcode main vs master.
  TEAM_BRANCH=$(git ls-remote --symref "$TEAM_REPO" HEAD 2>/dev/null \
    | awk '/^ref:/ {sub("refs/heads/","",$2); print $2; exit}')
  TEAM_BRANCH="${TEAM_BRANCH:-main}"

  # `git subtree add` builds a merge commit, so HEAD must exist. Bootstrap an
  # initial commit from AGENTS.md/CLAUDE.md if the repo has no commits yet.
  if ! git rev-parse HEAD > /dev/null 2>&1; then
    git add AGENTS.md CLAUDE.md
    git commit -q -m "chore: bootstrap AGENTS.md and CLAUDE.md"
    echo -e "${GREEN}✓ Created initial commit${NC}"
  fi

  if [ -d ".agents" ]; then
    echo -e "${YELLOW}⚠ .agents/ already exists, skipping subtree${NC}"
  else
    git subtree add --prefix=.agents "$TEAM_REPO" "$TEAM_BRANCH" --squash
    echo -e "${GREEN}✓ Vendored team rules as subtree (.agents/, branch: $TEAM_BRANCH)${NC}"
  fi

  # Create project-specific rules directory
  mkdir -p .agents-project/rules

  # Create domain-glossary in project-specific dir
  cat > .agents-project/rules/domain-glossary.md << 'EOF'
# domain-glossary

<!-- Add your project-specific terminology here -->
EOF

  echo -e "${GREEN}✓ Created .agents-project/rules/ for project-specific rules${NC}"

  # Append a pointer so agents see the project-specific rules dir, not just the vendored team rules.
  cat >> AGENTS.md << 'AGENTS_PROJECT_EOF'

# Project-Specific Rules

This project also keeps overrides and project-only rules in `.agents-project/rules/`.
Read every `.md` file under that directory — it lives in this repo (not the
vendored team subtree) and takes precedence over the shared rules in
`.agents/rules/` when they conflict.
AGENTS_PROJECT_EOF

  echo -e "${GREEN}✓ Appended .agents-project/ pointer to AGENTS.md${NC}"

  echo ""
  echo -e "${GREEN}✅ Project structure initialized (team mode)!${NC}"
  echo ""
  echo "📋 Next steps:"
  echo "   1. Edit AGENTS.md with your project details"
  echo "   2. Fill in .agents-project/rules/domain-glossary.md"
  echo "   3. git add -A && git commit -m 'chore: initialize agent-friendly structure'"
  echo ""
  echo "📋 Pull updates from the team rules repo:"
  echo "   git subtree pull --prefix=.agents $TEAM_REPO $TEAM_BRANCH --squash"
  echo ""
  echo -e "${BLUE}📖 See README.md for full documentation${NC}"

else
  # Standalone mode: create empty templates

  # Create directory structure
  mkdir -p .agents/rules
  mkdir -p .agents/skills
  mkdir -p .agents/examples/good
  mkdir -p .agents/examples/bad

  echo -e "${GREEN}✓ Created directory structure${NC}"

  # Create rule file skeletons
  for rule in coding-style testing security git-workflow domain-glossary; do
    cat > ".agents/rules/${rule}.md" << EOF
# ${rule}

<!-- Add your ${rule} rules here -->
EOF
  done

  echo -e "${GREEN}✓ Created .agents/rules/ (5 empty templates)${NC}"

  echo -e "${GREEN}✓ Created .agents/examples/{good,bad}${NC}"

  echo ""
  echo -e "${GREEN}✅ Project structure initialized!${NC}"
  echo ""
  echo "📋 Next steps:"
  echo "   1. Edit AGENTS.md with your project details"
  echo "   2. Fill in .agents/rules/ files"
  echo "   3. git add -A && git commit -m 'chore: initialize agent-friendly structure'"
  echo ""
  echo -e "${BLUE}📖 See README.md for full documentation${NC}"
fi
