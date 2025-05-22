import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import './service_locator.dart';
import './ui/screens/home_screen.dart';

class TaskTamerApp extends StatelessWidget {
  const TaskTamerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskTamer',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(),
    );
  }
}

Future<void> initializeApp() async {
  await Hive.initFlutter();
  setupLocator();
}
