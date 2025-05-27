import 'package:equatable/equatable.dart';
import 'package:task_tamer/src/models/egg.dart';

abstract class EggState extends Equatable {
  const EggState();

  @override
  List<Object?> get props => [];
}

class EggInitial extends EggState {
  const EggInitial();
}

class EggLoading extends EggState {
  const EggLoading();
}

class EggsLoaded extends EggState {
  final List<Egg> eggs;

  const EggsLoaded(this.eggs);

  @override
  List<Object> get props => [eggs];
}

class UnhatchedEggsLoaded extends EggState {
  final List<Egg> eggs;

  const UnhatchedEggsLoaded(this.eggs);

  @override
  List<Object> get props => [eggs];
}

class EggOperationSuccess extends EggState {
  final String message;
  final Egg? egg;

  const EggOperationSuccess({required this.message, this.egg});

  @override
  List<Object?> get props => [message, egg];
}

class EggOperationFailure extends EggState {
  final String error;

  const EggOperationFailure(this.error);

  @override
  List<Object> get props => [error];
}

class EggHatchSuccess extends EggState {
  final String message;
  final Egg egg;
  final String? creatureId;

  const EggHatchSuccess({required this.message, required this.egg, this.creatureId});

  @override
  List<Object?> get props => [message, egg, creatureId];
}
