# AList Magisk 模块安装指南

本模块将 [AList](https://github.com/AlistGo/alist) 文件服务器集成到 Android 系统中，当前版本：v3.45.0。

## 功能
- 自动同步 AList 官方版本
- 支持 ARM 和 ARM64 架构
- 首次安装生成随机管理员账号和密码，保存到 `/data/adb/modules/alist-magisk/密码.txt`
- 自动启动 AList 服务，数据存储在模块的 `data` 目录
- 支持动作按钮，管理 AList 服务

## 安装流程
1. **准备工作**：
   - 确保设备已安装 Magisk（建议 v28.0 或更高版本以支持动作按钮）。
   - 设备已获得 Root 权限。
   - 确保有网络连接以下载模块。

2. **下载模块**：
   - 从 [GitHub Releases](https://github.com/Alien-Et/Alist-Magisk/releases) 下载最新模块 ZIP 文件（例如：alist-magisk-v3.45.0.zip）。

3. **安装模块**：
   - 打开 Magisk 应用，进入“模块”选项卡。
   - 点击“从本地安装”，选择下载的 ZIP 文件。
   - 安装过程会显示：
     - 设备架构（ARM 或 ARM64）。
     - AList 二进制安装路径（/system/bin/alist）。
     - 首次安装生成的管理员账号和密码。
   - 安装完成后，重启设备。

4. **验证安装**：
   - 检查 `/data/adb/modules/alist-magisk/密码.txt` 是否存在。
   - 运行以下命令检查 AList 服务：
     ```bash
     alist version
     ```
   - 访问 AList Web 界面（默认：http://localhost:5244，使用 `密码.txt` 中的账号和密码登录）。

## 使用说明
- **服务管理**：
  - AList 服务在系统启动时自动运行（通过 service.sh）。
  - 使用 Magisk 应用的“动作”按钮检查服务状态。
  - 手动管理服务：
    ```bash
    su -c /data/adb/modules/alist-magisk/action.sh start   # 启动服务
    su -c /data/adb/modules/alist-magisk/action.sh stop    # 停止服务
    su -c /data/adb/modules/alist-magisk/action.sh status  # 检查状态
    su -c /data/adb/modules/alist-magisk/action.sh reset   # 重置密码
    ```
- **更新模块**：通过 Magisk 检查更新，或手动下载最新 ZIP 文件重新安装。
- **卸载模块**：在 Magisk 中禁用或删除模块，重启设备（数据目录需手动清理）。

## 常见问题
- **Q: 无法访问 Web 界面？**
  - 确保网络正常，尝试使用设备 IP 访问（http://<设备IP>:5244）。
  - 检查服务状态：
    ```bash
    su -c /data/adb/modules/alist-magisk/action.sh status
    ```
  - 手动启动服务：
    ```bash
    su -c /data/adb/modules/alist-magisk/action.sh start
    ```
- **Q: 密码丢失？**
  - 查看 `/data/adb/modules/alist-magisk/密码.txt`。
  - 或运行：
    ```bash
    su -c /data/adb/modules/alist-magisk/action.sh reset
    ```
- **Q: 动作按钮未显示？**
  - 确保 Magisk 版本 >= v28.0。
  - 确认 action.sh 存在且具有执行权限（chmod 755）。

## 更多信息
访问 [项目主页](https://github.com/Alien-Et/Alist-Magisk) 获取完整文档和更新日志。
