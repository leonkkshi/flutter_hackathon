import 'package:flutter/foundation.dart';
import 'package:flutter_hackathon/core/erros/app_exception.dart';
import 'package:flutter_hackathon/feature/application/service/interfaces/i_user_service.dart';
import 'package:flutter_hackathon/feature/domain/entities/user_item.dart';

enum UserManagementStatus { initial, loading, success, failure }

class UserManagementViewModel extends ChangeNotifier {
  final IUserService _userService;

  UserManagementViewModel(this._userService);

  UserManagementStatus _status = UserManagementStatus.initial;
  List<UserItem> _allUsers = [];
  List<UserItem> _filteredUsers = [];
  String _searchQuery = '';
  int _currentPage = 1;
  final int _pageSize = 5;
  String? _errorMessage;

  UserManagementStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  int get currentPage => _currentPage;
  int get totalPages => (_filteredUsers.length / _pageSize).ceil().clamp(1, 999);
  bool get isLoading => _status == UserManagementStatus.loading;

  List<UserItem> get allUsers => _allUsers;

  List<UserItem> get pagedUsers {
    final start = (_currentPage - 1) * _pageSize;
    final end = (start + _pageSize).clamp(0, _filteredUsers.length);
    if (start >= _filteredUsers.length) return [];
    return _filteredUsers.sublist(start, end);
  }

  Future<void> loadUsers() async {
    _status = UserManagementStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _allUsers = await _userService.getUsers();
      _applyFilter();
      _status = UserManagementStatus.success;
    } on AppException catch (e) {
      _status = UserManagementStatus.failure;
      _errorMessage = e.message;
    } catch (_) {
      _status = UserManagementStatus.failure;
      _errorMessage = 'Không thể tải danh sách người dùng.';
    }
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    _currentPage = 1;
    _applyFilter();
    notifyListeners();
  }

  void goToPage(int page) {
    if (page < 1 || page > totalPages) return;
    _currentPage = page;
    notifyListeners();
  }

  Future<void> deleteUser(int userId) async {
    // Optimistic local removal for snappy UX
    _allUsers.removeWhere((u) => u.id == userId);
    _applyFilter();
    if (_currentPage > totalPages) {
      _currentPage = totalPages;
    }
    notifyListeners();

    // Fire-and-forget to API (DummyJSON delete is soft)
    try {
      await _userService.deleteUser(userId);
    } on AppException {
      // Silently ignore — DummyJSON fakes deletes
    } catch (_) {
      // Same
    }
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredUsers = List.from(_allUsers);
    } else {
      final q = _searchQuery.toLowerCase();
      _filteredUsers = _allUsers
          .where((u) =>
              u.fullName.toLowerCase().contains(q) ||
              u.username.toLowerCase().contains(q) ||
              u.email.toLowerCase().contains(q))
          .toList();
    }
  }
  Future<void> addUser(UserItem user) async {
    // Generate a local ID (negative to avoid collision with API IDs)
    final newId = _allUsers.isEmpty
        ? -1
        : (_allUsers.map((u) => u.id).reduce((a, b) => a < b ? a : b) - 1);
    final newUser = user.copyWith(id: newId);
    
    // Local optimistic update
    _allUsers.insert(0, newUser);
    _currentPage = 1;
    _applyFilter();
    notifyListeners();

    try {
      await _userService.addUser(user);
    } catch (e) {
      // Silently ignore for mock API
    }
  }

  Future<void> updateUser(UserItem updated) async {
    // Local optimistic update
    final idx = _allUsers.indexWhere((u) => u.id == updated.id);
    if (idx != -1) {
      _allUsers[idx] = updated;
      _applyFilter();
      notifyListeners();
    }

    try {
      if (updated.id > 0) {
        await _userService.updateUser(updated);
      }
    } catch (e) {
      // Silently ignore for mock API
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
