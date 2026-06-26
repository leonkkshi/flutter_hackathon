import 'package:dio/dio.dart';
import 'package:flutter_hackathon/core/constants/api_constant.dart';
import 'package:flutter_hackathon/core/erros/app_exception.dart';
import 'package:flutter_hackathon/feature/data/dtos/auth/login_request_dto.dart';
import 'package:flutter_hackathon/feature/data/dtos/auth/login_response_dto.dart';

class AuthRemoteDataSource {
  final Dio _dio;
  AuthRemoteDataSource(this._dio);
  Future<LoginResponseDto> login(LoginRequestDto request) async {
    try {
      final response = await _dio.post<Map<String,dynamic>>(
        ApiConstant.loginEndpoint,
        data: request.toJson(),
      );
      final data = response.data;
      if(data == null ){
        throw const AppException('Dữ liệu phản hồi từ server không hợp lệ.');
      }
      return LoginResponseDto.fromJson(data);
    } on DioException catch (error) {
      throw AppException(_getErrorMessage(error));
    }
  }
  String _getErrorMessage(DioException error) {
    final data = error.response?.data;

    if (data is Map<String, dynamic>) {
      final message = data['message'] ;
      if (message !=null) {
        return message;
      }
    }

    if (data is String && data.trim().isNotEmpty) {
      return data;
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Kết nối đến server bị quá thời gian.';
      case DioExceptionType.sendTimeout:
        return 'Gửi dữ liệu lên server bị quá thời gian.';
      case DioExceptionType.receiveTimeout:
        return 'Server phản hồi quá chậm.';
      case DioExceptionType.badResponse:
        return 'Đăng nhập thất bại. Vui lòng kiểm tra lại tài khoản và mật khẩu.';
      case DioExceptionType.cancel:
        return 'Yêu cầu đã bị hủy.';
      case DioExceptionType.connectionError:
        return 'Không thể kết nối đến server.';
      case DioExceptionType.badCertificate:
        return 'Chứng chỉ kết nối không hợp lệ.';
      case DioExceptionType.unknown:
        return 'Đã xảy ra lỗi khi đăng nhập.';
    }
  }
  
 
  
}
