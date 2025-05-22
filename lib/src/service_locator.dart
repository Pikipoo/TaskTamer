import 'package:get_it/get_it.dart';
import './repositories/hive_task_repository.dart';
import './blocs/task_bloc.dart';
import './blocs/pet_bloc.dart';
import './services/notification_service.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton<TaskRepository>(() => HiveTaskRepository());
  locator.registerFactory(() => TaskBloc(locator()));
  locator.registerFactory(() => PetBloc());
  locator.registerLazySingleton<NotificationService>(
    () => NotificationService(),
  );
}
