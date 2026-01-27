# OpenCode Keybinds 配置指南

## 概述

OpenCode 有一系列快捷键，你可以通过 OpenCode 配置进行自定义。

## Leader 键

OpenCode 使用 `leader` 键作为大多数快捷键的前缀。这避免了与终端的冲突。

默认情况下，`ctrl+x` 是 leader 键，大多数操作需要你先按 leader 键，然后按快捷键。例如，要开始新会话，你先按 `ctrl+x`，然后按 `n`。

你不必为快捷键使用 leader 键，但我们建议这样做。

## 配置示例

```json
{
  "$schema": "https://opencode.ai/config.json",
  "keybinds": {
    "leader": "ctrl+x",
    "app_exit": "ctrl+c,ctrl+d,<leader>q",
    "editor_open": "<leader>e",
    "theme_list": "<leader>t",
    "sidebar_toggle": "<leader>b",
    "session_new": "<leader>n",
    "session_list": "<leader>l",
    "model_list": "<leader>m",
    "agent_cycle": "tab"
  }
}
```

## 禁用快捷键

通过将键值设置为 `"none"` 来禁用快捷键：

```json
{
  "$schema": "https://opencode.ai/config.json",
  "keybinds": {
    "session_compact": "none"
  }
}
```

## 完整快捷键列表

### 应用程序

| 快捷键                  | 默认值                    | 描述         |
| ----------------------- | ------------------------- | ------------ |
| `leader`                | `ctrl+x`                  | Leader 键    |
| `app_exit`              | `ctrl+c,ctrl+d,<leader>q` | 退出应用     |
| `editor_open`           | `<leader>e`               | 打开编辑器   |
| `theme_list`            | `<leader>t`               | 主题列表     |
| `sidebar_toggle`        | `<leader>b`               | 切换侧边栏   |
| `scrollbar_toggle`      | `none`                    | 切换滚动条   |
| `username_toggle`       | `none`                    | 切换用户名   |
| `status_view`           | `<leader>s`               | 状态视图     |
| `tool_details`          | `none`                    | 工具详情     |
| `terminal_suspend`      | `ctrl+z`                  | 挂起终端     |
| `terminal_title_toggle` | `none`                    | 切换终端标题 |
| `tips_toggle`           | `<leader>h`               | 切换提示     |

### 会话管理

| 快捷键                        | 默认值          | 描述           |
| ----------------------------- | --------------- | -------------- |
| `session_new`                 | `<leader>n`     | 新建会话       |
| `session_list`                | `<leader>l`     | 会话列表       |
| `session_timeline`            | `<leader>g`     | 会话时间线     |
| `session_export`              | `<leader>x`     | 导出会话       |
| `session_fork`                | `none`          | 分叉会话       |
| `session_rename`              | `none`          | 重命名会话     |
| `session_share`               | `none`          | 分享会话       |
| `session_unshare`             | `none`          | 取消分享会话   |
| `session_interrupt`           | `escape`        | 中断会话       |
| `session_compact`             | `<leader>c`     | 压缩会话       |
| `session_child_cycle`         | `<leader>right` | 循环子会话     |
| `session_child_cycle_reverse` | `<leader>left`  | 反向循环子会话 |
| `session_parent`              | `<leader>up`    | 父会话         |

### 消息导航

| 快捷键                    | 默认值                | 描述         |
| ------------------------- | --------------------- | ------------ |
| `messages_page_up`        | `pageup,ctrl+alt+b`   | 向上翻页     |
| `messages_page_down`      | `pagedown,ctrl+alt+f` | 向下翻页     |
| `messages_line_up`        | `ctrl+alt+y`          | 向上一行     |
| `messages_line_down`      | `ctrl+alt+e`          | 向下一行     |
| `messages_half_page_up`   | `ctrl+alt+u`          | 向上半页     |
| `messages_half_page_down` | `ctrl+alt+d`          | 向下半页     |
| `messages_first`          | `ctrl+g,home`         | 第一条消息   |
| `messages_last`           | `ctrl+alt+g,end`      | 最后一条消息 |
| `messages_next`           | `none`                | 下一条消息   |
| `messages_previous`       | `none`                | 上一条消息   |
| `messages_copy`           | `<leader>y`           | 复制消息     |
| `messages_undo`           | `<leader>u`           | 撤销         |
| `messages_redo`           | `<leader>r`           | 重做         |
| `messages_last_user`      | `none`                | 最后用户消息 |
| `messages_toggle_conceal` | `<leader>h`           | 切换隐藏     |

### 模型和代理

| 快捷键                         | 默认值      | 描述             |
| ------------------------------ | ----------- | ---------------- |
| `model_list`                   | `<leader>m` | 模型列表         |
| `model_cycle_recent`           | `f2`        | 循环最近模型     |
| `model_cycle_recent_reverse`   | `shift+f2`  | 反向循环最近模型 |
| `model_cycle_favorite`         | `none`      | 循环收藏模型     |
| `model_cycle_favorite_reverse` | `none`      | 反向循环收藏模型 |
| `agent_list`                   | `<leader>a` | 代理列表         |
| `agent_cycle`                  | `tab`       | 循环代理         |
| `agent_cycle_reverse`          | `shift+tab` | 反向循环代理     |
| `variant_cycle`                | `ctrl+t`    | 循环变体         |
| `command_list`                 | `ctrl+p`    | 命令列表         |

### 输入编辑

| 快捷键                       | 默认值                                       | 描述         |
| ---------------------------- | -------------------------------------------- | ------------ |
| `input_clear`                | `ctrl+c`                                     | 清除输入     |
| `input_paste`                | `ctrl+v`                                     | 粘贴         |
| `input_submit`               | `return`                                     | 提交         |
| `input_newline`              | `shift+return,ctrl+return,alt+return,ctrl+j` | 换行         |
| `input_move_left`            | `left,ctrl+b`                                | 左移光标     |
| `input_move_right`           | `right,ctrl+f`                               | 右移光标     |
| `input_move_up`              | `up`                                         | 上移光标     |
| `input_move_down`            | `down`                                       | 下移光标     |
| `input_line_home`            | `ctrl+a`                                     | 行首         |
| `input_line_end`             | `ctrl+e`                                     | 行尾         |
| `input_buffer_home`          | `home`                                       | 缓冲区开头   |
| `input_buffer_end`           | `end`                                        | 缓冲区结尾   |
| `input_delete_line`          | `ctrl+shift+d`                               | 删除行       |
| `input_delete_to_line_end`   | `ctrl+k`                                     | 删除到行尾   |
| `input_delete_to_line_start` | `ctrl+u`                                     | 删除到行首   |
| `input_backspace`            | `backspace,shift+backspace`                  | 退格         |
| `input_delete`               | `ctrl+d,delete,shift+delete`                 | 删除         |
| `input_undo`                 | `ctrl+-,super+z`                             | 撤销输入     |
| `input_redo`                 | `ctrl+.,super+shift+z`                       | 重做输入     |
| `input_word_forward`         | `alt+f,alt+right,ctrl+right`                 | 前进一个词   |
| `input_word_backward`        | `alt+b,alt+left,ctrl+left`                   | 后退一个词   |
| `input_delete_word_forward`  | `alt+d,alt+delete,ctrl+delete`               | 删除后一个词 |
| `input_delete_word_backward` | `ctrl+w,ctrl+backspace,alt+backspace`        | 删除前一个词 |
| `history_previous`           | `up`                                         | 上一条历史   |
| `history_next`               | `down`                                       | 下一条历史   |

## 桌面应用快捷键

OpenCode 桌面应用的提示输入支持常见的 Readline/Emacs 风格快捷键。这些是内置的，目前无法通过 `opencode.json` 配置。

| 快捷键   | 操作                          |
| -------- | ----------------------------- |
| `ctrl+a` | 移动到当前行开头              |
| `ctrl+e` | 移动到当前行结尾              |
| `ctrl+b` | 光标后退一个字符              |
| `ctrl+f` | 光标前进一个字符              |
| `alt+b`  | 光标后退一个词                |
| `alt+f`  | 光标前进一个词                |
| `ctrl+d` | 删除光标下的字符              |
| `ctrl+k` | 删除到行尾                    |
| `ctrl+u` | 删除到行首                    |
| `ctrl+w` | 删除前一个词                  |
| `alt+d`  | 删除后一个词                  |
| `ctrl+t` | 转置字符                      |
| `ctrl+g` | 取消弹出窗口/中止运行中的响应 |

## Shift+Enter 配置

某些终端默认不发送带修饰键的 Enter。你可能需要配置终端以发送 `Shift+Enter` 作为转义序列。

### Windows Terminal

打开 `settings.json`：

```
%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json
```

在根级 `actions` 数组中添加：

```json
"actions": [
  {
    "command": {
      "action": "sendInput",
      "input": "\u001b[13;2u"
    },
    "id": "User.sendInput.ShiftEnterCustom"
  }
]
```

在根级 `keybindings` 数组中添加：

```json
"keybindings": [
  {
    "keys": "shift+enter",
    "id": "User.sendInput.ShiftEnterCustom"
  }
]
```

保存文件并重启 Windows Terminal 或打开新标签页。
