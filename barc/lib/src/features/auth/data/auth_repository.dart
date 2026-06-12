import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:atproto/atproto.dart' as atp;
import 'package:atproto_core/atproto_core.dart' as core;

class AuthRepository {
  final FlutterSecureStorage _storage;
  
  static const _sessionKey = 'barc_app_session';

  AuthRepository(this._storage);

  Future<void> saveSession(core.Session session) async {
    await _storage.write(key: _sessionKey, value: jsonEncode(session.toJson()));
  }

  Future<core.Session?> getSession() async {
    final data = await _storage.read(key: _sessionKey);
    if (data == null) return null;
    return core.Session.fromJson(jsonDecode(data));
  }

  Future<core.Session> login(String handle, String password) async {
    final response = await atp.createSession(
      identifier: handle,
      password: password,
    );
    
    final session = response.data;
    await saveSession(session);
    return session;
  }
  
  Future<void> logout() async {
    await _storage.delete(key: _sessionKey);
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(const FlutterSecureStorage());
});

final authSessionProvider = FutureProvider<core.Session?>((ref) async {
  final repo = ref.watch(authRepositoryProvider);
  return await repo.getSession();
});
