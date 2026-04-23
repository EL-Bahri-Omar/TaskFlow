class UserModel {
  final String id;
  final String name;
  final String email;
  final String avatar;
  final String? token;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatar = '',
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatar: json['avatar'] as String? ?? '',
      token: json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
    };
  }
}
