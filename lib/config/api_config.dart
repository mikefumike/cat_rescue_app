// lib/config/api_config.dart - API 配置
// 用于配置后端 API 地址

class ApiConfig {
  // 后端 API 基础地址
  // 部署到腾讯云后，替换为真实的 API 网关地址
  static const String BASE_URL = 'http://localhost:3000'; // 本地开发
  // static const String BASE_URL = 'https://xxx.gz.apigw.tencentcs.com'; // 生产环境

  // 认证相关
  static const String LOGIN = '$BASE_URL/api/auth/login';
  static const String REGISTER = '$BASE_URL/api/auth/register';
  static const String VERIFY = '$BASE_URL/api/auth/verify';
  static const String INIT_ADMIN = '$BASE_URL/api/auth/init-admin';

  // 猫咪管理
  static const String CATS = '$BASE_URL/api/cats';
  static const String CAT_DETAIL = '$BASE_URL/api/cats'; // + /:catId

  // 医疗记录
  static const String MEDICAL = '$BASE_URL/api/medical';
  static const String MEDICAL_BY_CAT = '$BASE_URL/api/medical/cat'; // + /:catId
  static const String UPCOMING_VISITS = '$BASE_URL/api/medical/upcoming/visits';

  // 收养申请
  static const String ADOPTIONS = '$BASE_URL/api/adoptions';
  static const String ADOPTION_DETAIL = '$BASE_URL/api/adoptions'; // + /:adoptionId
  static const String ADOPTION_STATUS = '$BASE_URL/api/adoptions'; // + /:adoptionId/status

  // 请求超时时间 (毫秒)
  static const int TIMEOUT = 10000;

  // 本地存储 key
  static const String TOKEN_KEY = 'auth_token';
  static const String USER_ROLE_KEY = 'user_role';
}