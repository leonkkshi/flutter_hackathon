import 'package:flutter_hackathon/feature/data/datasource/auth_local_data_source.dart';
import 'package:flutter_hackathon/feature/data/datasource/auth_remote_data_source.dart';
import 'package:flutter_hackathon/feature/data/dtos/auth/login_request_dto.dart';
import 'package:flutter_hackathon/feature/data/mappers/auth/auth_mapper.dart';
import 'package:flutter_hackathon/feature/domain/entities/user.dart';
import 'package:flutter_hackathon/feature/domain/i_repositories/i_auth_repository.dart';

class AuthRepositoryImpl implements IAuthRepository {
 final AuthRemoteDataSource _remoteDataSource;
 final AuthLocalDataSource _localDataSource;
 final AuthMapper _authMapper;

 AuthRepositoryImpl ({
required AuthRemoteDataSource remoteDataSource,
required AuthLocalDataSource localDataSource,
required AuthMapper authMapper,


 }) : _remoteDataSource = remoteDataSource,
      _localDataSource =localDataSource,
      _authMapper =authMapper;



  @override
  Future<User> login({
    required String username,
     required String password,
     }) async {
final request = LoginRequestDto(
  username: username,
  password: password,
);
final response = await _remoteDataSource.login(request);
await _localDataSource.saveTokens(
  accessToken: response.accessToken,
  refreshToken: response.refreshToken,
);
return _authMapper.map(response);
  }

  @override
  Future<void> logout() async {
   await _localDataSource.clearSession();
  }
    @override
  Future<bool> isLoggedIn() async {
  return await _localDataSource.hasTokens();
  }
}
