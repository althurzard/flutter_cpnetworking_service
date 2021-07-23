import 'auth_session_info.dart';

class StorageSessionInfo implements JSONable {
  int appType;
  AuthSessionInterface sessionInfo;
  StorageSessionInfo({required this.appType, required this.sessionInfo});

  @override
  Map<String, dynamic> toJson() {
    return {'appType': appType, 'sessionInfo': sessionInfo.toJson()};
  }

  factory StorageSessionInfo.fromJson(Map<String, dynamic> json) {
    return StorageSessionInfo(
        appType: json['appType'],
        sessionInfo: AuthSessionInfo.fromJson(json['sessionInfo']));
  }
}
