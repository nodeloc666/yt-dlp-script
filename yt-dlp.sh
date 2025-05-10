#!/bin/bash

# 设置字符编码
export LANG=zh_CN.UTF-8

# 颜色设置
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
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
        read -p "按回车键退出..." 
        exit 1
    fi
    
    # 检查 yt-dlp
    if ! command -v ./yt-dlp &> /dev/null; then
        echo -e "${RED}未检测到 yt-dlp${NC}"
        echo -e "${YELLOW}[Y/n] 是否下载 yt-dlp？[默认:是]${NC}"
        read -p "请选择: " install_choice
        if [ -z "$install_choice" ] || [ "$install_choice" = "y" ] || [ "$install_choice" = "Y" ]; then
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
        echo -e "${YELLOW}[Y/n] 是否自动安装？[默认:是]${NC}"
        read -p "请选择: " install_choice
        
        if [ -z "$install_choice" ] || [ "$install_choice" = "y" ] || [ "$install_choice" = "Y" ]; then
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
                read -p "按回车键继续..."
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

# 设置默认值
default_output="./video"
format="2160"
threads="5"

# 检查并创建config文件夹和cookies.txt
mkdir -p config
touch config/cookies.txt config/urls.txt

# 启动脚本前检查依赖
check_dependencies

input_url() {
    clear
    echo -e "${BLUE}===== 视频下载工具 =====${NC}"
    echo
    echo "[0] 退出脚本"
    echo
    echo "[1] 单个视频下载"
    echo
    echo "[2] 批量视频下载"
    echo

    read -p "请选择下载模式(0-2): " mode
    echo

    case $mode in
        1) single_video ;;
        2) batch_videos ;;
        0) exit 0 ;;
        *) 
            echo -e "${RED}无效选择，请重新输入${NC}"
            echo
            sleep 2
            input_url
            ;;
    esac
}

single_video() {
    clear
    echo -e "${BLUE}===== 单个视频下载 =====${NC}"
    echo
    echo "[0] 退出脚本"
    echo
    echo "[100] 返回首页"
    echo

    read -p "请输入视频链接(或输入0/100): " url
    echo

    if [ "$url" = "0" ]; then 
        exit 0
    elif [ "$url" = "100" ]; then
        input_url
    elif [ -z "$url" ]; then
        single_video
    else
        select_output
    fi
}

batch_videos() {
    clear
    echo -e "${BLUE}===== 批量视频下载 =====${NC}"
    echo
    echo "请将视频链接保存在config文件夹下的 urls.txt 文件中"
    echo
    echo "每行一个链接"
    echo
    echo "[0] 退出脚本"
    echo
    echo -e "${YELLOW}[1] 继续下载 [默认]${NC}"
    echo
    echo "[100] 返回首页"
    echo

    if [ ! -s "config/urls.txt" ]; then
        echo -e "${RED}urls.txt 文件为空，请添加视频链接后重试${NC}"
        echo
        read -p "请按任意键继续..."
        input_url
    fi

    url="config/urls.txt"
    video_count=$(wc -l < config/urls.txt)

    echo -e "${GREEN}已检测到 urls.txt 文件，包含 ${video_count} 个视频链接${NC}"
    echo
    read -p "请选择操作(0/1/100)，直接回车继续下载: " choice
    echo

    case $choice in
        "") select_output ;;
        1) select_output ;;
        0) exit 0 ;;
        100) input_url ;;
        *)
            echo -e "${RED}无效选择，请重新输入${NC}"
            echo
            sleep 2
            batch_videos
            ;;
    esac
}

select_output() {
    clear
    echo -e "${BLUE}===== 请选择下载目录 =====${NC}"
    echo
    echo -e "${YELLOW}[1] 使用默认目录 ($default_output) [默认]${NC}"
    echo
    echo "[2] 指定新目录"
    echo
    echo "[0] 退出脚本"
    echo
    echo "[100] 返回首页"
    echo

    read -p "请选择下载目录选项(0-2,100)，直接回车使用默认值: " output_choice
    echo

    case $output_choice in
        ""|1) 
            output_dir="$default_output"
            select_quality
            ;;
        2)
            read -p "请输入下载目录路径: " output_dir
            echo
            if [ -z "$output_dir" ]; then
                echo "未输入目录路径，将使用默认目录"
                echo
                output_dir="$default_output"
                sleep 2
            fi
            select_quality
            ;;
        0) exit 0 ;;
        100) input_url ;;
        *)
            echo -e "${RED}无效选择，请重新输入${NC}"
            echo
            sleep 2
            select_output
            ;;
    esac
}

select_quality() {
    clear
    echo -e "${BLUE}===== 请选择视频分辨率 =====${NC}"
    echo
    echo "[0] 退出脚本"
    echo
    echo "[1] 480P"
    echo
    echo "[2] 720P"
    echo
    echo "[3] 1080P"
    echo
    echo -e "${YELLOW}[4] 2160P(4K) [默认]${NC}"
    echo
    echo "[100] 返回首页"
    echo

    read -p "请输入数字选择(0-4,100)，直接回车使用默认值: " choice
    echo

    case $choice in
        ""|4)
            format="2160"
            filter="bv[height<=$format][ext=mp4]+ba[ext=m4a]/best"
            select_threads
            ;;
        1)
            format="480"
            filter="bv[height<=$format][ext=mp4]+ba[ext=m4a]/best"
            select_threads
            ;;
        2)
            format="720"
            filter="bv[height<=$format][ext=mp4]+ba[ext=m4a]/best"
            select_threads
            ;;
        3)
            format="1080"
            filter="bv[height<=$format][ext=mp4]+ba[ext=m4a]/best"
            select_threads
            ;;
        0) exit 0 ;;
        100) input_url ;;
        *)
            echo -e "${RED}无效选择，请重新输入${NC}"
            echo
            sleep 2
            select_quality
            ;;
    esac
}

select_threads() {
    clear
    echo -e "${BLUE}===== 请选择下载线程数 =====${NC}"
    echo
    echo "线程数越高下载速度越快，但可能会导致不稳定"
    echo
    echo "推荐值: 4-6"
    echo
    echo -e "${YELLOW}默认值: 5${NC}"
    echo
    echo "[0] 退出脚本"
    echo
    echo "[100] 返回首页"
    echo

    read -p "请输入下载线程数(1-10)或选择操作(0,100)，直接回车使用默认值: " threads
    echo

    case $threads in
        "") 
            threads=5
            confirm_download
            ;;
        0) exit 0 ;;
        100) input_url ;;
        *)
            if [[ $threads =~ ^[1-9]$|^10$ ]]; then
                confirm_download
            else
                echo -e "${RED}无效线程数，请输入1-10之间的整数${NC}"
                echo
                sleep 2
                select_threads
            fi
            ;;
    esac
}

confirm_download() {
    clear
    echo -e "${BLUE}===== 下载配置确认 =====${NC}"
    echo
    if [ "$mode" = "1" ]; then
        echo "下载模式: 单个视频"
        echo
        echo "视频链接: $url"
        echo
    else
        echo "下载模式: 批量下载"
        echo
        echo "视频列表: urls.txt"
        echo
        echo "视频数量: $video_count 个"
        echo
    fi
    echo "最大分辨率: ${format}P"
    echo
    echo "下载线程数: $threads"
    echo
    echo "下载目录: $output_dir"
    echo

    # 检查cookies.txt是否配置
    if [ -s "config/cookies.txt" ]; then
        cookie_status="已配置"
    else
        cookie_status="未配置"
    fi
    echo "Cookie状态: $cookie_status"
    echo
    echo "[0] 退出脚本"
    echo
    echo -e "${YELLOW}[1] 开始下载 [默认]${NC}"
    echo
    echo "[100] 返回首页"
    echo

    read -p "请选择操作(0/1/100)，直接回车开始下载: " choice
    echo

    case $choice in
        ""|1) start_download ;;
        0) exit 0 ;;
        100) input_url ;;
        *)
            echo -e "${RED}无效选择，请重新输入${NC}"
            echo
            sleep 2
            confirm_download
            ;;
    esac
}

start_download() {
    clear
    echo -e "${BLUE}===== 开始下载 =====${NC}"
    echo
    echo "正在下载，请稍候..."
    echo

    mkdir -p "$output_dir"

    # 尝试使用cookie下载
    if [ "$cookie_status" = "已配置" ]; then
        if [ "$mode" = "1" ]; then
            ./yt-dlp -f "$filter" \
            --merge-output-format mp4 \
            --concurrent-fragments "$threads" \
            --cookies "config/cookies.txt" \
            -P "$output_dir" \
            "$url" || {
                echo -e "${RED}Cookie可能已失效，尝试不使用Cookie下载...${NC}"
                echo
                ./yt-dlp -f "$filter" \
                --merge-output-format mp4 \
                --concurrent-fragments "$threads" \
                -P "$output_dir" \
                "$url"
            }
        else
            ./yt-dlp -f "$filter" \
            --merge-output-format mp4 \
            --concurrent-fragments "$threads" \
            --cookies "config/cookies.txt" \
            -P "$output_dir" \
            -a "$url" || {
                echo -e "${RED}Cookie可能已失效，尝试不使用Cookie下载...${NC}"
                echo
                ./yt-dlp -f "$filter" \
                --merge-output-format mp4 \
                --concurrent-fragments "$threads" \
                -P "$output_dir" \
                -a "$url"
            }
        fi
    else
        if [ "$mode" = "1" ]; then
            ./yt-dlp -f "$filter" \
            --merge-output-format mp4 \
            --concurrent-fragments "$threads" \
            -P "$output_dir" \
            "$url"
        else
            ./yt-dlp -f "$filter" \
            --merge-output-format mp4 \
            --concurrent-fragments "$threads" \
            -P "$output_dir" \
            -a "$url"
        fi
    fi

    echo
    echo -e "${GREEN}下载完成！${NC}"
    echo
    read -p "按任意键继续..."
}

# 启动脚本
check_dependencies
input_url
