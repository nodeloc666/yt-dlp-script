yt-dlp的一键脚本
---

# 🎬 yt-dlp 批量下载脚本（支持 Windows / Linux）

> 基于 [`yt-dlp`](https://github.com/yt-dlp/yt-dlp) 的一键式视频批量下载工具，灵感来自 [nodeseek 大佬](https://www.nodeseek.com/post-334093-2#15)。

支持单个或多个视频链接下载，兼容 Windows 与主流 Linux 发行版（Debian / Ubuntu / Alpine / CentOS）。

---

## ✨ 功能特色

* 📥 **一键运行，按提示输入信息即可开始下载**
* 🍪 **支持自定义 Cookie（适用于登录后才能下载的视频）**
* 📂 **支持自定义输出目录**
* 📃 **支持批量下载（自动读取 `urls.txt` 文件）**
* ⚙️ **自动处理依赖环境（Linux 下自动安装 `yt-dlp`、`ffmpeg`）**

---

## 🖼️ 截图预览

| 示例 1                                                                | 示例 2                                                                |
| ------------------------------------------------------------------- | ------------------------------------------------------------------- |
| ![1](https://img.cccd.cloudns.be/file/1746720584399_1000193433.jpg) | ![2](https://img.cccd.cloudns.be/file/1746720581006_1000193434.jpg) |
| ![3](https://img.cccd.cloudns.be/file/1746720588978_1000193428.jpg) | ![4](https://img.cccd.cloudns.be/file/1746720587272_1000193427.jpg) |

---

## 🪟 Windows 使用方法

1. 下载：

   * [yt-dlp.exe](https://github.com/yt-dlp/yt-dlp)
   * [ffmpeg（Windows 版本）](https://www.gyan.dev/ffmpeg/builds/ffmpeg-git-full.7z)

2. 解压后将以下文件放在同一目录下（例如 `yt-dlp` 文件夹中）：

   * `yt-dlp.exe`
   * `ffmpeg.exe`
   * `ffprobe.exe`
   * `yt-dlp.bat`（脚本文件）

3. 双击运行 `yt-dlp.bat`，根据提示输入信息开始下载。

---

## 🐧 Linux 使用方法

适配系统：**Debian / Ubuntu / Alpine / CentOS**

打开终端，执行以下命令一键部署/更新并运行：

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/nodeloc666/yt-dlp-script/main/install.sh)"

```

---

## ⚠️ 注意事项

1. **批量模式**：自动读取脚本目录下的 `urls.txt`，每行填写一个视频链接；如未检测到，将自动创建该文件。
2. **资源限制**：内存较小的设备请避免同时下载大体积视频或设置高线程数。
3. **CentOS 说明**：因环境特殊性未完全测试，建议先在非生产环境尝试；其余主流系统均已验证可用。

---

## 📄 License

本项目遵循 MIT 协议。

---

是否还需要我帮你生成项目徽章（badges）或优化 `.bat`/`.sh` 脚本结构？
