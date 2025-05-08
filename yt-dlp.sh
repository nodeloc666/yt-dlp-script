#!/bin/bash

# 设置字符编码
export LANG=zh_CN.UTF-8

# 颜色设置
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# 检查并安装依赖
check_dependencies() {
    echo -e "${BLUE}===== 检查依赖 =====${NC}"
    echo
    
    # 检查 curl
    if ! command -v curl &> /dev/null; then
        echo -e "${RED}未检测到 curl，请先安装 curl：${NC}"
        echo "Debian/Ubuntu: sudo apt install curl"
        echo "CentOS: sudo yum install curl"
        echo "Alpine: apk add curl"
        read -e -p "按回车键退出..." 
        exit 1
    fi
    
    # 检查 yt-dlp
    if ! command -v ./yt-dlp &> /dev/null; then
        echo -e "${RED}未检测到 yt-dlp${NC}"
        echo "[Y] 是"
        echo "[N] 否"
        read -e -p "是否下载 yt-dlp？(Y/N): " install_choice
        if [ "$install_choice" = "y" ] || [ "$install_choice" = "Y" ]; then
            echo "正在下载 yt-dlp..."
            curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o yt-dlp
            chmod +x yt-dlp
            echo -e "${GREEN}yt-dlp 下载完成${NC}"
        else
            echo "请手动下载 yt-dlp 后重试"
            exit 1
        fi
    fi
    
    # 检查 ffmpeg 和 ffprobe
    if ! command -v ffmpeg &> /dev/null || ! command -v ffprobe &> /dev/null; then
        echo -e "${RED}未检测到 ffmpeg/ffprobe${NC}"
        echo "[Y] 是"
        echo "[N] 否"
        read -e -p "是否自动安装？(Y/N): " install_choice
        
        if [ "$install_choice" = "y" ] || [ "$install_choice" = "Y" ]; then
            echo "正在安装 ffmpeg..."
            if [ -f /etc/debian_version ]; then
                sudo apt-get update && sudo apt-get install -y ffmpeg
            elif [ -f /etc/redhat-release ]; then
                sudo yum install -y epel-release
                sudo yum install -y ffmpeg
            elif [ -f /etc/alpine-release ]; then
                apk add ffmpeg
            else
                echo -e "${RED}无法识别系统类型，请手动安装 ffmpeg：${NC}"
                echo "Debian/Ubuntu: sudo apt install ffmpeg"
                echo "CentOS: sudo yum install ffmpeg"
                echo "Alpine: apk add ffmpeg"
                read -e -p "按回车键继续..."
                exit 1
            fi
            echo -e "${GREEN}ffmpeg 安装完成${NC}"
        else
            echo "请手动安装 ffmpeg 后重试"
            exit 1
        fi
    fi
    
    echo -e "${GREEN}所有依赖检查完成！${NC}"
    sleep 2
}

clear_screen() {
    clear
}

input_url() {
    clear_screen
    echo -e "${BLUE}===== 视频下载脚本 =====${NC}"
    echo
    echo "[0] 退出程序"
    echo "[1] 单个视频下载"
    echo "[2] 批量视频下载"
    echo
    read -e -p "请选择下载模式(0-2): " mode
    
    case $mode in
        0) 
            echo "正在退出程序..."
            exit 0 
            ;;
        1) single_video ;;
        2) batch_videos ;;
        *) 
            echo -e "${RED}无效选择，请重新输入${NC}"
            sleep 2
            input_url
            ;;
    esac
}

single_video() {
    clear_screen
    echo -e "${BLUE}===== 单个视频下载 =====${NC}"
    echo
    echo "[0] 返回上一步"
    read -e -p "请输入视频链接: " url
    
    if [ "$url" = "0" ]; then
        input_url
        return
    fi
    
    [ -z "$url" ] && single_video
    select_quality
}

batch_videos() {
    clear_screen
    echo -e "${BLUE}===== 批量视频下载 =====${NC}"
    echo
    echo "请将视频链接保存在当前目录下的 urls.txt 文件中"
    echo "每行一个链接"
    echo
    echo "[0] 返回上一步"
    echo "[1] 继续操作"
    echo
    read -e -p "请选择(0-1): " choice
    
    case $choice in
        0)
            input_url
            return
            ;;
        1)
            if [ ! -f "urls.txt" ]; then
                echo -e "${RED}未找到 urls.txt 文件${NC}"
                echo "已为您创建 urls.txt 文件，请在文件中添加视频链接后重试"
                touch urls.txt
                echo
                read -e -p "请按回车键继续..."
                input_url
            fi
            
            if [ ! -s "urls.txt" ]; then
                echo -e "${RED}urls.txt 文件为空，请添加视频链接后重试${NC}"
                echo
                read -e -p "请按回车键继续..."
                input_url
            fi
            
            url="urls.txt"
            video_count=$(wc -l < urls.txt)
            echo -e "${GREEN}已检测到 urls.txt 文件，包含 ${video_count} 个视频链接${NC}"
            sleep 2
            select_quality
            ;;
        *)
            echo -e "${RED}无效选择，请重新输入${NC}"
            sleep 2
            batch_videos
            ;;
    esac
}

select_quality() {
    clear_screen
    echo -e "${BLUE}===== 请选择视频分辨率 =====${NC}"
    echo
    echo "[0] 返回上一步"
    echo "[1] 480P"
    echo "[2] 720P"
    echo "[3] 1080P"
    echo "[4] 2160P(4K)"
    echo
    read -e -p "请输入数字选择(0-4): " choice
    
    case $choice in
        0) 
            if [ "$mode" == "1" ]; then
                single_video
            else
                batch_videos
            fi
            ;;
        1) format=480 ;;
        2) format=720 ;;
        3) format=1080 ;;
        4) format=2160 ;;
        *)
            echo -e "${RED}无效选择，请重新输入${NC}"
            sleep 2
            select_quality
            ;;
    esac
    
    [ "$choice" != "0" ] && {
        filter="bv[height<=$format][ext=mp4]+ba[ext=m4a]/best"
        select_threads
    }
}

select_threads() {
    clear_screen
    echo -e "${BLUE}===== 请选择下载线程数 =====${NC}"
    echo
    echo "[0] 返回上一步"
    echo "线程数越高下载速度越快，但可能会导致不稳定"
    echo "推荐值: 4-6"
    echo
    read -e -p "请输入下载线程数(0-10): " threads
    
    if [ "$threads" = "0" ]; then
        select_quality
        return
    fi
    
    if [[ ! $threads =~ ^[1-9]$|^10$ ]]; then
        echo -e "${RED}无效线程数，请输入0-10之间的整数${NC}"
        sleep 2
        select_threads
    fi
    
    confirm_download
}

confirm_download() {
    clear_screen
    echo -e "${BLUE}===== 下载配置确认 =====${NC}"
    echo
    if [ "$mode" == "1" ]; then
        echo "下载模式: 单个视频"
        echo "视频链接: $url"
    else
        echo "下载模式: 批量下载"
        echo "视频列表: urls.txt"
        echo "视频总数: ${video_count} 个"
    fi
    echo "最大分辨率: ${format}P"
    echo "下载线程数: $threads"
    echo
    echo "[0] 返回上一步"
    echo "[1] 开始下载"
    echo "[2] 重新配置"
    echo
    read -e -p "请选择(0-2): " confirm
    
    case $confirm in
        0) select_threads ;;
        1) start_download ;;
        2) input_url ;;
        *)
            echo -e "${RED}无效选择，请重新输入${NC}"
            sleep 2
            confirm_download
            ;;
    esac
}

start_download() {
    clear_screen
    echo -e "${BLUE}===== 开始下载 =====${NC}"
    echo
    echo "正在下载，请稍候..."
    echo
    
    if [ "$mode" == "1" ]; then
        ./yt-dlp -f "$filter" \
        --merge-output-format mp4 \
        --concurrent-fragments "$threads" \
        "$url"
    else
        ./yt-dlp -f "$filter" \
        --merge-output-format mp4 \
        --concurrent-fragments "$threads" \
        -a "$url"
    fi
    
    echo
    echo -e "${GREEN}下载完成！${NC}"
    read -e -p "按回车键退出..."
}

# 主程序开始
check_dependencies
input_url
