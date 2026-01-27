# OpenCode Agents 配置指南

## 概述

Agents 是专门的 AI 助手，可以针对特定任务和工作流程进行配置。它们允许你创建具有自定义提示词、模型和工具访问权限的专用工具。

## Agent 类型

### 1. 主代理 (Primary Agents)

- 直接与用户交互的主要助手
- 使用 **Tab** 键在它们之间切换
- 内置: **Build** 和 **Plan**

### 2. 子代理 (Subagents)

- 主代理可以调用的专门助手
- 可以通过 **@** 提及手动调用
- 内置: **General** 和 **Explore**

## 内置 Agents

| Agent   | 模式   | 描述                                       |
| ------- | ------ | ------------------------------------------ |
| Build   | 主代理 | 默认代理，启用所有工具，用于开发工作       |
| Plan    | 主代理 | 受限代理，用于规划和分析，不修改代码       |
| General | 子代理 | 通用代理，用于研究复杂问题和执行多步骤任务 |
| Explore | 子代理 | 快速只读代理，用于探索代码库               |

## 配置方式

### 方式一: JSON 配置

在 `opencode.json` 中配置:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "agent": {
    "build": {
      "mode": "primary",
      "model": "anthropic/claude-sonnet-4-20250514",
      "prompt": "{file:./prompts/build.txt}",
      "tools": {
        "write": true,
        "edit": true,
        "bash": true
      }
    },
    "plan": {
      "mode": "primary",
      "model": "anthropic/claude-haiku-4-20250514",
      "tools": {
        "write": false,
        "edit": false,
        "bash": false
      }
    },
    "code-reviewer": {
      "description": "审查代码的最佳实践和潜在问题",
      "mode": "subagent",
      "model": "anthropic/claude-sonnet-4-20250514",
      "prompt": "你是一个代码审查员。专注于安全性、性能和可维护性。",
      "tools": {
        "write": false,
        "edit": false
      }
    }
  }
}
```

### 方式二: Markdown 文件配置

将 Markdown 文件放置在:

- 全局配置: `~/.config/opencode/agents/`
- 项目配置: `.opencode/agents/`

文件名即为 agent 名称，例如 `review.md` 创建名为 `review` 的 agent。

示例 `~/.config/opencode/agents/review.md`:

```markdown
---
description: 审查代码质量和最佳实践
mode: subagent
model: anthropic/claude-sonnet-4-20250514
temperature: 0.1
tools:
  write: false
  edit: false
  bash: false
---

你处于代码审查模式。专注于:

- 代码质量和最佳实践
- 潜在的 bug 和边界情况
- 性能影响
- 安全考虑

提供建设性反馈，但不直接修改代码。
```

## 配置选项详解

| 选项          | 类型   | 描述                                                  |
| ------------- | ------ | ----------------------------------------------------- |
| `description` | 字符串 | **必需** - Agent 的简短描述                           |
| `mode`        | 字符串 | `primary`(主代理), `subagent`(子代理), 或 `all`(默认) |
| `model`       | 字符串 | 覆盖此 agent 使用的模型，格式: `provider/model-id`    |
| `prompt`      | 字符串 | 自定义系统提示词，支持文件引用 `{file:./path}`        |
| `temperature` | 数字   | 控制响应的随机性 (0.0-1.0)                            |
| `maxSteps`    | 数字   | 最大迭代步数限制                                      |
| `disable`     | 布尔值 | 设为 `true` 禁用此 agent                              |
| `hidden`      | 布尔值 | 从 @ 自动完成菜单中隐藏（仅子代理）                   |
| `tools`       | 对象   | 控制可用工具                                          |
| `permission`  | 对象   | 配置权限                                              |

### Temperature 参考值

| 范围    | 用途                             |
| ------- | -------------------------------- |
| 0.0-0.2 | 代码分析和规划，非常专注和确定性 |
| 0.3-0.5 | 一般开发任务，平衡响应           |
| 0.6-1.0 | 头脑风暴和探索，更有创意         |

### 工具配置

```json
{
  "agent": {
    "readonly": {
      "tools": {
        "write": false,
        "edit": false,
        "mymcp_*": false
      }
    }
  }
}
```

支持通配符模式，如 `mymcp_*` 匹配所有以 `mymcp_` 开头的工具。

### 权限配置

```json
{
  "agent": {
    "build": {
      "permission": {
        "edit": "ask",
        "bash": {
          "*": "ask",
          "git status *": "allow",
          "git push": "ask"
        },
        "webfetch": "deny"
      }
    }
  }
}
```

权限值说明:
| 值 | 说明 |
|------|------|
| `"ask"` | 运行前提示用户批准 |
| `"allow"` | 允许所有操作，无需批准 |
| `"deny"` | 完全禁用该工具 |

### Task 权限 (控制子代理调用)

```json
{
  "agent": {
    "orchestrator": {
      "mode": "primary",
      "permission": {
        "task": {
          "*": "deny",
          "orchestrator-*": "allow",
          "code-reviewer": "ask"
        }
      }
    }
  }
}
```

规则按顺序评估，**最后匹配的规则生效**。

## 创建新 Agent

使用命令行交互式创建:

```bash
opencode agent create
```

该命令会引导你:

1. 选择保存位置（全局或项目）
2. 输入 agent 描述
3. 生成系统提示词和标识符
4. 选择可用工具
5. 创建 Markdown 配置文件

## 示例 Agents

### 文档编写 Agent

```markdown
---
description: 编写和维护项目文档
mode: subagent
tools:
  bash: false
---

你是一个技术文档编写者。创建清晰、全面的文档。

专注于:

- 清晰的解释
- 正确的结构
- 代码示例
- 用户友好的语言
```

### 安全审计 Agent

```markdown
---
description: 执行安全审计并识别漏洞
mode: subagent
tools:
  write: false
  edit: false
---

你是一个安全专家。专注于识别潜在的安全问题。

检查:

- 输入验证漏洞
- 身份验证和授权缺陷
- 数据暴露风险
- 依赖项漏洞
- 配置安全问题
```

## 使用方式

1. **切换主代理**: 使用 **Tab** 键循环切换
2. **调用子代理**: 在消息中使用 `@agent-name`，例如 `@general 帮我搜索这个函数`
3. **导航子会话**:
   - `<Leader>+Right` - 向前循环 (父会话 → 子会话1 → 子会话2 → ...)
   - `<Leader>+Left` - 向后循环
