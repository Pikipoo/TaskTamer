import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_tamer/src/blocs/creature/creature_bloc.dart';
import 'package:task_tamer/src/blocs/creature/creature_state.dart';
import 'package:task_tamer/src/ui/widgets/creature_card.dart';

class CreaturesScreen extends StatelessWidget {
  const CreaturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreatureBloc, CreatureState>(
      builder: (context, state) {
        if (state is CreaturesLoaded || state is UnlockedCreaturesLoaded) {
          final creatures = state is CreaturesLoaded
              ? state.creatures
              : (state as UnlockedCreaturesLoaded).creatures;

          if (creatures.isEmpty) {
            return const Center(child: Text('No creatures yet. Complete tasks to unlock them!'));
          }

          final unlockedCreatures = creatures.where((c) => c.isUnlocked).toList();
          final lockedCreatures = creatures.where((c) => !c.isUnlocked).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your Creatures', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                if (unlockedCreatures.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: Text('No creatures unlocked yet. Complete tasks to unlock them!'),
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: unlockedCreatures.length,
                    itemBuilder: (context, index) {
                      return CreatureCard(creature: unlockedCreatures[index]);
                    },
                  ),
                const SizedBox(height: 24),
                Text('Locked Creatures', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                if (lockedCreatures.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(child: Text('You\'ve unlocked all creatures. Great job!')),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: lockedCreatures.length,
                    itemBuilder: (context, index) {
                      return CreatureCard(creature: lockedCreatures[index], isLocked: true);
                    },
                  ),
              ],
            ),
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
