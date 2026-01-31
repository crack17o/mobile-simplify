import 'package:shared_preferences/shared_preferences.dart';

/// Stockage local des infos profil (nom affiché, email) pour le client.
class ProfileService {
  static const _keyDisplayName = 'simplify_profile_display_name';
  static const _keyEmail = 'simplify_profile_email';

  Future<String?> getDisplayName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyDisplayName);
  }

  Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail);
  }

  Future<void> setDisplayName(String? value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value == null || value.isEmpty) {
      await prefs.remove(_keyDisplayName);
    } else {
      await prefs.setString(_keyDisplayName, value);
    }
  }

  Future<void> setEmail(String? value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value == null || value.isEmpty) {
      await prefs.remove(_keyEmail);
    } else {
      await prefs.setString(_keyEmail, value);
    }
  }

  Future<void> save({String? displayName, String? email}) async {
    final prefs = await SharedPreferences.getInstance();
    if (displayName != null) {
      if (displayName.isEmpty) {
        await prefs.remove(_keyDisplayName);
      } else {
        await prefs.setString(_keyDisplayName, displayName);
      }
    }
    if (email != null) {
      if (email.isEmpty) {
        await prefs.remove(_keyEmail);
      } else {
        await prefs.setString(_keyEmail, email);
      }
    }
  }
}
