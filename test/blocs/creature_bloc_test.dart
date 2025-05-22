import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:task_tamer/src/blocs/creature/creature_bloc.dart';
import 'package:task_tamer/src/blocs/creature/creature_event.dart';
import 'package:task_tamer/src/blocs/creature/creature_state.dart';
import 'package:task_tamer/src/models/creature.dart';
import 'package:task_tamer/src/repositories/creature_repository.dart';

class MockCreatureRepository extends Mock implements CreatureRepository {}

// Define fake classes for Mocktail fallback values
class FakeCreature extends Fake implements Creature {}

void main() {
  late MockCreatureRepository creatureRepository;
  late CreatureBloc creatureBloc;

  // Register fallback values for Mocktail
  setUpAll(() {
    registerFallbackValue(FakeCreature());
  });

  final testCreature1 = Creature(
    id: '1',
    name: 'Fluffy',
    species: 'Flufkin',
    level: 1,
    experiencePoints: 0,
    imagePath: 'assets/images/creatures/flufkin.png',
    isUnlocked: true,
  );

  final testCreature2 = Creature(
    id: '2',
    name: 'Bubbles',
    species: 'Aquafin',
    level: 1,
    experiencePoints: 0,
    imagePath: 'assets/images/creatures/aquafin.png',
    isUnlocked: false,
  );

  final updatedCreature = testCreature1.copyWith(level: 2, experiencePoints: 60);

  setUp(() {
    creatureRepository = MockCreatureRepository();
    creatureBloc = CreatureBloc(creatureRepository: creatureRepository);
  });

  tearDown(() {
    creatureBloc.close();
  });

  test('initial state should be CreatureInitial', () {
    expect(creatureBloc.state, const CreatureInitial());
  });

  group('InitializeDefaultCreatures', () {
    blocTest<CreatureBloc, CreatureState>(
      'emits [CreatureLoading] when initialization is successful',
      build: () {
        when(() => creatureRepository.initializeDefaultCreatures()).thenAnswer((_) async => {});
        return creatureBloc;
      },
      act: (bloc) => bloc.add(const InitializeDefaultCreatures()),
      expect: () => [const CreatureLoading()],
      verify: (_) {
        verify(() => creatureRepository.initializeDefaultCreatures()).called(1);
      },
    );

    blocTest<CreatureBloc, CreatureState>(
      'emits [CreatureLoading, CreatureOperationFailure] when initialization fails',
      build: () {
        when(
          () => creatureRepository.initializeDefaultCreatures(),
        ).thenThrow(Exception('Failed to initialize creatures'));
        return creatureBloc;
      },
      act: (bloc) => bloc.add(const InitializeDefaultCreatures()),
      expect: () => [
        const CreatureLoading(),
        const CreatureOperationFailure('Exception: Failed to initialize creatures'),
      ],
    );
  });

  group('LoadCreatures', () {
    blocTest<CreatureBloc, CreatureState>(
      'emits [CreatureLoading, CreaturesLoaded] when LoadCreatures is successful',
      build: () {
        when(
          () => creatureRepository.getAllCreatures(),
        ).thenAnswer((_) async => [testCreature1, testCreature2]);
        return creatureBloc;
      },
      act: (bloc) => bloc.add(const LoadCreatures()),
      expect: () => [
        const CreatureLoading(),
        CreaturesLoaded([testCreature1, testCreature2]),
      ],
      verify: (_) {
        verify(() => creatureRepository.getAllCreatures()).called(1);
      },
    );

    blocTest<CreatureBloc, CreatureState>(
      'emits [CreatureLoading, CreatureOperationFailure] when LoadCreatures fails',
      build: () {
        when(
          () => creatureRepository.getAllCreatures(),
        ).thenThrow(Exception('Failed to load creatures'));
        return creatureBloc;
      },
      act: (bloc) => bloc.add(const LoadCreatures()),
      expect: () => [
        const CreatureLoading(),
        const CreatureOperationFailure('Exception: Failed to load creatures'),
      ],
    );
  });

  group('AddExperienceToCreature', () {
    blocTest<CreatureBloc, CreatureState>(
      'emits [CreatureLoading, CreaturesLoaded] when AddExperienceToCreature is successful',
      build: () {
        when(
          () => creatureRepository.addExperiencePoints('1', 30),
        ).thenAnswer((_) async => updatedCreature);
        when(
          () => creatureRepository.getAllCreatures(),
        ).thenAnswer((_) async => [updatedCreature, testCreature2]);
        return creatureBloc;
      },
      act: (bloc) => bloc.add(const AddExperienceToCreature('1', 30)),
      expect: () => [
        const CreatureLoading(),
        CreaturesLoaded([updatedCreature, testCreature2]),
      ],
      verify: (_) {
        verify(() => creatureRepository.addExperiencePoints('1', 30)).called(1);
        verify(() => creatureRepository.getAllCreatures()).called(1);
      },
    );

    blocTest<CreatureBloc, CreatureState>(
      'emits [CreatureLoading, CreatureOperationFailure] when AddExperienceToCreature fails',
      build: () {
        when(
          () => creatureRepository.addExperiencePoints('1', 30),
        ).thenThrow(Exception('Failed to add experience points'));
        return creatureBloc;
      },
      act: (bloc) => bloc.add(const AddExperienceToCreature('1', 30)),
      expect: () => [
        const CreatureLoading(),
        const CreatureOperationFailure('Exception: Failed to add experience points'),
      ],
    );
  });

  group('UnlockCreature', () {
    final unlockedCreature = testCreature2.copyWith(isUnlocked: true);

    blocTest<CreatureBloc, CreatureState>(
      'emits [CreatureLoading, CreatureOperationSuccess] when UnlockCreature is successful',
      build: () {
        when(
          () => creatureRepository.unlockCreature('2'),
        ).thenAnswer((_) async => unlockedCreature);
        return creatureBloc;
      },
      act: (bloc) => bloc.add(const UnlockCreature('2')),
      expect: () => [
        const CreatureLoading(),
        CreatureOperationSuccess(message: 'Bubbles unlocked!', creature: unlockedCreature),
      ],
      verify: (_) {
        verify(() => creatureRepository.unlockCreature('2')).called(1);
      },
    );

    blocTest<CreatureBloc, CreatureState>(
      'emits [CreatureLoading, CreatureOperationFailure] when UnlockCreature fails',
      build: () {
        when(
          () => creatureRepository.unlockCreature('2'),
        ).thenThrow(Exception('Failed to unlock creature'));
        return creatureBloc;
      },
      act: (bloc) => bloc.add(const UnlockCreature('2')),
      expect: () => [
        const CreatureLoading(),
        const CreatureOperationFailure('Exception: Failed to unlock creature'),
      ],
    );
  });

  group('RenameCreature', () {
    final renamedCreature = testCreature1.copyWith(name: 'Super Fluffy');

    blocTest<CreatureBloc, CreatureState>(
      'emits [CreatureLoading, CreaturesLoaded] when RenameCreature is successful',
      build: () {
        when(
          () => creatureRepository.renameCreature('1', 'Super Fluffy'),
        ).thenAnswer((_) async => renamedCreature);
        when(
          () => creatureRepository.getAllCreatures(),
        ).thenAnswer((_) async => [renamedCreature, testCreature2]);
        return creatureBloc;
      },
      act: (bloc) => bloc.add(const RenameCreature('1', 'Super Fluffy')),
      expect: () => [
        const CreatureLoading(),
        CreaturesLoaded([renamedCreature, testCreature2]),
      ],
      verify: (_) {
        verify(() => creatureRepository.renameCreature('1', 'Super Fluffy')).called(1);
        verify(() => creatureRepository.getAllCreatures()).called(1);
      },
    );

    blocTest<CreatureBloc, CreatureState>(
      'emits [CreatureLoading, CreatureOperationFailure] when RenameCreature fails',
      build: () {
        when(
          () => creatureRepository.renameCreature('1', 'Super Fluffy'),
        ).thenThrow(Exception('Failed to rename creature'));
        return creatureBloc;
      },
      act: (bloc) => bloc.add(const RenameCreature('1', 'Super Fluffy')),
      expect: () => [
        const CreatureLoading(),
        const CreatureOperationFailure('Exception: Failed to rename creature'),
      ],
    );
  });
}
