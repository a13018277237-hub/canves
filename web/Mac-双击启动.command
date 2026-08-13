#!/bin/bash
# macOS 启动脚本：双击即可启动应用
# 不需要安装 Node.js 或任何依赖，使用 macOS 自带的 Python 3

cd "$(dirname "$0")"

PORT=3000

# 检查端口是否被占用，占用则换端口
while lsof -i :$PORT > /dev/null 2>&1; do
    PORT=$((PORT + 1))
done

# 自动打开浏览器
(sleep 1 && open "http://localhost:$PORT") &

echo "============================================"
echo "  无限画布已启动"
echo "  浏览器地址: http://localhost:$PORT"
echo "  关闭此窗口即可停止应用"
echo "============================================"
echo ""

# 用 macOS 自带的 Python 3 启动静态服务器
python3 -m http.server $PORT --directory dist

# 如果 python3 不存在，回退到 python
if [ $? -ne 0 ]; then
    echo "未找到 python3，尝试 python..."
    python -m SimpleHTTPServer $PORT
fi
