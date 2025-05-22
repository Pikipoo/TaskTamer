import 'package:flutter/material.dart';
import 'package:task_tamer/src/models/task.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onComplete;
  final VoidCallback onDelete;

  const TaskItem({
    super.key,
    required this.task,
    required this.onComplete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        leading: _buildLeadingIcon(context),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            fontWeight: task.isCompleted ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description != null && task.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  task.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (task.dueDate != null)
                  _buildInfoChip(
                    context,
                    Icons.event,
                    task.getFormattedDueDate(),
                    task.isOverdue() ? Colors.red : null,
                  ),
                if (task.repeatFrequency != null && task.repeatFrequency != RepeatFrequency.none)
                  _buildInfoChip(
                    context,
                    Icons.repeat,
                    task.repeatDescription,
                  ),
                if (task.timesPerDay != null && task.timesPerDay! > 1)
                  _buildInfoChip(
                    context,
                    Icons.check_circle_outline,
                    task.timesPerDayDescription,
                  ),
              ],
            ),
            if (task.timesPerDay != null && task.timesPerDay! > 1)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: LinearProgressIndicator(
                  value: task.completionProgress,
                  minHeight: 8,
                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: onDelete,
        ),
      ),
    );
  }

  Widget _buildLeadingIcon(BuildContext context) {
    return InkWell(
      onTap: onComplete,
      customBorder: const CircleBorder(),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: task.isCompleted
              ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
              : Colors.transparent,
          border: Border.all(
            color: task.isCompleted
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
            width: 2,
          ),
        ),
        child: task.isCompleted
            ? Icon(
                Icons.check,
                color: Theme.of(context).colorScheme.primary,
              )
            : null,
      ),
    );
  }

  Widget _buildInfoChip(
    BuildContext context,
    IconData icon,
    String label, [
    Color? color,
  ]) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Chip(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        labelPadding: const EdgeInsets.symmetric(horizontal: 4.0),
        avatar: Icon(
          icon,
          size: 16,
          color: color ?? Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color ?? Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
