import 'dart:async';

import 'package:hive/hive.dart';
import 'package:task_tamer/src/models/creature.dart';
import 'package:uuid/uuid.dart';

class CreatureRepository {
  static const String _boxName = 'creatures';
  final Box<dynamic> _box;

  CreatureRepository(this._box);

  static Future<CreatureRepository> create() async {
    final box = await Hive.openBox(_boxName);
    print('Got object store box in database $_boxName.');
    return CreatureRepository(box);
  }

  Future<List<Creature>> getAllCreatures() async {
    final creatures = <Creature>[];

    for (var key in _box.keys) {
      final dynamic value = _box.get(key);
      if (value is Map) {
        creatures.add(Creature.fromJson(Map<String, dynamic>.from(value)));
      } else if (value is Creature) {
        creatures.add(value);
      }
    }

    return creatures;
  }

  Future<List<Creature>> getUnlockedCreatures() async {
    final creatures = await getAllCreatures();
    return creatures.where((creature) => creature.isUnlocked).toList();
  }

  Future<Creature?> getCreatureById(String id) async {
    final value = _box.get(id);
    if (value == null) return null;

    if (value is Map) {
      return Creature.fromJson(Map<String, dynamic>.from(value));
    } else if (value is Creature) {
      return value;
    }

    return null;
  }

  Future<Creature> addCreature({
    required String name,
    required String species,
    required String imagePath,
    bool isUnlocked = false,
  }) async {
    final creature = Creature(
      id: const Uuid().v4(),
      name: name,
      species: species,
      imagePath: imagePath,
      isUnlocked: isUnlocked,
    );

    await _box.put(creature.id, creature);
    return creature;
  }

  Future<Creature> updateCreature(Creature creature) async {
    await _box.put(creature.id, creature);
    return creature;
  }

  Future<void> deleteCreature(String id) async {
    await _box.delete(id);
  }

  Future<Creature> unlockCreature(String id) async {
    final creature = await getCreatureById(id);
    if (creature == null) {
      throw Exception('Creature not found');
    }

    final unlockedCreature = creature.unlock();
    await _box.put(id, unlockedCreature);
    return unlockedCreature;
  }

  Future<Creature> addExperiencePoints(String id, int points) async {
    final creature = await getCreatureById(id);
    if (creature == null) {
      throw Exception('Creature not found');
    }

    final updatedCreature = creature.addExperiencePoints(points);
    await _box.put(id, updatedCreature);
    return updatedCreature;
  }

  // Method to rename a creature
  Future<Creature> renameCreature(String id, String newName) async {
    final creature = await getCreatureById(id);
    if (creature == null) {
      throw Exception('Creature not found');
    }

    final updatedCreature = creature.copyWith(name: newName);
    await _box.put(id, updatedCreature);
    return updatedCreature;
  }

  // Initialize with some default creatures
  Future<void> initializeDefaultCreatures() async {
    if (_box.isEmpty) {
      final defaultCreatures = [
        {
          'name': 'Flufkin',
          'species': 'Flufkin',
          'imagePath': 'assets/images/creatures/flufkin.png',
          'isUnlocked': true,
        },
        {
          'name': 'Sparkle',
          'species': 'Sparkler',
          'imagePath': 'assets/images/creatures/sparkler.png',
          'isUnlocked': false,
        },
        {
          'name': 'Bubbles',
          'species': 'Aquafluff',
          'imagePath': 'assets/images/creatures/aquafluff.png',
          'isUnlocked': false,
        },
      ];

      for (final creatureData in defaultCreatures) {
        await addCreature(
          name: creatureData['name'] as String,
          species: creatureData['species'] as String,
          imagePath: creatureData['imagePath'] as String,
          isUnlocked: creatureData['isUnlocked'] as bool,
        );
      }
    }
  }
}
