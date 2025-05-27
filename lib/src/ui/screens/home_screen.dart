import 'package:flutter/material.dart';
import 'package:task_tamer/src/ui/screens/creatures_screen.dart';
import 'package:task_tamer/src/ui/screens/dashboard_screen.dart';
import 'package:task_tamer/src/ui/screens/eggs_screen.dart';
import 'package:task_tamer/src/ui/screens/tasks_screen.dart';
import 'package:task_tamer/src/ui/widgets/app_drawer.dart';
import 'package:task_tamer/src/ui/widgets/task_form.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

// Make this class public so it can be accessed from other screens
class HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Index of the Creatures tab
  static const int CREATURES_TAB_INDEX = 2;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const TasksScreen(),
    const CreaturesScreen(),
    const EggsScreen(),
  ];

  final List<String> _titles = ['Dashboard', 'Tasks', 'Creatures', 'Eggs'];

  // Method to switch to creatures tab
  void switchToCreaturesTab() {
    setState(() {
      _currentIndex = CREATURES_TAB_INDEX;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_currentIndex])),
      drawer: const AppDrawer(),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed, // Needed for more than 3 items
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.task_alt), label: 'Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Creatures'),
          BottomNavigationBarItem(icon: Icon(Icons.egg), label: 'Eggs'),
        ],
      ),
      floatingActionButton: _currentIndex == 1
          ? FloatingActionButton(
              onPressed: () => _showAddTaskDialog(context),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(child: TaskForm()),
        );
      },
    );
  }
}
