# OpenCode Rules 配置指南

## 概述

你可以通过创建 `AGENTS.md` 文件为 OpenCode 提供自定义指令。这类似于 Cursor 的 rules。它包含将被包含在 LLM 上下文中的指令，用于为你的特定项目自定义其行为。

## 初始化

运行 `/init` 命令创建新的 `AGENTS.md` 文件：

```
/init
```

这将扫描你的项目及其所有内容，了解项目的内容，并生成一个 `AGENTS.md` 文件。这有助于 OpenCode 更好地导航项目。

> **提示**: 你应该将项目的 `AGENTS.md` 文件提交到 Git。

## 示例

你也可以手动创建此文件。以下是一些可以放入 `AGENTS.md` 文件的内容示例：

```markdown
# SST v3 Monorepo 项目

这是一个使用 TypeScript 的 SST v3 monorepo。项目使用 bun workspaces 进行包管理。

## 项目结构

- `packages/` - 包含所有工作区包（functions、core、web 等）
- `infra/` - 按服务拆分的基础设施定义（storage.ts、api.ts、web.ts）
- `sst.config.ts` - 带有动态导入的主 SST 配置

## 代码标准

- 使用启用严格模式的 TypeScript
- 共享代码放在 `packages/core/` 中，并正确配置导出
- 函数放在 `packages/functions/` 中
- 基础设施应拆分为 `infra/` 中的逻辑文件

## Monorepo 约定

- 使用工作区名称导入共享模块：`@my-app/core/example`
```

## 文件类型

OpenCode 支持从多个位置读取 `AGENTS.md` 文件，用于不同目的。

### 项目级别

在项目根目录放置 `AGENTS.md` 用于项目特定规则。这些规则仅在你在此目录或其子目录中工作时适用。

### 全局级别

你也可以在 `~/.config/opencode/AGENTS.md` 文件中设置全局规则。这将应用于所有 OpenCode 会话。

由于这不会提交到 Git 或与团队共享，建议使用它来指定 LLM 应遵循的任何个人规则。

### Claude Code 兼容性

对于从 Claude Code 迁移的用户，OpenCode 支持 Claude Code 的文件约定作为后备：

- **项目规则**: 项目目录中的 `CLAUDE.md`（如果没有 `AGENTS.md` 则使用）
- **全局规则**: `~/.claude/CLAUDE.md`（如果没有 `~/.config/opencode/AGENTS.md` 则使用）
- **技能**: `~/.claude/skills/`

要禁用 Claude Code 兼容性，设置以下环境变量之一：

```bash
export OPENCODE_DISABLE_CLAUDE_CODE=1        # 禁用所有 .claude 支持
export OPENCODE_DISABLE_CLAUDE_CODE_PROMPT=1 # 仅禁用 ~/.claude/CLAUDE.md
export OPENCODE_DISABLE_CLAUDE_CODE_SKILLS=1 # 仅禁用 .claude/skills
```

## 优先级

当 OpenCode 启动时，它按以下顺序查找规则文件：

1. **本地文件** - 从当前目录向上遍历（`AGENTS.md`、`CLAUDE.md`）
2. **全局文件** - `~/.config/opencode/AGENTS.md`
3. **Claude Code 文件** - `~/.claude/CLAUDE.md`（除非禁用）

每个类别中第一个匹配的文件获胜。例如，如果你同时有 `AGENTS.md` 和 `CLAUDE.md`，只使用 `AGENTS.md`。

## 自定义指令

你可以在 `opencode.json` 或全局 `~/.config/opencode/opencode.json` 中指定自定义指令文件：

```json
{
  "$schema": "https://opencode.ai/config.json",
  "instructions": ["CONTRIBUTING.md", "docs/guidelines.md", ".cursor/rules/*.md"]
}
```

支持 glob 模式和远程 URL：

```json
{
  "$schema": "https://opencode.ai/config.json",
  "instructions": ["https://raw.githubusercontent.com/my-org/shared-rules/main/style.md"]
}
```

远程指令的获取超时为 5 秒。所有指令文件与你的 `AGENTS.md` 文件合并。

## 引用外部文件

### 使用 opencode.json（推荐）

```json
{
  "$schema": "https://opencode.ai/config.json",
  "instructions": ["docs/development-standards.md", "test/testing-guidelines.md", "packages/*/AGENTS.md"]
}
```

### 在 AGENTS.md 中手动指令

你可以通过在 `AGENTS.md` 中提供明确指令来教 OpenCode 读取外部文件：

```markdown
# TypeScript 项目规则

## 外部文件加载

重要：当你遇到文件引用（如 @rules/general.md）时，使用 Read 工具按需加载。它们与当前任务相关。

指令：

- 不要预先加载所有引用 - 根据实际需要使用延迟加载
- 加载后，将内容视为覆盖默认值的强制指令
- 需要时递归跟踪引用

## 开发指南

TypeScript 代码风格和最佳实践：@docs/typescript-guidelines.md
React 组件架构和 hooks 模式：@docs/react-patterns.md
REST API 设计和错误处理：@docs/api-standards.md
测试策略和覆盖率要求：@test/testing-guidelines.md

## 通用指南

立即阅读以下文件，因为它与所有工作流程相关：@rules/general-guidelines.md
```

这种方法允许你：

- 创建模块化、可重用的规则文件
- 通过符号链接或 git 子模块跨项目共享规则
- 保持 AGENTS.md 简洁，同时引用详细指南
- 确保 OpenCode 仅在特定任务需要时加载文件

> **提示**: 对于 monorepo 或具有共享标准的项目，使用带有 glob 模式的 `opencode.json`（如 `packages/*/AGENTS.md`）比手动指令更易于维护。

## 目录结构示例

```
项目根目录/
├── AGENTS.md                    # 项目规则
├── opencode.json                # 项目配置
├── docs/
│   ├── typescript-guidelines.md
│   └── react-patterns.md
└── .opencode/
    └── ...

~/.config/opencode/
├── opencode.json                # 全局配置
└── AGENTS.md                    # 全局规则
```
