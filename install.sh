#!/bin/bash

set -e

# 脚本配置
DIR="yt-dlp"
SCRIPT_NAME="yt-dlp.sh"
SCRIPT_URL="https://raw.githubusercontent.com/nodeloc666/yt-dlp-script/main/$SCRIPT_NAME"

# 创建目录（如果不存在）
if [ ! -d "$DIR" ]; then
    echo "📁 正在创建目录：$DIR"
    mkdir -p "$DIR"
else
    echo "📂 目录已存在：$DIR"
fi

# 进入目录
cd "$DIR" || {
    echo "❌ 无法进入目录：$DIR"
    exit 1
}

# 下载函数，curl 或 wget 二选一
download_script() {
    echo "🌐 正在下载最新版本的 $SCRIPT_NAME..."

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

# 下载 & 执行
download_script
chmod +x "$SCRIPT_NAME"

echo "✅ 下载成功，开始执行 $SCRIPT_NAME ..."
bash "$SCRIPT_NAME"
