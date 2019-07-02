import 'package:dartnissanconnectna/src/nissanconnect_response.dart';
import 'package:dartnissanconnectna/src/nissanconnect_vehicle.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NissanConnectSession {
  final String baseUrl = "https://icm.infinitiusa.com/NissanLeafProd/rest/";
  final String apiKey = "f950a00e-73a5-11e7-8cf7-a6006ad3dba0";

  bool debug;
  List<String> debugLog = List<String>();

  var username;
  var password;
  var authToken;
  var authCookie;

  NissanConnectVehicle vehicle;
  List<NissanConnectVehicle> vehicles;

  NissanConnectSession({this.debug = false});

  Future<NissanConnectResponse> requestWithRetry(
      {String endpoint, String method = "POST", Map params}) async {
    NissanConnectResponse response =
        await request(endpoint: endpoint, method: method, params: params);

    var status = response.statusCode;

    if (status != null && status >= 400) {
      _print(
          'NissanConnect API; logging in and trying request again: $response');

      await login(username: username, password: password);

      response =
          await request(endpoint: endpoint, method: method, params: params);
    }
    return response;
  }

  Future<NissanConnectResponse> request(
      {String endpoint, String method = "POST", Map params}) async {
    _print('Invoking NissanConnect API: $endpoint');
    _print('Params: $params');

    Map<String, String> headers = Map();
    headers["Content-Type"] = "application/json";
    headers["API-Key"] = apiKey;

    if (authCookie != null) {
      headers["Cookie"] = authCookie;
    }

    if (authToken != null) {
      headers["Authorization"] = authToken;
    }

    _print('Headers: $headers');

    http.Response response;
    switch (method) {
      case "GET":
        response = await http.get("${baseUrl}${endpoint}", headers: headers);
        break;
      default:
        response = await http.post("${baseUrl}${endpoint}",
            headers: headers, body: json.encode(params));
    }

    dynamic jsonData = json.decode(response.body);

    _print('result: $jsonData');

    return NissanConnectResponse(
        response.statusCode, response.headers, jsonData);
  }

  Future<NissanConnectVehicle> login({String username, String password}) async {
    this.username = username;
    this.password = password;

    NissanConnectResponse response =
        await request(endpoint: "auth/authenticationForAAS", params: {
      "authenticate": {
        "userid": username,
        "password": password,
        "brand-s": "N",
        "language-s": "en_US",
        "country": "US"
      }
    });

    this.authCookie = response.headers["set-cookie"];
    this.authToken = response.body["authToken"];

    vehicles = List<NissanConnectVehicle>();

    for (Map vehicle in response.body["vehicles"]) {
      vehicles.add(new NissanConnectVehicle(
          this, vehicle["uvi"], vehicle["modelyear"], vehicle["nickname"]));
    }

    return vehicle = vehicles.first;
  }

  _print(message) {
    if (debug) {
      print(message);
      debugLog.add(message);
    }
  }
}
