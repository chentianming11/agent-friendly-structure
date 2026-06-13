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
      echo "  --team <git-url>  通过 git subtree 将团队共享规则嵌入到 .agents/ 目录"
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

# 项目规则

详细的开发规则存放在 `.agents/rules/` 目录下。处理相关任务时，请将该目录下的
所有 `.md` 文件视为项目权威规则并按需查阅。

# 技能

可复用的自定义技能存放在 `.agents/skills/` 目录下。当任务匹配某个技能时按需查阅。

# 示例

参考代码存放在 `.agents/examples/good/`（要遵循的模式）和 `.agents/examples/bad/`
（要避免的反模式）。

# 非显而易见的陷阱

<!-- 添加项目特定的陷阱 -->
AGENTS_EOF

echo -e "${GREEN}✓ 已创建 AGENTS.md${NC}"

# 创建 CLAUDE.md 桥接文件，使 Claude Code 能够读取 AGENTS.md
# Claude Code 默认不会自动加载 AGENTS.md，需通过 @import 引入
cat > CLAUDE.md << 'CLAUDE_EOF'
@AGENTS.md
CLAUDE_EOF

echo -e "${GREEN}✓ 已创建 CLAUDE.md（为 Claude Code 桥接 AGENTS.md）${NC}"

if [ -n "$TEAM_REPO" ]; then
  # 团队模式：使用 git subtree（把团队规则内容嵌入本仓库，普通 `git clone`
  # 即可拿到全部内容——不需要 submodule init，也没有 .gitmodules）。

  # 确保在 git 仓库中
  if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠ 不是 git 仓库，正在初始化...${NC}"
    git init
    echo -e "${GREEN}✓ 已初始化 git 仓库${NC}"
  fi

  # 自动探测远程默认分支，避免硬编码 main / master
  TEAM_BRANCH=$(git ls-remote --symref "$TEAM_REPO" HEAD 2>/dev/null \
    | awk '/^ref:/ {sub("refs/heads/","",$2); print $2; exit}')
  TEAM_BRANCH="${TEAM_BRANCH:-main}"

  # `git subtree add` 会生成 merge commit，要求 HEAD 已存在。
  # 若是空仓库，先用 AGENTS.md / CLAUDE.md 做一次初始提交。
  if ! git rev-parse HEAD > /dev/null 2>&1; then
    git add AGENTS.md CLAUDE.md
    git commit -q -m "chore: bootstrap AGENTS.md and CLAUDE.md"
    echo -e "${GREEN}✓ 已创建初始 commit${NC}"
  fi

  if [ -d ".agents" ]; then
    echo -e "${YELLOW}⚠ .agents/ 已存在，跳过 subtree${NC}"
  else
    git subtree add --prefix=.agents "$TEAM_REPO" "$TEAM_BRANCH" --squash
    echo -e "${GREEN}✓ 已通过 subtree 嵌入团队规则 (.agents/, 分支: $TEAM_BRANCH)${NC}"
  fi

  # 创建项目专属规则目录
  mkdir -p .agents-project/rules

  # 在项目专属目录创建 domain-glossary
  cat > .agents-project/rules/domain-glossary.md << 'EOF'
# domain-glossary

<!-- 在此添加项目特定术语 -->
EOF

  echo -e "${GREEN}✓ 已创建 .agents-project/rules/ 用于项目专属规则${NC}"

  # 追加项目专属规则目录的引导，避免 Agent 只看到 subtree 中的共享规则
  cat >> AGENTS.md << 'AGENTS_PROJECT_EOF'

# 项目专属规则

本项目还在 `.agents-project/rules/` 中维护覆盖与项目独有的规则。请读取该目录
下的所有 `.md` 文件——它存放于本仓库（不在嵌入的团队 subtree 中），且与
`.agents/rules/` 中的共享规则冲突时，以本目录为准。
AGENTS_PROJECT_EOF

  echo -e "${GREEN}✓ 已在 AGENTS.md 追加 .agents-project/ 引导${NC}"

  echo ""
  echo -e "${GREEN}✅ 项目结构初始化完成（团队模式）！${NC}"
  echo ""
  echo "📋 后续步骤："
  echo "   1. 编辑 AGENTS.md 填写项目详情"
  echo "   2. 填充 .agents-project/rules/domain-glossary.md"
  echo "   3. git add -A && git commit -m 'chore: 初始化 agent 友好的结构'"
  echo ""
  echo "📋 拉取团队仓库的最新规则："
  echo "   git subtree pull --prefix=.agents $TEAM_REPO $TEAM_BRANCH --squash"
  echo ""
  echo -e "${BLUE}📖 详见 README_CN.md 获取完整文档${NC}"

else
  # 独立模式：创建空模板

  # 创建目录结构
  mkdir -p .agents/rules
  mkdir -p .agents/skills
  mkdir -p .agents/examples/good
  mkdir -p .agents/examples/bad

  echo -e "${GREEN}✓ 已创建目录结构${NC}"

  # 创建规则文件骨架
  for rule in coding-style testing security git-workflow domain-glossary; do
    cat > ".agents/rules/${rule}.md" << EOF
# ${rule}

<!-- Add your ${rule} rules here -->
EOF
  done

  echo -e "${GREEN}✓ 已创建 .agents/rules/ (5 个空模板)${NC}"

  echo -e "${GREEN}✓ 已创建 .agents/examples/{good,bad}${NC}"

  echo ""
  echo -e "${GREEN}✅ 项目结构初始化完成！${NC}"
  echo ""
  echo "📋 后续步骤："
  echo "   1. 编辑 AGENTS.md 填写项目详情"
  echo "   2. 填充 .agents/rules/ 目录下的规则文件"
  echo "   3. git add -A && git commit -m 'chore: 初始化 agent 友好的结构'"
  echo ""
  echo -e "${BLUE}📖 详见 README_CN.md 获取完整文档${NC}"
fi
