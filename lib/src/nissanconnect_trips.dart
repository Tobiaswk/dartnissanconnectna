import 'package:dartnissanconnectna/src/nissanconnect_trip.dart';
import 'package:dartnissanconnectna/src/nissanconnect_trip_detail.dart';
import 'package:dartnissanconnectna/src/unit_calculator.dart';
import 'package:intl/intl.dart';

class NissanConnectTrips {
  UnitCalculator unitCalculator = new UnitCalculator();
  List<NissanConnectTrip> trips = List();

  NissanConnectTrips(Map map) {
    List trips = map['priceSimulatorDetailInfoResponsePersonalData']
            ['priceSimulatorDetailInfoDateList']['priceSimulatorDetailInfoDate']
        .reversed
        .toList();

    for (Map trip in trips) {
      NissanConnectTrip nissanConnectTrip = new NissanConnectTrip();
      nissanConnectTrip.date =
          new DateFormat('yyyy-MM-dd').parse(trip['targetDate'], true);

      double totalCo2reductionKg = 0;
      double totalWhUsed = 0;
      double totalTravelDistanceMeters = 0;

      for (Map tripDetail in trip['priceSimulatorDetailInfoTripList']
          ['priceSimulatorDetailInfoTrip']) {
        NissanConnectTripDetail connectTripDetail =
            new NissanConnectTripDetail();
        connectTripDetail.tripId = tripDetail['tripId'];
        connectTripDetail.co2ReductionKg =
            "${tripDetail['cO2Reduction']} kg CO2";
        connectTripDetail.milesPerKWh = unitCalculator.milesPerKWhPretty(
                double.parse(tripDetail['powerConsumptTotal']),
                double.parse(tripDetail['travelDistance'])) +
            ' miles/kWh';
        connectTripDetail.kWhPerMiles = unitCalculator.kWhPerMilesPretty(
                double.parse(tripDetail['powerConsumptTotal']),
                double.parse(tripDetail['travelDistance'])) +
            ' kWh/miles';
        connectTripDetail.kilometersPerKWh =
            unitCalculator.kilometersPerKWhPretty(
                    double.parse(tripDetail['powerConsumptTotal']),
                    double.parse(tripDetail['travelDistance'])) +
                ' km/kWh';
        connectTripDetail.kWhPerKilometers =
            unitCalculator.kWhPerKilometersPretty(
                    double.parse(tripDetail['powerConsumptTotal']),
                    double.parse(tripDetail['travelDistance'])) +
                ' kWh/km';
        connectTripDetail.kWhUsed = unitCalculator.WhtoKWhPretty(
                double.parse(tripDetail['powerConsumptTotal'])) +
            ' kWh';
        connectTripDetail.travelDistanceKilometers =
            unitCalculator.toKilometersPretty(
                    double.parse(tripDetail['travelDistance'])) +
                ' km';
        connectTripDetail.travelDistanceMiles = unitCalculator
                .toMilesPretty(double.parse(tripDetail['travelDistance'])) +
            ' km';

        totalCo2reductionKg += int.parse(tripDetail['cO2Reduction']);
        totalWhUsed += double.parse(tripDetail['powerConsumptTotal']);
        totalTravelDistanceMeters += double.parse(tripDetail['travelDistance']);

        nissanConnectTrip.tripDetails.add(connectTripDetail);
      }

      nissanConnectTrip.co2reductionKg = "${totalCo2reductionKg} CO2 kg";
      nissanConnectTrip.milesPerKWh = unitCalculator.milesPerKWhPretty(
              totalWhUsed, totalTravelDistanceMeters) +
          ' miles/kWh';
      nissanConnectTrip.kWhPerMiles = unitCalculator.kWhPerMilesPretty(
              totalWhUsed, totalTravelDistanceMeters) +
          ' kWh/miles';
      nissanConnectTrip.kilometersPerKWh = unitCalculator
              .kilometersPerKWhPretty(totalWhUsed, totalTravelDistanceMeters) +
          ' km/kWh';
      nissanConnectTrip.kWhPerKilometers = unitCalculator
              .kWhPerKilometersPretty(totalWhUsed, totalTravelDistanceMeters) +
          ' kWh/km';
      nissanConnectTrip.kWhUsed =
          unitCalculator.WhtoKWhPretty(totalWhUsed) + ' kWh';
      nissanConnectTrip.travelDistanceMiles =
          unitCalculator.toMilesPretty(totalTravelDistanceMeters) + ' miles';
      nissanConnectTrip.travelDistanceKilometers =
          unitCalculator.toKilometersPretty(totalTravelDistanceMeters) + ' km';

      this.trips.add(nissanConnectTrip);
    }
  }
}
