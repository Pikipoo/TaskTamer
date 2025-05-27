import 'package:flutter/material.dart';
import 'package:task_tamer/src/models/creature.dart';
import 'package:task_tamer/src/ui/widgets/experience_bar.dart';

class CreatureCard extends StatelessWidget {
  final Creature creature;
  final bool isLocked;
  final Function()? onTap;
  final Function()? onAddXP;

  const CreatureCard({
    super.key,
    required this.creature,
    this.isLocked = false,
    this.onTap,
    this.onAddXP,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isLocked ? Colors.grey : creature.rarity.color, width: 2),
      ),
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: isLocked
                        ? Center(
                            child: Icon(
                              Icons.lock,
                              size: 64,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant.withOpacity(0.5),
                            ),
                          )
                        : Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(
                                creature.imagePath,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Icon(
                                      Icons.pets,
                                      size: 64,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant.withOpacity(0.5),
                                    ),
                                  );
                                },
                              ),
                              Positioned(
                                right: 8,
                                top: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: creature.rarity.color.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    creature.rarity.displayName,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              if (onAddXP != null && !isLocked)
                                Positioned(
                                  left: 8,
                                  bottom: 8,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.add, color: Colors.white),
                                      tooltip: 'Add XP',
                                      onPressed: onAddXP,
                                      iconSize: 18,
                                      padding: const EdgeInsets.all(4),
                                      constraints: const BoxConstraints(),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                isLocked ? '???' : creature.name,
                                style: Theme.of(
                                  context,
                                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (!isLocked)
                              Text(
                                'Lvl ${creature.level}',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isLocked ? 'Unknown Species' : creature.species,
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (!isLocked) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildInfoChip(
                                context,
                                label: creature.type.displayName,
                                icon: Icons.shield,
                              ),
                              const SizedBox(width: 4),
                              _buildInfoChip(
                                context,
                                label: creature.element.displayName,
                                icon: _getElementIcon(creature.element),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ExperienceBar(
                            currentXP: creature.experiencePoints,
                            maxXP: creature.experienceForNextLevel,
                          ),
                          if (creature.canEvolve)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Row(
                                children: [
                                  Icon(Icons.auto_awesome, size: 14, color: Colors.amber),
                                  const SizedBox(width: 2),
                                  Text(
                                    'Ready to evolve!',
                                    style: TextStyle(
                                      color: Colors.amber,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (isLocked) Positioned.fill(child: Container(color: Colors.black.withOpacity(0.3))),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, {required String label, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Theme.of(context).colorScheme.onPrimaryContainer),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getElementIcon(CreatureElement element) {
    switch (element) {
      case CreatureElement.FIRE:
        return Icons.local_fire_department;
      case CreatureElement.WATER:
        return Icons.water_drop;
      case CreatureElement.EARTH:
        return Icons.landscape;
      case CreatureElement.AIR:
        return Icons.air;
      case CreatureElement.LIGHT:
        return Icons.light_mode;
      case CreatureElement.DARK:
        return Icons.dark_mode;
    }
  }
}
