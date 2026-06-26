import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hackathon/app/routes/app_route.dart';
import 'package:flutter_hackathon/core/network/api_client.dart';
import 'package:flutter_hackathon/feature/application/service/impls/auth_service_impl.dart';
import 'package:flutter_hackathon/feature/application/service/impls/task_service_impl.dart';
import 'package:flutter_hackathon/feature/application/service/impls/user_service_impl.dart';
import 'package:flutter_hackathon/feature/application/service/interfaces/i_auth_service.dart';
import 'package:flutter_hackathon/feature/application/service/interfaces/i_task_service.dart';
import 'package:flutter_hackathon/feature/application/service/interfaces/i_user_service.dart';
import 'package:flutter_hackathon/feature/data/datasource/auth_local_data_source.dart';
import 'package:flutter_hackathon/feature/data/datasource/auth_remote_data_source.dart';
import 'package:flutter_hackathon/feature/data/datasource/task_local_data_source.dart';
import 'package:flutter_hackathon/feature/data/datasource/user_remote_data_source.dart';
import 'package:flutter_hackathon/feature/data/impl_repositories/auth_repository_impl.dart';
import 'package:flutter_hackathon/feature/data/impl_repositories/task_repository_impl.dart';
import 'package:flutter_hackathon/feature/data/impl_repositories/user_repository_impl.dart';
import 'package:flutter_hackathon/feature/data/mappers/auth/auth_mapper.dart';
import 'package:flutter_hackathon/feature/data/mappers/user/user_item_mapper.dart';
import 'package:flutter_hackathon/feature/domain/i_repositories/i_auth_repository.dart';
import 'package:flutter_hackathon/feature/domain/i_repositories/i_task_repository.dart';
import 'package:flutter_hackathon/feature/domain/i_repositories/i_user_repository.dart';
import 'package:flutter_hackathon/feature/presentation/viewmodel/login_view_model.dart';
import 'package:flutter_hackathon/feature/presentation/viewmodel/task_view_model.dart';
import 'package:flutter_hackathon/feature/presentation/viewmodel/user_management_view_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return MultiProvider(
      providers: [
        // ── Infrastructure ───────────────────────────────────────────
        Provider<Dio>(create: (_) => ApiClient.createDio()),

        // ── Auth datasources ─────────────────────────────────────────
        Provider<AuthRemoteDataSource>(
          create: (ctx) => AuthRemoteDataSource(ctx.read<Dio>()),
        ),
        Provider<AuthLocalDataSource>(
          create: (_) => AuthLocalDataSource(const FlutterSecureStorage()),
        ),

        // ── User datasource ──────────────────────────────────────────
        Provider<UserRemoteDataSource>(
          create: (ctx) => UserRemoteDataSource(ctx.read<Dio>()),
        ),
        Provider<TaskLocalDataSource>(create: (_) => TaskLocalDataSource()),

        // ── Mappers ───────────────────────────────────────────────────
        Provider<AuthMapper>(create: (_) => AuthMapper()),
        Provider<UserItemMapper>(create: (_) => UserItemMapper()),

        // ── Repositories ──────────────────────────────────────────────
        Provider<IAuthRepository>(
          create: (ctx) => AuthRepositoryImpl(
            remoteDataSource: ctx.read<AuthRemoteDataSource>(),
            localDataSource: ctx.read<AuthLocalDataSource>(),
            authMapper: ctx.read<AuthMapper>(),
          ),
        ),
        Provider<IUserRepository>(
          create: (ctx) => UserRepositoryImpl(
            remoteDataSource: ctx.read<UserRemoteDataSource>(),
            mapper: ctx.read<UserItemMapper>(),
          ),
        ),
        Provider<ITaskRepository>(
          create: (ctx) => TaskRepositoryImpl(
            localDataSource: ctx.read<TaskLocalDataSource>(),
          ),
        ),

        // ── Services ──────────────────────────────────────────────────
        Provider<IAuthService>(create: (_) => AuthServiceImpl()),
        Provider<IUserService>(
          create: (ctx) => UserServiceImpl(ctx.read<IUserRepository>()),
        ),
        Provider<ITaskService>(
          create: (ctx) => TaskServiceImpl(ctx.read<ITaskRepository>()),
        ),

        // ── ViewModels ────────────────────────────────────────────────
        ChangeNotifierProvider<LoginViewModel>(
          create: (ctx) => LoginViewModel(ctx.read<IAuthService>()),
        ),
        ChangeNotifierProvider<UserManagementViewModel>(
          create: (ctx) => UserManagementViewModel(ctx.read<IUserService>()),
        ),
        ChangeNotifierProvider<TaskViewModel>(
          create: (ctx) => TaskViewModel(ctx.read<ITaskService>()),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter MVVM Login',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        initialRoute: AppRoutes.login,
        onGenerateRoute: AppRoutes.anGenerateRoute,
      ),
    );
  }
}
