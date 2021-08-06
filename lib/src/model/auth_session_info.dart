import 'dart:convert';

abstract class JSONable {
  Map<String, dynamic> toJson();
}

abstract class AuthSessionInterface implements JSONable {
  late String accessToken;
  late String phoneNumber;
  late Map<String, dynamic> others;
}

class AuthSessionInfo implements AuthSessionInterface {
  @override
  late String accessToken;
  @override
  late String phoneNumber;
  @override
  Map<String, dynamic> others;
  AuthSessionInfo(
      {required this.accessToken,
      required this.phoneNumber,
      this.others = const {}});

  factory AuthSessionInfo.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? others = jsonDecode(json['others'] ?? '{}');
    return AuthSessionInfo(
        accessToken: json['accessToken'],
        phoneNumber: json['phoneNumber'],
        others: others ?? {});
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'phoneNumber': phoneNumber,
      'others': jsonEncode(others)
    };
  }
}
