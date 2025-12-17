import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:weather_app_final/services/auth.dart';
import 'package:weather_app_final/widgets/weather_background.dart';

class RegistrationPage extends StatelessWidget {
  RegistrationPage({Key? key}) : super(key: key) {
    user = auth.currentUser;
  }

  final auth = Auth();
  User? user;

  @override
  Widget build(BuildContext context) {
    return WeatherBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(
            'Account Page',
            style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),

        ),
        body: Container(
          padding: EdgeInsets.only(left: 20, right: 20, top: 40, bottom: 20),
          child: Column(
            children: <Widget>[
              // Profile image
              CircleAvatar(
                backgroundColor: Colors.white,
                radius: 60,
                child: Icon(
                  Icons.account_circle,
                  size: 80,
                  color: Colors.blue[300],
                ),
              ),

              SizedBox(
                height: 25,
              ),

              // Email
              Text(
                user?.email ?? 'email not found',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),

              SizedBox(height: 10),

              // User ID
              Text(
                'User: ${user?.uid.substring(0, 6) ?? 'unknown'}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),

              SizedBox(height: 50),

              // Info card
              Card(
                color: Colors.white.withOpacity(0.2),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Info',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Divider(
                        color: Colors.white.withOpacity(0.3),
                                            ),

                      // some space
                      SizedBox(
                        height: 15.0,
                      ),

                      // email thing
                      Row(
                        children: [
                          Icon(
                            Icons.email_outlined,
                            color: Colors.white,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              user == null ? 'no email' : user!.email!,
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 8),

                      // when joined
                      if (user?.metadata != null && user!.metadata.creationTime != null)
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: Colors.white,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Joined: ' + getDate(user!.metadata.creationTime!),
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // push everything up
              Expanded(child: Container()),

              // logout button
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      await auth.signOut();
                    } catch (e) {
                      print('error signing out: $e');
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                    child: Text(
                      'Sign Out',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 17.0,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 8),

              // version text at bottom
              Text(
                'App Version 1.0',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 11.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // helper to format date
  String getDate(DateTime d) {
    return '${d.month}/${d.day}/${d.year}';
  }
}