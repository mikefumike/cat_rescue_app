# 光影爱宠 — iOS 构建指南

## 前提条件

- 一个 **Apple ID**（免费注册即可）
- （可选）**Apple Developer 会员**（¥688/年），用于签名发布到 App Store
- 不用 Mac 也能编译（用 Codemagic 云构建）

---

## 方案 A：Codemagic 云构建（推荐，无需 Mac）

### 第1步：准备好代码仓库

1. 把代码传到 GitHub（或 GitLab/Bitbucket）
2. 确保 **`codemagic.yaml`** 在项目根目录
3. 提交时**不要**包含这些到 Git（已在 `.gitignore` 中）：
   - `build/`
   - `.dart_tool/`
   - `.packages`
   - `Podfile.lock`

### 第2步：注册 Codemagic

1. 打开 https://codemagic.io
2. 用 GitHub/GitLab 账号登录
3. 点击 **Add application** → 选择你的仓库
4. 选择 workflow：**ios-workflow**

### 第3步：配置代码签名（无证书也可以编译）

**方式一：无签名（仅测试）**
- 直接编译，产物为 `.app`，可通过 Xcode 安装到连接的设备

**方式二：有签名（可安装到手机）**
1. 在 Codemagic UI → **Environment variables** 添加：
   - `CM_CERTIFICATE` → 你的 Apple 发布证书 (P12, Base64)
   - `CM_CERTIFICATE_PASS` → 证书密码
   - `CM_PROVISIONING_PROFILE` → 描述文件 (Base64)

2. 或者用 **App Store Connect API key**（推荐）：
   - 访问 https://appstoreconnect.apple.com/access/api
   - 创建 API Key → 下载私钥文件
   - 在 Codemagic 设置 `APP_STORE_CONNECT_ISSUER_ID`、`APP_STORE_CONNECT_KEY_ID`、`APP_STORE_CONNECT_PRIVATE_KEY`

### 第4步：编译 & 下载

1. 点击 **Start build**
2. 等 15-20 分钟
3. 下载 `Runner.ipa` 用爱思助手/Sideloadly 安装到 iPhone

---

## 方案 B：本地 Mac + Xcode（你有 Mac 时）

```bash
cd cat_rescue_app

# 1. 安装依赖
flutter pub get

# 2. 安装 CocoaPods
cd ios
pod install
cd ..

# 3. 打开 Xcode 工作区
open ios/Runner.xcworkspace

# 4. 在 Xcode 中：
#    - Signing & Capabilities → Team → 选择你的 Apple ID
#    - Bundle Identifier → 改成你自己的（如 com.yourname.catRescueApp）

# 5. 编译
flutter build ios --release

# 6. 产物在：
#    build/ios/iphoneos/Runner.app
```

---

## 方案 C：免费侧载（无需 ¥688 会员）

1. 用 **Codemagic** 编译出 `.app`（`--no-codesign`）
2. 把 `.app` 传到 Mac 上
3. 用 **Sideloadly** 或 **AltStore** 安装到 iPhone
   - 需要 Apple ID（免费）
   - 每7天需要重签一次
   - 最多装 3 个应用

---

## iOS 图标

猫咪图标已经自动生成了（`flutter_launcher_icons` 已配置），包含所有 iOS 尺寸：
- 20×20 ~ 1024×1024 共 20 个尺寸
- 路径：`ios/Runner/Assets.xcassets/AppIcon.appiconset/`

## 注意事项

| 问题 | 说明 |
|------|------|
| `flutter_plugin_android_lifecycle` NDK 警告 | 不影响 iOS 构建，忽略 |
| 缺少 `Podfile.lock` | 首次 `pod install` 会自动生成 |
| 推送通知/位置权限 | 当前未配置，如需在 Xcode 中开启 Capabilities |
