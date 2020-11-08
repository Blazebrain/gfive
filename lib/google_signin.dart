import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screens/completeReg.dart';

class GoogleLoginHandler extends StatefulWidget {
  static const route = 'GoogleLoginHandler';
  @override
  _GoogleLoginHandlerState createState() => _GoogleLoginHandlerState();
}

class _GoogleLoginHandlerState extends State<GoogleLoginHandler> {
  final googleSignIn = GoogleSignIn();
  final firebaseAuth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  SharedPreferences prefs;

  bool isLoading = false;
  bool isLoggedIn = false;
  User currentUser;

  @override
  void initState() {
    super.initState();
    handleSignIn();
  }

// Method to handle the sign in of a new user who has not logged in previously
  Future<Null> handleSignIn() async {
    prefs = await SharedPreferences.getInstance();
    this.setState(() {
      isLoading = true;
    });
    // next line begins the sign in process, with the .signIn method attached to the GoogleSignIn Class
    GoogleSignInAccount googleUser = await googleSignIn.signIn();
    // next line hold authentication tokens for the google signed in account
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    // next line creates a credential interface to handle the auth credentials for the new google user
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    // next line creates a new firebaseUser using the signed in credentials that has been captured in the credentials interface container
    User firebaseUser =
        (await firebaseAuth.signInWithCredential(credential)).user;
// this checks if a new user have been succesfully created with the signInWithCredential method using the google login credentials
// thats what the next if statement mean, if yes, it checks to see if the user is already on the database(firestore)
    if (firebaseUser != null) {
      // next line sends a query and checks if the userid that comes with the firebase user container has a similar id in the database
      final QuerySnapshot result = await firestore
          .collection(
              'users') //this queries the users collection in the firestore
          .where('id',
              isEqualTo:
                  firebaseUser.uid) // this checks to see if the id's are equal
          .get(); // this gets the document queried and saves it into the result variable

      final List<DocumentSnapshot> documents = result
          .docs; //This sends the result i.e documents to a list of documnets snapshots
      // The next if line checks to see if there is anyone with same credentials already on the database
      // if there is, the document list would be > than 1, if not, its 0
      if (documents.length == 0) {
        // next line then pushes/set the data to the database(firestore) and adds the required fields
        firestore.collection('users').doc(firebaseUser.uid).set({
          'nickName': firebaseUser.displayName,
          'id': firebaseUser.uid,
          'photoUrl': firebaseUser.photoURL,
          'phoneNumber': firebaseUser.phoneNumber,
          'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
          'email': firebaseUser.email,
          'joinedDate': DateTime.now(),
          'chattingWith': null,
        });

        // next line then writes the data to a local interface, using shared preferences package
        currentUser = firebaseUser;
        await prefs.setString('id', currentUser.uid);
        await prefs.setString('nickName', currentUser.displayName);
        await prefs.setString('photoUrl', currentUser.photoURL);
      } else {
        // ignore: unnecessary_statements
        // This writes the data to the shared preferences locally for further use
        // it comes in to place when there is already a user  with those credentials on the database so all we need is the data to be available locally
        await prefs.setString('id', documents[0].get('id'));
        await prefs.setString('nickName', documents[0].get('nickName'));
        await prefs.setString('photoUrl', documents[0].get('photoUrl'));
      }
      // next line shows a toast message to the user signifying successful sign in to the app both on database and locally
      Fluttertoast.showToast(
        backgroundColor: Color(0xff2556D9),
        msg: 'Sign In Successful',
        textColor: Colors.black,
        toastLength: Toast.LENGTH_LONG,
      );
      setState(() {
        isLoading = false;
      });
      Navigator.pushNamed(context, CompleteReg.route);
    } else {
      Fluttertoast.showToast(msg: 'Sign in Failed');
      setState(() {
        isLoading = false;
      });
    }
  }

  loading() {
    return Container(
      color: Colors.white,
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
          backgroundColor: Colors.black,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ? loading() : Container();
  }
}
