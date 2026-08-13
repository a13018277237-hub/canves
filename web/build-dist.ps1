# 构建并打包成可分发压缩包
# 用法：在 web 目录运行 powershell -ExecutionPolicy Bypass -File build-dist.ps1
# Requires -Version 5.1

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "开始构建..." -ForegroundColor Cyan
npm run build
if ($LASTEXITCODE -ne 0) { Write-Host "构建失败" -ForegroundColor Red; exit 1 }

$distDir = "dist"
if (-not (Test-Path $distDir)) {
    Write-Host "dist 目录不存在" -ForegroundColor Red
    exit 1
}

$pkgName = "infinite-canvas-web"
if (Test-Path $pkgName) { Remove-Item -Recurse -Force $pkgName }
New-Item -ItemType Directory -Path $pkgName | Out-Null

Copy-Item -Recurse -Force "dist" "$pkgName/dist"
Copy-Item -Force "Mac-双击启动.command" "$pkgName/Mac-双击启动.command"
Copy-Item -Force "Windows-双击启动.bat" "$pkgName/Windows-双击启动.bat"
Copy-Item -Force "serve.py" "$pkgName/serve.py"
Copy-Item -Force "README-用户使用.md" "$pkgName/README.md"

$zip = "$pkgName.zip"
if (Test-Path $zip) { Remove-Item -Force $zip }
Compress-Archive -Path "$pkgName/*" -DestinationPath $zip -CompressionLevel Optimal

Remove-Item -Recurse -Force $pkgName

Write-Host ""
Write-Host "完成！分发包已生成: $zip" -ForegroundColor Green
Write-Host "把这个 zip 发给用户即可。" -ForegroundColor Green
