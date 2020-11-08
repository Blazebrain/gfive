import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gfive/components/fullPhoto.dart';
import 'package:gfive/components/loading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget {
  static const route = 'ChatScreen';
  final peerId;
  final peerAvatar;
  final peerName;
  ChatScreen({this.peerId, this.peerAvatar, this.peerName});
  @override
  _ChatScreenState createState() => _ChatScreenState(
      peerId: peerId, peerAvatar: peerAvatar, peerName: peerName);
}

class _ChatScreenState extends State<ChatScreen> {
  _ChatScreenState({this.peerId, this.peerAvatar, this.peerName});
  final peerId;
  final peerName;
  final peerAvatar;

  SharedPreferences pref;

  List<QueryDocumentSnapshot> listMessages = new List.from([]);
  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listscrollController = ScrollController();
  final FocusNode focusNode = FocusNode();
  String groupChatId;
  String id;
  int _limit = 20;
  final int _limitIncrement = 20;
  File imageFile;
  bool isLoading;
  bool isShowSticker;
  String imageUrl;
  SharedPreferences prefs;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  _scrollListener() {
    if (listscrollController.offset >=
            listscrollController.position.maxScrollExtent &&
        !listscrollController.position.outOfRange) {
      print('reached the bottom');
      setState(() {
        _limit += _limitIncrement;
      });
    }
    if (listscrollController.offset <=
            listscrollController.position.minScrollExtent &&
        !listscrollController.position.outOfRange) {
      print('reached the top');
      setState(() {
        print('reached the top');
      });
    }
  }

// Method handling change in keyboard focus
  onFocusChange() {
    // if the keyboard has focus or is focused on the screen
    if (focusNode.hasFocus) {
      setState(() {
        isShowSticker = false;
        print('sticker removed due to change in focus');
      });
    }
  }

  Future<bool> onBackPress() {
    if (isShowSticker == true) {
      setState(() {
        isShowSticker = false;
      });
      print('sticker board taken out');
    } else {
      firestore.collection('users').doc(id).update({'chattingWith': null});
      Navigator.pop(context);
      print('returned to previous page');
    }
    return Future.value(false);
  }

  void getSticker() {
    focusNode.unfocus();
    setState(() {
      isShowSticker = !isShowSticker;
    });
    print('keyboard taken out of focus');
  }

  // Method to build the sticker pack
  Widget buildSticker() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FlatButton(
                onPressed: () => onSendMessage('mimi1', 2),
                child: Image.asset(
                  'images/mimi1.gif',
                  height: 50,
                  width: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi2', 2),
                child: Image.asset(
                  'images/mimi2.gif',
                  height: 50,
                  width: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi3', 2),
                child: Image.asset(
                  'images/mimi3.gif',
                  height: 50,
                  width: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FlatButton(
                onPressed: () => onSendMessage('mimi4', 2),
                child: Image.asset(
                  'images/mimi4.gif',
                  height: 50,
                  width: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi5', 2),
                child: Image.asset(
                  'images/mimi5.gif',
                  height: 50,
                  width: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi6', 2),
                child: Image.asset(
                  'images/mimi6.gif',
                  height: 50,
                  width: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FlatButton(
                onPressed: () => onSendMessage('mimi7', 2),
                child: Image.asset(
                  'images/mimi7.gif',
                  height: 50,
                  width: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi8', 2),
                child: Image.asset(
                  'images/mimi8.gif',
                  height: 50,
                  width: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ],
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey,
            width: 0.5,
          ),
        ),
      ),
      padding: EdgeInsets.all(5.0),
      height: 180.0,
    );
  }

  readLocal() async {
    prefs = await SharedPreferences.getInstance();
    id = prefs.getString('id');
    print(id);
    if (id.hashCode <= peerId.hashCode) {
      groupChatId = '$id - $peerId';
    } else {
      groupChatId = '$peerId - $id';
    }
    firestore.collection('users').doc(id).update({'chattingWith': peerId});
    setState(() {});
    print('chattingWith updated');
  }

  buildListMessages() {
    return Flexible(
      child: groupChatId == ''
          ? Loading()
          : StreamBuilder(
              stream: firestore
                  .collection('messages')
                  .doc(groupChatId)
                  .collection(groupChatId)
                  .orderBy('timestamp')
                  .limit(_limit)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Loading();
                } else {
                  listMessages.addAll(snapshot.data.documents);
                  print(snapshot.data.documents.length);
                  print(snapshot.data.documents);
                  return ListView.builder(
                    itemBuilder: (context, index) =>
                        buildItem(index, snapshot.data.documents[index]),
                    itemCount: snapshot.data.documents.length,
                  );
                }
              },
            ),
    );
  }

  buildItem(int index, DocumentSnapshot document) {
    if (document.data()['idFrom'] == id) {
      // if the messages originate from me
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // if the message sent is a text message
          document.data()['type'] == 0
              ? Container(
                  child: Text(
                    document.data()['content'],
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                  margin: EdgeInsets.only(
                    right: 10,
                    top: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.blue[300],
                  ),
                )
              : document.data()['type'] == 1
                  // if the message sent is an image
                  ? Container(
                      child: FlatButton(
                        onPressed: () {
                          print(document.data()['content']);
                          print(document.get('content'));
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return FullPhoto(
                              url: document.data()['content'],
                            );
                          }));
                        },
                        child: Material(
                          child: CachedNetworkImage(
                            placeholder: (context, url) => Container(
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.blueAccent),
                              ),
                              width: 200,
                              height: 200,
                              padding: EdgeInsets.all(70),
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            errorWidget: (context, url, error) => Material(
                              child: Image.asset(
                                'images/not_avail.jpeg',
                                height: 200,
                                width: 200,
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              clipBehavior: Clip.hardEdge,
                            ),
                            imageUrl: document.data()['content'],
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                          clipBehavior: Clip.hardEdge,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      margin: EdgeInsets.only(
                        bottom: isLastMessageRight(index) ? 20 : 10,
                        right: 10,
                      ),
                    )
                  :
                  //  if its a sticker i send in the chat
                  Container(
                      child: Image.asset(
                        'images/${document.data()['content']}.gif',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                      width: 100,
                      height: 100,
                    ),

          Container(
            child: Text(
              DateFormat('kk:mm').format(DateTime.fromMillisecondsSinceEpoch(
                  int.parse(document.data()['timestamp']))),
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12.0,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.right,
            ),
            margin: EdgeInsets.only(
              left: 150,
              right: 15,
              bottom: isLastMessageRight(index) ? 20 : 5,
            ),
          ),
        ],
      );
    } else {
      // Message from my friend in the chat
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // isLastMessageLeft(index)
                //     ? Material(
                //         child: CachedNetworkImage(
                //           placeholder: (context, url) => Container(
                //             child: CircularProgressIndicator(
                //               valueColor:
                //                   AlwaysStoppedAnimation(Colors.blueAccent),
                //             ),
                //             width: 35,
                //             height: 35,
                //             padding: EdgeInsets.all(10),
                //           ),
                //           errorWidget: (context, url, error) => Material(
                //             child: Image.asset(
                //               'images/not_avail.jpeg',
                //               height: 200,
                //               width: 200,
                //               fit: BoxFit.cover,
                //             ),
                //             borderRadius: BorderRadius.circular(8),
                //             clipBehavior: Clip.hardEdge,
                //           ),
                //           imageUrl: peerAvatar,
                //           height: 35,
                //           width: 35,
                //           fit: BoxFit.cover,
                //         ),
                //         borderRadius: BorderRadius.circular(18),
                //         clipBehavior: Clip.hardEdge,
                //       )
                // :
                Container(
                  width: 15,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    document.data()['type'] == 0
                        ? Container(
                            child: Text(
                              document.data()['content'],
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.blue[300],
                            ),
                          )
                        : document.data()['type'] == 1
                            // if the message my friends sends is an image
                            ? Container(
                                child: FlatButton(
                                  onPressed: () {
                                    print(document.data()['content']);
                                    print(document.get('content'));
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return FullPhoto(
                                        url: document.data()['content'],
                                      );
                                    }));
                                  },
                                  child: Material(
                                    child: CachedNetworkImage(
                                      placeholder: (context, url) => Container(
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation(
                                              Colors.blueAccent),
                                        ),
                                        width: 200,
                                        height: 200,
                                        padding: EdgeInsets.all(70),
                                        decoration: BoxDecoration(
                                          color: Colors.grey,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Material(
                                        child: Image.asset(
                                          'images/not_avail.jpeg',
                                          height: 200,
                                          width: 200,
                                          fit: BoxFit.cover,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        clipBehavior: Clip.hardEdge,
                                      ),
                                      imageUrl: document.data()['content'],
                                      width: 200,
                                      height: 200,
                                      fit: BoxFit.cover,
                                    ),
                                    clipBehavior: Clip.hardEdge,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                                margin: EdgeInsets.only(
                                  left: 10,
                                ),
                              )
                            :
                            //  if its a sticker my friend send in the chat
                            Container(
                                child: Image.asset(
                                  'images/${document.data()['content']}.gif',
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                                margin: EdgeInsets.only(
                                  bottom: isLastMessageLeft(index) ? 20 : 10,
                                  right: 10,
                                ),
                              ),
                    Container(
                      child: Text(
                        DateFormat('kk:mm').format(
                            DateTime.fromMillisecondsSinceEpoch(
                                int.parse(document.data()['timestamp']))),
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12.0,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 5),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
        margin: EdgeInsets.only(bottom: 10, top: 10),
      );
    }
  }

  isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessages != null &&
            listMessages[index - 1].data()['idFrom'] == id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  isLastMessageLeft(int index) {
    if ((index > 0 &&
            listMessages != null &&
            listMessages[index - 1].data()['idFrom'] == id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

// method to finalize sending of messages
  void onSendMessage(String content, int type) {
    // type 0 = text, 1 = image, 2 = sticker;
    if (content.trim() != '') {
      textEditingController.clear();
      var documentReference = firestore
          .collection('messages')
          .doc(groupChatId)
          .collection(groupChatId)
          .doc(DateTime.now().millisecondsSinceEpoch.toString());

      firestore.runTransaction(
        (transaction) async => transaction.set(
          documentReference,
          {
            'idFrom': id,
            'idTo': peerId,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': content,
            'type': type,
          },
        ),
      );
      listscrollController.animateTo(
        0.0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Fluttertoast.showToast(
        msg: 'NOthing to send',
        backgroundColor: Colors.blueAccent,
        textColor: Colors.white,
      );
    }
  }

  //  Method to get the image file from the user phone
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
      setState(() {
        isLoading = true;
      });
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
        isLoading = false;
        print("File Uploaded");
        onSendMessage(imageUrl, 1);
      });
    },
        // next set of lines handles errors arising from wrong file specs
        onError: (err) {
      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: "The file is not an image");
    });
  }

  // This builds the row containing the buttons and textfield for the chatscreen
  buildInput() {
    return Container(
      child: Row(
        children: [
          // building the Sticker button
          Material(
            child: Container(
              child: IconButton(
                onPressed: getSticker,
                icon: Icon(Icons.face),
                color: Color(0xff203152),
              ),
            ),
            color: Colors.white,
          ),
          // building image button
          Material(
            child: Container(
              child: IconButton(
                onPressed: getImage,
                icon: Icon(Icons.image),
                color: Color(0xff203152),
              ),
            ),
            color: Colors.white,
          ),
          // building text field
          Expanded(
            child: Container(
              child: TextField(
                controller: textEditingController,
                focusNode: focusNode,
                onSubmitted: (value) {
                  onSendMessage(textEditingController.text, 0);
                },
                decoration: InputDecoration.collapsed(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),
          // building the send button
          Material(
            child: Container(
              child: IconButton(
                onPressed: () => onSendMessage(textEditingController.text, 0),
                icon: Icon(Icons.send),
                color: Color(0xff203152),
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey,
            width: 0.5,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    isShowSticker = false;
    imageUrl = '';
    isLoading = false;
    groupChatId = '';
    readLocal();
    focusNode.addListener(
      () {
        onFocusChange();
      },
    );
    listscrollController.addListener(
      () {
        _scrollListener();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            print('tapped');
            return Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return FullPhoto(
                    url: peerAvatar,
                  );
                },
              ),
            );
          },
          child: Row(
            children: [
              Row(
                children: [
                  Material(
                    child: CachedNetworkImage(
                      placeholder: (context, url) => Container(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.blueAccent),
                        ),
                        width: 200,
                        height: 200,
                        padding: EdgeInsets.all(70),
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      errorWidget: (context, url, error) => Material(
                        child: Image.asset(
                          'images/not_avail.jpeg',
                          height: 200,
                          width: 200,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        clipBehavior: Clip.hardEdge,
                      ),
                      imageUrl: peerAvatar,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                    clipBehavior: Clip.hardEdge,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    "$peerName",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: WillPopScope(
        child: Stack(
          children: [
            Column(
              children: [
                // List of Messages
                buildListMessages(),
                // BUilding stickers

                // input field for messages
                buildInput(),
                (isShowSticker ? buildSticker() : Container()),
              ],
            ),
            // Loading and positioning of the children of a stack widget
            // Positioned(

            //   child: isLoading ? Loading() : Container(),
            // ),
          ],
        ),
        onWillPop: onBackPress,
      ),
    );
  }
}
