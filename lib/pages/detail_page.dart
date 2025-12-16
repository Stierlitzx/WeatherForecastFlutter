import 'package:flutter/material.dart';
import 'package:weather_app_final/widgets/time_card.dart';
import 'package:weather_app_final/widgets/day_card.dart';
import 'package:weather_app_final/widgets/weather_background.dart';
import 'package:weather_app_final/services/weather_service.dart';
import 'package:intl/intl.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final WeatherService _weatherService = WeatherService();
  List<HourlyWeather> _hourlyForecast = [];
  List<CityWeather> _cityWeather = [];
  List<DailyWeather> _dailyForecast = [];
  WeatherData? _currentWeather;
  bool _isLoading = true;
  String _forecastType = 'hourly'; // hourly, nearby, or static

  @override
  void initState() {
    super.initState();
    _loadForecastData();
  }

  Future<void> _loadForecastData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load current weather for the metrics
      _currentWeather = await _weatherService.getCurrentWeather();

      // Try to get hourly forecast first
      final hourly = await _weatherService.getHourlyForecast();
      
      if(hourly.isNotEmpty) {
        setState(() {
          _hourlyForecast = hourly;
          _forecastType = 'hourly';
          _isLoading = false; 
        });
      } else {
        // Fallback to nearby cities
        try {
          final position = await _weatherService.getCurrentLocation();
          final nearby = await _weatherService.getNearbyCitiesWeather(
            position.latitude, 
            position.longitude
          );
          
          if(nearby.isNotEmpty) {
            setState(() {
              _cityWeather = nearby;
              _forecastType = 'nearby';
              _isLoading = false;
            });
          } else {
            // Final fallback to static cities
            final static = await _weatherService.getStaticCitiesWeather();
            setState(() {
              _cityWeather = static;
              _forecastType = 'static';
              _isLoading = false;
            });
          }
        } catch(e) {
          // If location fails, go straight to static cities
          final static = await _weatherService.getStaticCitiesWeather();
          setState(() {
            _cityWeather = static;
            _forecastType = 'static';
            _isLoading = false;
          });
        }
      }

      // Load daily forecast
      final daily = await _weatherService.getDailyForecast();
      setState(() {
        _dailyForecast = daily;
      });

    } catch(e) {
      print('Error loading forecast: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildTimeCards() {
    if(_forecastType == 'hourly' && _hourlyForecast.isNotEmpty) {
      return SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _hourlyForecast.asMap().entries.map((entry) {
            return TimeCard(
              hourlyWeather: entry.value,
              isNow: entry.key == 0,
            );
          }).toList(),
        ),
      );
    } else if(_cityWeather.isNotEmpty) {
      return SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _cityWeather.map((city) {
            return TimeCard(
              cityWeather: city,
              isNow: false,
            );
          }).toList(),
        ),
      );
    }
    
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WeatherBackground(
        child: SafeArea(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: _isLoading ? 
              Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ) 
            : SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Row(
                            children: [
                              Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                              SizedBox(width: 8,),
                              Text(
                                "Back",
                                overflow: TextOverflow.fade,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Overpass',
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(-1.0, 1.0),
                                      blurRadius: 3.0,
                                      color: Colors.black.withOpacity(0.3),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        Expanded(child: Container()),
                        GestureDetector(
                          child: Image(
                            width: 24,
                            image: AssetImage('assets/setting.png')
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 0),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 22),
                    child: Row(
                      children: [
                        Text(
                          _forecastType == 'hourly' ? "Today" : "Locations",
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Overpass',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
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
                        Text(
                          DateFormat('MMM, d').format(DateTime.now()),
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Overpass',
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
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
                  _buildTimeCards(),
                  SizedBox(height: 48,),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 28),
                    child: Row(
                      children: [
                        Text(
                          "Next Forecast",
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Overpass',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
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
                          width: 24,
                          image: AssetImage(
                            'assets/calendar.png',
                          )
                        ),
                      ],
                    ),
                  ),
                  _dailyForecast.isNotEmpty ?
                    SingleChildScrollView(
                      child: Column(
                        children: _dailyForecast.map((day) => DayCard(dailyWeather: day)).toList(),
                      )
                    )
                  : Container(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          'No daily forecast available',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Overpass',
                          ),
                        ),
                      ),
                    ),
                  SizedBox(height: 12,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 165,
                              height: 130,
                              decoration: BoxDecoration(
                              color: Colors.white.withOpacity(.3),
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                              border: Border.all(
                                color: Colors.white.withOpacity(.7),
                              ),
                            ),
                              child: Column(
                                children: [
                                  SizedBox(height: 4,),
                                  Text(
                                    "Air pressure",
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
                                  SizedBox(height: 16,),
                                  Text(
                                    "${_currentWeather?.pressure.round() ?? 1000}",
                                    overflow: TextOverflow.fade,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Overpass',
                                      fontSize: 32,
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
                              )
                            ),
                            SizedBox(height: 16,),
                            Container(
                              width: 165,
                              height: 130,
                              decoration: BoxDecoration(
                              color: Colors.white.withOpacity(.3),
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                              border: Border.all(
                                color: Colors.white.withOpacity(.7),
                              ),
                            ),
                              child: Column(
                                children: [
                                  SizedBox(height: 4,),
                                  Text(
                                    "Smoke",
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
                                  SizedBox(height: 16,),
                                  Text(
                                    "${_currentWeather?.smoke.round() ?? 8}%",
                                    overflow: TextOverflow.fade,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Overpass',
                                      fontSize: 32,
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
                              )
                            ),
                          ],
                        ),
                        
                        Expanded(child: Container()),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 165,
                              height: 130,
                              decoration: BoxDecoration(
                              color: Colors.white.withOpacity(.3),
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                              border: Border.all(
                                color: Colors.white.withOpacity(.7),
                              ),
                            ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(height: 4,),
                                  Text(
                                    "Feels Like",
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
                                  SizedBox(height: 16,),
                                  Text(
                                    " ${_currentWeather?.feelsLike.round() ?? 23}°",
                                    overflow: TextOverflow.fade,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Overpass',
                                      fontSize: 32,
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
                              )
                            ),
                            
                            SizedBox(height: 16,),
                            Container(
                              width: 165,
                              height: 130,
                              decoration: BoxDecoration(
                              color: Colors.white.withOpacity(.3),
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                              border: Border.all(
                                color: Colors.white.withOpacity(.7),
                              ),
                            ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(height: 4,),
                                  Text(
                                    "UV Index",
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
                                  SizedBox(height: 16,),
                                  Text(
                                    "${_currentWeather?.uvIndex ?? 3}",
                                    overflow: TextOverflow.fade,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Overpass',
                                      fontSize: 32,
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
                              )
                            ),
                          ],
                        ),
                      ]
                    ),
                  ),
                  SizedBox(height: 12,),
                ],
              )
            )
          ),
        )
      ),
    );
  }
}