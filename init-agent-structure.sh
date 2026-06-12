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
      echo "  --team <git-url>  Add team shared rules as git submodule"
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

# Code Style

See `.agent/rules/coding-style.md`

# Testing

See `.agent/rules/testing.md`

# Security

See `.agent/rules/security.md`

# Git Workflow

See `.agent/rules/git-workflow.md`

# Domain Glossary

See `.agent/rules/domain-glossary.md`

# Skills

See `.agent/skills/`

# Examples

See `.agent/examples/good/` for patterns to follow, `.agent/examples/bad/` for anti-patterns to avoid.

# Non-Obvious Gotchas

<!-- Add project-specific gotchas -->
AGENTS_EOF

echo -e "${GREEN}✓ Created AGENTS.md${NC}"

if [ -n "$TEAM_REPO" ]; then
  # Team mode: use git submodule

  # Ensure we're in a git repo
  if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠ Not a git repo, initializing...${NC}"
    git init
    echo -e "${GREEN}✓ Initialized git repository${NC}"
  fi

  # Add team repo as submodule
  if [ -d ".agent" ]; then
    echo -e "${YELLOW}⚠ .agent/ already exists, skipping submodule${NC}"
  else
    git submodule add "$TEAM_REPO" .agent
    echo -e "${GREEN}✓ Added team rules as submodule (.agent/)${NC}"
  fi

  # Create project-specific rules directory
  mkdir -p .agent-project/rules

  # Create domain-glossary in project-specific dir
  cat > .agent-project/rules/domain-glossary.md << 'EOF'
# domain-glossary

<!-- Add your project-specific terminology here -->
EOF

  echo -e "${GREEN}✓ Created .agent-project/rules/ for project-specific rules${NC}"

  # Update AGENTS.md domain-glossary link to point to project-specific
  sed -i.bak 's|See `.agent/rules/domain-glossary.md`|See `.agent-project/rules/domain-glossary.md`|' AGENTS.md
  rm -f AGENTS.md.bak

  echo ""
  echo -e "${GREEN}✅ Project structure initialized (team mode)!${NC}"
  echo ""
  echo "📋 Next steps:"
  echo "   1. Edit AGENTS.md with your project details"
  echo "   2. Fill in .agent-project/rules/domain-glossary.md"
  echo "   3. git add -A && git commit -m 'chore: initialize agent-friendly structure'"
  echo ""
  echo "📋 Update team shared rules:"
  echo "   git submodule update --remote .agent"
  echo "   git commit -am 'chore: update team agent rules'"
  echo ""
  echo -e "${BLUE}📖 See README.md for full documentation${NC}"

else
  # Standalone mode: create empty templates

  # Create directory structure
  mkdir -p .agent/rules
  mkdir -p .agent/skills
  mkdir -p .agent/examples/good
  mkdir -p .agent/examples/bad

  echo -e "${GREEN}✓ Created directory structure${NC}"

  # Create rule file skeletons
  for rule in coding-style testing security git-workflow domain-glossary; do
    cat > ".agent/rules/${rule}.md" << EOF
# ${rule}

<!-- Add your ${rule} rules here -->
EOF
  done

  echo -e "${GREEN}✓ Created .agent/rules/ (5 empty templates)${NC}"

  echo -e "${GREEN}✓ Created .agent/examples/{good,bad}${NC}"

  echo ""
  echo -e "${GREEN}✅ Project structure initialized!${NC}"
  echo ""
  echo "📋 Next steps:"
  echo "   1. Edit AGENTS.md with your project details"
  echo "   2. Fill in .agent/rules/ files"
  echo "   3. git add -A && git commit -m 'chore: initialize agent-friendly structure'"
  echo ""
  echo -e "${BLUE}📖 See README.md for full documentation${NC}"
fi
