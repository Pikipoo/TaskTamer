/// Unit tests for the Task model
///
/// This file contains comprehensive tests for the Task model,
/// including constructor tests, method tests, serialization tests,
/// and utility method tests to ensure the model functions correctly.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:task_tamer/src/models/task.dart';

void main() {
  /// Group of tests for the Task model
  group('Task Model', () {
    // Common test date for consistent testing
    final currentDate = DateTime(2023, 6, 15, 10, 0);

    /// Test creating a Task with only required parameters
    test('should create Task with required parameters', () {
      final task = Task(id: '1', title: 'Test Task', creationDate: currentDate);

      expect(task.id, '1');
      expect(task.title, 'Test Task');
      expect(task.creationDate, currentDate);
      expect(task.isCompleted, false);
      expect(task.completedTimes, 0);
    });

    /// Test creating a Task with all available parameters
    test('should create Task with all parameters', () {
      final dueDate = currentDate.add(const Duration(days: 1));
      final notificationTimes = [dueDate.subtract(const Duration(hours: 1))];

      final task = Task(
        id: '1',
        title: 'Test Task',
        description: 'Test Description',
        creationDate: currentDate,
        dueDate: dueDate,
        repeatFrequency: RepeatFrequency.daily,
        repeatValue: 1,
        timesPerDay: 2,
        completedTimes: 1,
        notificationTimes: notificationTimes,
        isCompleted: false,
      );

      expect(task.id, '1');
      expect(task.title, 'Test Task');
      expect(task.description, 'Test Description');
      expect(task.creationDate, currentDate);
      expect(task.dueDate, dueDate);
      expect(task.repeatFrequency, RepeatFrequency.daily);
      expect(task.repeatValue, 1);
      expect(task.timesPerDay, 2);
      expect(task.completedTimes, 1);
      expect(task.notificationTimes, notificationTimes);
      expect(task.isCompleted, false);
    });

    /// Test the copyWith method creates a new instance with updated values
    test('copyWith should create a new instance with updated values', () {
      final task = Task(id: '1', title: 'Test Task', creationDate: currentDate);

      final updatedTask = task.copyWith(title: 'Updated Task', description: 'Added Description');

      expect(updatedTask.id, '1');
      expect(updatedTask.title, 'Updated Task');
      expect(updatedTask.description, 'Added Description');
      expect(updatedTask.creationDate, currentDate);
    });

    /// Test incrementCompletedTimes for multi-time tasks
    test('incrementCompletedTimes should increment counter and update isCompleted', () {
      final task = Task(
        id: '1',
        title: 'Test Task',
        creationDate: currentDate,
        timesPerDay: 2,
        completedTimes: 0,
      );

      final updatedTask = task.incrementCompletedTimes();
      expect(updatedTask.completedTimes, 1);
      expect(updatedTask.isCompleted, false);

      final completedTask = updatedTask.incrementCompletedTimes();
      expect(completedTask.completedTimes, 2);
      expect(completedTask.isCompleted, true);
    });

    /// Test incrementCompletedTimes for single-time tasks
    test('incrementCompletedTimes should mark single-time task as completed', () {
      final task = Task(id: '1', title: 'Test Task', creationDate: currentDate);

      final updatedTask = task.incrementCompletedTimes();
      expect(updatedTask.completedTimes, 1);
      expect(updatedTask.isCompleted, true);
    });

    /// Test resetCompletedTimes resets counter and completion status
    test('resetCompletedTimes should reset counter and isCompleted', () {
      final task = Task(
        id: '1',
        title: 'Test Task',
        creationDate: currentDate,
        timesPerDay: 2,
        completedTimes: 2,
        isCompleted: true,
      );

      final resetTask = task.resetCompletedTimes();
      expect(resetTask.completedTimes, 0);
      expect(resetTask.isCompleted, false);
    });

    /// Test serialization to JSON
    test('toJson should return a valid map', () {
      final dueDate = currentDate.add(const Duration(days: 1));
      final notificationTimes = [dueDate.subtract(const Duration(hours: 1))];

      final task = Task(
        id: '1',
        title: 'Test Task',
        description: 'Test Description',
        creationDate: currentDate,
        dueDate: dueDate,
        repeatFrequency: RepeatFrequency.daily,
        repeatValue: 1,
        timesPerDay: 2,
        completedTimes: 1,
        notificationTimes: notificationTimes,
        isCompleted: false,
      );

      final json = task.toJson();

      expect(json['id'], '1');
      expect(json['title'], 'Test Task');
      expect(json['description'], 'Test Description');
      expect(json['creationDate'], currentDate.toIso8601String());
      expect(json['dueDate'], dueDate.toIso8601String());
      expect(json['repeatFrequency'], 'daily');
      expect(json['repeatValue'], 1);
      expect(json['timesPerDay'], 2);
      expect(json['completedTimes'], 1);
      expect(json['notificationTimes'], [notificationTimes[0].toIso8601String()]);
      expect(json['isCompleted'], false);
    });

    /// Test deserialization from JSON
    test('fromJson should create a task from json', () {
      final dueDate = currentDate.add(const Duration(days: 1));
      final notificationTime = dueDate.subtract(const Duration(hours: 1));

      final json = {
        'id': '1',
        'title': 'Test Task',
        'description': 'Test Description',
        'creationDate': currentDate.toIso8601String(),
        'dueDate': dueDate.toIso8601String(),
        'repeatFrequency': 'daily',
        'repeatValue': 1,
        'timesPerDay': 2,
        'completedTimes': 1,
        'notificationTimes': [notificationTime.toIso8601String()],
        'isCompleted': false,
      };

      final task = Task.fromJson(json);

      expect(task.id, '1');
      expect(task.title, 'Test Task');
      expect(task.description, 'Test Description');
      expect(task.creationDate, currentDate);
      expect(task.dueDate, dueDate);
      expect(task.repeatFrequency, RepeatFrequency.daily);
      expect(task.repeatValue, 1);
      expect(task.timesPerDay, 2);
      expect(task.completedTimes, 1);
      expect(task.notificationTimes?.length, 1);
      expect(task.notificationTimes?[0], notificationTime);
      expect(task.isCompleted, false);
    });

    /// Test getFormattedDueDate with a valid due date
    test('getFormattedDueDate should return correct format', () {
      final dueDate = DateTime(2023, 6, 16, 10, 0);
      final task = Task(id: '1', title: 'Test Task', creationDate: currentDate, dueDate: dueDate);

      expect(task.getFormattedDueDate(), 'Jun 16, 2023');
    });

    /// Test getFormattedDueDate with null due date
    test('getFormattedDueDate should return "No due date" when null', () {
      final task = Task(id: '1', title: 'Test Task', creationDate: currentDate);

      expect(task.getFormattedDueDate(), 'No due date');
    });

    /// Test getFormattedDueTime with a valid due date
    test('getFormattedDueTime should return correct format', () {
      final dueDate = DateTime(2023, 6, 16, 14, 30);
      final task = Task(id: '1', title: 'Test Task', creationDate: currentDate, dueDate: dueDate);

      expect(task.getFormattedDueTime(), '02:30 PM');
    });

    /// Test isOverdue for tasks with past due dates
    test('isOverdue should return true for past due dates', () {
      final now = DateTime.now();
      final pastDueDate = now.subtract(const Duration(days: 1));

      final task = Task(
        id: '1',
        title: 'Test Task',
        creationDate: currentDate,
        dueDate: pastDueDate,
        isCompleted: false,
      );

      expect(task.isOverdue(), true);
    });

    /// Test isOverdue for tasks with future due dates
    test('isOverdue should return false for future due dates', () {
      final now = DateTime.now();
      final futureDueDate = now.add(const Duration(days: 1));

      final task = Task(
        id: '1',
        title: 'Test Task',
        creationDate: currentDate,
        dueDate: futureDueDate,
        isCompleted: false,
      );

      expect(task.isOverdue(), false);
    });

    /// Test isOverdue for completed tasks
    test('isOverdue should return false for completed tasks', () {
      final now = DateTime.now();
      final pastDueDate = now.subtract(const Duration(days: 1));

      final task = Task(
        id: '1',
        title: 'Test Task',
        creationDate: currentDate,
        dueDate: pastDueDate,
        isCompleted: true,
      );

      expect(task.isOverdue(), false);
    });

    /// Test repeatDescription for different repeat frequencies
    test('repeatDescription should return correct string for each frequency', () {
      final baseTask = Task(id: '1', title: 'Test Task', creationDate: currentDate);

      final hourlyTask = baseTask.copyWith(repeatFrequency: RepeatFrequency.hourly, repeatValue: 1);
      expect(hourlyTask.repeatDescription, 'Every 1 hour');

      final dailyTask = baseTask.copyWith(repeatFrequency: RepeatFrequency.daily, repeatValue: 2);
      expect(dailyTask.repeatDescription, 'Every 2 days');

      final weeklyTask = baseTask.copyWith(repeatFrequency: RepeatFrequency.weekly, repeatValue: 1);
      expect(weeklyTask.repeatDescription, 'Every 1 week');

      final monthlyTask = baseTask.copyWith(
        repeatFrequency: RepeatFrequency.monthly,
        repeatValue: 3,
      );
      expect(monthlyTask.repeatDescription, 'Every 3 months');

      final yearlyTask = baseTask.copyWith(repeatFrequency: RepeatFrequency.yearly, repeatValue: 1);
      expect(yearlyTask.repeatDescription, 'Every 1 year');

      final noRepeatTask = baseTask.copyWith(repeatFrequency: RepeatFrequency.none);
      expect(noRepeatTask.repeatDescription, 'Does not repeat');

      final nullRepeatTask = baseTask;
      expect(nullRepeatTask.repeatDescription, 'Does not repeat');
    });

    test('timesPerDayDescription should return correct string', () {
      final task = Task(
        id: '1',
        title: 'Test Task',
        creationDate: currentDate,
        timesPerDay: 3,
        completedTimes: 1,
      );

      expect(task.timesPerDayDescription, '1/3 times completed');
    });

    test('timesPerDayDescription should return empty string for single-time tasks', () {
      final task = Task(
        id: '1',
        title: 'Test Task',
        creationDate: currentDate,
        timesPerDay: 1,
        completedTimes: 0,
      );

      expect(task.timesPerDayDescription, '');
    });

    test('completionProgress should return correct value', () {
      final task = Task(
        id: '1',
        title: 'Test Task',
        creationDate: currentDate,
        timesPerDay: 4,
        completedTimes: 1,
      );

      expect(task.completionProgress, 0.25);
    });

    test('completionProgress should return 1.0 for completed tasks', () {
      final task = Task(id: '1', title: 'Test Task', creationDate: currentDate, isCompleted: true);

      expect(task.completionProgress, 1.0);
    });

    test('completionProgress should return 0.0 for incomplete tasks', () {
      final task = Task(id: '1', title: 'Test Task', creationDate: currentDate, isCompleted: false);

      expect(task.completionProgress, 0.0);
    });
  });
}
