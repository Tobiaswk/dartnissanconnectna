import 'package:dartnissanconnectna/src/unit_calculator.dart';
import 'package:intl/intl.dart';

class NissanConnectStats {
  DateTime date;
  String co2ReductionKg;
  String milesPerKWh;
  String kilometersPerKWh;
  String kWhPerMiles;
  String kWhPerKilometers;
  String kWhUsed;
  String travelDistanceMiles;
  String travelDistanceKilometers;
  Duration travelTime;

  NissanConnectStats(Map map) {
    UnitCalculator unitCalculator = new UnitCalculator();

    this.co2ReductionKg =
        "${map['co2Reduction'] ?? map['cO2Reduction']} kg";
    this.milesPerKWh = unitCalculator.milesPerKWhPretty(
            double.parse(map['powerConsumptTotal']),
            double.parse(map['travelDistance'])) +
        ' miles/kWh';
    this.kWhPerMiles = unitCalculator.kWhPerMilesPretty(
            double.parse(map['powerConsumptTotal']),
            double.parse(map['travelDistance'])) +
        ' kWh/miles';
    this.kilometersPerKWh = unitCalculator.kilometersPerKWhPretty(
            double.parse(map['powerConsumptTotal']),
            double.parse(map['travelDistance'])) +
        ' km/kWh';
    this.kWhPerKilometers = unitCalculator.kWhPerKilometersPretty(
            double.parse(map['powerConsumptTotal']),
            double.parse(map['travelDistance'])) +
        ' kWh/km';
    this.kWhUsed =
        unitCalculator.WhtoKWhPretty(double.parse(map['powerConsumptTotal'])) +
            ' kWh';
    this.travelDistanceKilometers =
        unitCalculator.toKilometersPretty(double.parse(map['travelDistance'])) +
            ' km';
    this.travelDistanceMiles =
        unitCalculator.toMilesPretty(double.parse(map['travelDistance'])) +
            ' miles';
    this.travelTime = Duration(seconds: int.parse(map['travelTime']));
    if (map['targetDate'] != null) {
      this.date = new DateFormat('yyyy-MM-dd').parse(map['targetDate'], true);
    } else if (map['targetMonth'] != null) {
      // https://stackoverflow.com/questions/51042621/unable-to-covert-string-date-in-format-yyyymmddhhmmss-to-datetime-dart
      this.date = new DateFormat('yyyy.MM').parse(
          map['targetMonth'].substring(0, 4) +
              '.' +
              map['targetMonth'].substring(4), true);
    }
  }
}
