import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const RoadsApp());
}

class RoadsApp extends StatelessWidget {
  const RoadsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roads Mobile Application',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}