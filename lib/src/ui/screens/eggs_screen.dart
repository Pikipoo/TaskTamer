import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_tamer/src/blocs/egg/egg_bloc.dart';
import 'package:task_tamer/src/blocs/egg/egg_event.dart';
import 'package:task_tamer/src/blocs/egg/egg_state.dart';
import 'package:task_tamer/src/models/egg.dart';
import 'package:task_tamer/src/ui/widgets/egg_card.dart';

class EggsScreen extends StatelessWidget {
  const EggsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EggBloc, EggState>(
      builder: (context, state) {
        if (state is EggsLoaded || state is UnhatchedEggsLoaded) {
          final eggs = state is EggsLoaded ? state.eggs : (state as UnhatchedEggsLoaded).eggs;

          // Filter out hatched eggs
          final unhatchedEggs = eggs.where((egg) => !egg.isHatched).toList();

          // Group eggs by whether they're ready to hatch
          final readyToHatchEggs = unhatchedEggs.where((egg) => egg.canHatch).toList();
          final growingEggs = unhatchedEggs.where((egg) => !egg.canHatch).toList();

          if (unhatchedEggs.isEmpty) {
            return const Center(
              child: Text('No eggs available. Complete tasks to earn more eggs!'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (readyToHatchEggs.isNotEmpty) ...[
                  Text(
                    'Ready to Hatch',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Tap on an egg to hatch it!', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: readyToHatchEggs.length,
                    itemBuilder: (context, index) {
                      return EggCard(
                        egg: readyToHatchEggs[index],
                        onTap: () => _hatchEgg(context, readyToHatchEggs[index]),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
                if (growingEggs.isNotEmpty) ...[
                  Text('Growing Eggs', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    'Feed eggs with XP to help them grow',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: growingEggs.length,
                    itemBuilder: (context, index) {
                      return EggCard(
                        egg: growingEggs[index],
                        onTap: () => _showAddXPDialog(context, growingEggs[index]),
                      );
                    },
                  ),
                ],
              ],
            ),
          );
        }

        if (state is EggOperationSuccess) {
          // Reload eggs after a successful operation
          context.read<EggBloc>().add(const LoadEggs());

          // Show a snackbar with the success message
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), behavior: SnackBarBehavior.floating),
            );
          });

          return const Center(child: CircularProgressIndicator());
        }

        if (state is EggHatchSuccess) {
          // Reload eggs after a successful hatch
          context.read<EggBloc>().add(const LoadEggs());

          // Show a snackbar with the success message
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 5),
              ),
            );
          });

          return const Center(child: CircularProgressIndicator());
        }

        if (state is EggOperationFailure) {
          // Show a snackbar with the error message
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.red,
              ),
            );
          });

          // Reload eggs after error
          context.read<EggBloc>().add(const LoadEggs());
          return const Center(child: CircularProgressIndicator());
        }

        // Initial load or loading state
        context.read<EggBloc>().add(const LoadEggs());
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  void _hatchEgg(BuildContext context, Egg egg) {
    context.read<EggBloc>().add(HatchEgg(egg.id));
  }

  void _showAddXPDialog(BuildContext context, Egg egg) {
    final remainingXP = egg.experienceRequired - egg.experiencePoints;

    // Define initial XP value for the slider
    double selectedXP = 1.0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add XP to Egg'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('This egg needs $remainingXP more XP to hatch.'),
              const SizedBox(height: 16),

              // Label showing the selected XP value
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Selected XP:', style: Theme.of(context).textTheme.bodyMedium),
                  Text(
                    '${selectedXP.round()}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // XP Slider
              Slider(
                value: selectedXP,
                min: 1,
                max: remainingXP.toDouble(),
                divisions: remainingXP > 20
                    ? 20
                    : remainingXP.toInt(), // Limit divisions for smoother sliding
                label: selectedXP.round().toString(),
                onChanged: (value) {
                  setState(() {
                    selectedXP = value;
                  });
                },
              ),

              // Progress visualization
              LinearProgressIndicator(
                value: (egg.experiencePoints + selectedXP.round()) / egg.experienceRequired,
                minHeight: 8,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  (egg.experiencePoints + selectedXP.round() >= egg.experienceRequired)
                      ? Colors.green
                      : Theme.of(context).colorScheme.primary,
                ),
              ),

              const SizedBox(height: 8),
              Text(
                'Progress: ${egg.experiencePoints} + ${selectedXP.round()} = ${(egg.experiencePoints + selectedXP.round())} / ${egg.experienceRequired}',
                style: Theme.of(context).textTheme.bodySmall,
              ),

              if (egg.experiencePoints + selectedXP.round() >= egg.experienceRequired)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Egg will be ready to hatch!',
                        style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final xpAmount = selectedXP.round();
                if (xpAmount > 0) {
                  context.read<EggBloc>().add(
                    AddEggExperiencePoints(eggId: egg.id, points: xpAmount),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Add XP'),
            ),
          ],
        ),
      ),
    );
  }
}
