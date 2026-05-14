import '../../core/utils/json_util.dart';

class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    this.username,
    this.firstName,
    this.lastName,
    this.profilePic,
    this.bio,
    this.dob,
    this.gender,
    this.createdAt,
    this.followersListPublic = true,
    this.followingListPublic = true,
    this.savedPostsPublic = false,
  });

  final String id;
  final String email;
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? profilePic;
  final String? bio;
  final String? dob;
  final String? gender;
  final DateTime? createdAt;
  final bool followersListPublic;
  final bool followingListPublic;
  final bool savedPostsPublic;

  String? get fullName {
    final f = firstName?.trim() ?? '';
    final l = lastName?.trim() ?? '';
    final full = '$f $l'.trim();
    return full.isEmpty ? null : full;
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      username: JsonUtils.nullableString(json['userName']),
      firstName: JsonUtils.nullableString(json['firstName']),
      lastName: JsonUtils.nullableString(json['lastName']),
      profilePic: JsonUtils.nullableString(json['profilePic']),
      bio: JsonUtils.nullableString(json['bio']),
      dob: JsonUtils.nullableString(json['dob']),
      gender: JsonUtils.nullableString(json['gender']),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      followersListPublic: json['followersListPublic'] is bool
          ? json['followersListPublic'] as bool
          : (json['followersListPublic']?.toString() == 'false' ? false : true),
      followingListPublic: json['followingListPublic'] is bool
          ? json['followingListPublic'] as bool
          : (json['followingListPublic']?.toString() == 'false' ? false : true),
      savedPostsPublic: json['savedPostsPublic'] is bool
          ? json['savedPostsPublic'] as bool
          : (json['savedPostsPublic']?.toString() == 'true' ? true : false),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'userName': username,
        'firstName': firstName,
        'lastName': lastName,
        'profilePic': profilePic,
        'bio': bio,
        'dob': dob,
        'gender': gender,
        'createdAt': createdAt?.toIso8601String(),
        'followersListPublic': followersListPublic,
        'followingListPublic': followingListPublic,
        'savedPostsPublic': savedPostsPublic,
      };

  UserModel copyWith({
    String? id,
    String? email,
    String? username,
    String? firstName,
    String? lastName,
    String? profilePic,
    String? bio,
    String? dob,
    String? gender,
    DateTime? createdAt,
    bool? followersListPublic,
    bool? followingListPublic,
    bool? savedPostsPublic,
  }) =>
      UserModel(
        id: id ?? this.id,
        email: email ?? this.email,
        username: username ?? this.username,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        profilePic: profilePic ?? this.profilePic,
        bio: bio ?? this.bio,
        dob: dob ?? this.dob,
        gender: gender ?? this.gender,
        createdAt: createdAt ?? this.createdAt,
        followersListPublic: followersListPublic ?? this.followersListPublic,
        followingListPublic: followingListPublic ?? this.followingListPublic,
        savedPostsPublic: savedPostsPublic ?? this.savedPostsPublic,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is UserModel && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
