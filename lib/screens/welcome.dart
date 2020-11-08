import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:gfive/components/rounded_button.dart';
import 'package:gfive/google_signin.dart';
import 'package:gfive/screens/login.dart';
import 'package:gfive/screens/registration.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'homescreen.dart';

class WelcomeScreen extends StatefulWidget {
  static const route = 'WelcomeScreen';
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation animation;
  Animation anime;
  // GoogleLoginHandler googleLogin = GoogleLoginHandler();
  final googleSignIn = GoogleSignIn();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  SharedPreferences prefs;
  bool isLoading = false;
  bool isLoggedIn = false;
  User currentUser;

  @override
  void initState() {
    super.initState();
    isSignedIn();
    controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
      upperBound: 1,
    );
    anime = CurvedAnimation(parent: controller, curve: Curves.decelerate);
    animation = ColorTween(begin: Colors.blueGrey, end: Colors.white)
        .animate(controller);
    controller.forward();

    // controller.addStatusListener((status) {
    //   print(status);
    //   // if (status == AnimationStatus.completed) {
    //   //   controller.reverse(from: 1.0);
    //   // } else if (status == AnimationStatus.dismissed) {
    //   //   controller.forward();
    //   // }
    // });

    controller.addListener(() {
      setState(() {});
      print(animation.value);
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void isSignedIn() async {
    this.setState(() {
      isLoading = true;
    });
    prefs = await SharedPreferences.getInstance();
    final user = 'back';

    // The next line checks to see if the user is signed in by returning a bool true/false
    isLoggedIn = await googleSignIn.isSignedIn();
    print(isLoggedIn);
    // if logged in, it pushes the user to the homescreen
    if (isLoggedIn == true) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return HomeScreen(
          userName: user,
        );
      }));
    }
    this.setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: animation.value,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(
                  height: MediaQuery.of(context).size.height / 5,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Hero(
                      tag: 'logo',
                      child: Container(
                        child: Image.asset('images/uni1.png'),
                        height: anime.value * 100,
                      ),
                    ),
                    TypewriterAnimatedTextKit(
                      text: ['GFive'],
                      textStyle: TextStyle(
                        fontSize: 50.0,
                        fontWeight: FontWeight.w900,
                        color: Colors.blue[900],
                      ),
                      speed: Duration(milliseconds: 1000),
                      totalRepeatCount: 3,
                    ),
                  ],
                ),
                SizedBox(
                  height: 35.0,
                ),
                RoundedButton(
                  color: Colors.lightBlueAccent,
                  buttonTitle: 'Log in',
                  onPress: () {
                    Navigator.pushNamed(context, LoginScreen.route);
                  },
                ),
                RoundedButton(
                  color: Colors.blueAccent,
                  buttonTitle: 'Register',
                  onPress: () {
                    Navigator.pushNamed(context, RegistrationScreen.route);
                  },
                ),
                RoundedButton(
                  color: Colors.blue,
                  buttonTitle: 'Sign in with Googe',
                  onPress: () {
                    Navigator.pushNamed(context, GoogleLoginHandler.route);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
