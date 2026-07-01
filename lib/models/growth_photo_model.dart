import 'package:hive/hive.dart';

part 'growth_photo_model.g.dart';

/// 猫咪成长记录（支持照片和视频）
@HiveType(typeId: 5)
class GrowthPhotoModel {
  @HiveField(0)
  final String id;

  /// 本地存储的文件名（通过 MediaStorageService 保存）
  @HiveField(1)
  final String photoFileName;

  /// 拍摄日期
  @HiveField(2)
  final DateTime dateTaken;

  /// 备注（如：打完疫苗精神很好；长了0.5kg）
  @HiveField(3)
  final String? note;

  /// 当时的体重（kg）
  @HiveField(4)
  final double? weight;

  @HiveField(5)
  final DateTime createdAt;

  /// 是否为视频（true=视频, false=照片）
  @HiveField(6)
  final bool isVideo;

  GrowthPhotoModel({
    required this.id,
    required this.photoFileName,
    required this.dateTaken,
    this.note,
    this.weight,
    required this.createdAt,
    this.isVideo = false,
  });

  /// 获取媒体类型标签文字
  String get mediaLabel => isVideo ? '视频' : '照片';

  /// 获取图标
  String get mediaEmoji => isVideo ? '🎬' : '📷';

  GrowthPhotoModel copyWith({
    String? id,
    String? photoFileName,
    DateTime? dateTaken,
    String? note,
    double? weight,
    DateTime? createdAt,
    bool? isVideo,
  }) {
    return GrowthPhotoModel(
      id: id ?? this.id,
      photoFileName: photoFileName ?? this.photoFileName,
      dateTaken: dateTaken ?? this.dateTaken,
      note: note ?? this.note,
      weight: weight ?? this.weight,
      createdAt: createdAt ?? this.createdAt,
      isVideo: isVideo ?? this.isVideo,
    );
  }  Map<String, dynamic> toJson() => {
    'id': id,
    'photoFileName': photoFileName,
    'dateTaken': dateTaken.toIso8601String(),
    'note': note,
    'weight': weight,
    'createdAt': createdAt.toIso8601String(),
    'isVideo': isVideo,
  };

  factory GrowthPhotoModel.fromJson(Map<String, dynamic> json) => GrowthPhotoModel(
    id: json['id'] as String,
    photoFileName: json['photoFileName'] as String,
    dateTaken: DateTime.parse(json['dateTaken'] as String),
    note: json['note'] as String?,
    weight: (json['weight'] as num?)?.toDouble(),
    createdAt: DateTime.parse(json['createdAt'] as String),
    isVideo: json['isVideo'] as bool? ?? false,
  );
}