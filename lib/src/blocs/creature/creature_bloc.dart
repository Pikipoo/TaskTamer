import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_tamer/src/blocs/creature/creature_event.dart';
import 'package:task_tamer/src/blocs/creature/creature_state.dart';
import 'package:task_tamer/src/repositories/creature_repository.dart';

class CreatureBloc extends Bloc<CreatureEvent, CreatureState> {
  final CreatureRepository _creatureRepository;

  CreatureBloc({required CreatureRepository creatureRepository})
    : _creatureRepository = creatureRepository,
      super(const CreatureInitial()) {
    on<LoadCreatures>(_onLoadCreatures);
    on<LoadUnlockedCreatures>(_onLoadUnlockedCreatures);
    on<AddCreature>(_onAddCreature);
    on<UpdateCreature>(_onUpdateCreature);
    on<DeleteCreature>(_onDeleteCreature);
    on<UnlockCreature>(_onUnlockCreature);
    on<AddCreatureExperiencePoints>(_onAddCreatureExperiencePoints);
    on<AddExperienceToCreature>(_onAddExperienceToCreature);
    on<RenameCreature>(_onRenameCreature);
    on<InitializeDefaultCreatures>(_onInitializeDefaultCreatures);
  }

  Future<void> _onLoadCreatures(LoadCreatures event, Emitter<CreatureState> emit) async {
    emit(const CreatureLoading());
    try {
      final creatures = await _creatureRepository.getAllCreatures();
      emit(CreaturesLoaded(creatures));
    } catch (e) {
      emit(CreatureOperationFailure(e.toString()));
    }
  }

  Future<void> _onLoadUnlockedCreatures(
    LoadUnlockedCreatures event,
    Emitter<CreatureState> emit,
  ) async {
    emit(const CreatureLoading());
    try {
      final creatures = await _creatureRepository.getUnlockedCreatures();
      emit(UnlockedCreaturesLoaded(creatures));
    } catch (e) {
      emit(CreatureOperationFailure(e.toString()));
    }
  }

  Future<void> _onAddCreature(AddCreature event, Emitter<CreatureState> emit) async {
    emit(const CreatureLoading());
    try {
      final creature = await _creatureRepository.addCreature(
        name: event.name,
        species: event.species,
        imagePath: event.imagePath,
        isUnlocked: event.isUnlocked,
      );

      emit(CreatureOperationSuccess(message: 'Creature added successfully', creature: creature));
    } catch (e) {
      emit(CreatureOperationFailure(e.toString()));
    }
  }

  Future<void> _onUpdateCreature(UpdateCreature event, Emitter<CreatureState> emit) async {
    emit(const CreatureLoading());
    try {
      final creature = await _creatureRepository.updateCreature(event.creature);

      emit(CreatureOperationSuccess(message: 'Creature updated successfully', creature: creature));
    } catch (e) {
      emit(CreatureOperationFailure(e.toString()));
    }
  }

  Future<void> _onDeleteCreature(DeleteCreature event, Emitter<CreatureState> emit) async {
    emit(const CreatureLoading());
    try {
      await _creatureRepository.deleteCreature(event.creatureId);

      final creatures = await _creatureRepository.getAllCreatures();
      emit(CreaturesLoaded(creatures));
    } catch (e) {
      emit(CreatureOperationFailure(e.toString()));
    }
  }

  Future<void> _onUnlockCreature(UnlockCreature event, Emitter<CreatureState> emit) async {
    emit(const CreatureLoading());
    try {
      final creature = await _creatureRepository.unlockCreature(event.creatureId);

      emit(CreatureOperationSuccess(message: '${creature.name} unlocked!', creature: creature));
    } catch (e) {
      emit(CreatureOperationFailure(e.toString()));
    }
  }

  Future<void> _onAddCreatureExperiencePoints(
    AddCreatureExperiencePoints event,
    Emitter<CreatureState> emit,
  ) async {
    try {
      final creature = await _creatureRepository.getCreatureById(event.creatureId);
      if (creature == null) {
        emit(const CreatureOperationFailure('Creature not found'));
        return;
      }

      final previousLevel = creature.level;
      final updatedCreature = await _creatureRepository.addExperiencePoints(
        event.creatureId,
        event.points,
      );

      if (updatedCreature.level > previousLevel) {
        // Creature leveled up
        emit(
          CreatureOperationSuccess(
            message: '${updatedCreature.name} leveled up to level ${updatedCreature.level}!',
            creature: updatedCreature,
          ),
        );
      } else {
        // Just emit the current state to avoid UI flicker
        final creatures = await _creatureRepository.getAllCreatures();
        emit(CreaturesLoaded(creatures));
      }
    } catch (e) {
      emit(CreatureOperationFailure(e.toString()));
    }
  }

  // Handler for AddExperienceToCreature event
  Future<void> _onAddExperienceToCreature(
    AddExperienceToCreature event,
    Emitter<CreatureState> emit,
  ) async {
    emit(const CreatureLoading());
    try {
      await _creatureRepository.addExperiencePoints(event.creatureId, event.points);

      final creatures = await _creatureRepository.getAllCreatures();
      emit(CreaturesLoaded(creatures));
    } catch (e) {
      emit(CreatureOperationFailure(e.toString()));
    }
  }

  // Handler for RenameCreature event
  Future<void> _onRenameCreature(RenameCreature event, Emitter<CreatureState> emit) async {
    emit(const CreatureLoading());
    try {
      await _creatureRepository.renameCreature(event.creatureId, event.newName);

      final creatures = await _creatureRepository.getAllCreatures();
      emit(CreaturesLoaded(creatures));
    } catch (e) {
      emit(CreatureOperationFailure(e.toString()));
    }
  }

  Future<void> _onInitializeDefaultCreatures(
    InitializeDefaultCreatures event,
    Emitter<CreatureState> emit,
  ) async {
    emit(const CreatureLoading());
    try {
      await _creatureRepository.initializeDefaultCreatures();
    } catch (e) {
      emit(CreatureOperationFailure(e.toString()));
    }
  }
}
