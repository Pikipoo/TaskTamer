import 'package:flutter/material.dart';

class ExperienceBar extends StatelessWidget {
  final int currentXP;
  final int maxXP;

  const ExperienceBar({
    super.key,
    required this.currentXP,
    required this.maxXP,
  });

  @override
  Widget build(BuildContext context) {
    final progress = currentXP / maxXP;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'XP Progress',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              '$currentXP / $maxXP',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 12,
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}
