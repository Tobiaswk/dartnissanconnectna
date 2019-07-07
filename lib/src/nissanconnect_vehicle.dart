import 'package:dartnissanconnectna/dartnissanconnectna.dart';
import 'package:dartnissanconnectna/src/nissanconnect_stats.dart';
import 'package:dartnissanconnectna/src/nissanconnect_trips.dart';
import 'package:intl/intl.dart';

class NissanConnectVehicle {
  var _targetDateFormatter = new DateFormat('yyyy-MM-dd');
  var _targetMonthFormatter = new DateFormat('yyyyMM');

  NissanConnectSession session;
  var vin;
  var modelYear;
  var nickname;

  NissanConnectVehicle(this.session, this.vin, this.modelYear, this.nickname);

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
}
