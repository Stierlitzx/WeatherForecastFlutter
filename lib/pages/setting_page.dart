import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:weather_app_final/services/auth.dart';

class RegistrationPage extends StatelessWidget {
  RegistrationPage({super.key});

  final User? user = Auth().currentUser;

  Future<void> signOut() async {
    await Auth().signOut();
  }

  Widget _title() {
    return Text('Firebase Auth');
  }

  Widget _userUiD() {
    return Text(user?.email ?? 'User email');
  }

  Widget _signOutButton() {
    return ElevatedButton(
      onPressed: signOut, 
      child: Text('Sign Out')
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _title(),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _userUiD(),
            _signOutButton(),
          ],
        ),
      ),
    );
  }
}