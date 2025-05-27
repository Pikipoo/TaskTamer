/// Main application widget for TaskTamer
///
/// This file defines the root widget of the TaskTamer application, setting up
/// the BLoC providers, theme configuration, and initial route.
///
/// The app architecture follows the BLoC pattern for state management, separating
/// business logic from UI components.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_tamer/src/blocs/creature/creature_bloc.dart';
import 'package:task_tamer/src/blocs/creature/creature_event.dart';
import 'package:task_tamer/src/blocs/egg/egg_bloc.dart';
import 'package:task_tamer/src/blocs/egg/egg_event.dart';
import 'package:task_tamer/src/blocs/task/task_bloc.dart';
import 'package:task_tamer/src/blocs/task/task_event.dart';
import 'package:task_tamer/src/blocs/user/user_bloc.dart';
import 'package:task_tamer/src/blocs/user/user_event.dart';
import 'package:task_tamer/src/repositories/task_repository.dart';
import 'package:task_tamer/src/repositories/user_repository.dart';
import 'package:task_tamer/src/service_locator.dart';
import 'package:task_tamer/src/services/notification_service.dart';
import 'package:task_tamer/src/ui/screens/home_screen.dart';
import 'package:task_tamer/src/ui/themes/app_theme.dart';

/// Root widget for the TaskTamer application
///
/// Sets up the BLoC providers for the application, initializing:
/// - [TaskBloc] for task management
/// - [UserBloc] for user profile and progression
/// - [CreatureBloc] for pet/creature management
/// - [EggBloc] for egg management and hatching
///
/// Also configures theme settings and sets the home screen as the initial route.
class TaskTamerApp extends StatelessWidget {
  const TaskTamerApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Create UserBloc first so we can pass it to TaskBloc
    final userBloc = UserBloc(userRepository: serviceLocator<UserRepository>())
      ..add(const LoadUserProfile());

    // Create TaskBloc with reference to UserBloc
    final taskBloc = TaskBloc(
      taskRepository: serviceLocator<TaskRepository>(),
      userRepository: serviceLocator<UserRepository>(),
      notificationService: serviceLocator<NotificationService>(),
      userBloc: userBloc,
    )..add(const LoadTasks());

    return MultiBlocProvider(
      providers: [
        // User BLoC provider - handles user profile and progression
        BlocProvider<UserBloc>(create: (context) => userBloc),
        // Task BLoC provider - handles task-related operations and state
        BlocProvider<TaskBloc>(create: (context) => taskBloc),
        // Creature BLoC provider - handles pet/creature management
        BlocProvider<CreatureBloc>(
          create: (context) => serviceLocator<CreatureBloc>()
            ..add(const InitializeDefaultCreatures())
            ..add(const LoadCreatures()),
        ),
        // Egg BLoC provider - handles egg management and hatching
        BlocProvider<EggBloc>(
          create: (context) => serviceLocator<EggBloc>()
            ..add(const InitializeStarterEggs())
            ..add(const LoadEggs()),
        ),
      ],
      child: MaterialApp(
        title: 'TaskTamer',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system, // Uses system theme preference
        debugShowCheckedModeBanner: false, // Removes the debug banner
        home: const HomeScreen(), // Initial screen
      ),
    );
  }
}
