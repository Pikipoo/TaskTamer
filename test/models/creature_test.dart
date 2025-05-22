import 'package:flutter_test/flutter_test.dart';
import 'package:task_tamer/src/models/creature.dart';

void main() {
  group('Creature Model', () {
    test('should create Creature with required parameters', () {
      final creature = Creature(
        id: '1',
        name: 'Fluffy',
        species: 'Flufkin',
        imagePath: 'assets/images/creatures/flufkin.png',
      );

      expect(creature.id, '1');
      expect(creature.name, 'Fluffy');
      expect(creature.species, 'Flufkin');
      expect(creature.level, 1);
      expect(creature.experiencePoints, 0);
      expect(creature.imagePath, 'assets/images/creatures/flufkin.png');
      expect(creature.isUnlocked, false);
    });

    test('should create Creature with all parameters', () {
      final creature = Creature(
        id: '1',
        name: 'Fluffy',
        species: 'Flufkin',
        level: 3,
        experiencePoints: 120,
        imagePath: 'assets/images/creatures/flufkin.png',
        isUnlocked: true,
      );

      expect(creature.id, '1');
      expect(creature.name, 'Fluffy');
      expect(creature.species, 'Flufkin');
      expect(creature.level, 3);
      expect(creature.experiencePoints, 120);
      expect(creature.imagePath, 'assets/images/creatures/flufkin.png');
      expect(creature.isUnlocked, true);
    });

    test('copyWith should create a new instance with updated values', () {
      final creature = Creature(
        id: '1',
        name: 'Fluffy',
        species: 'Flufkin',
        imagePath: 'assets/images/creatures/flufkin.png',
      );

      final updatedCreature = creature.copyWith(
        name: 'Super Fluffy',
        level: 2,
        isUnlocked: true,
      );

      expect(updatedCreature.id, '1');
      expect(updatedCreature.name, 'Super Fluffy');
      expect(updatedCreature.species, 'Flufkin');
      expect(updatedCreature.level, 2);
      expect(updatedCreature.experiencePoints, 0);
      expect(updatedCreature.imagePath, 'assets/images/creatures/flufkin.png');
      expect(updatedCreature.isUnlocked, true);
    });

    test('addExperiencePoints should increment XP and calculate new level', () {
      final creature = Creature(
        id: '1',
        name: 'Fluffy',
        species: 'Flufkin',
        level: 1,
        experiencePoints: 0,
        imagePath: 'assets/images/creatures/flufkin.png',
      );

      // Adding 25 XP (not enough for level up)
      final updatedCreature = creature.addExperiencePoints(25);
      expect(updatedCreature.experiencePoints, 25);
      expect(updatedCreature.level, 1);

      // Adding another 30 XP (should level up)
      final leveledUpCreature = updatedCreature.addExperiencePoints(30);
      expect(leveledUpCreature.experiencePoints, 55);
      expect(leveledUpCreature.level, 2);

      // Adding 50 more XP (should reach level 3)
      final highLevelCreature = leveledUpCreature.addExperiencePoints(50);
      expect(highLevelCreature.experiencePoints, 105);
      expect(highLevelCreature.level, 3);
    });

    test('unlock should set isUnlocked to true', () {
      final creature = Creature(
        id: '1',
        name: 'Fluffy',
        species: 'Flufkin',
        imagePath: 'assets/images/creatures/flufkin.png',
        isUnlocked: false,
      );

      final unlockedCreature = creature.unlock();
      expect(unlockedCreature.isUnlocked, true);
    });

    test('toJson should return a valid map', () {
      final creature = Creature(
        id: '1',
        name: 'Fluffy',
        species: 'Flufkin',
        level: 3,
        experiencePoints: 120,
        imagePath: 'assets/images/creatures/flufkin.png',
        isUnlocked: true,
      );

      final json = creature.toJson();

      expect(json['id'], '1');
      expect(json['name'], 'Fluffy');
      expect(json['species'], 'Flufkin');
      expect(json['level'], 3);
      expect(json['experiencePoints'], 120);
      expect(json['imagePath'], 'assets/images/creatures/flufkin.png');
      expect(json['isUnlocked'], true);
    });

    test('fromJson should create a creature from json', () {
      final json = {
        'id': '1',
        'name': 'Fluffy',
        'species': 'Flufkin',
        'level': 3,
        'experiencePoints': 120,
        'imagePath': 'assets/images/creatures/flufkin.png',
        'isUnlocked': true,
      };

      final creature = Creature.fromJson(json);

      expect(creature.id, '1');
      expect(creature.name, 'Fluffy');
      expect(creature.species, 'Flufkin');
      expect(creature.level, 3);
      expect(creature.experiencePoints, 120);
      expect(creature.imagePath, 'assets/images/creatures/flufkin.png');
      expect(creature.isUnlocked, true);
    });

    test('fromJson should set default values when not provided', () {
      final json = {
        'id': '1',
        'name': 'Fluffy',
        'species': 'Flufkin',
        'imagePath': 'assets/images/creatures/flufkin.png',
      };

      final creature = Creature.fromJson(json);

      expect(creature.id, '1');
      expect(creature.name, 'Fluffy');
      expect(creature.species, 'Flufkin');
      expect(creature.level, 1);
      expect(creature.experiencePoints, 0);
      expect(creature.imagePath, 'assets/images/creatures/flufkin.png');
      expect(creature.isUnlocked, false);
    });
  });
}
