import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latihan_responsi/models/restaurant_model.dart';
import 'package:latihan_responsi/models/review_model.dart';
import 'package:latihan_responsi/network/api_exception.dart';

class ApiService {
  static const String _baseUrl = 'https://restaurant-api.dicoding.dev';

  Future<List<Restaurant>> getRestaurants() async {
    final response = await http.get(Uri.parse('$_baseUrl/list'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['error'] == false) {
        return List<Restaurant>.from(
            data['restaurants'].map((x) => Restaurant.fromJson(x)));
      } else {
        throw ApiException(data['message']);
      }
    } else {
      throw ApiException('Failed to load restaurants');
    }
  }

  Future<Restaurant> getRestaurantDetail(String id) async {
    final response = await http.get(Uri.parse('$_baseUrl/detail/$id'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['error'] == false) {
        return Restaurant.fromJson(data['restaurant']);
      } else {
        throw ApiException(data['message']);
      }
    } else {
      throw ApiException('Failed to load restaurant details');
    }
  }

  Future<List<Restaurant>> searchRestaurants(String query) async {
    final response = await http.get(Uri.parse('$_baseUrl/search?q=$query'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['error'] == false) {
        return List<Restaurant>.from(
            data['restaurants'].map((x) => Restaurant.fromJson(x)));
      } else {
        throw ApiException(data['message']);
      }
    } else {
      throw ApiException('Failed to search restaurants');
    }
  }

  Future<List<Review>> addReview(String id, String name, String review) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/review'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'id': id, 'name': name, 'review': review}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      if (data['error'] == false) {
        return List<Review>.from(
          data['customerReviews'].map((x) => Review.fromJson(x)),
        );
      } else {
        throw ApiException(data['message'] ?? 'Failed to add review');
      }
    } else {
      throw ApiException('Failed to add review: ${response.statusCode}');
    }
  }

  static String getRestaurantImageUrl(String pictureId,
      {String size = 'medium'}) {
    return '$_baseUrl/images/$size/$pictureId';
  }
}
