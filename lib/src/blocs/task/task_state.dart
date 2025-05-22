import 'package:equatable/equatable.dart';
import 'package:task_tamer/src/models/task.dart';

abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {
  const TaskInitial();
}

class TaskLoading extends TaskState {
  const TaskLoading();
}

class TasksLoaded extends TaskState {
  final List<Task> tasks;

  const TasksLoaded(this.tasks);

  @override
  List<Object> get props => [tasks];
}

class TaskOperationSuccess extends TaskState {
  final String message;
  final Task? task;

  const TaskOperationSuccess({required this.message, this.task});

  @override
  List<Object?> get props => [message, task];
}

class TaskOperationFailure extends TaskState {
  final String error;

  const TaskOperationFailure(this.error);

  @override
  List<Object> get props => [error];
}
