# OpenCode Custom Tools 配置指南

## 概述

自定义工具是你创建的函数，LLM 可以在对话期间调用它们。它们与 OpenCode 的内置工具（如 `read`、`write`、`bash`）一起工作。

## 创建工具

工具定义为 **TypeScript** 或 **JavaScript** 文件。但是，工具定义可以调用用**任何语言**编写的脚本——TypeScript 或 JavaScript 仅用于工具定义本身。

### 文件位置

工具可以放置在：

- 项目级别: `.opencode/tools/`
- 全局级别: `~/.config/opencode/tools/`

### 基本结构

使用 `tool()` 辅助函数创建工具，它提供类型安全和验证：

`.opencode/tools/database.ts`：

```typescript
import { tool } from "@opencode-ai/plugin"

export default tool({
  description: "查询项目数据库",
  args: {
    query: tool.schema.string().describe("要执行的 SQL 查询"),
  },
  async execute(args) {
    // 你的数据库逻辑
    return `执行查询: ${args.query}`
  },
})
```

**文件名**成为**工具名称**。上面的代码创建了一个 `database` 工具。

### 单文件多工具

你也可以从单个文件导出多个工具。每个导出成为**单独的工具**，名称为 **`<文件名>_<导出名>`**：

`.opencode/tools/math.ts`：

```typescript
import { tool } from "@opencode-ai/plugin"

export const add = tool({
  description: "两数相加",
  args: {
    a: tool.schema.number().describe("第一个数"),
    b: tool.schema.number().describe("第二个数"),
  },
  async execute(args) {
    return args.a + args.b
  },
})

export const multiply = tool({
  description: "两数相乘",
  args: {
    a: tool.schema.number().describe("第一个数"),
    b: tool.schema.number().describe("第二个数"),
  },
  async execute(args) {
    return args.a * args.b
  },
})
```

这创建了两个工具：`math_add` 和 `math_multiply`。

## 参数定义

你可以使用 `tool.schema`（就是 [Zod](https://zod.dev)）来定义参数类型：

```typescript
args: {
  query: tool.schema.string().describe("要执行的 SQL 查询")
}
```

你也可以直接导入 Zod 并返回普通对象：

```typescript
import { z } from "zod"

export default {
  description: "工具描述",
  args: {
    param: z.string().describe("参数描述"),
  },
  async execute(args, context) {
    // 工具实现
    return "结果"
  },
}
```

### 常用参数类型

```typescript
// 字符串
tool.schema.string().describe("描述")

// 数字
tool.schema.number().describe("描述")

// 布尔值
tool.schema.boolean().describe("描述")

// 可选参数
tool.schema.string().optional().describe("描述")

// 枚举
tool.schema.enum(["option1", "option2"]).describe("描述")

// 数组
tool.schema.array(tool.schema.string()).describe("描述")
```

## 上下文信息

工具接收关于当前会话的上下文：

`.opencode/tools/project.ts`：

```typescript
import { tool } from "@opencode-ai/plugin"

export default tool({
  description: "获取项目信息",
  args: {},
  async execute(args, context) {
    // 访问上下文信息
    const { agent, sessionID, messageID } = context
    return `代理: ${agent}, 会话: ${sessionID}, 消息: ${messageID}`
  },
})
```

## 示例

### 用 Python 编写工具

你可以用任何语言编写工具。以下是使用 Python 实现两数相加的示例。

首先，创建 Python 脚本：

`.opencode/tools/add.py`：

```python
import sys

a = int(sys.argv[1])
b = int(sys.argv[2])
print(a + b)
```

然后创建调用它的工具定义：

`.opencode/tools/python-add.ts`：

```typescript
import { tool } from "@opencode-ai/plugin"

export default tool({
  description: "使用 Python 将两个数相加",
  args: {
    a: tool.schema.number().describe("第一个数"),
    b: tool.schema.number().describe("第二个数"),
  },
  async execute(args) {
    const result = await Bun.$`python3 .opencode/tools/add.py ${args.a} ${args.b}`.text()
    return result.trim()
  },
})
```

这里使用 [`Bun.$`](https://bun.com/docs/runtime/shell) 工具运行 Python 脚本。

### API 调用工具

`.opencode/tools/weather.ts`：

```typescript
import { tool } from "@opencode-ai/plugin"

export default tool({
  description: "获取指定城市的天气信息",
  args: {
    city: tool.schema.string().describe("城市名称"),
  },
  async execute(args) {
    const response = await fetch(
      `https://api.weatherapi.com/v1/current.json?key=${process.env.WEATHER_API_KEY}&q=${args.city}`,
    )
    const data = await response.json()
    return JSON.stringify(data, null, 2)
  },
})
```

### 文件处理工具

`.opencode/tools/csv-parser.ts`：

```typescript
import { tool } from "@opencode-ai/plugin"

export default tool({
  description: "解析 CSV 文件并返回 JSON",
  args: {
    filePath: tool.schema.string().describe("CSV 文件路径"),
  },
  async execute(args) {
    const file = Bun.file(args.filePath)
    const content = await file.text()

    const lines = content.split("\n")
    const headers = lines[0].split(",")
    const data = lines.slice(1).map((line) => {
      const values = line.split(",")
      return headers.reduce(
        (obj, header, i) => {
          obj[header.trim()] = values[i]?.trim()
          return obj
        },
        {} as Record<string, string>,
      )
    })

    return JSON.stringify(data, null, 2)
  },
})
```

## 目录结构

```
项目根目录/
└── .opencode/
    └── tools/
        ├── database.ts      # 创建 "database" 工具
        ├── math.ts          # 创建 "math_add" 和 "math_multiply" 工具
        ├── weather.ts       # 创建 "weather" 工具
        └── add.py           # Python 脚本（被其他工具调用）

~/.config/opencode/
└── tools/
    └── global-tool.ts       # 全局工具
```

## 依赖管理

本地工具可以使用外部 npm 包。在配置目录中添加 `package.json`：

`.opencode/package.json`：

```json
{
  "dependencies": {
    "shescape": "^2.1.0"
  }
}
```

OpenCode 在启动时运行 `bun install` 安装这些依赖。然后你的工具可以导入它们：

```typescript
import { escape } from "shescape"

export default tool({
  // ...
})
```
