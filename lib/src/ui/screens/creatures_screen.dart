import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_tamer/src/blocs/creature/creature_bloc.dart';
import 'package:task_tamer/src/blocs/creature/creature_event.dart';
import 'package:task_tamer/src/blocs/creature/creature_state.dart';
import 'package:task_tamer/src/blocs/user/user_bloc.dart';
import 'package:task_tamer/src/blocs/user/user_event.dart';
import 'package:task_tamer/src/blocs/user/user_state.dart';
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

  void _showAddXPDialog(BuildContext context, Creature creature) {
    // Get current user state to check available XP
    final userState = context.read<UserBloc>().state;
    if (userState is! UserLoaded) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cannot load user profile')));
      return;
    }

    final availableXP = userState.userProfile.availableExperiencePoints;
    if (availableXP <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No XP available. Complete tasks to earn more!')),
      );
      return;
    }

    // Calculate max XP to add - either available XP or what's needed for next level
    final xpForNextLevel = creature.experienceForNextLevel;
    final maxXP = availableXP < xpForNextLevel ? availableXP : xpForNextLevel;

    // Define initial XP value
    double selectedXP = 1.0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Add XP to ${creature.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('You have $availableXP XP available to use.'),
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
                max: maxXP.toDouble(),
                divisions: maxXP > 20 ? 20 : maxXP.toInt(), // Limit divisions for smoother sliding
                label: selectedXP.round().toString(),
                onChanged: (value) {
                  setState(() {
                    selectedXP = value;
                  });
                },
              ),

              // Progress visualization
              LinearProgressIndicator(
                value: (creature.experiencePoints + selectedXP.round()) / xpForNextLevel,
                minHeight: 8,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  (creature.experiencePoints + selectedXP.round() >= xpForNextLevel)
                      ? Colors.green
                      : Theme.of(context).colorScheme.primary,
                ),
              ),

              const SizedBox(height: 8),
              Text(
                'Progress: ${creature.experiencePoints} + ${selectedXP.round()} = ${(creature.experiencePoints + selectedXP.round())} / $xpForNextLevel',
                style: Theme.of(context).textTheme.bodySmall,
              ),

              if (creature.experiencePoints + selectedXP.round() >= xpForNextLevel)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Will level up to ${creature.level + 1}!',
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
                  // Add XP to creature
                  context.read<CreatureBloc>().add(
                    AddCreatureExperiencePoints(creatureId: creature.id, points: xpAmount),
                  );

                  // Deduct XP from user's available XP
                  context.read<UserBloc>().add(UseAvailableExperiencePoints(xpAmount));

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

          // Get user state to check if we have available XP
          final userState = context.watch<UserBloc>().state;
          final hasAvailableXP =
              userState is UserLoaded && userState.userProfile.availableExperiencePoints > 0;

          return SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasAvailableXP)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Card(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'You have ${(userState).userProfile.availableExperiencePoints} XP available. Tap the + button on any creature to use it!',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
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
                          child: _buildHighlightedCreatureCard(
                            creature,
                            hasAvailableXP: hasAvailableXP,
                          ),
                        );
                      }

                      return CreatureCard(
                        creature: creature,
                        onAddXP: hasAvailableXP ? () => _showAddXPDialog(context, creature) : null,
                      );
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

  Widget _buildHighlightedCreatureCard(Creature creature, {bool hasAvailableXP = false}) {
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
        CreatureCard(
          creature: creature,
          onAddXP: hasAvailableXP ? () => _showAddXPDialog(context, creature) : null,
        ),
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
