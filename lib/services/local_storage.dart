import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/resep.dart';

class LocalStorage {
  static const String validUsername = 'dhiara';
  static const String validPassword = '185';

  static Future<bool> login(String username, String password) async {
    if (username == validUsername && password == validPassword) {
      final loginData = await SharedPreferences.getInstance();
      await loginData.setBool('loginData', true);
      return true;
    }
    return false;
  }

  static Future<bool> isLoggedIn() async {
    final loginData = await SharedPreferences.getInstance();
    return loginData.getBool('loginData') ?? false;
  }

  static Future<void> logout() async {
    final loginData = await SharedPreferences.getInstance();
    await loginData.setBool('loginData', false);
  }

  static Box get _box => Hive.box('favorites');

  static ValueListenable<Box> get favoritesListenable => _box.listenable();

  static Future<void> addFavorite(Resep resep) async {
    await _box.put(resep.id, resep.toJson());
  }

  static Future<void> removeFavorite(int id) async {
    await _box.delete(id);
  }

  static bool isFavorite(int id) {
    return _box.containsKey(id);
  }

  static List<Resep> getFavorites() {
    return _box.values.map((e) {
      return Resep.fromJson(Map<String, dynamic>.from(e));
    }).toList();
  }
}
