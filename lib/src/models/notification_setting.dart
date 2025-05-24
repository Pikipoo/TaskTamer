/// Notification setting model for the TaskTamer application
///
/// This file defines the NotificationSetting model, which represents configuration
/// for when notifications should be sent relative to a task's due date.
/// The model includes functionality to calculate absolute notification times
/// based on a reference due date.
library;

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Represents a notification timing setting
///
/// NotificationSetting defines when a notification should be sent relative
/// to a task's due date. It specifies a time value, unit (hours, days, etc.),
/// and whether the notification should be sent before or after the due date.
///
/// For example, "2 hours before due date" or "1 day after due date".
@immutable
class NotificationSetting extends Equatable {
  /// The numeric value for the time (e.g., 2 for "2 hours")
  final int value;

  /// The time unit (hours, days, weeks, etc.)
  final NotificationTimeUnit timeUnit;

  /// Whether the notification should be sent before (true) or after (false) the due date
  final bool isBeforeDueDate;

  /// Creates a new NotificationSetting instance
  ///
  /// [value] is the numeric time value
  /// [timeUnit] is the unit of time (hours, days, etc.)
  /// [isBeforeDueDate] defaults to true, meaning the notification will be sent before the due date
  const NotificationSetting({
    required this.value,
    required this.timeUnit,
    this.isBeforeDueDate = true,
  });

  /// Calculates the notification time based on a due date
  ///
  /// Given a [dueDate], this method calculates the absolute DateTime when
  /// the notification should be sent based on this setting's value, time unit,
  /// and whether it's before or after the due date.
  ///
  /// Returns a DateTime representing when the notification should be sent.
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
  ///
  /// Example: "2 hours before due date" or "1 day after due date"
  String get description {
    final String unitString = timeUnit.toString().split('.').last.toLowerCase();
    final String unitText = value == 1
        ? unitString.substring(0, unitString.length - 1)
        : unitString;
    final String timing = isBeforeDueDate ? 'before' : 'after';

    return '$value $unitText $timing due date/time';
  }

  /// List of properties used for equality comparison and hash code generation
  @override
  List<Object?> get props => [value, timeUnit, isBeforeDueDate];

  /// Converts this NotificationSetting to a JSON map
  ///
  /// Used for serializing the NotificationSetting to persistent storage.
  Map<String, dynamic> toJson() {
    return {'value': value, 'timeUnit': timeUnit.index, 'isBeforeDueDate': isBeforeDueDate};
  }

  /// Creates a NotificationSetting from a JSON map
  ///
  /// Used for deserializing a NotificationSetting from persistent storage.
  factory NotificationSetting.fromJson(Map<String, dynamic> json) {
    return NotificationSetting(
      value: json['value'],
      timeUnit: NotificationTimeUnit.values[json['timeUnit']],
      isBeforeDueDate: json['isBeforeDueDate'],
    );
  }
}

/// Units of time for notification settings
///
/// Represents the different time units that can be used for scheduling notifications.
enum NotificationTimeUnit {
  /// Hours (e.g., 2 hours before due date)
  hours,

  /// Days (e.g., 1 day before due date)
  days,

  /// Weeks (e.g., 1 week before due date)
  weeks,

  /// Months (e.g., 1 month before due date)
  months,

  /// Years (e.g., 1 year before due date)
  years,
}
