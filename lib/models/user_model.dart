import 'package:hive/hive.dart';

part 'user_model.g.dart';

/// 用户角色枚举
@HiveType(typeId: 2)
enum UserRole {
  @HiveField(0)
  guest,   // 游客 - 只读浏览
  @HiveField(1)
  admin,   // 管理员 - 完整权限
}

/// 用户模型
@HiveType(typeId: 3)
class UserModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String username;

  @HiveField(2)
  final String passwordHash;

  @HiveField(3)
  final UserRole role;

  @HiveField(4)
  final String displayName;

  @HiveField(5)
  final String avatar;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final bool isActive;

  UserModel({
    required this.id,
    required this.username,
    required this.passwordHash,
    required this.role,
    required this.displayName,
    this.avatar = '',
    required this.createdAt,
    this.isActive = true,
  });
}
