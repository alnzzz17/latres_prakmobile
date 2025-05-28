import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:latihan_responsi/models/restaurant_model.dart';
import 'package:latihan_responsi/presenters/auth_presenter.dart';
import 'package:latihan_responsi/presenters/restaurant_presenter.dart';
import 'package:latihan_responsi/views/favorite_screen.dart';
import 'package:latihan_responsi/views/restaurant_widget.dart';
import 'package:latihan_responsi/views/restaurant_detail_screen.dart';

class RestaurantListScreen extends StatefulWidget {
  const RestaurantListScreen({super.key});

  @override
  RestaurantListScreenState createState() => RestaurantListScreenState();
}

class RestaurantListScreenState extends State<RestaurantListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late Future<List<Restaurant>> _currentFuture;

  @override
  void initState() {
    super.initState();
    final restaurantPresenter = Provider.of<RestaurantPresenter>(context, listen: false);
    _currentFuture = restaurantPresenter.getRestaurants();
  }

  @override
  Widget build(BuildContext context) {
    final authPresenter = Provider.of<AuthPresenter>(context);
    final restaurantPresenter = Provider.of<RestaurantPresenter>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: FutureBuilder(
          future: authPresenter.getLoggedInUser(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(
                'Hello, ${snapshot.data!.username}',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            }
            return Text(
              'Restaurants',
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
        centerTitle: true,
        backgroundColor: theme.primaryColor,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavoriteScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await authPresenter.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                onChanged: _performSearch,
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search Restaurants',
                  labelStyle: theme.textTheme.bodyMedium,
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            _performSearch('');
                          },
                        )
                      : null,
                ),
                onSubmitted: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Restaurant>>(
              future: _currentFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: theme.primaryColor,
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: theme.colorScheme.error,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load restaurants',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please try again later',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _currentFuture = restaurantPresenter.getRestaurants();
                            });
                          },
                          child: Text(
                            'Retry',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.restaurant,
                          color: theme.primaryColor,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No restaurants available'
                              : 'No results found',
                          style: theme.textTheme.titleMedium,
                        ),
                        if (_searchQuery.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              _searchController.clear();
                              _performSearch('');
                            },
                            child: Text(
                              'Clear search',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.primaryColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                } else {
                  return RefreshIndicator(
                    color: theme.primaryColor,
                    onRefresh: () async {
                      setState(() {
                        _currentFuture = _searchQuery.isEmpty
                            ? restaurantPresenter.getRestaurants()
                            : restaurantPresenter.searchRestaurants(_searchQuery);
                      });
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final restaurant = snapshot.data![index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: RestaurantCard(
                            restaurant: restaurant,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RestaurantDetailScreen(
                                    restaurantId: restaurant.id!,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    final restaurantPresenter = Provider.of<RestaurantPresenter>(context, listen: false);
    setState(() {
      if (query.isEmpty) {
        _currentFuture = restaurantPresenter.getRestaurants();
      } else {
        _currentFuture = restaurantPresenter.searchRestaurants(query);
      }
    });
  }
}