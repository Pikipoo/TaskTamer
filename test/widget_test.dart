/// Main application widget test
///
/// This file contains tests for the main TaskTamerApp widget.
/// It sets up a test environment with mock dependencies and verifies
/// that the application initializes and renders correctly.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:task_tamer/src/app.dart';
import 'package:task_tamer/src/blocs/creature/creature_bloc.dart';
import 'package:task_tamer/src/blocs/task/task_bloc.dart';
import 'package:task_tamer/src/blocs/user/user_bloc.dart';
import 'package:task_tamer/src/models/user_profile.dart';
import 'package:task_tamer/src/repositories/creature_repository.dart';
import 'package:task_tamer/src/repositories/task_repository.dart';
import 'package:task_tamer/src/repositories/user_repository.dart';
import 'package:task_tamer/src/services/notification_service.dart';

/// Mock implementation of TaskRepository for testing
class MockTaskRepository extends Mock implements TaskRepository {}

/// Mock implementation of UserRepository for testing
class MockUserRepository extends Mock implements UserRepository {}

/// Mock implementation of CreatureRepository for testing
class MockCreatureRepository extends Mock implements CreatureRepository {}

/// Mock implementation of NotificationService for testing
class MockNotificationService extends Mock implements NotificationService {}

void main() {
  late MockTaskRepository taskRepository;
  late MockUserRepository userRepository;
  late MockCreatureRepository creatureRepository;
  late MockNotificationService notificationService;

  /// Setup function that runs before each test
  ///
  /// This function:
  /// 1. Initializes all mock dependencies
  /// 2. Sets up default responses for mock methods
  /// 3. Resets and configures the GetIt service locator
  setUp(() {
    // Initialize mocks
    taskRepository = MockTaskRepository();
    userRepository = MockUserRepository();
    creatureRepository = MockCreatureRepository();
    notificationService = MockNotificationService();

    // Setup default responses
    when(() => taskRepository.getAllTasks()).thenAnswer((_) async => []);
    // Create a mock user profile for testing purposes
    final testUserProfile = UserProfile(id: 'test-user', name: 'Test User');
    when(() => userRepository.getUserProfile()).thenAnswer((_) async => testUserProfile);
    when(() => creatureRepository.getAllCreatures()).thenAnswer((_) async => []);
    when(() => creatureRepository.initializeDefaultCreatures()).thenAnswer((_) async => {});
    when(() => notificationService.initialize()).thenAnswer((_) async => {});

    // Reset GetIt before each test
    final getIt = GetIt.instance;
    if (getIt.isRegistered<TaskRepository>()) getIt.unregister<TaskRepository>();
    if (getIt.isRegistered<UserRepository>()) getIt.unregister<UserRepository>();
    if (getIt.isRegistered<CreatureRepository>()) getIt.unregister<CreatureRepository>();
    if (getIt.isRegistered<NotificationService>()) getIt.unregister<NotificationService>();
    if (getIt.isRegistered<TaskBloc>()) getIt.unregister<TaskBloc>();
    if (getIt.isRegistered<UserBloc>()) getIt.unregister<UserBloc>();
    if (getIt.isRegistered<CreatureBloc>()) getIt.unregister<CreatureBloc>();

    // Register services
    getIt.registerSingleton<NotificationService>(notificationService);
    getIt.registerSingleton<TaskRepository>(taskRepository);
    getIt.registerSingleton<UserRepository>(userRepository);
    getIt.registerSingleton<CreatureRepository>(creatureRepository);

    // Register blocs
    getIt.registerFactory<TaskBloc>(
      () => TaskBloc(
        taskRepository: getIt<TaskRepository>(),
        userRepository: getIt<UserRepository>(),
        notificationService: getIt<NotificationService>(),
      ),
    );

    getIt.registerFactory<UserBloc>(() => UserBloc(userRepository: getIt<UserRepository>()));

    getIt.registerFactory<CreatureBloc>(
      () => CreatureBloc(creatureRepository: getIt<CreatureRepository>()),
    );
  });

  /// Test that verifies the app builds and renders correctly
  ///
  /// This test:
  /// 1. Builds the TaskTamerApp widget
  /// 2. Waits for all animations to complete
  /// 3. Verifies that at least one Scaffold is present in the widget tree
  testWidgets('App should build and render home screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TaskTamerApp());
    await tester.pumpAndSettle();

    // Verify that the home screen is shown
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
