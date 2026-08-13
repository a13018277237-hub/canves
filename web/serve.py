#!/usr/bin/env python3
"""
无限画布启动器
双击此文件或运行 python3 serve.py
启动后浏览器自动打开 http://localhost:3000
"""
import http.server
import socketserver
import webbrowser
import socket
import os
import sys
import argparse
import threading
import time
from pathlib import Path

PORT = 3000
ROOT = Path(__file__).parent / "dist"


class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(ROOT), **kwargs)

    def do_GET(self):
        # SPA fallback: 不存在的路径回退到 index.html
        path = self.path.split("?")[0].split("#")[0]
        candidate = ROOT / path.lstrip("/")
        if path != "/" and not candidate.exists() and not path.startswith("/assets"):
            self.path = "/"
        return super().do_GET()

    def log_message(self, *args, **kwargs):
        # 静默默认访问日志，避免刷屏
        pass


def find_port(start_port):
    """用 socket 测试端口是否可用，避免 TCPServer 关闭后立即重绑失败"""
    port = start_port
    while port < start_port + 100:
        try:
            with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
                s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
                s.bind(("127.0.0.1", port))
                return port
        except OSError:
            port += 1
    return start_port


class ReusableTCPServer(socketserver.TCPServer):
    allow_reuse_address = True


def main():
    parser = argparse.ArgumentParser(description="无限画布启动器")
    parser.add_argument("--port", type=int, default=PORT, help=f"端口号，默认 {PORT}")
    args = parser.parse_args()

    if not ROOT.exists():
        print(f"错误：未找到 dist 目录：{ROOT}")
        print("请确保此文件与 dist 文件夹在同一目录下")
        sys.exit(1)

    port = find_port(args.port)
    url = f"http://localhost:{port}"

    httpd = ReusableTCPServer(("127.0.0.1", port), Handler)

    print("=" * 44)
    print("  无限画布已启动")
    print(f"  浏览器地址: {url}")
    print("  按 Ctrl+C 停止")
    print("=" * 44)

    # 服务器启动成功后延迟打开浏览器
    def open_browser():
        time.sleep(1.5)
        webbrowser.open(url)

    threading.Thread(target=open_browser, daemon=True).start()

    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\n已停止")
        httpd.server_close()
        sys.exit(0)


if __name__ == "__main__":
    main()
