class User {
  final String id;
  final String? nickname;
  final String? profileImage;
  final String? email;
  final bool isOnboarded;

  User({
    required this.id,
    this.nickname,
    this.profileImage,
    this.email,
    this.isOnboarded = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    print('Parsing User: $json'); // Debug log
    return User(
      id: json['id']?.toString() ?? '',
      nickname: json['nickname'],
      profileImage: json['profile_image'],
      email: json['email'],
      isOnboarded: json['isOnboarded'] ?? false,
    );
  }
}
