class Profile {
  final String id;
  final String? name;
  final String role;
  final String? avatarUrl;
  final DateTime createdAt;

  Profile({
    required this.id,
    this.name,
    required this.role,
    this.avatarUrl,
    required this.createdAt,
  });

  bool get isManager => role == 'manager';

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      name: json['name'] as String?,
      role: json['role'] as String? ?? 'staff',
      avatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
