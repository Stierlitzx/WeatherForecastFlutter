import 'package:flutter/material.dart';
import 'package:weather_app_final/services/weather_service.dart';
import 'package:intl/intl.dart';

class TimeCard extends StatefulWidget {
  final HourlyWeather? hourlyWeather;
  final CityWeather? cityWeather;
  final bool isNow;

  const TimeCard({
    super.key, 
    this.hourlyWeather,
    this.cityWeather,
    this.isNow = false,
  });

  @override
  State<TimeCard> createState() => _TimeCardState();
}

class _TimeCardState extends State<TimeCard> {
  final WeatherService _weatherService = WeatherService();

  String _getDisplayTime() {
    if(widget.hourlyWeather != null) {
      return DateFormat('HH:mm').format(widget.hourlyWeather!.time);
    } else if(widget.cityWeather != null) {
      return widget.cityWeather!.cityName;
    }
    return '00:00';
  }

  String _getTemperature() {
    if(widget.hourlyWeather != null) {
      return '${widget.hourlyWeather!.temperature.round()}°';
    } else if(widget.cityWeather != null) {
      return '${widget.cityWeather!.temperature.round()}°';
    }
    return '0°';
  }

  String _getIcon() {
    if(widget.hourlyWeather != null) {
      return _weatherService.getWeatherIcon(widget.hourlyWeather!.icon);
    } else if(widget.cityWeather != null) {
      return _weatherService.getWeatherIcon(widget.cityWeather!.icon);
    }
    return 'assets/sunny_cloud.png';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Container(
        decoration: widget.isNow ? BoxDecoration(
          color: Colors.white.withOpacity(.3),
          borderRadius: BorderRadius.all(Radius.circular(20)),
          border: Border.all(
            color: Colors.white.withOpacity(.7),
          ),
        ) : BoxDecoration(),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            children: [
              SizedBox(height: 12,),
              Text(
                _getTemperature(),
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
              SizedBox(height: 0,),
              Image(
                width: 64,
                image: AssetImage(_getIcon())
              ),
              SizedBox(height: 0,),
              Text(
                _getDisplayTime(),
                overflow: TextOverflow.fade,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Overpass',
                  fontSize: widget.cityWeather != null ? 16 : 24,
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
            ],
          ),
        ),
      ),
    );
  }
}