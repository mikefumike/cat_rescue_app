// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medical_record_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MedicalRecordModelAdapter extends TypeAdapter<MedicalRecordModel> {
  @override
  final int typeId = 1;

  @override
  MedicalRecordModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MedicalRecordModel(
      id: fields[0] as String,
      catId: fields[1] as String,
      type: fields[2] as String,
      title: fields[3] as String,
      recordDate: fields[4] as DateTime,
      nextDueDate: fields[5] as DateTime?,
      medication: fields[6] as String?,
      dosage: fields[7] as String?,
      notes: fields[8] as String?,
      photos: (fields[9] as List).cast<String>(),
      createdAt: fields[10] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, MedicalRecordModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.catId)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.recordDate)
      ..writeByte(5)
      ..write(obj.nextDueDate)
      ..writeByte(6)
      ..write(obj.medication)
      ..writeByte(7)
      ..write(obj.dosage)
      ..writeByte(8)
      ..write(obj.notes)
      ..writeByte(9)
      ..write(obj.photos)
      ..writeByte(10)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicalRecordModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
