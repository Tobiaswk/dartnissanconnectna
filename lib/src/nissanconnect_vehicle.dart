import 'package:dartnissanconnectna/dartnissanconnectna.dart';
import 'package:dartnissanconnectna/src/nissanconnect_location.dart';
import 'package:dartnissanconnectna/src/nissanconnect_stats.dart';
import 'package:dartnissanconnectna/src/nissanconnect_trips.dart';
import 'package:intl/intl.dart';

class NissanConnectVehicle {
  var _targetDateFormatter = new DateFormat('yyyy-MM-dd');
  var _targetMonthFormatter = new DateFormat('yyyyMM');
  var _executionTimeFormatter = new DateFormat("yyyy-MM-dd'T'H:m:s'Z'");

  NissanConnectSession session;
  var vin;
  var modelYear;
  var nickname;
  var incTemperature;

  NissanConnectVehicle(this.session, this.vin, this.modelYear, this.nickname,
      this.incTemperature);

  Future<NissanConnectBattery> requestBatteryStatus() async {
    var response = await session.requestWithRetry(
        endpoint: "battery/vehicles/$vin/getChargingStatusRequest",
        method: "GET");

    return NissanConnectBattery(response.body);
  }

  Future<NissanConnectStats> requestDailyStatistics(DateTime date) async {
    var response = await session.requestWithRetry(
        endpoint: "ecoDrive/vehicles/$vin/driveHistoryRecords",
        method: "POST",
        params: {
          "displayCondition": {
            "TargetDate": _targetDateFormatter.format(date.toUtc())
          }
        });

    return NissanConnectStats(
        response.body['personalData']['dateSummaryDetailInfo']);
  }

  Future<NissanConnectStats> requestMonthlyStatistics(DateTime date) async {
    var response = await session.requestWithRetry(
        endpoint: "ecoDrive/vehicles/$vin/CarKarteGraphAllInfo",
        method: "POST",
        params: {
          "dateRangeLevel": "DAILY",
          "graphType": "ALL",
          "targetMonth": _targetMonthFormatter.format(date.toUtc())
        });

    return NissanConnectStats(
        response.body['carKarteGraphInfoResponseMonthPersonalData']
            ['monthSummaryCarKarteDetailInfo']);
  }

  Future<NissanConnectTrips> requestMonthlyStatisticsTrips(
      DateTime date) async {
    var response = await session.requestWithRetry(
        endpoint: "electricusage/vehicles/$vin/detailpriceSimulatordata",
        method: "POST",
        params: {"Targetmonth": _targetMonthFormatter.format(date.toUtc())});

    return NissanConnectTrips(response.body);
  }

  Future<bool> requestChargingStart() async {
    var response = await session.requestWithRetry(
        endpoint: "battery/vehicles/$vin/remoteChargingRequest",
        method: "POST");

    return response.statusCode == 200;
  }

  Future<bool> requestClimateControlOn(DateTime date) async {
    var response = await session.requestWithRetry(
        endpoint: "hvac/vehicles/$vin/activateHVAC",
        method: "POST",
        params: {
          "executionTime": _executionTimeFormatter.format(date.toUtc())
        });

    return response.statusCode == 200;
  }

  Future<bool> requestClimateControlScheduledCancel() async {
    var response = await session.requestWithRetry(
        endpoint: "hvacSchedule/vehicles/$vin/cancelHVACSchedule",
        method: "POST");

    return response.statusCode == 200;
  }

  Future<bool> requestClimateControlOff() async {
    var response = await session.requestWithRetry(
        endpoint: "hvac/vehicles/$vin/deactivateHVAC", method: "POST");

    return response.statusCode == 200;
  }

  Future<DateTime> requestClimateControlScheduled() async {
    var response = await session.requestWithRetry(
        endpoint: "hvacSchedule/vehicles/$vin/getHvacSchedule", method: "GET");

    return new DateFormat("yyyy-MM-dd'T'H:m:s")
        .parse(response.body['executeTime'], true);
  }

  Future<NissanConnectLocation> requestLocation(DateTime date) async {
    var response = await session.requestWithRetry(
        endpoint: "vehicleLocator/vehicles/$vin/refreshVehicleLocator",
        method: "POST",
        params: {
          "acquiredDataUpperLimit": "1",
          "searchPeriod":
              "${new DateFormat('yyyyMMdd').format(date.subtract(new Duration(days: 30)))},${new DateFormat('yyyyMMdd').format(date)}",
          "serviceName": "MyCarFinderResult"
        });

    return new NissanConnectLocation(response.body);
  }
}
