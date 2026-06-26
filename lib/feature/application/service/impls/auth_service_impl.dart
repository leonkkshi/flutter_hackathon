import 'package:flutter_hackathon/core/erros/app_exception.dart';
import 'package:flutter_hackathon/feature/application/service/interfaces/i_auth_service.dart';
import 'package:flutter_hackathon/feature/domain/entities/user.dart';

class AuthServiceImpl implements IAuthService {
  static const String _validEmail = 'admin@gmail.com';
  static const String _validPassword = '123456';

  bool _loggedIn = false;

  AuthServiceImpl();

  @override
  Future<User> login({
    required String username,
    required String password,
  }) async {
    final normalizedEmail = username.trim();

    if (normalizedEmail.isEmpty) {
      throw const AppException('Email is required');
    }
    if (password.isEmpty) {
      throw const AppException('Password is required');
    }
    if (normalizedEmail != _validEmail || password != _validPassword) {
      throw const AppException('Invalid email or password');
    }

    _loggedIn = true;

    return const User(
      id: 1,
      username: 'admin',
      email: _validEmail,
      fullName: 'Admin',
      imageUrl: '',
      accessToken: 'local-demo-access-token',
      refreshToken: 'local-demo-refresh-token',
    );
  }

  @override
  Future<void> logout() async {
    _loggedIn = false;
  }

  @override
  Future<bool> isLoggedIn() async {
    return _loggedIn;
  }
}
