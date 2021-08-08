import 'package:dio/dio.dart';

enum RequestType { post, get }

abstract class BaseAPIServiceInterface {
  late Map<String, String> headers;
  late String baseURL;
  late String encoding;
}

abstract class InputServiceInterface extends BaseAPIServiceInterface {
  late String path;
  late RequestType requestType;
  String get fullPath => '$baseURL$path';
  late Map<String, dynamic> queryParameters;
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
  Map<String, dynamic> queryParameters = {};

  DefaultInputService(
      {this.baseURL = '',
      this.encoding = '',
      this.headers = const {},
      this.path = '',
      this.requestType = RequestType.get,
      this.queryParameters = const {}});

  @override
  String get fullPath => '$baseURL$path';
}
