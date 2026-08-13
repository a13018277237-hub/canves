@echo off
chcp 65001 > nul
cd /d "%~dp0web"
powershell -NoProfile -ExecutionPolicy Bypass -File build-dist.ps1
pause
