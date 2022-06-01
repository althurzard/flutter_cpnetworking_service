import 'package:dio/dio.dart';

class AppError extends DioError {
  AppError({
    required super.requestOptions,
    super.error,
    super.response,
    super.type,
  });
}
