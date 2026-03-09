class UserModel {
  const UserModel({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.role,
    required this.createdAt,
    this.avatarUrl,
    this.university,
    this.studentId,
  });

  final String id;
  final String fullName;
  final String phone;
  final String email;
  final UserRole role;
  final DateTime createdAt;
  final String? avatarUrl;
  final String? university;
  final String? studentId;

  // ── Convenience ────────────────────────────────────────────────────────────
  String get firstName => fullName.split(' ').first;
  bool get isOwner => role == UserRole.owner;
  bool get isAdmin => role == UserRole.admin;

  // ── Serialisation ──────────────────────────────────────────────────────────
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String? ?? '',
      role: UserRole.fromString(json['role'] as String? ?? 'student'),
      createdAt: DateTime.parse(json['created_at'] as String),
      avatarUrl: json['avatar_url'] as String?,
      university: json['university'] as String?,
      studentId: json['student_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'email': email,
      'role': role.value,
      'created_at': createdAt.toIso8601String(),
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (university != null) 'university': university,
      if (studentId != null) 'student_id': studentId,
    };
  }

  UserModel copyWith({
    String? fullName,
    String? phone,
    String? email,
    UserRole? role,
    String? avatarUrl,
    String? university,
    String? studentId,
  }) {
    return UserModel(
      id: id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      createdAt: createdAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      university: university ?? this.university,
      studentId: studentId ?? this.studentId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// ── UserRole ───────────────────────────────────────────────────────────────────
enum UserRole {
  student('student'),
  owner('owner'),
  admin('admin');

  const UserRole(this.value);
  final String value;

  static UserRole fromString(String v) {
    return UserRole.values.firstWhere(
      (e) => e.value == v,
      orElse: () => UserRole.student,
    );
  }
}
