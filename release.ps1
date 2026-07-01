# release.ps1 - 发版辅助脚本
# 用法: .\release.ps1 1.1.0
# 前提: 已执行 flutter build apk --debug

param(
    [Parameter(Mandatory=$true)]
    [string]$Version
)

$projRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$apkSource = "$projRoot\build\app\outputs\flutter-apk\app-debug.apk"
$versionDir = "$projRoot\versions\V$Version"

if (-not (Test-Path $apkSource)) {
    Write-Host "❌ APK 未找到: $apkSource" -ForegroundColor Red
    Write-Host "请先运行: flutter build apk --debug" -ForegroundColor Yellow
    exit 1
}

# 创建版本目录
New-Item -ItemType Directory -Path $versionDir -Force | Out-Null

# 复制 APK
$apkDest = "$versionDir\cat_rescue_app-V${Version}-debug.apk"
Copy-Item $apkSource $apkDest -Force
$size = [Math]::Round((Get-Item $apkDest).Length / 1MB, 1)

# 更新 pubspec.yaml buildNumber
$pubspec = "$projRoot\pubspec.yaml"
$content = [System.IO.File]::ReadAllText($pubspec, [System.Text.Encoding]::UTF8)
if ($content -match 'version:\s*(?<ver>\d+\.\d+\.\d+)\+(?<build>\d+)') {
    $newBuild = [int]$Matches.build + 1
    $content = $content -replace 'version:\s*\d+\.\d+\.\d+\+\d+', "version: $($Matches.ver)+$newBuild"
    [System.IO.File]::WriteAllText($pubspec, $content, [System.Text.Encoding]::UTF8)
    Write-Host "📦 pubspec.yaml buildNumber: $($Matches.build) → $newBuild" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "✅ V${Version} 归档完成" -ForegroundColor Green
Write-Host "   APK: $apkDest ($size MB)"
Write-Host ""
Write-Host "📝 请手动更新 VERSION_HISTORY.md，然后提交 Git:"
Write-Host "   git add VERSION_HISTORY.md pubspec.yaml versions/"
Write-Host "   git commit -m \"Release V${Version}\""
Write-Host "   git tag v${Version}"
Write-Host "   git push && git push --tags"
