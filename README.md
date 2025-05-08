# 简介
一键脚本，可批量进行视频下载
# 使用方法
## Windows
下载[yt-dlp](https://github.com/yt-dlp/yt-dlp)
下载[ffmpeg](https://www.gyan.dev/ffmpeg/builds/ffmpeg-git-full.7z)

新建文件夹`yt-dlp`，将`ffmpeg.exe`,`ffprobe.exe`,`yt-dlp.exe`,`yt-dlp.bat`放在同一目录下，然后双击运行`yt-dlp.bat`运行，按照提示输入相应信息即可

## Linux（对Debian/Ubuntu/Alpine/Centos都做了适配）

```sh
mkdir yt-dlp && cd yt-dlp && curl "https://raw.githubusercontent.com/nodeloc666/yt-dlp-bat/refs/heads/main/yt-dlp.sh" -o yt-dlp.sh && bash yt-dlp.sh
```


**注意**：
1. 批量下载时，会自动检测同目录下的urls.txt，如若没有，会自动创建，在txt文件，视频链接每行一个链接
2. 内存较小时，尽量避免`大视频`和`高线程`
3. centos由于没有对应系统，并未做测试，其他系统都进行测试，能正常运行
