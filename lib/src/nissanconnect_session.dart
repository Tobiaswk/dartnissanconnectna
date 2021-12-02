import 'dart:async';
import 'dart:convert';

import 'package:dartnissanconnectna/src/nissanconnect_response.dart';
import 'package:dartnissanconnectna/src/nissanconnect_vehicle.dart';
import 'package:http/http.dart' as http;

class NissanConnectSession {
  final String baseUrl =
      'https://icm.infinitiusa.com/NissanConnectEVProd/rest/';
  final String apiKey =
      'bJG8LvpcRAAOrVQ8GByIzWkR4n993iccFtKNs1sn+gheOFGnT6ABaR6cvclCXetW';
  final String userAgentKey = 'pZiN3BSpfjtVulW6QB52Itw6rc5YEDZXKGlKzGsTvPY=';

  bool debug;
  List<String> debugLog = [];

  String? username;
  String? password;
  String? authToken;
  String? authCookie;
  String? userAgent;

  late NissanConnectVehicle vehicle;
  late List<NissanConnectVehicle> vehicles;

  NissanConnectSession({this.debug = false});

  Future<NissanConnectResponse> requestWithRetry(
      {required String endpoint, String method = 'POST', Map? params}) async {
    NissanConnectResponse response =
        await request(endpoint: endpoint, method: method, params: params);

    if (response.statusCode >= 400) {
      _print(
          'NissanConnect API; logging in and trying request again: $response');

      await login(
          username: username!, password: password!, userAgent: userAgent);

      response =
          await request(endpoint: endpoint, method: method, params: params);
    }
    return response;
  }

  Future<NissanConnectResponse> request(
      {required String endpoint, String method = 'POST', Map? params}) async {
    _print('Invoking NissanConnect (NA) API: $endpoint');
    _print('Params: $params');

    Map<String, String> headers = Map();
    headers['Content-Type'] = 'application/json';
    headers['Api-Key'] = apiKey;
    headers['User-Agent-Key'] = userAgentKey;

    if (userAgent != null) {
      headers['User-Agent'] = userAgent!;
    }

    if (authCookie != null) {
      headers['Cookie'] = authCookie!;
    }

    if (authToken != null) {
      headers['Authorization'] = authToken!;
    }

    _print('Headers: $headers');

    http.Response response;
    switch (method) {
      case 'GET':
        response = await http.get(Uri.parse('${baseUrl}${endpoint}'),
            headers: headers);
        break;
      default:
        response = await http.post(Uri.parse('${baseUrl}${endpoint}'),
            headers: headers, body: json.encode(params));
    }

    dynamic jsonData;
    try {
      jsonData = json.decode(response.body);
      _print('Result: $jsonData');
    } catch (e) {
      _print('JSON decoding failed!');
    }

    return NissanConnectResponse(
        response.statusCode, response.headers, jsonData);
  }

  Future<NissanConnectVehicle> login(
      {required String username,
      required String password,
      String countryCode = 'US',
      String? userAgent}) async {
    this.username = username;
    this.password = password;
    this.userAgent = userAgent;

    NissanConnectResponse response =
        await request(endpoint: 'auth/authenticationForAAS', params: {
      'authenticate': {
        'userid': username,
        'password': password,
        'brand-s': 'N',
        'language-s': 'EN',
        'country': countryCode // ISO 3166-1 alpha-2 code
      }
    });

    /// For some reason unbeknownst the set-cookie contains key-value pairs
    /// that should not be used in the Cookie header (if present requests fails)
    /// We remove these key-value pairs manually
    authCookie = response.headers['set-cookie']
        .replaceAll(RegExp(r' Expires=.*?;'), '')
        .replaceAll(RegExp(r' Path=.*?;'), '')
        .replaceAll('SameSite=None,', '');

    authToken = response.body['authToken'];

    vehicles = <NissanConnectVehicle>[];

    for (Map vehicle in response.body['vehicles']) {
      vehicles.add(NissanConnectVehicle(
          this,
          vehicle['uvi'],
          vehicle['modelyear'],
          vehicle['nickname'],
          vehicle['interiorTempRecords'] != null
              ? vehicle['interiorTempRecords']['inc_temp']
              : null));
    }

    return vehicle = vehicles.first;
  }

  _print(message) {
    if (debug) {
      print('\$ $message');
      debugLog.add('\$ $message');
    }
  }
}
