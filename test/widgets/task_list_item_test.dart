import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:task_tamer/src/blocs/task/task_bloc.dart';
import 'package:task_tamer/src/blocs/task/task_event.dart';
import 'package:task_tamer/src/models/task.dart';
import 'package:task_tamer/src/ui/widgets/task_item.dart';

class MockTaskBloc extends Mock implements TaskBloc {}

// Define fake classes for Mocktail fallback values
class FakeCompleteTask extends Fake implements CompleteTask {}

class FakeDeleteTask extends Fake implements DeleteTask {}

void main() {
  late MockTaskBloc mockTaskBloc;

  // Register fallback values for Mocktail
  setUpAll(() {
    registerFallbackValue(FakeCompleteTask());
    registerFallbackValue(FakeDeleteTask());
  });

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

  Future<void> pumpTaskItem(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<TaskBloc>.value(
            value: mockTaskBloc,
            child: TaskItem(
              task: task,
              onComplete: () => mockTaskBloc.add(const CompleteTask('1')),
              onDelete: () => mockTaskBloc.add(const DeleteTask('1')),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('TaskItem displays task information correctly', (WidgetTester tester) async {
    await pumpTaskItem(tester);

    expect(find.text('Test Task'), findsOneWidget);
    expect(find.text('Test Description'), findsOneWidget);
    expect(find.text('Jun 16, 2023'), findsOneWidget); // Formatted due date
    expect(find.text('Every 1 day'), findsOneWidget); // Repeat description
    expect(find.text('0/2 times completed'), findsOneWidget); // Times per day description
  });

  testWidgets('Tapping complete button triggers callback', (WidgetTester tester) async {
    bool callbackCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: TaskItem(
            task: task,
            onComplete: () {
              callbackCalled = true;
            },
            onDelete: () {},
          ),
        ),
      ),
    );

    // Find the Container inside the InkWell
    final container = find.descendant(of: find.byType(InkWell), matching: find.byType(Container));
    expect(container, findsOneWidget);

    // Tap on the container
    await tester.tap(container);
    await tester.pump();

    // Verify callback was called
    expect(callbackCalled, isTrue);
  });

  testWidgets('Tapping delete button triggers callback', (WidgetTester tester) async {
    bool callbackCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: TaskItem(
            task: task,
            onComplete: () {},
            onDelete: () {
              callbackCalled = true;
            },
          ),
        ),
      ),
    );

    // Find and tap the delete button
    final deleteButton = find.byIcon(Icons.delete);
    expect(deleteButton, findsOneWidget);

    await tester.tap(deleteButton);
    await tester.pump();

    // Verify callback was called
    expect(callbackCalled, isTrue);
  });

  testWidgets('TaskItem shows progress indicator for multi-time tasks', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TaskItem(task: task, onComplete: () {}, onDelete: () {}),
        ),
      ),
    );

    // Check for linear progress indicator
    expect(find.byType(LinearProgressIndicator), findsOneWidget);

    // Verify progress is 0%
    final progressIndicator = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(progressIndicator.value, 0.0);
  });

  testWidgets('TaskItem shows different progress for partially completed task', (
    WidgetTester tester,
  ) async {
    final partiallyCompletedTask = task.copyWith(completedTimes: 1);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TaskItem(task: partiallyCompletedTask, onComplete: () {}, onDelete: () {}),
        ),
      ),
    );

    // Check for linear progress indicator
    expect(find.byType(LinearProgressIndicator), findsOneWidget);

    // Verify progress is 50%
    final progressIndicator = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(progressIndicator.value, 0.5);

    // Check text shows 1/2 completed
    expect(find.text('1/2 times completed'), findsOneWidget);
  });
}
