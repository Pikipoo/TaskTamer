/// States for the TaskBloc
///
/// This file defines all possible states that the TaskBloc can be in.
/// Each state represents a specific condition of the task-related UI
/// and the data that should be displayed.
library;

import 'package:equatable/equatable.dart';
import 'package:task_tamer/src/models/task.dart';

/// Base class for all task-related states
///
/// All specific task states extend this class to ensure
/// consistent equality comparison.
abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

/// Initial state when the bloc is created
///
/// This state is used before any tasks are loaded, typically
/// for a brief period during app initialization.
class TaskInitial extends TaskState {
  const TaskInitial();
}

/// State when tasks are being loaded or operations are in progress
///
/// This state is used to show loading indicators in the UI
/// when async operations are being performed.
class TaskLoading extends TaskState {
  const TaskLoading();
}

/// State when tasks have been successfully loaded
///
/// Contains the list of tasks to be displayed in the UI.
/// This is the primary state for displaying task data.
class TasksLoaded extends TaskState {
  /// The list of loaded tasks
  final List<Task> tasks;

  const TasksLoaded(this.tasks);

  @override
  List<Object> get props => [tasks];
}

/// State when a task operation has completed successfully
///
/// Contains a success message and optionally the affected task.
/// Used for displaying success notifications to the user.
class TaskOperationSuccess extends TaskState {
  /// Success message to display to the user
  final String message;

  /// The task that was affected by the operation (optional)
  final Task? task;

  const TaskOperationSuccess({required this.message, this.task});

  @override
  List<Object?> get props => [message, task];
}

/// State when a task operation has failed
///
/// Contains an error message describing what went wrong.
/// Used for displaying error notifications to the user.
class TaskOperationFailure extends TaskState {
  /// Error message to display to the user
  final String error;

  const TaskOperationFailure(this.error);

  @override
  List<Object> get props => [error];
}
