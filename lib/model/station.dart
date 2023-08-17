class Station{
  final String _name;
  final double _lon;
  final double _lat;
  final int _codeUIC;

  Station(this._codeUIC, this._name, this._lon, this._lat);

  get name => _name;
  get lon => _lon;
  get lat => _lat;
  get codeUIC => _codeUIC;

  @override
  String toString() {
    return _name;
  }
}