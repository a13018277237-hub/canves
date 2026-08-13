# 无限画布 - 使用说明

## 启动应用

### Windows
双击 `Windows-双击启动.bat`，浏览器会自动打开应用。

首次运行如果提示未找到 Python，请安装 Python 3：
- 下载地址：https://www.python.org/downloads/
- 安装时请勾选 "Add Python to PATH"
- 安装完成后重新双击 `Windows-双击启动.bat`

### macOS
双击 `Mac-双击启动.command` 文件，浏览器会自动打开。

如果提示"无法打开"，右键点击该文件 → 选择"打开" → 在弹窗中再次选择"打开"。

### Linux
在终端运行：
```bash
python3 serve.py
```

## 关闭应用

关闭终端窗口，或按 Ctrl + C。

## 系统要求

- Windows 10+ / macOS 10.15+ / Linux
- Python 3.6+（macOS 自带，Windows 需自行安装）

## 文件说明

| 文件 | 说明 |
|------|------|
| Windows-双击启动.bat | Windows 启动脚本 |
| Mac-双击启动.command | macOS 启动脚本 |
| serve.py | Python 启动器（跨平台备用） |
| dist/ | 应用文件，请勿删除或修改 |
