import 'package:dartnissanconnectna/dartnissanconnectna.dart';

main() {
  NissanConnectSession connectSession = new NissanConnectSession(debug: true);

  connectSession.login(username: "username", password: "password").then((vehicle) {
    print(vehicle.vin);
    print(vehicle.modelYear);
    print(vehicle.nickname);

    vehicle.requestBatteryStatus().then((battery) {
      print(battery);
    });
  });
}

