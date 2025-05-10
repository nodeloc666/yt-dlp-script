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
