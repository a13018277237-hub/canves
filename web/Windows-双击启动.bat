@echo off
chcp 65001 > nul
cd /d "%~dp0"

REM 检查 Python
where python >nul 2>nul
if %errorlevel% neq 0 (
    where py >nul 2>nul
    if %errorlevel% neq 0 (
        echo ============================================
        echo   未找到 Python，请先安装 Python 3
        echo   下载地址: https://www.python.org/downloads/
        echo   安装时请勾选 "Add Python to PATH"
        echo ============================================
        echo =
        pause
        exit /b 1
    )
    set PY=py
) else (
    set PY=python
)

echo ============================================
echo   无限画布启动中...
echo   浏览器会自动打开，请稍候
echo   关闭此窗口即可停止应用
echo ============================================
echo =

REM serve.py 会自己找可用端口并打开浏览器
%PY% serve.py

REM 如果 Python 退出（出错或用户关闭），保持窗口不立即关闭
echo =
echo 应用已停止
pause
