// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cat_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CatModelAdapter extends TypeAdapter<CatModel> {
  @override
  final int typeId = 0;

  @override
  CatModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CatModel(
      id: fields[0] as String,
      name: fields[1] as String,
      birthDate: fields[2] as DateTime?,
      gender: fields[3] as String,
      breed: fields[4] as String,
      weight: fields[5] as double,
      personalityTags: (fields[6] as List).cast<String>(),
      photos: (fields[7] as List).cast<String>(),
      status: fields[8] as String,
      rescueDate: fields[9] as DateTime,
      description: fields[10] as String?,
      medicalRecords: (fields[11] as List).cast<MedicalRecordModel>(),
      createdAt: fields[12] as DateTime,
      updatedAt: fields[13] as DateTime,
      growthPhotos: (fields[14] as List).cast<GrowthPhotoModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, CatModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.birthDate)
      ..writeByte(3)
      ..write(obj.gender)
      ..writeByte(4)
      ..write(obj.breed)
      ..writeByte(5)
      ..write(obj.weight)
      ..writeByte(6)
      ..write(obj.personalityTags)
      ..writeByte(7)
      ..write(obj.photos)
      ..writeByte(8)
      ..write(obj.status)
      ..writeByte(9)
      ..write(obj.rescueDate)
      ..writeByte(10)
      ..write(obj.description)
      ..writeByte(11)
      ..write(obj.medicalRecords)
      ..writeByte(12)
      ..write(obj.createdAt)
      ..writeByte(13)
      ..write(obj.updatedAt)
      ..writeByte(14)
      ..write(obj.growthPhotos);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CatModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
