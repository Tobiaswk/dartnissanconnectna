import 'dart:convert';

import 'package:http/http.dart' as http;

/// Used for getting Firebase Remote Config key-value pairs
/// Nissan uses a Firebase Remote Config to store some
/// "secrets" for their clients
/// This class fetches these key-value pairs using the Firebase Remote Config API
class FirebaseRemoteConfig {
  static Future<Map> load(
      {required String appId,
      required String projectId,
      required String apiKey}) async {
    var firebaseRemoteConfigResponse = await http.post(
        Uri.parse(
            'https://firebaseremoteconfig.googleapis.com/v1/projects/$projectId/namespaces/firebase:fetch?key=$apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'appId': '$appId',
          'appInstanceId': 'dummy',
        }));

    return json.decode(firebaseRemoteConfigResponse.body)['entries'];
  }
}
