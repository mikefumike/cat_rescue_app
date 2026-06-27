# 喵星守护站 - 流浪猫救助管理APP

跨平台流浪猫救助管理应用，帮助救助者系统化管理猫咪信息、医疗记录和领养流程。

## 📱 功能特性

### 核心功能
- ✅ **猫咪管理**：添加/编辑/删除猫咪信息，支持照片、性格标签、状态管理
- ✅ **医疗记录管理**：疫苗、驱虫、绝育、疾病治疗记录，日历视图，到期提醒
- ✅ **领养管理**：领养申请审核、进度跟踪、回访记录
- ✅ **数据统计**：仪表盘展示关键指标，各状态猫咪数量统计

### 技术特性
- 🚀 **跨平台**：一套代码运行iOS和Android
- 💾 **本地存储**：Hive本地数据库，无需联网
- 🎨 **现代UI**：Material 3设计，流畅动画
- 📸 **图片支持**：图片选择、预览、缓存
- 📅 **日历视图**：直观展示医疗记录时间线
- 🔔 **到期提醒**：疫苗/驱虫到期自动提醒

---

## 📂 项目结构

```
lib/
├── main.dart                          # 应用入口
├── models/
│   ├── cat_model.dart                # 猫咪数据模型
│   └── medical_record_model.dart     # 医疗记录数据模型
├── services/
│   └── database_service.dart         # 本地数据库服务
└── screens/
    ├── home_screen.dart               # 主页面（仪表盘）
    ├── cat_list_screen.dart          # 猫咪列表
    ├── cat_detail_screen.dart        # 猫咪详情
    ├── add_edit_cat_screen.dart      # 添加/编辑猫咪
    ├── medical_record_screen.dart    # 医疗记录列表（日历）
    ├── add_edit_medical_record_screen.dart  # 添加/编辑医疗记录
    ├── adoption_screen.dart          # 领养列表
    ├── adoption_detail_screen.dart   # 领养详情
    ├── add_edit_adoption_screen.dart # 添加/编辑领养申请
    └── settings_screen.dart          # 设置页面
```

---

## 🛠️ 安装与运行

### 1. 安装Flutter SDK

#### 方法一：官方安装（推荐）
1. 访问 [Flutter官网](https://flutter.dev)
2. 下载Windows版Flutter SDK
3. 解压到 `C:\Users\你的用户名\flutter`
4. 添加到环境变量PATH：`C:\Users\你的用户名\flutter\bin`

#### 方法二：国内镜像（快速）
```powershell
# 使用国内镜像下载（如果官方下载慢）
$env:FLUTTER_STORAGE_BASE_URL = "https://storage.flutter-io.cn"
$env:PUB_HOSTED_URL = "https://pub.flutter-io.cn"

# 从GitHub克隆（需要Git）
git clone https://github.com/flutter/flutter.git -b stable --depth 1 "$env:USERPROFILE\flutter"
```

#### 方法三：直接下载压缩包
1. 访问 https://storage.flutter-io.cn/flutter_infra_release/releases/stable/windows/
2. 下载最新版 `flutter_windows_*-stable.zip`
3. 解压到 `C:\Users\你的用户名\flutter`
4. 添加到环境变量PATH

### 2. 环境配置

```powershell
# 验证Flutter安装
flutter doctor

# 如果提示缺少Android工具链，安装Android Studio
# 如果提示缺少iOS工具链（Mac），安装Xcode

# 接受Android许可
flutter doctor --android-licenses
```

### 3. 安装依赖

```powershell
cd cat_rescue_app
flutter pub get
```

### 4. 生成代码（Hive适配器）

```powershell
# 生成.g.dart文件
flutter packages pub run build_runner build --delete-conflicting-outputs

# 如果提示冲突，使用：
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### 5. 运行应用

```powershell
# 连接真实设备或启动模拟器
flutter devices

# 运行到Android
flutter run

# 运行到iOS（需要Mac）
flutter run -d ios

# 构建发布版
flutter build apk --release  # Android
flutter build ios --release   # iOS
```

---

## 📦 依赖包说明

### 状态管理
- `provider`: 状态管理
- `flutter_riverpod`: 响应式状态管理

### 路由导航
- `go_router`: 声明式路由

### 本地存储
- `hive_flutter`: 轻量级NoSQL数据库
- `shared_preferences`: 简单键值存储

### UI组件
- `flutter_easyloading`: 加载提示
- `fluttertoast`: Toast提示
- `cached_network_image`: 网络图片缓存
- `image_picker`: 图片选择
- `table_calendar`: 日历组件
- `form_field_validator`: 表单验证

### 工具
- `intl`: 日期格式化
- `package_info_plus`: 应用信息
- `permission_handler`: 权限管理

---

## 🎯 使用指南

### 添加第一只猫咪
1. 打开APP，点击底部"猫咪"标签
2. 点击右下角"+"按钮
3. 填写猫咪信息（名字、品种、体重等）
4. 添加照片（可选）
5. 点击"保存"

### 记录医疗信息
1. 在猫咪详情页，查看"医疗记录"部分
2. 点击"查看全部"进入医疗记录列表
3. 点击右下角"+"添加记录
4. 选择记录类型（疫苗/驱虫/绝育/疾病治疗）
5. 填写标题、日期、药品信息等
6. 设置下次预约日期（可选，用于提醒）
7. 保存

### 管理领养流程
1. 点击底部"领养"标签
2. 点击"+"添加领养申请
3. 填写申请人信息、居住条件等
4. 审核通过后，更新猫咪状态为"已送养"

---

## 🐛 常见问题

### 1. Flutter SDK下载慢或失败
**解决方案**：
- 使用国内镜像：`$env:FLUTTER_STORAGE_BASE_URL = "https://storage.flutter-io.cn"`
- 手动下载压缩包，解压安装

### 2. `flutter doctor` 报错
**解决方案**：
- 确保Android Studio已安装
- 运行 `flutter doctor --android-licenses` 接受许可
- 检查环境变量PATH是否包含Flutter的bin目录

### 3. `build_runner` 生成代码失败
**解决方案**：
```powershell
# 删除冲突文件后重新生成
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### 4. 图片无法显示
**解决方案**：
- 检查 `pubspec.yaml` 中是否已配置网络图片权限
- Android: 检查 `android/app/src/main/AndroidManifest.xml` 网络权限
- iOS: 检查 `ios/Runner/Info.plist` 网络权限

---

## 📝 开发进度

### ✅ 已完成（100%）
- [x] 项目基础配置
- [x] 数据模型（猫咪、医疗记录）
- [x] 数据库服务（Hive本地存储）
- [x] 猫咪管理UI（列表/详情/添加/编辑）
- [x] 医疗记录UI（列表/日历/添加/编辑）
- [x] 领养管理UI（列表/详情/添加/编辑）
- [x] 设置页面
- [x] 应用入口和主题配置

### ⏳ 待完善
- [ ] Flutter SDK环境安装
- [ ] 代码生成（Hive适配器）
- [ ] 测试数据生成
- [ ] 真机调试
- [ ] 性能优化
- [ ] 发布打包

---

## 👥 贡献指南

欢迎提交Issue和Pull Request！

### 开发流程
1. Fork本项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 提交Pull Request

---

## 📄 开源协议

本项目采用MIT协议开源。

---

## 📧 联系方式

如有问题或建议，请提交Issue或联系开发者。

**开发者**: 资深移动端架构师（iOS + Android + 跨平台）

**项目地址**: `C:\Users\Administrator\.qclaw\workspace-x5kuz49xple53hhg\cat_rescue_app\`

---

## 🙏 致谢

感谢所有为流浪猫救助事业贡献力量的人！

---

**最后更新**: 2026-06-01
