import 'dart:ffi';

import 'stop.dart';
import 'type_train.dart';

class Train {
  int num = 0;
  TypeTrain? type;
  String localHour = "";
  String localMinute = "";
  String vehicleJourney = "";
  List stops = <Stop>[];
  Stop? from;
  Stop? to;

  Train(this.num, this.type, this.localHour, this.localMinute);

  void addStop(Stop stop, bool departureStation, bool arrivalStation) {
    stops.add(stop);
    if(departureStation) {
      from = stop;
    }

    if(arrivalStation) {
      to = stop;
    }
  }

  @override
  String toString() {
    return "${localHour}h$localMinute - ${to?.station?.name} \n ${type?.name} $num";
  }
}

