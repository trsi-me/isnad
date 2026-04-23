enum UserRole {
  soldier,
  command,
  hospital,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.soldier:
        return 'عسكري ميداني';
      case UserRole.command:
        return 'قيادة';
      case UserRole.hospital:
        return 'مستشفى';
    }
  }

  String get value => name;
}

UserRole? userRoleFromString(String? raw) {
  if (raw == null) return null;
  for (final r in UserRole.values) {
    if (r.value == raw) return r;
  }
  return null;
}
