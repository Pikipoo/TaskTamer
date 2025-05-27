import 'dart:async';

import 'package:hive/hive.dart';
import 'package:task_tamer/src/models/creature.dart';
import 'package:task_tamer/src/models/egg.dart';
import 'package:uuid/uuid.dart';

class EggRepository {
  static const String _boxName = 'eggs';
  final Box<dynamic> _box;

  EggRepository(this._box);

  static Future<EggRepository> create() async {
    final box = await Hive.openBox(_boxName);
    print('Got object store box in database $_boxName.');
    return EggRepository(box);
  }

  Future<List<Egg>> getAllEggs() async {
    final eggs = <Egg>[];

    for (var key in _box.keys) {
      final dynamic value = _box.get(key);
      if (value is Map) {
        eggs.add(Egg.fromJson(Map<String, dynamic>.from(value)));
      } else if (value is Egg) {
        eggs.add(value);
      }
    }

    return eggs;
  }

  Future<List<Egg>> getUnhatchedEggs() async {
    final eggs = await getAllEggs();
    return eggs.where((egg) => !egg.isHatched).toList();
  }

  Future<Egg?> getEggById(String id) async {
    final value = _box.get(id);
    if (value == null) return null;

    if (value is Map) {
      return Egg.fromJson(Map<String, dynamic>.from(value));
    } else if (value is Egg) {
      return value;
    }

    return null;
  }

  Future<Egg> addEgg({
    required CreatureRarity rarity,
    int experienceRequired = Egg.DEFAULT_HATCH_XP,
  }) async {
    final egg = Egg(id: const Uuid().v4(), rarity: rarity, experienceRequired: experienceRequired);

    await _box.put(egg.id, egg);
    return egg;
  }

  Future<Egg> updateEgg(Egg egg) async {
    await _box.put(egg.id, egg);
    return egg;
  }

  Future<void> deleteEgg(String id) async {
    await _box.delete(id);
  }

  Future<Egg> addExperiencePoints(String id, int points) async {
    final egg = await getEggById(id);
    if (egg == null) {
      throw Exception('Egg not found');
    }

    // Calculate how much XP is needed to reach the required amount
    final remainingXP = egg.experienceRequired - egg.experiencePoints;

    // Limit the added XP to the remaining amount needed
    final adjustedPoints = points > remainingXP ? remainingXP : points;

    // Only update if there's XP to add
    if (adjustedPoints <= 0) {
      return egg; // Already has enough or more XP
    }

    final updatedEgg = egg.addExperiencePoints(adjustedPoints);
    await _box.put(id, updatedEgg);
    return updatedEgg;
  }

  Future<Egg> hatchEgg(String id) async {
    final egg = await getEggById(id);
    if (egg == null) {
      throw Exception('Egg not found');
    }

    if (!egg.canHatch) {
      throw Exception('Egg does not have enough experience to hatch');
    }

    final hatchedEgg = egg.hatch();
    await _box.put(id, hatchedEgg);
    return hatchedEgg;
  }

  /// Initialize with starter eggs for new players
  Future<void> initializeStarterEggs() async {
    if (_box.isEmpty) {
      // Add 3 starter eggs
      await addEgg(rarity: CreatureRarity.COMMON);
      await addEgg(rarity: CreatureRarity.COMMON);
      await addEgg(rarity: CreatureRarity.UNCOMMON); // One slightly better egg
    }
  }

  /// Test the XP limiting functionality (for development verification only)
  /// This method should not be used in production
  Future<Map<String, dynamic>> testXpLimiting() async {
    // Create a test egg with 10 XP required
    final testEgg = await addEgg(rarity: CreatureRarity.COMMON, experienceRequired: 10);

    // Test case 1: Add 5 XP (within limit)
    final egg1 = await addExperiencePoints(testEgg.id, 5);

    // Test case 2: Add 10 XP (more than needed)
    final egg2 = await addExperiencePoints(egg1.id, 10);

    // Test case 3: Add more XP when already at max
    final egg3 = await addExperiencePoints(egg2.id, 5);

    // Clean up
    await deleteEgg(testEgg.id);

    return {
      'case1': {
        'added': 5,
        'expected': 5,
        'actual': egg1.experiencePoints,
        'success': egg1.experiencePoints == 5,
      },
      'case2': {
        'added': 10,
        'expected': 10, // Only 5 more should be added to reach 10
        'actual': egg2.experiencePoints,
        'success': egg2.experiencePoints == 10,
      },
      'case3': {
        'added': 5,
        'expected': 10, // No change since already at max
        'actual': egg3.experiencePoints,
        'success': egg3.experiencePoints == 10,
      },
      'overall':
          egg1.experiencePoints == 5 && egg2.experiencePoints == 10 && egg3.experiencePoints == 10,
    };
  }
}
