# OpenCode 配置指南汇总

本文档汇总了 OpenCode 的核心配置功能。

## 目录

### 核心功能

- [agents.md](./agents.md) - Agents（代理）配置指南
- [skills.md](./skills.md) - Skills（技能）配置指南
- [mcp-servers.md](./mcp-servers.md) - MCP Servers 配置指南

### 扩展功能

- [commands.md](./commands.md) - Commands（自定义命令）配置指南
- [rules.md](./rules.md) - Rules（规则/指令）配置指南
- [custom-tools.md](./custom-tools.md) - Custom Tools（自定义工具）配置指南
- [plugins.md](./plugins.md) - Plugins（插件）配置指南

### 系统配置

- [keybinds.md](./keybinds.md) - Keybinds（快捷键）配置指南
- [permissions.md](./permissions.md) - Permissions（权限）配置指南
- [formatters.md](./formatters.md) - Formatters（格式化器）配置指南

---

## 功能快速对比

| 功能             | 用途                                             | 配置位置                                         |
| ---------------- | ------------------------------------------------ | ------------------------------------------------ |
| **Agents**       | 创建专门的 AI 助手，自定义提示词、模型和工具权限 | `opencode.json` 或 `.opencode/agents/*.md`       |
| **Skills**       | 定义可重用的指令，按需加载                       | `.opencode/skills/<name>/SKILL.md`               |
| **MCP Servers**  | 添加外部工具，扩展 OpenCode 能力                 | `opencode.json` 的 `mcp` 配置                    |
| **Commands**     | 创建可重复使用的命令模板                         | `opencode.json` 或 `.opencode/commands/*.md`     |
| **Rules**        | 通过 AGENTS.md 配置模型行为和项目规则            | `AGENTS.md` 或 `opencode.json` 的 `instructions` |
| **Custom Tools** | 创建自定义工具扩展 OpenCode 能力                 | `.opencode/tools/*.ts`                           |
| **Plugins**      | 通过插件扩展 OpenCode 功能                       | `.opencode/plugins/*.ts` 或 npm 包               |
| **Keybinds**     | 自定义键盘绑定                                   | `opencode.json` 的 `keybinds` 配置               |
| **Permissions**  | 控制工具权限                                     | `opencode.json` 的 `permission` 配置             |
| **Formatters**   | 代码格式化配置                                   | `opencode.json` 的 `formatter` 配置              |

---

## 配置文件位置汇总

### 全局配置

```
~/.config/opencode/
├── opencode.json          # 全局配置文件
├── AGENTS.md              # 全局规则
├── agents/                # 全局 Agent 定义
│   └── *.md
├── commands/              # 全局命令定义
│   └── *.md
├── skills/                # 全局 Skill 定义
│   └── <name>/
│       └── SKILL.md
├── tools/                 # 全局自定义工具
│   └── *.ts
└── plugins/               # 全局插件
    └── *.ts
```

### 项目配置

```
项目根目录/
├── opencode.json          # 项目配置文件
├── AGENTS.md              # 项目规则
└── .opencode/
    ├── package.json       # 插件/工具依赖
    ├── agents/            # 项目 Agent 定义
    │   └── *.md
    ├── commands/          # 项目命令定义
    │   └── *.md
    ├── skills/            # 项目 Skill 定义
    │   └── <name>/
    │       └── SKILL.md
    ├── tools/             # 项目自定义工具
    │   └── *.ts
    └── plugins/           # 项目插件
        └── *.ts
```

---

## 完整配置示例

```json
{
  "$schema": "https://opencode.ai/config.json",

  "model": "anthropic/claude-sonnet-4-5",
  "theme": "opencode",
  "autoupdate": true,

  "agent": {
    "build": {
      "mode": "primary",
      "model": "anthropic/claude-sonnet-4-20250514",
      "tools": {
        "write": true,
        "edit": true,
        "bash": true
      }
    },
    "plan": {
      "mode": "primary",
      "permission": {
        "edit": "deny",
        "bash": "ask"
      }
    },
    "code-reviewer": {
      "description": "审查代码质量和最佳实践",
      "mode": "subagent",
      "temperature": 0.1,
      "tools": {
        "write": false,
        "edit": false
      }
    }
  },

  "command": {
    "test": {
      "template": "运行测试并显示覆盖率报告",
      "description": "运行测试",
      "agent": "build"
    }
  },

  "permission": {
    "*": "allow",
    "bash": {
      "*": "ask",
      "git *": "allow",
      "git push *": "deny"
    },
    "skill": {
      "*": "allow",
      "internal-*": "deny"
    }
  },

  "mcp": {
    "context7": {
      "type": "remote",
      "url": "https://mcp.context7.com/mcp",
      "enabled": true
    },
    "local-tools": {
      "type": "local",
      "command": ["npx", "-y", "my-mcp-server"],
      "environment": {
        "API_KEY": "{env:MY_API_KEY}"
      }
    }
  },

  "formatter": {
    "prettier": {
      "command": ["npx", "prettier", "--write", "$FILE"],
      "extensions": [".js", ".ts", ".jsx", ".tsx"]
    }
  },

  "keybinds": {
    "leader": "ctrl+x",
    "session_new": "<leader>n",
    "model_list": "<leader>m"
  },

  "instructions": ["CONTRIBUTING.md", "docs/guidelines.md"],

  "plugin": ["opencode-helicone-session"]
}
```

---

## 常用命令

```bash
# 初始化项目（生成 AGENTS.md）
/init

# 创建新 Agent
opencode agent create

# MCP 认证
opencode mcp auth <server-name>

# 列出 MCP 服务器
opencode mcp list

# 调试 MCP 连接
opencode mcp debug <server-name>

# 查看可用模型
opencode models

# 撤销/重做更改
/undo
/redo

# 分享会话
/share
```

---

## 使用技巧

### 1. Agent 切换

- 使用 **Tab** 键在主代理之间切换
- 使用 **@agent-name** 调用子代理

### 2. Skill 调用

- 代理会自动发现可用技能
- 在提示词中描述需求，代理会选择合适的技能

### 3. MCP 工具使用

- 在提示词中添加 `use <mcp-name>` 来使用特定 MCP
- 或在 `AGENTS.md` 中配置自动使用规则

### 4. 自定义命令

- 使用 `/command-name` 执行自定义命令
- 支持参数传递和 shell 输出注入

### 5. 权限控制

- 使用 `"ask"` 在执行前提示确认
- 使用通配符模式批量配置权限

---

## 参考链接

- [OpenCode 官方文档](https://opencode.ai/docs)
- [Agents 文档](https://opencode.ai/docs/agents/)
- [Skills 文档](https://opencode.ai/docs/skills/)
- [MCP Servers 文档](https://opencode.ai/docs/mcp-servers/)
- [Commands 文档](https://opencode.ai/docs/commands/)
- [Rules 文档](https://opencode.ai/docs/rules/)
- [Custom Tools 文档](https://opencode.ai/docs/custom-tools/)
- [Plugins 文档](https://opencode.ai/docs/plugins/)
- [Keybinds 文档](https://opencode.ai/docs/keybinds/)
- [Permissions 文档](https://opencode.ai/docs/permissions/)
- [Formatters 文档](https://opencode.ai/docs/formatters/)
