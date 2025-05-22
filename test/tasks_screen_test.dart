import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_tamer/screens/tasks_screen.dart';
import 'package:task_tamer/models/task.dart';

void main() {
  testWidgets('TasksScreen renders, adds, completes, edits, and deletes a task', (WidgetTester tester) async {
    int xp = 0;
    Map<String, Task> taskMap = {};
    void onXpEarned(int add) => xp += add;
    void onAddTask(Task t) => taskMap[t.id] = t;
    void onDeleteTask(String id) => taskMap.remove(id);

    await tester.pumpWidget(MaterialApp(
      home: TasksScreen(
        onXpEarned: onXpEarned,
        tasks: taskMap.values.toList(),
        onAddTask: onAddTask,
        onDeleteTask: onDeleteTask,
      ),
    ));
    expect(find.text('No tasks yet. Add one!'), findsOneWidget);

    // Add a task
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.bySemanticsLabel('Title *'), 'Test Task');
    await tester.enterText(find.bySemanticsLabel('XP Reward'), '15');
    await tester.tap(find.byType(ElevatedButton).last);
    await tester.pumpAndSettle();
    // Rebuild with updated tasks
    await tester.pumpWidget(MaterialApp(
      home: TasksScreen(
        onXpEarned: onXpEarned,
        tasks: taskMap.values.toList(),
        onAddTask: onAddTask,
        onDeleteTask: onDeleteTask,
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Test Task'), findsOneWidget);
    expect(taskMap.length, 1);

    // Complete the task
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(taskMap.values.first.isCompleted, true);
    expect(xp, 15);

    // Edit the task
    await tester.tap(find.text('Test Task'));
    await tester.pumpAndSettle();
    await tester.enterText(find.bySemanticsLabel('Title *'), 'Edited Task');
    await tester.tap(find.byType(ElevatedButton).last);
    await tester.pumpAndSettle();
    // Rebuild with updated tasks
    await tester.pumpWidget(MaterialApp(
      home: TasksScreen(
        onXpEarned: onXpEarned,
        tasks: taskMap.values.toList(),
        onAddTask: onAddTask,
        onDeleteTask: onDeleteTask,
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Edited Task'), findsOneWidget);
    expect(taskMap.values.first.title, 'Edited Task');

    // Delete the task
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();
    // Rebuild with updated tasks
    await tester.pumpWidget(MaterialApp(
      home: TasksScreen(
        onXpEarned: onXpEarned,
        tasks: taskMap.values.toList(),
        onAddTask: onAddTask,
        onDeleteTask: onDeleteTask,
      ),
    ));
    await tester.pumpAndSettle();
    expect(taskMap.isEmpty, true);
    expect(find.text('No tasks yet. Add one!'), findsOneWidget);
  });

  testWidgets('TasksScreen handles times per day progress', (WidgetTester tester) async {
    int xp = 0;
    final task = Task(id: 'multi', title: 'Multi', timesPerDay: 2);
    final tasks = [task];
    await tester.pumpWidget(MaterialApp(
      home: TasksScreen(
        onXpEarned: (add) => xp += add,
        tasks: tasks,
        onAddTask: (_) {},
        onDeleteTask: (_) {},
      ),
    ));
    expect(find.text('Multi'), findsOneWidget);
    expect(task.isCompleted, false);
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(task.isCompleted, false);
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(task.isCompleted, true);
  });
}
