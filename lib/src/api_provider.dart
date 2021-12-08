import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'error.dart';
import 'storage_token_processor.dart';
import 'api_input_service.dart';
import 'dart:convert';

abstract class NetworkConfigurable extends BaseAPIServiceInterface {
  late String refreshTokenPath;
  Interceptor? interceptor;
}

class DefaultNetworkConfigurable implements NetworkConfigurable {
  @override
  String baseURL;

  @override
  Map<String, String> headers;

  @override
  String refreshTokenPath;

  DefaultNetworkConfigurable(
      {this.baseURL = '',
      this.headers = const {'accept': '*/*'},
      this.refreshTokenPath = '',
      this.encoding = 'application/json',
      this.interceptor});

  @override
  String encoding;

  @override
  Interceptor? interceptor;
}

class APIProvider {
  final _dio = Dio();

  NetworkConfigurable networkConfiguration;

  StorageTokenProcessor storageTokenProcessor;

  Interceptor? interceptor;

  APIProvider(
      {required this.networkConfiguration,
      required this.storageTokenProcessor,
      this.interceptor}) {
    _dio.interceptors.add(InterceptorsWrapper(
        onRequest: _onRequest, onError: _onError, onResponse: _onResponse));
    if (this.interceptor != null) {
      _dio.interceptors.add(this.interceptor!);
    }
    if (this.networkConfiguration.interceptor != null) {
      _dio.interceptors.add(this.networkConfiguration.interceptor!);
    }
    _dio.options.baseUrl = networkConfiguration.baseURL;
  }

  void _onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // TODO: handle something(token, headers, etc)
    if (kDebugMode) print("""REQUEST:
    ${cURLRepresentation(options)}
    """);
    return handler.next(options);
  }

  void _onError(DioError err, ErrorInterceptorHandler handler) {
    // TODO: handle refresh token
    return handler.next(err);
  }

  void _onResponse(
      Response<dynamic> response, ResponseInterceptorHandler handler) {
    return handler.next(response);
  }

  Future<Response> request({required InputServiceInterface input}) async {
    _dio.options.headers = _defaultHeaders(input.headers);
    _dio.options.contentType =
        input.encoding.isEmpty ? networkConfiguration.encoding : input.encoding;
    Uri? fullPath;

    switch (input.requestType) {
      case RequestType.get:
        if (input.baseURL.isNotEmpty && input.path.isNotEmpty) {
          fullPath = Uri.parse(input.fullPath);
          if (input.queryParameters != null) {
            fullPath..replace(queryParameters: input.queryParameters);
          }
        }
        return _dioGet(uri: fullPath, input: input);
      case RequestType.post:
        if (input.baseURL.isNotEmpty && input.path.isNotEmpty) {
          fullPath = Uri.parse(input.fullPath);
        }
        return _dioPost(uri: fullPath, input: input);
      case RequestType.put:
        if (input.baseURL.isNotEmpty && input.path.isNotEmpty) {
          fullPath = Uri.parse(input.fullPath);
        }
        return _dioPut(uri: fullPath, input: input);
      case RequestType.delete:
        if (input.baseURL.isNotEmpty && input.path.isNotEmpty) {
          fullPath = Uri.parse(input.fullPath);
        }
        return _dioDelete(uri: fullPath, input: input);
    }
  }

  Future<Response> _dioGet({Uri? uri, InputServiceInterface? input}) async {
    Response response;
    try {
      if (uri != null) {
        response = await _dio.getUri(uri);
      } else {
        response =
            await _dio.get(input!.path, queryParameters: input.queryParameters);
      }
      return Future.value(response);
    } on DioError catch (e) {
      return Future.error(AppError.withDioError(e));
    }
  }

  Future<Response> _dioPost({Uri? uri, InputServiceInterface? input}) async {
    Response response;
    try {
      if (uri != null) {
        response = await _dio.postUri(uri,
            data: input?.formData ?? input?.queryParameters);
      } else {
        response = await _dio.post(input!.path,
            data: input.formData ?? input.queryParameters);
      }
      return Future.value(response);
    } on DioError catch (e) {
      return Future.error(AppError.withDioError(e));
    }
  }

  Future<Response> _dioPut({Uri? uri, InputServiceInterface? input}) async {
    Response response;
    try {
      if (uri != null) {
        response = await _dio.putUri(uri,
            data: input?.formData ?? input?.queryParameters);
      } else {
        response = await _dio.put(input!.path,
            data: input.formData ?? input.queryParameters);
      }
      return Future.value(response);
    } on DioError catch (e) {
      return Future.error(AppError.withDioError(e));
    }
  }

  Future<Response> _dioDelete({Uri? uri, InputServiceInterface? input}) async {
    Response response;
    try {
      if (uri != null) {
        response = await _dio.deleteUri(uri,
            data: input?.formData ?? input?.queryParameters);
      } else {
        response = await _dio.delete(input!.path,
            data: input.formData ?? input.queryParameters);
      }
      return Future.value(response);
    } on DioError catch (e) {
      return Future.error(AppError.withDioError(e));
    }
  }

  Map<String, String> _defaultHeaders(Map<String, String> otherHeaders) =>
      {...networkConfiguration.headers, ...otherHeaders};

  String cURLRepresentation(RequestOptions options) {
    List<String> components = ["\$ curl -i"];
    if (options.method.toUpperCase() == "GET") {
      components.add("-X ${options.method}");
    }

    options.headers.forEach((k, v) {
      if (k != "Cookie") {
        components.add("-H \"$k: $v\"");
      }
    });

    var data = json.encode(options.data);
    data = data.replaceAll('\"', '\\\"');
    components.add("-d \"$data\"");

    components.add("\"${options.uri.toString()}\"");

    return components.join('\\\n\t');
  }
}
