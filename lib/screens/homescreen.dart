import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gfive/components/loading.dart';
import 'package:gfive/screens/chatscreen.dart';
import 'package:gfive/screens/welcome.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'completeReg.dart';

class HomeScreen extends StatefulWidget {
  final userName;
  final userId;
  HomeScreen({Key key, this.userId, this.userName}) : super(key: key);
  static const route = 'HomeScreen';
  @override
  _HomeScreenState createState() => _HomeScreenState(currentUserId: userId);
}

class _HomeScreenState extends State<HomeScreen> {
  // @override
  // void initState() {
  //   super.initState();
  //   registerNotification();
  //   configLocalNotification();
  // }

  _HomeScreenState({Key key, this.currentUserId});
  final String currentUserId;
  SharedPreferences prefs;
  GoogleSignIn googleSignIn = GoogleSignIn();
//   final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   void showNotification(message) async {
//     var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
//       Platform.isAndroid
//           ? 'com.dfa.flutterchatdemo'
//           : 'com.duytq.flutterchatdemo',
//       'Flutter chat demo',
//       'your channel description',
//       playSound: true,
//       enableVibration: true,
//       importance: Importance.Max,
//       priority: Priority.High,
//     );
//     var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
//     var platformChannelSpecifics = new NotificationDetails(
//         androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

//     print(message);
// //    print(message['body'].toString());
// //    print(json.encode(message));

//     await flutterLocalNotificationsPlugin.show(0, message['title'].toString(),
//         message['body'].toString(), platformChannelSpecifics,
//         payload: json.encode(message));

// //    await flutterLocalNotificationsPlugin.show(
// //        0, 'plain title', 'plain body', platformChannelSpecifics,
// //        payload: 'item x');
//   }

//   void registerNotification() {
//     firebaseMessaging.requestNotificationPermissions();

//     firebaseMessaging.configure(onMessage: (Map<String, dynamic> message) {
//       print('onMessage: $message');
//       Platform.isAndroid
//           ? showNotification(message['notification'])
//           : showNotification(message['aps']['alert']);
//       return;
//     }, onResume: (Map<String, dynamic> message) {
//       print('onResume: $message');
//       return;
//     }, onLaunch: (Map<String, dynamic> message) {
//       print('onLaunch: $message');
//       return;
//     });

//     firebaseMessaging.getToken().then((token) {
//       print('token: $token');
//       FirebaseFirestore.instance
//           .collection('users')
//           .doc(currentUserId)
//           .update({'pushToken': token});
//     }).catchError((err) {
//       Fluttertoast.showToast(msg: err.message.toString());
//     });
//   }

//   void configLocalNotification() {
//     var initializationSettingsAndroid =
//         new AndroidInitializationSettings('app_icon');
//     var initializationSettingsIOS = new IOSInitializationSettings();
//     var initializationSettings = new InitializationSettings(
//         initializationSettingsAndroid, initializationSettingsIOS);
//     flutterLocalNotificationsPlugin.initialize(initializationSettings);
//   }

  Future<Null> handleSignOut() async {
    prefs = await SharedPreferences.getInstance();
    await FirebaseAuth.instance.signOut();
    if (await googleSignIn.isSignedIn() == true) {
      await googleSignIn.disconnect();
      await googleSignIn.signOut();
    }

    await prefs.clear();

    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
      return WelcomeScreen();
    }), (route) => false);
  }

  Future<bool> onBackPress() {
    onWillPop();

    return Future.value(false);
  }

  onWillPop() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Are you sure you want to quit?'),
        actions: [
          RaisedButton(
            onPressed: () => Navigator.pushNamed(context, WelcomeScreen.route),
            child: Text('Sign out'),
          ),
          RaisedButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  itemMenuPress(Choice choice) {
    if (choice.title == 'Log out') {
      print('started work');
      handleSignOut();
    } else if (choice.title == 'Settings') {
      Navigator.pushNamed(context, CompleteReg.route);
    }
  }

  List<Choice> choices = <Choice>[
    Choice(title: 'Log out', icon: Icons.exit_to_app),
    Choice(title: 'Settings', icon: Icons.settings)
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Welcome ${widget.userName}'),
          backgroundColor: Colors.lightBlueAccent,
          actions: [
            PopupMenuButton<Choice>(
                onSelected: itemMenuPress,
                itemBuilder: (context) {
                  return choices
                      .map(
                        (Choice choice) => PopupMenuItem<Choice>(
                          value: choice,
                          child: Row(
                            children: [
                              Icon(
                                choice.icon,
                                color: Colors.black,
                              ),
                              Container(
                                width: 10.0,
                              ),
                              Text(
                                choice.title,
                                style: TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList();
                }),
          ],
        ),
        body: WillPopScope(
          onWillPop: onBackPress,
          child: Container(
            child: StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Loading();
                } else {
                  return ListView.builder(
                    padding: EdgeInsets.only(top: 15),
                    itemBuilder: (context, index) => buildItem(
                        context, snapshot.data.documents[index], currentUserId),
                    itemCount: snapshot.data.documents.length,
                  );
                }
              },
            ),
          ),
        ));
  }
}

Widget buildItem(BuildContext context, DocumentSnapshot document, String id) {
  if (document.get('id') == id) {
    return Container();
  } else {
    return Container(
      child: FlatButton(
        padding: EdgeInsets.fromLTRB(15.0, 0.0, 0.0, 0.0),
        onPressed: () {
          print(document.get('id'));
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) {
              return ChatScreen(
                peerId: document.get('id'),
                peerAvatar: document.get('photoUrl'),
                peerName: document.get('FullName'),
              );
            }),
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                Material(
                  child: document.get('photoUrl') != null
                      ? CachedNetworkImage(
                          placeholder: (context, url) => Container(
                            child: CircularProgressIndicator(
                              strokeWidth: 1.0,
                              valueColor:
                                  AlwaysStoppedAnimation(Colors.blueAccent),
                              backgroundColor: Colors.white,
                            ),
                            height: 50,
                            width: 50,
                          ),
                          imageUrl: document.get('photoUrl'),
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : Icon(
                          Icons.account_circle,
                          size: 50,
                          color: Colors.grey,
                        ),
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                  clipBehavior: Clip.hardEdge,
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: Text('${document.get('nickName')}'),
                        margin: EdgeInsets.only(left: 10),
                      ),
                      Container(
                        margin: EdgeInsets.only(right: 8),
                        child: Text(
                          // '${TimeOfDay.now().hour}:${TimeOfDay.now().minute}',
                          DateFormat('kk:mm').format(DateTime.now()),
                          style: TextStyle(color: Colors.blue[900]),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          child: Text(
                            '${document.get('aboutMe')}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          margin: EdgeInsets.only(left: 10),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(right: 8, left: 15),
                        child: CircleAvatar(
                          radius: 13,
                          backgroundColor: Colors.blue[900],
                          child: Text('1'),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 10),
                    child: Divider(
                      color: Colors.black12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Choice {
  Choice({this.icon, this.title});
  final String title;
  final IconData icon;
}
