# AList Magisk 模块

[![Release](https://img.shields.io/github/v/release/Alien-Et/Alist-Magisk)](https://github.com/Alien-Et/Alist-Magisk/releases)
[![License](https://img.shields.io/github/license/Alien-Et/Alist-Magisk)](https://github.com/Alien-Et/Alist-Magisk/blob/main/LICENSE)

AList Magisk 模块将 [AList](https://github.com/AlistGo/alist) 文件服务器集成到 Android 系统中，通过 Magisk 以系统化方式运行，支持 ARM 和 ARM64 架构。

## 功能亮点
- **最新版本同步**：自动跟踪 AList 官方版本（当前：v3.45.0）。
- **无缝集成**：将 AList 二进制安装到 /system/bin，系统启动后自动运行。
- **随机凭据**：首次启动服务时生成管理员账号和密码，保存到模块目录，覆盖安装保留原有密码。
- **动态服务管理**：通过 Magisk 的“动作”按钮切换 AList 服务状态（启动/停止），模块描述动态显示服务状态和局域网地址（运行时）。
- **更新支持**：通过 update.json 提供模块更新检查。
- **轻量高效**：占用空间小，适合 Android 设备。

## 快速开始
1. **下载**：从 [GitHub Releases](https://github.com/Alien-Et/Alist-Magisk/releases) 获取最新模块（alist-magisk-v3.45.0.zip）。
2. **安装**：
   - 在 Magisk 应用中选择“从本地安装”，加载 ZIP 文件。
   - 重启设备以应用模块并启动 AList 服务。
3. **使用**：
   - 查看 `/data/adb/modules/alist-magisk/密码.txt` 获取账号和密码（首次启动后生成）。
   - 访问 http://localhost:5244 或设备 IP 的 5244 端口，登录 AList Web 界面。
   - 在 Magisk 应用中点击“动作”按钮切换服务状态，模块描述会动态更新。

## 详细文档
- **安装和使用**：查看 [模块自述文件](Alist-Magisk/README.md) 获取详细安装流程和故障排除。
- **更新日志**：查看 [CHANGELOG.md](Alist-Magisk/CHANGELOG.md)。
- **问题反馈**：提交 [Issue](https://github.com/Alien-Et/Alist-Magisk/issues).

## 贡献
- 欢迎提交 Pull Request 或 Issue。
- 感谢 [AList](https://github.com/AlistGo/alist) 项目提供支持。

## 许可证
本项目基于 [MIT 许可证](LICENSE) 发布。
