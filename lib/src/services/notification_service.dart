import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:task_tamer/src/models/task.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Checks if the current platform is supported for notifications
  bool get _isUnsupportedPlatform => kIsWeb || (!kIsWeb && Platform.isLinux);

  Future<void> initialize() async {
    tz_data.initializeTimeZones();

    // Skip notification setup on web or Linux for now
    if (_isUnsupportedPlatform) {
      print('Skipping notification initialization on ${kIsWeb ? 'web' : 'Linux'} platform');
      return;
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );
  }

  void _onDidReceiveNotificationResponse(NotificationResponse response) {
    // Handle notification tap
    if (response.payload != null) {
      // Navigate to task details
    }
  }

  Future<void> scheduleTaskNotification(Task task) async {
    // Skip notification on unsupported platforms
    if (_isUnsupportedPlatform) {
      return;
    }

    // First check if there's a due date
    if (task.dueDate == null) {
      return;
    }

    // Handle calculated notifications from settings
    List<DateTime>? timesToSchedule = task.notificationTimes;

    // If we have notification settings, calculate the times
    if (task.notificationSettings != null && task.notificationSettings!.isNotEmpty) {
      final calculatedTimes = task.calculateNotificationTimes();
      if (calculatedTimes != null && calculatedTimes.isNotEmpty) {
        // Use calculated times or append to existing times
        if (timesToSchedule == null) {
          timesToSchedule = calculatedTimes;
        } else {
          timesToSchedule = [...timesToSchedule, ...calculatedTimes];
        }
      }
    }

    // No notification times available
    if (timesToSchedule == null || timesToSchedule.isEmpty) {
      return;
    }

    for (int i = 0; i < timesToSchedule.length; i++) {
      final scheduledTime = timesToSchedule[i];

      if (scheduledTime.isBefore(DateTime.now())) {
        continue; // Skip past notifications
      }

      final notificationId = int.parse('${task.id.hashCode}$i'.substring(0, 9));

      final notificationDetails = NotificationDetails(
        android: const AndroidNotificationDetails(
          'task_reminders',
          'Task Reminders',
          channelDescription: 'Notifications for task reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      );

      await _notificationsPlugin.zonedSchedule(
        notificationId,
        'Task Reminder: ${task.title}',
        task.description ?? 'It\'s time to complete your task!',
        tz.TZDateTime.from(scheduledTime, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: task.id,
      );
    }
  }

  Future<void> cancelTaskNotifications(String taskId) async {
    // Skip on unsupported platforms
    if (_isUnsupportedPlatform) {
      return;
    }

    // A simple approach is to cancel a range of notification IDs
    // that could be associated with this task
    final baseId = taskId.hashCode;
    final idStr = baseId.toString().substring(0, 9);
    final baseNotificationId = int.parse(idStr);

    for (int i = 0; i < 20; i++) {
      // Increasing to 20 as we may have more notifications now
      await _notificationsPlugin.cancel(baseNotificationId + i);
    }
  }

  Future<void> updateTaskNotifications(Task task) async {
    // Skip on unsupported platforms
    if (_isUnsupportedPlatform) {
      return;
    }

    // First cancel existing notifications
    await cancelTaskNotifications(task.id);
    // Then schedule new ones
    await scheduleTaskNotification(task);
  }

  Future<void> cancelAllNotifications() async {
    // Skip on unsupported platforms
    if (_isUnsupportedPlatform) {
      return;
    }

    await _notificationsPlugin.cancelAll();
  }

  Future<bool> requestPermissions() async {
    if (_isUnsupportedPlatform) {
      return true; // No permissions needed on unsupported platforms
    }

    if (!kIsWeb && Platform.isAndroid) {
      final permissionStatus = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      return permissionStatus ?? false;
    }

    return true;
  }
}
