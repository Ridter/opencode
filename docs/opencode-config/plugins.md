# OpenCode Plugins 配置指南

## 概述

插件允许你通过挂钩各种事件和自定义行为来扩展 OpenCode。你可以创建插件来添加新功能、与外部服务集成或修改 OpenCode 的默认行为。

## 使用插件

有两种方式加载插件。

### 从本地文件

将 JavaScript 或 TypeScript 文件放在插件目录中：

- `.opencode/plugins/` - 项目级插件
- `~/.config/opencode/plugins/` - 全局插件

这些目录中的文件在启动时自动加载。

### 从 npm

在配置文件中指定 npm 包：

```json
{
  "$schema": "https://opencode.ai/config.json",
  "plugin": ["opencode-helicone-session", "opencode-wakatime", "@my-org/custom-plugin"]
}
```

支持常规和作用域 npm 包。

### 安装方式

**npm 插件**在启动时使用 Bun 自动安装。包及其依赖项缓存在 `~/.cache/opencode/node_modules/`。

**本地插件**直接从插件目录加载。要使用外部包，你必须在配置目录中创建 `package.json`，或将插件发布到 npm 并添加到配置中。

### 加载顺序

插件从所有来源加载，所有钩子按顺序运行。加载顺序是：

1. 全局配置 (`~/.config/opencode/opencode.json`)
2. 项目配置 (`opencode.json`)
3. 全局插件目录 (`~/.config/opencode/plugins/`)
4. 项目插件目录 (`.opencode/plugins/`)

具有相同名称和版本的重复 npm 包只加载一次。但是，具有相似名称的本地插件和 npm 插件会分别加载。

## 创建插件

插件是一个 **JavaScript/TypeScript 模块**，导出一个或多个插件函数。每个函数接收一个上下文对象并返回一个钩子对象。

### 依赖管理

本地插件和自定义工具可以使用外部 npm 包。在配置目录中添加 `package.json`：

`.opencode/package.json`：

```json
{
  "dependencies": {
    "shescape": "^2.1.0"
  }
}
```

OpenCode 在启动时运行 `bun install` 安装这些依赖。然后你的插件和工具可以导入它们。

### 基本结构

`.opencode/plugins/example.js`：

```javascript
export const MyPlugin = async ({ project, client, $, directory, worktree }) => {
  console.log("插件已初始化！")

  return {
    // 钩子实现放在这里
  }
}
```

插件函数接收：

| 参数        | 描述                                 |
| ----------- | ------------------------------------ |
| `project`   | 当前项目信息                         |
| `directory` | 当前工作目录                         |
| `worktree`  | git 工作树路径                       |
| `client`    | 用于与 AI 交互的 OpenCode SDK 客户端 |
| `$`         | Bun 的 shell API，用于执行命令       |

### TypeScript 支持

对于 TypeScript 插件，你可以从插件包导入类型：

```typescript
import type { Plugin } from "@opencode-ai/plugin"

export const MyPlugin: Plugin = async ({ project, client, $, directory, worktree }) => {
  return {
    // 类型安全的钩子实现
  }
}
```

## 可用事件

插件可以订阅以下事件：

### 命令事件

- `command.executed`

### 文件事件

- `file.edited`
- `file.watcher.updated`

### 安装事件

- `installation.updated`

### LSP 事件

- `lsp.client.diagnostics`
- `lsp.updated`

### 消息事件

- `message.part.removed`
- `message.part.updated`
- `message.removed`
- `message.updated`

### 权限事件

- `permission.asked`
- `permission.replied`

### 服务器事件

- `server.connected`

### 会话事件

- `session.created`
- `session.compacted`
- `session.deleted`
- `session.diff`
- `session.error`
- `session.idle`
- `session.status`
- `session.updated`

### 待办事件

- `todo.updated`

### 工具事件

- `tool.execute.after`
- `tool.execute.before`

### TUI 事件

- `tui.prompt.append`
- `tui.command.execute`
- `tui.toast.show`

## 示例

### 发送通知

当某些事件发生时发送通知：

```javascript
export const NotificationPlugin = async ({ project, client, $, directory, worktree }) => {
  return {
    event: async ({ event }) => {
      // 会话完成时发送通知
      if (event.type === "session.idle") {
        await $`osascript -e 'display notification "会话已完成！" with title "opencode"'`
      }
    },
  }
}
```

这里使用 `osascript` 在 macOS 上运行 AppleScript 发送通知。

### .env 保护

防止 OpenCode 读取 `.env` 文件：

```javascript
export const EnvProtection = async ({ project, client, $, directory, worktree }) => {
  return {
    "tool.execute.before": async (input, output) => {
      if (input.tool === "read" && output.args.filePath.includes(".env")) {
        throw new Error("不要读取 .env 文件")
      }
    },
  }
}
```

### 自定义工具

插件也可以向 OpenCode 添加自定义工具：

```typescript
import { type Plugin, tool } from "@opencode-ai/plugin"

export const CustomToolsPlugin: Plugin = async (ctx) => {
  return {
    tool: {
      mytool: tool({
        description: "这是一个自定义工具",
        args: {
          foo: tool.schema.string(),
        },
        async execute(args, ctx) {
          return `你好 ${args.foo}！`
        },
      }),
    },
  }
}
```

### 日志记录

使用 `client.app.log()` 而不是 `console.log` 进行结构化日志记录：

```typescript
export const MyPlugin = async ({ client }) => {
  await client.app.log({
    service: "my-plugin",
    level: "info",
    message: "插件已初始化",
    extra: { foo: "bar" },
  })
}
```

级别：`debug`、`info`、`warn`、`error`。

### 压缩钩子

自定义会话压缩时包含的上下文：

```typescript
import type { Plugin } from "@opencode-ai/plugin"

export const CompactionPlugin: Plugin = async (ctx) => {
  return {
    "experimental.session.compacting": async (input, output) => {
      // 向压缩提示注入额外上下文
      output.context.push(`## 自定义上下文

包含应在压缩后保留的任何状态：
- 当前任务状态
- 做出的重要决定
- 正在积极处理的文件`)
    },
  }
}
```

你也可以通过设置 `output.prompt` 完全替换压缩提示：

```typescript
import type { Plugin } from "@opencode-ai/plugin"

export const CustomCompactionPlugin: Plugin = async (ctx) => {
  return {
    "experimental.session.compacting": async (input, output) => {
      // 替换整个压缩提示
      output.prompt = `你正在为多代理群会话生成延续提示。

总结：
1. 当前任务及其状态
2. 正在修改哪些文件以及由谁修改
3. 代理之间的任何阻塞或依赖关系
4. 完成工作的下一步

格式化为新代理可以用来恢复工作的结构化提示。`
    },
  }
}
```

当设置 `output.prompt` 时，它完全替换默认的压缩提示。在这种情况下，`output.context` 数组被忽略。

## 目录结构

```
项目根目录/
└── .opencode/
    ├── package.json           # 插件依赖
    └── plugins/
        ├── notification.js    # 通知插件
        ├── env-protection.js  # 环境保护插件
        └── custom-tools.ts    # 自定义工具插件

~/.config/opencode/
└── plugins/
    └── global-plugin.js       # 全局插件
```
