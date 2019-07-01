import 'package:dartnissanconnectna/dartnissanconnectna.dart';

class NissanConnectVehicle {
  NissanConnectSession session;
  var vin;
  var modelYear;
  var nickname;

  NissanConnectVehicle(this.session, this.vin, this.modelYear, this.nickname);

  Future<NissanConnectBattery> requestBatteryStatus() async {
    var response =
    await session.requestWithRetry(endpoint: "battery/vehicles/$vin/getChargingStatusRequest", method: "GET");

    return NissanConnectBattery(response.body);
  }
}