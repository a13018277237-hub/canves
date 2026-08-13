Add-Type -AssemblyName System.Drawing

$src = "d:\sftool\infinite-canvas-main\web\build\icon-src.png"
$dst = "d:\sftool\infinite-canvas-main\web\build\icon.png"

$img = [System.Drawing.Bitmap]::FromFile($src)
$w = $img.Width
$h = $img.Height
Write-Output "Source: ${w}x${h} $($img.PixelFormat)"

$rect = New-Object System.Drawing.Rectangle(0, 0, $w, $h)
$bmp = $img.Clone($rect, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$img.Dispose()

$lockBits = $bmp.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadWrite, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$stride = $lockBits.Stride
$scan0 = $lockBits.Scan0
$totalBytes = [Math]::Abs($stride) * $h
$bytes = New-Object byte[] $totalBytes
[System.Runtime.InteropServices.Marshal]::Copy($scan0, $bytes, 0, $totalBytes)

$cleared = 0
$semitransparent = 0
for ($y = 0; $y -lt $h; $y++) {
    $row = $y * $stride
    for ($x = 0; $x -lt $w; $x++) {
        $i = $row + $x * 4
        $b = $bytes[$i]
        $g = $bytes[$i + 1]
        $r = $bytes[$i + 2]
        $max = [Math]::Max($r, [Math]::Max($g, $b))
        $min = [Math]::Min($r, [Math]::Min($g, $b))
        $lum = ($max + $min) / 2
        $a = 255
        if ($lum -ge 250) {
            $a = 0
            $cleared++
        } elseif ($lum -gt 235) {
            $a = [int](255 * (250 - $lum) / 15)
            $semitransparent++
        }
        $bytes[$i + 3] = $a
    }
}

[System.Runtime.InteropServices.Marshal]::Copy($bytes, 0, $scan0, $totalBytes)
$bmp.UnlockBits($lockBits)
$bmp.Save($dst, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()

Write-Output "Output: $dst"
Write-Output "Cleared (alpha=0): $cleared / $($w * $h)"
Write-Output "Semitransparent (0<alpha<255): $semitransparent"
