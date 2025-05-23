import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class Creature extends Equatable {
  final String id;
  final String name;
  final String species;
  final int level;
  final int experiencePoints;
  final String imagePath;
  final bool isUnlocked;

  const Creature({
    required this.id,
    required this.name,
    required this.species,
    this.level = 1,
    this.experiencePoints = 0,
    required this.imagePath,
    this.isUnlocked = false,
  });

  Creature copyWith({
    String? id,
    String? name,
    String? species,
    int? level,
    int? experiencePoints,
    String? imagePath,
    bool? isUnlocked,
  }) {
    return Creature(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      level: level ?? this.level,
      experiencePoints: experiencePoints ?? this.experiencePoints,
      imagePath: imagePath ?? this.imagePath,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }

  Creature addExperiencePoints(int points) {
    final newExperiencePoints = experiencePoints + points;
    // Simple level calculation: level = 1 + exp / 50 (rounded down)
    final newLevel = 1 + (newExperiencePoints ~/ 50);
    return copyWith(experiencePoints: newExperiencePoints, level: newLevel);
  }

  Creature unlock() {
    return copyWith(isUnlocked: true);
  }

  @override
  List<Object?> get props => [id, name, species, level, experiencePoints, imagePath, isUnlocked];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'level': level,
      'experiencePoints': experiencePoints,
      'imagePath': imagePath,
      'isUnlocked': isUnlocked,
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
    );
  }
}
