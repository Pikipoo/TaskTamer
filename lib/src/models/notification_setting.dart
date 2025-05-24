import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class NotificationSetting extends Equatable {
  final int value;
  final NotificationTimeUnit timeUnit;
  final bool isBeforeDueDate;

  const NotificationSetting({
    required this.value,
    required this.timeUnit,
    this.isBeforeDueDate = true,
  });

  /// Calculates the notification time based on a due date
  DateTime calculateNotificationTime(DateTime dueDate) {
    switch (timeUnit) {
      case NotificationTimeUnit.hours:
        return isBeforeDueDate
            ? dueDate.subtract(Duration(hours: value))
            : dueDate.add(Duration(hours: value));
      case NotificationTimeUnit.days:
        return isBeforeDueDate
            ? dueDate.subtract(Duration(days: value))
            : dueDate.add(Duration(days: value));
      case NotificationTimeUnit.weeks:
        return isBeforeDueDate
            ? dueDate.subtract(Duration(days: value * 7))
            : dueDate.add(Duration(days: value * 7));
      case NotificationTimeUnit.months:
        // Approximating a month as 30 days
        return isBeforeDueDate
            ? dueDate.subtract(Duration(days: value * 30))
            : dueDate.add(Duration(days: value * 30));
      case NotificationTimeUnit.years:
        // Approximating a year as 365 days
        return isBeforeDueDate
            ? dueDate.subtract(Duration(days: value * 365))
            : dueDate.add(Duration(days: value * 365));
    }
  }

  /// Returns a descriptive string of the notification setting
  String get description {
    final String unitString = timeUnit.toString().split('.').last.toLowerCase();
    final String unitText = value == 1
        ? unitString.substring(0, unitString.length - 1)
        : unitString;
    final String timing = isBeforeDueDate ? 'before' : 'after';

    return '$value $unitText $timing due date/time';
  }

  @override
  List<Object?> get props => [value, timeUnit, isBeforeDueDate];

  Map<String, dynamic> toJson() {
    return {'value': value, 'timeUnit': timeUnit.index, 'isBeforeDueDate': isBeforeDueDate};
  }

  factory NotificationSetting.fromJson(Map<String, dynamic> json) {
    return NotificationSetting(
      value: json['value'],
      timeUnit: NotificationTimeUnit.values[json['timeUnit']],
      isBeforeDueDate: json['isBeforeDueDate'],
    );
  }
}

enum NotificationTimeUnit { hours, days, weeks, months, years }
