import 'package:flutter/material.dart';

class WeatherBackground extends StatelessWidget {
  final Widget child;
  
  const WeatherBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xff4A91FF),
            Color(0xff47BFDF),
          ],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 80,
            child: Image.asset(
              'assets/Vector 11.png',
              width: 350, 
              height: 350,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            top: 100,
            right: 210,
            child: Image.asset(
              'assets/Vector 12.png',
              width: 300, 
              height: 300,
              fit: BoxFit.contain,
            ),
          ),
          child,
        ],
      ),
    );
  }
}