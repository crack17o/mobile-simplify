import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_simplify/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Identifiants de démo (mock) pour tests.
/// - Client : MSISDN [DemoCredentials.clientMsisdn] + PIN [DemoCredentials.clientPin]
/// - Agent terrain : MSISDN [DemoCredentials.agentMsisdn] + PIN [DemoCredentials.agentPin]
abstract class DemoCredentials {
  /// Client simple — MSISDN
  static const String clientMsisdn = '243812345678';
  /// Client simple — PIN
  static const String clientPin = '0000';

  /// Agent de terrain — MSISDN
  static const String agentMsisdn = '243898765432';
  /// Agent de terrain — PIN
  static const String agentPin = '1234';
}

/// Service d'auth : login téléphone + PIN, JWT en retour.
/// Le type user (client/agent) est reconnu automatiquement via le JWT (claim role).
///
/// Pour l'instant : **données 100 % mockées** (aucun appel API).
/// Utiliser [DemoCredentials] pour se connecter en démo.
class AuthService {
  static const _keyUser = 'simplify_user';
  static const _keyToken = 'simplify_token';
  static const _secureKeyUser = 'simplify_secure_user';

  final _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;

  Future<void> loadFromStorage() async {
    String? json;
    try {
      json = await _secureStorage.read(key: _secureKeyUser);
    } catch (_) {}
    if (json == null || json.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      json = prefs.getString(_keyUser);
    }
    if (json != null && json.isNotEmpty) {
      try {
        final map = jsonDecode(json) as Map<String, dynamic>;
        _currentUser = AppUser(
          id: map['id'] as String,
          msisdn: map['msisdn'] as String,
          token: map['token'] as String,
          role: map['role'] == 'agent' ? UserRole.agent : UserRole.client,
        );
      } catch (_) {
        await _clearStorage();
      }
    }
  }

  Future<void> _clearStorage() async {
    try {
      await _secureStorage.delete(key: _secureKeyUser);
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUser);
    await prefs.remove(_keyToken);
  }

  Future<void> _persistUser(String json) async {
    try {
      await _secureStorage.write(key: _secureKeyUser, value: json);
    } catch (_) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUser, json);
    }
  }

  Future<AppUser?> login({required String msisdn, required String pin}) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final isAgent = pin == DemoCredentials.agentPin;
    final role = isAgent ? UserRole.agent : UserRole.client;
    final id = isAgent ? 'AGT001' : 'CLI001';
    final token = 'mock_jwt_${msisdn}_${role.name}_${DateTime.now().millisecondsSinceEpoch}';

    _currentUser = AppUser(id: id, msisdn: msisdn, token: token, role: role);

    final json = jsonEncode({
      'id': _currentUser!.id,
      'msisdn': _currentUser!.msisdn,
      'token': _currentUser!.token,
      'role': role.name,
    });
    await _persistUser(json);

    return _currentUser;
  }

  Future<void> logout() async {
    _currentUser = null;
    await _clearStorage();
  }
}
