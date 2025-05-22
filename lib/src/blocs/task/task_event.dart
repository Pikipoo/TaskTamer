import 'package:equatable/equatable.dart';
import 'package:task_tamer/src/models/task.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class LoadTasks extends TaskEvent {
  const LoadTasks();
}

class AddTask extends TaskEvent {
  final String title;
  final String? description;
  final DateTime? dueDate;
  final RepeatFrequency? repeatFrequency;
  final int? repeatValue;
  final int? timesPerDay;
  final List<DateTime>? notificationTimes;

  const AddTask({
    required this.title,
    this.description,
    this.dueDate,
    this.repeatFrequency,
    this.repeatValue,
    this.timesPerDay,
    this.notificationTimes,
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
      ];
}

class UpdateTask extends TaskEvent {
  final Task task;

  const UpdateTask(this.task);

  @override
  List<Object> get props => [task];
}

class DeleteTask extends TaskEvent {
  final String taskId;

  const DeleteTask(this.taskId);

  @override
  List<Object> get props => [taskId];
}

class CompleteTask extends TaskEvent {
  final String taskId;

  const CompleteTask(this.taskId);

  @override
  List<Object> get props => [taskId];
}

class ResetTaskCompletion extends TaskEvent {
  final String taskId;

  const ResetTaskCompletion(this.taskId);

  @override
  List<Object> get props => [taskId];
}

class CheckTasksForReset extends TaskEvent {
  const CheckTasksForReset();
}
