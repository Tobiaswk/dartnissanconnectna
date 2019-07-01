import 'package:dartnissanconnectna/dartnissanconnectna.dart';

main() {
  NissanConnectSession session = new NissanConnectSession(debug: true);

  session.login(username: "username", password: "password").then((vehicle) {
    print(vehicle.vin);
    print(vehicle.modelYear);
    print(vehicle.nickname);

    vehicle.requestBatteryStatus().then((battery) {
      print(battery);
    });
  });
}
