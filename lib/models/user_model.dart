import 'package:flutter/foundation.dart';

class User {
  final String id;
  final String? nickname;
  final String? profileImage;
  final String? email;
  final bool isOnboarded;
  final String? birthdate;
  final String? location;
  final String? guardianContact;
  final String? userContact;

  User({
    required this.id,
    this.nickname,
    this.profileImage,
    this.email,
    this.isOnboarded = false,
    this.birthdate,
    this.location,
    this.guardianContact,
    this.userContact,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    debugPrint('Parsing User: $json'); 
    return User(
      id: json['id']?.toString() ?? '',
      nickname: json['nickname'],
      profileImage: json['profile_image'],
      email: json['email'],
      isOnboarded: false,
      birthdate: json['birthdate'],
      location: json['location'],
      guardianContact: json['guardian_contact'],
      userContact: json['user_contact'] ?? json['phone_number'],
    );
  }
}
