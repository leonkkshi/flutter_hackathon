import 'package:flutter_hackathon/feature/data/dtos/auth/login_response_dto.dart';
import 'package:flutter_hackathon/feature/data/mappers/i_mapper.dart';
import 'package:flutter_hackathon/feature/domain/entities/user.dart';

class AuthMapper implements IMapper<LoginResponseDto, User> {
  @override
  User map(LoginResponseDto source) {
    return User(
     id:source.user.id,
     username: source.user.username,
     email: source.user.email,
     fullName: '${source.user.firstName} ${source.user.lastName}'.trim(),
     imageUrl: source.user.imageUrl,
     accessToken: source.accessToken,
     refreshToken: source.refreshToken,
    );
  }
}
