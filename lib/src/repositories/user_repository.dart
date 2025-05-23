import 'dart:async';
import 'package:hive/hive.dart';
import 'package:task_tamer/src/models/user_profile.dart';
import 'package:uuid/uuid.dart';

class UserRepository {
  static const String _boxName = 'user_profile';
  static const String _userIdKey = 'user_id';
  final Box<Map<dynamic, dynamic>> _box;

  UserRepository(this._box);

  static Future<UserRepository> create() async {
    final box = await Hive.openBox<Map<dynamic, dynamic>>(_boxName);
    return UserRepository(box);
  }

  Future<UserProfile> getUserProfile() async {
    final userId = await _getUserId();
    final userData = _box.get(userId);

    if (userData != null) {
      return UserProfile.fromJson(Map<String, dynamic>.from(userData));
    }

    // Create a default profile if none exists
    final defaultProfile = UserProfile(id: userId, name: 'Player', experiencePoints: 0, level: 1);

    await _box.put(userId, defaultProfile.toJson());
    return defaultProfile;
  }

  Future<UserProfile> updateUserProfile(UserProfile userProfile) async {
    await _box.put(userProfile.id, userProfile.toJson());
    return userProfile;
  }

  Future<UserProfile> addExperiencePoints(int points) async {
    final user = await getUserProfile();
    final updatedUser = user.addExperiencePoints(points);
    await _box.put(user.id, updatedUser.toJson());
    return updatedUser;
  }

  Future<UserProfile> updateName(String name) async {
    final user = await getUserProfile();
    final updatedUser = user.copyWith(name: name);
    await _box.put(user.id, updatedUser.toJson());
    return updatedUser;
  }

  Future<UserProfile> updateAvatar(String avatarPath) async {
    final user = await getUserProfile();
    final updatedUser = user.copyWith(avatarPath: avatarPath);
    await _box.put(user.id, updatedUser.toJson());
    return updatedUser;
  }

  Future<String> _getUserId() async {
    final userIdBox = await Hive.openBox<String>('app_data');
    var userId = userIdBox.get(_userIdKey);

    if (userId == null) {
      userId = const Uuid().v4();
      await userIdBox.put(_userIdKey, userId);
    }

    return userId;
  }
}
