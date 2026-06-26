import 'package:flutter/material.dart';
import 'package:flutter_hackathon/feature/domain/entities/user_item.dart';
import 'package:flutter_hackathon/feature/presentation/view/home_page.dart';
import 'package:flutter_hackathon/feature/presentation/view/login_page.dart';
import 'package:flutter_hackathon/feature/presentation/view/task_list_page.dart';
import 'package:flutter_hackathon/feature/presentation/view/user_detail_page.dart';
import 'package:flutter_hackathon/feature/presentation/view/user_form_page.dart';
import 'package:flutter_hackathon/feature/presentation/view/user_management_page.dart';

class AppRoutes {
  AppRoutes._();

  static const String login = '/';
  static const String home = '/home';
  static const String userManagement = '/user-management';
  static const String userDetail = '/user-detail';
  static const String userForm = '/user-form';
  static const String taskList = '/tasks';

  static Route<dynamic> anGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case userManagement:
        return MaterialPageRoute(builder: (_) => const UserManagementPage());
      case taskList:
        return MaterialPageRoute(builder: (_) => const TaskListPage());
      case userDetail:
        final user = settings.arguments as UserItem;
        return MaterialPageRoute(builder: (_) => UserDetailPage(user: user));
      case userForm:
        final user = settings.arguments as UserItem?;
        return MaterialPageRoute(
          builder: (_) => UserFormPage(existingUser: user),
        );

      default:
        return MaterialPageRoute(builder: (_) => const LoginPage());
    }
  }
}
