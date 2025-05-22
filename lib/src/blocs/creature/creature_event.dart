import 'package:equatable/equatable.dart';
import 'package:task_tamer/src/models/creature.dart';

abstract class CreatureEvent extends Equatable {
  const CreatureEvent();

  @override
  List<Object?> get props => [];
}

class LoadCreatures extends CreatureEvent {
  const LoadCreatures();
}

class LoadUnlockedCreatures extends CreatureEvent {
  const LoadUnlockedCreatures();
}

class AddCreature extends CreatureEvent {
  final String name;
  final String species;
  final String imagePath;
  final bool isUnlocked;

  const AddCreature({
    required this.name,
    required this.species,
    required this.imagePath,
    this.isUnlocked = false,
  });

  @override
  List<Object> get props => [name, species, imagePath, isUnlocked];
}

class UpdateCreature extends CreatureEvent {
  final Creature creature;

  const UpdateCreature(this.creature);

  @override
  List<Object> get props => [creature];
}

class DeleteCreature extends CreatureEvent {
  final String creatureId;

  const DeleteCreature(this.creatureId);

  @override
  List<Object> get props => [creatureId];
}

class UnlockCreature extends CreatureEvent {
  final String creatureId;

  const UnlockCreature(this.creatureId);

  @override
  List<Object> get props => [creatureId];
}

class AddCreatureExperiencePoints extends CreatureEvent {
  final String creatureId;
  final int points;

  const AddCreatureExperiencePoints({
    required this.creatureId,
    required this.points,
  });

  @override
  List<Object> get props => [creatureId, points];
}

class InitializeDefaultCreatures extends CreatureEvent {
  const InitializeDefaultCreatures();
}
