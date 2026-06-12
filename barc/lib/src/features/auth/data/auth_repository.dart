import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:atproto_oauth/atproto_oauth.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

class AuthRepository {
  final FlutterSecureStorage _storage;
  
  static const _sessionKey = 'barc_oauth_session';
  static const _authNonceKey = 'barc_auth_nonce';
  static const _pdsNonceKey = 'barc_pds_nonce';

  AuthRepository(this._storage);

  Map<String, dynamic> _sessionToJson(OAuthSession session) => {
    'accessToken': session.accessToken,
    'refreshToken': session.refreshToken,
    'tokenType': session.tokenType,
    'scope': session.scope,
    'expiresAt': session.expiresAt.toIso8601String(),
    'sub': session.sub,
    'dPoPNonce': session.$dPoPNonce,
    'publicKey': session.$publicKey,
    'privateKey': session.$privateKey,
  };

  OAuthSession _sessionFromJson(Map<String, dynamic> json) => OAuthSession(
    accessToken: json['accessToken'],
    refreshToken: json['refreshToken'],
    tokenType: json['tokenType'],
    scope: json['scope'],
    expiresAt: DateTime.parse(json['expiresAt']),
    sub: json['sub'],
    $dPoPNonce: json['dPoPNonce'],
    $publicKey: json['publicKey'],
    $privateKey: json['privateKey'],
  );

  Future<void> saveSession(OAuthSession session) async {
    await _storage.write(key: _sessionKey, value: jsonEncode(_sessionToJson(session)));
  }

  Future<OAuthSession?> getSession() async {
    final data = await _storage.read(key: _sessionKey);
    if (data == null) return null;
    return _sessionFromJson(jsonDecode(data));
  }

  Future<void> saveAuthServerNonce(String nonce) async {
    await _storage.write(key: _authNonceKey, value: nonce);
  }

  Future<String?> getAuthServerNonce() async {
    return _storage.read(key: _authNonceKey);
  }

  Future<void> savePdsNonce(String nonce) async {
    await _storage.write(key: _pdsNonceKey, value: nonce);
  }

  Future<String?> getPdsNonce() async {
    return _storage.read(key: _pdsNonceKey);
  }

  Future<OAuthSession> login(String handle) async {
    final metadata = await getClientMetadata(
      'https://atprotodart.com/oauth/bluesky/atprotodart/client-metadata.json'
    );
    
    final client = OAuthClient(metadata);
    final (authUrl, ctx) = await client.authorize(handle);

    final resultUrl = await FlutterWebAuth2.authenticate(
      url: authUrl.toString(),
      callbackUrlScheme: 'barc', 
    );

    // Assuming client.callback requires the redirectUrl and the state/context
    // We pass it to get the OAuthSession.
    final session = await client.callback(resultUrl, ctx);
    
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

final authSessionProvider = FutureProvider<OAuthSession?>((ref) async {
  final repo = ref.watch(authRepositoryProvider);
  return await repo.getSession();
});
