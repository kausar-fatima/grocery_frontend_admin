import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/network/api_exception.dart';
import '../../data/api/admin_api.dart';
import '../../data/api/reviews_api.dart';
import '../../data/models/admin_stats.dart';
import '../../data/models/app_user.dart';
import '../../data/models/order.dart';
import '../../data/models/review.dart';
import '../../data/models/store.dart';

enum Load { initial, loading, loaded, error }

class AdminState extends Equatable {
  final Load statsStatus;
  final AdminStats? stats;
  final Load usersStatus;
  final List<AppUser> users;
  final Load storesStatus;
  final List<Store> stores;
  final Load ordersStatus;
  final List<Order> orders;
  final Load reviewsStatus;
  final List<Review> reviews;
  final String? error;

  const AdminState({
    this.statsStatus = Load.initial,
    this.stats,
    this.usersStatus = Load.initial,
    this.users = const [],
    this.storesStatus = Load.initial,
    this.stores = const [],
    this.ordersStatus = Load.initial,
    this.orders = const [],
    this.reviewsStatus = Load.initial,
    this.reviews = const [],
    this.error,
  });

  List<AppUser> get pending =>
      users.where((u) => !u.isApproved && u.role != 'CUSTOMER').toList();

  AdminState copyWith({
    Load? statsStatus,
    AdminStats? stats,
    Load? usersStatus,
    List<AppUser>? users,
    Load? storesStatus,
    List<Store>? stores,
    Load? ordersStatus,
    List<Order>? orders,
    Load? reviewsStatus,
    List<Review>? reviews,
    String? error,
  }) =>
      AdminState(
        statsStatus: statsStatus ?? this.statsStatus,
        stats: stats ?? this.stats,
        usersStatus: usersStatus ?? this.usersStatus,
        users: users ?? this.users,
        storesStatus: storesStatus ?? this.storesStatus,
        stores: stores ?? this.stores,
        ordersStatus: ordersStatus ?? this.ordersStatus,
        orders: orders ?? this.orders,
        reviewsStatus: reviewsStatus ?? this.reviewsStatus,
        reviews: reviews ?? this.reviews,
        error: error,
      );

  @override
  List<Object?> get props => [
        statsStatus,
        stats,
        usersStatus,
        users,
        storesStatus,
        stores,
        ordersStatus,
        orders,
        reviewsStatus,
        reviews,
        error,
      ];
}

/// Backs the whole admin console (dashboard, users, stores, orders, reviews).
class AdminCubit extends Cubit<AdminState> {
  AdminCubit(this._api, this._reviewsApi) : super(const AdminState());

  final AdminApi _api;
  final ReviewsApi _reviewsApi;

  Future<void> loadAll() async {
    await Future.wait([loadStats(), loadUsers()]);
  }

  Future<void> loadStats() async {
    emit(state.copyWith(statsStatus: Load.loading, error: null));
    try {
      final stats = await _api.stats();
      emit(state.copyWith(statsStatus: Load.loaded, stats: stats));
    } on ApiException catch (e) {
      emit(state.copyWith(statsStatus: Load.error, error: e.message));
    }
  }

  Future<void> loadUsers({String? role}) async {
    emit(state.copyWith(usersStatus: Load.loading, error: null));
    try {
      final users = await _api.users(role: role);
      emit(state.copyWith(usersStatus: Load.loaded, users: users));
    } on ApiException catch (e) {
      emit(state.copyWith(usersStatus: Load.error, error: e.message));
    }
  }

  Future<void> loadStores() async {
    emit(state.copyWith(storesStatus: Load.loading, error: null));
    try {
      final stores = await _api.stores();
      emit(state.copyWith(storesStatus: Load.loaded, stores: stores));
    } on ApiException catch (e) {
      emit(state.copyWith(storesStatus: Load.error, error: e.message));
    }
  }

  Future<void> loadOrders() async {
    emit(state.copyWith(ordersStatus: Load.loading, error: null));
    try {
      final orders = await _api.orders();
      emit(state.copyWith(ordersStatus: Load.loaded, orders: orders));
    } on ApiException catch (e) {
      emit(state.copyWith(ordersStatus: Load.error, error: e.message));
    }
  }

  Future<void> loadReviews() async {
    emit(state.copyWith(reviewsStatus: Load.loading, error: null));
    try {
      final reviews = await _reviewsApi.getAll();
      emit(state.copyWith(reviewsStatus: Load.loaded, reviews: reviews));
    } on ApiException catch (e) {
      emit(state.copyWith(reviewsStatus: Load.error, error: e.message));
    }
  }

  Future<bool> approve(int id, bool approved) async {
    try {
      await _api.setApproval(id, approved);
      emit(state.copyWith(
        users: state.users
            .map((u) => u.id == id ? u.copyWith(isApproved: approved) : u)
            .toList(),
      ));
      loadStats();
      return true;
    } on ApiException catch (e) {
      emit(state.copyWith(error: e.message));
      return false;
    }
  }

  Future<bool> setRole(int id, String role) async {
    try {
      await _api.setRole(id, role);
      await loadUsers();
      return true;
    } on ApiException catch (e) {
      emit(state.copyWith(error: e.message));
      return false;
    }
  }

  Future<bool> deleteUser(int id) async {
    final previous = state.users;
    emit(state.copyWith(users: state.users.where((u) => u.id != id).toList()));
    try {
      await _api.deleteUser(id);
      loadStats();
      return true;
    } on ApiException catch (e) {
      emit(state.copyWith(users: previous, error: e.message));
      return false;
    }
  }

  Future<bool> deleteReview(int id) async {
    final previous = state.reviews;
    emit(state.copyWith(
        reviews: state.reviews.where((r) => r.id != id).toList()));
    try {
      await _reviewsApi.delete(id);
      return true;
    } on ApiException catch (e) {
      emit(state.copyWith(reviews: previous, error: e.message));
      return false;
    }
  }
}
