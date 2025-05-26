import 'package:flutter/material.dart';
import 'package:latihan_responsi/network/api_service.dart';
import 'package:provider/provider.dart';
import 'package:latihan_responsi/models/restaurant_model.dart';
import 'package:latihan_responsi/presenters/restaurant_presenter.dart';
import 'package:latihan_responsi/presenters/favorite_presenter.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final String restaurantId;

  const RestaurantDetailScreen({
    super.key,
    required this.restaurantId,
  });

  @override
  _RestaurantDetailScreenState createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  late Future<Restaurant> _restaurantFuture;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _reviewController = TextEditingController();
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _restaurantFuture = Provider.of<RestaurantPresenter>(context, listen: false)
        .getRestaurantDetail(widget.restaurantId)
        .then((list) => list.first);
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final favoritePresenter =
        Provider.of<FavoritePresenter>(context, listen: false);
    bool isFav = await favoritePresenter.isFavorite(widget.restaurantId);
    if (mounted) {
      setState(() {
        _isFavorite = isFav;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final restaurantPresenter = Provider.of<RestaurantPresenter>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Restaurant Details',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.primaryColor,
        elevation: 4,
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.white : Colors.white.withOpacity(0.7),
            ),
            onPressed: () async {
              final favoritePresenter =
                  Provider.of<FavoritePresenter>(context, listen: false);
              final restaurant = await _restaurantFuture;

              if (_isFavorite) {
                await favoritePresenter.removeFavorite(widget.restaurantId);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Removed from favorites'),
                    backgroundColor: theme.primaryColor,
                  ),
                );
              } else {
                await favoritePresenter.addFavorite(restaurant);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Added to favorites'),
                    backgroundColor: theme.primaryColor,
                  ),
                );
              }

              if (mounted) {
                final updated =
                    await favoritePresenter.isFavorite(widget.restaurantId);
                setState(() {
                  _isFavorite = updated;
                });
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<Restaurant>(
        future: _restaurantFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: theme.primaryColor),
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
                    'Failed to load restaurant details',
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
                        _restaurantFuture = restaurantPresenter
                            .getRestaurantDetail(widget.restaurantId)
                            .then((list) => list.first);
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
          } else if (!snapshot.hasData) {
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
                    'No details available',
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
            );
          } else {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Restaurant Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      ApiService.getRestaurantImageUrl(
                        snapshot.data!.pictureId!,
                        size: 'large',
                      ),
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Restaurant Name and Rating
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            snapshot.data!.name ?? 'No name',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.location_on, 
                                  size: 16, 
                                  color: theme.primaryColor),
                              const SizedBox(width: 4),
                              Text(
                                snapshot.data!.city ?? 'Unknown city',
                                style: theme.textTheme.bodyMedium,
                              ),
                              const Spacer(),
                              Icon(Icons.star, 
                                  size: 16, 
                                  color: Colors.amber),
                              const SizedBox(width: 4),
                              Text(
                                snapshot.data!.rating?.toStringAsFixed(1) ?? '0.0',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Address Section
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Address',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            snapshot.data!.address ?? 'No address',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Categories Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Categories',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: snapshot.data!.categories
                                ?.map((category) => Chip(
                                      label: Text(
                                        category.name ?? '',
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                      backgroundColor: theme.primaryColor.withOpacity(0.1),
                                    ))
                                .toList() ??
                                [],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Description Section
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Description',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            snapshot.data!.description ?? 'No description',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Menus Section
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Menus',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Foods
                          Text(
                            'Foods',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Column(
                            children: snapshot.data!.menus?.foods
                                ?.map((food) => ListTile(
                                      leading: Icon(Icons.fastfood,
                                          color: theme.primaryColor),
                                      title: Text(
                                        food.name ?? '',
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                    ))
                                .toList() ??
                                [],
                          ),
                          const SizedBox(height: 16),
                          
                          // Drinks
                          Text(
                            'Drinks',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Column(
                            children: snapshot.data!.menus?.drinks
                                ?.map((drink) => ListTile(
                                      leading: Icon(Icons.local_drink,
                                          color: theme.primaryColor),
                                      title: Text(
                                        drink.name ?? '',
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                    ))
                                .toList() ??
                                [],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Reviews Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Customer Reviews',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...snapshot.data!.customerReviews
                              ?.map((review) => Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            review.name ?? 'Anonymous',
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            review.review ?? '',
                                            style: theme.textTheme.bodyMedium,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            review.date ?? '',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ))
                              .toList() ??
                              [],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Add Review Section
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add Review',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Name Input
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Your Name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Review Input
                          TextFormField(
                            controller: _reviewController,
                            decoration: InputDecoration(
                              labelText: 'Your Review',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.9),
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          
                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                              ),
                              onPressed: () async {
                                if (_nameController.text.isNotEmpty &&
                                    _reviewController.text.isNotEmpty) {
                                  try {
                                    await restaurantPresenter.addReview(
                                      widget.restaurantId,
                                      _nameController.text,
                                      _reviewController.text,
                                    );

                                    final refreshed = await restaurantPresenter
                                        .getRestaurantDetail(
                                            widget.restaurantId);

                                    if (mounted) {
                                      setState(() {
                                        _restaurantFuture = Future.value(
                                            refreshed.first);
                                      });
                                    }

                                    _nameController.clear();
                                    _reviewController.clear();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                            'Review added successfully'),
                                        backgroundColor: theme.primaryColor,
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Failed to add review: $e'),
                                        backgroundColor: theme.colorScheme.error,
                                      ),
                                    );
                                  }
                                }
                              },
                              child: Text(
                                'SUBMIT REVIEW',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _reviewController.dispose();
    super.dispose();
  }
}