// Electron 主进程：开发模式加载 Vite dev server，生产模式加载打包后的 dist/index.html
// 详见 web/package.json 的 electron:* 脚本
const { app, BrowserWindow, shell, Menu } = require("electron");
const path = require("node:path");
const fs = require("node:fs");

const isDev = !!process.env.VITE_DEV;
const distDir = path.join(__dirname, "..", "dist");
// 开发模式从源码 build 目录读图标；生产模式 electron-builder 已把图标嵌入 exe，无需单独文件
const iconPath = path.join(__dirname, "..", "build", "icon.png");
const hasIcon = fs.existsSync(iconPath);

function createWindow() {
    // 应用显示标题：这里可自由修改，不影响用户数据归属
    // 注意：用户数据归属的键是 package.json build.appId 和 build.productName，切勿修改那两项
    const win = new BrowserWindow({
        width: 1440,
        height: 900,
        backgroundColor: "#0a0a0a",
        icon: hasIcon ? iconPath : undefined,
        title: "无限画布",
        webPreferences: {
            contextIsolation: true,
            nodeIntegration: false,
            spellcheck: false,
        },
    });

    // 外部链接（如文档、GitHub）交给系统浏览器打开，避免在应用内打开空白页
    win.webContents.setWindowOpenHandler(({ url }) => {
        if (/^https?:/.test(url)) {
            shell.openExternal(url);
            return { action: "deny" };
        }
        return { action: "allow" };
    });

    if (isDev) {
        win.loadURL("http://localhost:3000");
        win.webContents.openDevTools();
    } else {
        // 生产模式加载本地文件，hash 路由默认定位到根路径（首页）
        win.loadFile(path.join(distDir, "index.html"));
    }
}

app.whenReady().then(() => {
    // 生产环境隐藏默认菜单栏；开发模式保留便于调试
    if (!isDev) Menu.setApplicationMenu(null);
    createWindow();
    app.on("activate", () => {
        if (BrowserWindow.getAllWindows().length === 0) createWindow();
    });
});

app.on("window-all-closed", () => {
    if (process.platform !== "darwin") app.quit();
});
