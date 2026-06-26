import 'package:flutter_hackathon/feature/data/datasource/user_remote_data_source.dart';
import 'package:flutter_hackathon/feature/data/mappers/user/user_item_mapper.dart';
import 'package:flutter_hackathon/feature/domain/entities/user_item.dart';
import 'package:flutter_hackathon/feature/domain/i_repositories/i_user_repository.dart';

class UserRepositoryImpl implements IUserRepository {
  final UserRemoteDataSource _remoteDataSource;
  final UserItemMapper _mapper;

  UserRepositoryImpl({
    required UserRemoteDataSource remoteDataSource,
    required UserItemMapper mapper,
  })  : _remoteDataSource = remoteDataSource,
        _mapper = mapper;

  @override
  Future<List<UserItem>> getUsers({int skip = 0, int limit = 30}) async {
    final response = await _remoteDataSource.getUsers(skip: skip, limit: limit);
    return response.users.map(_mapper.map).toList();
  }

  @override
  Future<UserItem> addUser(UserItem user) async {
    final parts = user.fullName.trim().split(' ');
    final firstName = parts.isNotEmpty ? parts.first : '';
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    final dto = await _remoteDataSource.addUser({
      'firstName': firstName,
      'lastName': lastName,
      'username': user.username,
      'email': user.email,
      'phone': user.phone,
      'age': user.age,
      'gender': user.gender.toLowerCase() == 'nam' ? 'male' : 'female',
    });
    return _mapper.map(dto);
  }

  @override
  Future<UserItem> updateUser(UserItem user) async {
    final parts = user.fullName.trim().split(' ');
    final firstName = parts.isNotEmpty ? parts.first : '';
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    final dto = await _remoteDataSource.updateUser(user.id, {
      'firstName': firstName,
      'lastName': lastName,
      'username': user.username,
      'email': user.email,
      'phone': user.phone,
      'age': user.age,
      'gender': user.gender.toLowerCase() == 'nam' ? 'male' : 'female',
    });
    return _mapper.map(dto);
  }

  @override
  Future<void> deleteUser(int userId) async {
    await _remoteDataSource.deleteUser(userId);
  }
}
