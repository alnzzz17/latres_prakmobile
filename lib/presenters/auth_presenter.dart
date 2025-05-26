import 'package:flutter/material.dart';

import 'package:latihan_responsi/models/user_model.dart';
import 'package:latihan_responsi/utils/shared_prefs.dart';


abstract class AuthView {
  void onLoginSuccess();
  void onLoginError(String message);
  void onRegisterSuccess();
  void onRegisterError(String message);
}

class AuthPresenter extends ChangeNotifier {
  final SharedPrefs _sharedPrefs;
  User? _currentUser;

  AuthPresenter(this._sharedPrefs);

  User? get currentUser => _currentUser;

  Future<void> login(String username, String password) async {
    try {
      final users = await _sharedPrefs.getUsers();
      final user = users.cast<User?>().firstWhere(
        (u) => u != null && u.username == username && u.password == password,
        orElse: () => User(username: '', password: ''),
      );

      if (user != null && user.username.isNotEmpty) {
        await _sharedPrefs.setLoggedInUser(user);
        _currentUser = user;
        notifyListeners();
      } else {
        throw Exception('Invalid username or password');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> register(String username, String password) async {
    try {
      final users = await _sharedPrefs.getUsers();
      if (users.cast<User?>().any((u) => u != null && u.username == username)) {
        throw Exception('Username already exists');
      }

      final newUser = User(username: username, password: password);
      users.add(newUser);
      await _sharedPrefs.saveUsers(users);
      await _sharedPrefs.setLoggedInUser(newUser);
      _currentUser = newUser;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _sharedPrefs.clearLoggedInUser();
    _currentUser = null;
    notifyListeners();
  }

  Future<User?> getLoggedInUser() async {
    _currentUser = await _sharedPrefs.getLoggedInUser();
    return _currentUser;
  }
}