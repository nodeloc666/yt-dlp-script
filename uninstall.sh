#!/bin/bash

DIR="yt-dlp"

echo "⚠️ 将要删除安装目录：$DIR"

# 二次确认
read -p "你确定要删除该目录及其全部内容吗？(y/N): " confirm

if [[ "$confirm" =~ ^[Yy]$ ]]; then
    if [ -d "$DIR" ]; then
        rm -rf "$DIR"
        echo "✅ 已删除目录：$DIR"
    else
        echo "ℹ️ 目录不存在：$DIR，无需删除。"
    fi
else
    echo "❎ 取消删除操作。"
fi
