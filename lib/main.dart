import 'package:flutter/material.dart';
import 'features/map/screens/map_screen.dart';

void main() {
  runApp(const RoadsApp());
}

class RoadsApp extends StatelessWidget {
  const RoadsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roads',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MapScreen(),
    );
  }
}