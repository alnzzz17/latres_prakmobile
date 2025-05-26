import 'package:flutter/material.dart';

import 'package:latihan_responsi/models/restaurant_model.dart';
import 'package:latihan_responsi/utils/shared_prefs.dart';


abstract class FavoriteView {
  void showFavorites(List<Restaurant> favorites);
  void showError(String message);
}

class FavoritePresenter extends ChangeNotifier {
  final SharedPrefs _sharedPrefs;
  List<Restaurant> _favorites = [];

  FavoritePresenter(this._sharedPrefs);

  List<Restaurant> get favorites => _favorites;

  Future<List<Restaurant>> getFavorites() async {
    try {
      _favorites = await _sharedPrefs.getFavorites();
      notifyListeners();
      return _favorites;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addFavorite(Restaurant restaurant) async {
    try {
      if (!_favorites.any((r) => r.id == restaurant.id)) {
        _favorites.add(restaurant);
        await _sharedPrefs.saveFavorites(_favorites);
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeFavorite(String restaurantId) async {
    try {
      _favorites.removeWhere((r) => r.id == restaurantId);
      await _sharedPrefs.saveFavorites(_favorites);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isFavorite(String restaurantId) async {
    try {
      final currentFavorites = await _sharedPrefs.getFavorites();
      return currentFavorites.any((r) => r.id == restaurantId);
    } catch (e) {
      rethrow;
    }
  }
}
