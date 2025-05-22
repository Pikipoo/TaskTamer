import 'package:flutter_bloc/flutter_bloc.dart';

abstract class PetEvent {}

class LoadPet extends PetEvent {}

class FeedPet extends PetEvent {}

class EvolvePet extends PetEvent {}

abstract class PetState {}

class PetInitial extends PetState {}

class PetLoaded extends PetState {}

class PetBloc extends Bloc<PetEvent, PetState> {
  PetBloc() : super(PetInitial()) {
    on<LoadPet>((event, emit) {
      emit(PetLoaded());
    });
    on<FeedPet>((event, emit) {
      // TODO: Implement feeding logic
    });
    on<EvolvePet>((event, emit) {
      // TODO: Implement evolution logic
    });
  }
}
