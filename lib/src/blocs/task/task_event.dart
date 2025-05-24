/// Events for the TaskBloc
///
/// This file defines all the events that can be dispatched to the TaskBloc.
/// Each event represents a specific action or intention that triggers state changes.
library;

import 'package:equatable/equatable.dart';
import 'package:task_tamer/src/models/notification_setting.dart';
import 'package:task_tamer/src/models/task.dart';

/// Base class for all task-related events
///
/// All specific task events extend this class to ensure
/// consistent equality comparison.
abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all tasks
///
/// Dispatched when the app needs to fetch all tasks from storage,
/// typically when initializing the task list screen.
class LoadTasks extends TaskEvent {
  const LoadTasks();
}

/// Event to add a new task
///
/// Contains all the information needed to create a new task.
/// Dispatched when a user creates a task through the UI.
class AddTask extends TaskEvent {
  /// The title of the task (required)
  final String title;

  /// Detailed description of the task (optional)
  final String? description;

  /// When the task is due (optional)
  final DateTime? dueDate;

  /// How often the task repeats (optional)
  final RepeatFrequency? repeatFrequency;

  /// Value for repeat frequency, e.g., every 2 days (optional)
  final int? repeatValue;

  /// For tasks that need to be completed multiple times per day (optional)
  final int? timesPerDay;

  /// Specific times when notifications should be sent (optional)
  final List<DateTime>? notificationTimes;

  /// Settings for generating notification times relative to due date (optional)
  final List<NotificationSetting>? notificationSettings;

  const AddTask({
    required this.title,
    this.description,
    this.dueDate,
    this.repeatFrequency,
    this.repeatValue,
    this.timesPerDay,
    this.notificationTimes,
    this.notificationSettings,
  });

  @override
  List<Object?> get props => [
    title,
    description,
    dueDate,
    repeatFrequency,
    repeatValue,
    timesPerDay,
    notificationTimes,
    notificationSettings,
  ];
}

/// Event to update an existing task
///
/// Contains the task object with updated values.
/// Dispatched when a user edits a task through the UI.
class UpdateTask extends TaskEvent {
  /// The task object with updated values
  final Task task;

  const UpdateTask(this.task);

  @override
  List<Object> get props => [task];
}

/// Event to delete a task
///
/// Contains the ID of the task to delete.
/// Dispatched when a user deletes a task through the UI.
class DeleteTask extends TaskEvent {
  /// ID of the task to delete
  final String taskId;

  const DeleteTask(this.taskId);

  @override
  List<Object> get props => [taskId];
}

/// Event to mark a task as completed
///
/// Contains the ID of the task to complete.
/// Dispatched when a user marks a task as done through the UI.
class CompleteTask extends TaskEvent {
  /// ID of the task to complete
  final String taskId;

  const CompleteTask(this.taskId);

  @override
  List<Object> get props => [taskId];
}

/// Event to reset a task's completion status
///
/// Contains the ID of the task to reset.
/// Typically used for repeating tasks or when a user wants to unmark a task.
class ResetTaskCompletion extends TaskEvent {
  /// ID of the task to reset
  final String taskId;

  const ResetTaskCompletion(this.taskId);

  @override
  List<Object> get props => [taskId];
}

/// Event to check all tasks that need to be reset
///
/// Dispatched periodically to reset completed repeating tasks
/// when their repeat schedule dictates they should become active again.
class CheckTasksForReset extends TaskEvent {
  const CheckTasksForReset();
}
