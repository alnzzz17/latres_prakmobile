import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:latihan_responsi/models/user_model.dart';
import 'package:latihan_responsi/models/restaurant_model.dart';

class SharedPrefs {
  static const String _usersKey = 'users';
  static const String _loggedInUserKey = 'loggedInUser';
  static const String _favoritesKey = 'favorites';

  Future<List<User>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getStringList(_usersKey) ?? [];
    return usersJson.map((json) => User.fromJson(jsonDecode(json))).toList();
  }

  Future<void> saveUsers(List<User> users) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = users.map((user) => jsonEncode(user.toJson())).toList();
    await prefs.setStringList(_usersKey, usersJson);
  }

  Future<void> setLoggedInUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_loggedInUserKey, jsonEncode(user.toJson()));
  }

  Future<User?> getLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_loggedInUserKey);
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  Future<void> clearLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loggedInUserKey);
  }

// In shared_prefs.dart, verify these methods:
// In shared_prefs.dart, verify these methods:
Future<List<Restaurant>> getFavorites() async {
  final prefs = await SharedPreferences.getInstance();
  final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];
  return favoritesJson
      .map((json) => Restaurant.fromJson(jsonDecode(json)))
      .toList();
}

Future<void> saveFavorites(List<Restaurant> favorites) async {
  final prefs = await SharedPreferences.getInstance();
  final favoritesJson = 
      favorites.map((r) => jsonEncode(r.toJson())).toList();
  await prefs.setStringList(_favoritesKey, favoritesJson);
}
}