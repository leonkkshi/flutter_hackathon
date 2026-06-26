import 'package:flutter_hackathon/feature/domain/entities/user_item.dart';

abstract interface class IUserRepository {
  Future<List<UserItem>> getUsers({int skip = 0, int limit = 30});
  Future<UserItem> addUser(UserItem user);
  Future<UserItem> updateUser(UserItem user);
  Future<void> deleteUser(int userId);
}
