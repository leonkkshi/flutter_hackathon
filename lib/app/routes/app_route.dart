import 'package:flutter/material.dart';
import 'package:flutter_hackathon/feature/domain/entities/user_item.dart';
import 'package:flutter_hackathon/feature/domain/entities/video_item.dart';
import 'package:flutter_hackathon/feature/presentation/view/home_page.dart';
import 'package:flutter_hackathon/feature/presentation/view/login_page.dart';
import 'package:flutter_hackathon/feature/presentation/view/user_detail_page.dart';
import 'package:flutter_hackathon/feature/presentation/view/user_form_page.dart';
import 'package:flutter_hackathon/feature/presentation/view/user_management_page.dart';
import 'package:flutter_hackathon/feature/presentation/view/video_list_page.dart';
import 'package:flutter_hackathon/feature/presentation/view/video_detail_page.dart';
import 'package:flutter_hackathon/feature/presentation/view/video_form_page.dart';

class AppRoutes {
  AppRoutes._();

  static const String login          = '/';
  static const String home           = '/home';
  static const String userManagement = '/user-management';
  static const String userDetail     = '/user-detail';
  static const String userForm       = '/user-form';
  
  // Video CRUD routes
  static const String videoList      = '/videos';
  static const String videoDetail    = '/video-detail';
  static const String videoForm      = '/video-form';

  static Route<dynamic> anGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case userManagement:
        return MaterialPageRoute(builder: (_) => const UserManagementPage());
      case userDetail:
        final user = settings.arguments as UserItem;
        return MaterialPageRoute(
          builder: (_) => UserDetailPage(user: user),
        );
      case userForm:
        final user = settings.arguments as UserItem?;
        return MaterialPageRoute(
          builder: (_) => UserFormPage(existingUser: user),
        );
      
      // Video screens with standard transitions
      case videoList:
        return MaterialPageRoute(builder: (_) => const VideoListPage());
      case videoDetail:
        final video = settings.arguments as VideoItem;
        return MaterialPageRoute(
          builder: (_) => VideoDetailPage(video: video),
        );
      case videoForm:
        final video = settings.arguments as VideoItem?;
        return MaterialPageRoute(
          builder: (_) => VideoFormPage(existingVideo: video),
        );

      default:
        return MaterialPageRoute(builder: (_) => const LoginPage());
    }
  }
}

