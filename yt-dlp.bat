@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
color 0B

:: 初始化配置
call :init_config
call :load_config
goto main_menu

:init_config
if not exist "config" mkdir "config"
if not exist "config\config.ini" (
    echo [single] > "config\config.ini"
    echo output_dir=.\video >> "config\config.ini"
    echo format=1080 >> "config\config.ini"
    echo threads=5 >> "config\config.ini"
    echo cookies= >> "config\config.ini"
    echo. >> "config\config.ini"
    echo [batch] >> "config\config.ini"
    echo output_dir=.\video >> "config\config.ini"
    echo format=1080 >> "config\config.ini"
    echo threads=3 >> "config\config.ini"
    echo cookies= >> "config\config.ini"
)
if not exist "config\urls.txt" echo. > "config\urls.txt"
goto :eof

:load_config
for /f "tokens=1,2 delims==" %%a in ('type "config\config.ini" ^| findstr /i "output_dir"') do (
    set "default_output=%%b"
)
for /f "tokens=1,2 delims==" %%a in ('type "config\config.ini" ^| findstr /i "format"') do (
    set "default_format=%%b"
)
for /f "tokens=1,2 delims==" %%a in ('type "config\config.ini" ^| findstr /i "threads"') do (
    set "default_threads=%%b"
)
for /f "tokens=1,2 delims==" %%a in ('type "config\config.ini" ^| findstr /i "cookies"') do (
    set "default_cookies=%%b"
)
goto :eof

:main_menu
cls
echo ===== 视频下载工具 ===== 
echo. 
echo [1] 单个视频下载 
echo [2] 批量下载 
echo [0] 退出脚本 
echo. 

set /p choice="请选择功能(0-2): "
if "!choice!"=="1" goto single_video
if "!choice!"=="2" goto batch_videos
if "!choice!"=="0" exit
echo 无效选择，请重新输入 
timeout /t 2 >nul
goto main_menu

:single_video
cls
echo ===== 单个视频下载 ===== 
echo. 
set /p url="请输入视频链接(输入0返回主菜单): "
if "!url!"=="0" goto main_menu
if "!url!"=="" goto single_video

echo. 
echo [1] 使用默认配置 [默认] 
echo [2] 自定义配置 
echo [3] 返回主菜单 
echo. 

set /p config_choice="请选择配置方式(1-3): "
if "!config_choice!"=="2" goto custom_config
if "!config_choice!"=="3" goto main_menu
if "!config_choice!"=="" set "config_choice=1"
call :use_default_config single
goto confirm_download

:use_default_config
set "output_dir=!default_output!"
set "format=!default_format!"
set "threads=!default_threads!"
set "cookies=!default_cookies!"
goto :eof

:custom_config
cls
echo ===== 自定义配置 ===== 
echo. 
set /p output_dir="请输入下载目录(默认.\video): "
if "!output_dir!"=="" set "output_dir=.\video"

echo. 
echo 选择视频质量： 
echo [1] 480P 
echo [2] 720P 
echo [3] 1080P [默认] 
echo [4] 2160P(4K) 
set /p quality="请选择(1-4): "
if "!quality!"=="1" set "format=480"
if "!quality!"=="2" set "format=720"
if "!quality!"=="" set "format=1080"
if "!quality!"=="3" set "format=1080"
if "!quality!"=="4" set "format=2160"

echo. 
set /p threads="请输入下载线程数(1-10，默认5): "
if "!threads!"=="" set "threads=5"

echo. 
set /p cookies="请输入cookies文件路径(可选): "
goto :eof

:confirm_download
cls
echo ===== 下载配置确认 ===== 
echo. 
echo 视频链接: !url! 
echo 下载目录: !output_dir! 
echo 视频质量: !format!P 
echo 下载线程: !threads! 

:: 检查cookies配置状态
if not "!cookies!"=="" (
    echo Cookies状态: 已配置 
) else (
    echo Cookies状态: 未配置 
)

echo. 
echo [1] 开始下载(默认) 
echo [2] 返回主菜单 
echo. 

set /p confirm="请选择(1-2): "
if "!confirm!"=="2" goto main_menu

call :download_video
echo. 
echo 脚本运行完成，按任意键返回主菜单... 
pause >nul
goto main_menu

:batch_videos
cls
echo ===== 批量下载 ===== 
echo. 

if not exist "config\urls.txt" (
    echo urls.txt文件不存在，已创建空文件 
    echo. > "config\urls.txt"
    timeout /t 2 >nul
    goto main_menu
)

findstr /r /c:"." "config\urls.txt" >nul
if errorlevel 1 (
    echo urls.txt文件为空，请添加视频链接 
    timeout /t 2 >nul
    goto main_menu
)

call :use_default_config batch

set /a url_count=0
for /f %%i in ('type "config\urls.txt"^|find /v /c ""') do set /a url_count=%%i

echo 检测到!url_count!个视频链接 
echo. 
echo 当前配置： 
echo 下载目录: !output_dir! 
echo 视频质量: !format!P 
echo 下载线程: !threads! 

:: 检查cookies配置状态
if not "!cookies!"=="" (
    echo Cookies状态: 已配置 
) else (
    echo Cookies状态: 未配置 
)

echo. 
echo [1] 开始下载(默认) 
echo [2] 返回主菜单 
echo. 

set /p batch_choice="请选择(1-2): "
if "!batch_choice!"=="2" goto main_menu

set "url=-a config\urls.txt"
call :download_video
echo. 
echo 脚本运行完成，按任意键返回主菜单... 
pause >nul
goto main_menu

:download_video
cls
echo ===== 开始下载 ===== 
echo. 

set "filter=bv[height<=!format!][ext=mp4]+ba[ext=m4a]/best"

if not "!cookies!"=="" (
    yt-dlp -f "!filter!" --merge-output-format mp4 --concurrent-fragments !threads! --cookies "!cookies!" -P "!output_dir!" !url! || (
        echo Cookie可能已失效，尝试不使用Cookie下载... 
        echo. 
        yt-dlp -f "!filter!" --merge-output-format mp4 --concurrent-fragments !threads! -P "!output_dir!" !url!
    )
) else (
    yt-dlp -f "!filter!" --merge-output-format mp4 --concurrent-fragments !threads! -P "!output_dir!" !url!
)

if errorlevel 1 (
    echo 下载失败！ 
    timeout /t 3 >nul
) else (
    echo 下载完成！ 
    timeout /t 3 >nul
)
goto :eof
