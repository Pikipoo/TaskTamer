import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:task_tamer/src/models/notification_setting.dart';

@immutable
class Task extends Equatable {
  final String id;
  final String title;
  final String? description;
  final DateTime creationDate;
  final DateTime? dueDate;
  final RepeatFrequency? repeatFrequency;
  final int? repeatValue;
  final int? timesPerDay;
  final int completedTimes;
  final List<DateTime>? notificationTimes;
  final List<NotificationSetting>? notificationSettings;
  final bool isCompleted;

  const Task({
    required this.id,
    required this.title,
    this.description,
    required this.creationDate,
    this.dueDate,
    this.repeatFrequency,
    this.repeatValue,
    this.timesPerDay,
    this.completedTimes = 0,
    this.notificationTimes,
    this.notificationSettings,
    this.isCompleted = false,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? creationDate,
    DateTime? dueDate,
    RepeatFrequency? repeatFrequency,
    int? repeatValue,
    int? timesPerDay,
    int? completedTimes,
    List<DateTime>? notificationTimes,
    List<NotificationSetting>? notificationSettings,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      creationDate: creationDate ?? this.creationDate,
      dueDate: dueDate ?? this.dueDate,
      repeatFrequency: repeatFrequency ?? this.repeatFrequency,
      repeatValue: repeatValue ?? this.repeatValue,
      timesPerDay: timesPerDay ?? this.timesPerDay,
      completedTimes: completedTimes ?? this.completedTimes,
      notificationTimes: notificationTimes ?? this.notificationTimes,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  /// Calculates notification times based on notification settings and due date
  List<DateTime>? calculateNotificationTimes() {
    if (dueDate == null || notificationSettings == null || notificationSettings!.isEmpty) {
      return notificationTimes;
    }

    final List<DateTime> calculatedTimes = [];
    for (final setting in notificationSettings!) {
      calculatedTimes.add(setting.calculateNotificationTime(dueDate!));
    }

    return calculatedTimes;
  }

  Task incrementCompletedTimes() {
    final newCompletedTimes = completedTimes + 1;
    final newIsCompleted = timesPerDay != null ? newCompletedTimes >= timesPerDay! : true;

    return copyWith(completedTimes: newCompletedTimes, isCompleted: newIsCompleted);
  }

  Task resetCompletedTimes() {
    return copyWith(completedTimes: 0, isCompleted: false);
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    creationDate,
    dueDate,
    repeatFrequency,
    repeatValue,
    timesPerDay,
    completedTimes,
    notificationTimes,
    notificationSettings,
    isCompleted,
  ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'creationDate': creationDate.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'repeatFrequency': repeatFrequency?.name,
      'repeatValue': repeatValue,
      'timesPerDay': timesPerDay,
      'completedTimes': completedTimes,
      'notificationTimes': notificationTimes?.map((e) => e.toIso8601String()).toList(),
      'notificationSettings': notificationSettings?.map((e) => e.toJson()).toList(),
      'isCompleted': isCompleted,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      creationDate: DateTime.parse(json['creationDate']),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      repeatFrequency: json['repeatFrequency'] != null
          ? RepeatFrequency.values.firstWhere(
              (e) => e.name == json['repeatFrequency'],
              orElse: () => RepeatFrequency.none,
            )
          : null,
      repeatValue: json['repeatValue'],
      timesPerDay: json['timesPerDay'],
      completedTimes: json['completedTimes'] ?? 0,
      notificationTimes: json['notificationTimes'] != null
          ? (json['notificationTimes'] as List).map((e) => DateTime.parse(e)).toList()
          : null,
      notificationSettings: json['notificationSettings'] != null
          ? (json['notificationSettings'] as List)
                .map((e) => NotificationSetting.fromJson(e))
                .toList()
                .cast<NotificationSetting>()
          : null,
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  String getFormattedDueDate() {
    if (dueDate == null) return 'No due date';
    return DateFormat('MMM d, yyyy').format(dueDate!);
  }

  String getFormattedDueTime() {
    if (dueDate == null) return '';
    return DateFormat('hh:mm a').format(dueDate!);
  }

  bool isDue() {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.isBefore(now) && !isCompleted;
  }

  bool isOverdue() {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.isBefore(now) && !isCompleted;
  }

  String get repeatDescription {
    if (repeatFrequency == null || repeatValue == null) {
      return 'Does not repeat';
    }

    switch (repeatFrequency) {
      case RepeatFrequency.hourly:
        return 'Every $repeatValue hour${repeatValue == 1 ? '' : 's'}';
      case RepeatFrequency.daily:
        return 'Every $repeatValue day${repeatValue == 1 ? '' : 's'}';
      case RepeatFrequency.weekly:
        return 'Every $repeatValue week${repeatValue == 1 ? '' : 's'}';
      case RepeatFrequency.monthly:
        return 'Every $repeatValue month${repeatValue == 1 ? '' : 's'}';
      case RepeatFrequency.yearly:
        return 'Every $repeatValue year${repeatValue == 1 ? '' : 's'}';
      case RepeatFrequency.none:
      default:
        return 'Does not repeat';
    }
  }

  String get timesPerDayDescription {
    if (timesPerDay == null || timesPerDay == 1) {
      return '';
    }
    return '$completedTimes/$timesPerDay times completed';
  }

  double get completionProgress {
    if (timesPerDay == null || timesPerDay == 0) return isCompleted ? 1.0 : 0.0;
    return completedTimes / timesPerDay!;
  }
}

enum RepeatFrequency { none, hourly, daily, weekly, monthly, yearly }
