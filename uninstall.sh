#!/bin/bash

DIR="yt-dlp"

echo "⚠️ 将要删除 yt-dlp 安装目录：$DIR"

# 确认是否删除脚本目录
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

# 检查并提示是否卸载 ffmpeg
if command -v ffmpeg >/dev/null 2>&1; then
    echo -e "\n🎥 检测到系统已安装 ffmpeg。"
    read -p "你是否也想卸载 ffmpeg？(y/N): " uninstall_ffmpeg
    if [[ "$uninstall_ffmpeg" =~ ^[Yy]$ ]]; then
        echo "🧼 正在卸载 ffmpeg..."
        sudo apt-get remove --purge -y ffmpeg && sudo apt-get autoremove -y
        echo "✅ ffmpeg 已卸载。"
    else
        echo "ℹ️ 保留 ffmpeg 安装。"
    fi
else
    echo -e "\nℹ️ 系统未检测到 ffmpeg，无需卸载。"
fi
