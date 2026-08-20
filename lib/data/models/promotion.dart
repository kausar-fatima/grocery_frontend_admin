import 'package:equatable/equatable.dart';

/// An admin-managed promotional discount.
class Promotion extends Equatable {
  final int id;
  final String title;
  final String description;
  final int discountPercent;
  final bool active;
  final bool firstOrderOnly;
  final double minSubtotal;

  const Promotion({
    required this.id,
    required this.title,
    this.description = '',
    this.discountPercent = 0,
    this.active = true,
    this.firstOrderOnly = false,
    this.minSubtotal = 0,
  });

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse('$v') ?? 0;
  }

  factory Promotion.fromJson(Map<String, dynamic> json) => Promotion(
        id: _toInt(json['id']),
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        discountPercent: _toInt(json['discountPercent']),
        active: json['active'] == true,
        firstOrderOnly: json['firstOrderOnly'] == true,
        minSubtotal: _toDouble(json['minSubtotal']),
      );

  Promotion copyWith({bool? active}) => Promotion(
        id: id,
        title: title,
        description: description,
        discountPercent: discountPercent,
        active: active ?? this.active,
        firstOrderOnly: firstOrderOnly,
        minSubtotal: minSubtotal,
      );

  @override
  List<Object?> get props =>
      [id, title, description, discountPercent, active, firstOrderOnly, minSubtotal];
}
