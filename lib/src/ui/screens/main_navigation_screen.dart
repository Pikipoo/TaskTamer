import 'package:flutter/material.dart';
import 'tasks_screen.dart';
import 'projects_screen.dart';
import 'creatures_screen.dart';
import 'package:task_tamer/src/models/task.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/task_bloc.dart';
import '../../service_locator.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    locator<TaskBloc>().add(LoadTasks());
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      BlocProvider.value(
        value: locator<TaskBloc>(),
        child: const TasksScreen(),
      ),
      const ProjectsScreen(),
      const CreaturesScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('TaskTamer'),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_open),
            label: 'Projects',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            label: 'Creatures',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: const <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green,
              ),
              child: Text('Settings', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings (coming soon)'),
            ),
          ],
        ),
      ),
    );
  }
}
