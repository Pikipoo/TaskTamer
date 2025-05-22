import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import './service_locator.dart';
import './ui/screens/main_navigation_screen.dart';
import './blocs/task_bloc.dart';
import './models/task.dart';

class TaskTamerApp extends StatelessWidget {
  const TaskTamerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: locator<TaskBloc>(),
      child: MaterialApp(
        title: 'TaskTamer',
        theme: ThemeData(
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const MainNavigationScreen(),
      ),
    );
  }
}

Future<void> initializeApp() async {
  await Hive.initFlutter();
  // Register Hive adapters if not already registered
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(RepeatUnitAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(TaskAdapter());
  }
  setupLocator();
}
