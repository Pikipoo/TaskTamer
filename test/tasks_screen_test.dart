import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_tamer/src/ui/screens/tasks_screen.dart';
import 'package:task_tamer/src/models/task.dart';
import 'package:task_tamer/src/blocs/task_bloc.dart';
import 'package:task_tamer/src/repositories/hive_task_repository.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';

void main() {
  setUpAll(() async {
    final testDir = Directory('./test/hive_testing');
    if (!testDir.existsSync()) {
      testDir.createSync(recursive: true);
    }
    Hive.init(testDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(RepeatUnitAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TaskAdapter());
    }
  });

  setUp(() async {
    // Clear the test box before each test
    final box = await Hive.openBox<Task>('tasks');
    await box.clear();
  });

  Widget makeTestable(Widget child) {
    final repo = HiveTaskRepository();
    final bloc = TaskBloc(repo);
    return BlocProvider.value(
      value: bloc..add(LoadTasks()),
      child: MaterialApp(home: child),
    );
  }

  testWidgets(
    'TasksScreen renders, adds, edits, and deletes a task',
    (WidgetTester tester) async {
      await tester.pumpWidget(makeTestable(const TasksScreen()));
      await tester.pumpAndSettle();
      expect(find.text('No tasks yet. Add one!'), findsOneWidget);

      // Add a task
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.bySemanticsLabel('Title *'), 'Test Task');
      await tester.enterText(find.bySemanticsLabel('XP Reward'), '15');
      await tester.tap(find.byType(ElevatedButton).last);
      await tester.pumpAndSettle();
      expect(find.text('Test Task'), findsOneWidget);

      // Edit the task
      await tester.tap(find.text('Test Task'));
      await tester.pumpAndSettle();
      await tester.enterText(find.bySemanticsLabel('Title *'), 'Edited Task');
      await tester.tap(find.byType(ElevatedButton).last);
      await tester.pumpAndSettle();
      expect(find.text('Edited Task'), findsOneWidget);

      // Delete the task
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();
      expect(find.text('No tasks yet. Add one!'), findsOneWidget);
    },
  );

  testWidgets('TasksScreen handles times per day progress', (
    WidgetTester tester,
  ) async {
    final repo = HiveTaskRepository();
    final bloc = TaskBloc(repo);
    await tester.pumpWidget(
      BlocProvider.value(
        value: bloc..add(LoadTasks()),
        child: const MaterialApp(home: TasksScreen()),
      ),
    );
    await tester.pumpAndSettle();
    // Add a multi-times-per-day task
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.bySemanticsLabel('Title *'), 'Multi');
    await tester.enterText(find.bySemanticsLabel('Times per Day'), '2');
    await tester.tap(find.byType(ElevatedButton).last);
    await tester.pumpAndSettle();
    expect(find.text('Multi'), findsOneWidget);
    // Complete once
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    // Should not be completed yet
    // Complete again
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    // Should now be completed
  });
}
