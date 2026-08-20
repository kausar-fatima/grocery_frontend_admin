import 'package:equatable/equatable.dart';

import 'order.dart';

class AdminStats extends Equatable {
  final int totalUsers;
  final int customers;
  final int storeOwners;
  final int riders;
  final int pendingApprovals;
  final int totalProducts;
  final int totalStores;
  final int totalReviews;
  final int totalOrders;
  final double revenue;
  final Map<String, int> ordersByStatus;
  final List<Order> recentOrders;

  const AdminStats({
    this.totalUsers = 0,
    this.customers = 0,
    this.storeOwners = 0,
    this.riders = 0,
    this.pendingApprovals = 0,
    this.totalProducts = 0,
    this.totalStores = 0,
    this.totalReviews = 0,
    this.totalOrders = 0,
    this.revenue = 0,
    this.ordersByStatus = const {},
    this.recentOrders = const [],
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    final byStatus = <String, int>{};
    final raw = json['ordersByStatus'];
    if (raw is Map) {
      raw.forEach((k, v) => byStatus['$k'] = v is int ? v : int.tryParse('$v') ?? 0);
    }
    return AdminStats(
      totalUsers: _int(json['totalUsers']),
      customers: _int(json['customers']),
      storeOwners: _int(json['storeOwners']),
      riders: _int(json['riders']),
      pendingApprovals: _int(json['pendingApprovals']),
      totalProducts: _int(json['totalProducts']),
      totalStores: _int(json['totalStores']),
      totalReviews: _int(json['totalReviews']),
      totalOrders: _int(json['totalOrders']),
      revenue: json['revenue'] is num
          ? (json['revenue'] as num).toDouble()
          : double.tryParse('${json['revenue'] ?? 0}') ?? 0,
      ordersByStatus: byStatus,
      recentOrders: (json['recentOrders'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map(Order.fromJson)
              .toList() ??
          const [],
    );
  }

  static int _int(dynamic v) => v is int ? v : int.tryParse('${v ?? 0}') ?? 0;

  @override
  List<Object?> get props => [totalUsers, totalOrders, revenue, pendingApprovals];
}
