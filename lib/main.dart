import 'package:flutter/material.dart';
import 'package:googlemapdemo/MyHomeScreen/mapstream.dart';
import 'package:googlemapdemo/MyHomeScreen/my_home_screen.dart';
import 'package:googlemapdemo/map_view/map_home_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MapHomeView(),
    );
  }
}
