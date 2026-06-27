# 后端集成指南 - 喵星守护站

本文档指导如何将 Flutter APP 从本地 Hive 数据库迁移到云端 Serverless 后端。

## 📋 目录

1. [前置条件](#前置条件)
2. [部署后端](#部署后端)
3. [配置 Flutter APP](#配置-flutter-app)
4. [修改代码](#修改代码)
5. [测试](#测试)
6. [数据迁移](#数据迁移)
7. [故障排查](#故障排查)

---

## 前置条件

### 1. 腾讯云账号

- 注册地址: <https://cloud.tencent.com/>
- 实名认证（必须）
- 获取 SecretId 和 SecretKey: <https://console.cloud.tencent.com/cam/capi>

### 2. MongoDB 数据库

**选项A: 腾讯云 MongoDB（推荐）**

1. 访问 <https://console.cloud.tencent.com/mongodb>
2. 创建实例（最低配约 30元/月）
3. 获取连接字符串

**选项B: 本地 MongoDB（测试用）**

```bash
# Windows 安装 MongoDB Community Edition
# 下载: https://www.mongodb.com/try/download/community

# 启动 MongoDB
mongod --dbpath="C:\data\db"
```

**选项C: MongoDB Atlas（免费）**

- 注册: <https://www.mongodb.com/atlas>
- 创建免费集群
- 获取连接字符串

### 3. Node.js 环境

- 下载: <https://nodejs.org/>
- 验证: `node --version` (需要 16+)

---

## 部署后端

### 方式1: 使用部署脚本（推荐）

```bash
cd cat_rescue_backend
.\deploy.ps1
```

脚本会自动：
1. 检查 Node.js
2. 安装依赖
3. 检查 Serverless CLI
4. 配置腾讯云凭证
5. 创建 `.env` 文件
6. 部署到腾讯云

### 方式2: 手动部署

#### 1. 安装 Serverless CLI

```bash
npm install -g serverless
```

#### 2. 配置腾讯云凭证

```bash
serverless config credentials --provider tencent --key <SecretId> --secret <SecretKey>
```

#### 3. 安装依赖

```bash
cd cat_rescue_backend
npm install
```

#### 4. 配置环境变量

```bash
cp .env.example .env
# 编辑 .env 填入真实值
notepad .env
```

#### 5. 部署

```bash
serverless deploy
```

部署成功后会返回 **API 网关地址**，记录此地址（例如: `https://xxx.gz.apigw.tencentcs.com`）

#### 6. 配置环境变量（腾讯云控制台）

1. 访问 <https://console.cloud.tencent.com/scf>
2. 找到 `cat-rescue-api` 函数
3. 点击"函数管理" → "函数配置"
4. 添加环境变量:
   - `MONGODB_URI`: MongoDB 连接字符串
   - `JWT_SECRET`: JWT 签名密钥（修改为随机字符串）

---

## 配置 Flutter APP

### 1. 更新 `lib/config/api_config.dart`

```dart
class ApiConfig {
  // 生产环境: 替换为真实的 API 网关地址
  static const String BASE_URL = 'https://xxx.gz.apigw.tencentcs.com';

  // 本地开发:
  // static const String BASE_URL = 'http://localhost:3000';
}
```

### 2. 安装依赖

```bash
cd cat_rescue_app
flutter pub get
```

---

## 修改代码

### 方式1: 完全使用云端（推荐）

修改 `lib/main.dart`，将 `DatabaseService()` 替换为 `ApiService()`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化 API 服务（不需要 await）
  final apiService = ApiService();

  runApp(MyApp(apiService: apiService));
}
```

然后修改所有页面，将 `DatabaseService()` 替换为 `ApiService()`。

### 方式2: 混合模式（离线支持）

保留本地 Hive 数据库，同时支持云端同步:

```dart
// lib/services/sync_service.dart
class SyncService {
  final DatabaseService _local = DatabaseService();
  final ApiService _api = ApiService();

  // 同步本地数据到云端
  Future<void> syncToCloud() async {
    // 实现同步逻辑
  }

  // 从云端拉取数据
  Future<void> syncFromCloud() async {
    // 实现同步逻辑
  }
}
```

---

## 测试

### 1. 本地测试后端

```bash
cd cat_rescue_backend
npm start
```

访问 <http://localhost:3000/health> 验证后端是否正常运行。

### 2. 测试登录

```bash
# 初始化管理员账号
curl -X POST http://localhost:3000/api/auth/init-admin

# 登录
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'
```

### 3. 测试 API 接口

```bash
# 使用上一步返回的 token
TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."

# 获取所有猫咪
curl http://localhost:3000/api/cats \
  -H "Authorization: Bearer $TOKEN"
```

### 4. 运行 Flutter APP

```bash
cd cat_rescue_app
flutter run -d chrome
```

---

## 数据迁移

### 从本地 Hive 迁移到 MongoDB

创建迁移脚本 `cat_rescue_backend/migrate.js`:

```javascript
const { Hive } = require('hive-dart');
const mongoose = require('mongoose');
const Cat = require('./models/cat');
const MedicalRecord = require('./models/medical');
const Adoption = require('./models/adoption');

async function migrate() {
  // 连接 MongoDB
  await mongoose.connect(process.env.MONGODB_URI);

  // 读取 Hive 数据
  const cats = await Hive.box('cats').values.toList();

  // 迁移到 MongoDB
  for (const cat of cats) {
    await Cat.create(cat);
  }

  console.log(`✅ 迁移 ${cats.length} 只猫咪数据`);
  process.exit(0);
}

migrate().catch(console.error);
```

运行迁移:

```bash
cd cat_rescue_backend
node migrate.js
```

---

## 故障排查

### 1. 部署失败

**问题**: `serverless deploy` 失败

**解决**:
- 检查腾讯云凭证是否正确
- 检查 `serverless.yml` 配置是否正确
- 查看详细错误日志: `serverless deploy --debug`

### 2. 后端无法连接 MongoDB

**问题**: 后端启动时报错 `MongooseServerSelectionError`

**解决**:
- 检查 `.env` 中的 `MONGODB_URI` 是否正确
- 检查 MongoDB 实例是否运行
- 检查防火墙/安全组是否允许连接

### 3. Flutter APP 无法连接后端

**问题**: API 请求失败

**解决**:
- 检查 `ApiConfig.BASE_URL` 是否正确
- 检查后端是否正常运行（访问 `/health`）
- 检查 token 是否过期
- 查看浏览器控制台错误信息

### 4. CORS 错误

**问题**: 浏览器报 CORS 错误

**解决**:
- 后端已启用 CORS（`app.use(cors())`）
- 检查前端请求的 `Content-Type` 是否正确
- 检查请求头是否包含 `Authorization`

---

## 成本优化

### 1. 使用免费额度

- 云函数: 每月 **100万次** 调用免费
- API 网关: 每月 **100万次** 请求免费
- MongoDB Atlas: **免费集群** (512MB 存储)

### 2. 减少不必要的 API 调用

- 使用本地缓存（Hive）
- 批量操作（一次请求处理多个数据）
- 避免轮询，使用 WebSocket 或推送通知

### 3. 选择合适的 MongoDB 方案

| 方案 | 成本 | 适用场景 |
|------|------|-----------|
| MongoDB Atlas 免费集群 | 0元/月 | 小型项目（<500MB数据） |
| 腾讯云 MongoDB 基础版 | ~30元/月 | 中型项目 |
| 自建 MongoDB | 0元（服务器成本） | 有服务器资源 |

---

## 安全建议

### 1. 修改默认密码

部署后立即修改默认管理员密码:

```bash
# 使用 API 更新密码（需要实现此接口）
curl -X PUT http://localhost:3000/api/auth/change-password \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"oldPassword":"admin123","newPassword":"newStrongPassword"}'
```

### 2. 使用强 JWT 密钥

修改 `.env` 中的 `JWT_SECRET` 为随机字符串:

```bash
# 生成随机字符串
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

### 3. 启用 HTTPS

腾讯云 API 网关默认支持 HTTPS，无需额外配置。

### 4. 限制 CORS

生产环境建议限制 CORS 允许的域名:

```javascript
app.use(cors({
  origin: 'https://your-flutter-app-domain.com'
}));
```

---

## 下一步

- [ ] 添加图片上传功能（集成腾讯云 COS）
- [ ] 添加推送通知功能
- [ ] 添加数据统计分析
- [ ] 优化性能和用户体验
- [ ] 添加单元测试

---

**文档版本**: 1.0.0
**最后更新**: 2026-06-03
**作者**: Cat Rescue Team