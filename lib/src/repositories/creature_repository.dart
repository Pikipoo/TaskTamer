import 'dart:async';
import 'dart:math';

import 'package:hive/hive.dart';
import 'package:task_tamer/src/models/creature.dart';
import 'package:task_tamer/src/models/egg.dart';
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
    CreatureRarity rarity = CreatureRarity.COMMON,
    required CreatureType type,
    required CreatureElement element,
    required String description,
  }) async {
    final creature = Creature(
      id: const Uuid().v4(),
      name: name,
      species: species,
      imagePath: imagePath,
      isUnlocked: isUnlocked,
      rarity: rarity,
      type: type,
      element: element,
      description: description,
    );

    await _box.put(creature.id, creature);
    return creature;
  }

  /// Create a creature from a hatched egg
  Future<Creature> createCreatureFromEgg(Egg egg) async {
    if (!egg.isHatched) {
      throw Exception('Cannot create creature from unhatched egg');
    }

    // Determine the creature's rarity based on egg's rarity probabilities
    final rarity = egg.determineHatchedRarity();

    // Select random type and element
    final type = CreatureType.values[Random().nextInt(CreatureType.values.length)];
    final element = CreatureElement.values[Random().nextInt(CreatureElement.values.length)];

    // Create species name based on element and type
    final speciesName = _generateSpeciesName(element, type);

    // Create a description
    final description = _generateDescription(speciesName, element, type);

    // Determine image path based on element and type
    // In a real app, you'd have more specific sprite selection logic
    final imagePath =
        'assets/images/creatures/${element.name.toLowerCase()}_${type.name.toLowerCase()}.png';

    return addCreature(
      name: speciesName,
      species: speciesName,
      imagePath: imagePath,
      isUnlocked: true, // Creatures from eggs are automatically unlocked
      rarity: rarity,
      type: type,
      element: element,
      description: description,
    );
  }

  String _generateSpeciesName(CreatureElement element, CreatureType type) {
    // Simple name generation - in a real app, you'd have more sophisticated naming
    final elementPrefixes = {
      CreatureElement.FIRE: ['Ember', 'Blaze', 'Inferno'],
      CreatureElement.WATER: ['Aqua', 'Wave', 'Tide'],
      CreatureElement.EARTH: ['Terra', 'Stone', 'Pebble'],
      CreatureElement.AIR: ['Wind', 'Breeze', 'Gust'],
      CreatureElement.LIGHT: ['Lumi', 'Shine', 'Glow'],
      CreatureElement.DARK: ['Shadow', 'Dusk', 'Gloom'],
    };

    final typeSuffixes = {
      CreatureType.TANK: ['Shield', 'Armor', 'Guard'],
      CreatureType.DPS: ['Blade', 'Strike', 'Fang'],
      CreatureType.SUPPORT: ['Heal', 'Aid', 'Bless'],
    };

    final prefix = elementPrefixes[element]![Random().nextInt(elementPrefixes[element]!.length)];
    final suffix = typeSuffixes[type]![Random().nextInt(typeSuffixes[type]!.length)];

    return '$prefix$suffix';
  }

  String _generateDescription(String name, CreatureElement element, CreatureType type) {
    // Simple description generation - in a real app, you'd have more sophisticated descriptions
    final elementDesc = {
      CreatureElement.FIRE: 'fiery',
      CreatureElement.WATER: 'aquatic',
      CreatureElement.EARTH: 'earthen',
      CreatureElement.AIR: 'aerial',
      CreatureElement.LIGHT: 'luminous',
      CreatureElement.DARK: 'shadowy',
    };

    final typeDesc = {
      CreatureType.TANK: 'defensive abilities',
      CreatureType.DPS: 'offensive prowess',
      CreatureType.SUPPORT: 'supportive nature',
    };

    return 'A $name is a ${elementDesc[element]} creature known for its ${typeDesc[type]}.';
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

  /// Evolve a creature to the next rarity if possible
  Future<Creature> evolveCreature(String id) async {
    final creature = await getCreatureById(id);
    if (creature == null) {
      throw Exception('Creature not found');
    }

    if (!creature.canEvolve) {
      throw Exception('Creature cannot evolve yet');
    }

    final evolvedCreature = creature.evolve();
    await _box.put(id, evolvedCreature);
    return evolvedCreature;
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
          'rarity': CreatureRarity.COMMON,
          'type': CreatureType.SUPPORT,
          'element': CreatureElement.EARTH,
          'description': 'A friendly earth creature that helps plants grow.',
        },
        {
          'name': 'Sparkle',
          'species': 'Sparkler',
          'imagePath': 'assets/images/creatures/sparkler.png',
          'isUnlocked': false,
          'rarity': CreatureRarity.UNCOMMON,
          'type': CreatureType.DPS,
          'element': CreatureElement.FIRE,
          'description': 'A fiery creature that lights up the night sky.',
        },
        {
          'name': 'Bubbles',
          'species': 'Aquafluff',
          'imagePath': 'assets/images/creatures/aquafluff.png',
          'isUnlocked': false,
          'rarity': CreatureRarity.RARE,
          'type': CreatureType.TANK,
          'element': CreatureElement.WATER,
          'description': 'A water creature that creates protective bubbles.',
        },
      ];

      for (final creatureData in defaultCreatures) {
        await addCreature(
          name: creatureData['name'] as String,
          species: creatureData['species'] as String,
          imagePath: creatureData['imagePath'] as String,
          isUnlocked: creatureData['isUnlocked'] as bool,
          rarity: creatureData['rarity'] as CreatureRarity,
          type: creatureData['type'] as CreatureType,
          element: creatureData['element'] as CreatureElement,
          description: creatureData['description'] as String,
        );
      }
    }
  }
}
