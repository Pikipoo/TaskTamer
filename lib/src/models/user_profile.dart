import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class UserProfile extends Equatable {
  final String id;
  final String name;
  final int experiencePoints;
  final int level;
  final String? avatarPath;

  const UserProfile({
    required this.id,
    required this.name,
    this.experiencePoints = 0,
    this.level = 1,
    this.avatarPath,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    int? experiencePoints,
    int? level,
    String? avatarPath,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      experiencePoints: experiencePoints ?? this.experiencePoints,
      level: level ?? this.level,
      avatarPath: avatarPath ?? this.avatarPath,
    );
  }

  UserProfile addExperiencePoints(int points) {
    final newExperiencePoints = experiencePoints + points;
    // Simple level calculation: level = 1 + exp / 100 (rounded down)
    final newLevel = 1 + (newExperiencePoints ~/ 100);
    return copyWith(experiencePoints: newExperiencePoints, level: newLevel);
  }

  int get experiencePointsForNextLevel => (level) * 100;

  double get levelProgress {
    final pointsForCurrentLevel = (level - 1) * 100;
    final pointsForNextLevel = level * 100;
    final pointsInCurrentLevel = experiencePoints - pointsForCurrentLevel;
    final pointsRequiredForNextLevel = pointsForNextLevel - pointsForCurrentLevel;
    return pointsInCurrentLevel / pointsRequiredForNextLevel;
  }

  @override
  List<Object?> get props => [id, name, experiencePoints, level, avatarPath];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'experiencePoints': experiencePoints,
      'level': level,
      'avatarPath': avatarPath,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['name'],
      experiencePoints: json['experiencePoints'] ?? 0,
      level: json['level'] ?? 1,
      avatarPath: json['avatarPath'],
    );
  }
}
