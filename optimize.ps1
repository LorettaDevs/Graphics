function New-EmptyDirectory {
    param (
        [string[]]$Paths
    )

    foreach ($path in $Paths) {
        if (Test-Path -Path $path -PathType Container) {
            Remove-Item -Path $path -Recurse -Force
        }
        New-Item -Path $path -ItemType Directory
    }
}

$sizes = @(
    16, # favicon
    64,
    128,
    196, # apple
    256,
    512,
    1024,
    2048
)

New-EmptyDirectory "dist"

# SVG Optimization
svgo "./logo.svg" -o "./dist/logo.svg"

# SVG Rasterizing
foreach ($size in $sizes) {
    Write-Output "============== ${size}x${size} =============="
    $pngPath = "./dist/logo_${size}x${size}.png"
    Write-Output "resvg"
    resvg -w $size -h $size "./dist/logo.svg" $pngPath
    Write-Output "pngquant"
    pngquant --strip --skip-if-larger --force --quality=45-85 $pngPath --output $pngPath
    pngquant --strip --skip-if-larger --force --ordered --speed=1 --quality=50-90 $pngPath --output $pngPath
    Write-Output "oxipng"
    oxipng --strip all --opt max --quiet $pngPath
}
