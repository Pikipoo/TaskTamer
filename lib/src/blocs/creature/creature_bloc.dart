import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_tamer/src/blocs/creature/creature_event.dart';
import 'package:task_tamer/src/blocs/creature/creature_state.dart';
import 'package:task_tamer/src/models/creature.dart';
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
    on<EvolveCreature>(_onEvolveCreature);
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
        rarity: event.rarity,
        type: event.type,
        element: event.element,
        description: event.description,
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
        if (updatedCreature.canEvolve) {
          // If creature can evolve, notify the user
          emit(
            CreatureOperationSuccess(
              message:
                  '${updatedCreature.name} reached level ${updatedCreature.level} and can evolve!',
              creature: updatedCreature,
            ),
          );
        } else {
          emit(
            CreatureOperationSuccess(
              message: '${updatedCreature.name} leveled up to level ${updatedCreature.level}!',
              creature: updatedCreature,
            ),
          );
        }
      } else {
        // Just emit the current state to avoid UI flicker
        final creatures = await _creatureRepository.getAllCreatures();
        emit(CreaturesLoaded(creatures));
      }
    } catch (e) {
      emit(CreatureOperationFailure(e.toString()));
    }
  }

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

  Future<void> _onEvolveCreature(EvolveCreature event, Emitter<CreatureState> emit) async {
    emit(const CreatureLoading());
    try {
      // First check if the creature can evolve
      final creature = await _creatureRepository.getCreatureById(event.creatureId);
      if (creature == null) {
        emit(const CreatureOperationFailure('Creature not found'));
        return;
      }

      if (!creature.canEvolve) {
        emit(
          CreatureOperationFailure(
            '${creature.name} is not ready to evolve yet. It needs to reach level ${Creature.MAX_LEVEL}.',
          ),
        );
        return;
      }

      // Evolve the creature
      final evolvedCreature = await _creatureRepository.evolveCreature(event.creatureId);
      final newRarity = evolvedCreature.rarity.displayName;

      emit(
        CreatureOperationSuccess(
          message: '${evolvedCreature.name} evolved to $newRarity rarity!',
          creature: evolvedCreature,
        ),
      );
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
