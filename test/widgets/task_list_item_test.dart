import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:task_tamer/src/blocs/task/task_bloc.dart';
import 'package:task_tamer/src/blocs/task/task_event.dart';
import 'package:task_tamer/src/models/task.dart';
import 'package:task_tamer/src/ui/widgets/task_list_item.dart';

class MockTaskBloc extends Mock implements TaskBloc {}

void main() {
  late MockTaskBloc mockTaskBloc;

  final testDate = DateTime(2023, 6, 15, 10, 0);
  final dueDate = testDate.add(const Duration(days: 1));

  final task = Task(
    id: '1',
    title: 'Test Task',
    description: 'Test Description',
    creationDate: testDate,
    dueDate: dueDate,
    repeatFrequency: RepeatFrequency.daily,
    repeatValue: 1,
    timesPerDay: 2,
    completedTimes: 0,
    isCompleted: false,
  );

  setUp(() {
    mockTaskBloc = MockTaskBloc();
  });

  Future<void> pumpTaskListItem(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<TaskBloc>.value(
            value: mockTaskBloc,
            child: TaskListItem(task: task),
          ),
        ),
      ),
    );
  }

  testWidgets('TaskListItem displays task information correctly', (WidgetTester tester) async {
    await pumpTaskListItem(tester);

    expect(find.text('Test Task'), findsOneWidget);
    expect(find.text('Test Description'), findsOneWidget);
    expect(find.text('Jun 16, 2023'), findsOneWidget); // Formatted due date
    expect(find.text('Every 1 day'), findsOneWidget); // Repeat description
    expect(find.text('0/2 times completed'), findsOneWidget); // Times per day description
  });

  testWidgets('Tapping complete button triggers CompleteTask event', (WidgetTester tester) async {
    when(() => mockTaskBloc.add(any<CompleteTask>())).thenReturn(null);

    await pumpTaskListItem(tester);

    // Find and tap the complete button
    final completeButton = find.byIcon(Icons.check_circle_outline);
    expect(completeButton, findsOneWidget);

    await tester.tap(completeButton);
    await tester.pump();

    verify(() => mockTaskBloc.add(const CompleteTask('1'))).called(1);
  });

  testWidgets('Tapping edit button shows edit dialog', (WidgetTester tester) async {
    await pumpTaskListItem(tester);

    // Find and tap the edit button
    final editButton = find.byIcon(Icons.edit);
    expect(editButton, findsOneWidget);

    await tester.tap(editButton);
    await tester.pumpAndSettle();

    // Verify edit dialog is shown
    expect(find.text('Edit Task'), findsOneWidget);
    expect(find.byType(TextFormField), findsAtLeastNWidgets(1));
    expect(find.text('Save'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });

  testWidgets('Tapping delete button shows confirmation dialog', (WidgetTester tester) async {
    await pumpTaskListItem(tester);

    // Find and tap the delete button
    final deleteButton = find.byIcon(Icons.delete);
    expect(deleteButton, findsOneWidget);

    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    // Verify confirmation dialog is shown
    expect(find.text('Delete Task'), findsOneWidget);
    expect(find.text('Are you sure you want to delete this task?'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });

  testWidgets('Confirming delete triggers DeleteTask event', (WidgetTester tester) async {
    when(() => mockTaskBloc.add(any<DeleteTask>())).thenReturn(null);

    await pumpTaskListItem(tester);

    // Find and tap the delete button
    final deleteButton = find.byIcon(Icons.delete);
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    // Find and tap the confirm delete button
    final confirmDeleteButton = find.text('Delete');
    await tester.tap(confirmDeleteButton);
    await tester.pump();

    verify(() => mockTaskBloc.add(const DeleteTask('1'))).called(1);
  });

  testWidgets('TaskListItem shows progress indicator for multi-time tasks', (WidgetTester tester) async {
    await pumpTaskListItem(tester);

    // Check for linear progress indicator
    expect(find.byType(LinearProgressIndicator), findsOneWidget);

    // Verify progress is 0%
    final progressIndicator = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator)
    );
    expect(progressIndicator.value, 0.0);
  });

  testWidgets('TaskListItem shows different progress for partially completed task', (WidgetTester tester) async {
    final partiallyCompletedTask = task.copyWith(completedTimes: 1);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<TaskBloc>.value(
            value: mockTaskBloc,
            child: TaskListItem(task: partiallyCompletedTask),
          ),
        ),
      ),
    );

    // Check for linear progress indicator
    expect(find.byType(LinearProgressIndicator), findsOneWidget);

    // Verify progress is 50%
    final progressIndicator = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator)
    );
    expect(progressIndicator.value, 0.5);

    // Check text shows 1/2 completed
    expect(find.text('1/2 times completed'), findsOneWidget);
  });
}
