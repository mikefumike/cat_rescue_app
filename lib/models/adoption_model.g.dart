// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adoption_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AdoptionModelAdapter extends TypeAdapter<AdoptionModel> {
  @override
  final int typeId = 4;

  @override
  AdoptionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AdoptionModel(
      id: fields[0] as String,
      catId: fields[1] as String,
      applicantName: fields[2] as String,
      contact: fields[3] as String,
      livingCondition: fields[4] as String,
      hasPetExperience: fields[5] as bool,
      experienceDescription: fields[6] as String?,
      hasSealedWindow: fields[7] as bool,
      acceptedVisit: fields[8] as bool,
      applyDate: fields[9] as DateTime,
      status: fields[10] as String,
      reviewNotes: fields[11] as String?,
      adoptionDate: fields[12] as DateTime?,
      photos: (fields[13] as List).cast<String>(),
      visitRecords: (fields[14] as List).cast<String>(),
      createdAt: fields[15] as DateTime,
      updatedAt: fields[16] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, AdoptionModel obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.catId)
      ..writeByte(2)
      ..write(obj.applicantName)
      ..writeByte(3)
      ..write(obj.contact)
      ..writeByte(4)
      ..write(obj.livingCondition)
      ..writeByte(5)
      ..write(obj.hasPetExperience)
      ..writeByte(6)
      ..write(obj.experienceDescription)
      ..writeByte(7)
      ..write(obj.hasSealedWindow)
      ..writeByte(8)
      ..write(obj.acceptedVisit)
      ..writeByte(9)
      ..write(obj.applyDate)
      ..writeByte(10)
      ..write(obj.status)
      ..writeByte(11)
      ..write(obj.reviewNotes)
      ..writeByte(12)
      ..write(obj.adoptionDate)
      ..writeByte(13)
      ..write(obj.photos)
      ..writeByte(14)
      ..write(obj.visitRecords)
      ..writeByte(15)
      ..write(obj.createdAt)
      ..writeByte(16)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdoptionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
