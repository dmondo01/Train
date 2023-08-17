
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';

import '../model/station.dart';
import '../model/stop.dart';
import '../model/train.dart';
import '../model/type_train.dart';
import '../api_key.dart';

class Request {
  String sncfToken = sncfApiKey;
  String googleToken = googleApiKey;
  List<Station> stations = [];

  Future<List<Station>> fetchStation() async {
    final response = await http.get(Uri.parse('https://ressources.data.sncf.com/api/v2/catalog/datasets/referentiel-gares-voyageurs/exports/json?limit=-1&offset=0&timezone=UTC'));

    if (response.statusCode == 200) {
      List<dynamic> listJson = jsonDecode(response.body);
      for (var element in listJson) {
          if(element['longitude_entreeprincipale_wgs84'] != null && element['latitude_entreeprincipale_wgs84'] != null){
            String nom = element['gare_alias_libelle_noncontraint'];
            double? lon = double.parse(element['longitude_entreeprincipale_wgs84']);
            double? lat = double.parse(element['latitude_entreeprincipale_wgs84']);
            int codeUIC = int.parse(element['uic_code']);
          stations.add(Station(codeUIC, nom, lon, lat));
        }
      }
    }
    await _readCsv();
    return stations;
  }

  Future<void> _readCsv() async {
    var result = await rootBundle.loadString("assets/data/gares.csv");
    const CsvToListConverter().convert(result, eol: '\n', fieldDelimiter: ';').forEach((element) {
      if(_getStation(element[0]) == null) {
        stations.add(Station(element[0], element[1], element[2], element[3]));
      }
    });
  }

  Future<List<Train>> getTrainsFromAPISNCF(Station station) async {
    final response = await http.get(Uri.parse('https://api.sncf.com/v1/coverage/sncf/stop_areas/stop_area:SNCF:${station.codeUIC}/departures/?count=8&key=$sncfToken&'));
    List<Train> trains = [];

    if(response.statusCode == 200) {
      Map<String, dynamic> listJson = jsonDecode(response.body);

      // For each departing train
      listJson['departures'].forEach((element) {
        // Retrieve the departure time of the train from the selected station
        Map<String, dynamic> stop_date_time = element["stop_date_time"];
        String localHour = stop_date_time["departure_date_time"].substring(9,11);
        String localMinute = stop_date_time["departure_date_time"].substring(11,13);

        // Find the type of train
        Map<String, dynamic> informations = element["display_informations"];
        String typeStr = informations["network"];

        TypeTrain type;
        try {
          type = TypeTrain.values.byName(
              typeStr.replaceAll(" ", "_").replaceAll("é", "e").toUpperCase());
        }
        on ArgumentError {
          type = TypeTrain.UNKNOWN;
        }

        // Find the num of the train
        int num = int.parse(informations["trip_short_name"]);

        // Vehicle journey id
        String vehicleJourney = element["links"][1]["id"];
        var list = vehicleJourney.split(":");
        if(list.length > 6) {
          vehicleJourney = "${list[0]}:${list[1]}:${list[2]}:${list[3]}:${list[4]}:${list[5]}";
        }

        // Create a new Train
        Train train = Train(num, type, localHour, localMinute);
        train.vehicleJourney = vehicleJourney;

        // Add the train to the list
        trains.add(train);
      });
    }
    return trains;
  }

  Future<void> getStops(Train train) async {
    final response = await http.get(Uri.parse('https://api.sncf.com/v1/coverage/sncf/vehicle_journeys/${train.vehicleJourney}?key=$sncfToken&'));
    if(response.statusCode == 200) {
      Map<String, dynamic> listJson = jsonDecode(response.body);
      var allStops = listJson["vehicle_journeys"][0];
      // For each stop
      allStops["stop_times"].forEach((element){
        Map<String, dynamic> stopPoint = element["stop_point"];

        int codeUIC = int.parse(stopPoint["id"].split(":")[2]);
        String hourArrival = element["arrival_time"].substring(0,2);
        String minuteArrival = element["arrival_time"].substring(2,4);
        String hourDeparture = element["departure_time"].substring(0,2);
        String minuteDeparture = element["departure_time"].substring(2,4);

        // Determines if the station is the departure station
        bool departureStation = !element["drop_off_allowed"];
        // Determines if the station is the arrival station
        bool arrivalStation = !element["pickup_allowed"];

        Station? station = _getStation(codeUIC);

        // Add informations to the object Train
        train.addStop(Stop(station, hourArrival, minuteArrival, hourDeparture, minuteDeparture), departureStation, arrivalStation);
      });
    }
  }

  Station? _getStation(int codeUIC) {
    Station? s;
    for (var station in stations) {
      if(station.codeUIC == codeUIC) {
        s = station;
        continue;
      }
    }
    return s;
  }

  Future<List<LatLng>> getRoute(LatLng from, LatLng to) async{
    PolylinePoints polylinePoints = PolylinePoints();
    List<LatLng> points = [];


    PolylineResult response = await polylinePoints.getRouteBetweenCoordinates(
      googleToken,
      PointLatLng(from.latitude, from.longitude),
      PointLatLng(to.latitude, to.longitude),
      travelMode: TravelMode.transit,
    );

    if(response.points.isNotEmpty) {
      for (var point in response.points) {
        points.add(LatLng(point.latitude, point.longitude));
      }
    }
    return points;
  }
}