import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app_final/services/weather_service.dart';

class CitySelectionPage extends StatefulWidget {
  const CitySelectionPage({super.key});

  @override
  State<CitySelectionPage> createState() => _CitySelectionPageState();
}

class _CitySelectionPageState extends State<CitySelectionPage> {
  final TextEditingController searchCtrl = TextEditingController();
  final WeatherService _weatherService = WeatherService();
  
  // TODO: move this to a proper cities database or API call
  List<Map<String, dynamic>> cities = [
    {'name': 'Almaty', 'lat': 43.2389, 'lon': 76.8897, 'country': 'Kazakhstan'},
    {'name': 'Astana', 'lat': 51.1694, 'lon': 71.4491, 'country': 'Kazakhstan'},
    {'name': 'Shymkent', 'lat': 42.3417, 'lon': 69.5901, 'country': 'Kazakhstan'},
    {'name': 'New York', 'lat': 40.7128, 'lon': -74.0060, 'country': 'USA'},
    {'name': 'London', 'lat': 51.5074, 'lon': -0.1278, 'country': 'UK'},
    {'name': 'Paris', 'lat': 48.8566, 'lon': 2.3522, 'country': 'France'},
    {'name': 'Tokyo', 'lat': 35.6762, 'lon': 139.6503, 'country': 'Japan'},
    {'name': 'Berlin', 'lat': 52.5200, 'lon': 13.4050, 'country': 'Germany'},
    {'name': 'Moscow', 'lat': 55.7558, 'lon': 37.6173, 'country': 'Russia'},
    {'name': 'Dubai', 'lat': 25.2048, 'lon': 55.2708, 'country': 'UAE'},
    {'name': 'Singapore', 'lat': 1.3521, 'lon': 103.8198, 'country': 'Singapore'},
    {'name': 'Sydney', 'lat': -33.8688, 'lon': 151.2093, 'country': 'Australia'},
    {'name': 'Los Angeles', 'lat': 34.0522, 'lon': -118.2437, 'country': 'USA'},
    {'name': 'Chicago', 'lat': 41.8781, 'lon': -87.6298, 'country': 'USA'},
    {'name': 'Toronto', 'lat': 43.6532, 'lon': -79.3832, 'country': 'Canada'},
    {'name': 'Mumbai', 'lat': 19.0760, 'lon': 72.8777, 'country': 'India'},
    {'name': 'Beijing', 'lat': 39.9042, 'lon': 116.4074, 'country': 'China'},
    {'name': 'Seoul', 'lat': 37.5665, 'lon': 126.9780, 'country': 'South Korea'},
    {'name': 'Rome', 'lat': 41.9028, 'lon': 12.4964, 'country': 'Italy'},
    {'name': 'Madrid', 'lat': 40.4168, 'lon': -3.7038, 'country': 'Spain'},
  ];
  
  List<Map<String, dynamic>> filteredList = [];
  bool loading = false;
  String errMsg = '';

  @override
  void initState() {
    super.initState();
    filteredList = cities;
    searchCtrl.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      String query = searchCtrl.text.toLowerCase().trim();
      if (query.isEmpty) {
        filteredList = cities;
      } else {
        filteredList = cities.where((c) => 
          c['name'].toString().toLowerCase().contains(query)
        ).toList();
      }
    });
  }

  // get user's current location and return to previous screen
  Future<void> handleCurrentLocation() async {
    setState(() {
      loading = true;
      errMsg = '';
    });

    try {
      Position pos = await _weatherService.getCurrentLocation();
      String name = await _weatherService.getCityName(pos.latitude, pos.longitude);

      if (mounted) {
        Navigator.pop(context, {
          'name': name.isNotEmpty ? name : 'Current Location',
          'lat': pos.latitude,
          'lon': pos.longitude,
        });
      }
    } catch (e) {
      setState(() {
        // strip the 'Exception: ' prefix for cleaner UI
        errMsg = e.toString().replaceAll('Exception: ', '');
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff4A91FF), Color(0xff47BFDF)],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 80,
              child: Image.asset('assets/Vector 11.png',
                width: 350, height: 350, fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: 100,
              right: 210,
              child: Image.asset('assets/Vector 12.png',
                width: 300, height: 300, fit: BoxFit.contain,
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  // header with back button
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
                          onPressed: () => Navigator.pop(context),
                        ),
                        SizedBox(width: 8),
                        Text('Select City',
                          style: TextStyle(
                            fontFamily: 'Overpass',
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                offset: Offset(-2.0, 2.0),
                                blurRadius: 3.0,
                                color: Colors.black.withOpacity(0.2),
                              ),
                            ],
                          )),
                      ],
                    ),
                  ),

                  // search bar section
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: TextField(
                      controller: searchCtrl,
                      style: TextStyle(color: Colors.white, fontFamily: 'Overpass', fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'Search city...',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontFamily: 'Overpass',
                        ),
                        prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.8)),
                        suffixIcon: searchCtrl.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, color: Colors.white.withOpacity(0.8)),
                                onPressed: () => searchCtrl.clear(),
                              )
                            : null,
                        filled: false,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // current location button
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: InkWell(
                      onTap: loading ? null : handleCurrentLocation,
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.4)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle),
                              child: loading
                                  ? SizedBox(
                                      width: 24, height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                                  : Icon(Icons.my_location, color: Colors.white, size: 24),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Use Current Location',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Overpass',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(-1.0, 1.0),
                                          blurRadius: 2.0,
                                          color: Colors.black.withOpacity(0.2),
                                        ),
                                      ],
                                    )),
                                  SizedBox(height: 4),
                                  Text(
                                    loading ? 'Getting location...' : 'Automatically detect your location',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontFamily: 'Overpass',
                                      fontSize: 13)),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios, 
                              color: Colors.white.withOpacity(0.7), size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 12),

                  // error display
                  if (errMsg.isNotEmpty)
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withOpacity(0.6))),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(errMsg,
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Overpass',
                                fontSize: 13))),
                        ],
                      ),
                    ),

                  SizedBox(height: 8),

                  // cities list
                  Expanded(
                    child: filteredList.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off, size: 64, 
                                  color: Colors.white.withOpacity(0.5)),
                                SizedBox(height: 16),
                                Text('No cities found',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontFamily: 'Overpass',
                                    fontSize: 16,
                                    shadows: [
                                      Shadow(
                                        offset: Offset(-1.0, 1.0),
                                        blurRadius: 2.0,
                                        color: Colors.black.withOpacity(0.2),
                                      ),
                                    ],
                                  )),
                              ]))
                        : ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            itemCount: filteredList.length,
                            itemBuilder: (context, idx) {
                              var cityData = filteredList[idx];
                              return Padding(
                                padding: EdgeInsets.only(bottom: 12),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pop(context, cityData);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3))),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.2),
                                            shape: BoxShape.circle),
                                          child: Icon(Icons.location_city, 
                                            color: Colors.white, size: 20),
                                        ),
                                        SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(cityData['name'],
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: 'Overpass',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  shadows: [
                                                    Shadow(
                                                      offset: Offset(-1.0, 1.0),
                                                      blurRadius: 2.0,
                                                      color: Colors.black.withOpacity(0.2),
                                                    ),
                                                  ],
                                                )),
                                              SizedBox(height: 4),
                                              Text(cityData['country'],
                                                style: TextStyle(
                                                  color: Colors.white.withOpacity(0.8),
                                                  fontFamily: 'Overpass',
                                                  fontSize: 13)),
                                            ])),
                                        Icon(Icons.arrow_forward_ios, 
                                          color: Colors.white.withOpacity(0.6), size: 16),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}