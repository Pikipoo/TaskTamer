import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:task_tamer/src/models/task.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz_data.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
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

  Future<void> _onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) async {
    // Handle iOS notification when app is in foreground
  }

  void _onDidReceiveNotificationResponse(NotificationResponse response) {
    // Handle notification tap
    if (response.payload != null) {
      // Navigate to task details
    }
  }

  Future<void> scheduleTaskNotification(Task task) async {
    if (task.notificationTimes == null || task.notificationTimes!.isEmpty) {
      return;
    }

    for (int i = 0; i < task.notificationTimes!.length; i++) {
      final scheduledTime = task.notificationTimes![i];

      if (scheduledTime.isBefore(DateTime.now())) {
        continue; // Skip past notifications
      }

      final notificationId = int.parse('${task.id.hashCode}$i'.substring(0, 9));

      await _notificationsPlugin.zonedSchedule(
        notificationId,
        'Task Reminder: ${task.title}',
        task.description ?? 'It\'s time to complete your task!',
        tz.TZDateTime.from(scheduledTime, tz.local),
        NotificationDetails(
          android: const AndroidNotificationDetails(
            'task_reminders',
            'Task Reminders',
            channelDescription: 'Notifications for task reminders',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: task.id,
      );
    }
  }

  Future<void> cancelTaskNotifications(String taskId) async {
    // A simple approach is to cancel a range of notification IDs
    // that could be associated with this task
    final baseId = taskId.hashCode;
    final idStr = baseId.toString().substring(0, 9);
    final baseNotificationId = int.parse(idStr);

    for (int i = 0; i < 10; i++) { // Assuming max 10 notifications per task
      await _notificationsPlugin.cancel(baseNotificationId + i);
    }
  }

  Future<void> updateTaskNotifications(Task task) async {
    // First cancel existing notifications
    await cancelTaskNotifications(task.id);
    // Then schedule new ones
    await scheduleTaskNotification(task);
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  Future<bool> requestPermissions() async {
    final permissionStatus = await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    return permissionStatus ?? false;
  }
}
