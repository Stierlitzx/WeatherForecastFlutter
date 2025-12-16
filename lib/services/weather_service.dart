import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class WeatherService {
  final String apiKey = 'wcPYsXVulft6jWGYumaRhZioOzc4qffL';
  final String baseUrl = 'https://api.pirateweather.net/forecast';

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled(); 
    
    LocationPermission permission = await Geolocator.checkPermission(); 

    return await Geolocator.getCurrentPosition( 
      desiredAccuracy: LocationAccuracy.high, 
    );
  }

  Future<String> getCityNameFromAPI(double lat, double lon) async { 
    try {
      final url = 'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&zoom=10&addressdetails=1';
      
      final response = await http.get( 
        Uri.parse(url), 
        headers: {  
          'User-Agent': 'WeatherApp/1.0',  
        },
      );

      if (response.statusCode == 200) { 
        final data = json.decode(response.body);
         
        if (data['address'] != null) {
          final address = data['address'];
             
          String? cityName = address['city'] ?? 
                            address['town'] ?? 
                            address['village'] ??
                            address['municipality'] ??
                            address['county'] ?? 
                            address['state'];
          
          if (cityName != null && cityName.isNotEmpty) { 
            print('Got city from Nominatim: $cityName'); 
            return cityName;
          }
        }
      }
    } catch (e) { 
      print('Error getting city from Nominatim: $e');
    }
     
    return '';
  }

  Future<String> getCityName(double lat, double lon) async {
    String cityName = await getCityNameFromAPI(lat, lon);
    
    if (cityName.isNotEmpty) { 
      return cityName;
    }
     
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
       
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
         
        print('Geocoding package results:');
        print('Locality: ${place.locality}');
        print('SubLocality: ${place.subLocality}');
        print('SubAdministrativeArea: ${place.subAdministrativeArea}');
        print('AdministrativeArea: ${place.administrativeArea}');
        
        cityName = place.locality ?? 
                   place.subLocality ?? 
                   place.subAdministrativeArea ?? 
                   place.administrativeArea ?? 
                   '';
        
        if (cityName.isNotEmpty && cityName.toLowerCase() != 'unknown') {
          return cityName;
        }
      }
    } catch (e) { 
      print('Error with geocoding package: $e');
    }
    
    return _getCityFromCoordinates(lat, lon);
  }

  String _getCityFromCoordinates(double lat, double lon) {
    if (lat >= 43.15 && lat <= 43.35 && lon >= 76.80 && lon <= 77.05) {
      return 'Almaty';
    }
    else if (lat >= 40.5 && lat <= 40.9 && lon >= -74.1 && lon <= -73.7) {
      return 'New York';
    }
    else if (lat >= 51.3 && lat <= 51.7 && lon >= -0.3 && lon <= 0.2) {
      return 'London';
    }
    else if (lat >= 35.5 && lat <= 35.8 && lon >= 139.5 && lon <= 139.9) {
      return 'Tokyo';
    }
    else if (lat >= 48.8 && lat <= 48.9 && lon >= 2.2 && lon <= 2.5) {
      return 'Paris';
    }
    else {
      return 'Location';
    }
  }

  Future<Map<String, dynamic>> getWeatherData(double lat, double lon) async {
    final url = '$baseUrl/$apiKey/$lat,$lon?units=si';
      
    final response = await http.get(Uri.parse(url));
 
    if (response.statusCode == 200) { 
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<WeatherData> getCurrentWeather() async {
    try {
      final position = await getCurrentLocation();
       
      
      final cityName = await getCityName(position.latitude, position.longitude);
      final data = await getWeatherData(position.latitude, position.longitude);
       
      return WeatherData.fromJson(data, cityName);
    } catch (e) {
      throw Exception(e);
    }
  }

  String getWeatherIcon(String? icon) {
    if (icon == null) return 'assets/sunny_cloud.png';
    
    if (icon.contains('clear-night')) {
      return 'assets/clear_night.png';
    } else if (icon.contains('partly-cloudy-night')) {
      return 'assets/night_cloudy.png';
    } else if (icon.contains('cloudy') && icon.contains('night')) {
      return 'assets/night_cloudy.png';
    } else if (icon.contains('rain') && icon.contains('night')) {
      return 'assets/night_rain.png';
    }
    else if (icon.contains('clear-day') || icon == 'clear') {
      return 'assets/sunny.png';
    } else if (icon.contains('partly-cloudy-day') || icon.contains('partly-cloudy')) {
      return 'assets/sunny_cloud.png';
    } else if (icon.contains('cloudy')) {
      return 'assets/cloudy.png';
    } else if (icon.contains('rain') || icon.contains('drizzle')) {
      return 'assets/rain.png';
    } else if (icon.contains('thunderstorm') || icon.contains('thunder')) {
      return 'assets/thunder.png';
    } else if (icon.contains('snow')) {
      return 'assets/snowy.png';
    } else if (icon.contains('wind')) {
      return 'assets/wind.png';
    } else if (icon.contains('fog')) {
      return 'assets/cloudy.png';
    } else {
      return 'assets/sunny_cloud.png';
    }
  }

  String getWeatherDescription(String? icon) {
    if (icon == null) return 'Cloudy';
    
    if (icon.contains('clear-day')) {
      return 'Sunny';
    } else if (icon.contains('clear-night')) {
      return 'Clear Night';
    } else if (icon.contains('partly-cloudy')) {
      return 'Partly Cloudy';
    } else if (icon.contains('cloudy')) {
      return 'Cloudy';
    } else if (icon.contains('rain')) {
      return 'Rainy';
    } else if (icon.contains('snow')) {
      return 'Snowy';
    } else if (icon.contains('wind')) {
      return 'Windy';
    } else if (icon.contains('fog')) {
      return 'Foggy';
    } else {
      return 'Cloudy';
    }
  }
}

class WeatherData {
  final double temperature;
  final double windSpeed;
  final double humidity;
  final String icon;
  final String description;
  final DateTime time;
  final String cityName;

  WeatherData({
    required this.temperature,
    required this.windSpeed,
    required this.humidity,
    required this.icon,
    required this.description,
    required this.time,
    required this.cityName,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json, String cityName) {
    final currently = json['currently'];
    final weatherService = WeatherService();
    
    return WeatherData(
      temperature: currently['temperature']?.toDouble() ?? 0.0,
      windSpeed: currently['windSpeed']?.toDouble() ?? 0.0,
      humidity: (currently['humidity']?.toDouble() ?? 0.0) * 100,
      icon: currently['icon'] ?? 'cloudy',
      description: weatherService.getWeatherDescription(currently['icon']),
      time: DateTime.fromMillisecondsSinceEpoch(
        (currently['time'] ?? 0) * 1000,
      ),
      cityName: cityName,
    );
  }
}