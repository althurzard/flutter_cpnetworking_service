import 'package:dio/dio.dart';

enum RequestType { post, get, put, delete }

abstract class BaseAPIServiceInterface {
  late Map<String, String> headers;
  late String baseURL;
  late String encoding;
}

abstract class InputServiceInterface extends BaseAPIServiceInterface {
  late String path;
  late RequestType requestType;
  String get fullPath => '$baseURL$path';
  Map<String, dynamic>? queryParameters;
  FormData? formData;
}

class DefaultInputService implements InputServiceInterface {
  @override
  String baseURL = '';

  @override
  String encoding = Headers.jsonContentType;

  @override
  Map<String, String> headers = {};

  @override
  String path = '';

  @override
  RequestType requestType = RequestType.get;

  @override
  Map<String, dynamic>? queryParameters = {};

  DefaultInputService(
      {this.baseURL = '',
      this.encoding = '',
      this.headers = const {},
      this.path = '',
      this.requestType = RequestType.get,
      this.queryParameters,
      this.formData});

  @override
  String get fullPath => '$baseURL$path';

  @override
  FormData? formData;
}
