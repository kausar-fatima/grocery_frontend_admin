import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the JWT access token securely across app launches.
class TokenStorage {
  TokenStorage(this._storage);

  final FlutterSecureStorage _storage;

  static const _tokenKey = 'access_token';

  String? _cached;

  /// Synchronous access for the Dio interceptor (kept warm after [load]).
  String? get token => _cached;

  Future<String?> load() async {
    try {
      _cached = await _storage.read(key: _tokenKey);
    } catch (_) {
      // A key/algorithm mismatch (e.g. after reinstall) can make the stored
      // value unreadable. Treat it as "no session" and clear the bad entry
      // rather than letting session restore hang.
      _cached = null;
      await clear();
    }
    return _cached;
  }

  Future<void> save(String token) async {
    _cached = token;
    try {
      await _storage.write(key: _tokenKey, value: token);
    } catch (_) {
      // Persistence failed; the in-memory token still works for this session.
    }
  }

  Future<void> clear() async {
    _cached = null;
    try {
      await _storage.delete(key: _tokenKey);
    } catch (_) {
      // Ignore — nothing more we can do to remove it.
    }
  }
}
