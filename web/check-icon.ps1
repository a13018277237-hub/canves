Add-Type -AssemblyName System.Drawing
$img = [System.Drawing.Bitmap]::FromFile("d:\sftool\infinite-canvas-main\web\build\icon.png")
$w = $img.Width
$h = $img.Height
Write-Output "Size: ${w}x${h} PixelFormat: $($img.PixelFormat)"
$transparent = 0
$opaque = 0
$semi = 0
for ($y = 0; $y -lt $h; $y += 4) {
    for ($x = 0; $x -lt $w; $x += 4) {
        $px = $img.GetPixel($x, $y)
        if ($px.A -eq 0) { $transparent++ }
        elseif ($px.A -eq 255) { $opaque++ }
        else { $semi++ }
    }
}
Write-Output "Sampled - transparent=$transparent opaque=$opaque semi=$semi"
Write-Output "TopLeft: $($img.GetPixel(0,0))"
Write-Output "TopRight: $($img.GetPixel($w-1,0))"
Write-Output "BottomLeft: $($img.GetPixel(0,$h-1))"
Write-Output "BottomRight: $($img.GetPixel($w-1,$h-1))"
Write-Output "Center: $($img.GetPixel([int]($w/2),[int]($h/2)))"
$img.Dispose()
