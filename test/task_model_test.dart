import 'package:flutter_test/flutter_test.dart';
import 'package:task_tamer/src/models/task.dart';
import 'package:hive/hive.dart';

void main() {
  group('Task Model', () {
    test('Task creation with all fields', () {
      final task = Task(
        id: '1',
        title: 'Test Task',
        description: 'desc',
        dueDate: DateTime(2025, 1, 1, 12, 0),
        repeatUnit: RepeatUnit.day,
        repeatInterval: 2,
        timesPerDay: 3,
        xpReward: 50,
        notifications: [DateTime(2024, 12, 31, 12, 0)],
      );
      expect(task.id, '1');
      expect(task.title, 'Test Task');
      expect(task.description, 'desc');
      expect(task.dueDate, DateTime(2025, 1, 1, 12, 0));
      expect(task.repeatUnit, RepeatUnit.day);
      expect(task.repeatInterval, 2);
      expect(task.timesPerDay, 3);
      expect(task.xpReward, 50);
      expect(task.notifications.length, 1);
      expect(task.isCompleted, false);
      expect(task.timesCompletedToday, 0);
    });

    test('Task editing', () {
      final task = Task(id: '2', title: 'Edit Me');
      task.title = 'Edited';
      task.description = 'New desc';
      task.dueDate = DateTime(2025, 2, 2);
      task.repeatUnit = RepeatUnit.week;
      task.repeatInterval = 1;
      task.timesPerDay = 2;
      task.xpReward = 20;
      expect(task.title, 'Edited');
      expect(task.description, 'New desc');
      expect(task.dueDate, DateTime(2025, 2, 2));
      expect(task.repeatUnit, RepeatUnit.week);
      expect(task.repeatInterval, 1);
      expect(task.timesPerDay, 2);
      expect(task.xpReward, 20);
    });

    test('Task completion and times per day', () {
      final task = Task(id: '3', title: 'Multi', timesPerDay: 2);
      expect(task.isCompleted, false);
      expect(task.progress, 0.0);
      task.complete();
      expect(task.isCompleted, false);
      expect(task.progress, 0.5);
      task.complete();
      expect(task.isCompleted, true);
      expect(task.progress, 1.0);
    });

    test('Task notifications', () {
      final task = Task(
        id: '4',
        title: 'Notify',
        notifications: [DateTime(2025, 1, 1, 8, 0)],
      );
      expect(task.notifications.length, 1);
      expect(task.notifications.first, DateTime(2025, 1, 1, 8, 0));
    });

    test('Hive compatibility with put and update', () async {
      Hive.init('./test_hive');
      Hive.registerAdapter(TaskAdapter());
      Hive.registerAdapter(RepeatUnitAdapter());
      var box = await Hive.openBox<Task>('testBox');
      final task = Task(id: '5', title: 'Hive');
      await box.put(task.id, task);
      final loaded = box.get(task.id);
      expect(loaded?.id, '5');
      // Update and re-save
      task.title = 'Updated';
      await box.put(task.id, task);
      final updated = box.get(task.id);
      expect(updated?.title, 'Updated');
      await box.delete(task.id);
      await box.close();
    });
  });
}
