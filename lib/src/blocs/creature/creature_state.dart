import 'package:equatable/equatable.dart';
import 'package:task_tamer/src/models/creature.dart';

abstract class CreatureState extends Equatable {
  const CreatureState();

  @override
  List<Object?> get props => [];
}

class CreatureInitial extends CreatureState {
  const CreatureInitial();
}

class CreatureLoading extends CreatureState {
  const CreatureLoading();
}

class CreaturesLoaded extends CreatureState {
  final List<Creature> creatures;
  final String? newlyHatchedCreatureId;

  const CreaturesLoaded(this.creatures, {this.newlyHatchedCreatureId});

  @override
  List<Object?> get props => [creatures, newlyHatchedCreatureId];
}

class UnlockedCreaturesLoaded extends CreatureState {
  final List<Creature> creatures;
  final String? newlyHatchedCreatureId;

  const UnlockedCreaturesLoaded(this.creatures, {this.newlyHatchedCreatureId});

  @override
  List<Object?> get props => [creatures, newlyHatchedCreatureId];
}

class CreatureOperationSuccess extends CreatureState {
  final String message;
  final Creature? creature;
  final bool isNewlyHatched;

  const CreatureOperationSuccess({
    required this.message,
    this.creature,
    this.isNewlyHatched = false,
  });

  @override
  List<Object?> get props => [message, creature, isNewlyHatched];
}

class CreatureOperationFailure extends CreatureState {
  final String error;

  const CreatureOperationFailure(this.error);

  @override
  List<Object> get props => [error];
}

class NewlyHatchedCreature extends CreatureState {
  final Creature creature;
  final String message;

  const NewlyHatchedCreature({required this.creature, this.message = 'New creature hatched!'});

  @override
  List<Object> get props => [creature, message];
}
