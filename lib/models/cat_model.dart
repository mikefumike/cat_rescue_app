import 'package:hive/hive.dart';
import 'medical_record_model.dart';
import 'growth_photo_model.dart';

part 'cat_model.g.dart';

@HiveType(typeId: 0)
class CatModel {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final DateTime? birthDate;
  
  @HiveField(3)
  final String gender;
  
  @HiveField(4)
  final String breed;
  
  @HiveField(5)
  final double weight;
  
  @HiveField(6)
  final List<String> personalityTags;
  
  @HiveField(7)
  final List<String> photos;
  
  @HiveField(8)
  final String status; // 待救助、隔离中、健康待领养、已送养、回喵星
  
  @HiveField(9)
  final DateTime rescueDate;
  
  @HiveField(10)
  final String? description;
  
  @HiveField(11)
  final List<MedicalRecordModel> medicalRecords;
  
  @HiveField(12)
  final DateTime createdAt;
  
  @HiveField(13)
  final DateTime updatedAt;

  @HiveField(14)
  final List<GrowthPhotoModel> growthPhotos;

  CatModel({
    required this.id,
    required this.name,
    this.birthDate,
    required this.gender,
    required this.breed,
    required this.weight,
    required this.personalityTags,
    required this.photos,
    required this.status,
    required this.rescueDate,
    this.description,
    this.medicalRecords = const [],
    required this.createdAt,
    required this.updatedAt,
    this.growthPhotos = const [],
  });

  // 计算年龄
  String get age {
    if (birthDate == null) return '未知';
    final now = DateTime.now();
    final age = now.difference(birthDate!);
    final months = (age.inDays / 30).floor();
    if (months < 12) return '${months}个月';
    final years = (months / 12).floor();
    return '$years岁${months % 12 > 0 ? '${months % 12}个月' : ''}';
  }

  // 拷贝方法
  CatModel copyWith({
    String? id,
    String? name,
    DateTime? birthDate,
    String? gender,
    String? breed,
    double? weight,
    List<String>? personalityTags,
    List<String>? photos,
    String? status,
    DateTime? rescueDate,
    String? description,
    List<MedicalRecordModel>? medicalRecords,
    List<GrowthPhotoModel>? growthPhotos,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CatModel(
      id: id ?? this.id,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      breed: breed ?? this.breed,
      weight: weight ?? this.weight,
      personalityTags: personalityTags ?? this.personalityTags,
      photos: photos ?? this.photos,
      status: status ?? this.status,
      rescueDate: rescueDate ?? this.rescueDate,
      description: description ?? this.description,
      medicalRecords: medicalRecords ?? this.medicalRecords,
      growthPhotos: growthPhotos ?? this.growthPhotos,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}