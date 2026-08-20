import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  final int id;
  final String username;
  final String email;
  final String phone;
  final String role;
  final bool isApproved;

  const AppUser({
    required this.id,
    required this.username,
    required this.email,
    this.phone = '',
    this.role = 'STORE_OWNER',
    this.isApproved = false,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
        username: (json['username'] ?? '').toString(),
        email: (json['email'] ?? '').toString(),
        phone: (json['phone'] ?? '').toString(),
        role: (json['role'] ?? 'STORE_OWNER').toString(),
        isApproved: json['isApproved'] as bool? ?? false,
      );

  AppUser copyWith({String? role, bool? isApproved}) => AppUser(
        id: id,
        username: username,
        email: email,
        phone: phone,
        role: role ?? this.role,
        isApproved: isApproved ?? this.isApproved,
      );

  @override
  List<Object?> get props => [id, email, role, isApproved];
}
