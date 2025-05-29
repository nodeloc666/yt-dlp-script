@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
color 0B

:: 设置默认值
set "default_output=.\video"
set "format=2160"
set "threads=5"

:: 检查并创建config文件夹和cookies.txt
if not exist "config" (
    mkdir "config"
    echo.> "config\cookies.txt"
)
if not exist "config\urls.txt" echo.> "config\urls.txt"

:input_url
cls
echo ===== 视频下载工具 =====
echo.
echo [0] 退出脚本
echo.
echo [1] 单个视频下载
echo.
echo [2] 批量视频下载
echo.

set /p mode="请选择下载模式(0-2): "
echo.

if "!mode!"=="1" (
    goto single_video
) else if "!mode!"=="2" (
    goto batch_videos
) else if "!mode!"=="0" (
    exit
) else (
    echo 无效选择，请重新输入
    echo.
    timeout /t 2 >nul
    goto input_url
)

:single_video
cls
echo ===== 单个视频下载 =====
echo.
echo [0] 退出脚本
echo.
echo [100] 返回首页
echo.

set /p url="请输入视频链接(或输入0/100): "
echo.

if "!url!"=="0" exit
if "!url!"=="100" goto input_url
if "!url!"=="" goto single_video
goto select_output

:batch_videos
cls
echo ===== 批量视频下载 =====
echo.
echo 请将视频链接保存在config文件夹下的 urls.txt 文件中
echo.
echo 每行一个链接
echo.
echo [0] 退出脚本
echo.
color 0E
echo [1] 继续下载 [默认]
echo.
color 0B
echo [100] 返回首页
echo.

if not exist "config\urls.txt" (
    echo 未找到 urls.txt 文件
    echo.
    echo 已为您创建 urls.txt 文件，请在文件中添加视频链接后重试
    echo.> "config\urls.txt"
    echo.
    echo 请按任意键继续...
    pause >nul
    goto input_url
)

findstr /r /c:"." "config\urls.txt" >nul
if errorlevel 1 (
    echo urls.txt 文件为空，请添加视频链接后重试
    echo.
    echo 请按任意键继续...
    pause >nul
    goto input_url
)

set "url=config\urls.txt"
set /a video_count=0
for /f %%i in ('type "config\urls.txt"^|find /v /c ""') do set /a video_count=%%i

echo 已检测到 urls.txt 文件，包含 !video_count! 个视频链接
echo.
set /p choice="请选择操作(0/1/100)，直接回车继续下载: "
echo.

if "!choice!"=="" (
    goto select_output
) else if "!choice!"=="1" (
    goto select_output
) else if "!choice!"=="0" (
    exit
) else if "!choice!"=="100" (
    goto input_url
) else (
    echo 无效选择，请重新输入
    echo.
    timeout /t 2 >nul
    goto batch_videos
)

:select_output
cls
echo ===== 请选择下载目录 =====
echo.
color 0E
echo [1] 使用默认目录 (!default_output!) [默认]
echo.
color 0B
echo [2] 指定新目录
echo.
echo [0] 退出脚本
echo.
echo [100] 返回首页
echo.

set /p output_choice="请选择下载目录选项(0-2,100)，直接回车使用默认值: "
echo.

if "!output_choice!"=="" (
    set "output_dir=!default_output!"
    goto select_quality
) else if "!output_choice!"=="1" (
    set "output_dir=!default_output!"
    goto select_quality
) else if "!output_choice!"=="2" (
    set /p output_dir="请输入下载目录路径: "
    echo.
    if "!output_dir!"=="" (
        echo 未输入目录路径，将使用默认目录
        echo.
        set "output_dir=!default_output!"
        timeout /t 2 >nul
    )
    goto select_quality
) else if "!output_choice!"=="0" (
    exit
) else if "!output_choice!"=="100" (
    goto input_url
) else (
    echo 无效选择，请重新输入
    echo.
    timeout /t 2 >nul
    goto select_output
)

:select_quality
cls
echo ===== 请选择视频分辨率 =====
echo.
echo [0] 退出脚本
echo.
echo [1] 480P
echo.
echo [2] 720P
echo.
echo [3] 1080P
echo.
color 0E
echo [4] 2160P(4K) [默认]
echo.
color 0B
echo [100] 返回首页
echo.

set /p choice="请输入数字选择(0-4,100)，直接回车使用默认值: "
echo.

if "!choice!"=="" (
    set "format=2160"
    set "filter=bv[height<=!format!][ext=mp4]+ba[ext=m4a]/best"
    goto select_threads
) else if "!choice!"=="1" (
    set "format=480"
    set "filter=bv[height<=!format!][ext=mp4]+ba[ext=m4a]/best"
    goto select_threads
) else if "!choice!"=="2" (
    set "format=720"
    set "filter=bv[height<=!format!][ext=mp4]+ba[ext=m4a]/best"
    goto select_threads
) else if "!choice!"=="3" (
    set "format=1080"
    set "filter=bv[height<=!format!][ext=mp4]+ba[ext=m4a]/best"
    goto select_threads
) else if "!choice!"=="4" (
    set "format=2160"
    set "filter=bv[height<=!format!][ext=mp4]+ba[ext=m4a]/best"
    goto select_threads
) else if "!choice!"=="0" (
    exit
) else if "!choice!"=="100" (
    goto input_url
) else (
    echo 无效选择，请重新输入
    echo.
    timeout /t 2 >nul
    goto select_quality
)

:select_threads
cls
echo ===== 请选择下载线程数 =====
echo.
echo 线程数越高下载速度越快，但可能会导致不稳定
echo.
echo 推荐值: 4-6
echo.
color 0E
echo 默认值: 5
echo.
color 0B
echo [0] 退出脚本
echo.
echo [100] 返回首页
echo.

set /p threads="请输入下载线程数(1-10)或选择操作(0,100)，直接回车使用默认值: "
echo.

if "!threads!"=="" (
    set "threads=5"
    goto confirm_download
) else if "!threads!"=="0" (
    exit
) else if "!threads!"=="100" (
    goto input_url
)

set "valid=true"
if !threads! LSS 1 set "valid=false"
if !threads! GTR 10 set "valid=false"
echo !threads!| findstr /r "^[1-9][0-9]*$" >nul || set "valid=false"

if "!valid!"=="true" (
    goto confirm_download
) else (
    echo 无效线程数，请输入1-10之间的整数
    echo.
    timeout /t 2 >nul
    goto select_threads
)

:confirm_download
cls
echo ===== 下载配置确认 =====
echo.
if "!mode!"=="1" (
    echo 下载模式: 单个视频
    echo.
    echo 视频链接: !url!
    echo.
) else (
    echo 下载模式: 批量下载
    echo.
    echo 视频列表: urls.txt
    echo.
    echo 视频数量: !video_count! 个
    echo.
)
echo 最大分辨率: !format!P
echo.
echo 下载线程数: !threads!
echo.
echo 下载目录: !output_dir!
echo.

:: 检查cookies.txt是否配置
set "cookie_status=未配置"
if exist "config\cookies.txt" (
    findstr /r /c:"." "config\cookies.txt" >nul
    if not errorlevel 1 set "cookie_status=已配置"
)
echo Cookie状态: !cookie_status!
echo.
echo ===== =========== =====
echo [0] 退出脚本
echo.
color 0E
echo [1] 开始下载 [默认]
echo.
color 0B
echo [100] 返回首页
echo.

set /p choice="请选择操作(0/1/100)，直接回车开始下载: "
echo.

if "!choice!"=="" goto start_download
if "!choice!"=="1" goto start_download
if "!choice!"=="0" exit
if "!choice!"=="100" goto input_url
echo 无效选择，请重新输入
echo.
timeout /t 2 >nul
goto confirm_download

:start_download
cls
echo ===== 开始下载 =====
echo.
echo 正在下载，请稍候...
echo.

:: 尝试使用cookie下载
if "!cookie_status!"=="已配置" (
    if "!mode!"=="1" (
        yt-dlp -f "!filter!" ^
        --merge-output-format mp4 ^
        --concurrent-fragments !threads! ^
        --cookies "config\cookies.txt" ^
        -P "!output_dir!" ^
        "!url!" || (
            echo Cookie可能已失效，尝试不使用Cookie下载...
            echo.
            yt-dlp -f "!filter!" ^
            --merge-output-format mp4 ^
            --concurrent-fragments !threads! ^
            -P "!output_dir!" ^
            "!url!"
        )
    ) else (
        yt-dlp -f "!filter!" ^
        --merge-output-format mp4 ^
        --concurrent-fragments !threads! ^
        --cookies "config\cookies.txt" ^
        -P "!output_dir!" ^
        -a "!url!" || (
            echo Cookie可能已失效，尝试不使用Cookie下载...
            echo.
            yt-dlp -f "!filter!" ^
            --merge-output-format mp4 ^
            --concurrent-fragments !threads! ^
            -P "!output_dir!" ^
            -a "!url!"
        )
    )
) else (
    if "!mode!"=="1" (
        yt-dlp -f "!filter!" ^
        --merge-output-format mp4 ^
        --concurrent-fragments !threads! ^
        -P "!output_dir!" ^
        "!url!"
    ) else (
        yt-dlp -f "!filter!" ^
        --merge-output-format mp4 ^
        --concurrent-fragments !threads! ^
        -P "!output_dir!" ^
        -a "!url!"
    )
)

echo.
echo 下载完成！
echo.
pause >nul
