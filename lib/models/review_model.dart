class Review {
  final String? name;
  final String? review;
  final String? date;

  Review({this.name, this.review, this.date});

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      name: json['name'],
      review: json['review'],
      date: json['date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'review': review,
      'date': date,
    };
  }
}
