import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class WeatherService {
  // api key just hardcoded for now
  final String apiKey = 'rZx6BLOPiJtL7JdjVBGn5l52HaBxnIFi';
  final String baseUrl = 'https://api.pirateweather.net/forecast';

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception('Location service not enabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        throw Exception('Permission denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Permission denied forever');
    }

    // just get high accuracy for now
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // reverse geocoding using openstreetmap api
  Future<String> getCityNameFromAPI(double lat, double lon) async {
    try {
      final url =
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&zoom=10&addressdetails=1';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'WeatherApp/1.0',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['address'] != null) {
          final addr = data['address'];

          String? city =
              addr['city'] ??
              addr['town'] ??
              addr['village'] ??
              addr['municipality'] ??
              addr['county'] ??
              addr['state'];

          if (city != null && city.isNotEmpty) {
            debugPrint('City from API: $city');
            return city;
          }
        }
      }
    } catch (e) {
      debugPrint('Reverse geo error: $e');
    }

    return '';
  }

  // try different ways to get city name
  Future<String> getCityName(double lat, double lon) async {
    String city = await getCityNameFromAPI(lat, lon);

    if (city.isNotEmpty) {
      return city;
    }

    try {
      List<Placemark> places = await placemarkFromCoordinates(lat, lon);

      if (places.isNotEmpty) {
        final p = places.first;

        // debug info
        debugPrint('Placemark debug:');
        debugPrint('locality: ${p.locality}');
        debugPrint('subLocality: ${p.subLocality}');
        debugPrint('adminArea: ${p.administrativeArea}');

        city =
            p.locality ??
            p.subLocality ??
            p.subAdministrativeArea ??
            p.administrativeArea ??
            '';

        if (city.isNotEmpty && city.toLowerCase() != 'unknown') {
          return city;
        }
      }
    } catch (e) {
      debugPrint('Placemark error: $e');
    }

    // fallback hardcoded
    return _getCityFromCoordinates(lat, lon);
  }

  String _getCityFromCoordinates(double lat, double lon) {
    if (lat >= 43.15 && lat <= 43.35 && lon >= 76.80 && lon <= 77.05) {
      return 'Almaty';
    }
    if (lat >= 40.5 && lat <= 40.9 && lon >= -74.1 && lon <= -73.7) {
      return 'New York';
    }
    if (lat >= 51.3 && lat <= 51.7 && lon >= -0.3 && lon <= 0.2) {
      return 'London';
    }
    if (lat >= 35.5 && lat <= 35.8 && lon >= 139.5 && lon <= 139.9) {
      return 'Tokyo';
    }
    if (lat >= 48.8 && lat <= 48.9 && lon >= 2.2 && lon <= 2.5) {
      return 'Paris';
    }

    return 'Location';
  }

  Future<Map<String, dynamic>> getWeatherData(double lat, double lon) async {
    final url = '$baseUrl/$apiKey/$lat,$lon?units=si';

    final res = await http.get(Uri.parse(url));

    if (res.statusCode == 200) {
      return json.decode(res.body);
    } else {
      throw Exception('Weather api error');
    }
  }

  Future<WeatherData> getCurrentWeather() async {
    try {
      final pos = await getCurrentLocation();
      final city = await getCityName(pos.latitude, pos.longitude);
      final data = await getWeatherData(pos.latitude, pos.longitude);

      return WeatherData.fromJson(data, city);
    } catch (e) {
      debugPrint('getCurrentWeather failed: $e');
      throw Exception('Cannot load weather');
    }
  }

  // hourly forecast (24 hours)
  Future<List<HourlyWeather>> getHourlyForecast() async {
    try {
      final pos = await getCurrentLocation();
      final data = await getWeatherData(pos.latitude, pos.longitude);

      if (data['hourly'] != null && data['hourly']['data'] != null) {
        List list = data['hourly']['data'];
        return list
            .take(24)
            .map((e) => HourlyWeather.fromJson(e))
            .toList();
      }
    } catch (e) {
      debugPrint('Hourly error: $e');
    }

    return [];
  }

  // nearby cities fallback
  Future<List<CityWeather>> getNearbyCitiesWeather(double lat, double lon) async {
    List<Map<String, dynamic>> cities = [
      {'lat': lat + 0.5, 'lon': lon},
      {'lat': lat - 0.5, 'lon': lon},
      {'lat': lat, 'lon': lon + 0.5},
      {'lat': lat, 'lon': lon - 0.5},
    ];

    List<CityWeather> result = [];

    for (var c in cities) {
      try {
        final data = await getWeatherData(c['lat'], c['lon']);
        final cityName = await getCityName(c['lat'], c['lon']);
        result.add(CityWeather.fromJson(data, cityName));
      } catch (e) {
        debugPrint('Nearby city error: $e');
      }
    }

    return result;
  }

  // static cities list
  Future<List<CityWeather>> getStaticCitiesWeather() async {
    List<Map<String, dynamic>> cities = [
      {'name': 'Paris', 'lat': 48.8566, 'lon': 2.3522},
      {'name': 'Berlin', 'lat': 52.52, 'lon': 13.405},
      {'name': 'New York', 'lat': 40.7128, 'lon': -74.006},
      {'name': 'Moscow', 'lat': 55.7558, 'lon': 37.6173},
      {'name': 'Astana', 'lat': 51.1694, 'lon': 71.4491},
    ];

    List<CityWeather> list = [];

    for (var c in cities) {
      try {
        final data = await getWeatherData(c['lat'], c['lon']);
        list.add(CityWeather.fromJson(data, c['name']));
      } catch (e) {
        debugPrint('Static city error ${c['name']}');
      }
    }

    return list;
  }

  Future<List<DailyWeather>> getDailyForecast() async {
    try {
      final pos = await getCurrentLocation();
      final data = await getWeatherData(pos.latitude, pos.longitude);

      if (data['daily'] != null && data['daily']['data'] != null) {
        List days = data['daily']['data'];
        return days.take(7).map((e) => DailyWeather.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Daily forecast error: $e');
    }

    return [];
  }

  String getWeatherIcon(String? icon) {
    if (icon == null) return 'assets/sunny_cloud.png';

    if (icon.contains('clear')) return 'assets/sunny.png';
    if (icon.contains('night')) return 'assets/clear_night.png';
    if (icon.contains('cloud')) return 'assets/sunny_cloud.png';
    if (icon.contains('rain')) return 'assets/rain.png';
    if (icon.contains('storm')) return 'assets/heavyrain_and_storm.png';
    if (icon.contains('snow')) return 'assets/heavyrain_and_storm.png';
    if (icon.contains('wind')) return 'assets/wind.png';
    if (icon.contains('fog')) return 'assets/cloudy.png';

    return 'assets/sunny_cloud.png';
  }

  String getWeatherDescription(String? icon) {
    if (icon == null) return 'Cloudy';

    if (icon.contains('clear-day')) return 'Sunny';
    if (icon.contains('clear-night')) return 'Clear Night';
    if (icon.contains('partly')) return 'Partly Cloudy';
    if (icon.contains('cloudy')) return 'Cloudy';
    if (icon.contains('rain')) return 'Rainy';
    if (icon.contains('snow')) return 'Snowy';
    if (icon.contains('wind')) return 'Windy';
    if (icon.contains('fog')) return 'Foggy';

    return 'Cloudy';
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
  final double pressure;
  final double feelsLike;
  final double smoke;
  final int uvIndex;

  WeatherData({
    required this.temperature,
    required this.windSpeed,
    required this.humidity,
    required this.icon,
    required this.description,
    required this.time,
    required this.cityName,
    required this.pressure,
    required this.feelsLike,
    required this.smoke,
    required this.uvIndex,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json, String city) {
    final c = json['currently'];
    final ws = WeatherService();

    return WeatherData(
      temperature: c['temperature']?.toDouble() ?? 0,
      windSpeed: c['windSpeed']?.toDouble() ?? 0,
      humidity: (c['humidity']?.toDouble() ?? 0) * 100,
      icon: c['icon'] ?? 'cloudy',
      description: ws.getWeatherDescription(c['icon']),
      time: DateTime.fromMillisecondsSinceEpoch((c['time'] ?? 0) * 1000),
      cityName: city,
      pressure: c['pressure']?.toDouble() ?? 0,
      feelsLike: c['feelsLike']?.toDouble() ??
          c['apparentTemperature']?.toDouble() ??
          0,
      smoke: (c['smoke']?.toDouble() ?? 0) * 100,
      uvIndex: c['uvIndex']?.toInt() ?? 0,
    );
  }
}

class HourlyWeather {
  final double temperature;
  final String icon;
  final DateTime time;

  HourlyWeather({
    required this.temperature,
    required this.icon,
    required this.time,
  });

  factory HourlyWeather.fromJson(Map<String, dynamic> json) {
    return HourlyWeather(
      temperature: json['temperature']?.toDouble() ?? 0,
      icon: json['icon'] ?? 'cloudy',
      time: DateTime.fromMillisecondsSinceEpoch((json['time'] ?? 0) * 1000),
    );
  }
}

class DailyWeather {
  final double tempHigh;
  final double tempLow;
  final String icon;
  final DateTime time;

  DailyWeather({
    required this.tempHigh,
    required this.tempLow,
    required this.icon,
    required this.time,
  });

  factory DailyWeather.fromJson(Map<String, dynamic> json) {
    return DailyWeather(
      tempHigh: json['temperatureHigh']?.toDouble() ?? 0,
      tempLow: json['temperatureLow']?.toDouble() ?? 0,
      icon: json['icon'] ?? 'cloudy',
      time: DateTime.fromMillisecondsSinceEpoch((json['time'] ?? 0) * 1000),
    );
  }
}

class CityWeather {
  final String cityName;
  final double temperature;
  final String icon;
  final double pressure;
  final double feelsLike;
  final double smoke;
  final int uvIndex;

  CityWeather({
    required this.cityName,
    required this.temperature,
    required this.icon,
    required this.pressure,
    required this.feelsLike,
    required this.smoke,
    required this.uvIndex,
  });

  factory CityWeather.fromJson(Map<String, dynamic> json, String city) {
    final c = json['currently'];

    return CityWeather(
      cityName: city,
      temperature: c['temperature']?.toDouble() ?? 0,
      icon: c['icon'] ?? 'cloudy',
      pressure: c['pressure']?.toDouble() ?? 0,
      feelsLike: c['feelsLike']?.toDouble() ??
          c['apparentTemperature']?.toDouble() ??
          0,
      smoke: (c['smoke']?.toDouble() ?? 0) * 100,
      uvIndex: c['uvIndex']?.toInt() ?? 0,
    );
  }
}
