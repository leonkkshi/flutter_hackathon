import 'package:flutter_hackathon/feature/data/dtos/user/user_dto.dart';

class UserListResponseDto {
  final List<UserDto> users;
  final int total;
  final int skip;
  final int limit;

  const UserListResponseDto({
    required this.users,
    required this.total,
    required this.skip,
    required this.limit,
  });

  factory UserListResponseDto.fromJson(Map<String, dynamic> json) {
    final rawList = json['users'] as List<dynamic>? ?? [];
    return UserListResponseDto(
      users: rawList
          .whereType<Map<String, dynamic>>()
          .map(UserDto.fromJson)
          .toList(),
      total: json['total'] as int? ?? 0,
      skip: json['skip'] as int? ?? 0,
      limit: json['limit'] as int? ?? 0,
    );
  }
}
