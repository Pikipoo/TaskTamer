import 'package:hive/hive.dart';
part 'task.g.dart';

@HiveType(typeId: 0)
enum RepeatUnit {
  @HiveField(0)
  none,
  @HiveField(1)
  hour,
  @HiveField(2)
  day,
  @HiveField(3)
  week,
  @HiveField(4)
  month,
  @HiveField(5)
  year,
}

@HiveType(typeId: 1)
class Task extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  String title;
  @HiveField(2)
  String? description;
  @HiveField(3)
  final DateTime creationDate;
  @HiveField(4)
  DateTime? dueDate;
  @HiveField(5)
  RepeatUnit repeatUnit;
  @HiveField(6)
  int? repeatInterval;
  @HiveField(7)
  int timesPerDay;
  @HiveField(8)
  int timesCompletedToday;
  @HiveField(9)
  bool isCompleted;
  @HiveField(10)
  int xpReward;
  @HiveField(11)
  List<DateTime> notifications;

  Task({
    required this.id,
    required this.title,
    this.description,
    DateTime? creationDate,
    this.dueDate,
    this.repeatUnit = RepeatUnit.none,
    this.repeatInterval,
    this.timesPerDay = 1,
    this.timesCompletedToday = 0,
    this.isCompleted = false,
    this.xpReward = 10,
    List<DateTime>? notifications,
  })  : creationDate = creationDate ?? DateTime.now(),
        notifications = notifications ?? [];

  void complete() {
    timesCompletedToday++;
    if (timesCompletedToday >= timesPerDay) {
      isCompleted = true;
    }
  }

  void resetForRepeat() {
    isCompleted = false;
    timesCompletedToday = 0;
  }

  double get progress => timesPerDay > 1 ? timesCompletedToday / timesPerDay : (isCompleted ? 1.0 : 0.0);

  bool shouldRepeat(DateTime now) {
    if (repeatUnit == RepeatUnit.none || repeatInterval == null) return false;
    // Add logic to check if it's time to repeat based on repeatUnit and repeatInterval
    return false;
  }
}
