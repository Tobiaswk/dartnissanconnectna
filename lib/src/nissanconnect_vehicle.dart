import 'package:dartnissanconnectna/dartnissanconnectna.dart';
import 'package:dartnissanconnectna/src/nissanconnect_battery.dart';

class NissanConnectVehicle {
  var vin;
  var modelYear;
  var nickname;

  NissanConnectSession session;

  NissanConnectVehicle(this.vin, this.modelYear, this.nickname, this.session);

  Future<NissanConnectBattery> requestBatteryStatus() async {
    var response =
    await session.requestWithRetry(endpoint: "battery/vehicles/$vin/getChargingStatusRequest", method: "GET");

    return NissanConnectBattery(response.body);
  }
}