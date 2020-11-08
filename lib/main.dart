import 'package:flutter/material.dart';
import 'package:gfive/firebase_loader.dart';
import 'package:gfive/google_signin.dart';
import 'package:gfive/screens/chatscreen.dart';
import 'package:gfive/screens/completeReg.dart';
import 'package:gfive/screens/homescreen.dart';
import 'package:gfive/screens/login.dart';
import 'package:gfive/screens/registration.dart';
import 'package:gfive/screens/welcome.dart';
import 'screens/welcome.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: App.route,
      routes: {
        App.route: (context) => App(),
        WelcomeScreen.route: (context) => WelcomeScreen(),
        ChatScreen.route: (context) => ChatScreen(),
        LoginScreen.route: (context) => LoginScreen(),
        GoogleLoginHandler.route: (context) => GoogleLoginHandler(),
        HomeScreen.route: (context) => HomeScreen(),
        CompleteReg.route: (context) => CompleteReg(),
        RegistrationScreen.route: (context) => RegistrationScreen(),
      },
    );
  }
}
