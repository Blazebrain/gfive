import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gfive/constants.dart';
import 'package:flutter/material.dart';
import 'package:gfive/components/rounded_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gfive/screens/homescreen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  static const route = 'LoginScreen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  SharedPreferences prefs;
  User loggedInUser;
  String email;
  String password;
  bool showSpinner = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Container(
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height / 5,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Hero(
                    tag: 'logo',
                    child: Container(
                      height: 120.0,
                      child: Image.asset('images/uni1.png'),
                    ),
                  ),
                  SizedBox(
                    height: 48.0,
                  ),
                  TextField(
                    keyboardType: TextInputType.emailAddress,
                    textAlign: TextAlign.center,
                    onChanged: (value) {
                      //Do something with the user input.
                      email = value;
                    },
                    decoration: kTextFieldDecoration.copyWith(
                      hintText: 'Enter your email',
                    ),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  TextField(
                    textAlign: TextAlign.center,
                    obscureText: true,
                    onChanged: (value) {
                      //Do something with the user input.
                      password = value;
                    },
                    decoration: kTextFieldDecoration.copyWith(
                      hintText: 'Enter your password.',
                    ),
                  ),
                  SizedBox(
                    height: 24.0,
                  ),
                  RoundedButton(
                    color: Colors.lightBlueAccent,
                    buttonTitle: 'Log In',
                    onPress: () async {
                      prefs = await SharedPreferences.getInstance();
                      User signedIn;
                      setState(() {
                        showSpinner = true;
                      });

                      try {
                        try {
                          signedIn = (await _auth.signInWithEmailAndPassword(
                                  email: email, password: password))
                              .user;
                        } on Exception catch (e) {
                          print(e.toString());
                          Fluttertoast.showToast(
                            msg: e.toString(),
                            toastLength: Toast.LENGTH_LONG,
                            textColor: Colors.black,
                            backgroundColor: Colors.blueAccent,
                          );
                          setState(() {
                            showSpinner = false;
                          });
                          Navigator.pushNamed(context, LoginScreen.route);
                        }
                        final result = await firestore
                            .collection('users')
                            .doc(signedIn.uid)
                            .get();

                        await prefs.setString('id', result.get('id'));
                        await prefs.setString(
                            'nickName', result.get('nickName'));

                        await prefs.setString(
                            'FullName', result.get('FullName'));
                        await prefs.setString('aboutMe', result.get('aboutMe'));
                        await prefs.setString(
                            'phoneNumber', result.get('phoneNumber'));

                        if (signedIn != null) {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return HomeScreen(
                              userName: prefs.getString('nickName'),
                              userId: prefs.getString('id'),
                            );
                          }));
                        }
                        setState(() {
                          showSpinner = false;
                        });
                      } on Exception catch (e) {
                        print(e);
                      }
                    },
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
