/// Type d'utilisateur reconnu automatiquement à partir du login (JWT).
enum UserRole { client, agent }

/// IDs stables des rôles (API / JWT / stockage).
/// - [RoleIds.client] = "client"
/// - [RoleIds.agent] = "agent"
abstract class RoleIds {
  static const String client = 'client';
  static const String agent = 'agent';

  static int indexOf(UserRole role) => role.index;
  static UserRole? fromId(String id) {
    switch (id) {
      case client:
        return UserRole.client;
      case agent:
        return UserRole.agent;
      default:
        return null;
    }
  }
}

extension UserRoleExtension on UserRole {
  String get roleId => this == UserRole.client ? RoleIds.client : RoleIds.agent;
}

class AppUser {
  final String id;
  final String msisdn;
  final String token; // JWT
  final UserRole role;

  const AppUser({
    required this.id,
    required this.msisdn,
    required this.token,
    required this.role,
  });

  bool get isClient => role == UserRole.client;
  bool get isAgent => role == UserRole.agent;
}
