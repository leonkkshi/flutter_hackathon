import 'package:flutter/foundation.dart';
import 'package:flutter_hackathon/core/erros/app_exception.dart';
import 'package:flutter_hackathon/feature/application/service/interfaces/i_auth_service.dart';
import 'package:flutter_hackathon/feature/domain/entities/user.dart';
import 'package:flutter_hackathon/feature/domain/i_repositories/i_auth_repository.dart';

class AuthServiceImpl implements IAuthService {
  final IAuthRepository _authRepository;
  
  AuthServiceImpl(this._authRepository);
  @override
  Future<User> login({
    required String username,
    required String password,
  }) async {
  final normalizedUsername = username.trim();

  if (normalizedUsername.isEmpty){
    throw const AppException('Usernam không được để trống.');
  }
  if(password.isEmpty){
    throw const AppException('Password không được để trống.');
  }
  if(password.length < 6){
    throw const AppException('Password phải có ít nhất 6 ký tự.');
  }
return _authRepository.login(
  username: normalizedUsername,
  password: password,
);
  }

  @override
  Future<void> logout() async {
    // Simulate a logout process
    await Future.delayed(const Duration(seconds: 1));
    debugPrint('User logged out');
  }

  @override
  Future<bool> isLoggedIn() async {
    // Simulate checking if the user is logged in
    await Future.delayed(const Duration(seconds: 1));
    // For this example, we will just return false
    return false;
  }
}
