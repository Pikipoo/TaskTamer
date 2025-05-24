/// Repository for managing tasks in the TaskTamer application
///
/// This repository provides methods for creating, reading, updating, and deleting
/// tasks in the application. It uses Hive for local storage of task data.
///
/// The repository acts as an abstraction layer between the data source (Hive)
/// and the rest of the application, providing a clean API for task operations.
library;

import 'dart:async';

import 'package:hive/hive.dart';
import 'package:task_tamer/src/models/notification_setting.dart';
import 'package:task_tamer/src/models/task.dart';
import 'package:uuid/uuid.dart';

/// Repository responsible for task data operations
///
/// The TaskRepository handles all CRUD operations for tasks, including:
/// - Creating new tasks
/// - Retrieving tasks (all or by ID)
/// - Updating existing tasks
/// - Deleting tasks
/// - Managing task completion states
/// - Handling repeating task reset logic
class TaskRepository {
  /// Name of the Hive box used to store tasks
  static const String _boxName = 'tasks';

  /// Reference to the Hive box for task storage
  final Box<dynamic> _box;

  /// Private constructor requiring a Hive box
  TaskRepository(this._box);

  /// Factory method to create and initialize a TaskRepository
  ///
  /// Opens a Hive box for task storage and returns a new TaskRepository instance.
  /// This is the recommended way to create a TaskRepository.
  ///
  /// Example:
  /// ```dart
  /// final taskRepository = await TaskRepository.create();
  /// ```
  static Future<TaskRepository> create() async {
    final box = await Hive.openBox(_boxName);
    print('Got object store box in database $_boxName.');
    return TaskRepository(box);
  }

  /// Retrieves all tasks from storage
  ///
  /// Returns a list of all Task objects stored in the repository.
  /// If no tasks exist, returns an empty list.
  Future<List<Task>> getAllTasks() async {
    // For consistent mapping, we convert all stored items to Task objects
    final tasks = <Task>[];

    for (var key in _box.keys) {
      final dynamic value = _box.get(key);
      if (value is Map) {
        tasks.add(Task.fromJson(Map<String, dynamic>.from(value)));
      } else if (value is Task) {
        tasks.add(value);
      }
    }

    return tasks;
  }

  /// Retrieves a specific task by its ID
  ///
  /// [id] is the unique identifier of the task
  ///
  /// Returns the Task object if found, or null if no task exists with the given ID.
  Future<Task?> getTaskById(String id) async {
    final value = _box.get(id);
    if (value == null) return null;

    if (value is Map) {
      return Task.fromJson(Map<String, dynamic>.from(value));
    } else if (value is Task) {
      return value;
    }

    return null;
  }

  /// Creates a new task with the given properties
  ///
  /// Required parameters:
  /// - [title]: The title of the task
  ///
  /// Optional parameters:
  /// - [description]: A detailed description of the task
  /// - [dueDate]: When the task is due
  /// - [repeatFrequency]: How often the task repeats (daily, weekly, etc.)
  /// - [repeatValue]: Value for repeat frequency (e.g., every 2 days)
  /// - [timesPerDay]: For tasks that need to be completed multiple times per day
  /// - [notificationTimes]: Specific times when notifications should be sent
  /// - [notificationSettings]: Settings for generating notification times
  ///
  /// Returns the newly created Task object.
  Future<Task> createTask({
    required String title,
    String? description,
    DateTime? dueDate,
    RepeatFrequency? repeatFrequency,
    int? repeatValue,
    int? timesPerDay,
    List<DateTime>? notificationTimes,
    List<NotificationSetting>? notificationSettings,
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
      notificationSettings: notificationSettings,
    );

    await _box.put(task.id, task);
    return task;
  }

  /// Updates an existing task
  ///
  /// [task] is the Task object with updated values.
  /// The task ID is used to identify which task to update.
  ///
  /// Returns the updated Task object.
  Future<Task> updateTask(Task task) async {
    await _box.put(task.id, task);
    return task;
  }

  /// Deletes a task by its ID
  ///
  /// [id] is the unique identifier of the task to delete.
  Future<void> deleteTask(String id) async {
    await _box.delete(id);
  }

  /// Marks a task as completed or increments its completion count
  ///
  /// [id] is the unique identifier of the task to complete.
  ///
  /// For tasks with timesPerDay:
  /// - Increments the completedTimes counter
  /// - Marks as completed only when completedTimes reaches or exceeds timesPerDay
  ///
  /// For regular tasks:
  /// - Simply marks the task as completed
  ///
  /// Returns the updated Task object.
  /// Throws an exception if the task is not found.
  Future<Task> completeTask(String id) async {
    final task = await getTaskById(id);
    if (task == null) {
      throw Exception('Task not found');
    }

    if (task.timesPerDay != null && task.timesPerDay! > 1) {
      final updatedTask = task.incrementCompletedTimes();
      await _box.put(id, updatedTask);
      return updatedTask;
    } else {
      final completedTask = task.copyWith(isCompleted: true);
      await _box.put(id, completedTask);
      return completedTask;
    }
  }

  /// Retrieves all tasks that are currently due
  ///
  /// A task is considered due if its due date is in the past and it is not completed.
  /// Returns a list of due Task objects.
  Future<List<Task>> getDueTasks() async {
    final tasks = await getAllTasks();
    return tasks.where((task) => task.isDue()).toList();
  }

  /// Resets completion status for repeating tasks if their reset time has passed
  ///
  /// This method should be called periodically (e.g., at app startup)
  /// to reset any completed repeating tasks that are due to repeat.
  Future<void> resetCompletedTasksIfNeeded() async {
    final tasks = await getAllTasks();
    final now = DateTime.now();

    for (final task in tasks) {
      if (task.isCompleted && task.repeatFrequency != null && task.repeatValue != null) {
        final shouldReset = _shouldResetTask(task, now);
        if (shouldReset) {
          final resetTask = task.resetCompletedTimes();
          await _box.put(task.id, resetTask);
        }
      }
    }
  }

  /// Determines if a completed task should be reset based on its repeat settings
  ///
  /// [task] is the task to check
  /// [now] is the current datetime to compare against
  ///
  /// Returns true if the task should be reset, false otherwise.
  bool _shouldResetTask(Task task, DateTime now) {
    if (!task.isCompleted) return false;
    if (task.repeatFrequency == null || task.repeatValue == null) return false;

    final completionTime = task.dueDate ?? task.creationDate;
    final resetTime = _calculateResetTime(completionTime, task.repeatFrequency!, task.repeatValue!);

    return now.isAfter(resetTime);
  }

  /// Calculates the next reset time for a repeating task
  ///
  /// [baseTime] is the starting point (typically the last completion time)
  /// [frequency] is how often the task repeats (hourly, daily, etc.)
  /// [value] is the repeat value (e.g., every 2 days)
  ///
  /// Returns a DateTime representing when the task should reset.
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
