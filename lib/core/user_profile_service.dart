import 'package:shared_preferences/shared_preferences.dart';

/// Profil client (onboarding) : nom, prénom, adresse, activité.
class UserProfileService {
  static const _keyOnboardingDone = 'simplify_onboarding_done';
  static const _keyFirstName = 'simplify_profile_first_name';
  static const _keyLastName = 'simplify_profile_last_name';
  static const _keyAddress = 'simplify_profile_address';
  static const _keyCommune = 'simplify_profile_commune';
  static const _keyActivite = 'simplify_profile_activite';

  static const activites = [
    'Commerce',
    'Agriculture',
    'Artisanat',
    'Service',
    'Emploi salarié',
    'Autre',
  ];

  Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingDone) ?? false;
  }

  Future<void> setOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingDone, true);
  }

  Future<String?> getFirstName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyFirstName);
  }

  Future<String?> getLastName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastName);
  }

  Future<String?> getAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAddress);
  }

  Future<String?> getCommune() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCommune);
  }

  Future<String?> getActivite() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyActivite);
  }

  Future<void> saveProfile({
    required String firstName,
    required String lastName,
    String? address,
    String? commune,
    String? activite,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFirstName, firstName);
    await prefs.setString(_keyLastName, lastName);
    if (address != null) await prefs.setString(_keyAddress, address);
    if (commune != null) await prefs.setString(_keyCommune, commune);
    if (activite != null) await prefs.setString(_keyActivite, activite);
  }
}
