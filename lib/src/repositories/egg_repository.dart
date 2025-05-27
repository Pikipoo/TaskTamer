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

    final updatedEgg = egg.addExperiencePoints(points);
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
}
