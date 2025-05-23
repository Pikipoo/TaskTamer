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

  const CreaturesLoaded(this.creatures);

  @override
  List<Object> get props => [creatures];
}

class UnlockedCreaturesLoaded extends CreatureState {
  final List<Creature> creatures;

  const UnlockedCreaturesLoaded(this.creatures);

  @override
  List<Object> get props => [creatures];
}

class CreatureOperationSuccess extends CreatureState {
  final String message;
  final Creature? creature;

  const CreatureOperationSuccess({required this.message, this.creature});

  @override
  List<Object?> get props => [message, creature];
}

class CreatureOperationFailure extends CreatureState {
  final String error;

  const CreatureOperationFailure(this.error);

  @override
  List<Object> get props => [error];
}
