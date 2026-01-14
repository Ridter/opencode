#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "📦 安装依赖..."
bun install

echo "🔨 构建当前平台的二进制文件..."
cd packages/opencode
bun run build --single

# 检测平台和架构
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)
if [ "$ARCH" = "arm64" ]; then
    ARCH="arm64"
elif [ "$ARCH" = "x86_64" ]; then
    ARCH="x64"
fi

BINARY_PATH="$SCRIPT_DIR/packages/opencode/dist/opencode-${OS}-${ARCH}/bin/opencode"

if [ ! -f "$BINARY_PATH" ]; then
    echo "❌ 构建失败，找不到二进制文件: $BINARY_PATH"
    exit 1
fi

echo "🔗 创建全局符号链接..."
BUN_BIN_DIR="$HOME/.bun/bin"
mkdir -p "$BUN_BIN_DIR"
ln -sf "$BINARY_PATH" "$BUN_BIN_DIR/opencode"

echo "✅ 安装完成！"
echo "二进制文件: $BINARY_PATH"
echo "符号链接: $BUN_BIN_DIR/opencode"
echo ""
echo "现在可以在任意位置运行 'opencode' 命令"
