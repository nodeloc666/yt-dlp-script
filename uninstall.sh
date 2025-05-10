#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m' # 无色

DIR="yt-dlp"

echo -e "${YELLOW}⚠️  将要删除 yt-dlp 安装目录：${BLUE}${DIR}${NC}"

# 提示确认
echo -ne "${YELLOW}你确定要删除该目录及其全部内容吗？(y/N): ${NC}"
read confirm
if [[ "$confirm" =~ ^[Yy]$ ]]; then
    if [ -d "$DIR" ]; then
        rm -rf "$DIR"
        echo -e "${GREEN}✅ 已删除目录：${DIR}${NC}"
    else
        echo -e "${BLUE}ℹ️  目录不存在：${DIR}，无需删除。${NC}"
    fi
else
    echo -e "${RED}❎ 已取消删除操作。${NC}"
fi

# 检查 ffmpeg
if command -v ffmpeg >/dev/null 2>&1; then
    echo -e "\n${BLUE}🎥 检测到系统已安装 ffmpeg。${NC}"
    echo -ne "${YELLOW}你是否也想卸载 ffmpeg？(y/N): ${NC}"
    read uninstall_ffmpeg
    if [[ "$uninstall_ffmpeg" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}🧼 正在卸载 ffmpeg...${NC}"
        sudo apt-get remove --purge -y ffmpeg && sudo apt-get autoremove -y
        echo -e "${GREEN}✅ ffmpeg 已卸载。${NC}"
    else
        echo -e "${BLUE}ℹ️ 保留 ffmpeg 安装。${NC}"
    fi
else
    echo -e "\n${BLUE}ℹ️ 系统未检测到 ffmpeg，无需卸载。${NC}"
fi
