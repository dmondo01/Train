import 'station.dart';

class Stop{
  final Station? _station;
  String _hourArrival = "";
  String _minuteArrival = "";
  String _hourDeparture = "";
  String _minuteDeparture = "";

  Stop(this._station, this._hourArrival, this._minuteArrival, this._hourDeparture, this._minuteDeparture);

  Station? get station =>_station;
  String get hourArrival => _hourArrival;
  String get minuteDeparture => _minuteDeparture;
  String get hourDeparture => _hourDeparture;
  String get minuteArrival => _minuteArrival;
}