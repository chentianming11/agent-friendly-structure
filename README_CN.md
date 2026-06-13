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
使用 **git subtree** 把团队共享规则仓库内嵌到 `.agents/` 目录。当多个项目共享相同的编码规范、测试实践和安全指南时非常适用。与 submodule 不同，规则文件就是仓库里的普通文件——`git clone` 直接拿到，无需 `git submodule init`。

**团队模式创建：**
```
.
├── AGENTS.md                    ← 项目入口（Cursor/Copilot 自动加载；由你填写）
├── CLAUDE.md                    ← 一行桥接 `@AGENTS.md`，让 Claude Code 读取 AGENTS.md
├── .agents/                     ← 通过 git subtree 嵌入的团队共享规则（真实文件，不是指针）
│   ├── rules/                   ← 共享规则文件（改动应提交到团队仓库，然后 `subtree pull`）
│   ├── skills/                  ← 共享的可复用技能模板
│   └── examples/                ← 共享的好/坏代码示例
└── .agents-project/             ← 项目专属覆盖（保留在本仓库内）
    └── rules/
        └── domain-glossary.md   ← 项目专属术语表（由你填写）
```

**从团队仓库拉取最新规则：**
```bash
git subtree pull --prefix=.agents <团队仓库 URL> <分支> --squash
```

## 做了什么

创建骨架结构：

```
.
├── AGENTS.md                    ← AI agent 的项目入口点（Cursor、Copilot 等会自动加载）
├── CLAUDE.md                    ← 仅一行的桥接文件：`@AGENTS.md`，供 Claude Code 使用
├── .agents/                     ← Agent 需要了解的项目信息全部放在这里
│   ├── rules/                   ← 项目权威规则（按需读取）
│   │   ├── coding-style.md      ← 代码约定与风格
│   │   ├── testing.md           ← 测试标准与模式
│   │   ├── security.md          ← 安全要求与检查清单
│   │   ├── git-workflow.md      ← 分支、提交、PR 流程
│   │   └── domain-glossary.md   ← 项目特定术语
│   ├── skills/                  ← 可复用技能模板（任务匹配时按需加载）
│   └── examples/                ← 项目中真实的代码示例
│       ├── good/                ← 要遵循的模式
│       └── bad/                 ← 要避免的反模式
```

所有文件都是空模板 — 由你填写适合项目的内容。

## 核心概念

### AGENTS.md
- 所有 AI agent 的**唯一入口**（跨工具标准）
- 包含项目概述、构建命令、边界规则，以及指向 `.agents/rules/` 和 `.agents/skills/` 的引导
- 保持在 200 行以内
- **不会硬编码**每个规则文件名 — Agent 会按需读取 `.agents/rules/` 目录，所以新增/删除规则文件时无需修改 AGENTS.md

### CLAUDE.md
- 内容只有一行：`@AGENTS.md`
- Claude Code 默认**不会**自动加载 `AGENTS.md`，需通过 `CLAUDE.md` 中的 `@import` 语法在会话启动时引入
- Cursor、GitHub Copilot 等 Agent 会直接读取 `AGENTS.md`，并忽略 `CLAUDE.md`

### .agents/rules/
五个空模板，用于填写你团队的规则：
- **coding-style.md** — 代码约定和最佳实践
- **testing.md** — 测试标准和模式
- **security.md** — 安全指南和检查清单
- **git-workflow.md** — Git 约定和 PR 流程
- **domain-glossary.md** — 项目特定术语

### .agents/skills/
空目录。在构建过程中添加可复用的技能模板：
```
.agents/skills/
└── my-skill/                    ← 每个技能一个目录
    ├── SKILL.md                 ← 技能元数据（名称、何时使用、描述）
    ├── references/              ← 技能引用的详细文档
    ├── assets/                  ← 技能要应用的模板和代码片段
    └── scripts/                 ← 可执行辅助脚本 / 可运行示例
```

### .agents/examples/
空目录，用于存放项目中的真实代码示例：
- **good/** — 展示最佳实践的实际代码
- **bad/** — 展示反模式的实际代码

**应该放什么：** 真实的源代码文件（不是 markdown），AI agent 可以从中学习。在文件顶部添加简短注释说明为什么好或坏。

**示例 - good/error-handling.ts:**
```typescript
// 好的做法：带有有意义消息的错误处理
export async function fetchUser(id: string): Promise<User> {
  const user = await db.users.findById(id);
  if (!user) {
    throw new UserNotFoundError(`User ${id} not found`);
  }
  return user;
}
```

**示例 - bad/error-handling.ts:**
```typescript
// 坏的做法：静默失败导致调试困难
export async function fetchUser(id: string): Promise<User> {
  try {
    return await db.users.findById(id);
  } catch (e) {
    return null;
  }
}
```

## 最佳实践

- **保持 AGENTS.md 精简** — 200 行以内，链接到详细规则
- **每个规则文件一个主题** — 专注且易于查找
- **逐步增长技能** — 随着构建而添加
- **添加真实示例** — 来自你实际的代码库

### Agent 如何决定加载 `.agents/rules/*.md`

`.agents/rules/` 下的文件**不会**在会话启动时被预加载到 Agent 的 context 里。Claude Code 和 Cursor 都是**按需读取**，而 Agent 是否决定打开某个文件，依赖两个信号：

1. **AGENTS.md 中的引导语** —— 脚本里写了"把 `.agents/rules/` 视为项目权威规则"这样的明确说明，请不要削弱它。
2. **文件名本身** —— Agent 会用当前任务和文件名做语义匹配，来判断要不要读这个文件。

实操含义：

- ✅ **使用自描述的文件名**：`coding-style.md`、`testing.md`、`pr-review.md`、`kafka-conventions.md`。像 `rules1.md`、`notes.md`、`misc.md` 这类泛化名字几乎不会被读取——模型猜不出它们什么时候适用。
- ✅ **领域专属规则放进主题命名的文件**，不要堆进一个杂物篮。
- ⚠️ **想让某条规则每次会话都被加载？** 把它直接写进 `AGENTS.md` 正文——那是两边工具唯一会自动加载的内容。

## 常见问题

**Q: 我需要指定技术栈吗？**
A: 不需要。模板是语言无关的 — 根据你的技术栈填写即可。

**Q: 我可以删除不需要的规则文件吗？**
A: 可以。直接删除文件即可。AGENTS.md 整体引用 `.agents/rules/` 目录，无需修改。

**Q: 我可以添加更多规则文件吗？**
A: 可以。直接在 `.agents/rules/` 中创建新的 `.md` 文件。Agent 会按需读取整个目录，AGENTS.md 不需要逐个列举。

**Q: 为什么有一个只包含 `@AGENTS.md` 的 `CLAUDE.md`？**
A: Claude Code 默认不会自动加载 `AGENTS.md`（[官方文档](https://code.claude.com/docs/en/memory)）。`@AGENTS.md` 这个 import 语法是官方推荐的桥接方式。Cursor、Copilot 等 Agent 会直接读取 `AGENTS.md`，不会用到 `CLAUDE.md`。

## 仓库

GitHub: https://github.com/chentianming11/agent-friendly-structure

---

**简单。实用。AI 友好。**
