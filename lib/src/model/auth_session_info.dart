abstract class JSONable {
  Map<String, dynamic> toJson();
}

abstract class AuthSessionInterface implements JSONable {
  late String accessToken;
  late String phoneNumber;
}

class AuthSessionInfo implements AuthSessionInterface {
  @override
  late String accessToken;
  @override
  late String phoneNumber;
  AuthSessionInfo({required this.accessToken, required this.phoneNumber});

  factory AuthSessionInfo.fromJson(Map<String, dynamic> json) {
    return AuthSessionInfo(
        accessToken: json['accessToken'], phoneNumber: json['phoneNumber']);
  }

  @override
  Map<String, dynamic> toJson() {
    return {'accessToken': accessToken, 'phoneNumber': phoneNumber};
  }
}
