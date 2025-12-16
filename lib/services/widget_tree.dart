import 'package:flutter/material.dart';
import 'package:weather_app_final/pages/home_page.dart';
import 'package:weather_app_final/services/auth.dart';
import 'package:weather_app_final/pages/login_registration_page.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().authStateChanges, 
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        if (snapshot.hasData) {
          return HomeScreen();
        } else {
          return LoginRegistrationPage();
        }
      },
    );
  }
}