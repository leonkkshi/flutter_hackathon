import 'package:dio/dio.dart';
import 'package:flutter_hackathon/core/constants/api_constant.dart';
import 'package:flutter_hackathon/core/erros/app_exception.dart';
import 'package:flutter_hackathon/feature/data/dtos/user/user_dto.dart';
import 'package:flutter_hackathon/feature/data/dtos/user/user_list_response_dto.dart';

class UserRemoteDataSource {
  final Dio _dio;
  UserRemoteDataSource(this._dio);

  Future<UserListResponseDto> getUsers({int skip = 0, int limit = 30}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstant.usersEndpoint,
        queryParameters: {'skip': skip, 'limit': limit},
      );
      final data = response.data;
      if (data == null) {
        throw const AppException('Dữ liệu phản hồi từ server không hợp lệ.');
      }
      return UserListResponseDto.fromJson(data);
    } on DioException catch (error) {
      throw AppException(_getErrorMessage(error));
    }
  }

  Future<UserDto> addUser(Map<String, dynamic> userData) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '${ApiConstant.usersEndpoint}/add',
        data: userData,
      );
      final data = response.data;
      if (data == null) {
        throw const AppException('Dữ liệu phản hồi từ server không hợp lệ.');
      }
      return UserDto.fromJson(data);
    } on DioException catch (error) {
      throw AppException(_getErrorMessage(error));
    }
  }

  Future<UserDto> updateUser(int id, Map<String, dynamic> userData) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '${ApiConstant.usersEndpoint}/$id',
        data: userData,
      );
      final data = response.data;
      if (data == null) {
        throw const AppException('Dữ liệu phản hồi từ server không hợp lệ.');
      }
      return UserDto.fromJson(data);
    } on DioException catch (error) {
      throw AppException(_getErrorMessage(error));
    }
  }

  Future<void> deleteUser(int userId) async {
    try {
      await _dio.delete<Map<String, dynamic>>(
        '${ApiConstant.usersEndpoint}/$userId',
      );
    } on DioException catch (error) {
      throw AppException(_getErrorMessage(error));
    }
  }

  String _getErrorMessage(DioException error) {
    final data = error.response?.data;

    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message != null) return message.toString();
    }

    if (data is String && data.trim().isNotEmpty) return data;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Kết nối đến server bị quá thời gian.';
      case DioExceptionType.sendTimeout:
        return 'Gửi dữ liệu lên server bị quá thời gian.';
      case DioExceptionType.receiveTimeout:
        return 'Server phản hồi quá chậm.';
      case DioExceptionType.badResponse:
        return 'Không thể thực hiện thao tác. Vui lòng thử lại.';
      case DioExceptionType.cancel:
        return 'Yêu cầu đã bị hủy.';
      case DioExceptionType.connectionError:
        return 'Không thể kết nối đến server.';
      case DioExceptionType.badCertificate:
        return 'Chứng chỉ kết nối không hợp lệ.';
      case DioExceptionType.unknown:
        return 'Đã xảy ra lỗi không xác định.';
    }
  }
}
