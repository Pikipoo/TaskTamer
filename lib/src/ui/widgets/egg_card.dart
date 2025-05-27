import 'package:flutter/material.dart';
import 'package:task_tamer/src/models/egg.dart';
import 'package:task_tamer/src/ui/widgets/experience_bar.dart';

class EggCard extends StatelessWidget {
  final Egg egg;
  final Function()? onTap;

  const EggCard({super.key, required this.egg, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: egg.rarity.color, width: 2),
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
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Center(child: _buildEggIcon()),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: egg.rarity.color.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              egg.rarity.displayName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Mystery Egg',
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getEggDescription(),
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        ExperienceBar(
                          currentXP: egg.experiencePoints,
                          maxXP: egg.experienceRequired,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (egg.canHatch)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.transparent,
                        Colors.yellow.withOpacity(0.2),
                        Colors.yellow.withOpacity(0.3),
                      ],
                    ),
                  ),
                ),
              ),
            if (egg.canHatch)
              Positioned(
                left: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
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
                    children: [
                      const Icon(Icons.egg_alt, size: 16, color: Colors.white),
                      const SizedBox(width: 4),
                      const Text(
                        'READY!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEggIcon() {
    // The icon size is proportional to how close the egg is to hatching
    final progress = egg.experiencePoints / egg.experienceRequired;
    final minSize = 64.0;
    final maxSize = 96.0;
    final size = minSize + ((maxSize - minSize) * progress);

    final iconColor = egg.canHatch ? Colors.amber : egg.rarity.color.withOpacity(0.7);

    return Icon(Icons.egg_outlined, size: size, color: iconColor);
  }

  String _getEggDescription() {
    if (egg.canHatch) {
      return 'This egg is ready to hatch! Tap to hatch it.';
    } else {
      final remainingXP = egg.experienceRequired - egg.experiencePoints;
      return 'Needs $remainingXP more XP to hatch.';
    }
  }
}
