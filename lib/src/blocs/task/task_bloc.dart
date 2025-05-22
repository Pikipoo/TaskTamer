import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_tamer/src/blocs/task/task_event.dart';
import 'package:task_tamer/src/blocs/task/task_state.dart';
import 'package:task_tamer/src/models/task.dart';
import 'package:task_tamer/src/repositories/task_repository.dart';
import 'package:task_tamer/src/repositories/user_repository.dart';
import 'package:task_tamer/src/services/notification_service.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository _taskRepository;
  final UserRepository _userRepository;
  final NotificationService _notificationService;

  TaskBloc({
    required TaskRepository taskRepository,
    required UserRepository userRepository,
    required NotificationService notificationService,
  })  : _taskRepository = taskRepository,
        _userRepository = userRepository,
        _notificationService = notificationService,
        super(const TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
    on<CompleteTask>(_onCompleteTask);
    on<ResetTaskCompletion>(_onResetTaskCompletion);
    on<CheckTasksForReset>(_onCheckTasksForReset);
  }

  Future<void> _onLoadTasks(
    LoadTasks event,
    Emitter<TaskState> emit,
  ) async {
    emit(const TaskLoading());
    try {
      final tasks = await _taskRepository.getAllTasks();
      emit(TasksLoaded(tasks));
    } catch (e) {
      emit(TaskOperationFailure(e.toString()));
    }
  }

  Future<void> _onAddTask(
    AddTask event,
    Emitter<TaskState> emit,
  ) async {
    emit(const TaskLoading());
    try {
      final task = await _taskRepository.createTask(
        title: event.title,
        description: event.description,
        dueDate: event.dueDate,
        repeatFrequency: event.repeatFrequency,
        repeatValue: event.repeatValue,
        timesPerDay: event.timesPerDay,
        notificationTimes: event.notificationTimes,
      );

      // Schedule notifications if needed
      if (task.notificationTimes != null && task.notificationTimes!.isNotEmpty) {
        await _notificationService.scheduleTaskNotification(task);
      }

      final tasks = await _taskRepository.getAllTasks();
      emit(TasksLoaded(tasks));
    } catch (e) {
      emit(TaskOperationFailure(e.toString()));
    }
  }

  Future<void> _onUpdateTask(
    UpdateTask event,
    Emitter<TaskState> emit,
  ) async {
    emit(const TaskLoading());
    try {
      final task = await _taskRepository.updateTask(event.task);

      // Update notifications
      await _notificationService.updateTaskNotifications(task);

      final tasks = await _taskRepository.getAllTasks();
      emit(TasksLoaded(tasks));
    } catch (e) {
      emit(TaskOperationFailure(e.toString()));
    }
  }

  Future<void> _onDeleteTask(
    DeleteTask event,
    Emitter<TaskState> emit,
  ) async {
    emit(const TaskLoading());
    try {
      // Cancel notifications before deleting
      await _notificationService.cancelTaskNotifications(event.taskId);

      await _taskRepository.deleteTask(event.taskId);
      final tasks = await _taskRepository.getAllTasks();
      emit(TasksLoaded(tasks));
    } catch (e) {
      emit(TaskOperationFailure(e.toString()));
    }
  }

  Future<void> _onCompleteTask(
    CompleteTask event,
    Emitter<TaskState> emit,
  ) async {
    emit(const TaskLoading());
    try {
      final task = await _taskRepository.completeTask(event.taskId);

      // Only award XP if the task is fully completed
      if (task.isCompleted) {
        // Award XP to the user (10 XP per task)
        await _userRepository.addExperiencePoints(10);
      }

      final tasks = await _taskRepository.getAllTasks();
      emit(TasksLoaded(tasks));
    } catch (e) {
      emit(TaskOperationFailure(e.toString()));
    }
  }

  Future<void> _onResetTaskCompletion(
    ResetTaskCompletion event,
    Emitter<TaskState> emit,
  ) async {
    emit(const TaskLoading());
    try {
      final task = await _taskRepository.getTaskById(event.taskId);
      if (task != null) {
        final resetTask = task.resetCompletedTimes();
        await _taskRepository.updateTask(resetTask);
      }

      final tasks = await _taskRepository.getAllTasks();
      emit(TasksLoaded(tasks));
    } catch (e) {
      emit(TaskOperationFailure(e.toString()));
    }
  }

  Future<void> _onCheckTasksForReset(
    CheckTasksForReset event,
    Emitter<TaskState> emit,
  ) async {
    try {
      await _taskRepository.resetCompletedTasksIfNeeded();

      // Only emit new state if the current state is TasksLoaded
      // to avoid interrupting other operations
      if (state is TasksLoaded) {
        final tasks = await _taskRepository.getAllTasks();
        emit(TasksLoaded(tasks));
      }
    } catch (_) {
      // Silently fail, as this is a background operation
    }
  }
}
