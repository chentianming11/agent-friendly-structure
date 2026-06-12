# Agent-Friendly Structure

[English Documentation](./README.md)

一个简单、实用的工具，用于初始化 AI 友好的项目结构。

## 快速开始

**独立模式**（单个项目）：
```bash
curl -sSL https://raw.githubusercontent.com/chentianming11/agent-friendly-structure/main/init-agent-structure-zh.sh | bash
```

**团队模式**（跨项目共享规则）：
```bash
curl -sSL https://raw.githubusercontent.com/chentianming11/agent-friendly-structure/main/init-agent-structure-zh.sh | bash -s -- --team https://github.com/your-team/agent-rules.git
```

完成。不需要其他参数。

## 两种模式

### 独立模式
在项目中创建空模板。所有规则由你自己填写。

### 团队模式
使用 git submodule 链接团队共享规则仓库。当多个项目共享相同的编码规范、测试实践和安全指南时非常适用。

**团队模式创建：**
```
.
├── AGENTS.md                    ← 项目专属（你来填写）
├── .agent → submodule           ← 团队共享规则（来自你的团队仓库）
│   ├── rules/
│   ├── skills/
│   └── examples/
└── .agent-project/
    └── rules/
        └── domain-glossary.md   ← 项目专属术语表
```

**更新团队规则：**
```bash
git submodule update --remote .agent
git commit -am 'chore: 更新团队 agent 规则'
```

## 做了什么

创建骨架结构：

```
.
├── AGENTS.md                    ← AI agent 的项目入口点
├── .agent/
│   ├── rules/                   ← 空模板，由你填写团队规则
│   │   ├── coding-style.md
│   │   ├── testing.md
│   │   ├── security.md
│   │   ├── git-workflow.md
│   │   └── domain-glossary.md
│   ├── skills/                  ← 在此添加你的可复用技能
│   └── examples/                ← 在此添加好/坏代码模式
│       ├── good/
│       └── bad/
```

所有文件都是空模板 — 由你填写适合项目的内容。

## 核心概念

### AGENTS.md
- 所有 AI agent 的**唯一入口**
- 包含项目概述、构建命令、边界规则和链接等章节
- 保持在 200 行以内

### .agent/rules/
五个空模板，用于填写你团队的规则：
- **coding-style.md** — 代码约定和最佳实践
- **testing.md** — 测试标准和模式
- **security.md** — 安全指南和检查清单
- **git-workflow.md** — Git 约定和 PR 流程
- **domain-glossary.md** — 项目特定术语

### .agent/skills/
空目录。在构建过程中添加可复用的技能模板：
```
.agent/skills/
└── my-skill/
    ├── SKILL.md              # 元数据（名称、描述）
    ├── references/           # 详细文档
    ├── assets/               # 模板和代码片段
    └── scripts/              # 可执行示例
```

### .agent/examples/
空目录，用于学习材料：
- **good/** — 要遵循的代码模式
- **bad/** — 要避免的反模式

## 使用方法

### 独立模式

运行脚本后，你的项目结构如下：

```
.
├── AGENTS.md                    ← 填写项目详情
└── .agent/
    ├── rules/                   ← 5 个空模板，需要填写
    ├── skills/                  ← 空目录，逐步添加技能
    └── examples/                ← 空目录，逐步添加示例
```

**第 1 步：填写 AGENTS.md**

将占位注释替换为你的项目详情：
```markdown
# 项目概述

一个基于 Node.js 和 PostgreSQL 的电商 API。

# 构建和测试命令

pnpm install
pnpm dev
pnpm test
```

**第 2 步：填写规则文件**

编辑 `.agent/rules/` 中的每个文件：
- `coding-style.md` — 你的语言特定约定
- `testing.md` — 你的覆盖率目标和模式
- `security.md` — 你的安全要求
- `git-workflow.md` — 你的分支/提交约定
- `domain-glossary.md` — 你的项目特定术语

**第 3 步：构建技能库**

当你发现可复用的模式时，在 `.agent/skills/` 中创建技能。

**第 4 步：添加示例**

在 `.agent/examples/good/` 和 `.agent/examples/bad/` 中，添加来自你项目的真实代码，教 AI agent 什么该遵循、什么该避免。

### 团队模式

使用 `--team` 参数运行脚本后，你的项目结构如下：

```
.
├── AGENTS.md                    ← 填写项目详情（项目专属）
├── .agent → submodule           ← 团队共享规则（不要直接编辑）
│   ├── rules/
│   ├── skills/
│   └── examples/
└── .agent-project/
    └── rules/
        └── domain-glossary.md   ← 填写项目专属术语表
```

**第 1 步：填写 AGENTS.md**

与独立模式相同 — 描述项目概述、构建命令、边界规则和陷阱。

**第 2 步：填写项目专属规则**

编辑 `.agent-project/rules/domain-glossary.md`，填写你项目的术语。也可以在这里添加更多项目专属规则文件。

**第 3 步：使用团队共享规则**

`.agent/` 中的规则、技能和示例来自团队共享仓库。**不要直接编辑** — 修改应在团队仓库中进行。

**第 4 步：更新团队规则**

当团队仓库更新后，拉取最新内容：
```bash
git submodule update --remote .agent
git commit -am 'chore: 更新团队 agent 规则'
```

**第 5 步：提交**
```bash
git add -A
git commit -m 'chore: 初始化 agent 友好的结构'
```

## 最佳实践

- **保持 AGENTS.md 精简** — 200 行以内，链接到详细规则
- **每个规则文件一个主题** — 专注且易于查找
- **逐步增长技能** — 随着构建而添加
- **添加真实示例** — 来自你实际的代码库

## 常见问题

**Q: 我需要指定技术栈吗？**
A: 不需要。模板是语言无关的 — 根据你的技术栈填写即可。

**Q: 我可以删除不需要的规则文件吗？**
A: 可以。删除任何文件并更新 AGENTS.md 中的链接。

**Q: 我可以添加更多规则文件吗？**
A: 可以。在 `.agent/rules/` 中创建新的 `.md` 文件，并从 AGENTS.md 链接它们。

## 仓库

GitHub: https://github.com/chentianming11/agent-friendly-structure

---

**简单。实用。AI 友好。**
