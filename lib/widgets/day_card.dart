import 'package:flutter/material.dart';
import 'package:weather_app_final/services/weather_service.dart';
import 'package:intl/intl.dart';

class DayCard extends StatefulWidget {
  final DailyWeather dailyWeather;

  const DayCard({super.key, required this.dailyWeather});

  @override
  State<DayCard> createState() => _DayCardState();
}

class _DayCardState extends State<DayCard> {
  final WeatherService _weatherService = WeatherService();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      child: Container(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(
            children: [
              SizedBox(width: 12,),
              Text(
                DateFormat('MMM, d').format(widget.dailyWeather.time),
                overflow: TextOverflow.fade,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Overpass',
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                  shadows: [
                    Shadow(
                      offset: Offset(-1.0, 1.0),
                      blurRadius: 3.0,
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ],
                ),
              ),
              Expanded(child: Container()),
              Image(
                width: 64,
                image: AssetImage(_weatherService.getWeatherIcon(widget.dailyWeather.icon))
              ),
              Expanded(child: Container()),
              Text(
                "${widget.dailyWeather.tempHigh.round()}°",
                overflow: TextOverflow.fade,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Overpass',
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                  shadows: [
                    Shadow(
                      offset: Offset(-1.0, 1.0),
                      blurRadius: 3.0,
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 6,)
            ],
          ),
        ),
      ),
    );
  }
}