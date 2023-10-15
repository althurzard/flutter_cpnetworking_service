import 'dart:developer';
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
  final dio = Dio();

  NetworkConfigurable networkConfiguration;

  StorageTokenProcessor storageTokenProcessor;

  Interceptor? interceptor;

  APIProvider(
      {required this.networkConfiguration,
      required this.storageTokenProcessor,
      this.interceptor}) {
    dio.interceptors.add(InterceptorsWrapper(
        onRequest: _onRequest, onError: _onError, onResponse: _onResponse));
    if (interceptor != null) {
      dio.interceptors.add(interceptor!);
    }
    if (networkConfiguration.interceptor != null) {
      dio.interceptors.add(networkConfiguration.interceptor!);
    }
    dio.options.baseUrl = networkConfiguration.baseURL;
  }

  void _onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // TODO: handle something(token, headers, etc)
    if (kDebugMode) {
      log('''REQUEST:
    ${cURLRepresentation(options)}
    ''');
    }
    return handler.next(options);
  }

  void _onError(DioException err, ErrorInterceptorHandler handler) {
    // TODO: handle refresh token
    return handler.next(err);
  }

  void _onResponse(
      Response<dynamic> response, ResponseInterceptorHandler handler) {
    return handler.next(response);
  }

  Future<Response> request({required InputServiceInterface input}) async {
    dio.options.headers = _defaultHeaders(input.headers);
    dio.options.contentType =
        input.encoding.isEmpty ? networkConfiguration.encoding : input.encoding;
    Uri? fullPath;

    switch (input.requestType) {
      case RequestType.get:
        if (input.baseURL.isNotEmpty && input.path.isNotEmpty) {
          fullPath = Uri.parse(input.fullPath);
          if (input.queryParameters != null) {
            fullPath.replace(queryParameters: input.queryParameters);
          }
        }
        return dioGet(uri: fullPath, input: input);
      case RequestType.post:
        if (input.baseURL.isNotEmpty && input.path.isNotEmpty) {
          fullPath = Uri.parse(input.fullPath);
        }
        return dioPost(uri: fullPath, input: input);
      case RequestType.put:
        if (input.baseURL.isNotEmpty && input.path.isNotEmpty) {
          fullPath = Uri.parse(input.fullPath);
        }
        return dioPut(uri: fullPath, input: input);
      case RequestType.delete:
        if (input.baseURL.isNotEmpty && input.path.isNotEmpty) {
          fullPath = Uri.parse(input.fullPath);
        }
        return dioDelete(uri: fullPath, input: input);
      case RequestType.patch:
        if (input.baseURL.isNotEmpty && input.path.isNotEmpty) {
          fullPath = Uri.parse(input.fullPath);
        }
        return dioPatch(uri: fullPath, input: input);
    }
  }

  Future<Response> dioGet({Uri? uri, InputServiceInterface? input}) async {
    Response response;
    try {
      if (uri != null) {
        response = await dio.getUri(
          uri,
          onReceiveProgress: input?.onReceiveProgress,
        );
      } else {
        response = await dio.get(
          input!.path,
          queryParameters: input.queryParameters,
          onReceiveProgress: input.onReceiveProgress,
        );
      }
      return Future.value(response);
    } on DioException catch (e) {
      return Future.error(AppError(
          requestOptions: e.requestOptions,
          response: e.response,
          error: e.error,
          type: e.type));
    }
  }

  Future<Response> dioPost({Uri? uri, InputServiceInterface? input}) async {
    Response response;
    try {
      if (uri != null) {
        response = await dio.postUri(uri,
            data: input?.formData ?? input?.queryParameters,
            onReceiveProgress: input?.onReceiveProgress,
            onSendProgress: input?.onSendProgress);
      } else {
        response = await dio.post(input!.path,
            data: input.formData ?? input.queryParameters,
            onReceiveProgress: input.onReceiveProgress,
            onSendProgress: input.onSendProgress);
      }
      return Future.value(response);
    } on DioException catch (e) {
      return Future.error(AppError(
          requestOptions: e.requestOptions,
          response: e.response,
          error: e.error,
          type: e.type));
    }
  }

  Future<Response> dioPut({Uri? uri, InputServiceInterface? input}) async {
    Response response;
    try {
      if (uri != null) {
        response = await dio.putUri(uri,
            data: input?.formData ?? input?.queryParameters,
            onReceiveProgress: input?.onReceiveProgress,
            onSendProgress: input?.onSendProgress);
      } else {
        response = await dio.put(input!.path,
            data: input.formData ?? input.queryParameters,
            onReceiveProgress: input.onReceiveProgress,
            onSendProgress: input.onSendProgress);
      }
      return Future.value(response);
    } on DioException catch (e) {
      return Future.error(AppError(
          requestOptions: e.requestOptions,
          response: e.response,
          error: e.error,
          type: e.type));
    }
  }

  Future<Response> dioDelete({Uri? uri, InputServiceInterface? input}) async {
    Response response;
    try {
      if (uri != null) {
        response = await dio.deleteUri(uri,
            data: input?.formData ?? input?.queryParameters);
      } else {
        response = await dio.delete(input!.path,
            data: input.formData ?? input.queryParameters);
      }
      return Future.value(response);
    } on DioException catch (e) {
      return Future.error(AppError(
          requestOptions: e.requestOptions,
          response: e.response,
          error: e.error,
          type: e.type));
    }
  }

  Future<Response> dioPatch({Uri? uri, InputServiceInterface? input}) async {
    Response response;
    try {
      if (uri != null) {
        response = await dio.patchUri(uri,
            data: input?.formData ?? input?.queryParameters,
            onReceiveProgress: input?.onReceiveProgress,
            onSendProgress: input?.onSendProgress);
      } else {
        response = await dio.patch(input!.path,
            data: input.formData ?? input.queryParameters,
            onReceiveProgress: input.onReceiveProgress,
            onSendProgress: input.onSendProgress);
      }
      return Future.value(response);
    } on DioException catch (e) {
      return Future.error(AppError(
          requestOptions: e.requestOptions,
          response: e.response,
          error: e.error,
          type: e.type));
    }
  }

  Map<String, String> _defaultHeaders(Map<String, String> otherHeaders) =>
      {...networkConfiguration.headers, ...otherHeaders};

  String cURLRepresentation(RequestOptions options) {
    var components = <String>['\$ curl -i'];
    components.add('-X ${options.method.toUpperCase()}');

    options.headers.forEach((k, v) {
      if (k != 'Cookie') {
        components.add('-H \"$k: $v\"');
      }
    });

    if (options.data is FormData) {
      components.add('\"${options.uri.toString()}\"');
      return components.join('\\\n\t');
    }
    var data = json.encode(options.data);
    data = data.replaceAll('\"', '\\\"');
    components.add('-d \"$data\"');
    components.add('\"${options.uri.toString()}\"');
    return components.join('\\\n\t');
  }
}
