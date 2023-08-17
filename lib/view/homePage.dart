import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';

import '../api/request.dart';
import '../model/station.dart';
import '../model/train.dart';

class HomePage extends StatefulWidget {
  final String title;

  const HomePage({super.key, required this.title});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Request _request = Request();
  List<Station> _stations = [];
  List<Train> _departures = [];

  @override
  void initState() {
    _request.fetchStation().then((value) {
      _stations = value;
      //_request.readCsv().then((value) {
        setState(() {
          //_stations = value;
        });
      });
    //});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    GlobalKey<AutoCompleteTextFieldState<Station>> key = GlobalKey();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Train'),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(20),
            child: Align(
              alignment: Alignment.topCenter,
              child: AutoCompleteTextField<Station>(
                key: key,
                itemSubmitted: (item) {
                  _request.getTrainsFromAPISNCF(item).then((value) async {
                    _departures = value;
                    for (var train in _departures) {
                      await _request.getStops(train);
                      setState(() { });
                    }
                  });
                },
                suggestions: _stations,
                //link the list of stations to the autocomplete textfield
                itemBuilder: (context, suggestion) => ListTile(
                  //display the list of stations by their name
                  title: Text(suggestion.name),
                ),
                itemFilter: (suggestion, query) {
                  //search in the list of stations by their name
                  return suggestion.name.toLowerCase().contains(query.toLowerCase());
                },
                itemSorter: (a, b) {
                  //compare the stations by their name
                  return a.name.compareTo(b.name);
                },
                clearOnSubmit: false,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'City',
                ),
              )
            )
          ),
          Text(
            'Next departures',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _departures.length,
              itemBuilder: (context, index) {
                final departure = _departures[index];
                return Container(
                  margin: const EdgeInsets.only(left: 20, right: 20, bottom: 0, top: 10),
                  child: ListTile(
                    title: Text("${departure.localHour}h${departure.localMinute} - ${departure.to?.station?.name}"),
                    subtitle: Text("${departure.type?.name.replaceAll("_", " ")} ${departure.num}"),
                    shape: const RoundedRectangleBorder(
                      //borderRadius: BorderRadius.all(Radius.circular(32)),
                      side: BorderSide(color: Colors.black),
                    ),
                    onTap: () {
                      Navigator.pushNamed( context, '/map',
                        arguments: departure,
                      );
                    },
                  ),
                );
              }
            ),
          )
        ],
      ),
    );
  }
}