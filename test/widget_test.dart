// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

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

// Mock classes
class MockTaskRepository extends Mock implements TaskRepository {}

class MockUserRepository extends Mock implements UserRepository {}

class MockCreatureRepository extends Mock implements CreatureRepository {}

class MockNotificationService extends Mock implements NotificationService {}

void main() {
  late MockTaskRepository taskRepository;
  late MockUserRepository userRepository;
  late MockCreatureRepository creatureRepository;
  late MockNotificationService notificationService;

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

  testWidgets('App should build and render home screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TaskTamerApp());
    await tester.pumpAndSettle();

    // Verify that the home screen is shown
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
