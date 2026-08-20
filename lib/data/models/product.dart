import 'package:equatable/equatable.dart';

import '../../core/utils/food_emoji.dart';

class Product extends Equatable {
  final int id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String? image;
  final bool isAvailable;
  final int categoryId;
  final String categoryName;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    this.image,
    this.isAvailable = true,
    required this.categoryId,
    required this.categoryName,
  });

  bool get inStock => isAvailable && stock > 0;

  String get displayImage => (image != null && image!.trim().isNotEmpty)
      ? image!
      : FoodEmoji.forName(name);

  factory Product.fromJson(Map<String, dynamic> json) {
    final category = json['category'] as Map<String, dynamic>?;
    return Product(
      id: _int(json['id']),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      price: _double(json['price']),
      stock: _int(json['stock']),
      image: json['image'] as String?,
      isAvailable: json['isAvailable'] as bool? ?? true,
      categoryId: _int(category?['id'] ?? json['categoryId']),
      categoryName: (category?['name'] ?? 'Grocery').toString(),
    );
  }

  static int _int(dynamic v) => v is int ? v : int.tryParse('${v ?? 0}') ?? 0;
  static double _double(dynamic v) =>
      v is num ? v.toDouble() : double.tryParse('${v ?? 0}') ?? 0;

  @override
  List<Object?> get props => [id];
}
