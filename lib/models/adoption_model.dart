import 'package:hive/hive.dart';

part 'adoption_model.g.dart';

@HiveType(typeId: 4)
class AdoptionModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String catId;

  @HiveField(2)
  final String applicantName;

  @HiveField(3)
  final String contact;

  @HiveField(4)
  final String livingCondition;

  @HiveField(5)
  final bool hasPetExperience;

  @HiveField(6)
  final String? experienceDescription;

  @HiveField(7)
  final bool hasSealedWindow;

  @HiveField(8)
  final bool acceptedVisit;

  @HiveField(9)
  final DateTime applyDate;

  @HiveField(10)
  final String status; // 待审核 / 初审通过 / 需家访 / 审核通过 / 已驳回 / 已领养

  @HiveField(11)
  final String? reviewNotes;

  @HiveField(12)
  final DateTime? adoptionDate;

  @HiveField(13)
  final List<String> photos; // 领养后照片

  @HiveField(14)
  final List<String> visitRecords; // 回访记录

  @HiveField(15)
  final DateTime createdAt;

  @HiveField(16)
  final DateTime updatedAt;

  AdoptionModel({
    required this.id,
    required this.catId,
    required this.applicantName,
    required this.contact,
    required this.livingCondition,
    required this.hasPetExperience,
    this.experienceDescription,
    required this.hasSealedWindow,
    required this.acceptedVisit,
    required this.applyDate,
    required this.status,
    this.reviewNotes,
    this.adoptionDate,
    this.photos = const [],
    this.visitRecords = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  AdoptionModel copyWith({
    String? id,
    String? catId,
    String? applicantName,
    String? contact,
    String? livingCondition,
    bool? hasPetExperience,
    String? experienceDescription,
    bool? hasSealedWindow,
    bool? acceptedVisit,
    DateTime? applyDate,
    String? status,
    String? reviewNotes,
    DateTime? adoptionDate,
    List<String>? photos,
    List<String>? visitRecords,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AdoptionModel(
      id: id ?? this.id,
      catId: catId ?? this.catId,
      applicantName: applicantName ?? this.applicantName,
      contact: contact ?? this.contact,
      livingCondition: livingCondition ?? this.livingCondition,
      hasPetExperience: hasPetExperience ?? this.hasPetExperience,
      experienceDescription: experienceDescription ?? this.experienceDescription,
      hasSealedWindow: hasSealedWindow ?? this.hasSealedWindow,
      acceptedVisit: acceptedVisit ?? this.acceptedVisit,
      applyDate: applyDate ?? this.applyDate,
      status: status ?? this.status,
      reviewNotes: reviewNotes ?? this.reviewNotes,
      adoptionDate: adoptionDate ?? this.adoptionDate,
      photos: photos ?? this.photos,
      visitRecords: visitRecords ?? this.visitRecords,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
