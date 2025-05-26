import 'package:latihan_responsi/models/review_model.dart';

class Restaurant {
  final String? id;
  final String? name;
  final String? description;
  final String? pictureId;
  final String? city;
  final double? rating;
  final String? address;
  final List<Category>? categories;
  final Menus? menus;
  final List<Review>? customerReviews;

  Restaurant({
    this.id,
    this.name,
    this.description,
    this.pictureId,
    this.city,
    this.rating,
    this.address,
    this.categories,
    this.menus,
    this.customerReviews,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      pictureId: json['pictureId'],
      city: json['city'],
      rating: (json['rating'] as num?)?.toDouble(),
      address: json['address'],
      categories: json['categories'] != null
          ? List<Category>.from(json['categories'].map((x) => Category.fromJson(x)))
          : null,
      menus: json['menus'] != null ? Menus.fromJson(json['menus']) : null,
      customerReviews: json['customerReviews'] != null
          ? List<Review>.from(json['customerReviews'].map((x) => Review.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'pictureId': pictureId,
      'city': city,
      'rating': rating,
      'address': address,
      'categories': categories?.map((x) => x.toJson()).toList(),
      'menus': menus?.toJson(),
      'customerReviews': customerReviews?.map((x) => x.toJson()).toList(),
    };
  }

  Restaurant copyWith({
  String? id,
  String? name,
  String? description,
  String? pictureId,
  String? city,
  double? rating,
  String? address,
  List<Category>? categories,
  Menus? menus,
  List<Review>? customerReviews,
}) {
  return Restaurant(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    pictureId: pictureId ?? this.pictureId,
    city: city ?? this.city,
    rating: rating ?? this.rating,
    address: address ?? this.address,
    categories: categories ?? this.categories,
    menus: menus ?? this.menus,
    customerReviews: customerReviews ?? this.customerReviews,
  );
}
}

class Category {
  final String? name;

  Category({this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}

class Menus {
  final List<MenuItem>? foods;
  final List<MenuItem>? drinks;

  Menus({this.foods, this.drinks});

  factory Menus.fromJson(Map<String, dynamic> json) {
    return Menus(
      foods: json['foods'] != null
          ? List<MenuItem>.from(json['foods'].map((x) => MenuItem.fromJson(x)))
          : null,
      drinks: json['drinks'] != null
          ? List<MenuItem>.from(json['drinks'].map((x) => MenuItem.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'foods': foods?.map((x) => x.toJson()).toList(),
      'drinks': drinks?.map((x) => x.toJson()).toList(),
    };
  }
}


class MenuItem {
  final String? name;

  MenuItem({this.name});

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}
