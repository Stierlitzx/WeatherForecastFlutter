import 'package:flutter/material.dart';
import 'package:weather_app_final/widgets/weather_background.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WeatherBackground(
        child: Center()
      ),
    );
  }
}