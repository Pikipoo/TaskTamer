/// Task model for the TaskTamer application
///
/// This file defines the Task model, which represents a user task with various properties
/// such as title, description, due date, repetition settings, and notification preferences.
/// The Task class is immutable and uses the Equatable package for value equality comparison.
library;

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:task_tamer/src/models/notification_setting.dart';

/// Represents a user task in the TaskTamer application
///
/// A Task is the core entity of the application, representing something the user
/// needs to do. Tasks can be one-time or repeating, and can have notifications
/// associated with them.
///
/// The class is immutable (all fields are final) and provides utility methods
/// for working with tasks, including formatting dates, checking due status,
/// and generating descriptive text.
@immutable
class Task extends Equatable {
  /// Unique identifier for the task
  final String id;

  /// Title/name of the task
  final String title;

  /// Optional detailed description of the task
  final String? description;

  /// When the task was created
  final DateTime creationDate;

  /// When the task is due (optional)
  final DateTime? dueDate;

  /// How often the task repeats (daily, weekly, etc.)
  final RepeatFrequency? repeatFrequency;

  /// Value for repeat frequency (e.g., every 2 days)
  final int? repeatValue;

  /// For tasks that need to be completed multiple times per day
  final int? timesPerDay;

  /// How many times the task has been completed in current cycle
  final int completedTimes;

  /// Specific times when notifications should be sent
  final List<DateTime>? notificationTimes;

  /// Settings for generating notification times relative to due date
  final List<NotificationSetting>? notificationSettings;

  /// Whether the task is completed
  final bool isCompleted;

  /// Creates a new Task instance
  ///
  /// [id] must be unique and is typically generated using UUID
  /// [title] is required and represents the task name
  /// [creationDate] is required and defaults to the current time when not specified
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

  /// Creates a copy of this Task with the given fields replaced with new values
  ///
  /// This is the recommended way to "modify" a Task since the class is immutable.
  ///
  /// Example:
  /// ```dart
  /// final updatedTask = task.copyWith(title: 'New Title', isCompleted: true);
  /// ```
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
  ///
  /// This method uses the [NotificationSetting] objects to calculate absolute
  /// notification times based on the task's due date.
  ///
  /// Returns the current notificationTimes if due date is null or there are no settings.
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

  /// Increments the completed times counter and updates completion status
  ///
  /// If the task has timesPerDay specified, it will be considered completed
  /// only when completedTimes reaches or exceeds timesPerDay.
  ///
  /// Returns a new Task instance with updated values.
  Task incrementCompletedTimes() {
    final newCompletedTimes = completedTimes + 1;
    final newIsCompleted = timesPerDay != null ? newCompletedTimes >= timesPerDay! : true;

    return copyWith(completedTimes: newCompletedTimes, isCompleted: newIsCompleted);
  }

  /// Resets the completion status of the task
  ///
  /// Used for repeating tasks that need to be reset after completion.
  /// Returns a new Task instance with completedTimes set to 0 and isCompleted set to false.
  Task resetCompletedTimes() {
    return copyWith(completedTimes: 0, isCompleted: false);
  }

  /// List of properties used for equality comparison and hash code generation
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

  /// Converts this Task to a JSON map
  ///
  /// Used for serializing the Task to persistent storage.
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

  /// Creates a Task from a JSON map
  ///
  /// Used for deserializing a Task from persistent storage.
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

  /// Returns a formatted string representation of the due date
  ///
  /// Example: "May 15, 2023"
  String getFormattedDueDate() {
    if (dueDate == null) return 'No due date';
    return DateFormat('MMM d, yyyy').format(dueDate!);
  }

  /// Returns a formatted string representation of the due time
  ///
  /// Example: "03:30 PM"
  String getFormattedDueTime() {
    if (dueDate == null) return '';
    return DateFormat('hh:mm a').format(dueDate!);
  }

  /// Checks if the task is currently due
  ///
  /// A task is considered due if it has a due date that is before the current time
  /// and it is not yet completed.
  bool isDue() {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.isBefore(now) && !isCompleted;
  }

  /// Checks if the task is overdue
  ///
  /// A task is considered overdue if it has a due date that is before the current time
  /// and it is not yet completed.
  bool isOverdue() {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.isBefore(now) && !isCompleted;
  }

  /// Returns a human-readable description of the repeat frequency
  ///
  /// Example: "Every 2 days"
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

  /// Returns a description of the times per day completion status
  ///
  /// Example: "2/5 times completed"
  String get timesPerDayDescription {
    if (timesPerDay == null || timesPerDay == 1) {
      return '';
    }
    return '$completedTimes/$timesPerDay times completed';
  }

  /// Returns the completion progress as a value between 0.0 and 1.0
  ///
  /// For tasks with timesPerDay, this is the ratio of completedTimes to timesPerDay.
  /// For regular tasks, this is either 0.0 (not completed) or 1.0 (completed).
  double get completionProgress {
    if (timesPerDay == null || timesPerDay == 0) return isCompleted ? 1.0 : 0.0;
    return completedTimes / timesPerDay!;
  }
}

/// Frequency at which tasks can repeat
///
/// Used to define how often a repeating task should recur.
enum RepeatFrequency {
  /// Task does not repeat
  none,

  /// Task repeats hourly (e.g., every 2 hours)
  hourly,

  /// Task repeats daily (e.g., every day or every 2 days)
  daily,

  /// Task repeats weekly (e.g., every week or every 2 weeks)
  weekly,

  /// Task repeats monthly (e.g., every month or every 3 months)
  monthly,

  /// Task repeats yearly (e.g., every year or every 2 years)
  yearly,
}
