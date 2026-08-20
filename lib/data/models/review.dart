import 'package:equatable/equatable.dart';

class Review extends Equatable {
  final int id;
  final int rating;
  final String comment;
  final int? productId;
  final int? orderId;
  final String userName;
  final DateTime? createdAt;

  const Review({
    required this.id,
    required this.rating,
    required this.comment,
    this.productId,
    this.orderId,
    this.userName = 'User',
    this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    return Review(
      id: _int(json['id']),
      rating: _int(json['rating']),
      comment: (json['comment'] ?? '').toString(),
      productId: json['productId'] == null ? null : _int(json['productId']),
      orderId: json['orderId'] == null ? null : _int(json['orderId']),
      userName: (user?['username'] ?? 'User').toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse('${json['createdAt']}')
          : null,
    );
  }

  static int _int(dynamic v) => v is int ? v : int.tryParse('${v ?? 0}') ?? 0;

  @override
  List<Object?> get props => [id];
}
