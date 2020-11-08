import 'package:flutter/material.dart';

const kTextFieldDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.lightBlueAccent, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.lightBlueAccent, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
);

const kMessageTextFieldDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  hintText: 'Type your message here...',
  border: InputBorder.none,
);

// Future<Null> updatePassword() async {
//   loggedInUser = firebaseAuth.currentUser;
//   await loggedInUser.reauthenticateWithCredential(widget.credential);
//   await loggedInUser.updatePassword(password);
//   print('password updated');
// }
// final AuthCredential credential;

//  SizedBox(
//                     height: 8.0,
//                   ),
//                   TextField(
//                     obscureText: true,
//                     textAlign: TextAlign.center,
//                     onChanged: (value) {
//                       //Do something with the user input.
//                       password = value;
//                     },
//                     decoration: kTextFieldDecoration.copyWith(
//                       hintText: 'password....',
//                     ),
//                   ),
