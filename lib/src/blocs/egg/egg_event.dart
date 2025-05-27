import 'package:equatable/equatable.dart';
import 'package:task_tamer/src/models/creature.dart';
import 'package:task_tamer/src/models/egg.dart';

abstract class EggEvent extends Equatable {
  const EggEvent();

  @override
  List<Object?> get props => [];
}

class LoadEggs extends EggEvent {
  const LoadEggs();
}

class LoadUnhatchedEggs extends EggEvent {
  const LoadUnhatchedEggs();
}

class AddEgg extends EggEvent {
  final CreatureRarity rarity;
  final int experienceRequired;

  const AddEgg({required this.rarity, this.experienceRequired = Egg.DEFAULT_HATCH_XP});

  @override
  List<Object> get props => [rarity, experienceRequired];
}

class UpdateEgg extends EggEvent {
  final Egg egg;

  const UpdateEgg(this.egg);

  @override
  List<Object> get props => [egg];
}

class DeleteEgg extends EggEvent {
  final String eggId;

  const DeleteEgg(this.eggId);

  @override
  List<Object> get props => [eggId];
}

class AddEggExperiencePoints extends EggEvent {
  final String eggId;
  final int points;

  const AddEggExperiencePoints({required this.eggId, required this.points});

  @override
  List<Object> get props => [eggId, points];
}

class HatchEgg extends EggEvent {
  final String eggId;

  const HatchEgg(this.eggId);

  @override
  List<Object> get props => [eggId];
}

class InitializeStarterEggs extends EggEvent {
  const InitializeStarterEggs();
}
