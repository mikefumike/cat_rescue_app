# iOS构建指南 - 喵星守护站

## 前置条件

### 硬件要求
- **Mac电脑**（必须）：iPhone/iPad应用只能在macOS上编译
- 推荐配置：Apple Silicon Mac (M1/M2/M3) 或 Intel Mac

### 软件要求
1. **macOS 13.0+** (Ventura或更高版本)
2. **Xcode 15.0+** (从App Store或Apple Developer网站下载)
3. **CocoaPods** (iOS依赖管理器)
4. **Flutter SDK** (macOS版本)

## 环境配置步骤

### 1. 安装Xcode
```bash
# 从App Store安装Xcode，或下载XIP文件手动安装

# 安装Xcode命令行工具
xcode-select --install

# 接受Xcode许可协议
sudo xcodebuild -license accept
```

### 2. 安装CocoaPods
```bash
sudo gem install cocoapods
# 或者使用Homebrew
brew install cocoapods
```

### 3. 安装Flutter SDK (macOS版本)
```bash
# 下载macOS版Flutter SDK
cd ~/development
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# 或使用Homebrew
brew install flutter
```

### 4. 配置Flutter
```bash
# 检查Flutter环境
flutter doctor

# 确保输出包含：
# [✓] Flutter (Channel stable)
# [✓] Xcode - develop for iOS and macOS
# [✓] CocoaPods
```

## 项目构建

### 1. 获取项目代码
将Windows上的项目同步到Mac（通过Git、网盘或U盘）：
```bash
# 项目路径（根据实际情况调整）
cd ~/Projects/cat_rescue_app
```

### 2. 安装iOS依赖
```bash
# 进入iOS目录
cd ios

# 安装CocoaPods依赖
pod install
pod repo update  # 如果遇到问题

cd ..
```

### 3. 运行应用
```bash
# 查看可用设备
flutter devices

# 在iOS模拟器上运行
flutter run -d <device_id>

# 或直接运行（会自动选择模拟器）
flutter run
```

### 4. 在真机上运行
```bash
# 连接iPhone后
flutter devices  # 查看设备

# 运行到真机
flutter run -d <iPhone_device_id>
```

## 真机调试配置

### Apple开发者账号
1. 访问 https://developer.apple.com
2. 注册开发者账号（免费或付费）
3. 在Xcode中添加账号：Preferences → Accounts

### 签名配置
1. 打开 `ios/Runner.xcworkspace`（用Xcode）
2. 选择 Runner 项目
3. 在 Signing & Capabilities 标签：
   - Team: 选择你的开发者账号
   - Bundle Identifier: 保持 `com.example.catRescueApp` 或修改

### 信任开发者证书（首次真机调试）
在iPhone上：设置 → 通用 → VPN与设备管理 → 信任开发者应用

## 常见问题

### 1. CocoaPods安装失败
```bash
# 更新CocoaPods仓库
pod repo update

# 清理缓存
pod cache clean --all
pod install
```

### 2. Xcode签名错误
- 确保Apple ID已添加到Xcode
- 检查Bundle Identifier是否唯一
- 尝试修改Bundle Identifier

### 3. 模拟器问题
```bash
# 打开iOS模拟器
open -a Simulator

# 重置模拟器
xcrun simctl erase all
```

### 4. 编译错误
```bash
# 清理Flutter缓存
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter run
```

## 发布准备

### App Store发布步骤
1. 创建App Store Connect账号
2. 准备应用截图和描述
3. 构建Release版本：
```bash
flutter build ios --release
```
4. 在Xcode中上传到App Store Connect
5. 提交审核

### Ad-hoc/内部分发
```bash
# 构建IPA文件
flutter build ios --release
# 在Xcode中：Product → Archive → Distribute App
```

## iOS特有功能

### 已配置的权限
- 相册访问：添加猫咪照片
- 相机使用：拍摄猫咪照片
- 定位服务：记录救助地点（可选）

### 推送通知（待实现）
如需推送通知，需：
1. 在pubspec.yaml取消注释 `firebase_messaging`
2. 配置Firebase项目
3. 添加APNs证书

## 文件结构

```
ios/
├── Runner/
│   ├── Info.plist          # 应用配置（已配置中文显示名和权限）
│   ├── AppDelegate.swift   # 应用入口
│   └── Assets.xcassets/    # 图标资源
├── Runner.xcodeproj/       # Xcode项目文件
├── Runner.xcworkspace/     # Xcode工作空间（打开这个）
└── Podfile                  # CocoaPods配置（首次pod install后生成）
```

## 远程构建方案

如果没有Mac电脑，可考虑：
1. **Codemagic** - Flutter官方推荐的CI/CD服务，免费额度可构建iOS
2. **GitHub Actions + macOS runner** - 需要付费账号
3. **虚拟机** - 在云端租用Mac（如MacStadium、MacinCloud）
4. **朋友/同事的Mac** - 借用他人Mac进行一次性构建

## 联系支持

如有问题，可参考：
- Flutter官方文档：https://docs.flutter.dev/deployment/ios
- CocoaPods官方：https://cocoapods.org/
- Stack Overflow: 搜索 `[flutter] [ios]`
