#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "📦 安装依赖..."
bun install

echo "🔨 构建当前平台的二进制文件..."
cd packages/opencode
bun run build --single

echo "🔗 全局链接..."
cd "$SCRIPT_DIR"
bun link

echo "✅ 安装完成！"
echo "现在可以在任意位置运行 'opencode' 命令"
