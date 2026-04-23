import '../core/enums/user_role.dart';

class UserModel {
  const UserModel({
    this.id,
    required this.militaryId,
    required this.fullName,
    required this.role,
    this.unit,
    this.phone,
    required this.passwordHash,
    required this.createdAt,
    this.lastActive,
  });

  final int? id;
  final String militaryId;
  final String fullName;
  final String role;
  final String? unit;
  final String? phone;
  final String passwordHash;
  final String createdAt;
  final String? lastActive;

  UserModel copyWith({
    int? id,
    String? militaryId,
    String? fullName,
    String? role,
    String? unit,
    String? phone,
    String? passwordHash,
    String? createdAt,
    String? lastActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      militaryId: militaryId ?? this.militaryId,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      unit: unit ?? this.unit,
      phone: phone ?? this.phone,
      passwordHash: passwordHash ?? this.passwordHash,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'military_id': militaryId,
      'full_name': fullName,
      'role': role,
      'unit': unit,
      'phone': phone,
      'password_hash': passwordHash,
      'created_at': createdAt,
      'last_active': lastActive,
    };
  }

  static UserModel fromMap(Map<String, Object?> map) {
    final r = map['role'] as String? ?? 'soldier';
    if (userRoleFromString(r) == null) {
      throw ArgumentError('Invalid role: $r');
    }
    return UserModel(
      id: map['id'] as int?,
      militaryId: map['military_id'] as String,
      fullName: map['full_name'] as String,
      role: r,
      unit: map['unit'] as String?,
      phone: map['phone'] as String?,
      passwordHash: map['password_hash'] as String,
      createdAt: map['created_at'] as String,
      lastActive: map['last_active'] as String?,
    );
  }
}
