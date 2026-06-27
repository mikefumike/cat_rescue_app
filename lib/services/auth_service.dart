import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:hive/hive.dart';
import 'package:cat_rescue_app/models/user_model.dart';

/// 权限管理服务 - 管理用户认证和权限控制
class AuthService {
  static const String _sessionBoxName = 'auth_session';
  static const String _usersBoxName = 'auth_users';

  late Box _sessionBox;
  late Box<UserModel> _usersBox;

  // 当前登录用户
  UserModel? _currentUser;

  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.role == UserRole.admin;
  bool get isGuest => _currentUser == null || _currentUser?.role == UserRole.guest;

  /// 初始化
  Future<void> init() async {
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(UserRoleAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(UserModelAdapter());
    }

    _sessionBox = await Hive.openBox(_sessionBoxName);
    _usersBox = await Hive.openBox<UserModel>(_usersBoxName);

    // 初始化默认管理员账户
    await _initDefaultAdmin();

    // 恢复登录状态
    await _restoreSession();
  }

  /// 初始化默认管理员账户
  Future<void> _initDefaultAdmin() async {
    final users = _usersBox.values.toList();
    final hasAdmin = users.any((u) => u.role == UserRole.admin && u.isActive);

    if (!hasAdmin) {
      final defaultAdmin = UserModel(
        id: 'admin_001',
        username: 'admin',
        passwordHash: _hashPassword('admin123'),
        role: UserRole.admin,
        displayName: '管理员',
        createdAt: DateTime.now(),
        isActive: true,
      );
      await _usersBox.put(defaultAdmin.id, defaultAdmin);
    }
  }

  /// 密码哈希（SHA-256）
  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  /// 登录
  Future<LoginResult> login(String username, String password) async {
    final passwordHash = _hashPassword(password);

    final user = _usersBox.values.firstWhere(
      (u) => u.username == username && u.passwordHash == passwordHash && u.isActive,
      orElse: () => throw Exception('用户名或密码错误'),
    );

    _currentUser = user;
    await _sessionBox.put('current_user_id', user.id);
    return LoginResult.success(user);
  }

  /// 游客模式 - 不登录直接浏览
  Future<void> enterAsGuest() async {
    _currentUser = UserModel(
      id: 'guest_000',
      username: 'guest',
      passwordHash: '',
      role: UserRole.guest,
      displayName: '游客',
      createdAt: DateTime.now(),
      isActive: true,
    );
    await _sessionBox.put('current_user_id', 'guest_000');
  }

  /// 恢复会话
  Future<void> _restoreSession() async {
    final userId = _sessionBox.get('current_user_id');
    if (userId != null && userId != 'guest_000') {
      _currentUser = _usersBox.get(userId);
    }
  }

  /// 登出
  Future<void> logout() async {
    _currentUser = null;
    await _sessionBox.delete('current_user_id');
  }

  /// 注册新用户（仅管理员可操作）
  Future<UserModel> registerUser({
    required String username,
    required String password,
    required String displayName,
    UserRole role = UserRole.guest,
  }) async {
    if (!isAdmin) throw Exception('权限不足，仅管理员可创建用户');

    // 检查用户名是否已存在
    final exists = _usersBox.values.any((u) => u.username == username);
    if (exists) throw Exception('用户名已存在');

    final user = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      username: username,
      passwordHash: _hashPassword(password),
      role: role,
      displayName: displayName,
      createdAt: DateTime.now(),
      isActive: true,
    );

    await _usersBox.put(user.id, user);
    return user;
  }

  /// 修改密码
  Future<void> changePassword(String oldPassword, String newPassword) async {
    if (_currentUser == null) throw Exception('未登录');
    if (_currentUser!.id == 'guest_000') throw Exception('游客账户无法修改密码');

    if (_currentUser!.passwordHash != _hashPassword(oldPassword)) {
      throw Exception('原密码错误');
    }

    final updated = UserModel(
      id: _currentUser!.id,
      username: _currentUser!.username,
      passwordHash: _hashPassword(newPassword),
      role: _currentUser!.role,
      displayName: _currentUser!.displayName,
      avatar: _currentUser!.avatar,
      createdAt: _currentUser!.createdAt,
      isActive: _currentUser!.isActive,
    );

    await _usersBox.put(updated.id, updated);
    _currentUser = updated;
  }

  /// 获取所有用户（仅管理员）
  List<UserModel> getAllUsers() {
    if (!isAdmin) return [];
    return _usersBox.values.toList();
  }

  /// 删除用户（仅管理员，不能删除自己）
  Future<void> deleteUser(String userId) async {
    if (!isAdmin) throw Exception('权限不足');
    if (userId == _currentUser?.id) throw Exception('不能删除自己');

    final user = _usersBox.get(userId);
    if (user == null) throw Exception('用户不存在');

    final updated = UserModel(
      id: user.id,
      username: user.username,
      passwordHash: user.passwordHash,
      role: user.role,
      displayName: user.displayName,
      avatar: user.avatar,
      createdAt: user.createdAt,
      isActive: false, // 软删除
    );
    await _usersBox.put(updated.id, updated);
  }

  /// 检查权限 - 是否可执行写操作
  bool canWrite() => isAdmin;

  /// 检查权限 - 是否可删除
  bool canDelete() => isAdmin;

  /// 检查权限 - 是否可管理用户
  bool canManageUsers() => isAdmin;
}

/// 登录结果
class LoginResult {
  final bool success;
  final UserModel? user;
  final String? error;

  LoginResult.success(this.user) : success = true, error = null;
  LoginResult.failure(this.error) : success = false, user = null;
}
