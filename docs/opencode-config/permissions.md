# OpenCode Permissions 配置指南

## 概述

OpenCode 使用 `permission` 配置来决定给定操作是否应该自动运行、提示你或被阻止。

## 权限值

每个权限规则解析为以下之一：

| 值        | 描述             |
| --------- | ---------------- |
| `"allow"` | 无需批准即可运行 |
| `"ask"`   | 提示批准         |
| `"deny"`  | 阻止操作         |

## 基本配置

你可以全局设置权限（使用 `*`），并覆盖特定工具：

```json
{
  "$schema": "https://opencode.ai/config.json",
  "permission": {
    "*": "ask",
    "bash": "allow",
    "edit": "deny"
  }
}
```

你也可以一次设置所有权限：

```json
{
  "$schema": "https://opencode.ai/config.json",
  "permission": "allow"
}
```

## 细粒度规则（对象语法）

对于大多数权限，你可以使用对象根据工具输入应用不同的操作：

```json
{
  "$schema": "https://opencode.ai/config.json",
  "permission": {
    "bash": {
      "*": "ask",
      "git *": "allow",
      "npm *": "allow",
      "rm *": "deny",
      "grep *": "allow"
    },
    "edit": {
      "*": "deny",
      "packages/web/src/content/docs/*.mdx": "allow"
    }
  }
}
```

规则按模式匹配评估，**最后匹配的规则获胜**。常见模式是将通配符 `"*"` 规则放在前面，更具体的规则放在后面。

### 通配符

权限模式使用简单的通配符匹配：

- `*` 匹配零个或多个任意字符
- `?` 匹配恰好一个字符
- 其他字符按字面匹配

### 主目录展开

你可以在模式开头使用 `~` 或 `$HOME` 引用主目录。这对 `external_directory` 规则特别有用：

- `~/projects/*` -> `/Users/username/projects/*`
- `$HOME/projects/*` -> `/Users/username/projects/*`
- `~` -> `/Users/username`

## 可用权限

OpenCode 权限按工具名称键入，加上几个安全保护：

| 权限                      | 描述                                                         |
| ------------------------- | ------------------------------------------------------------ |
| `read`                    | 读取文件（匹配文件路径）                                     |
| `edit`                    | 所有文件修改（涵盖 `edit`、`write`、`patch`、`multiedit`）   |
| `glob`                    | 文件通配（匹配 glob 模式）                                   |
| `grep`                    | 内容搜索（匹配正则表达式模式）                               |
| `list`                    | 列出目录中的文件（匹配目录路径）                             |
| `bash`                    | 运行 shell 命令（匹配解析的命令如 `git status --porcelain`） |
| `task`                    | 启动子代理（匹配子代理类型）                                 |
| `skill`                   | 加载技能（匹配技能名称）                                     |
| `lsp`                     | 运行 LSP 查询（目前非细粒度）                                |
| `todoread`, `todowrite`   | 读取/更新待办列表                                            |
| `webfetch`                | 获取 URL（匹配 URL）                                         |
| `websearch`, `codesearch` | 网络/代码搜索（匹配查询）                                    |
| `external_directory`      | 当工具触及项目工作目录外的路径时触发                         |
| `doom_loop`               | 当相同的工具调用以相同输入重复 3 次时触发                    |

## 默认值

如果你不指定任何内容，OpenCode 从宽松的默认值开始：

- 大多数权限默认为 `"allow"`
- `doom_loop` 和 `external_directory` 默认为 `"ask"`
- `read` 是 `"allow"`，但 `.env` 文件默认被拒绝：

```json
{
  "permission": {
    "read": {
      "*": "allow",
      "*.env": "deny",
      "*.env.*": "deny",
      "*.env.example": "allow"
    }
  }
}
```

## "Ask" 的行为

当 OpenCode 提示批准时，UI 提供三个结果：

| 选项     | 描述                                                           |
| -------- | -------------------------------------------------------------- |
| `once`   | 仅批准此请求                                                   |
| `always` | 批准匹配建议模式的未来请求（在当前 OpenCode 会话的剩余时间内） |
| `reject` | 拒绝请求                                                       |

`always` 将批准的模式集由工具提供（例如，bash 批准通常将安全命令前缀如 `git status*` 列入白名单）。

## 按代理配置权限

你可以按代理覆盖权限。代理权限与全局配置合并，代理规则优先。

### JSON 配置

```json
{
  "$schema": "https://opencode.ai/config.json",
  "permission": {
    "bash": {
      "*": "ask",
      "git *": "allow",
      "git commit *": "deny",
      "git push *": "deny",
      "grep *": "allow"
    }
  },
  "agent": {
    "build": {
      "permission": {
        "bash": {
          "*": "ask",
          "git *": "allow",
          "git commit *": "ask",
          "git push *": "deny",
          "grep *": "allow"
        }
      }
    }
  }
}
```

### Markdown 配置

`~/.config/opencode/agents/review.md`：

```markdown
---
description: 无编辑的代码审查
mode: subagent
permission:
  edit: deny
  bash: ask
  webfetch: deny
---

仅分析代码并建议更改。
```

## 实用示例

### 只读模式

```json
{
  "permission": {
    "edit": "deny",
    "bash": {
      "*": "deny",
      "git status *": "allow",
      "git diff *": "allow",
      "git log *": "allow"
    }
  }
}
```

### 安全的 Git 操作

```json
{
  "permission": {
    "bash": {
      "*": "ask",
      "git status *": "allow",
      "git diff *": "allow",
      "git log *": "allow",
      "git add *": "ask",
      "git commit *": "ask",
      "git push *": "deny",
      "git push --force *": "deny"
    }
  }
}
```

### 限制文件编辑范围

```json
{
  "permission": {
    "edit": {
      "*": "deny",
      "src/**/*.ts": "allow",
      "src/**/*.tsx": "allow",
      "tests/**/*.ts": "allow"
    }
  }
}
```

> **提示**: 对带参数的命令使用模式匹配。`"grep *"` 允许 `grep pattern file.txt`，而单独的 `"grep"` 会阻止它。像 `git status` 这样的命令适用于默认行为，但当传递参数时需要显式权限（如 `"git status *"`）。
