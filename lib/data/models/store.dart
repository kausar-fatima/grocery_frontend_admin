import 'package:equatable/equatable.dart';

class Store extends Equatable {
  final int id;
  final String name;
  final String address;
  final String phone;
  final String? image;
  final bool isActive;
  final String? ownerName;
  final String? ownerEmail;

  const Store({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    this.image,
    this.isActive = true,
    this.ownerName,
    this.ownerEmail,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    final owner = json['owner'] as Map<String, dynamic>?;
    return Store(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      name: (json['name'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      image: json['image'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      ownerName: owner?['username']?.toString(),
      ownerEmail: owner?['email']?.toString(),
    );
  }

  @override
  List<Object?> get props => [id];
}
