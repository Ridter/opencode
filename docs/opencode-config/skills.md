# OpenCode Skills 配置指南

## 概述

Agent Skills（代理技能）让 OpenCode 能够从你的仓库或主目录中发现可重用的指令。技能通过原生的 `skill` 工具按需加载——代理可以看到可用的技能列表，并在需要时加载完整内容。

## 文件放置位置

每个技能创建一个文件夹，并在其中放置 `SKILL.md` 文件。OpenCode 会搜索以下位置:

| 位置类型         | 路径                                        |
| ---------------- | ------------------------------------------- |
| 项目配置         | `.opencode/skills/<name>/SKILL.md`          |
| 全局配置         | `~/.config/opencode/skills/<name>/SKILL.md` |
| 项目 Claude 兼容 | `.claude/skills/<name>/SKILL.md`            |
| 全局 Claude 兼容 | `~/.claude/skills/<name>/SKILL.md`          |

## 发现机制

对于项目本地路径，OpenCode 会从当前工作目录向上遍历，直到到达 git 工作树根目录。它会加载沿途找到的所有匹配的 `skills/*/SKILL.md` 文件。

全局定义也会从 `~/.config/opencode/skills/*/SKILL.md` 和 `~/.claude/skills/*/SKILL.md` 加载。

## Frontmatter 格式

每个 `SKILL.md` 必须以 YAML frontmatter 开头。支持以下字段:

| 字段            | 必需 | 描述                 |
| --------------- | ---- | -------------------- |
| `name`          | 是   | 技能名称             |
| `description`   | 是   | 技能描述             |
| `license`       | 否   | 许可证               |
| `compatibility` | 否   | 兼容性信息           |
| `metadata`      | 否   | 字符串到字符串的映射 |

未知的 frontmatter 字段会被忽略。

## 命名规则

`name` 必须满足:

- 长度 1-64 个字符
- 小写字母数字，可用单个连字符分隔
- 不能以 `-` 开头或结尾
- 不能包含连续的 `--`
- 必须与包含 `SKILL.md` 的目录名匹配

等效正则表达式:

```
^[a-z0-9]+(-[a-z0-9]+)*$
```

## 描述长度规则

`description` 必须是 1-1024 个字符。保持足够具体，以便代理能够正确选择。

## 完整示例

创建 `.opencode/skills/git-release/SKILL.md`:

```markdown
---
name: git-release
description: 创建一致的发布版本和变更日志
license: MIT
compatibility: opencode
metadata:
  audience: maintainers
  workflow: github
---

## 我的功能

- 从已合并的 PR 中起草发布说明
- 建议版本号升级
- 提供可复制粘贴的 `gh release create` 命令

## 何时使用我

当你准备创建标签发布时使用此技能。
如果目标版本方案不清楚，请提出澄清问题。
```

## 工具描述中的显示

OpenCode 在 `skill` 工具描述中列出可用技能。每个条目包含技能名称和描述:

```xml
<available_skills>
  <skill>
    <name>git-release</name>
    <description>创建一致的发布版本和变更日志</description>
  </skill>
</available_skills>
```

代理通过调用工具加载技能:

```javascript
skill({ name: "git-release" })
```

## 权限配置

在 `opencode.json` 中使用基于模式的权限控制代理可以访问哪些技能:

```json
{
  "permission": {
    "skill": {
      "*": "allow",
      "pr-review": "allow",
      "internal-*": "deny",
      "experimental-*": "ask"
    }
  }
}
```

| 权限值  | 行为                       |
| ------- | -------------------------- |
| `allow` | 技能立即加载               |
| `deny`  | 技能对代理隐藏，访问被拒绝 |
| `ask`   | 加载前提示用户批准         |

模式支持通配符: `internal-*` 匹配 `internal-docs`、`internal-tools` 等。

## 按代理覆盖权限

### 自定义代理 (在 agent frontmatter 中)

```markdown
---
permission:
  skill:
    "documents-*": "allow"
---
```

### 内置代理 (在 opencode.json 中)

```json
{
  "agent": {
    "plan": {
      "permission": {
        "skill": {
          "internal-*": "allow"
        }
      }
    }
  }
}
```

## 禁用技能工具

完全禁用某些代理的技能功能:

### 自定义代理

```markdown
---
tools:
  skill: false
---
```

### 内置代理

```json
{
  "agent": {
    "plan": {
      "tools": {
        "skill": false
      }
    }
  }
}
```

禁用后，`<available_skills>` 部分将完全省略。

## 故障排除

如果技能没有显示:

1. 验证 `SKILL.md` 文件名全部大写
2. 检查 frontmatter 包含 `name` 和 `description`
3. 确保技能名称在所有位置中唯一
4. 检查权限——设置为 `deny` 的技能对代理隐藏

## 目录结构示例

```
项目根目录/
├── .opencode/
│   └── skills/
│       ├── git-release/
│       │   └── SKILL.md
│       └── code-review/
│           └── SKILL.md
└── opencode.json

~/.config/opencode/
└── skills/
    └── my-global-skill/
        └── SKILL.md
```
