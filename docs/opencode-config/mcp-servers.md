# OpenCode MCP Servers 配置指南

## 概述

你可以使用 **Model Context Protocol (MCP)** 向 OpenCode 添加外部工具。OpenCode 支持本地和远程服务器。

添加后，MCP 工具会自动与内置工具一起提供给 LLM 使用。

> **注意**: 使用 MCP 服务器会增加上下文。如果你有很多工具，这会很快累积。建议谨慎选择启用哪些 MCP 服务器。

## 启用 MCP

在 `opencode.json` 的 `mcp` 配置下定义 MCP 服务器，每个 MCP 使用唯一名称:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "mcp服务器名称": {
      "enabled": true
    },
    "另一个mcp服务器": {}
  }
}
```

设置 `enabled` 为 `false` 可以临时禁用服务器而不删除配置。

## 本地 MCP 服务器

将 `type` 设置为 `"local"`:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "my-local-mcp-server": {
      "type": "local",
      "command": ["npx", "-y", "my-mcp-command"],
      "enabled": true,
      "environment": {
        "MY_ENV_VAR": "my_env_var_value"
      }
    }
  }
}
```

### 本地 MCP 配置选项

| 选项          | 类型   | 必需 | 描述                                               |
| ------------- | ------ | ---- | -------------------------------------------------- |
| `type`        | 字符串 | 是   | 必须为 `"local"`                                   |
| `command`     | 数组   | 是   | 运行 MCP 服务器的命令和参数                        |
| `environment` | 对象   | 否   | 运行服务器时设置的环境变量                         |
| `enabled`     | 布尔值 | 否   | 启动时启用或禁用 MCP 服务器                        |
| `timeout`     | 数字   | 否   | 从 MCP 服务器获取工具的超时时间（毫秒），默认 5000 |

### 本地 MCP 示例

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "mcp_everything": {
      "type": "local",
      "command": ["npx", "-y", "@modelcontextprotocol/server-everything"]
    }
  }
}
```

使用时在提示词中添加 `use the mcp_everything tool`:

```
use the mcp_everything tool to add the number 3 and 4
```

## 远程 MCP 服务器

将 `type` 设置为 `"remote"`:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "my-remote-mcp": {
      "type": "remote",
      "url": "https://my-mcp-server.com",
      "enabled": true,
      "headers": {
        "Authorization": "Bearer MY_API_KEY"
      }
    }
  }
}
```

### 远程 MCP 配置选项

| 选项      | 类型       | 必需 | 描述                                  |
| --------- | ---------- | ---- | ------------------------------------- |
| `type`    | 字符串     | 是   | 必须为 `"remote"`                     |
| `url`     | 字符串     | 是   | 远程 MCP 服务器的 URL                 |
| `enabled` | 布尔值     | 否   | 启动时启用或禁用 MCP 服务器           |
| `headers` | 对象       | 否   | 随请求发送的头信息                    |
| `oauth`   | 对象/false | 否   | OAuth 认证配置，或 `false` 禁用 OAuth |
| `timeout` | 数字       | 否   | 超时时间（毫秒），默认 5000           |

## OAuth 认证

OpenCode 自动处理远程 MCP 服务器的 OAuth 认证。当服务器需要认证时，OpenCode 会:

1. 检测 401 响应并启动 OAuth 流程
2. 如果服务器支持，使用动态客户端注册 (RFC 7591)
3. 安全存储令牌供将来请求使用

### 自动 OAuth

对于大多数启用 OAuth 的 MCP 服务器，无需特殊配置:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "my-oauth-server": {
      "type": "remote",
      "url": "https://mcp.example.com/mcp"
    }
  }
}
```

### 预注册客户端凭据

如果你有 MCP 服务器提供商的客户端凭据:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "my-oauth-server": {
      "type": "remote",
      "url": "https://mcp.example.com/mcp",
      "oauth": {
        "clientId": "{env:MY_MCP_CLIENT_ID}",
        "clientSecret": "{env:MY_MCP_CLIENT_SECRET}",
        "scope": "tools:read tools:execute"
      }
    }
  }
}
```

### OAuth 命令行管理

```bash
# 认证特定 MCP 服务器
opencode mcp auth my-oauth-server

# 列出所有 MCP 服务器及其认证状态
opencode mcp list

# 删除存储的凭据
opencode mcp logout my-oauth-server

# 调试连接和 OAuth 流程
opencode mcp debug my-oauth-server
```

### 禁用 OAuth

对于使用 API 密钥而非 OAuth 的服务器:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "my-api-key-server": {
      "type": "remote",
      "url": "https://mcp.example.com/mcp",
      "oauth": false,
      "headers": {
        "Authorization": "Bearer {env:MY_API_KEY}"
      }
    }
  }
}
```

### OAuth 选项

| 选项           | 类型       | 描述                                           |
| -------------- | ---------- | ---------------------------------------------- |
| `oauth`        | 对象/false | OAuth 配置对象，或 `false` 禁用 OAuth 自动检测 |
| `clientId`     | 字符串     | OAuth 客户端 ID，未提供则尝试动态客户端注册    |
| `clientSecret` | 字符串     | OAuth 客户端密钥（如授权服务器需要）           |
| `scope`        | 字符串     | 授权期间请求的 OAuth 范围                      |

## MCP 工具管理

MCP 作为工具在 OpenCode 中可用，可以像其他工具一样管理。

### 全局启用/禁用

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "my-mcp-foo": {
      "type": "local",
      "command": ["bun", "x", "my-mcp-command-foo"]
    },
    "my-mcp-bar": {
      "type": "local",
      "command": ["bun", "x", "my-mcp-command-bar"]
    }
  },
  "tools": {
    "my-mcp-foo": false
  }
}
```

使用通配符模式禁用所有匹配的 MCP:

```json
{
  "tools": {
    "my-mcp*": false
  }
}
```

### 按代理启用

如果有大量 MCP 服务器，可以全局禁用，仅在特定代理中启用:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "my-mcp": {
      "type": "local",
      "command": ["bun", "x", "my-mcp-command"],
      "enabled": true
    }
  },
  "tools": {
    "my-mcp*": false
  },
  "agent": {
    "my-agent": {
      "tools": {
        "my-mcp*": true
      }
    }
  }
}
```

### 通配符模式说明

- `*` 匹配零个或多个任意字符（如 `"my-mcp*"` 匹配 `my-mcp_search`、`my-mcp_list` 等）
- `?` 匹配恰好一个字符
- 其他字符按字面匹配

> **注意**: MCP 服务器工具以服务器名称为前缀注册，要禁用某服务器的所有工具:
>
> ```json
> "mymcpservername_*": false
> ```

## 常用 MCP 服务器示例

### Sentry

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "sentry": {
      "type": "remote",
      "url": "https://mcp.sentry.dev/mcp",
      "oauth": {}
    }
  }
}
```

认证后使用:

```
Show me the latest unresolved issues in my project. use sentry
```

### Context7 (文档搜索)

基础配置:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "context7": {
      "type": "remote",
      "url": "https://mcp.context7.com/mcp"
    }
  }
}
```

使用 API 密钥获取更高速率限制:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "context7": {
      "type": "remote",
      "url": "https://mcp.context7.com/mcp",
      "headers": {
        "CONTEXT7_API_KEY": "{env:CONTEXT7_API_KEY}"
      }
    }
  }
}
```

使用示例:

```
Configure a Cloudflare Worker script to cache JSON API responses for five minutes. use context7
```

### Grep by Vercel (GitHub 代码搜索)

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "gh_grep": {
      "type": "remote",
      "url": "https://mcp.grep.app"
    }
  }
}
```

使用示例:

```
What's the right way to set a custom domain in an SST Astro component? use the gh_grep tool
```

## 在 AGENTS.md 中配置 MCP 使用

可以在项目的 `AGENTS.md` 中添加指令，让代理自动使用特定 MCP:

```markdown
When you need to search docs, use `context7` tools.

If you are unsure how to do something, use `gh_grep` to search code examples from GitHub.
```

## 环境变量引用

在配置中使用 `{env:VARIABLE_NAME}` 语法引用环境变量:

```json
{
  "headers": {
    "Authorization": "Bearer {env:MY_API_KEY}"
  }
}
```
