import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_tamer/src/blocs/creature/creature_bloc.dart';
import 'package:task_tamer/src/blocs/creature/creature_state.dart';
import 'package:task_tamer/src/blocs/task/task_bloc.dart';
import 'package:task_tamer/src/blocs/task/task_state.dart';
import 'package:task_tamer/src/blocs/user/user_bloc.dart';
import 'package:task_tamer/src/blocs/user/user_state.dart';
import 'package:task_tamer/src/ui/widgets/experience_bar.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserProfile(),
          const SizedBox(height: 24),
          _buildTaskSummary(),
          const SizedBox(height: 24),
          _buildCreatureSummary(),
        ],
      ),
    );
  }

  Widget _buildUserProfile() {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is UserLoaded || state is UserOperationSuccess) {
          final userProfile = state is UserLoaded
              ? state.userProfile
              : (state as UserOperationSuccess).userProfile;

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        child: userProfile.avatarPath != null
                            ? Image.asset(userProfile.avatarPath!)
                            : Text(
                                userProfile.name.isNotEmpty
                                    ? userProfile.name[0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(fontSize: 24),
                              ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userProfile.name,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            'Level ${userProfile.level}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ExperienceBar(
                    currentXP: userProfile.experiencePoints % 100,
                    maxXP: 100,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${userProfile.experiencePoints} XP total',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          );
        }

        return const Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTaskSummary() {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        if (state is TasksLoaded) {
          final tasks = state.tasks;
          final completedTasks = tasks.where((task) => task.isCompleted).length;
          final pendingTasks = tasks.length - completedTasks;

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Task Summary',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        context,
                        Icons.task_alt,
                        'Completed',
                        completedTasks.toString(),
                      ),
                      _buildStatItem(
                        context,
                        Icons.pending_actions,
                        'Pending',
                        pendingTasks.toString(),
                      ),
                      _buildStatItem(
                        context,
                        Icons.assignment,
                        'Total',
                        tasks.length.toString(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }

        return const Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCreatureSummary() {
    return BlocBuilder<CreatureBloc, CreatureState>(
      builder: (context, state) {
        if (state is CreaturesLoaded || state is UnlockedCreaturesLoaded) {
          final creatures = state is CreaturesLoaded
              ? state.creatures
              : (state as UnlockedCreaturesLoaded).creatures;

          final unlockedCreatures = creatures.where((c) => c.isUnlocked).length;

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Creatures',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        context,
                        Icons.pets,
                        'Unlocked',
                        unlockedCreatures.toString(),
                      ),
                      _buildStatItem(
                        context,
                        Icons.lock,
                        'Locked',
                        (creatures.length - unlockedCreatures).toString(),
                      ),
                      _buildStatItem(
                        context,
                        Icons.catching_pokemon,
                        'Total',
                        creatures.length.toString(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }

        return const Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Column(
      children: [
        Icon(icon, size: 32),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ],
    );
  }
}
