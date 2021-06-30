import 'package:dartnissanconnectna/dartnissanconnectna.dart';
import 'package:dartnissanconnectna/src/nissanconnect_location.dart';
import 'package:dartnissanconnectna/src/nissanconnect_stats.dart';
import 'package:dartnissanconnectna/src/nissanconnect_trips.dart';
import 'package:intl/intl.dart';

class NissanConnectVehicle {
  static const int BATTERY_STATUS_MAX_POLLING_RETRIES = 5;
  static const int BATTERY_STATUS_AGE_IN_MINUTES = 5;

  var _targetDateFormatter = DateFormat('yyyy-MM-dd');
  var _targetMonthFormatter = DateFormat('yyyyMM');
  var _executionTimeFormatter = DateFormat("yyyy-MM-dd'T'H:m:s'Z'");

  NissanConnectSession session;
  var vin;
  var modelYear;
  var nickname;
  double? incTemperature;

  NissanConnectVehicle(
      this.session, this.vin, this.modelYear, this.nickname, incTemperature) {
    this.incTemperature =
        incTemperature != null ? double.parse(incTemperature) : null;
  }

  Future<NissanConnectBattery> requestBatteryStatus(
      [DateTime? dateTime,
      int retries = BATTERY_STATUS_MAX_POLLING_RETRIES]) async {
    var response = await session.requestWithRetry(
        endpoint: 'battery/vehicles/$vin/getChargingStatusRequest',
        method: 'GET');

    var now = dateTime ?? DateTime.now();

    var result = NissanConnectBattery(response.body);

    if (now.difference(result.dateTime).inMinutes >
            BATTERY_STATUS_AGE_IN_MINUTES &&
        retries-- > 0) result = await requestBatteryStatus(dateTime, retries);

    return result;
  }

  Future<NissanConnectStats> requestDailyStatistics(DateTime date) async {
    var response = await session.requestWithRetry(
        endpoint: 'ecoDrive/vehicles/$vin/driveHistoryRecords',
        method: 'POST',
        params: {
          'displayCondition': {'TargetDate': _targetDateFormatter.format(date)}
        });

    return NissanConnectStats(
        response.body['personalData']['dateSummaryDetailInfo']);
  }

  Future<NissanConnectStats> requestMonthlyStatistics(DateTime month) async {
    var response = await session.requestWithRetry(
        endpoint: 'ecoDrive/vehicles/$vin/CarKarteGraphAllInfo',
        method: 'POST',
        params: {
          'dateRangeLevel': 'DAILY',
          'graphType': 'ALL',
          'targetMonth': _targetMonthFormatter.format(month)
        });

    return NissanConnectStats(
        response.body['carKarteGraphInfoResponseMonthPersonalData']
            ['monthSummaryCarKarteDetailInfo']);
  }

  Future<NissanConnectTrips> requestMonthlyStatisticsTrips(
      DateTime month) async {
    var response = await session.requestWithRetry(
        endpoint: 'electricusage/vehicles/$vin/detailpriceSimulatordata',
        method: 'POST',
        params: {'Targetmonth': _targetMonthFormatter.format(month)});
    return NissanConnectTrips(response.body);
  }

  Future<bool> requestChargingStart() async {
    var response = await session.requestWithRetry(
        endpoint: 'battery/vehicles/$vin/remoteChargingRequest',
        method: 'POST');

    return response.statusCode == 200;
  }

  Future<bool> requestClimateControlOn(DateTime date) async {
    var response = await session.requestWithRetry(
        endpoint: 'hvac/vehicles/$vin/activateHVAC',
        method: 'POST',
        params: {
          'executionTime': _executionTimeFormatter.format(date.toUtc())
        });

    return response.body['messageDeliveryStatus'] == 'Success';
  }

  Future<bool> requestClimateControlScheduledCancel() async {
    var response = await session.requestWithRetry(
        endpoint: 'hvacSchedule/vehicles/$vin/cancelHVACSchedule',
        method: 'POST');

    return response.body['messageDeliveryStatus'] == 'Success';
  }

  Future<bool> requestClimateControlOff() async {
    var response = await session.requestWithRetry(
        endpoint: 'hvac/vehicles/$vin/deactivateHVAC', method: 'POST');

    return response.body['messageDeliveryStatus'] == 'Success';
  }

  Future<DateTime> requestClimateControlScheduled() async {
    var response = await session.requestWithRetry(
        endpoint: 'hvacSchedule/vehicles/$vin/getHvacSchedule', method: 'GET');

    return DateFormat("yyyy-MM-dd'T'H:m:s")
        .parse(response.body['executeTime'], true)
        .toLocal();
  }

  Future<NissanConnectLocation> requestLocation(DateTime date) async {
    var response = await session.requestWithRetry(
        endpoint: 'vehicleLocator/vehicles/$vin/refreshVehicleLocator',
        method: 'POST',
        params: {
          'acquiredDataUpperLimit': '1',
          'searchPeriod':
              '${DateFormat('yyyyMMdd').format(date.subtract(Duration(days: 30)))},${DateFormat('yyyyMMdd').format(date)}',
          'serviceName': 'MyCarFinderResult'
        });

    return NissanConnectLocation(response.body);
  }
}
