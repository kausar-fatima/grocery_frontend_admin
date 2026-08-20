import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/network/api_exception.dart';
import '../../core/storage/token_storage.dart';
import '../../data/api/auth_api.dart';
import '../../data/models/app_user.dart';

enum AuthStatus { unknown, authenticated, unauthenticated, loading }

class AuthState extends Equatable {
  final AuthStatus status;
  final AppUser? user;
  final String? error;

  const AuthState({this.status = AuthStatus.unknown, this.user, this.error});

  AuthState copyWith({AuthStatus? status, AppUser? user, String? error}) =>
      AuthState(
        status: status ?? this.status,
        user: user ?? this.user,
        error: error,
      );

  @override
  List<Object?> get props => [status, user, error];
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._authApi, this._tokenStorage) : super(const AuthState());

  final AuthApi _authApi;
  final TokenStorage _tokenStorage;

  int? get userId => state.user?.id;

  Future<void> loadSession() async {
    try {
      final token = await _tokenStorage.load();
      if (token == null || token.isEmpty) {
        emit(const AuthState(status: AuthStatus.unauthenticated));
        return;
      }
      final user = await _authApi.profile();
      if (user.role != 'ADMIN') {
        await _tokenStorage.clear();
        emit(const AuthState(status: AuthStatus.unauthenticated));
        return;
      }
      emit(AuthState(status: AuthStatus.authenticated, user: user));
    } catch (_) {
      await _tokenStorage.clear();
      emit(const AuthState(status: AuthStatus.unauthenticated));
    }
  }

  Future<bool> login(String email, String password) async {
    emit(state.copyWith(status: AuthStatus.loading, error: null));
    try {
      final result = await _authApi.login(email: email, password: password);
      if (result.user.role != 'ADMIN') {
        await _tokenStorage.clear();
        emit(const AuthState(
          status: AuthStatus.unauthenticated,
          error: 'This account is not an administrator.',
        ));
        return false;
      }
      await _tokenStorage.save(result.token);
      emit(AuthState(status: AuthStatus.authenticated, user: result.user));
      return true;
    } on ApiException catch (e) {
      emit(AuthState(status: AuthStatus.unauthenticated, error: e.message));
      return false;
    }
  }

  Future<void> logout() async {
    await _tokenStorage.clear();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
