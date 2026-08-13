Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Drawing.Drawing2D

$size = 512
$bmp = New-Object System.Drawing.Bitmap($size, $size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.Clear([System.Drawing.Color]::Transparent)

# 圆角背景：深蓝紫渐变
$pad = 32
$radius = 96
$bgRect = New-Object System.Drawing.Rectangle($pad, $pad, $size - 2*$pad, $size - 2*$pad)
$path = New-Object System.Drawing.Drawing2D.GraphicsPath
$r = $radius
$diameter = $r * 2
$path.AddArc($bgRect.X, $bgRect.Y, $diameter, $diameter, 180, 90)
$path.AddArc($bgRect.Right - $diameter, $bgRect.Y, $diameter, $diameter, 270, 90)
$path.AddArc($bgRect.Right - $diameter, $bgRect.Bottom - $diameter, $diameter, $diameter, 0, 90)
$path.AddArc($bgRect.X, $bgRect.Bottom - $diameter, $diameter, $diameter, 90, 90)
$path.CloseFigure()

$brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush($bgRect, [System.Drawing.Color]::FromArgb(255, 30, 41, 59), [System.Drawing.Color]::FromArgb(255, 15, 23, 42), 45)
$g.FillPath($brush, $path)
$brush.Dispose()

# 中间三个白色节点 + 连线（表达"画布节点"）
$center = New-Object System.Drawing.PointF(256, 256)
$left = New-Object System.Drawing.PointF(140, 320)
$right = New-Object System.Drawing.PointF(372, 192)

$linePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(180, 255, 255, 255), 6)
$linePen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
$g.DrawLine($linePen, $left, $center)
$g.DrawLine($linePen, $center, $right)
$linePen.Dispose()

function DrawNode($g, $point, $radius) {
    $fill = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    $g.FillEllipse($fill, $point.X - $radius, $point.Y - $radius, $radius * 2, $radius * 2)
    $fill.Dispose()
}

DrawNode $g $center 34
DrawNode $g $left 26
DrawNode $g $right 26

# 外发光（中心节点）
$glow = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(60, 56, 189, 248))
$g.FillEllipse($glow, $center.X - 48, $center.Y - 48, 96, 96)
$glow.Dispose()
DrawNode $g $center 34

$g.Dispose()

$out = "d:\sftool\infinite-canvas-main\web\build\icon.png"
$bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Output "Generated: $out"

# 验证
$v = [System.Drawing.Bitmap]::FromFile($out)
$tr = 0; $op = 0; $semi = 0
for ($y = 0; $y -lt $v.Height; $y += 8) {
    for ($x = 0; $x -lt $v.Width; $x += 8) {
        $a = $v.GetPixel($x, $y).A
        if ($a -eq 0) { $tr++ } elseif ($a -eq 255) { $op++ } else { $semi++ }
    }
}
Write-Output "Size: $($v.Width)x$($v.Height) transparent=$tr opaque=$op semi=$semi"
$v.Dispose()
