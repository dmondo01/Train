import 'package:flutter/material.dart';

import 'view/homePage.dart';
import 'view/mapView.dart';

void main() {
  runApp(
      MaterialApp(
        title: 'My Train',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        routes: {
          '/' : (context) => const HomePage(title: 'My Train'),
          '/map' : (context) => const MapView(),
        },
        initialRoute: '/',
      )
  );
}