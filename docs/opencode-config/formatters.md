# OpenCode Formatters 配置指南

## 概述

OpenCode 在文件被写入或编辑后自动使用语言特定的格式化器格式化文件。这确保生成的代码遵循你项目的代码风格。

## 工作原理

当 OpenCode 写入或编辑文件时，它会：

1. 检查文件扩展名与所有启用的格式化器
2. 在文件上运行适当的格式化器命令
3. 自动应用格式化更改

这个过程在后台进行，确保你的代码风格得到维护，无需任何手动步骤。

## 内置格式化器

OpenCode 附带了几个流行语言和框架的内置格式化器：

| 格式化器       | 扩展名                                                  | 要求                                                       |
| -------------- | ------------------------------------------------------- | ---------------------------------------------------------- |
| gofmt          | .go                                                     | `gofmt` 命令可用                                           |
| mix            | .ex, .exs, .eex, .heex, .leex, .neex, .sface            | `mix` 命令可用                                             |
| prettier       | .js, .jsx, .ts, .tsx, .html, .css, .md, .json, .yaml 等 | `package.json` 中有 `prettier` 依赖                        |
| biome          | .js, .jsx, .ts, .tsx, .html, .css, .md, .json, .yaml 等 | 有 `biome.json(c)` 配置文件                                |
| zig            | .zig, .zon                                              | `zig` 命令可用                                             |
| clang-format   | .c, .cpp, .h, .hpp, .ino 等                             | 有 `.clang-format` 配置文件                                |
| ktlint         | .kt, .kts                                               | `ktlint` 命令可用                                          |
| ruff           | .py, .pyi                                               | `ruff` 命令可用并有配置                                    |
| rustfmt        | .rs                                                     | `rustfmt` 命令可用                                         |
| cargofmt       | .rs                                                     | `cargo fmt` 命令可用                                       |
| uv             | .py, .pyi                                               | `uv` 命令可用                                              |
| rubocop        | .rb, .rake, .gemspec, .ru                               | `rubocop` 命令可用                                         |
| standardrb     | .rb, .rake, .gemspec, .ru                               | `standardrb` 命令可用                                      |
| htmlbeautifier | .erb, .html.erb                                         | `htmlbeautifier` 命令可用                                  |
| air            | .R                                                      | `air` 命令可用                                             |
| dart           | .dart                                                   | `dart` 命令可用                                            |
| ocamlformat    | .ml, .mli                                               | `ocamlformat` 命令可用且有 `.ocamlformat` 配置文件         |
| terraform      | .tf, .tfvars                                            | `terraform` 命令可用                                       |
| gleam          | .gleam                                                  | `gleam` 命令可用                                           |
| nixfmt         | .nix                                                    | `nixfmt` 命令可用                                          |
| shfmt          | .sh, .bash                                              | `shfmt` 命令可用                                           |
| pint           | .php                                                    | `composer.json` 中有 `laravel/pint` 依赖                   |
| oxfmt (实验性) | .js, .jsx, .ts, .tsx                                    | `package.json` 中有 `oxfmt` 依赖且设置了实验性环境变量标志 |

如果你的项目在 `package.json` 中有 `prettier`，OpenCode 会自动使用它。

## 配置

你可以通过 OpenCode 配置中的 `formatter` 部分自定义格式化器：

```json
{
  "$schema": "https://opencode.ai/config.json",
  "formatter": {}
}
```

每个格式化器配置支持以下属性：

| 属性          | 类型       | 描述                         |
| ------------- | ---------- | ---------------------------- |
| `disabled`    | 布尔值     | 设为 `true` 禁用格式化器     |
| `command`     | 字符串数组 | 运行格式化的命令             |
| `environment` | 对象       | 运行格式化器时设置的环境变量 |
| `extensions`  | 字符串数组 | 此格式化器应处理的文件扩展名 |

## 禁用格式化器

### 禁用所有格式化器

要全局禁用**所有**格式化器，将 `formatter` 设为 `false`：

```json
{
  "$schema": "https://opencode.ai/config.json",
  "formatter": false
}
```

### 禁用特定格式化器

要禁用**特定**格式化器，将 `disabled` 设为 `true`：

```json
{
  "$schema": "https://opencode.ai/config.json",
  "formatter": {
    "prettier": {
      "disabled": true
    }
  }
}
```

## 自定义格式化器

你可以覆盖内置格式化器或通过指定命令、环境变量和文件扩展名添加新的格式化器：

```json
{
  "$schema": "https://opencode.ai/config.json",
  "formatter": {
    "prettier": {
      "command": ["npx", "prettier", "--write", "$FILE"],
      "environment": {
        "NODE_ENV": "development"
      },
      "extensions": [".js", ".ts", ".jsx", ".tsx"]
    },
    "custom-markdown-formatter": {
      "command": ["deno", "fmt", "$FILE"],
      "extensions": [".md"]
    }
  }
}
```

命令中的 **`$FILE` 占位符**将被替换为正在格式化的文件路径。

## 示例配置

### 使用 Biome 替代 Prettier

```json
{
  "$schema": "https://opencode.ai/config.json",
  "formatter": {
    "prettier": {
      "disabled": true
    },
    "biome": {
      "command": ["npx", "@biomejs/biome", "format", "--write", "$FILE"],
      "extensions": [".js", ".jsx", ".ts", ".tsx", ".json"]
    }
  }
}
```

### 添加 Python Black 格式化器

```json
{
  "$schema": "https://opencode.ai/config.json",
  "formatter": {
    "black": {
      "command": ["black", "$FILE"],
      "extensions": [".py"]
    }
  }
}
```

### 使用 ESLint 修复

```json
{
  "$schema": "https://opencode.ai/config.json",
  "formatter": {
    "eslint": {
      "command": ["npx", "eslint", "--fix", "$FILE"],
      "extensions": [".js", ".jsx", ".ts", ".tsx"]
    }
  }
}
```

### 多格式化器配置

```json
{
  "$schema": "https://opencode.ai/config.json",
  "formatter": {
    "prettier": {
      "command": ["npx", "prettier", "--write", "$FILE"],
      "extensions": [".js", ".ts", ".jsx", ".tsx", ".css", ".md", ".json"]
    },
    "gofmt": {
      "command": ["gofmt", "-w", "$FILE"],
      "extensions": [".go"]
    },
    "rustfmt": {
      "command": ["rustfmt", "$FILE"],
      "extensions": [".rs"]
    },
    "black": {
      "command": ["black", "$FILE"],
      "extensions": [".py"]
    }
  }
}
```
