import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class AppNotification extends Equatable {
  final int id;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final int? orderId;
  final DateTime? createdAt;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    this.type = 'general',
    this.isRead = false,
    this.orderId,
    this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      title: (json['title'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
      type: (json['type'] ?? 'general').toString(),
      isRead: json['isRead'] as bool? ?? false,
      orderId: json['orderId'] == null
          ? null
          : (json['orderId'] is int
              ? json['orderId']
              : int.tryParse('${json['orderId']}')),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse('${json['createdAt']}')
          : null,
    );
  }

  IconData get icon => switch (type) {
        'order' => Icons.shopping_bag_outlined,
        'status' => Icons.local_shipping_outlined,
        'rider' => Icons.two_wheeler_rounded,
        'approval' => Icons.verified_outlined,
        'promo' => Icons.local_offer_outlined,
        _ => Icons.notifications_none_rounded,
      };

  String get timeAgo {
    if (createdAt == null) return '';
    final diff = DateTime.now().difference(createdAt!);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }

  AppNotification copyWith({bool? isRead}) => AppNotification(
        id: id,
        title: title,
        body: body,
        type: type,
        isRead: isRead ?? this.isRead,
        orderId: orderId,
        createdAt: createdAt,
      );

  @override
  List<Object?> get props => [id, isRead];
}
