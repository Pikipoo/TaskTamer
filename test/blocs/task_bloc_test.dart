import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:task_tamer/src/blocs/task/task_bloc.dart';
import 'package:task_tamer/src/blocs/task/task_event.dart';
import 'package:task_tamer/src/blocs/task/task_state.dart';
import 'package:task_tamer/src/models/task.dart';
import 'package:task_tamer/src/models/user_profile.dart';
import 'package:task_tamer/src/repositories/task_repository.dart';
import 'package:task_tamer/src/repositories/user_repository.dart';
import 'package:task_tamer/src/services/notification_service.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

class MockUserRepository extends Mock implements UserRepository {}

class MockNotificationService extends Mock implements NotificationService {}

// Define fake classes for Mocktail fallback values
class FakeTask extends Fake implements Task {}

void main() {
  late MockTaskRepository taskRepository;
  late MockUserRepository userRepository;
  late MockNotificationService notificationService;
  late TaskBloc taskBloc;

  // Register fallback values for Mocktail
  setUpAll(() {
    registerFallbackValue(FakeTask());
  });

  final testDate = DateTime(2023, 6, 15, 10, 0);

  final testTask = Task(
    id: '1',
    title: 'Test Task',
    description: 'This is a test task',
    creationDate: testDate,
  );

  final updatedTask = testTask.copyWith(title: 'Updated Test Task');

  final completedTask = testTask.copyWith(completedTimes: 1, isCompleted: true);

  setUp(() {
    taskRepository = MockTaskRepository();
    userRepository = MockUserRepository();
    notificationService = MockNotificationService();
    taskBloc = TaskBloc(
      taskRepository: taskRepository,
      userRepository: userRepository,
      notificationService: notificationService,
    );
  });

  tearDown(() {
    taskBloc.close();
  });

  test('initial state should be TaskInitial', () {
    expect(taskBloc.state, const TaskInitial());
  });

  group('LoadTasks', () {
    blocTest<TaskBloc, TaskState>(
      'emits [TaskLoading, TasksLoaded] when LoadTasks is successful',
      build: () {
        when(() => taskRepository.getAllTasks()).thenAnswer((_) async => [testTask]);
        return taskBloc;
      },
      act: (bloc) => bloc.add(const LoadTasks()),
      expect: () => [
        const TaskLoading(),
        TasksLoaded([testTask]),
      ],
      verify: (_) {
        verify(() => taskRepository.getAllTasks()).called(1);
      },
    );

    blocTest<TaskBloc, TaskState>(
      'emits [TaskLoading, TaskOperationFailure] when LoadTasks fails',
      build: () {
        when(() => taskRepository.getAllTasks()).thenThrow(Exception('Failed to load tasks'));
        return taskBloc;
      },
      act: (bloc) => bloc.add(const LoadTasks()),
      expect: () => [
        const TaskLoading(),
        const TaskOperationFailure('Exception: Failed to load tasks'),
      ],
    );
  });

  group('AddTask', () {
    final taskToAdd = AddTask(
      title: 'New Task',
      description: 'New task description',
      dueDate: testDate.add(const Duration(days: 1)),
      repeatFrequency: RepeatFrequency.daily,
      repeatValue: 1,
      timesPerDay: 2,
      notificationTimes: [testDate.add(const Duration(hours: 2))],
    );

    final createdTask = Task(
      id: '2',
      title: 'New Task',
      description: 'New task description',
      creationDate: testDate,
      dueDate: testDate.add(const Duration(days: 1)),
      repeatFrequency: RepeatFrequency.daily,
      repeatValue: 1,
      timesPerDay: 2,
      notificationTimes: [testDate.add(const Duration(hours: 2))],
    );

    blocTest<TaskBloc, TaskState>(
      'emits [TaskLoading, TasksLoaded] when AddTask is successful',
      build: () {
        when(
          () => taskRepository.createTask(
            title: taskToAdd.title,
            description: taskToAdd.description,
            dueDate: taskToAdd.dueDate,
            repeatFrequency: taskToAdd.repeatFrequency,
            repeatValue: taskToAdd.repeatValue,
            timesPerDay: taskToAdd.timesPerDay,
            notificationTimes: taskToAdd.notificationTimes,
          ),
        ).thenAnswer((_) async => createdTask);
        when(
          () => notificationService.scheduleTaskNotification(createdTask),
        ).thenAnswer((_) async {});
        when(() => taskRepository.getAllTasks()).thenAnswer((_) async => [testTask, createdTask]);
        return taskBloc;
      },
      act: (bloc) => bloc.add(taskToAdd),
      expect: () => [
        const TaskLoading(),
        TasksLoaded([testTask, createdTask]),
      ],
      verify: (_) {
        verify(
          () => taskRepository.createTask(
            title: taskToAdd.title,
            description: taskToAdd.description,
            dueDate: taskToAdd.dueDate,
            repeatFrequency: taskToAdd.repeatFrequency,
            repeatValue: taskToAdd.repeatValue,
            timesPerDay: taskToAdd.timesPerDay,
            notificationTimes: taskToAdd.notificationTimes,
          ),
        ).called(1);
        verify(() => notificationService.scheduleTaskNotification(createdTask)).called(1);
        verify(() => taskRepository.getAllTasks()).called(1);
      },
    );

    blocTest<TaskBloc, TaskState>(
      'emits [TaskLoading, TaskOperationFailure] when AddTask fails',
      build: () {
        when(
          () => taskRepository.createTask(
            title: taskToAdd.title,
            description: taskToAdd.description,
            dueDate: taskToAdd.dueDate,
            repeatFrequency: taskToAdd.repeatFrequency,
            repeatValue: taskToAdd.repeatValue,
            timesPerDay: taskToAdd.timesPerDay,
            notificationTimes: taskToAdd.notificationTimes,
          ),
        ).thenThrow(Exception('Failed to create task'));
        return taskBloc;
      },
      act: (bloc) => bloc.add(taskToAdd),
      expect: () => [
        const TaskLoading(),
        const TaskOperationFailure('Exception: Failed to create task'),
      ],
    );
  });

  group('UpdateTask', () {
    blocTest<TaskBloc, TaskState>(
      'emits [TaskLoading, TasksLoaded] when UpdateTask is successful',
      build: () {
        when(() => taskRepository.updateTask(updatedTask)).thenAnswer((_) async => updatedTask);
        when(
          () => notificationService.updateTaskNotifications(updatedTask),
        ).thenAnswer((_) async {});
        when(() => taskRepository.getAllTasks()).thenAnswer((_) async => [updatedTask]);
        return taskBloc;
      },
      act: (bloc) => bloc.add(UpdateTask(updatedTask)),
      expect: () => [
        const TaskLoading(),
        TasksLoaded([updatedTask]),
      ],
      verify: (_) {
        verify(() => taskRepository.updateTask(updatedTask)).called(1);
        verify(() => notificationService.updateTaskNotifications(updatedTask)).called(1);
        verify(() => taskRepository.getAllTasks()).called(1);
      },
    );

    blocTest<TaskBloc, TaskState>(
      'emits [TaskLoading, TaskOperationFailure] when UpdateTask fails',
      build: () {
        when(
          () => taskRepository.updateTask(updatedTask),
        ).thenThrow(Exception('Failed to update task'));
        return taskBloc;
      },
      act: (bloc) => bloc.add(UpdateTask(updatedTask)),
      expect: () => [
        const TaskLoading(),
        const TaskOperationFailure('Exception: Failed to update task'),
      ],
    );
  });

  group('DeleteTask', () {
    blocTest<TaskBloc, TaskState>(
      'emits [TaskLoading, TasksLoaded] when DeleteTask is successful',
      build: () {
        when(() => notificationService.cancelTaskNotifications('1')).thenAnswer((_) async {});
        when(() => taskRepository.deleteTask('1')).thenAnswer((_) async {});
        when(() => taskRepository.getAllTasks()).thenAnswer((_) async => []);
        return taskBloc;
      },
      act: (bloc) => bloc.add(const DeleteTask('1')),
      expect: () => [const TaskLoading(), const TasksLoaded([])],
      verify: (_) {
        verify(() => notificationService.cancelTaskNotifications('1')).called(1);
        verify(() => taskRepository.deleteTask('1')).called(1);
        verify(() => taskRepository.getAllTasks()).called(1);
      },
    );

    blocTest<TaskBloc, TaskState>(
      'emits [TaskLoading, TaskOperationFailure] when DeleteTask fails',
      build: () {
        when(() => notificationService.cancelTaskNotifications('1')).thenAnswer((_) async {});
        when(() => taskRepository.deleteTask('1')).thenThrow(Exception('Failed to delete task'));
        return taskBloc;
      },
      act: (bloc) => bloc.add(const DeleteTask('1')),
      expect: () => [
        const TaskLoading(),
        const TaskOperationFailure('Exception: Failed to delete task'),
      ],
    );
  });

  group('CompleteTask', () {
    blocTest<TaskBloc, TaskState>(
      'emits [TaskLoading, TasksLoaded] when CompleteTask is successful',
      build: () {
        when(() => taskRepository.completeTask('1')).thenAnswer((_) async => completedTask);
        when(() => userRepository.addExperiencePoints(10)).thenAnswer(
          (_) async =>
              const UserProfile(id: 'user1', name: 'Test User', experiencePoints: 10, level: 1),
        );
        when(() => taskRepository.getAllTasks()).thenAnswer((_) async => [completedTask]);
        return taskBloc;
      },
      act: (bloc) => bloc.add(const CompleteTask('1')),
      expect: () => [
        const TaskLoading(),
        TasksLoaded([completedTask]),
      ],
      verify: (_) {
        verify(() => taskRepository.completeTask('1')).called(1);
        verify(() => userRepository.addExperiencePoints(10)).called(1);
        verify(() => taskRepository.getAllTasks()).called(1);
      },
    );

    blocTest<TaskBloc, TaskState>(
      'does not award XP if task is not fully completed',
      build: () {
        final partialCompletedTask = testTask.copyWith(completedTimes: 1, isCompleted: false);

        when(() => taskRepository.completeTask('1')).thenAnswer((_) async => partialCompletedTask);
        when(() => taskRepository.getAllTasks()).thenAnswer((_) async => [partialCompletedTask]);
        return taskBloc;
      },
      act: (bloc) => bloc.add(const CompleteTask('1')),
      expect: () => [const TaskLoading(), isA<TasksLoaded>()],
      verify: (_) {
        verify(() => taskRepository.completeTask('1')).called(1);
        verifyNever(() => userRepository.addExperiencePoints(any()));
        verify(() => taskRepository.getAllTasks()).called(1);
      },
    );

    blocTest<TaskBloc, TaskState>(
      'emits [TaskLoading, TaskOperationFailure] when CompleteTask fails',
      build: () {
        when(
          () => taskRepository.completeTask('1'),
        ).thenThrow(Exception('Failed to complete task'));
        return taskBloc;
      },
      act: (bloc) => bloc.add(const CompleteTask('1')),
      expect: () => [
        const TaskLoading(),
        const TaskOperationFailure('Exception: Failed to complete task'),
      ],
    );
  });

  group('ResetTaskCompletion', () {
    final resetTask = testTask.resetCompletedTimes();

    blocTest<TaskBloc, TaskState>(
      'emits [TaskLoading, TasksLoaded] when ResetTaskCompletion is successful',
      build: () {
        when(() => taskRepository.getTaskById('1')).thenAnswer((_) async => testTask);
        when(() => taskRepository.updateTask(any())).thenAnswer((_) async => resetTask);
        when(() => taskRepository.getAllTasks()).thenAnswer((_) async => [resetTask]);
        return taskBloc;
      },
      act: (bloc) => bloc.add(const ResetTaskCompletion('1')),
      expect: () => [
        const TaskLoading(),
        TasksLoaded([resetTask]),
      ],
      verify: (_) {
        verify(() => taskRepository.getTaskById('1')).called(1);
        verify(() => taskRepository.updateTask(any())).called(1);
        verify(() => taskRepository.getAllTasks()).called(1);
      },
    );

    blocTest<TaskBloc, TaskState>(
      'emits [TaskLoading, TaskOperationFailure] when ResetTaskCompletion fails',
      build: () {
        when(() => taskRepository.getTaskById('1')).thenThrow(Exception('Failed to get task'));
        return taskBloc;
      },
      act: (bloc) => bloc.add(const ResetTaskCompletion('1')),
      expect: () => [
        const TaskLoading(),
        const TaskOperationFailure('Exception: Failed to get task'),
      ],
    );
  });

  group('CheckTasksForReset', () {
    blocTest<TaskBloc, TaskState>(
      'emits [TasksLoaded] when state is TasksLoaded and operation is successful',
      build: () {
        when(() => taskRepository.resetCompletedTasksIfNeeded()).thenAnswer((_) async {});
        when(() => taskRepository.getAllTasks()).thenAnswer((_) async => [testTask]);
        return taskBloc;
      },
      seed: () => TasksLoaded([completedTask]),
      act: (bloc) => bloc.add(const CheckTasksForReset()),
      expect: () => [
        TasksLoaded([testTask]),
      ],
      verify: (_) {
        verify(() => taskRepository.resetCompletedTasksIfNeeded()).called(1);
        verify(() => taskRepository.getAllTasks()).called(1);
      },
    );

    blocTest<TaskBloc, TaskState>(
      'does not emit any state when state is not TasksLoaded',
      build: () {
        when(() => taskRepository.resetCompletedTasksIfNeeded()).thenAnswer((_) async {});
        return taskBloc;
      },
      seed: () => const TaskLoading(),
      act: (bloc) => bloc.add(const CheckTasksForReset()),
      expect: () => [],
      verify: (_) {
        verify(() => taskRepository.resetCompletedTasksIfNeeded()).called(1);
        verifyNever(() => taskRepository.getAllTasks());
      },
    );

    blocTest<TaskBloc, TaskState>(
      'does not emit error state when operation fails',
      build: () {
        when(
          () => taskRepository.resetCompletedTasksIfNeeded(),
        ).thenThrow(Exception('Failed to reset tasks'));
        return taskBloc;
      },
      seed: () => TasksLoaded([completedTask]),
      act: (bloc) => bloc.add(const CheckTasksForReset()),
      expect: () => [],
      verify: (_) {
        verify(() => taskRepository.resetCompletedTasksIfNeeded()).called(1);
        verifyNever(() => taskRepository.getAllTasks());
      },
    );
  });
}
