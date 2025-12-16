import 'package:flutter/material.dart';
import 'package:weather_app_final/pages/detail_page.dart';
import 'package:weather_app_final/widgets/weather_background.dart';
import 'package:weather_app_final/services/weather_service.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherService _weatherService = WeatherService();
  WeatherData? _weatherData;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final weather = await _weatherService.getCurrentWeather();

      setState(() {
        _weatherData = weather;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  String _getFormattedDate() {
    if (_weatherData == null) return 'Today';
    return DateFormat('EEEE, d MMMM').format(_weatherData!.time);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: WeatherBackground(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              )
            : _errorMessage.isNotEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.white,
                          size: 64,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Failed to load weather',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontFamily: 'Overpass',
                          ),
                        ),
                        SizedBox(height: 8),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            _errorMessage,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                              fontFamily: 'Overpass',
                            ),
                          ),
                        ),
                        SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loadWeather,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                          ),
                          child: Text(
                            'Retry',
                            style: TextStyle(
                              color: Color(0xff444E72),
                              fontSize: 16,
                              fontFamily: 'Overpass',
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadWeather,
                    color: Color(0xff4A91FF),
                    child: SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            SizedBox(height: 20),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    print('location pressed');
                                  },
                                  child: Row(
                                    children: [
                                      Column(
                                        children: [
                                          Image(
                                            height: 24,
                                            width: 24,
                                            color: Colors.white,
                                            image: AssetImage('assets/mark.png'),
                                            fit: BoxFit.cover,
                                          ),
                                          SizedBox(height: 4),
                                        ],
                                      ),
                                      SizedBox(width: 24),
                                      Text(
                                        _weatherData?.cityName ?? 'Loading...',
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
                                      SizedBox(width: 14),
                                      Icon(
                                        Icons.keyboard_arrow_down_outlined,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(child: Container()),
                                IconButton(
                                  icon: Icon(
                                    Icons.notifications_none_rounded,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                  onPressed: () {
                                    print('pressed');
                                  },
                                )
                              ],
                            ),
                            SizedBox(height: 0),
                            Image(
                              image: AssetImage(
                                _weatherService.getWeatherIcon(_weatherData?.icon),
                              ),
                              errorBuilder: (context, error, stackTrace) {
                                return Image(
                                  image: AssetImage('assets/sunny_cloud.png'),
                                );
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(.3),
                                  borderRadius: BorderRadius.all(Radius.circular(20)),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(.7),
                                  ),
                                ),
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: Column(
                                    children: [
                                      SizedBox(height: 16),
                                      Text(
                                        _getFormattedDate(),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontFamily: 'Overpass',
                                          fontWeight: FontWeight.w400,
                                          shadows: [
                                            Shadow(
                                              offset: Offset(-2.0, 2.0),
                                              blurRadius: 3.0,
                                              color: Colors.black.withOpacity(0.2),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Container(
                                        height: 120,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              ' ${_weatherData?.temperature.round() ?? 0}',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 100,
                                                fontFamily: 'Overpass',
                                                fontWeight: FontWeight.w300,
                                                shadows: [
                                                  Shadow(
                                                    offset: Offset(-8.0, 8.0),
                                                    blurRadius: 22.0,
                                                    color: Colors.black.withOpacity(0.2),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Text(
                                              '°',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 100,
                                                fontFamily: 'Overpass',
                                                fontWeight: FontWeight.w300,
                                                shadows: [
                                                  Shadow(
                                                    offset: Offset(-8.0, 8.0),
                                                    blurRadius: 22.0,
                                                    color: Colors.black.withOpacity(0.2),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        _weatherData?.description ?? 'Cloudy',
                                        style: TextStyle( 
                                          color: Colors.white, 
                                          fontSize: 24, 
                                          fontFamily: 'Overpass', 
                                          fontWeight: FontWeight.bold,
                                          shadows: [  
                                            Shadow(
                                              offset: Offset(-2.0, 2.0), 
                                              blurRadius: 3.0, 
                                              color: Colors.black.withValues(alpha: 0.2), 
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Row( 
                                        children: [
                                          SizedBox(width: 54), 
                                          Image( 
                                            width: 24,
                                            height: 24, 
                                            image: AssetImage('assets/wind.png'),
                                          ),
                                          SizedBox(width: 20),
                                          Text( 
                                            'Wind',
                                            style: TextStyle(   
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontFamily: 'Overpass', 
                                              fontWeight: FontWeight.w400, 
                                              shadows: [
                                                Shadow(
                                                  offset: Offset(-2.0, 2.0),
                                                  blurRadius: 3.0,
                                                  color: Colors.black.withOpacity(0.2),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: 20),
                                          Text(
                                            '|',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontFamily: 'Overpass',
                                              fontWeight: FontWeight.w400,
                                              shadows: [
                                                Shadow(
                                                  offset: Offset(-2.0, 2.0),
                                                  blurRadius: 3.0,
                                                  color: Colors.black.withOpacity(0.2),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: 20),
                                          Text(
                                            '${_weatherData?.windSpeed.round() ?? 0} km/h',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontFamily: 'Overpass',
                                              fontWeight: FontWeight.w400,
                                              shadows: [
                                                Shadow(
                                                  offset: Offset(-2.0, 2.0),
                                                  blurRadius: 3.0,
                                                  color: Colors.black.withOpacity(0.2),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 20),
                                      Row(
                                        children: [
                                          SizedBox(width: 54),
                                          Image(
                                            width: 24,
                                            height: 24,
                                            image: AssetImage('assets/hum.png'),
                                          ),
                                          SizedBox(width: 20),
                                          Text(
                                            'Hum',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontFamily: 'Overpass',
                                              fontWeight: FontWeight.w400,
                                              shadows: [
                                                Shadow(
                                                  offset: Offset(-2.0, 2.0),
                                                  blurRadius: 3.0,
                                                  color: Colors.black.withOpacity(0.2),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: 22),
                                          Text(
                                            '|',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontFamily: 'Overpass',
                                              fontWeight: FontWeight.w400,
                                              shadows: [
                                                Shadow(
                                                  offset: Offset(-2.0, 2.0),
                                                  blurRadius: 3.0,
                                                  color: Colors.black.withOpacity(0.2),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: 20),
                                          Text(
                                            '${_weatherData?.humidity.round() ?? 0} %',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontFamily: 'Overpass',
                                              fontWeight: FontWeight.w400,
                                              shadows: [
                                                Shadow(
                                                  offset: Offset(-2.0, 2.0),
                                                  blurRadius: 3.0,
                                                  color: Colors.black.withOpacity(0.2),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 40),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const DetailPage(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 2,
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Forecast Report',
                                        style: TextStyle(
                                          color: Color(0xff444E72),
                                          fontSize: 18,
                                          fontFamily: 'Overpass',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Icon(
                                        size: 24,
                                        Icons.keyboard_arrow_up_outlined,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}