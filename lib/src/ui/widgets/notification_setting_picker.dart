import 'package:flutter/material.dart';
import 'package:task_tamer/src/models/notification_setting.dart';

class NotificationSettingPicker extends StatefulWidget {
  final Function(NotificationSetting) onSettingAdded;

  const NotificationSettingPicker({super.key, required this.onSettingAdded});

  @override
  State<NotificationSettingPicker> createState() => _NotificationSettingPickerState();
}

class _NotificationSettingPickerState extends State<NotificationSettingPicker> {
  int _value = 1;
  NotificationTimeUnit _timeUnit = NotificationTimeUnit.hours;
  bool _isBeforeDueDate = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Notification'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: '1',
                  decoration: const InputDecoration(
                    labelText: 'Value',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _value = int.tryParse(value) ?? 1;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<NotificationTimeUnit>(
                  decoration: const InputDecoration(
                    labelText: 'Unit',
                    border: OutlineInputBorder(),
                  ),
                  value: _timeUnit,
                  items: NotificationTimeUnit.values.map((unit) {
                    return DropdownMenuItem<NotificationTimeUnit>(
                      value: unit,
                      child: Text(_getTimeUnitText(unit)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _timeUnit = value;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<bool>(
                  decoration: const InputDecoration(
                    labelText: 'Timing',
                    border: OutlineInputBorder(),
                  ),
                  value: _isBeforeDueDate,
                  items: const [
                    DropdownMenuItem<bool>(value: true, child: Text('Before due date')),
                    DropdownMenuItem<bool>(value: false, child: Text('After due date')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _isBeforeDueDate = value;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Center(child: Text(_getPreviewText(), style: Theme.of(context).textTheme.bodySmall)),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            final setting = NotificationSetting(
              value: _value,
              timeUnit: _timeUnit,
              isBeforeDueDate: _isBeforeDueDate,
            );
            widget.onSettingAdded(setting);
            Navigator.pop(context);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }

  String _getTimeUnitText(NotificationTimeUnit unit) {
    switch (unit) {
      case NotificationTimeUnit.hours:
        return 'Hours';
      case NotificationTimeUnit.days:
        return 'Days';
      case NotificationTimeUnit.weeks:
        return 'Weeks';
      case NotificationTimeUnit.months:
        return 'Months';
      case NotificationTimeUnit.years:
        return 'Years';
    }
  }

  String _getPreviewText() {
    final setting = NotificationSetting(
      value: _value,
      timeUnit: _timeUnit,
      isBeforeDueDate: _isBeforeDueDate,
    );
    return 'Will notify you ${setting.description}';
  }
}
