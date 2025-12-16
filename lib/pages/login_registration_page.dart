import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:weather_app_final/services/auth.dart';
import 'package:weather_app_final/widgets/weather_background.dart';

class LoginRegistrationPage extends StatefulWidget {
  const LoginRegistrationPage({Key? key}) : super(key: key);

  @override
  State<LoginRegistrationPage> createState() => _LoginRegistrationPageState();
}

class _LoginRegistrationPageState extends State<LoginRegistrationPage> {
  bool isLogin = true;
  bool loading = false;
  bool hidePassword = true;

  String errorText = "";

  TextEditingController emailCtrl = TextEditingController();
  TextEditingController passCtrl = TextEditingController();
  TextEditingController confirmCtrl = TextEditingController();

  Future login() async {
    setState(() {
      loading = true;
      errorText = "";
    });

    print("login pressed");

    try {
      await Auth().signInWithEmailAndPassword(
        email: emailCtrl.text,
        password: passCtrl.text,
      );
    } on FirebaseAuthException catch (e) {
      print("firebase error $e");
      setState(() {
        errorText = "Wrong email or password";
      });
    } catch (e) {
      print("unknown error $e");
      setState(() {
        errorText = "Something went wrong";
      });
    }
      if (!mounted) return;
      setState(() {
        loading = false;
      });
  }

  Future register() async {
    if (passCtrl.text != confirmCtrl.text) {
      setState(() {
        errorText = "Passwords not match";
      });
      return;
    }

    setState(() {
      loading = true;
      errorText = "";
    });

    print("register pressed");

    try {
      await Auth().createUserWithEmailAndPassword(
        email: emailCtrl.text,
        password: passCtrl.text,
      );
    } on FirebaseAuthException catch (e) {
      print("firebase error $e");
      setState(() {
        errorText = "Cannot create user";
      });
    } catch (e) {
      setState(() {
        errorText = "Register error";
      });
    }

    setState(() {
      loading = false;
    });
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WeatherBackground(
        child: SafeArea(
          child: Container(
            height: double.infinity,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 40),
            
                  Container(
                    padding: const EdgeInsets.all(0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      isLogin ? 'assets/clear.png' : 'assets/cloudy.png',
                      width: 160,
                      height: 160,
                    ),
                  ),
            
                  SizedBox(height: 32,),
                  Text(
                    'Weather Forecast',
                    style: TextStyle( 
                      fontFamily: 'Overpass',
                      fontSize: 36, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.white, 
                      letterSpacing: 1.2, 
                    ),
                  ),
            
                  SizedBox(height: 8,),
                  Text( 
                    isLogin ? 'Welcome back!' : 'Create your account',
                    style: TextStyle( 
                      fontSize: 16, 
                      color: Colors.white.withOpacity(0.9), 
                    ),
                  ),
                  SizedBox(height: 48),
            
                  Container(
                    padding: const EdgeInsets.all(32), 
                    decoration: BoxDecoration( 
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24), 
                      boxShadow: [
                        BoxShadow( 
                          color: Colors.black.withOpacity(0.1), 
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            fillColor: Color(0xfffafafa),
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                          ),
                        ),
                        SizedBox(height: 16,),
            
                        TextField(
                          controller: passCtrl,
                          obscureText: hidePassword,
                          decoration: InputDecoration(
                            fillColor: Color(0xfffafafa),
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                hidePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  hidePassword = !hidePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                          ),
                        ),
            
                        if (!isLogin) ...[
                          SizedBox(height: 16),
                          TextField(
                            controller: confirmCtrl,
                            obscureText: hidePassword,
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              prefixIcon: Icon(Icons.lock_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                            ),
                          ),
                        ],
            
                        SizedBox(height: 24),
            
                        if (errorText.isNotEmpty)
                          Text(
                            errorText,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 13,
                            ),
                          ),
            
                        SizedBox(height: 16),
            
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: loading
                                ? null
                                : isLogin
                                    ? login
                                    : register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF5AB8E8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: loading
                                ? CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(isLogin ? 'Login' : 'Register',
                                    style: TextStyle(
                                      fontFamily: 'Overpass',
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    )  
                              ),
                          ),
                        ),
            
                        SizedBox(height: 16),
            
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isLogin
                                  ? "Don't have an account? "
                                  : "Already have an account? ",
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  isLogin = !isLogin;
                                  errorText = "";
                                  confirmCtrl.clear();
                                });
                              },
                              child: Text(
                                isLogin ? 'Register' : 'Login',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
            
                  SizedBox(height: 12),
            
                  Text(
                    'Find out the weather forecast around you',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
