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

  String get age {
    if (birthDate == null) return '未知';
    final now = DateTime.now();
    final age = now.difference(birthDate!);
    final months = (age.inDays / 30).floor();
    if (months < 12) return '${months}个月';
    final years = (months / 12).floor();
    return '$years岁${months % 12 > 0 ? '${months % 12}个月' : ''}';
  }

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

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'birthDate': birthDate?.toIso8601String(),
    'gender': gender,
    'breed': breed,
    'weight': weight,
    'personalityTags': personalityTags,
    'photos': photos,
    'status': status,
    'rescueDate': rescueDate.toIso8601String(),
    'description': description,
    'medicalRecords': medicalRecords.map((r) => r.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'growthPhotos': growthPhotos.map((p) => p.toJson()).toList(),
  };

  factory CatModel.fromJson(Map<String, dynamic> json) => CatModel(
    id: json['id'] as String,
    name: json['name'] as String,
    birthDate: json['birthDate'] != null ? DateTime.parse(json['birthDate'] as String) : null,
    gender: json['gender'] as String,
    breed: json['breed'] as String,
    weight: (json['weight'] as num).toDouble(),
    personalityTags: (json['personalityTags'] as List<dynamic>).cast<String>(),
    photos: (json['photos'] as List<dynamic>).cast<String>(),
    status: json['status'] as String,
    rescueDate: DateTime.parse(json['rescueDate'] as String),
    description: json['description'] as String?,
    medicalRecords: (json['medicalRecords'] as List<dynamic>?)
        ?.map((r) => MedicalRecordModel.fromJson(r as Map<String, dynamic>)).toList() ?? [],
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
    growthPhotos: (json['growthPhotos'] as List<dynamic>?)
        ?.map((p) => GrowthPhotoModel.fromJson(p as Map<String, dynamic>)).toList() ?? [],
  );
}
