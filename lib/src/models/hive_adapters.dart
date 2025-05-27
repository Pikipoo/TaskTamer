import 'package:hive/hive.dart';
import 'package:task_tamer/src/models/creature.dart';
import 'package:task_tamer/src/models/egg.dart';
import 'package:task_tamer/src/models/notification_setting.dart';
import 'package:task_tamer/src/models/task.dart';
import 'package:task_tamer/src/models/user_profile.dart';

/// Registers all Hive type adapters needed for the application
///
/// This method should be called before opening any Hive boxes to ensure
/// that all custom types can be properly serialized and deserialized.
Future<void> registerHiveAdapters() async {
  // Register enum adapters
  Hive.registerAdapter(RepeatFrequencyAdapter());
  Hive.registerAdapter(NotificationTimeUnitAdapter());
  Hive.registerAdapter(CreatureRarityAdapter());
  Hive.registerAdapter(CreatureTypeAdapter());
  Hive.registerAdapter(CreatureElementAdapter());

  // Register model adapters
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(NotificationSettingAdapter());
  Hive.registerAdapter(CreatureAdapter());
  Hive.registerAdapter(EggAdapter());
  Hive.registerAdapter(UserProfileAdapter());
}

/// Adapter for RepeatFrequency enum
class RepeatFrequencyAdapter extends TypeAdapter<RepeatFrequency> {
  @override
  final int typeId = 30;

  @override
  RepeatFrequency read(BinaryReader reader) {
    return RepeatFrequency.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, RepeatFrequency obj) {
    writer.writeByte(obj.index);
  }
}

/// Adapter for NotificationTimeUnit enum
class NotificationTimeUnitAdapter extends TypeAdapter<NotificationTimeUnit> {
  @override
  final int typeId = 31;

  @override
  NotificationTimeUnit read(BinaryReader reader) {
    return NotificationTimeUnit.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, NotificationTimeUnit obj) {
    writer.writeByte(obj.index);
  }
}

/// Adapter for Task model
class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 32;

  @override
  Task read(BinaryReader reader) {
    final map = reader.readMap();
    return Task.fromJson(Map<String, dynamic>.from(map));
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer.writeMap(obj.toJson());
  }
}

/// Adapter for NotificationSetting model
class NotificationSettingAdapter extends TypeAdapter<NotificationSetting> {
  @override
  final int typeId = 33;

  @override
  NotificationSetting read(BinaryReader reader) {
    final map = reader.readMap();
    return NotificationSetting.fromJson(Map<String, dynamic>.from(map));
  }

  @override
  void write(BinaryWriter writer, NotificationSetting obj) {
    writer.writeMap(obj.toJson());
  }
}

/// Adapter for Creature model
class CreatureAdapter extends TypeAdapter<Creature> {
  @override
  final int typeId = 34;

  @override
  Creature read(BinaryReader reader) {
    final map = reader.readMap();
    return Creature.fromJson(Map<String, dynamic>.from(map));
  }

  @override
  void write(BinaryWriter writer, Creature obj) {
    writer.writeMap(obj.toJson());
  }
}

/// Adapter for UserProfile model
class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 35;

  @override
  UserProfile read(BinaryReader reader) {
    final map = reader.readMap();
    return UserProfile.fromJson(Map<String, dynamic>.from(map));
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer.writeMap(obj.toJson());
  }
}

/// Adapter for Egg model
class EggAdapter extends TypeAdapter<Egg> {
  @override
  final int typeId = 36;

  @override
  Egg read(BinaryReader reader) {
    final map = reader.readMap();
    return Egg.fromJson(Map<String, dynamic>.from(map));
  }

  @override
  void write(BinaryWriter writer, Egg obj) {
    writer.writeMap(obj.toJson());
  }
}

/// Adapter for CreatureRarity enum
class CreatureRarityAdapter extends TypeAdapter<CreatureRarity> {
  @override
  final int typeId = 37;

  @override
  CreatureRarity read(BinaryReader reader) {
    return CreatureRarity.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, CreatureRarity obj) {
    writer.writeByte(obj.index);
  }
}

/// Adapter for CreatureType enum
class CreatureTypeAdapter extends TypeAdapter<CreatureType> {
  @override
  final int typeId = 38;

  @override
  CreatureType read(BinaryReader reader) {
    return CreatureType.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, CreatureType obj) {
    writer.writeByte(obj.index);
  }
}

/// Adapter for CreatureElement enum
class CreatureElementAdapter extends TypeAdapter<CreatureElement> {
  @override
  final int typeId = 39;

  @override
  CreatureElement read(BinaryReader reader) {
    return CreatureElement.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, CreatureElement obj) {
    writer.writeByte(obj.index);
  }
}
