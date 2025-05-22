import 'package:flutter/material.dart';
import '../models/task.dart';
import 'dart:math';
import '../services/notification_service.dart';

class TasksScreen extends StatefulWidget {
  final List<Task> tasks;
  final void Function(Task) onAddTask;
  final void Function(String) onDeleteTask;
  final void Function(int) onXpEarned;
  const TasksScreen({Key? key, required this.onXpEarned, required this.tasks, required this.onAddTask, required this.onDeleteTask}) : super(key: key);

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  void _completeTask(Task task) {
    setState(() {
      task.complete();
      if (task.isCompleted) {
        widget.onXpEarned(task.xpReward);
      }
    });
  }

  void _showAddTaskDialog() {
    final _formKey = GlobalKey<FormState>();
    String title = '';
    String? description;
    DateTime? dueDate;
    RepeatUnit repeatUnit = RepeatUnit.none;
    int? repeatInterval;
    int timesPerDay = 1;
    int xpReward = 10;
    TimeOfDay? dueTime;
    List<Map<String, dynamic>> relativeNotifications = [];
    int notifValue = 1;
    String notifUnit = 'hour';
    final notifUnits = ['minute', 'hour', 'day', 'week'];

    void addRelativeNotification() {
      if (notifValue > 0 && notifUnits.contains(notifUnit)) {
        setState(() {
          relativeNotifications.add({'value': notifValue, 'unit': notifUnit});
        });
      }
    }
    void removeRelativeNotification(int idx) {
      setState(() {
        relativeNotifications.removeAt(idx);
      });
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Task'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Title *'),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Title required' : null,
                    onChanged: (value) => title = value,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Description'),
                    onChanged: (value) => description = value,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(dueDate == null ? 'No due date' : 'Due: \\${dueDate!.toLocal().toString().split(' ')[0]}'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() {
                              dueDate = picked;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(dueTime == null ? 'No due time' : 'Time: \\${dueTime!.format(context)}'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.access_time),
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (picked != null) {
                            setState(() {
                              dueTime = picked;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  DropdownButtonFormField<RepeatUnit>(
                    value: repeatUnit,
                    decoration: const InputDecoration(labelText: 'Repeat'),
                    items: RepeatUnit.values.map((unit) {
                      return DropdownMenuItem(
                        value: unit,
                        child: Text(unit == RepeatUnit.none ? 'Does not repeat' : unit.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        repeatUnit = value!;
                        if (repeatUnit == RepeatUnit.none) repeatInterval = null;
                      });
                    },
                  ),
                  if (repeatUnit != RepeatUnit.none)
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Repeat every ... (${repeatUnit.name}${repeatUnit == RepeatUnit.hour ? '' : 's'})'),
                      initialValue: '1',
                      keyboardType: TextInputType.number,
                      onChanged: (value) => repeatInterval = int.tryParse(value) ?? 1,
                    ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Times per Day'),
                    initialValue: '1',
                    keyboardType: TextInputType.number,
                    onChanged: (value) => timesPerDay = int.tryParse(value) ?? 1,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'XP Reward'),
                    initialValue: '10',
                    keyboardType: TextInputType.number,
                    onChanged: (value) => xpReward = int.tryParse(value) ?? 10,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Notifications:'),
                      SizedBox(width: 8),
                      SizedBox(
                        width: 60,
                        child: TextFormField(
                          initialValue: notifValue.toString(),
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: 'Value'),
                          onChanged: (v) => notifValue = int.tryParse(v) ?? 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: notifUnit,
                        items: notifUnits.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => notifUnit = v);
                        },
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: addRelativeNotification,
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                  for (int i = 0; i < relativeNotifications.length; i++)
                    ListTile(
                      dense: true,
                      title: Text('Notify ${relativeNotifications[i]['value']} ${relativeNotifications[i]['unit']}${relativeNotifications[i]['value'] == 1 ? '' : 's'} before due'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => removeRelativeNotification(i),
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  DateTime? fullDueDate;
                  if (dueDate != null) {
                    if (dueTime != null) {
                      fullDueDate = DateTime(
                        dueDate!.year,
                        dueDate!.month,
                        dueDate!.day,
                        dueTime!.hour,
                        dueTime!.minute,
                      );
                    } else {
                      fullDueDate = dueDate;
                    }
                  }
                  // Calculate notification times based on due date and relativeNotifications
                  List<DateTime> notifications = [];
                  if (fullDueDate != null) {
                    for (final notif in relativeNotifications) {
                      final int value = (notif['value'] as int);
                      Duration offset;
                      switch (notif['unit']) {
                        case 'minute':
                          offset = Duration(minutes: value);
                          break;
                        case 'hour':
                          offset = Duration(hours: value);
                          break;
                        case 'day':
                          offset = Duration(days: value);
                          break;
                        case 'week':
                          offset = Duration(days: 7 * value);
                          break;
                        default:
                          offset = Duration(hours: value);
                      }
                      final scheduled = fullDueDate.subtract(offset);
                      notifications.add(scheduled);
                    }
                  }
                  final newTask = Task(
                    id: Random().nextDouble().toString(),
                    title: title.trim(),
                    description: description,
                    dueDate: fullDueDate,
                    repeatUnit: repeatUnit,
                    repeatInterval: repeatInterval,
                    timesPerDay: timesPerDay,
                    xpReward: xpReward,
                    notifications: notifications,
                  );
                  // Schedule notifications
                  for (int i = 0; i < notifications.length; i++) {
                    NotificationService().scheduleNotification(
                      id: newTask.id.hashCode + i,
                      title: newTask.title,
                      body: 'Task "${newTask.title}" is due soon!',
                      scheduledDate: notifications[i],
                    );
                  }
                  widget.onAddTask(newTask);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditTaskDialog(Task task) {
    final _formKey = GlobalKey<FormState>();
    String title = task.title;
    String? description = task.description;
    DateTime? dueDate = task.dueDate;
    RepeatUnit repeatUnit = task.repeatUnit;
    int? repeatInterval = task.repeatInterval;
    int timesPerDay = task.timesPerDay;
    int xpReward = task.xpReward;
    TimeOfDay? dueTime = task.dueDate != null ? TimeOfDay(hour: task.dueDate!.hour, minute: task.dueDate!.minute) : null;
    List<Map<String, dynamic>> relativeNotifications = [];
    // Reconstruct relative notifications is not trivial, so just show the absolute times for now
    int notifValue = 1;
    String notifUnit = 'hour';
    final notifUnits = ['minute', 'hour', 'day', 'week'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Task'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: title,
                    decoration: const InputDecoration(labelText: 'Title *'),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Title required' : null,
                    onChanged: (value) => title = value,
                  ),
                  TextFormField(
                    initialValue: description,
                    decoration: const InputDecoration(labelText: 'Description'),
                    onChanged: (value) => description = value,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(dueDate == null ? 'No due date' : 'Due: \\${dueDate!.toLocal().toString().split(' ')[0]}'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: dueDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() {
                              dueDate = picked;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(dueTime == null ? 'No due time' : 'Time: \\${dueTime!.format(context)}'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.access_time),
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: dueTime ?? TimeOfDay.now(),
                          );
                          if (picked != null) {
                            setState(() {
                              dueTime = picked;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  DropdownButtonFormField<RepeatUnit>(
                    value: repeatUnit,
                    decoration: const InputDecoration(labelText: 'Repeat'),
                    items: RepeatUnit.values.map((unit) {
                      return DropdownMenuItem(
                        value: unit,
                        child: Text(unit == RepeatUnit.none ? 'Does not repeat' : unit.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        repeatUnit = value!;
                        if (repeatUnit == RepeatUnit.none) repeatInterval = null;
                      });
                    },
                  ),
                  if (repeatUnit != RepeatUnit.none)
                    TextFormField(
                      initialValue: repeatInterval?.toString() ?? '1',
                      decoration: InputDecoration(labelText: 'Repeat every ... (${repeatUnit.name}${repeatUnit == RepeatUnit.hour ? '' : 's'})'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => repeatInterval = int.tryParse(value) ?? 1,
                    ),
                  TextFormField(
                    initialValue: timesPerDay.toString(),
                    decoration: const InputDecoration(labelText: 'Times per Day'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => timesPerDay = int.tryParse(value) ?? 1,
                  ),
                  TextFormField(
                    initialValue: xpReward.toString(),
                    decoration: const InputDecoration(labelText: 'XP Reward'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => xpReward = int.tryParse(value) ?? 10,
                  ),
                  const SizedBox(height: 12),
                  // For now, just show the existing notification times
                  if (task.notifications.isNotEmpty)
                    ...task.notifications.map((dt) => ListTile(
                          dense: true,
                          title: Text('🔔 Notification: \\${dt}'),
                        )),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  DateTime? fullDueDate;
                  if (dueDate != null) {
                    if (dueTime != null) {
                      fullDueDate = DateTime(
                        dueDate!.year,
                        dueDate!.month,
                        dueDate!.day,
                        dueTime!.hour,
                        dueTime!.minute,
                      );
                    } else {
                      fullDueDate = dueDate;
                    }
                  }
                  setState(() {
                    task
                      ..title = title.trim()
                      ..description = description
                      ..dueDate = fullDueDate
                      ..repeatUnit = repeatUnit
                      ..repeatInterval = repeatInterval
                      ..timesPerDay = timesPerDay
                      ..xpReward = xpReward;
                  });
                  widget.onAddTask(task); // This will update and persist
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
      ),
      body: widget.tasks.isEmpty
          ? const Center(child: Text('No tasks yet. Add one!'))
          : ListView.builder(
              itemCount: widget.tasks.length,
              itemBuilder: (context, index) {
                final task = widget.tasks[index];
                return ListTile(
                  onTap: () => _showEditTaskDialog(task),
                  leading: Checkbox(
                    value: task.isCompleted,
                    onChanged: (_) => _completeTask(task),
                  ),
                  title: Text(
                    task.title,
                    style: TextStyle(
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (task.description != null && task.description!.isNotEmpty)
                        Text(task.description!),
                      Text('XP: ${task.xpReward}'),
                      if (task.dueDate != null)
                        Text('Due: ${task.dueDate}'),
                      if (task.repeatUnit != RepeatUnit.none && task.repeatInterval != null)
                        Text('Repeats every ${task.repeatInterval} ${task.repeatUnit.name}${task.repeatInterval == 1 ? '' : 's'}'),
                      if (task.timesPerDay > 1)
                        Row(
                          children: [
                            Expanded(
                              child: LinearProgressIndicator(
                                value: task.progress,
                                minHeight: 6,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${task.timesCompletedToday}/${task.timesPerDay}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      if (task.notifications.isNotEmpty)
                        ...task.notifications.map((dt) => Text('🔔 Notification: $dt')).toList(),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => widget.onDeleteTask(task.id),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
        tooltip: 'Add Task',
      ),
    );
  }
}
