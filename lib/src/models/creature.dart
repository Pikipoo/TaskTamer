import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Represents the rarity of a creature
enum CreatureRarity {
  COMMON,
  UNCOMMON,
  RARE,
  EPIC,
  LEGENDARY;

  String get displayName {
    switch (this) {
      case CreatureRarity.COMMON:
        return 'Common';
      case CreatureRarity.UNCOMMON:
        return 'Uncommon';
      case CreatureRarity.RARE:
        return 'Rare';
      case CreatureRarity.EPIC:
        return 'Epic';
      case CreatureRarity.LEGENDARY:
        return 'Legendary';
    }
  }

  Color get color {
    switch (this) {
      case CreatureRarity.COMMON:
        return Colors.grey;
      case CreatureRarity.UNCOMMON:
        return Colors.green;
      case CreatureRarity.RARE:
        return Colors.blue;
      case CreatureRarity.EPIC:
        return Colors.purple;
      case CreatureRarity.LEGENDARY:
        return Colors.orange;
    }
  }
}

/// Represents the type of a creature
enum CreatureType {
  TANK,
  DPS,
  SUPPORT;

  String get displayName {
    switch (this) {
      case CreatureType.TANK:
        return 'Tank';
      case CreatureType.DPS:
        return 'DPS';
      case CreatureType.SUPPORT:
        return 'Support';
    }
  }
}

/// Represents the element of a creature
enum CreatureElement {
  FIRE,
  WATER,
  EARTH,
  AIR,
  LIGHT,
  DARK;

  String get displayName {
    switch (this) {
      case CreatureElement.FIRE:
        return 'Fire';
      case CreatureElement.WATER:
        return 'Water';
      case CreatureElement.EARTH:
        return 'Earth';
      case CreatureElement.AIR:
        return 'Air';
      case CreatureElement.LIGHT:
        return 'Light';
      case CreatureElement.DARK:
        return 'Dark';
    }
  }
}

@immutable
class Creature extends Equatable {
  final String id;
  final String name;
  final String species;
  final int level;
  final int experiencePoints;
  final String imagePath;
  final bool isUnlocked;
  final CreatureRarity rarity;
  final CreatureType type;
  final CreatureElement element;
  final String description;

  /// The maximum level a creature can reach before evolving
  static const int MAX_LEVEL = 100;

  const Creature({
    required this.id,
    required this.name,
    required this.species,
    this.level = 1,
    this.experiencePoints = 0,
    required this.imagePath,
    this.isUnlocked = false,
    this.rarity = CreatureRarity.COMMON,
    required this.type,
    required this.element,
    required this.description,
  });

  Creature copyWith({
    String? id,
    String? name,
    String? species,
    int? level,
    int? experiencePoints,
    String? imagePath,
    bool? isUnlocked,
    CreatureRarity? rarity,
    CreatureType? type,
    CreatureElement? element,
    String? description,
  }) {
    return Creature(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      level: level ?? this.level,
      experiencePoints: experiencePoints ?? this.experiencePoints,
      imagePath: imagePath ?? this.imagePath,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      rarity: rarity ?? this.rarity,
      type: type ?? this.type,
      element: element ?? this.element,
      description: description ?? this.description,
    );
  }

  /// Calculate experience needed for the next level
  int get experienceForNextLevel {
    // Formula: 50 * (level ^ 1.5)
    return (50 * (level * sqrt(level))).floor();
  }

  /// Calculate total experience needed to reach MAX_LEVEL
  int get experienceToMaxLevel {
    int total = 0;
    for (int lvl = level; lvl < MAX_LEVEL; lvl++) {
      total += (50 * (lvl * sqrt(lvl))).floor();
    }
    return total;
  }

  /// Determine if creature is ready to evolve
  bool get canEvolve {
    return level >= MAX_LEVEL && rarity != CreatureRarity.LEGENDARY;
  }

  /// Get the next rarity for evolution
  CreatureRarity get nextRarity {
    switch (rarity) {
      case CreatureRarity.COMMON:
        return CreatureRarity.UNCOMMON;
      case CreatureRarity.UNCOMMON:
        return CreatureRarity.RARE;
      case CreatureRarity.RARE:
        return CreatureRarity.EPIC;
      case CreatureRarity.EPIC:
        return CreatureRarity.LEGENDARY;
      case CreatureRarity.LEGENDARY:
        return CreatureRarity.LEGENDARY; // Already at max rarity
    }
  }

  /// Add experience points to the creature and handle level up logic
  Creature addExperiencePoints(int points) {
    int newExperiencePoints = experiencePoints + points;
    int newLevel = level;

    // Calculate new level based on experience
    while (true) {
      int expForNextLevel = (50 * (newLevel * sqrt(newLevel))).floor();
      if (newExperiencePoints >= expForNextLevel && newLevel < MAX_LEVEL) {
        newExperiencePoints -= expForNextLevel;
        newLevel++;
      } else {
        break;
      }
    }

    return copyWith(experiencePoints: newExperiencePoints, level: newLevel);
  }

  /// Evolve the creature to the next rarity level
  Creature evolve() {
    if (!canEvolve) {
      return this;
    }

    return copyWith(level: 1, experiencePoints: 0, rarity: nextRarity);
  }

  Creature unlock() {
    return copyWith(isUnlocked: true);
  }

  @override
  List<Object?> get props => [
    id,
    name,
    species,
    level,
    experiencePoints,
    imagePath,
    isUnlocked,
    rarity,
    type,
    element,
    description,
  ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'level': level,
      'experiencePoints': experiencePoints,
      'imagePath': imagePath,
      'isUnlocked': isUnlocked,
      'rarity': rarity.index,
      'type': type.index,
      'element': element.index,
      'description': description,
    };
  }

  factory Creature.fromJson(Map<String, dynamic> json) {
    return Creature(
      id: json['id'],
      name: json['name'],
      species: json['species'],
      level: json['level'] ?? 1,
      experiencePoints: json['experiencePoints'] ?? 0,
      imagePath: json['imagePath'],
      isUnlocked: json['isUnlocked'] ?? false,
      rarity: json['rarity'] != null
          ? CreatureRarity.values[json['rarity']]
          : CreatureRarity.COMMON,
      type: json['type'] != null ? CreatureType.values[json['type']] : CreatureType.TANK,
      element: json['element'] != null
          ? CreatureElement.values[json['element']]
          : CreatureElement.FIRE,
      description: json['description'] ?? '',
    );
  }
}
