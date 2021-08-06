import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'model/auth_session_info.dart';
import 'model/storage_session_info.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

final bool _isRunningTest = Platform.environment
    .containsKey('FLUTTER_TEST'); /* cannot use storage during running tests */

abstract class StorageTokenProcessor {
  Future<void> save({required AuthSessionInterface sessionInfo, int appType});
  Future<void> removeSessionInfo({int appType});
  Future<void> removeAllSessionInfos();
  String getCurrentToken({int appType});
  AuthSessionInterface? getCurrentSessionInfo({int appType});
}

class DefaultStorageTokenProcessor implements StorageTokenProcessor {
  List<StorageSessionInfo> _sessionInfos = [];
  final String saveAuthSessionKey =
      'SaveAuthService.DefaultStorageTokenProcessor';
  late FlutterSecureStorage _storage;

  static Future<DefaultStorageTokenProcessor> create() async {
    var storage = DefaultStorageTokenProcessor();
    if (kIsWeb == false) {
      storage._storage = const FlutterSecureStorage();
    }
    await storage._loadFromStorage();
    return storage;
  }

  Future<void> _loadFromStorage() async {
    if (_isRunningTest) {
      return;
    }
    String? results;
    if (kIsWeb) {
      var prefs = await SharedPreferences.getInstance();
      results = prefs.getString(saveAuthSessionKey);
    } else {
      results = await _storage.read(key: saveAuthSessionKey);
    }
    if (results != null && results.isNotEmpty) {
      List<dynamic> parsedJson = jsonDecode(results);
      _sessionInfos =
          parsedJson.map((e) => StorageSessionInfo.fromJson(e)).toList();
    }
  }

  Future<void> _saveToKeychain() async {
    if (_isRunningTest) {
      return;
    }
    var encoded = jsonEncode(_sessionInfos);
    if (kIsWeb) {
      var prefs = await SharedPreferences.getInstance();
      await prefs.setString(saveAuthSessionKey, encoded);
    } else {
      await _storage.write(key: saveAuthSessionKey, value: encoded);
    }
  }

  @override
  String getCurrentToken({int appType = 0}) {
    var first =
        _sessionInfos.firstWhereOrNull((element) => element.appType == appType);
    return first?.sessionInfo.accessToken ?? '';
  }

  @override
  Future<void> removeAllSessionInfos() async {
    if (_isRunningTest) {
      return;
    }
    _sessionInfos.clear();
    if (kIsWeb) {
      var prefs = await SharedPreferences.getInstance();
      await prefs.setString(saveAuthSessionKey, '');
    } else {
      await _storage.write(key: saveAuthSessionKey, value: '');
    }
  }

  @override
  Future<void> removeSessionInfo({int? appType}) async {
    _sessionInfos.removeWhere((element) => element.appType == appType);
    await _saveToKeychain();
  }

  @override
  Future<void> save(
      {required AuthSessionInterface sessionInfo, int appType = 0}) async {
    if (_isRunningTest) {
      return;
    }
    var existSession =
        _sessionInfos.firstWhereOrNull((element) => element.appType == appType);
    if (existSession == null) {
      _sessionInfos
          .add(StorageSessionInfo(appType: appType, sessionInfo: sessionInfo));
    } else {
      _sessionInfos.removeWhere((element) => element.appType == appType);
      _sessionInfos
          .add(StorageSessionInfo(appType: appType, sessionInfo: sessionInfo));
    }
    await _saveToKeychain();
  }

  @override
  AuthSessionInterface? getCurrentSessionInfo({int appType = 0}) {
    var first =
        _sessionInfos.firstWhereOrNull((element) => element.appType == appType);
    return first?.sessionInfo;
  }
}
