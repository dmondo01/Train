import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../api/request.dart';
import '../model/train.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late GoogleMapController mapController;
  final List<Marker> markers = [];
  final Set<Polyline> polyline = {};
  late Train train;
  LatLng center = const LatLng(48.866667, 2.333333);
  LatLng? last;

  void onMapCreated(GoogleMapController controller) {
    List<LatLng> listLatLng = [];
    Request r = Request();
    mapController = controller;

    for (var stop in train.stops) {
      markers.add(Marker(
          markerId: MarkerId(stop.station.name),
          position: LatLng(stop.station.lat, stop.station.lon),
          infoWindow: InfoWindow(
              title: stop.station.name,
              snippet: "${stop.hourArrival}h${stop.minuteArrival} - ${stop
                  .hourDeparture}h${stop.minuteDeparture}"
          )
      ));

      listLatLng.add(LatLng(stop.station.lat, stop.station.lon));

      if (last != null) {
        r.getRoute(last!, LatLng(stop.station.lat, stop.station.lon)).then((value) {
          polyline.add(
              Polyline(
                  polylineId: PolylineId(stop.station.name),
                  points: value,
                  color: Colors.blue
              )
          );
          setState(() {
            _centerCamera();
          });
        });
      }
      last = LatLng(stop.station.lat, stop.station.lon);
    }

  }

  @override
  Widget build(BuildContext context) {
    train = ModalRoute.of(context)!.settings.arguments as Train;

    return Scaffold(
        appBar: AppBar(
          title: const Text('My Train'),
        ),
        body: Column(
            children: [
              Text("${train.type?.name.replaceAll("_", " ")} ${train.num}",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text("${train.from?.station?.name} - ${train.to?.station?.name}",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Expanded(
                child:
                GoogleMap(
                  onMapCreated: onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: center,
                    zoom: 8.0,
                  ),
                  markers: markers.toSet(),
                  polylines: polyline,
                ),
              )
            ]
        )
    );
  }

  void _centerCamera() {
    double minLat = polyline.first.points.first.latitude;
    double minLong = polyline.first.points.first.longitude;
    double maxLat = polyline.first.points.first.latitude;
    double maxLong = polyline.first.points.first.longitude;

    for (var poly in polyline) {
      for (var point in poly.points) {
        if (point.latitude < minLat) minLat = point.latitude;
        if (point.latitude > maxLat) maxLat = point.latitude;
        if (point.longitude < minLong) minLong = point.longitude;
        if (point.longitude > maxLong) maxLong = point.longitude;
      }
    }
    mapController.animateCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(
            southwest: LatLng(minLat, minLong),
            northeast: LatLng(maxLat, maxLong)),
        22));
  }
}