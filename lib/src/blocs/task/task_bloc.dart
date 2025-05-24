/// Business Logic Component (BLoC) for task management
///
/// This BLoC handles all task-related operations and state management in the TaskTamer app.
/// It processes events from the UI, interacts with the repositories and services,
/// and emits state updates back to the UI.
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_tamer/src/blocs/task/task_event.dart';
import 'package:task_tamer/src/blocs/task/task_state.dart';
import 'package:task_tamer/src/repositories/task_repository.dart';
import 'package:task_tamer/src/repositories/user_repository.dart';
import 'package:task_tamer/src/services/notification_service.dart';

/// BLoC responsible for managing task state and operations
///
/// The TaskBloc:
/// - Handles CRUD operations for tasks
/// - Manages task completion and reset logic
/// - Schedules notifications for tasks
/// - Awards experience points to the user upon task completion
/// - Maintains the current state of tasks in the application
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  /// Repository for task data operations
  final TaskRepository _taskRepository;

  /// Repository for user data operations (used for awarding XP)
  final UserRepository _userRepository;

  /// Service for scheduling and managing task notifications
  final NotificationService _notificationService;

  /// Creates a new TaskBloc with required dependencies
  ///
  /// Requires:
  /// - [taskRepository] for task data operations
  /// - [userRepository] for user data operations (XP awards)
  /// - [notificationService] for task notifications
  TaskBloc({
    required TaskRepository taskRepository,
    required UserRepository userRepository,
    required NotificationService notificationService,
  }) : _taskRepository = taskRepository,
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

  /// Handles the LoadTasks event
  ///
  /// Loads all tasks from the repository and emits a TasksLoaded state
  /// with the loaded tasks.
  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    emit(const TaskLoading());
    try {
      final tasks = await _taskRepository.getAllTasks();
      emit(TasksLoaded(tasks));
    } catch (e) {
      emit(TaskOperationFailure(e.toString()));
    }
  }

  /// Handles the AddTask event
  ///
  /// Creates a new task with the provided details and schedules notifications
  /// if needed.
  Future<void> _onAddTask(AddTask event, Emitter<TaskState> emit) async {
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
        notificationSettings: event.notificationSettings,
      );

      // Schedule notifications if needed
      if ((task.notificationTimes != null && task.notificationTimes!.isNotEmpty) ||
          (task.notificationSettings != null && task.notificationSettings!.isNotEmpty)) {
        await _notificationService.scheduleTaskNotification(task);
      }

      final tasks = await _taskRepository.getAllTasks();
      emit(TasksLoaded(tasks));
    } catch (e) {
      emit(TaskOperationFailure(e.toString()));
    }
  }

  /// Handles the UpdateTask event
  ///
  /// Updates an existing task and its associated notifications.
  Future<void> _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
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

  /// Handles the DeleteTask event
  ///
  /// Deletes a task and cancels any associated notifications.
  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
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

  /// Handles the CompleteTask event
  ///
  /// Marks a task as completed or increments its completion count.
  /// If the task is fully completed, awards XP to the user.
  Future<void> _onCompleteTask(CompleteTask event, Emitter<TaskState> emit) async {
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

  /// Handles the ResetTaskCompletion event
  ///
  /// Resets a task's completion status to uncompleted.
  Future<void> _onResetTaskCompletion(ResetTaskCompletion event, Emitter<TaskState> emit) async {
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

  /// Handles the CheckTasksForReset event
  ///
  /// Checks for repeating tasks that need to be reset and resets them.
  /// This is typically called when the app starts up or returns to the foreground.
  Future<void> _onCheckTasksForReset(CheckTasksForReset event, Emitter<TaskState> emit) async {
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
