#!/bin/bash

set -e

# 设置脚本目录
DIR="yt-dlp"
SCRIPT_NAME="yt-dlp.sh"
SCRIPT_URL="https://raw.githubusercontent.com/nodeloc666/yt-dlp-script/main/$SCRIPT_NAME"

# 创建并进入目录
mkdir -p "$DIR"
cd "$DIR"

# 下载函数：curl 或 wget 二选一
download_script() {
    echo "正在下载最新版本的 $SCRIPT_NAME..."

    if command -v curl > /dev/null 2>&1; then
        curl -fsSL -o "$SCRIPT_NAME" "$SCRIPT_URL" || {
            echo "❌ 使用 curl 下载失败，请检查网络或 URL。"
            exit 1
        }
    elif command -v wget > /dev/null 2>&1; then
        wget -q -O "$SCRIPT_NAME" "$SCRIPT_URL" || {
            echo "❌ 使用 wget 下载失败，请检查网络或 URL。"
            exit 1
        }
    else
        echo "❌ 未检测到 curl 或 wget，请先安装其中一个。"
        exit 1
    fi
}

# 执行流程
download_script
chmod +x "$SCRIPT_NAME"

echo "✅ 脚本已更新并赋予执行权限，开始运行..."
bash "$SCRIPT_NAME"
