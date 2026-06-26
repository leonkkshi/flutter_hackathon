import 'package:flutter_hackathon/feature/application/service/interfaces/i_user_service.dart';
import 'package:flutter_hackathon/feature/domain/entities/user_item.dart';
import 'package:flutter_hackathon/feature/domain/i_repositories/i_user_repository.dart';

class UserServiceImpl implements IUserService {
  final IUserRepository _userRepository;

  UserServiceImpl(this._userRepository);

  @override
  Future<List<UserItem>> getUsers() async {
    return _userRepository.getUsers(skip: 0, limit: 100);
  }

  @override
  Future<UserItem> addUser(UserItem user) async {
    return await _userRepository.addUser(user);
  }

  @override
  Future<UserItem> updateUser(UserItem user) async {
    return await _userRepository.updateUser(user);
  }

  @override
  Future<void> deleteUser(int userId) async {
    await _userRepository.deleteUser(userId);
  }
}
