// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 1;

  @override
  Task read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Task(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String?,
      creationDate: fields[3] as DateTime?,
      dueDate: fields[4] as DateTime?,
      repeatUnit: fields[5] as RepeatUnit,
      repeatInterval: fields[6] as int?,
      timesPerDay: fields[7] as int,
      timesCompletedToday: fields[8] as int,
      isCompleted: fields[9] as bool,
      xpReward: fields[10] as int,
      notifications: (fields[11] as List?)?.cast<DateTime>(),
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.creationDate)
      ..writeByte(4)
      ..write(obj.dueDate)
      ..writeByte(5)
      ..write(obj.repeatUnit)
      ..writeByte(6)
      ..write(obj.repeatInterval)
      ..writeByte(7)
      ..write(obj.timesPerDay)
      ..writeByte(8)
      ..write(obj.timesCompletedToday)
      ..writeByte(9)
      ..write(obj.isCompleted)
      ..writeByte(10)
      ..write(obj.xpReward)
      ..writeByte(11)
      ..write(obj.notifications);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RepeatUnitAdapter extends TypeAdapter<RepeatUnit> {
  @override
  final int typeId = 0;

  @override
  RepeatUnit read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RepeatUnit.none;
      case 1:
        return RepeatUnit.hour;
      case 2:
        return RepeatUnit.day;
      case 3:
        return RepeatUnit.week;
      case 4:
        return RepeatUnit.month;
      case 5:
        return RepeatUnit.year;
      default:
        return RepeatUnit.none;
    }
  }

  @override
  void write(BinaryWriter writer, RepeatUnit obj) {
    switch (obj) {
      case RepeatUnit.none:
        writer.writeByte(0);
        break;
      case RepeatUnit.hour:
        writer.writeByte(1);
        break;
      case RepeatUnit.day:
        writer.writeByte(2);
        break;
      case RepeatUnit.week:
        writer.writeByte(3);
        break;
      case RepeatUnit.month:
        writer.writeByte(4);
        break;
      case RepeatUnit.year:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RepeatUnitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
