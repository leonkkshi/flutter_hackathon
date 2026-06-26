import 'package:flutter_hackathon/feature/data/dtos/user/user_dto.dart';

class LoginResponseDto{
  final UserDto user;
  final String accessToken;
  final String refreshToken;
  const LoginResponseDto({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });
  
  factory LoginResponseDto.fromJson(Map<String, dynamic> json) {
    return LoginResponseDto(
      user: UserDto.fromJson(json),
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
    );
  }
}
