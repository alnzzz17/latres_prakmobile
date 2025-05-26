import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:latihan_responsi/models/restaurant_model.dart';
import 'package:latihan_responsi/presenters/favorite_presenter.dart';
import 'package:latihan_responsi/views/restaurant_widget.dart';
import 'package:latihan_responsi/views/restaurant_detail_screen.dart'; // Added missing import

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  late Future<List<Restaurant>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    final favoritePresenter = Provider.of<FavoritePresenter>(context, listen: false);
    _favoritesFuture = favoritePresenter.getFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorite Restaurants')),
      body: FutureBuilder<List<Restaurant>>(
        future: _favoritesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No favorite restaurants'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final restaurant = snapshot.data![index];
                return RestaurantCard(
                  restaurant: restaurant,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RestaurantDetailScreen(
                          restaurantId: restaurant.id!,
                        ),
                      ),
                    ).then((_) {
                      // Refresh data again when user comes back from detail
                      setState(() {
                        final favoritePresenter =
                            Provider.of<FavoritePresenter>(context, listen: false);
                        _favoritesFuture = favoritePresenter.getFavorites();
                      });
                    });
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
