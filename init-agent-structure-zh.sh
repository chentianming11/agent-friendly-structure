#!/bin/bash

# Agent 友好项目结构初始化脚本
# 用法:
#   bash init-agent-structure-zh.sh                     # 独立模式
#   bash init-agent-structure-zh.sh --team <git-url>    # 团队共享规则模式
# 在项目根目录下运行

set -e

PROJECT_NAME=$(basename "$(pwd)")
TEAM_REPO=""

# 解析参数
while [[ $# -gt 0 ]]; do
  case "$1" in
    --team)
      TEAM_REPO="$2"
      shift 2
      ;;
    --help|-h)
      echo "用法: bash init-agent-structure-zh.sh [--team <git-url>]"
      echo ""
      echo "选项:"
      echo "  --team <git-url>  将团队共享规则添加为 git submodule"
      echo "                    示例: --team https://github.com/your-team/agent-rules.git"
      exit 0
      ;;
    *)
      echo "未知选项: $1"
      echo "使用 --help 查看用法"
      exit 1
      ;;
  esac
done

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m'

if [ -n "$TEAM_REPO" ]; then
  echo -e "${BLUE}🚀 正在初始化 Agent 友好的项目结构: $PROJECT_NAME${NC}"
  echo -e "${YELLOW}   团队模式: $TEAM_REPO${NC}"
else
  echo -e "${BLUE}🚀 正在初始化 Agent 友好的项目结构: $PROJECT_NAME${NC}"
fi
echo ""

# 创建 AGENTS.md
cat > AGENTS.md << 'AGENTS_EOF'
# 项目概述

<!-- 描述：这个项目是什么？技术栈？核心服务？ -->

# 构建和测试命令

<!-- 列出项目命令，例如： -->
<!-- pnpm install / pnpm dev / pnpm test / pnpm lint -->

# 边界规则

**必须做：**
<!-- 添加你的规则 -->

**先询问：**
<!-- 添加你的规则 -->

**禁止做：**
<!-- 添加你的规则 -->

# 代码风格

详见 `.agent/rules/coding-style.md`

# 测试

详见 `.agent/rules/testing.md`

# 安全性

详见 `.agent/rules/security.md`

# Git 工作流

详见 `.agent/rules/git-workflow.md`

# 领域术语

详见 `.agent/rules/domain-glossary.md`

# 技能

详见 `.agent/skills/`

# 示例

详见 `.agent/examples/good/` 了解要遵循的模式，`.agent/examples/bad/` 了解要避免的反模式。

# 非显而易见的陷阱

<!-- 添加项目特定的陷阱 -->
AGENTS_EOF

echo -e "${GREEN}✓ 已创建 AGENTS.md${NC}"

if [ -n "$TEAM_REPO" ]; then
  # 团队模式：使用 git submodule

  # 确保在 git 仓库中
  if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠ 不是 git 仓库，正在初始化...${NC}"
    git init
    echo -e "${GREEN}✓ 已初始化 git 仓库${NC}"
  fi

  # 添加团队仓库作为 submodule
  if [ -d ".agent" ]; then
    echo -e "${YELLOW}⚠ .agent/ 已存在，跳过 submodule${NC}"
  else
    git submodule add "$TEAM_REPO" .agent
    echo -e "${GREEN}✓ 已添加团队规则为 submodule (.agent/)${NC}"
  fi

  # 创建项目专属规则目录
  mkdir -p .agent-project/rules

  # 在项目专属目录创建 domain-glossary
  cat > .agent-project/rules/domain-glossary.md << 'EOF'
# domain-glossary

<!-- 在此添加项目特定术语 -->
EOF

  echo -e "${GREEN}✓ 已创建 .agent-project/rules/ 用于项目专属规则${NC}"

  # 更新 AGENTS.md 中的 domain-glossary 链接指向项目专属目录
  sed -i.bak 's|See `.agent/rules/domain-glossary.md`|See `.agent-project/rules/domain-glossary.md`|' AGENTS.md
  rm -f AGENTS.md.bak

  echo ""
  echo -e "${GREEN}✅ 项目结构初始化完成（团队模式）！${NC}"
  echo ""
  echo "📋 后续步骤："
  echo "   1. 编辑 AGENTS.md 填写项目详情"
  echo "   2. 填充 .agent-project/rules/domain-glossary.md"
  echo "   3. git add -A && git commit -m 'chore: 初始化 agent 友好的结构'"
  echo ""
  echo "📋 更新团队共享规则："
  echo "   git submodule update --remote .agent"
  echo "   git commit -am 'chore: 更新团队 agent 规则'"
  echo ""
  echo -e "${BLUE}📖 详见 README_CN.md 获取完整文档${NC}"

else
  # 独立模式：创建空模板

  # 创建目录结构
  mkdir -p .agent/rules
  mkdir -p .agent/skills
  mkdir -p .agent/examples/good
  mkdir -p .agent/examples/bad

  echo -e "${GREEN}✓ 已创建目录结构${NC}"

  # 创建规则文件骨架
  for rule in coding-style testing security git-workflow domain-glossary; do
    cat > ".agent/rules/${rule}.md" << EOF
# ${rule}

<!-- Add your ${rule} rules here -->
EOF
  done

  echo -e "${GREEN}✓ 已创建 .agent/rules/ (5 个空模板)${NC}"

  echo -e "${GREEN}✓ 已创建 .agent/examples/{good,bad}${NC}"

  echo ""
  echo -e "${GREEN}✅ 项目结构初始化完成！${NC}"
  echo ""
  echo "📋 后续步骤："
  echo "   1. 编辑 AGENTS.md 填写项目详情"
  echo "   2. 填充 .agent/rules/ 目录下的规则文件"
  echo "   3. git add -A && git commit -m 'chore: 初始化 agent 友好的结构'"
  echo ""
  echo -e "${BLUE}📖 详见 README_CN.md 获取完整文档${NC}"
fi
