# AList Magisk 模块

[![Release](https://img.shields.io/github/v/release/Alien-Et/Alist-Magisk)](https://github.com/Alien-Et/Alist-Magisk/releases)
[![License](https://img.shields.io/github/license/Alien-Et/Alist-Magisk)](https://github.com/Alien-Et/Alist-Magisk/blob/main/LICENSE)

AList Magisk 模块将 [AList](https://github.com/AlistGo/alist) 文件服务器集成到 Android 系统中，通过 Magisk 以系统化方式运行，支持 ARM 和 ARM64 架构。

## 功能亮点
- **自动同步最新版本**：与 AList 官方版本保持一致（当前版本：v3.45.0）。
- **系统级集成**：将 AList 二进制文件安装到 /system/bin，系统启动后自动运行服务。
- **随机凭据生成**：首次启动服务时生成管理员账号和密码，保存至 /data/adb/modules/alist-magisk/随机密码.txt（格式为“账号：xxx”和“密码：xxx”），后续重启若文件存在则不重置密码。
- **动态服务管理**：通过 Magisk 的“动作”按钮启动或停止 AList 服务，module.prop 的 description 字段动态更新运行状态和访问地址。
- **更新支持**：通过 update.json 提供模块更新检查。
- **轻量高效**：占用空间小，适合 Android 设备。

## 快速开始
1. **下载模块**：
   - 从 [GitHub Releases](https://github.com/Alien-Et/Alist-Magisk/releases) 下载最新模块 ZIP 文件（例如：alist-magisk-v3.45.0.zip）。
2. **安装模块**：
   - 打开 Magisk 应用，进入“模块”选项卡。
   - 点击“从本地安装”，选择下载的 ZIP 文件。
   - 安装过程会显示设备架构（ARM 或 ARM64）及 AList 二进制安装路径（/system/bin/alist）。
   - 安装完成后，重启设备以应用模块并启动 AList 服务。
3. **使用模块**：
   - 查看 /data/adb/modules/alist-magisk/随机密码.txt 获取初始账号和密码。
   - 访问 AList Web 界面（默认：http://localhost:5244 或 http://<设备IP>:5244），使用 随机密码.txt 中的凭据登录。
   - 在 Magisk 应用中点击“动作”按钮切换服务状态，module.prop 的描述会更新为：
     - 运行中：【运行中】局域网地址：http://<设备IP>:5244 | 初始账密请移步到"/data/adb/modules/alist-magisk/随机密码.txt"查看
     - 已停止：【已停止】请点击"操作"启动程序。项目地址：https://github.com/Alien-Et/Alist-Magisk

## 详细文档
- **安装与使用指南**：查看 [模块自述文件](Alist-Magisk/README.md) 获取详细安装步骤和故障排除方法。
- **更新日志**：查看 [CHANGELOG.md](Alist-Magisk/CHANGELOG.md) 了解版本更新内容。
- **问题反馈**：在 [Issue](https://github.com/Alien-Et/Alist-Magisk/issues) 页面提交问题或建议。

## 功能详情
- **服务管理**：
  - 系统启动后，AList 服务通过 service.sh 自动运行，数据存储在 /data/adb/modules/alist-magisk/data。
  - 使用 Magisk 的“动作”按钮（需 Magisk v28.0 或更高版本）切换服务状态：
    - 服务运行时，module.prop 显示运行状态和局域网访问地址，提示用户查看 随机密码.txt 获取凭据。
    - 服务停止时，module.prop 显示停止状态和项目地址。
- **密码管理**：
  - 首次启动生成随机账号和密码，保存至 /data/adb/modules/alist-magisk/随机密码.txt（格式：账号：admin\n密码：xxxxxxxx）。
  - 若 随机密码.txt 存在，后续重启不会重置密码；若文件被删除，则重新生成。
- **数据持久性**：覆盖安装模块不会重置 data 目录或 随机密码.txt，需手动清理。
- **日志支持**：服务日志保存在 /data/adb/modules/alist-magisk/service.log，便于调试。

## 常见问题
- **Q: 无法访问 AList Web 界面？**
  - 确保网络正常，尝试使用设备 IP 访问（http://<设备IP>:5244）。
  - 检查服务状态：pgrep -f alist
  - 手动启动服务：su -c /data/adb/modules/alist-magisk/action.sh
- **Q: 密码丢失？**
  - 查看 /data/adb/modules/alist-magisk/随机密码.txt。
  - 若文件丢失，重启设备重新生成密码。
- **Q: 动作按钮无效？**
  - 确保 Magisk 版本 >= v28.0。
  - 手动操作：su -c pkill -f alist 或 su -c /data/adb/modules/alist-magisk/action.sh
- **Q: module.prop 未更新？**
  - 确认服务运行：pgrep -f alist
  - 检查日志：cat /data/adb/modules/alist-magisk/service.log
  - 手动运行：su -c /data/adb/modules/alist-magisk/service.sh

## 贡献
- 欢迎提交 Pull Request 或 Issue。
- 感谢 [AList](https://github.com/AlistGo/alist) 项目提供支持。

## 许可证
本项目基于 [MIT 许可证](LICENSE) 发布。
