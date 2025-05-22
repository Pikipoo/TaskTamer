import 'package:hive/hive.dart';
import '../models/task.dart';

abstract class TaskRepository {
  Future<List<Task>> getTasks();
  Future<void> addTask(Task task);
  Future<void> deleteTask(String id);
}

class HiveTaskRepository implements TaskRepository {
  static const String _boxName = 'tasks';

  @override
  Future<List<Task>> getTasks() async {
    final box = await Hive.openBox<Task>(_boxName);
    return box.values.toList();
  }

  @override
  Future<void> addTask(Task task) async {
    final box = await Hive.openBox<Task>(_boxName);
    await box.put(task.id, task);
  }

  @override
  Future<void> deleteTask(String id) async {
    final box = await Hive.openBox<Task>(_boxName);
    await box.delete(id);
  }
}
