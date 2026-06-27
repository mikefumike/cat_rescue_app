import 'package:hive/hive.dart';

part 'medical_record_model.g.dart';

@HiveType(typeId: 1)
class MedicalRecordModel {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String catId;
  
  @HiveField(2)
  final String type; // 疫苗、驱虫、绝育、疾病治疗
  
  @HiveField(3)
  final String title;
  
  @HiveField(4)
  final DateTime recordDate;
  
  @HiveField(5)
  final DateTime? nextDueDate;
  
  @HiveField(6)
  final String? medication;
  
  @HiveField(7)
  final String? dosage;
  
  @HiveField(8)
  final String? notes;
  
  @HiveField(9)
  final List<String> photos;
  
  @HiveField(10)
  final DateTime createdAt;

  MedicalRecordModel({
    required this.id,
    required this.catId,
    required this.type,
    required this.title,
    required this.recordDate,
    this.nextDueDate,
    this.medication,
    this.dosage,
    this.notes,
    this.photos = const [],
    required this.createdAt,
  });

  // 是否到期或即将到期
  bool get isDueSoon {
    if (nextDueDate == null) return false;
    final now = DateTime.now();
    final difference = nextDueDate!.difference(now).inDays;
    return difference >= 0 && difference <= 7; // 7天内到期
  }

  bool get isOverdue {
    if (nextDueDate == null) return false;
    return DateTime.now().isAfter(nextDueDate!);
  }

  // 拷贝方法
  MedicalRecordModel copyWith({
    String? id,
    String? catId,
    String? type,
    String? title,
    DateTime? recordDate,
    DateTime? nextDueDate,
    String? medication,
    String? dosage,
    String? notes,
    List<String>? photos,
    DateTime? createdAt,
  }) {
    return MedicalRecordModel(
      id: id ?? this.id,
      catId: catId ?? this.catId,
      type: type ?? this.type,
      title: title ?? this.title,
      recordDate: recordDate ?? this.recordDate,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      medication: medication ?? this.medication,
      dosage: dosage ?? this.dosage,
      notes: notes ?? this.notes,
      photos: photos ?? this.photos,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}