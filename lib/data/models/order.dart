import 'package:equatable/equatable.dart';

import 'product.dart';

enum OrderStatus {
  accepted,
  preparing,
  ready,
  pickedUp,
  onTheWay,
  delivered,
  cancelled,
  unknown,
}

extension OrderStatusX on OrderStatus {
  String get label => switch (this) {
        OrderStatus.accepted => 'Accepted',
        OrderStatus.preparing => 'Preparing',
        OrderStatus.ready => 'Ready',
        OrderStatus.pickedUp => 'Picked up',
        OrderStatus.onTheWay => 'On the way',
        OrderStatus.delivered => 'Delivered',
        OrderStatus.cancelled => 'Cancelled',
        OrderStatus.unknown => 'Processing',
      };

  /// The value the backend expects for `PATCH /orders/:id/:status`.
  String get apiValue => switch (this) {
        OrderStatus.accepted => 'ACCEPTED',
        OrderStatus.preparing => 'PREPARING',
        OrderStatus.ready => 'READY',
        OrderStatus.pickedUp => 'PICKED_UP',
        OrderStatus.onTheWay => 'ON_THE_WAY',
        OrderStatus.delivered => 'DELIVERED',
        OrderStatus.cancelled => 'CANCELLED',
        OrderStatus.unknown => 'ACCEPTED',
      };

  static OrderStatus parse(String raw) => switch (raw.toUpperCase()) {
        'ACCEPTED' => OrderStatus.accepted,
        'PREPARING' => OrderStatus.preparing,
        'READY' => OrderStatus.ready,
        'PICKED_UP' => OrderStatus.pickedUp,
        'ON_THE_WAY' => OrderStatus.onTheWay,
        'DELIVERED' => OrderStatus.delivered,
        'CANCELLED' => OrderStatus.cancelled,
        _ => OrderStatus.unknown,
      };
}

class OrderItem extends Equatable {
  final int id;
  final int quantity;
  final double price;
  final double subtotal;
  final Product? product;

  const OrderItem({
    required this.id,
    required this.quantity,
    required this.price,
    required this.subtotal,
    this.product,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        id: _int(json['id']),
        quantity: _int(json['quantity']),
        price: _double(json['price']),
        subtotal: _double(json['subtotal']),
        product: json['product'] is Map<String, dynamic>
            ? Product.fromJson(json['product'])
            : null,
      );

  @override
  List<Object?> get props => [id];
}

class OrderCustomer {
  final int id;
  final String name;
  final String phone;
  const OrderCustomer({required this.id, required this.name, required this.phone});
}

class Order extends Equatable {
  final int id;
  final OrderStatus status;
  final double totalAmount;
  final double deliveryFee;
  final String? address;
  final String? shippingMethod;
  final List<OrderItem> items;
  final OrderCustomer? customer;
  final DateTime? createdAt;

  const Order({
    required this.id,
    required this.status,
    required this.totalAmount,
    this.deliveryFee = 0,
    this.address,
    this.shippingMethod,
    this.items = const [],
    this.customer,
    this.createdAt,
  });

  int get itemCount => items.fold(0, (s, i) => s + i.quantity);

  factory Order.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map(OrderItem.fromJson)
            .toList() ??
        const [];
    final user = json['user'] as Map<String, dynamic>?;
    return Order(
      id: _int(json['id']),
      status: OrderStatusX.parse((json['status'] ?? '').toString()),
      totalAmount: _double(json['totalAmount']),
      deliveryFee: _double(json['deliveryFee']),
      address: json['address'] as String?,
      shippingMethod: json['shippingMethod'] as String?,
      items: items,
      customer: user == null
          ? null
          : OrderCustomer(
              id: _int(user['id']),
              name: (user['username'] ?? 'Customer').toString(),
              phone: (user['phone'] ?? '').toString(),
            ),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse('${json['createdAt']}')
          : null,
    );
  }

  @override
  List<Object?> get props => [id, status];
}

int _int(dynamic v) => v is int ? v : int.tryParse('${v ?? 0}') ?? 0;
double _double(dynamic v) =>
    v is num ? v.toDouble() : double.tryParse('${v ?? 0}') ?? 0;
