# OpenCode Commands 配置指南

## 概述

自定义命令让你可以指定一个提示词，在 TUI 中执行该命令时运行。

```
/my-command
```

自定义命令是内置命令（如 `/init`、`/undo`、`/redo`、`/share`、`/help`）的补充。

## 配置方式

### 方式一: JSON 配置

在 `opencode.json` 中使用 `command` 选项：

```json
{
  "$schema": "https://opencode.ai/config.json",
  "command": {
    "test": {
      "template": "运行完整的测试套件并生成覆盖率报告，显示所有失败的测试。\n专注于失败的测试并建议修复方案。",
      "description": "运行测试并生成覆盖率",
      "agent": "build",
      "model": "anthropic/claude-3-5-sonnet-20241022"
    }
  }
}
```

### 方式二: Markdown 文件配置

将 Markdown 文件放置在：

- 全局: `~/.config/opencode/commands/`
- 项目: `.opencode/commands/`

文件名即为命令名称。例如 `test.md` 创建 `/test` 命令。

示例 `.opencode/commands/test.md`：

```markdown
---
description: 运行测试并生成覆盖率
agent: build
model: anthropic/claude-3-5-sonnet-20241022
---

运行完整的测试套件并生成覆盖率报告，显示所有失败的测试。
专注于失败的测试并建议修复方案。
```

## 提示词配置

### 参数传递

使用 `$ARGUMENTS` 占位符传递参数：

```markdown
---
description: 创建新组件
---

创建一个名为 $ARGUMENTS 的新 React 组件，支持 TypeScript。
包含正确的类型定义和基本结构。
```

运行命令：

```
/component Button
```

`$ARGUMENTS` 将被替换为 `Button`。

### 位置参数

可以使用位置参数访问单个参数：

- `$1` - 第一个参数
- `$2` - 第二个参数
- `$3` - 第三个参数
- 以此类推...

示例：

```markdown
---
description: 创建带内容的新文件
---

在目录 $2 中创建名为 $1 的文件，
内容如下：$3
```

运行命令：

```
/create-file config.json src "{ \"key\": \"value\" }"
```

### Shell 输出注入

使用 _!`command`_ 将 bash 命令输出注入到提示词中：

```markdown
---
description: 分析测试覆盖率
---

以下是当前的测试结果：
!`npm test`

根据这些结果，建议如何提高覆盖率。
```

或者查看最近的更改：

```markdown
---
description: 审查最近的更改
---

最近的 git 提交：
!`git log --oneline -10`

审查这些更改并建议改进。
```

### 文件引用

使用 `@` 后跟文件名来包含文件：

```markdown
---
description: 审查组件
---

审查 @src/components/Button.tsx 中的组件。
检查性能问题并建议改进。
```

文件内容会自动包含在提示词中。

## 配置选项

| 选项          | 类型   | 必需 | 描述                                 |
| ------------- | ------ | ---- | ------------------------------------ |
| `template`    | 字符串 | 是   | 执行命令时发送给 LLM 的提示词        |
| `description` | 字符串 | 否   | 命令的简短描述，显示在 TUI 中        |
| `agent`       | 字符串 | 否   | 指定执行此命令的代理，默认为当前代理 |
| `subtask`     | 布尔值 | 否   | 强制命令触发子代理调用               |
| `model`       | 字符串 | 否   | 覆盖此命令的默认模型                 |

### subtask 选项

设置 `subtask: true` 可以强制命令触发子代理调用。这在你不想污染主上下文时很有用：

```json
{
  "command": {
    "analyze": {
      "subtask": true
    }
  }
}
```

## 内置命令

OpenCode 包含以下内置命令：

- `/init` - 初始化项目
- `/undo` - 撤销更改
- `/redo` - 重做更改
- `/share` - 分享会话
- `/help` - 显示帮助

> **注意**: 自定义命令可以覆盖内置命令。如果你定义了同名的自定义命令，它将覆盖内置命令。

## 完整示例

### 代码审查命令

`.opencode/commands/review.md`：

```markdown
---
description: 审查代码更改
agent: plan
---

审查以下文件中的代码更改：

!`git diff --cached`

检查：

- 代码质量和最佳实践
- 潜在的 bug 和边界情况
- 性能影响
- 安全考虑

提供建设性反馈。
```

### 文档生成命令

`.opencode/commands/docs.md`：

```markdown
---
description: 为文件生成文档
---

为 @$1 生成详细的文档。

包括：

- 函数/类的用途说明
- 参数和返回值描述
- 使用示例
- 注意事项
```

使用：

```
/docs src/utils/helpers.ts
```
