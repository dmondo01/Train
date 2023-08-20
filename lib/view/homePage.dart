import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../api/request.dart';
import 'stationView.dart';

class HomePage extends StatefulWidget {
  final String title;

  const HomePage({super.key, required this.title});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Request _request = Request();
  int _selectedIndex = 0;
  final List _pages = [
    const Center(
      child: StationView(title: 'My Train',),
    ),
    const Center(
      //child: StationView(title: 'My Train',),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _request.fetchStation().then((value) {
      setState(() {
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Train'),
      ),
      body:_pages[_selectedIndex],
      bottomNavigationBar:
      CupertinoTabBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home, color: Colors.black),
            label: 'Station',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.train_style_one, color: Colors.black),
            label: 'Train',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int value) {
    setState(() {
      _selectedIndex = value;
    });
  }
}