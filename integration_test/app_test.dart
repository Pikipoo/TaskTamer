import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:task_tamer/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-end app tests', () {
    testWidgets('Add a new task and verify it appears in the task list',
        (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify we're on the home screen
      expect(find.text('My Tasks'), findsOneWidget);

      // Find and tap the add task button
      final addTaskButton = find.byType(FloatingActionButton);
      expect(addTaskButton, findsOneWidget);
      await tester.tap(addTaskButton);
      await tester.pumpAndSettle();

      // Verify add task dialog appears
      expect(find.text('Add Task'), findsOneWidget);

      // Fill in task details
      await tester.enterText(
          find.byType(TextFormField).at(0), 'Integration Test Task');
      await tester.enterText(
          find.byType(TextFormField).at(1), 'Description for integration test');

      // Save the task
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify the task appears in the list
      expect(find.text('Integration Test Task'), findsOneWidget);
      expect(find.text('Description for integration test'), findsOneWidget);
    });

    testWidgets('Complete a task and verify it gets marked as completed',
        (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Add a task
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byType(TextFormField).at(0), 'Task to Complete');

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify the task appears in the list
      expect(find.text('Task to Complete'), findsOneWidget);

      // Find and tap the complete button
      final completeButton = find.byIcon(Icons.check_circle_outline).last;
      await tester.tap(completeButton);
      await tester.pumpAndSettle();

      // Verify the task is marked as completed (checkmark icon changes)
      expect(find.byIcon(Icons.check_circle).last, findsOneWidget);
    });

    testWidgets('Navigate between screens using bottom navigation',
        (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify we're on the tasks screen
      expect(find.text('My Tasks'), findsOneWidget);

      // Navigate to Creatures screen
      await tester.tap(find.byIcon(Icons.pets));
      await tester.pumpAndSettle();

      // Verify we're on the creatures screen
      expect(find.text('My Creatures'), findsOneWidget);

      // Navigate to Dashboard screen
      await tester.tap(find.byIcon(Icons.dashboard));
      await tester.pumpAndSettle();

      // Verify we're on the dashboard screen
      expect(find.text('Dashboard'), findsOneWidget);

      // Navigate back to Tasks screen
      await tester.tap(find.byIcon(Icons.checklist));
      await tester.pumpAndSettle();

      // Verify we're back on the tasks screen
      expect(find.text('My Tasks'), findsOneWidget);
    });

    testWidgets('Delete a task with confirmation dialog',
        (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Add a task
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byType(TextFormField).at(0), 'Task to Delete');

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify the task appears in the list
      expect(find.text('Task to Delete'), findsOneWidget);

      // Find and tap the delete button
      final deleteButton = find.byIcon(Icons.delete).last;
      await tester.tap(deleteButton);
      await tester.pumpAndSettle();

      // Verify confirmation dialog appears
      expect(find.text('Delete Task'), findsOneWidget);
      expect(find.text('Are you sure you want to delete this task?'), findsOneWidget);

      // Confirm deletion
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Verify the task is removed from the list
      expect(find.text('Task to Delete'), findsNothing);
    });

    testWidgets('Edit a task and verify changes are applied',
        (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Add a task
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byType(TextFormField).at(0), 'Original Task Name');

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify the task appears in the list
      expect(find.text('Original Task Name'), findsOneWidget);

      // Find and tap the edit button
      final editButton = find.byIcon(Icons.edit).last;
      await tester.tap(editButton);
      await tester.pumpAndSettle();

      // Verify edit dialog appears
      expect(find.text('Edit Task'), findsOneWidget);

      // Update the task name
      await tester.enterText(
          find.byType(TextFormField).at(0), 'Updated Task Name');

      // Save the changes
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify the task name is updated
      expect(find.text('Original Task Name'), findsNothing);
      expect(find.text('Updated Task Name'), findsOneWidget);
    });
  });
}
