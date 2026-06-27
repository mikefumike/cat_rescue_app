// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'growth_photo_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GrowthPhotoModelAdapter extends TypeAdapter<GrowthPhotoModel> {
  @override
  final int typeId = 5;

  @override
  GrowthPhotoModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GrowthPhotoModel(
      id: fields[0] as String,
      photoFileName: fields[1] as String,
      dateTaken: fields[2] as DateTime,
      note: fields[3] as String?,
      weight: fields[4] as double?,
      createdAt: fields[5] as DateTime,
      isVideo: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, GrowthPhotoModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.photoFileName)
      ..writeByte(2)
      ..write(obj.dateTaken)
      ..writeByte(3)
      ..write(obj.note)
      ..writeByte(4)
      ..write(obj.weight)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.isVideo);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GrowthPhotoModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
