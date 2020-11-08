import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gfive/components/rounded_button.dart';
import 'package:gfive/constants.dart';
import 'package:gfive/screens/homescreen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegistrationScreen extends StatefulWidget {
  static const route = 'RegistrationScreen';
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  SharedPreferences prefs;
  File imageFile;
  String imageUrl;
  String email;
  String password;
  String aboutMe;
  String nickName;
  String phoneNumber;
  String fullName;
  bool showSpinner = false;
  @override
  void initState() {
    super.initState();
  }

  Future getImage() async {
    // creating the instance
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedFile;
    // This gets the image from the gallery as the source, same technique to get videos from gallery source
    pickedFile = await imagePicker.getImage(source: ImageSource.gallery);
    // this returns the file path
    imageFile = File(pickedFile.path);

    print(imageFile);
    if (imageFile != null) {
      uploadFile();
    }
  }

  // Method to upload the file to the firestore
  Future uploadFile() async {
    // next line documents thre specific time of upload as a reference
    String fileUploadTime = DateTime.now().millisecondsSinceEpoch.toString();
    // next line creates a specific reference with the specific time attached to this reference
    StorageReference reference =
        FirebaseStorage.instance.ref().child(fileUploadTime);
    //  next line uploads the image file with the specific time of upload as a child to the reference in the firebase storage
    StorageUploadTask uploadTask = reference.putFile(imageFile);
    // the next line catches the last snapshot of the upload data and saves
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    // next set of lines gets the download url for the downloaded file
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      imageUrl = downloadUrl;
      setState(() {
        print("File Uploaded");
      });
    },
        // next set of lines handles errors arising from wrong file specs
        onError: (err) {
      Fluttertoast.showToast(msg: "The file is not an image");
    });
  }

  uploadOtherDetails(User createdUser) async {
    prefs = await SharedPreferences.getInstance();
    print(createdUser.uid);
    firestore.collection('users').doc(createdUser.uid).set({
      'nickName': nickName,
      'id': createdUser.uid,
      'phoneNumber': phoneNumber,
      'aboutMe': aboutMe,
      'FullName': fullName,
      'email': createdUser.email,
      'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
      'joinedDate': DateTime.now(),
      'chattingWith': null,
      'photoUrl': imageUrl,
    });

    await prefs.setString('aboutMe', '$aboutMe');
    await prefs.setString('nickName', '$nickName');
    await prefs.setString('FullName', '$fullName');
    await prefs.setString('phoneNumber', '$phoneNumber');
    await prefs.setString('id', createdUser.uid);
    await prefs.setString('email', createdUser.email);
    await prefs.setString('photoUrl', imageUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).size.height / 5,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.0),
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
                    height: 30.0,
                  ),
                  TextField(
                    keyboardType: TextInputType.emailAddress,
                    textAlign: TextAlign.center,
                    onChanged: (value) {
                      email = value;
                      //Do something with the user input.
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
                      hintText: 'Enter your password',
                    ),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  TextField(
                    textAlign: TextAlign.center,
                    onChanged: (value) {
                      //Do something with the user input.
                      fullName = value;
                    },
                    decoration: kTextFieldDecoration.copyWith(
                      hintText: 'Enter your full name',
                    ),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  TextField(
                    textAlign: TextAlign.center,
                    onChanged: (value) {
                      //Do something with the user input.
                      nickName = value;
                    },
                    decoration: kTextFieldDecoration.copyWith(
                      hintText: 'Enter your nick name...',
                    ),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  TextField(
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    onChanged: (value) {
                      //Do something with the user input.
                      phoneNumber = value;
                    },
                    decoration: kTextFieldDecoration.copyWith(
                      hintText: 'Enter your phone number...',
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
                      hintText: 'about me....',
                    ),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Material(
                    child: FlatButton.icon(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      onPressed: () => getImage(),
                      icon: Icon(
                        Icons.image,
                        color: Colors.white,
                      ),
                      label: Text(
                        'Upload your image',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      color: Colors.blueAccent,
                    ),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  RoundedButton(
                    color: Colors.blueAccent,
                    buttonTitle: 'Register',
                    onPress: () async {
                      UserCredential newUser;
                      setState(() {
                        showSpinner = true;
                      });
                      try {
                        Firebase.app();
                        try {
                          newUser = await _auth.createUserWithEmailAndPassword(
                              email: email, password: password);
                        } on Exception catch (e) {
                          setState(() {
                            showSpinner = false;
                          });
                          Fluttertoast.showToast(
                            msg: e.toString(),
                            toastLength: Toast.LENGTH_LONG,
                            backgroundColor: Colors.blueAccent,
                            textColor: Colors.black,
                          );
                          Navigator.pushNamed(
                              context, RegistrationScreen.route);
                        }
                        final createdUser = newUser.user;
                        print(createdUser);
                        uploadOtherDetails(createdUser);
                        print(newUser);
                        if (newUser != null) {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return HomeScreen(
                              userName: prefs.get('nickName'),
                            );
                          }));
                        }
                        setState(() {
                          showSpinner = false;
                        });
                      } on Exception catch (e) {
                        print(e);
                        Navigator.pushNamed(context, RegistrationScreen.route);
                        Fluttertoast.showToast(
                          msg: '$e',
                          timeInSecForIosWeb: 3,
                        );
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
