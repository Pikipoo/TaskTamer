import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:task_tamer/src/blocs/creature/creature_bloc.dart';
import 'package:task_tamer/src/blocs/task/task_bloc.dart';
import 'package:task_tamer/src/blocs/user/user_bloc.dart';
import 'package:task_tamer/src/repositories/creature_repository.dart';
import 'package:task_tamer/src/repositories/task_repository.dart';
import 'package:task_tamer/src/repositories/user_repository.dart';
import 'package:task_tamer/src/services/notification_service.dart';

final GetIt serviceLocator = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Initialize Hive
  await Hive.initFlutter();

  // Register services
  serviceLocator.registerSingleton<NotificationService>(NotificationService());
  await serviceLocator<NotificationService>().initialize();

  // Register repositories
  final taskRepository = await TaskRepository.create();
  serviceLocator.registerSingleton<TaskRepository>(taskRepository);

  final userRepository = await UserRepository.create();
  serviceLocator.registerSingleton<UserRepository>(userRepository);

  final creatureRepository = await CreatureRepository.create();
  serviceLocator.registerSingleton<CreatureRepository>(creatureRepository);

  // Register BLoCs
  serviceLocator.registerFactory<TaskBloc>(() => TaskBloc(
        taskRepository: serviceLocator<TaskRepository>(),
        userRepository: serviceLocator<UserRepository>(),
        notificationService: serviceLocator<NotificationService>(),
      ));

  serviceLocator.registerFactory<UserBloc>(() => UserBloc(
        userRepository: serviceLocator<UserRepository>(),
      ));

  serviceLocator.registerFactory<CreatureBloc>(() => CreatureBloc(
        creatureRepository: serviceLocator<CreatureRepository>(),
      ));
}
