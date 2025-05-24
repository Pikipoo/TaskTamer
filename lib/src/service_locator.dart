/// Dependency Injection configuration for TaskTamer
///
/// This file sets up the service locator using the GetIt package to implement
/// dependency injection throughout the application. It initializes and registers
/// all services, repositories, and BLoCs needed by the app.
///
/// The service locator pattern allows for:
/// - Cleaner code with reduced coupling
/// - Easier testing by allowing mock implementations
/// - Single source of truth for dependency instances
/// - Simplified access to dependencies from anywhere in the app
library;

import 'package:get_it/get_it.dart';
import 'package:task_tamer/src/blocs/creature/creature_bloc.dart';
import 'package:task_tamer/src/blocs/task/task_bloc.dart';
import 'package:task_tamer/src/blocs/user/user_bloc.dart';
import 'package:task_tamer/src/models/hive_adapters.dart';
import 'package:task_tamer/src/repositories/creature_repository.dart';
import 'package:task_tamer/src/repositories/task_repository.dart';
import 'package:task_tamer/src/repositories/user_repository.dart';
import 'package:task_tamer/src/services/notification_service.dart';

/// Global service locator instance used throughout the app
final GetIt serviceLocator = GetIt.instance;

/// Initializes all dependencies for the TaskTamer application
///
/// This function performs the following steps:
/// 1. Initializes Hive for local storage
/// 2. Registers Hive adapters for custom types
/// 3. Registers services (e.g., NotificationService)
/// 4. Creates and registers repositories
/// 5. Registers BLoCs with their dependencies
///
/// Should be called during app initialization in [main.dart]
/// before running the app to ensure all dependencies are available.
Future<void> setupServiceLocator() async {
  // Hive is already initialized in main.dart

  // Register Hive adapters for custom types
  await registerHiveAdapters();

  // Register services
  // NotificationService is registered as a singleton to maintain a single instance
  serviceLocator.registerSingleton<NotificationService>(NotificationService());
  await serviceLocator<NotificationService>().initialize();

  // Register repositories
  // TaskRepository is created and initialized before registration
  final taskRepository = await TaskRepository.create();
  serviceLocator.registerSingleton<TaskRepository>(taskRepository);

  // UserRepository for managing user data and progression
  final userRepository = await UserRepository.create();
  serviceLocator.registerSingleton<UserRepository>(userRepository);

  // CreatureRepository for managing game creatures/pets
  final creatureRepository = await CreatureRepository.create();
  serviceLocator.registerSingleton<CreatureRepository>(creatureRepository);

  // Register BLoCs
  // Using factory registration for BLoCs to create a new instance every time they're requested
  // TaskBloc handles task operations and is dependent on task and user repositories
  serviceLocator.registerFactory<TaskBloc>(
    () => TaskBloc(
      taskRepository: serviceLocator<TaskRepository>(),
      userRepository: serviceLocator<UserRepository>(),
      notificationService: serviceLocator<NotificationService>(),
    ),
  );

  // UserBloc handles user profile and progression
  serviceLocator.registerFactory<UserBloc>(
    () => UserBloc(userRepository: serviceLocator<UserRepository>()),
  );

  // CreatureBloc handles pet/creature management
  serviceLocator.registerFactory<CreatureBloc>(
    () => CreatureBloc(creatureRepository: serviceLocator<CreatureRepository>()),
  );
}
