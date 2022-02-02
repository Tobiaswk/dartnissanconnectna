import 'dart:convert';

import 'package:http/http.dart' as http;

/// Used for getting Firebase Remote Config key-value pairs
/// Nissan uses a Firebase Remote Config to store some
/// "secrets" for their clients
/// This class fetches these key-value pairs using the Firebase Remote Config API
class FirebaseRemoteConfig {
  static Future<Map> load() async {
    var appId = '1:25831104952:android:364bc23813c51afc';
    var projectId = '25831104952';
    var apiKey = 'AIzaSyBOFbpZI5N9zjx60DWWHETK52P0cTJ2RmM';
    var androidPackage = 'com.aqsmartphone.android.nissan';
    var androidCert = '94A5A06227EDB35F48BCA5092C2C091AD44C76EE';

    var firebaseRemoteConfigResponse = await http.post(
        Uri.parse(
            'https://firebaseremoteconfig.googleapis.com/v1/projects/$projectId/namespaces/firebase:fetch'),
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': '$apiKey',
          'X-Android-Package': '$androidPackage',
          'X-Android-Cert': '$androidCert',
        },
        body: json.encode({
          'appId': '$appId',
          'appInstanceId': 'dummy',
        }));
    return json.decode(firebaseRemoteConfigResponse.body)['entries'];
  }
}
