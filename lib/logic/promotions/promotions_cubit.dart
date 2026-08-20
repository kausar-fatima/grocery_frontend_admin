import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/network/api_exception.dart';
import '../../data/api/promotions_api.dart';
import '../../data/models/promotion.dart';

enum PromoLoad { initial, loading, loaded, error }

class PromotionsState extends Equatable {
  final PromoLoad status;
  final List<Promotion> items;
  final String? error;

  const PromotionsState({
    this.status = PromoLoad.initial,
    this.items = const [],
    this.error,
  });

  PromotionsState copyWith({
    PromoLoad? status,
    List<Promotion>? items,
    String? error,
  }) =>
      PromotionsState(
        status: status ?? this.status,
        items: items ?? this.items,
        error: error,
      );

  @override
  List<Object?> get props => [status, items, error];
}

class PromotionsCubit extends Cubit<PromotionsState> {
  PromotionsCubit(this._api) : super(const PromotionsState());

  final PromotionsApi _api;

  Future<void> load() async {
    emit(state.copyWith(status: PromoLoad.loading, error: null));
    try {
      final items = await _api.getAll();
      emit(state.copyWith(status: PromoLoad.loaded, items: items));
    } on ApiException catch (e) {
      emit(state.copyWith(status: PromoLoad.error, error: e.message));
    }
  }

  Future<bool> create(Map<String, dynamic> body) async {
    try {
      await _api.create(body);
      await load();
      return true;
    } on ApiException catch (e) {
      emit(state.copyWith(error: e.message));
      return false;
    }
  }

  Future<bool> update(int id, Map<String, dynamic> body) async {
    try {
      await _api.update(id, body);
      await load();
      return true;
    } on ApiException catch (e) {
      emit(state.copyWith(error: e.message));
      return false;
    }
  }

  /// Toggle active (optimistic).
  Future<void> toggleActive(Promotion promo) async {
    final next = promo.copyWith(active: !promo.active);
    emit(state.copyWith(
      items: state.items.map((p) => p.id == promo.id ? next : p).toList(),
    ));
    try {
      await _api.update(promo.id, {'active': next.active});
    } on ApiException catch (e) {
      // Revert on failure.
      emit(state.copyWith(
        items: state.items.map((p) => p.id == promo.id ? promo : p).toList(),
        error: e.message,
      ));
    }
  }

  Future<bool> remove(int id) async {
    final previous = state.items;
    emit(state.copyWith(items: previous.where((p) => p.id != id).toList()));
    try {
      await _api.remove(id);
      return true;
    } on ApiException catch (e) {
      emit(state.copyWith(items: previous, error: e.message));
      return false;
    }
  }
}
