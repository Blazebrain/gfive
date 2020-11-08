// import 'package:flutter/material.dart';

// // Method to build a list of messages gotten from a snapshot stream
// buildListMessages() {
//   return Expanded(
//     child: groupChatId == ''
//         ? Loading()
//         : StreamBuilder(
//             stream: firestore
//                 .collection('messages')
//                 .doc('groupChatId')
//                 .collection('groupChatId')
//                 .doc(DateTime.now().millisecondsSinceEpoch.toString())
//                 .snapshots(),
//             builder: (context, snapshot) {
//               if (!snapshot.hasData) {
//                 return Loading();
//               } else {
//                 listMessages.addAll(snapshot.data.document);
//                 return ListView.builder(
//                   itemCount: snapshot.data.documents.length,
//                   controller: listscrollController,
//                   reverse: true,
//                   itemBuilder: (context, index) {
//                     return buildChatItem(index, snapshot.data.documents[index]);
//                   },
//                 );
//               }
//             },
//           ),
//   );
// }

//  From the beginning

//  _scrollListener() {
//     if (listscrollController.offset >=
//             listscrollController.position.maxScrollExtent &&
//         !listscrollController.position.outOfRange) {
//       print('reached the bottom');
//       setState(() {
//         _limit += _limitIncrement;
//       });
//     }
//     if (listscrollController.offset <=
//             listscrollController.position.minScrollExtent &&
//         !listscrollController.position.outOfRange) {
//       print('reached the top');
//       setState(() {
//         print('reached the top');
//       });
//     }
//   }

//   void onFocusChange() {
//     if (focusNode.hasFocus) {
//       setState(() {
//         isShowSticker = false;
//       });
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     focusNode.addListener(
//       () {
//         onFocusChange();
//       },
//     );

//     listscrollController.addListener(
//       () {
//         _scrollListener();
//       },
//     );
//   }

//   readlocal() async {
//     prefs = await SharedPreferences.getInstance();
//     id = prefs.getString('id');
//     if (id.hashCode <= peerId.hashCode) {
//       groupChatId = '$id - $peerId';
//       print(groupChatId);
//     } else {
//       groupChatId = '$peerId - $id';
//     }

//     firestore.collection('users').doc(id).update({'chattingWith': peerId});
//     setState(() {});
//   }

//   //  Method to get the image file from the user phone
//   Future getImage() async {
//     // creating the instance
//     ImagePicker imagePicker = ImagePicker();
//     PickedFile pickedFile;
//     // This gets the image from the gallery as the source, same technique to get videos from gallery source
//     pickedFile = await imagePicker.getImage(source: ImageSource.gallery);
//     // this returns the file path
//     imageFile = File(pickedFile.path);

//     print(imageFile);
//     if (imageFile != null) {
//       setState(() {
//         isLoading = true;
//       });
//       uploadFile();
//     }
//   }

//   // Method to upload the file to the firestore
//   Future uploadFile() async {
//     // next line documents thre specific time of upload as a reference
//     String fileUploadTime = DateTime.now().millisecondsSinceEpoch.toString();
//     // next line creates a specific reference with the specific time attached to this reference
//     StorageReference reference =
//         FirebaseStorage.instance.ref().child(fileUploadTime);
//     //  next line uploads the image file with the specific time of upload as a child to the reference in the firebase storage
//     StorageUploadTask uploadTask = reference.putFile(imageFile);
//     // the next line catches the last snapshot of the upload data and saves
//     StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
//     // next set of lines gets the download url for the downloaded file
//     storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
//       imageUrl = downloadUrl;
//       setState(() {
//         isLoading = false;
//         print("File Uploaded");
//         onSendMessage(imageUrl, 1);
//       });
//     },
//         // next set of lines handles errors arising from wrong file specs
//         onError: (err) {
//       setState(() {
//         isLoading = false;
//       });

//       Fluttertoast.showToast(msg: "The file is not an image");
//     });
//   }

//   // method to finalize sending of messages
//   void onSendMessage(String content, int type) {
//     // type 0 = text, 1 = image, 2 = sticker;
//     if (content.trim() != '') {
//       textEditingController.clear();
//       var documentReference = firestore
//           .collection('messages')
//           .doc(groupChatId)
//           .collection(groupChatId)
//           .doc(DateTime.now().millisecondsSinceEpoch.toString());

//       firestore.runTransaction(
//         (transaction) async => transaction.set(
//           documentReference,
//           {
//             'idFrom': id,
//             'idTo': peerId,
//             'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
//             'content': content,
//             'type': type,
//           },
//         ),
//       );
//       listscrollController.animateTo(
//         0.0,
//         duration: Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//       );
//     } else {
//       Fluttertoast.showToast(
//         msg: 'NOthing to show',
//         backgroundColor: Colors.blueAccent,
//         textColor: Colors.white,
//       );
//     }
//   }

//   // Method to build the sticker pack
//   Widget buildSticker() {
//     return Container(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               FlatButton(
//                 onPressed: () => onSendMessage('mimi1', 2),
//                 child: Image.asset(
//                   'images/mimi1.gif',
//                   height: 50,
//                   width: 50.0,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//               FlatButton(
//                 onPressed: () => onSendMessage('mimi2', 2),
//                 child: Image.asset(
//                   'images/mimi2.gif',
//                   height: 50,
//                   width: 50.0,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//               FlatButton(
//                 onPressed: () => onSendMessage('mimi3', 2),
//                 child: Image.asset(
//                   'images/mimi3.gif',
//                   height: 50,
//                   width: 50.0,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ],
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               FlatButton(
//                 onPressed: () => onSendMessage('mimi4', 2),
//                 child: Image.asset(
//                   'images/mimi4.gif',
//                   height: 50,
//                   width: 50.0,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//               FlatButton(
//                 onPressed: () => onSendMessage('mimi5', 2),
//                 child: Image.asset(
//                   'images/mimi5.gif',
//                   height: 50,
//                   width: 50.0,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//               FlatButton(
//                 onPressed: () => onSendMessage('mimi6', 2),
//                 child: Image.asset(
//                   'images/mimi6.gif',
//                   height: 50,
//                   width: 50.0,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ],
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               FlatButton(
//                 onPressed: () => onSendMessage('mimi7', 2),
//                 child: Image.asset(
//                   'images/mimi7.gif',
//                   height: 50,
//                   width: 50.0,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//               FlatButton(
//                 onPressed: () => onSendMessage('mimi8', 2),
//                 child: Image.asset(
//                   'images/mimi8.gif',
//                   height: 50,
//                   width: 50.0,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//       decoration: BoxDecoration(
//         border: Border(
//           top: BorderSide(
//             color: Colors.grey,
//             width: 0.5,
//           ),
//         ),
//       ),
//       padding: EdgeInsets.all(5.0),
//       height: 180.0,
//     );
//   }

//   // // Method to handle back press
//   Future<bool> onBackPress() {
//     if (isShowSticker = true) {
//       setState(() {
//         isShowSticker = false;
//       });
//     } else {
//       firestore.collection('users').doc(id).update({'chattingWith': 'hiii'});
//       Navigator.pop(context);
//     }

//     return Future.value(false);
//   }

//   // This builds the row containing the buttons and textfield for the chatscreen
//   buildInput() {
//     return Container(
//       child: Row(
//         children: [
//           // building the Sticker button
//           Material(
//             child: Container(
//               child: IconButton(
//                 onPressed: getSticker,
//                 icon: Icon(Icons.face),
//                 color: Color(0xff203152),
//               ),
//             ),
//             color: Colors.white,
//           ),
//           // building image button
//           Material(
//             child: Container(
//               child: IconButton(
//                 onPressed: getImage,
//                 icon: Icon(Icons.image),
//                 color: Color(0xff203152),
//               ),
//             ),
//             color: Colors.white,
//           ),
//           // building text field
//           Expanded(
//             child: Container(
//               child: TextField(
//                 controller: textEditingController,
//                 focusNode: focusNode,
//                 onSubmitted: (value) {
//                   onSendMessage(textEditingController.text, 0);
//                 },
//                 decoration: InputDecoration.collapsed(
//                   hintText: 'Type your message...',
//                   hintStyle: TextStyle(
//                     color: Colors.grey,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           // building the send button
//           Material(
//             child: Container(
//               child: IconButton(
//                 onPressed: () => onSendMessage(textEditingController.text, 0),
//                 icon: Icon(Icons.send),
//                 color: Color(0xff203152),
//               ),
//             ),
//             color: Colors.white,
//           ),
//         ],
//       ),
//       width: double.infinity,
//       height: 50.0,
//       decoration: BoxDecoration(
//         border: Border(
//           top: BorderSide(
//             color: Colors.grey,
//             width: 0.5,
//           ),
//         ),
//       ),
//     );
//   }

//   // Method to show the sticker pack by setting isshowsticker to true
//   void getSticker() {
//     focusNode.unfocus();
//     setState(() {
//       isShowSticker = !isShowSticker;
//     });
//   }

//   // Method which builds the chat items
//   buildChatItem(int index, DocumentSnapshot document) {
//     // if the message is from me
//     if (document.get('idFrom') == 0) {
//       return Row(
//         children: [
//           // How the text will apear on the chat screen plus position
//           // If its a message that i send to the screen
//           document.get('type') == 0
//               ? Container(
//                   child: Text(
//                     document.get('content'),
//                     style: TextStyle(
//                       color: Colors.blueAccent,
//                     ),
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.grey,
//                     borderRadius: BorderRadius.circular(8.0),
//                   ),
//                   margin: EdgeInsets.only(
//                     bottom: isLastMessageRight(index) ? 20 : 10,
//                     right: 10,
//                   ),
//                 )
//               // if its an image i send to the chat, this defines how it will appear
//               : document.get('type') == 1
//                   ? Container(
//                       child: FlatButton(
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) {
//                                 return FullPhoto();
//                               },
//                             ),
//                           );
//                         },
//                         child: Material(
//                           child: CachedNetworkImage(
//                             placeholder: (context, url) {
//                               return Container(
//                                 child: CircularProgressIndicator(
//                                   valueColor:
//                                       AlwaysStoppedAnimation(Colors.blueAccent),
//                                 ),
//                                 width: 200,
//                                 height: 200,
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(8.0),
//                                 ),
//                               );
//                             },
//                             errorWidget: (context, url, error) {
//                               return Material(
//                                 child: Image.asset(
//                                   'images/not_avail.jpeg',
//                                   height: 200,
//                                   width: 200,
//                                   fit: BoxFit.cover,
//                                 ),
//                                 clipBehavior: Clip.hardEdge,
//                               );
//                             },
//                             imageUrl: document.get('content'),
//                             width: 200,
//                             height: 200,
//                             fit: BoxFit.cover,
//                           ),
//                           borderRadius: BorderRadius.all(
//                             Radius.circular(8.0),
//                           ),
//                         ),
//                         padding: EdgeInsets.all(0),
//                       ),
//                       margin: EdgeInsets.only(
//                         bottom: isLastMessageRight(index) ? 20 : 10,
//                         right: 10,
//                       ),
//                     )
//                   // if its a sticker i send in to the chaat, this defines it
//                   : Container(
//                       child: Image.asset(
//                         'images/${document.get('content')}.gif',
//                         width: 100,
//                         height: 100,
//                         fit: BoxFit.cover,
//                       ),
//                       margin: EdgeInsets.only(
//                         bottom: isLastMessageRight(index) ? 20 : 10,
//                         top: 10,
//                       ),
//                     ),
//         ],
//       );
//     } else {
//       // If its from the peer/friend, on the left hand
//       return Container(
//         child: Column(children: [
//           Row(
//             children: [
//               isLastMessageLeft(index)
//                   ? Material(
//                       child: CachedNetworkImage(
//                         imageUrl: peerAvatar,
//                         placeholder: (context, url) {
//                           return Container(
//                             child: CircularProgressIndicator(
//                               valueColor:
//                                   AlwaysStoppedAnimation(Colors.blueAccent),
//                             ),
//                             width: 35,
//                             height: 35,
//                             padding: EdgeInsets.all(10),
//                           );
//                         },
//                         width: 35,
//                         height: 35,
//                         fit: BoxFit.cover,
//                         errorWidget: (context, url, error) {
//                           return Material(
//                             child: Image.asset(
//                               'images/not_avail.jpeg',
//                               height: 200,
//                               width: 200,
//                               fit: BoxFit.cover,
//                             ),
//                             clipBehavior: Clip.hardEdge,
//                           );
//                         },
//                       ),
//                     )
//                   : Container(
//                       width: 35,
//                     ),
//             ],
//           )
//         ]),
//       );
//     }
//   }

//   bool isLastMessageLeft(int index) {
//     if ((index > 0 &&
//             listMessages != null &&
//             listMessages[index - 1].get('idFrom') != id) ||
//         index == 0) {
//       return true;
//     } else {
//       return false;
//     }
//   }

//   bool isLastMessageRight(int index) {
//     if ((index > 0 &&
//             listMessages != null &&
//             listMessages[index - 1].get('idFrom') != id) ||
//         index == 0) {
//       return true;
//     } else {
//       return false;
//     }
//   }
