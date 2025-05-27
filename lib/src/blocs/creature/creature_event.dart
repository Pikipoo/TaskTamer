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
  final CreatureRarity rarity;
  final CreatureType type;
  final CreatureElement element;
  final String description;

  const AddCreature({
    required this.name,
    required this.species,
    required this.imagePath,
    this.isUnlocked = false,
    this.rarity = CreatureRarity.COMMON,
    required this.type,
    required this.element,
    required this.description,
  });

  @override
  List<Object> get props => [
    name,
    species,
    imagePath,
    isUnlocked,
    rarity,
    type,
    element,
    description,
  ];
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

  const AddCreatureExperiencePoints({required this.creatureId, required this.points});

  @override
  List<Object> get props => [creatureId, points];
}

class AddExperienceToCreature extends CreatureEvent {
  final String creatureId;
  final int points;

  const AddExperienceToCreature(this.creatureId, this.points);

  @override
  List<Object> get props => [creatureId, points];
}

class EvolveCreature extends CreatureEvent {
  final String creatureId;

  const EvolveCreature(this.creatureId);

  @override
  List<Object> get props => [creatureId];
}

class RenameCreature extends CreatureEvent {
  final String creatureId;
  final String newName;

  const RenameCreature(this.creatureId, this.newName);

  @override
  List<Object> get props => [creatureId, newName];
}

class InitializeDefaultCreatures extends CreatureEvent {
  const InitializeDefaultCreatures();
}
