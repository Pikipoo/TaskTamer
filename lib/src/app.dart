import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_tamer/src/blocs/creature/creature_bloc.dart';
import 'package:task_tamer/src/blocs/creature/creature_event.dart';
import 'package:task_tamer/src/blocs/task/task_bloc.dart';
import 'package:task_tamer/src/blocs/task/task_event.dart';
import 'package:task_tamer/src/blocs/user/user_bloc.dart';
import 'package:task_tamer/src/blocs/user/user_event.dart';
import 'package:task_tamer/src/service_locator.dart';
import 'package:task_tamer/src/ui/screens/home_screen.dart';
import 'package:task_tamer/src/ui/themes/app_theme.dart';

class TaskTamerApp extends StatelessWidget {
  const TaskTamerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TaskBloc>(
          create: (context) => serviceLocator<TaskBloc>()..add(const LoadTasks()),
        ),
        BlocProvider<UserBloc>(
          create: (context) => serviceLocator<UserBloc>()..add(const LoadUserProfile()),
        ),
        BlocProvider<CreatureBloc>(
          create: (context) => serviceLocator<CreatureBloc>()
            ..add(const InitializeDefaultCreatures())
            ..add(const LoadCreatures()),
        ),
      ],
      child: MaterialApp(
        title: 'TaskTamer',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        home: const HomeScreen(),
      ),
    );
  }
}
