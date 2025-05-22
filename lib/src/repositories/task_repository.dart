import 'dart:async';

import 'package:hive/hive.dart';
import 'package:task_tamer/src/models/task.dart';
import 'package:uuid/uuid.dart';

class TaskRepository {
  static const String _boxName = 'tasks';
  final Box<Map<dynamic, dynamic>> _box;

  TaskRepository(this._box);

  static Future<TaskRepository> create() async {
    final box = await Hive.openBox<Map<dynamic, dynamic>>(_boxName);
    return TaskRepository(box);
  }

  Future<List<Task>> getAllTasks() async {
    return _box.values.map((json) => Task.fromJson(Map<String, dynamic>.from(json))).toList();
  }

  Future<Task?> getTaskById(String id) async {
    final json = _box.get(id);
    if (json == null) return null;
    return Task.fromJson(Map<String, dynamic>.from(json));
  }

  Future<Task> createTask({
    required String title,
    String? description,
    DateTime? dueDate,
    RepeatFrequency? repeatFrequency,
    int? repeatValue,
    int? timesPerDay,
    List<DateTime>? notificationTimes,
  }) async {
    final task = Task(
      id: const Uuid().v4(),
      title: title,
      description: description,
      creationDate: DateTime.now(),
      dueDate: dueDate,
      repeatFrequency: repeatFrequency,
      repeatValue: repeatValue,
      timesPerDay: timesPerDay,
      notificationTimes: notificationTimes,
    );

    await _box.put(task.id, task.toJson());
    return task;
  }

  Future<Task> updateTask(Task task) async {
    await _box.put(task.id, task.toJson());
    return task;
  }

  Future<void> deleteTask(String id) async {
    await _box.delete(id);
  }

  Future<Task> completeTask(String id) async {
    final task = await getTaskById(id);
    if (task == null) {
      throw Exception('Task not found');
    }

    if (task.timesPerDay != null && task.timesPerDay! > 1) {
      final updatedTask = task.incrementCompletedTimes();
      await _box.put(id, updatedTask.toJson());
      return updatedTask;
    } else {
      final completedTask = task.copyWith(isCompleted: true);
      await _box.put(id, completedTask.toJson());
      return completedTask;
    }
  }

  Future<List<Task>> getDueTasks() async {
    final tasks = await getAllTasks();
    return tasks.where((task) => task.isDue()).toList();
  }

  Future<void> resetCompletedTasksIfNeeded() async {
    final tasks = await getAllTasks();
    final now = DateTime.now();

    for (final task in tasks) {
      if (task.isCompleted && task.repeatFrequency != null && task.repeatValue != null) {
        final shouldReset = _shouldResetTask(task, now);
        if (shouldReset) {
          final resetTask = task.resetCompletedTimes();
          await _box.put(task.id, resetTask.toJson());
        }
      }
    }
  }

  bool _shouldResetTask(Task task, DateTime now) {
    if (!task.isCompleted) return false;
    if (task.repeatFrequency == null || task.repeatValue == null) return false;

    final completionTime = task.dueDate ?? task.creationDate;
    final resetTime = _calculateResetTime(completionTime, task.repeatFrequency!, task.repeatValue!);

    return now.isAfter(resetTime);
  }

  DateTime _calculateResetTime(DateTime baseTime, RepeatFrequency frequency, int value) {
    switch (frequency) {
      case RepeatFrequency.hourly:
        return baseTime.add(Duration(hours: value));
      case RepeatFrequency.daily:
        return baseTime.add(Duration(days: value));
      case RepeatFrequency.weekly:
        return baseTime.add(Duration(days: 7 * value));
      case RepeatFrequency.monthly:
        // Simple implementation - doesn't account for varying month lengths
        return DateTime(
          baseTime.year,
          baseTime.month + value,
          baseTime.day,
          baseTime.hour,
          baseTime.minute,
        );
      case RepeatFrequency.yearly:
        return DateTime(
          baseTime.year + value,
          baseTime.month,
          baseTime.day,
          baseTime.hour,
          baseTime.minute,
        );
      case RepeatFrequency.none:
        return baseTime;
    }
  }
}
