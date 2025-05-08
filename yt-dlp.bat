@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
color 0B

:input_url
cls
echo ===== YouTube 视频下载工具 =====
echo.
echo [1] 单个视频下载
echo [2] 批量视频下载
echo.
set /p mode="请选择下载模式(1-2): "

if "!mode!"=="1" (
    goto single_video
) else if "!mode!"=="2" (
    goto batch_videos
) else (
    echo 无效选择，请重新输入
    timeout /t 2 >nul
    goto input_url
)

:single_video
cls
echo ===== 单个视频下载 =====
echo.
set /p url="请输入视频链接: "
if "!url!"=="" goto single_video
goto select_quality

:batch_videos
cls
echo ===== 批量视频下载 =====
echo.
echo 请将视频链接保存在同目录下的 urls.txt 文件中

echo 每行一个链接
echo.
if not exist "urls.txt" (
    echo 未找到 urls.txt 文件
    echo 已为您创建 urls.txt 文件，请在文件中添加视频链接后重试
    echo.> urls.txt
    echo.
    echo 请按任意键继续...
    pause >nul
    goto input_url
)

findstr /r /c:"." "urls.txt" >nul
if errorlevel 1 (
    echo urls.txt 文件为空，请添加视频链接后重试

    echo.
    echo 请按任意键继续...
    pause >nul
    goto input_url
)

set "url=urls.txt"

echo 已检测到 urls.txt 文件，包含有效链接

timeout /t 2 >nul

:select_quality
cls
echo ===== 请选择视频分辨率 =====
echo.
echo [1] 480P
echo [2] 720P
echo [3] 1080P
echo [4] 2160P(4K)
echo.
set /p choice="请输入数字选择(1-4): "

if "!choice!"=="1" (
    set "format=480"
) else if "!choice!"=="2" (
    set "format=720"
) else if "!choice!"=="3" (
    set "format=1080"
) else if "!choice!"=="4" (
    set "format=2160"
) else (
    echo 无效选择，请重新输入
    timeout /t 2 >nul
    goto select_quality
)
set "filter=bv[height<=!format!][ext=mp4]+ba[ext=m4a]/best"

:select_threads
cls
echo ===== 请选择下载线程数 =====
echo.
echo 线程数越高下载速度越快，但可能会导致不稳定
echo 推荐值: 4-6
echo.
set /p threads="请输入下载线程数(1-10): "

set "valid=true"
if !threads! LSS 1 set "valid=false"
if !threads! GTR 10 set "valid=false"
echo !threads!|findstr /r "^[1-9][0-9]*$" >nul || set "valid=false"

if "!valid!"=="true" (
    goto confirm_download
) else (
    echo 无效线程数，请输入1-10之间的整数
    timeout /t 2 >nul
    goto select_threads
)

:confirm_download
cls
echo ===== 下载配置确认 =====
echo.
if "!mode!"=="1" (
    echo 下载模式: 单个视频
    echo 视频链接: !url!
) else (
    echo 下载模式: 批量下载
    echo 视频列表: urls.txt
)
echo 最大分辨率: !format!P
echo 下载线程数: !threads!
echo.
echo [1] 开始下载

echo [2] 重新配置
echo.
set /p confirm="请选择(1-2): "

if "!confirm!"=="1" (
    goto start_download
) else if "!confirm!"=="2" (
    goto input_url
) else (
    echo 无效选择，请重新输入
    timeout /t 2 >nul
    goto confirm_download
)

:start_download
cls
echo ===== 开始下载 =====
echo.
echo 正在下载，请稍候...
echo.

if "!mode!"=="1" (
    yt-dlp -f "!filter!" ^
    --merge-output-format mp4 ^
    --concurrent-fragments !threads! ^
    "!url!"
) else (
    yt-dlp -f "!filter!" ^
    --merge-output-format mp4 ^
    --concurrent-fragments !threads! ^
    -a "!url!"
)

echo.
echo 下载完成！
pause >nul
