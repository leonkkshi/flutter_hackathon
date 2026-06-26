import 'package:flutter_hackathon/feature/domain/entities/user.dart';

abstract interface class IAuthRepository {

Future <User> login(
  {
    required String username,
    required String password,
  }
);
Future<void> logout();
Future<bool> isLoggedIn();
}
