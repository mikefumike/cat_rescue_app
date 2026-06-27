# 自动启动脚本 - 喵星守护站 APP

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "   喵星守护站 APP - 自动启动脚本" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# 检查 Flutter SDK
Write-Host "步骤1：检查 Flutter SDK..." -ForegroundColor Yellow
if (Get-Command flutter -ErrorAction SilentlyContinue) {
    Write-Host "✅ Flutter SDK 已安装" -ForegroundColor Green
    flutter --version
} else {
    Write-Host "❌ Flutter SDK 未找到！" -ForegroundColor Red
    Write-Host "请按照以下步骤手动安装：" -ForegroundColor Yellow
    Write-Host "  1. 下载：https://storage.flutter-io.cn/flutter_infra_release/releases/stable/windows/flutter_windows_3.32.0-stable.zip" -ForegroundColor Yellow
    Write-Host "  2. 解压到：C:\Users\Administrator\flutter" -ForegroundColor Yellow
    Write-Host "  3. 添加到PATH：C:\Users\Administrator\flutter\bin" -ForegroundColor Yellow
    Write-Host "  4. 重新打开PowerShell，运行此脚本" -ForegroundColor Yellow
    pause
    exit 1
}

Write-Host ""
Write-Host "步骤2：检查 Android Studio..." -ForegroundColor Yellow
if (Test-Path "C:\Program Files\Android\Android Studio\bin\studio64.exe") {
    Write-Host "✅ Android Studio 已安装" -ForegroundColor Green
} else {
    Write-Host "⚠️  Android Studio 未找到（可选，用于模拟器）" -ForegroundColor Yellow
    Write-Host "   如果从真实设备运行，可以跳过" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "步骤3：运行 flutter doctor..." -ForegroundColor Yellow
flutter doctor

Write-Host ""
Write-Host "步骤4：进入项目目录..." -ForegroundColor Yellow
$projectPath = "C:\Users\Administrator\.qclaw\workspace-x5kuz49xple53hhg\cat_rescue_app"
if (Test-Path $projectPath) {
    Set-Location $projectPath
    Write-Host "✅ 已进入项目目录：$projectPath" -ForegroundColor Green
} else {
    Write-Host "❌ 项目目录未找到：$projectPath" -ForegroundColor Red
    pause
    exit 1
}

Write-Host ""
Write-Host "步骤5：安装依赖..." -ForegroundColor Yellow
flutter pub get

Write-Host ""
Write-Host "步骤6：生成 Hive 适配器..." -ForegroundColor Yellow
flutter packages pub run build_runner build --delete-conflicting-outputs

Write-Host ""
Write-Host "步骤7：检查已连接设备..." -ForegroundColor Yellow
flutter devices

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  准备完成！现在可以运行 APP" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "选择运行方式：" -ForegroundColor Yellow
Write-Host "  [1] 运行到 Android 设备/模拟器" -ForegroundColor White
Write-Host "  [2] 构建 APK 安装包" -ForegroundColor White
Write-Host "  [3] 退出" -ForegroundColor White
Write-Host ""

$choice = Read-Host "请输入选项 (1-3)"

switch ($choice) {
    '1' {
        Write-Host "正在运行 APP..." -ForegroundColor Green
        flutter run
    }
    '2' {
        Write-Host "正在构建 APK..." -ForegroundColor Green
        flutter build apk --release
        Write-Host "✅ APK 已生成：build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor Green
    }
    '3' {
        Write-Host "退出..." -ForegroundColor Yellow
        exit 0
    }
    default {
        Write-Host "无效选项" -ForegroundColor Red
        pause
    }
}

Write-Host ""
Write-Host "按任意键退出..." -ForegroundColor Yellow
pause