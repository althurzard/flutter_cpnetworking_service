import 'package:dio/dio.dart';

enum AppErrorType { serverError, timeOut, tokenError }

enum ErrorCode { badRequest, unauthorized, notFound, forbidden }

class ErrorCodeHelper {
  static ErrorCode create(int? value) {
    var errorCode = ErrorCode.badRequest;
    switch (value) {
      case 400:
        errorCode = ErrorCode.badRequest;
        break;
      case 401:
        errorCode = ErrorCode.unauthorized;
        break;
      case 403:
        errorCode = ErrorCode.forbidden;
        break;
      case 404:
        errorCode = ErrorCode.forbidden;
        break;
      default:
        errorCode = ErrorCode.badRequest;
        break;
    }
    return errorCode;
  }

  static int value(ErrorCode value) {
    switch (value) {
      case ErrorCode.badRequest:
        return 400;
      case ErrorCode.unauthorized:
        return 401;
      case ErrorCode.notFound:
        return 403;
      case ErrorCode.forbidden:
        return 404;
    }
  }
}

class AppError implements Exception {
  String? message = '';
  AppErrorType? type = AppErrorType.serverError;
  ErrorCode? errorCode = ErrorCode.badRequest;
  AppError({this.message, this.type, this.errorCode});

  factory AppError.fromJson(Map<String, dynamic> json) {
    var message = '';
    try {
      message = json['message'] ?? json['error']['message'];
    } catch (e) {
      message = message.isEmpty ? 'Unknown error' : message;
    }
    return AppError(message: message);
  }

  static AppError withDioError(DioError e) {
    var type = AppErrorType.serverError;
    switch (e.type) {
      case DioErrorType.connectTimeout:
      case DioErrorType.receiveTimeout:
      case DioErrorType.sendTimeout:
        type = AppErrorType.timeOut;
        break;
      default:
        break;
    }
    var error = e.response != null
        ? (e.response?.data is String
            ? AppError(
                message: e.response?.data,
                type: type,
                errorCode: ErrorCodeHelper.create(e.response?.statusCode))
            : AppError.fromJson(e.response?.data))
        : AppError(
            message: e.message,
            type: type,
            errorCode: ErrorCodeHelper.create(e.response?.statusCode));
    return error;
  }
}
