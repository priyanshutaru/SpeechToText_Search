class ProductResponse {
  late int id;
  late String title;
  late double price;
  late String description;
  late String category;
  late String image;
  late Rating rating;

  ProductResponse({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    required this.rating,
  });

  ProductResponse.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0000;
    title = json['title'] ?? "";
    price = (json['price'] as num).toDouble(); // Explicit conversion to double
    description = json['description'] ?? "";
    category = json['category'] ?? "";
    image = json['image'] ?? "";
    rating = json['rating'] != null
        ? Rating.fromJson(json['rating'])
        : Rating(rate: 0.0, count: 0);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['price'] = this.price;
    data['description'] = this.description;
    data['category'] = this.category;
    data['image'] = this.image;
    data['rating'] = this.rating.toJson();
    return data;
  }
}

class Rating {
  late double rate;
  late int count;

  Rating({required this.rate, required this.count});

  Rating.fromJson(Map<String, dynamic> json) {
    rate = (json['rate'] as num).toDouble(); // Explicit conversion to double
    count = json['count'] ?? 0000;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['rate'] = this.rate;
    data['count'] = this.count;
    return data;
  }
}