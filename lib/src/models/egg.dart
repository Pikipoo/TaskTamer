import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:task_tamer/src/models/creature.dart';

/// Represents an egg that can hatch into a creature
@immutable
class Egg extends Equatable {
  final String id;
  final CreatureRarity rarity;
  final int experiencePoints;
  final int experienceRequired;
  final bool isHatched;

  /// Default amount of experience needed to hatch an egg
  static const int DEFAULT_HATCH_XP = 10;

  const Egg({
    required this.id,
    required this.rarity,
    this.experiencePoints = 0,
    this.experienceRequired = DEFAULT_HATCH_XP,
    this.isHatched = false,
  });

  Egg copyWith({
    String? id,
    CreatureRarity? rarity,
    int? experiencePoints,
    int? experienceRequired,
    bool? isHatched,
  }) {
    return Egg(
      id: id ?? this.id,
      rarity: rarity ?? this.rarity,
      experiencePoints: experiencePoints ?? this.experiencePoints,
      experienceRequired: experienceRequired ?? this.experienceRequired,
      isHatched: isHatched ?? this.isHatched,
    );
  }

  /// Check if the egg has enough experience to hatch
  bool get canHatch => experiencePoints >= experienceRequired;

  /// Add experience points to the egg
  Egg addExperiencePoints(int points) {
    final newExperiencePoints = experiencePoints + points;
    return copyWith(experiencePoints: newExperiencePoints);
  }

  /// Hatch the egg and mark it as hatched
  Egg hatch() {
    if (!canHatch) {
      return this;
    }
    return copyWith(isHatched: true);
  }

  @override
  List<Object?> get props => [id, rarity, experiencePoints, experienceRequired, isHatched];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rarity': rarity.index,
      'experiencePoints': experiencePoints,
      'experienceRequired': experienceRequired,
      'isHatched': isHatched,
    };
  }

  factory Egg.fromJson(Map<String, dynamic> json) {
    return Egg(
      id: json['id'],
      rarity: json['rarity'] != null
          ? CreatureRarity.values[json['rarity']]
          : CreatureRarity.COMMON,
      experiencePoints: json['experiencePoints'] ?? 0,
      experienceRequired: json['experienceRequired'] ?? DEFAULT_HATCH_XP,
      isHatched: json['isHatched'] ?? false,
    );
  }

  /// Calculate the probability distribution for hatching creatures of different rarities
  /// The higher the egg's rarity, the higher the chance of hatching rarer creatures
  Map<CreatureRarity, double> getRarityProbabilities() {
    switch (rarity) {
      case CreatureRarity.COMMON:
        return {
          CreatureRarity.COMMON: 0.80,
          CreatureRarity.UNCOMMON: 0.15,
          CreatureRarity.RARE: 0.04,
          CreatureRarity.EPIC: 0.01,
          CreatureRarity.LEGENDARY: 0.00,
        };
      case CreatureRarity.UNCOMMON:
        return {
          CreatureRarity.COMMON: 0.60,
          CreatureRarity.UNCOMMON: 0.25,
          CreatureRarity.RARE: 0.10,
          CreatureRarity.EPIC: 0.05,
          CreatureRarity.LEGENDARY: 0.00,
        };
      case CreatureRarity.RARE:
        return {
          CreatureRarity.COMMON: 0.35,
          CreatureRarity.UNCOMMON: 0.35,
          CreatureRarity.RARE: 0.20,
          CreatureRarity.EPIC: 0.09,
          CreatureRarity.LEGENDARY: 0.01,
        };
      case CreatureRarity.EPIC:
        return {
          CreatureRarity.COMMON: 0.15,
          CreatureRarity.UNCOMMON: 0.25,
          CreatureRarity.RARE: 0.35,
          CreatureRarity.EPIC: 0.20,
          CreatureRarity.LEGENDARY: 0.05,
        };
      case CreatureRarity.LEGENDARY:
        return {
          CreatureRarity.COMMON: 0.05,
          CreatureRarity.UNCOMMON: 0.15,
          CreatureRarity.RARE: 0.30,
          CreatureRarity.EPIC: 0.35,
          CreatureRarity.LEGENDARY: 0.15,
        };
    }
  }

  /// Determine the rarity of the hatched creature based on probability
  CreatureRarity determineHatchedRarity() {
    final probabilities = getRarityProbabilities();
    final random = Random().nextDouble();
    double cumulativeProbability = 0.0;

    for (final entry in probabilities.entries) {
      cumulativeProbability += entry.value;
      if (random <= cumulativeProbability) {
        return entry.key;
      }
    }

    // Fallback to common if something goes wrong
    return CreatureRarity.COMMON;
  }
}
