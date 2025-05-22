import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_tamer/src/blocs/task/task_bloc.dart';
import 'package:task_tamer/src/blocs/task/task_event.dart';
import 'package:task_tamer/src/blocs/task/task_state.dart';
import 'package:task_tamer/src/models/task.dart';
import 'package:task_tamer/src/ui/widgets/task_item.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        if (state is TasksLoaded) {
          if (state.tasks.isEmpty) {
            return const Center(
              child: Text('No tasks yet. Add one by tapping the + button.'),
            );
          }

          final completedTasks = state.tasks.where((task) => task.isCompleted).toList();
          final pendingTasks = state.tasks.where((task) => !task.isCompleted).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pending Tasks',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                if (pendingTasks.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: Text('No pending tasks. Great job!'),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: pendingTasks.length,
                    itemBuilder: (context, index) {
                      return TaskItem(
                        task: pendingTasks[index],
                        onComplete: () => _completeTask(context, pendingTasks[index]),
                        onDelete: () => _deleteTask(context, pendingTasks[index]),
                      );
                    },
                  ),
                const SizedBox(height: 24),
                Text(
                  'Completed Tasks',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                if (completedTasks.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: Text('No completed tasks yet.'),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: completedTasks.length,
                    itemBuilder: (context, index) {
                      return TaskItem(
                        task: completedTasks[index],
                        onComplete: () => _resetTask(context, completedTasks[index]),
                        onDelete: () => _deleteTask(context, completedTasks[index]),
                      );
                    },
                  ),
              ],
            ),
          );
        }

        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  void _completeTask(BuildContext context, Task task) {
    context.read<TaskBloc>().add(CompleteTask(task.id));
  }

  void _resetTask(BuildContext context, Task task) {
    context.read<TaskBloc>().add(ResetTaskCompletion(task.id));
  }

  void _deleteTask(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<TaskBloc>().add(DeleteTask(task.id));
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
