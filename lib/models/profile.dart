class Profile {
  final String id;
  final String? fullName;
  final String? phone;
  final bool isAdmin;
  final DateTime createdAt;

  const Profile({
    required this.id,
    this.fullName,
    this.phone,
    this.isAdmin = false,
    required this.createdAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      fullName: json['full_name'] as String?,
      phone: json['phone'] as String?,
      isAdmin: json['is_admin'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}