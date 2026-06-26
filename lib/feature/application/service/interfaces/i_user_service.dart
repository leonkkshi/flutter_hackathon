import 'package:flutter_hackathon/feature/domain/entities/user_item.dart';

abstract interface class IUserService {
  Future<List<UserItem>> getUsers();
  Future<UserItem> addUser(UserItem user);
  Future<UserItem> updateUser(UserItem user);
  Future<void> deleteUser(int userId);
}
