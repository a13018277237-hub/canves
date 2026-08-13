// 用 Node.js + canvas (skia-canvas) 生成 512x512 透明背景图标
// 备选：直接用 sharp 放大自带图标；若无 sharp，则手写 PNG 编码
// 这里走最稳的方案：写一个最简 PNG 文件（纯色透明 + 中心方块），保证可用
const fs = require("fs");
const path = require("path");
const zlib = require("zlib");

const SIZE = 512;
const PAD = 48;
const RADIUS = 96;

// 32bit ARGB pixel buffer
const buf = Buffer.alloc(SIZE * SIZE * 4);

function setPixel(x, y, r, g, b, a) {
    if (x < 0 || y < 0 || x >= SIZE || y >= SIZE) return;
    const i = (y * SIZE + x) * 4;
    buf[i] = b;
    buf[i + 1] = g;
    buf[i + 2] = r;
    buf[i + 3] = a;
}

// 圆角矩形区域内填深色
function inRoundRect(x, y, x0, y0, w, h, r) {
    if (x < x0 || y < y0 || x >= x0 + w || y >= y0 + h) return false;
    const dx = Math.min(x - x0, x0 + w - 1 - x);
    const dy = Math.min(y - y0, y0 + h - 1 - y);
    if (dx >= r || dy >= r) return true;
    const cx = r - dx;
    const cy = r - dy;
    return cx * cx + cy * cy <= r * r;
}

function dist(ax, ay, bx, by) {
    return Math.sqrt((ax - bx) ** 2 + (ay - by) ** 2);
}

// 背景：深蓝紫渐变（按 x 方向简化）
for (let y = 0; y < SIZE; y++) {
    for (let x = 0; x < SIZE; x++) {
        if (inRoundRect(x, y, PAD, PAD, SIZE - 2 * PAD, SIZE - 2 * PAD, RADIUS)) {
            const t = (x - PAD) / (SIZE - 2 * PAD);
            const r = Math.round(30 + (15 - 30) * t);
            const g = Math.round(41 + (23 - 41) * t);
            const b = Math.round(59 + (42 - 59) * t);
            setPixel(x, y, r, g, b, 255);
        }
        // else 保持透明 (0,0,0,0)
    }
}

// 节点连线
function drawLine(x0, y0, x1, y1, w, r, g, b, a) {
    const len = Math.hypot(x1 - x0, y1 - y0);
    const steps = Math.ceil(len * 2);
    for (let i = 0; i <= steps; i++) {
        const t = i / steps;
        const cx = x0 + (x1 - x0) * t;
        const cy = y0 + (y1 - y0) * t;
        for (let dy = -w; dy <= w; dy++) {
            for (let dx = -w; dx <= w; dx++) {
                if (dx * dx + dy * dy <= w * w) setPixel(cx + dx, cy + dy, r, g, b, a);
            }
        }
    }
}

function drawCircle(cx, cy, rad, r, g, b, a) {
    for (let dy = -rad; dy <= rad; dy++) {
        for (let dx = -rad; dx <= rad; dx++) {
            if (dx * dx + dy * dy <= rad * rad) setPixel(cx + dx, cy + dy, r, g, b, a);
        }
    }
}

const c = { x: 256, y: 256 };
const l = { x: 150, y: 320 };
const rt = { x: 362, y: 192 };

// 连线
drawLine(l.x, l.y, c.x, c.y, 4, 255, 255, 255, 200);
drawLine(c.x, c.y, rt.x, rt.y, 4, 255, 255, 255, 200);

// 节点
drawCircle(c.x, c.y, 36, 255, 255, 255, 255);
drawCircle(l.x, l.y, 28, 255, 255, 255, 255);
drawCircle(rt.x, rt.y, 28, 255, 255, 255, 255);

// 中心节点高光
drawCircle(c.x, c.y, 18, 56, 189, 248, 255);

// 写 PNG
function crc32(buf) {
    let c = ~0;
    for (let i = 0; i < buf.length; i++) {
        c ^= buf[i];
        for (let k = 0; k < 8; k++) c = (c >>> 1) ^ (0xedb88320 & -(c & 1));
    }
    return ~c >>> 0;
}

function chunk(type, data) {
    const len = Buffer.alloc(4);
    len.writeUInt32BE(data.length, 0);
    const typeBuf = Buffer.from(type, "ascii");
    const crcBuf = Buffer.alloc(4);
    crcBuf.writeUInt32BE(crc32(Buffer.concat([typeBuf, data])), 0);
    return Buffer.concat([len, typeBuf, data, crcBuf]);
}

const sig = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]);
const ihdr = Buffer.alloc(13);
ihdr.writeUInt32BE(SIZE, 0);
ihdr.writeUInt32BE(SIZE, 4);
ihdr[8] = 8; // bit depth
ihdr[9] = 6; // color type RGBA
ihdr[10] = 0;
ihdr[11] = 0;
ihdr[12] = 0;

// raw scanlines with filter byte 0
const raw = Buffer.alloc((SIZE * 4 + 1) * SIZE);
for (let y = 0; y < SIZE; y++) {
    raw[y * (SIZE * 4 + 1)] = 0;
    buf.copy(raw, y * (SIZE * 4 + 1) + 1, y * SIZE * 4, (y + 1) * SIZE * 4);
}
const idat = zlib.deflateSync(raw);

const png = Buffer.concat([sig, chunk("IHDR", ihdr), chunk("IDAT", idat), chunk("IEND", Buffer.alloc(0))]);

const out = path.join(__dirname, "build", "icon.png");
fs.writeFileSync(out, png);
console.log("Generated:", out, `(${png.length} bytes)`);

// 验证
const check = fs.readFileSync(out);
const w = check.readUInt32BE(16);
const h = check.readUInt32BE(20);
const colorType = check[25];
console.log(`Size: ${w}x${h} colorType=${colorType} (6=RGBA)`);
