import 'package:dio/dio.dart';
import 'package:flutter_hackathon/core/constants/api_constant.dart';

class ApiClient {
  ApiClient._();
  static Dio createDio(){
    return Dio (
      BaseOptions (
        baseUrl: ApiConstant.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );
  }
}
