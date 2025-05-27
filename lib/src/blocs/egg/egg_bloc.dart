import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_tamer/src/blocs/egg/egg_event.dart';
import 'package:task_tamer/src/blocs/egg/egg_state.dart';
import 'package:task_tamer/src/repositories/creature_repository.dart';
import 'package:task_tamer/src/repositories/egg_repository.dart';

class EggBloc extends Bloc<EggEvent, EggState> {
  final EggRepository _eggRepository;
  final CreatureRepository _creatureRepository;

  EggBloc({required EggRepository eggRepository, required CreatureRepository creatureRepository})
    : _eggRepository = eggRepository,
      _creatureRepository = creatureRepository,
      super(const EggInitial()) {
    on<LoadEggs>(_onLoadEggs);
    on<LoadUnhatchedEggs>(_onLoadUnhatchedEggs);
    on<AddEgg>(_onAddEgg);
    on<UpdateEgg>(_onUpdateEgg);
    on<DeleteEgg>(_onDeleteEgg);
    on<AddEggExperiencePoints>(_onAddEggExperiencePoints);
    on<HatchEgg>(_onHatchEgg);
    on<InitializeStarterEggs>(_onInitializeStarterEggs);
  }

  Future<void> _onLoadEggs(LoadEggs event, Emitter<EggState> emit) async {
    emit(const EggLoading());
    try {
      final eggs = await _eggRepository.getAllEggs();
      emit(EggsLoaded(eggs));
    } catch (e) {
      emit(EggOperationFailure(e.toString()));
    }
  }

  Future<void> _onLoadUnhatchedEggs(LoadUnhatchedEggs event, Emitter<EggState> emit) async {
    emit(const EggLoading());
    try {
      final eggs = await _eggRepository.getUnhatchedEggs();
      emit(UnhatchedEggsLoaded(eggs));
    } catch (e) {
      emit(EggOperationFailure(e.toString()));
    }
  }

  Future<void> _onAddEgg(AddEgg event, Emitter<EggState> emit) async {
    emit(const EggLoading());
    try {
      final egg = await _eggRepository.addEgg(
        rarity: event.rarity,
        experienceRequired: event.experienceRequired,
      );

      emit(EggOperationSuccess(message: 'Egg added successfully', egg: egg));
    } catch (e) {
      emit(EggOperationFailure(e.toString()));
    }
  }

  Future<void> _onUpdateEgg(UpdateEgg event, Emitter<EggState> emit) async {
    emit(const EggLoading());
    try {
      final egg = await _eggRepository.updateEgg(event.egg);

      emit(EggOperationSuccess(message: 'Egg updated successfully', egg: egg));
    } catch (e) {
      emit(EggOperationFailure(e.toString()));
    }
  }

  Future<void> _onDeleteEgg(DeleteEgg event, Emitter<EggState> emit) async {
    emit(const EggLoading());
    try {
      await _eggRepository.deleteEgg(event.eggId);

      final eggs = await _eggRepository.getAllEggs();
      emit(EggsLoaded(eggs));
    } catch (e) {
      emit(EggOperationFailure(e.toString()));
    }
  }

  Future<void> _onAddEggExperiencePoints(
    AddEggExperiencePoints event,
    Emitter<EggState> emit,
  ) async {
    emit(const EggLoading());
    try {
      final egg = await _eggRepository.addExperiencePoints(event.eggId, event.points);

      // Check if the egg is ready to hatch
      if (egg.canHatch) {
        emit(EggOperationSuccess(message: 'The egg is ready to hatch! Tap to hatch it.', egg: egg));
      } else {
        emit(EggOperationSuccess(message: 'Added ${event.points} XP to the egg.', egg: egg));
      }
    } catch (e) {
      emit(EggOperationFailure(e.toString()));
    }
  }

  Future<void> _onHatchEgg(HatchEgg event, Emitter<EggState> emit) async {
    emit(const EggLoading());
    try {
      // First, mark the egg as hatched
      final hatchedEgg = await _eggRepository.hatchEgg(event.eggId);

      // Then, create a creature from the hatched egg
      final creature = await _creatureRepository.createCreatureFromEgg(hatchedEgg);

      emit(
        EggHatchSuccess(
          message: 'Egg hatched successfully! ${creature.name} has joined your collection!',
          egg: hatchedEgg,
          creatureId: creature.id,
        ),
      );
    } catch (e) {
      emit(EggOperationFailure(e.toString()));
    }
  }

  Future<void> _onInitializeStarterEggs(InitializeStarterEggs event, Emitter<EggState> emit) async {
    emit(const EggLoading());
    try {
      await _eggRepository.initializeStarterEggs();
      final eggs = await _eggRepository.getAllEggs();
      emit(EggsLoaded(eggs));
    } catch (e) {
      emit(EggOperationFailure(e.toString()));
    }
  }
}
