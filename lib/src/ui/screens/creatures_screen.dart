import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_tamer/src/blocs/creature/creature_bloc.dart';
import 'package:task_tamer/src/blocs/creature/creature_state.dart';
import 'package:task_tamer/src/models/creature.dart';
import 'package:task_tamer/src/ui/widgets/creature_card.dart';

class CreaturesScreen extends StatefulWidget {
  const CreaturesScreen({super.key});

  @override
  State<CreaturesScreen> createState() => _CreaturesScreenState();
}

class _CreaturesScreenState extends State<CreaturesScreen> {
  // Store the ID of the most recently hatched creature to highlight it
  String? _newlyHatchedCreatureId;

  // Scroll controller to scroll to the newly hatched creature
  final ScrollController _scrollController = ScrollController();

  // Global keys for grid items to find their positions
  final Map<String, GlobalKey> _creatureKeys = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCreature(String creatureId) {
    // Wait for the layout to be complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final key = _creatureKeys[creatureId];
      if (key?.currentContext != null) {
        // Get the position of the creature card
        final RenderBox box = key!.currentContext!.findRenderObject() as RenderBox;
        final position = box.localToGlobal(Offset.zero);

        // Scroll to position with some padding
        _scrollController.animateTo(
          position.dy - 120, // Subtract some padding to show above the card
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreatureBloc, CreatureState>(
      listener: (context, state) {
        // Listen for new creatures and update the newly hatched creature ID
        if (state is CreaturesLoaded && state.newlyHatchedCreatureId != null) {
          setState(() {
            _newlyHatchedCreatureId = state.newlyHatchedCreatureId;
          });

          // Scroll to the newly hatched creature
          if (_newlyHatchedCreatureId != null) {
            _scrollToCreature(_newlyHatchedCreatureId!);
          }
        } else if (state is UnlockedCreaturesLoaded && state.newlyHatchedCreatureId != null) {
          setState(() {
            _newlyHatchedCreatureId = state.newlyHatchedCreatureId;
          });

          // Scroll to the newly hatched creature
          if (_newlyHatchedCreatureId != null) {
            _scrollToCreature(_newlyHatchedCreatureId!);
          }
        } else if (state is CreatureOperationSuccess &&
            state.isNewlyHatched &&
            state.creature != null) {
          setState(() {
            _newlyHatchedCreatureId = state.creature!.id;
          });
        }
      },
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

          // Find the newly hatched creature index if it exists
          final newlyHatchedIndex = unlockedCreatures.indexWhere(
            (creature) => creature.id == _newlyHatchedCreatureId,
          );

          // Reset creature keys for the current set of creatures
          _creatureKeys.clear();

          // Create keys for each creature
          for (final creature in unlockedCreatures) {
            _creatureKeys[creature.id] = GlobalKey();
          }

          return SingleChildScrollView(
            controller: _scrollController,
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
                      final creature = unlockedCreatures[index];
                      final isNewlyHatched = creature.id == _newlyHatchedCreatureId;

                      // If this is the newly hatched creature, wrap it with a highlight
                      if (isNewlyHatched) {
                        return KeyedSubtree(
                          key: _creatureKeys[creature.id],
                          child: _buildHighlightedCreatureCard(creature),
                        );
                      }

                      return CreatureCard(creature: creature);
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

  Widget _buildHighlightedCreatureCard(Creature creature) {
    // Clear the newly hatched ID after a short delay to remove the highlight effect
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _newlyHatchedCreatureId = null;
        });
      }
    });

    return Stack(
      children: [
        CreatureCard(creature: creature),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber, width: 3),
              boxShadow: [
                BoxShadow(color: Colors.amber.withOpacity(0.5), blurRadius: 12, spreadRadius: 2),
              ],
            ),
          ),
        ),
        Positioned(
          top: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.auto_awesome, size: 14, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  'NEW!',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
