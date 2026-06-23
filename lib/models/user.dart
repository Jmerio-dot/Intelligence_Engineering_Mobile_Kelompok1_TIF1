class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final String status;
  final String? avatar;
  final String? bio;
  final String? location;
  final String? website;
  final int issueCount;
  final DateTime? createdAt;
  final DateTime? lastLogin;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'member',
    this.status = 'active',
    this.avatar,
    this.bio,
    this.location,
    this.website,
    this.issueCount = 0,
    this.createdAt,
    this.lastLogin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown User',
      email: json['email'] ?? '',
      role: json['role'] ?? 'member',
      status: json['status'] ?? 'active',
      avatar: json['avatar'],
      bio: json['bio'],
      location: json['location'],
      website: json['website'],
    );
  }

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }
}
