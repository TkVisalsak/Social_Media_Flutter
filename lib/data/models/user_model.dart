class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    this.username,
    this.name,
    this.avatarUrl,
    this.bio,
  });

  final String id;
  final String email;
  final String? username;
  final String? name;
  final String? avatarUrl;
  final String? bio;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      username: _nullableString(
        json['username'] ??
            json['userName'] ??
            json['user_name'] ??
            json['handle'],
      ),
      name: _nullableString(
        json['name'] ??
            json['full_name'] ??
            json['fullName'] ??
            json['display_name'] ??
            json['displayName'],
      ),
      avatarUrl: _nullableString(
        json['avatar_url'] ??
            json['avatarUrl'] ??
            json['avatar'] ??
            json['profilePicture'] ??
            json['profile_picture'],
      ),
      bio: _nullableString(json['bio']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'name': name,
      'avatar_url': avatarUrl,
      'bio': bio,
    };
  }

  static String? _nullableString(dynamic value) {
    if (value == null) return null;
    final str = value.toString().trim();
    return str.isEmpty ? null : str;
  }
}
