import 'package:flutter/material.dart';

import 'package:latihan_responsi/models/restaurant_model.dart';
import 'package:latihan_responsi/network/api_exception.dart';
import 'package:latihan_responsi/network/api_service.dart';

abstract class RestaurantView {
  void showRestaurants(List<Restaurant> restaurants);
  void showRestaurantDetail(Restaurant restaurant);
  void showError(String message);
  void showLoading();
  void hideLoading();
}

class RestaurantPresenter extends ChangeNotifier {
  final ApiService _apiService;
  List<Restaurant> _restaurants = [];
  Restaurant? _selectedRestaurant;

  RestaurantPresenter(this._apiService);

  List<Restaurant> get restaurants => _restaurants;
  Restaurant? get selectedRestaurant => _selectedRestaurant;

  Future<List<Restaurant>> getRestaurants() async {
    try {
      _restaurants = await _apiService.getRestaurants();
      notifyListeners();
      return _restaurants;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Restaurant>> getRestaurantDetail(String id) async {
    try {
      _selectedRestaurant = await _apiService.getRestaurantDetail(id);
      notifyListeners();
      if (_selectedRestaurant != null) {
        return [_selectedRestaurant!];
      } else {
        return [];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Restaurant>> searchRestaurants(String query) async {
    try {
      _restaurants = await _apiService.searchRestaurants(query);
      notifyListeners();
      return _restaurants;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addReview(String id, String name, String review) async {
  try {
    final newReviews = await _apiService.addReview(id, name, review);

    if (newReviews.isEmpty) {
      throw ApiException('Review not added');
    }

    // Update the selected restaurant's reviews
    if (_selectedRestaurant != null && _selectedRestaurant!.id == id) {
      _selectedRestaurant = _selectedRestaurant!.copyWith(
        customerReviews: newReviews,
      );
    }

    final index = _restaurants.indexWhere((r) => r.id == id);
    if (index != -1) {
      _restaurants[index] = _restaurants[index].copyWith(
        customerReviews: newReviews,
      );
    }

    notifyListeners();
  } catch (e) {
    if (e is ApiException && e.toString().contains('timeout')) {
      await getRestaurantDetail(id);
    } else {
      rethrow;
    }
  }
}

}
