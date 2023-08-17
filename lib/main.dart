import 'package:flutter/material.dart';

import 'view/homePage.dart';

void main() {
  runApp(
      MaterialApp(
        title: 'My Train',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        routes: {
          '/' : (context) => const HomePage(title: 'My Train'),
        },
        initialRoute: '/',
      )
  );
}