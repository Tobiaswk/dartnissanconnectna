import 'package:dartnissanconnectna/src/nissanconnect_trip_detail.dart';

class NissanConnectTrip {
  late DateTime date;
  late String co2reductionKg;
  late String milesPerKWh;
  late String kilometersPerKWh;
  late String kWhPerMiles;
  late String kWhPerKilometers;
  late String kWhUsed;
  late String travelDistanceMiles;
  late String travelDistanceKilometers;

  List<NissanConnectTripDetail> tripDetails = [];
}
