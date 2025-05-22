import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_tamer/src/blocs/task/task_bloc.dart';
import 'package:task_tamer/src/blocs/task/task_event.dart';
import 'package:task_tamer/src/models/task.dart';

class TaskForm extends StatefulWidget {
  final Task? task;

  const TaskForm({
    super.key,
    this.task,
  });

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  RepeatFrequency? _repeatFrequency = RepeatFrequency.none;
  int? _repeatValue = 1;
  int? _timesPerDay = 1;
  final List<DateTime> _notificationTimes = [];

  @override
  void initState() {
    super.initState();

    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description ?? '';
      _dueDate = widget.task!.dueDate;
      _dueTime = widget.task!.dueDate != null
          ? TimeOfDay.fromDateTime(widget.task!.dueDate!)
          : null;
      _repeatFrequency = widget.task!.repeatFrequency ?? RepeatFrequency.none;
      _repeatValue = widget.task!.repeatValue ?? 1;
      _timesPerDay = widget.task!.timesPerDay ?? 1;

      if (widget.task!.notificationTimes != null) {
        _notificationTimes.addAll(widget.task!.notificationTimes!);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.task == null ? 'Add Task' : 'Edit Task',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDueDate(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Due Date',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _dueDate == null
                            ? 'No due date'
                            : '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: _dueDate == null ? null : () => _selectDueTime(context),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Due Time',
                        border: const OutlineInputBorder(),
                        enabled: _dueDate != null,
                      ),
                      child: Text(
                        _dueTime == null
                            ? 'No time'
                            : '${_dueTime!.hour}:${_dueTime!.minute.toString().padLeft(2, '0')}',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<RepeatFrequency>(
                    decoration: const InputDecoration(
                      labelText: 'Repeat',
                      border: OutlineInputBorder(),
                    ),
                    value: _repeatFrequency,
                    items: RepeatFrequency.values.map((frequency) {
                      return DropdownMenuItem<RepeatFrequency>(
                        value: frequency,
                        child: Text(_getRepeatFrequencyText(frequency)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _repeatFrequency = value;
                      });
                    },
                  ),
                ),
                if (_repeatFrequency != RepeatFrequency.none) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      initialValue: _repeatValue?.toString() ?? '1',
                      decoration: InputDecoration(
                        labelText: 'Every ${_getRepeatFrequencyUnit()}',
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          _repeatValue = int.tryParse(value) ?? 1;
                        });
                      },
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _timesPerDay?.toString() ?? '1',
                    decoration: const InputDecoration(
                      labelText: 'Times per day',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _timesPerDay = int.tryParse(value) ?? 1;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _addNotification(context),
                    icon: const Icon(Icons.notifications),
                    label: const Text('Add Notification'),
                  ),
                ),
              ],
            ),
            if (_notificationTimes.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('Notifications:'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _notificationTimes.map((time) {
                  return Chip(
                    label: Text(
                      '${time.day}/${time.month} ${time.hour}:${time.minute.toString().padLeft(2, '0')}',
                    ),
                    onDeleted: () {
                      setState(() {
                        _notificationTimes.remove(time);
                      });
                    },
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _saveTask,
                  child: Text(widget.task == null ? 'Add' : 'Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getRepeatFrequencyText(RepeatFrequency frequency) {
    switch (frequency) {
      case RepeatFrequency.none:
        return 'Does not repeat';
      case RepeatFrequency.hourly:
        return 'Hourly';
      case RepeatFrequency.daily:
        return 'Daily';
      case RepeatFrequency.weekly:
        return 'Weekly';
      case RepeatFrequency.monthly:
        return 'Monthly';
      case RepeatFrequency.yearly:
        return 'Yearly';
    }
  }

  String _getRepeatFrequencyUnit() {
    switch (_repeatFrequency) {
      case RepeatFrequency.hourly:
        return 'hours';
      case RepeatFrequency.daily:
        return 'days';
      case RepeatFrequency.weekly:
        return 'weeks';
      case RepeatFrequency.monthly:
        return 'months';
      case RepeatFrequency.yearly:
        return 'years';
      case RepeatFrequency.none:
      default:
        return '';
    }
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final initialDate = _dueDate ?? DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (pickedDate != null && pickedDate != _dueDate) {
      setState(() {
        _dueDate = pickedDate;
      });
    }
  }

  Future<void> _selectDueTime(BuildContext context) async {
    final initialTime = _dueTime ?? TimeOfDay.now();
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime != null && pickedTime != _dueTime) {
      setState(() {
        _dueTime = pickedTime;
      });
    }
  }

  Future<void> _addNotification(BuildContext context) async {
    final initialDate = _dueDate ?? DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (pickedDate != null) {
      final initialTime = TimeOfDay.now();
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: initialTime,
      );

      if (pickedTime != null) {
        setState(() {
          final notificationTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          _notificationTimes.add(notificationTime);
        });
      }
    }
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final DateTime? combinedDueDateTime = _dueDate == null
          ? null
          : _dueTime == null
              ? _dueDate
              : DateTime(
                  _dueDate!.year,
                  _dueDate!.month,
                  _dueDate!.day,
                  _dueTime!.hour,
                  _dueTime!.minute,
                );

      if (widget.task == null) {
        // Create new task
        context.read<TaskBloc>().add(
              AddTask(
                title: _titleController.text,
                description: _descriptionController.text.isEmpty
                    ? null
                    : _descriptionController.text,
                dueDate: combinedDueDateTime,
                repeatFrequency: _repeatFrequency == RepeatFrequency.none
                    ? null
                    : _repeatFrequency,
                repeatValue:
                    _repeatFrequency == RepeatFrequency.none ? null : _repeatValue,
                timesPerDay: _timesPerDay == 1 ? null : _timesPerDay,
                notificationTimes:
                    _notificationTimes.isEmpty ? null : _notificationTimes,
              ),
            );
      } else {
        // Update existing task
        context.read<TaskBloc>().add(
              UpdateTask(
                widget.task!.copyWith(
                  title: _titleController.text,
                  description: _descriptionController.text.isEmpty
                      ? null
                      : _descriptionController.text,
                  dueDate: combinedDueDateTime,
                  repeatFrequency: _repeatFrequency == RepeatFrequency.none
                      ? null
                      : _repeatFrequency,
                  repeatValue:
                      _repeatFrequency == RepeatFrequency.none ? null : _repeatValue,
                  timesPerDay: _timesPerDay == 1 ? null : _timesPerDay,
                  notificationTimes:
                      _notificationTimes.isEmpty ? null : _notificationTimes,
                ),
              ),
            );
      }

      Navigator.pop(context);
    }
  }
}
