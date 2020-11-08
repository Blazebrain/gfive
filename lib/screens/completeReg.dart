import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gfive/screens/homescreen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:gfive/constants.dart';
import 'package:gfive/components/rounded_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompleteReg extends StatefulWidget {
  static const route = 'CompleteReg';

  @override
  CompleteRegState createState() => CompleteRegState();
}

class CompleteRegState extends State<CompleteReg> {
  final firebaseAuth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  SharedPreferences prefs;
  User loggedInUser;
  String nickName;
  String aboutMe;
  String password;
  String phoneNumber;
  bool showSpinner = false;

  Future<Null> completeRegistration() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      showSpinner = true;
    });
    loggedInUser = firebaseAuth.currentUser;
    print(loggedInUser.displayName);
    final QuerySnapshot results = await firestore
        .collection('users')
        .where('id', isEqualTo: loggedInUser.uid)
        .get();

    final List<DocumentSnapshot> documents = results.docs;
    if (documents.length > 0) {
      firestore.collection('users').doc(loggedInUser.uid).update({
        'FullName': nickName,
        'aboutMe': aboutMe,
        'phoneNumber': phoneNumber
      });
      loggedInUser.updatePassword(password);
      // loggedInUser.sendEmailVerification()
      print(password);
      await prefs.setString('FullName', '$nickName');
      await prefs.setString('aboutMe', '$aboutMe');
      await prefs.setString('phoneNumber', '$phoneNumber');

      Fluttertoast.showToast(
        msg: 'Sign In Sucessful',
        timeInSecForIosWeb: 3,
      );
      setState(() {
        showSpinner = false;
      });
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return HomeScreen(
          userName: prefs.getString('FullName'),
        );
      }));
    }
  }

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
              margin: EdgeInsets.only(top: 100),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Hero(
                    tag: 'logo',
                    child: CircleAvatar(
                      radius: 50,
                      child: Image.asset('images/uni1.png'),
                    ),
                  ),
                  SizedBox(
                    height: 48.0,
                  ),
                  TextField(
                    textAlign: TextAlign.center,
                    onChanged: (value) {
                      //Do something with the user input.
                      nickName = value;
                    },
                    decoration: kTextFieldDecoration.copyWith(
                      hintText: 'nickname....',
                    ),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  TextField(
                    textAlign: TextAlign.center,
                    onChanged: (value) {
                      //Do something with the user input.
                      aboutMe = value;
                    },
                    decoration: kTextFieldDecoration.copyWith(
                      hintText: 'about Me...',
                    ),
                  ),
                  SizedBox(
                    height: 24.0,
                  ),
                  TextField(
                    obscureText: true,
                    textAlign: TextAlign.center,
                    onChanged: (value) {
                      //Do something with the user input.
                      password = value;
                    },
                    decoration: kTextFieldDecoration.copyWith(
                      hintText: 'password...',
                    ),
                  ),
                  SizedBox(
                    height: 24.0,
                  ),
                  RoundedButton(
                    color: Colors.lightBlueAccent,
                    buttonTitle: 'Complete Registration',
                    onPress: () async {
                      completeRegistration();
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
