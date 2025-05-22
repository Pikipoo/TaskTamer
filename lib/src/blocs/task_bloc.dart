import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/task.dart';
import '../repositories/hive_task_repository.dart';

abstract class TaskEvent {}

class LoadTasks extends TaskEvent {}

class AddTask extends TaskEvent {
  final Task task;
  AddTask(this.task);
}

class DeleteTask extends TaskEvent {
  final String id;
  DeleteTask(this.id);
}

abstract class TaskState {}

class TasksInitial extends TaskState {}

class TasksLoaded extends TaskState {
  final List<Task> tasks;
  TasksLoaded(this.tasks);
}

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository repository;
  TaskBloc(this.repository) : super(TasksInitial()) {
    on<LoadTasks>((event, emit) async {
      final tasks = await repository.getTasks();
      emit(TasksLoaded(tasks));
    });
    on<AddTask>((event, emit) async {
      await repository.addTask(event.task);
      final tasks = await repository.getTasks();
      emit(TasksLoaded(tasks));
    });
    on<DeleteTask>((event, emit) async {
      await repository.deleteTask(event.id);
      final tasks = await repository.getTasks();
      emit(TasksLoaded(tasks));
    });
  }
}
