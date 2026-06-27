# 喵星守护站 - 安装配置指南

## 🚨 Flutter SDK安装（必须首先完成）

由于自动下载多次失败，请按以下方式**手动安装**Flutter SDK：

### 方法一：下载压缩包（最稳定，推荐）

1. **下载Flutter SDK**
   - 访问：https://storage.flutter-io.cn/flutter_infra_release/releases/stable/windows/
   - 下载最新版：`flutter_windows_*-stable.zip`（约1.5GB）
   - 例如：`flutter_windows_3.32.0-stable.zip`

2. **解压到用户目录**
   ```powershell
   # 解压到 C:\Users\你的用户名\flutter
   # 确保路径不包含空格或中文
   ```

3. **添加到环境变量PATH**
   ```powershell
   # 方式A：PowerShell（临时）
   $env:PATH += ";C:\Users\Administrator\flutter\bin"
   
   # 方式B：系统环境变量（永久）
   # 右键"此电脑" → 属性 → 高级系统设置 → 环境变量
   # 在"用户变量"的PATH中添加：C:\Users\Administrator\flutter\bin
   ```

4. **验证安装**
   ```powershell
   flutter --version
   flutter doctor
   ```

---

### 方法二：Git克隆（需要Git）

```powershell
# 设置国内镜像
$env:FLUTTER_STORAGE_BASE_URL = "https://storage.flutter-io.cn"
$env:PUB_HOSTED_URL = "https://pub.flutter-io.cn"

# 克隆Flutter（stable分支）
git clone https://github.com/flutter/flutter.git -b stable --depth 1 "$env:USERPROFILE\flutter"

# 添加到PATH
$env:PATH += ";$env:USERPROFILE\flutter\bin"

# 验证
flutter --version
```

---

## ✅ Flutter安装完成后的配置步骤

### 1. 安装Android Studio（必须）

1. 下载：https://developer.android.com/studio
2. 安装时勾选：
   - ✅ Android SDK
   - ✅ Android SDK Platform
   - ✅ Android Virtual Device
3. 启动Android Studio，完成初始设置

### 2. 接受Android许可

```powershell
flutter doctor --android-licenses
# 一路输入 y 接受所有许可
```

### 3. 配置项目

```powershell
# 进入项目目录
cd C:\Users\Administrator\.qclaw\workspace-x5kuz49xple53hhg\cat_rescue_app

# 安装依赖
flutter pub get

# 生成Hive适配器（重要！）
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### 4. 连接设备或启动模拟器

```powershell
# 查看已连接设备
flutter devices

# 如果没有设备，启动Android模拟器
# 方式A：Android Studio → Device Manager → 创建/启动虚拟机
# 方式B：连接真实Android手机（开启USB调试）
```

### 5. 运行应用

```powershell
# 运行到Android
flutter run

# 如果是发布模式
flutter run --release
```

---

## 🔧 常见问题解决

### 问题1：`flutter doctor` 报错"Unable to find bundled Java"

**解决方案**：
1. 打开Android Studio
2. File → Settings → Android SDK → SDK Tools
3. 勾选 "Android SDK Command-line Tools (latest)"
4. Apply → OK
5. 重新运行 `flutter doctor`

---

### 问题2：`flutter pub get` 下载依赖慢

**解决方案**：
```powershell
# 设置国内镜像
$env:PUB_HOSTED_URL = "https://pub.flutter-io.cn"
$env:FLUTTER_STORAGE_BASE_URL = "https://storage.flutter-io.cn"

# 重新运行
flutter pub get
```

---

### 问题3：`build_runner` 生成代码失败

**解决方案**：
```powershell
# 删除冲突文件
Remove-Item lib\models\*.g.dart -ErrorAction SilentlyContinue

# 重新生成
flutter packages pub run build_runner build --delete-conflicting-outputs
```

---

### 问题4：运行`flutter run`时报错"Gradle build failed"

**解决方案**：
```powershell
# 进入android目录
cd android

# 清理Gradle
.\gradlew clean

# 返回项目根目录
cd ..

# 重新运行
flutter run
```

---

## 📦 项目已完成的文件

✅ **已完成所有核心功能开发**，包括：

1. **配置与模型**
   - `pubspec.yaml` - 项目依赖
   - `lib/models/cat_model.dart` - 猫咪模型
   - `lib/models/medical_record_model.dart` - 医疗记录模型

2. **服务层**
   - `lib/services/database_service.dart` - 本地数据库

3. **UI界面**
   - `lib/main.dart` - 应用入口
   - `lib/screens/home_screen.dart` - 主页面
   - `lib/screens/cat_list_screen.dart` - 猫咪列表
   - `lib/screens/cat_detail_screen.dart` - 猫咪详情
   - `lib/screens/add_edit_cat_screen.dart` - 添加/编辑猫咪
   - `lib/screens/medical_record_screen.dart` - 医疗记录
   - `lib/screens/add_edit_medical_record_screen.dart` - 添加/编辑医疗记录
   - `lib/screens/adoption_screen.dart` - 领养列表
   - `lib/screens/adoption_detail_screen.dart` - 领养详情
   - `lib/screens/add_edit_adoption_screen.dart` - 添加/编辑领养
   - `lib/screens/settings_screen.dart` - 设置页面

4. **工具类**
   - `lib/utils/data_generator.dart` - 测试数据生成

5. **文档**
   - `README.md` - 项目说明
   - `INSTALLATION_GUIDE.md` - 本安装指南

---

## 🚀 快速启动检查清单

- [ ] Flutter SDK已安装（`flutter --version` 成功）
- [ ] Android Studio已安装（`flutter doctor` 无错误）
- [ ] Android许可证已接受（`flutter doctor --android-licenses`）
- [ ] 设备已连接（`flutter devices` 能看到设备）
- [ ] 项目依赖已安装（`flutter pub get` 成功）
- [ ] Hive适配器已生成（`flutter packages pub run build_runner` 成功）

完成以上步骤后，运行 `flutter run` 即可启动应用！

---

## 📞 需要帮助？

如果遇到问题，可以：
1. 查看 `flutter doctor` 的完整输出
2. 检查 `FLUTTER_ROOT\docs` 官方文档
3. 访问 Flutter中文网：https://flutter.cn

---

**最后更新**：2026-06-01
**项目路径**：`C:\Users\Administrator\.qclaw\workspace-x5kuz49xple53hhg\cat_rescue_app\`
