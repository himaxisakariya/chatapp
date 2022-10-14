import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:loction/classmodel/chat_model.dart';
import 'package:loction/components/colors.dart';
import 'package:loction/screens/welcome_screen.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';

final _firestore = FirebaseFirestore.instance;
User? loggedInuser;
final focusNode = FocusNode();

class ChatScreen extends StatefulWidget {
  static String id = 'chat_screen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final sendmessage = TextEditingController();
  final _auth = FirebaseAuth.instance;
  var messageText;
  final ImagePicker _picker = ImagePicker();
  String? imageurl;
  final storageRef = FirebaseStorage.instance;
  bool i = true;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  void dispose() async {
    super.dispose();
    await _auth.signOut();
  }

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInuser = user;
        print(loggedInuser);
      }
    } catch (e) {
      print(e);
    }
  }

  void onEmojiSelected(String emoji) => setState(() {
        sendmessage.text = sendmessage.text + emoji;
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () {
                _auth.signOut();
                Navigator.pushReplacement(context, MaterialPageRoute(
                  builder: (context) {
                    return WelcomeScreen();
                  },
                ));
              }),
        ],
        title: Text('Messages'),
        backgroundColor: FixColors.primaryTeal,
      ),
      body: SafeArea(
        child: WillPopScope(
          onWillPop: () async {
            bool willLeave = false;
            await showDialog(
                context: context,
                builder: (_) => AlertDialog(
                      title: const Text('Exit'),
                      content: const Text("Are you sure You want to Exit?"),
                      actions: [
                        TextButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStatePropertyAll(Colors.teal)),
                            onPressed: () {
                              willLeave = true;
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              'Yes',
                              style: TextStyle(color: Colors.white),
                            )),
                        TextButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStatePropertyAll(Colors.teal)),
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text(
                              'No',
                              style: TextStyle(color: Colors.white),
                            ))
                      ],
                    ));
            return willLeave;
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              demo(),
              Container(
                width: double.infinity,
                height: 50.0,
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.black38)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Material(
                      child: new Container(
                          margin: new EdgeInsets.symmetric(horizontal: 4.0),
                          child: IconButton(
                              onPressed: () {
                                setState(() {
                                  i = !i;
                                });
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text("Image"),
                                      content: Text("Select Image"),
                                      actions: [
                                        IconButton(
                                            onPressed: () async {
                                              Navigator.pop(context);
                                              final XFile? image =
                                                  await _picker.pickImage(
                                                      source:
                                                          ImageSource.camera);
                                              File file = File(image!.path);
                                              if (image != null) {
                                                var snapshot = await storageRef
                                                    .ref()
                                                    .child(
                                                        'images/${image.name}')
                                                    .putFile(file);
                                                var downloadUrl = await snapshot
                                                    .ref
                                                    .getDownloadURL();
                                                setState(() {
                                                  imageurl = downloadUrl;
                                                });
                                                print(imageurl);
                                                if (downloadUrl == null) {
                                                  CircularProgressIndicator();
                                                }
                                              }
                                            },
                                            icon: Icon(Icons.camera_alt)),
                                        IconButton(
                                            onPressed: () async {
                                              Navigator.pop(context);
                                              final XFile? image =
                                                  await _picker.pickImage(
                                                      source:
                                                          ImageSource.gallery);
                                              var file = File(image!.path);
                                              if (image != null) {
                                                var snapshot = await storageRef
                                                    .ref()
                                                    .child(
                                                        'images/${image.name}')
                                                    .putFile(file);
                                                var downloadUrl = await snapshot
                                                    .ref
                                                    .getDownloadURL();
                                                setState(() {
                                                  imageurl = downloadUrl;
                                                });
                                                print(imageurl);
                                                if (downloadUrl == null) {
                                                  CircularProgressIndicator();
                                                }
                                              }
                                            },
                                            icon: Icon(Icons
                                                .photo_size_select_actual_outlined))
                                      ],
                                    );
                                  },
                                );
                              },
                              icon: Icon(Icons.image))),
                      color: Colors.white,
                    ),
                    Flexible(
                      child: Container(
                        child: TextField(
                          textInputAction: TextInputAction.send,
                          keyboardType: TextInputType.multiline,
                          focusNode: focusNode,
                          onSubmitted: (value) {
                            sendmessage.clear();
                            _firestore.collection('messages').add({
                              'sender': loggedInuser!.email,
                              'text': messageText,
                              'type': imageurl,
                              'timestamp': Timestamp.now(),
                            });
                          },
                          controller: sendmessage,
                          onChanged: (value) {
                            if (imageurl != null) {
                              imageurl = value;
                            } else {
                              messageText = value;
                            }
                          },
                          style:
                              TextStyle(color: Colors.blueGrey, fontSize: 15.0),
                          decoration: InputDecoration(
                              hintText: "Type Something....",
                              hintStyle: TextStyle(color: Colors.blueGrey)),
                        ),
                      ),
                    ),
                    Material(
                      child: new Container(
                        margin: new EdgeInsets.symmetric(horizontal: 8.0),
                        child: new IconButton(
                          icon: new Icon(Icons.send),
                          onPressed: () {
                            sendmessage.clear();
                            _firestore.collection('messages').add({
                              'sender': loggedInuser!.email,
                              'text': messageText,
                              'type': imageurl,
                              'timestamp': Timestamp.now(),
                            });
                          },
                          color: Colors.blueGrey,
                        ),
                      ),
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class demo extends StatefulWidget {
  const demo({Key? key}) : super(key: key);

  @override
  State<demo> createState() => _demoState();
}

class _demoState extends State<demo> {
  @override
  Widget build(BuildContext context) {
    List<UserModal> elements = <UserModal>[];
    return SingleChildScrollView(
      child: StreamBuilder(
        stream: _firestore
            .collection('messages')
            .orderBy("timestamp", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Text(''));
          } else if (snapshot.hasData) {
           // final user = snapshot.data!;
           //  UserModal userModal =
           //      UserModal.fromJson(snapshot.data as Map<String, dynamic>);
            UserModal userModal =
            snapshot.data!.docs as UserModal;
            return StickyGroupedListView<UserModal, DateTime>(
              elements: elements,
              order: StickyGroupedListOrder.DESC,
              groupBy: (UserModal userModal) => DateTime(userModal.timestamp!.year,
                  userModal.timestamp!.month, userModal.timestamp!.day),
              groupSeparatorBuilder: (UserModal element) {
                return SizedBox(
                    height: 50,
                    child: Align(
                        alignment: Alignment.center,
                        child: Container(
                            width: 120,
                            decoration: BoxDecoration(
                              color: Colors.teal,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(20.0)),
                            ),
                            child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                    '${userModal.timestamp!.day} / ${userModal.timestamp!.month} / ${userModal.timestamp!.year}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold))))));
              },
              floatingHeader: true,
              itemBuilder: (context, userModal) {
                return Padding(
                  padding: EdgeInsets.all(10.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: userModal.isMe!
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "${userModal.sender}",
                          style:
                              TextStyle(fontSize: 12.0, color: Colors.black54),
                        ),
                        Material(
                            borderRadius: BorderRadius.circular(20),
                            elevation: 5.0,
                            color: userModal.isMe!
                                ? FixColors.primaryGrey
                                : FixColors.lightBlue,
                            child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 20.0),
                                child: Column(
                                    crossAxisAlignment: userModal.isMe!
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                    children: [
                                      if (userModal.type == null)
                                        Text(
                                          userModal.text!,
                                          style: TextStyle(
                                            fontSize: 18.0,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      if (userModal.type != null)
                                        Container(
                                          height: 200,
                                          width: 200,
                                          child: CachedNetworkImage(
                                            imageUrl: "${userModal.type}",
                                            fit: BoxFit.fill,
                                            placeholder: (context, url) =>
                                                CircularProgressIndicator(),
                                            errorWidget: (context, url, error) {
                                              return Container(
                                                height: 0,
                                                width: 0,
                                              );
                                            },
                                          ),
                                        ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 6.0),
                                        // child: Text(
                                        //   DateFormat('h:mm a').format(element.timestamp),
                                        //   style: TextStyle(
                                        //     fontSize: 9.0,
                                        //     color: Colors.black54,
                                        //   ),
                                        // ),
                                      )
                                    ])))
                      ],
                    ),
                  ),
                );
              },
              itemComparator: (element1, element2) =>
                  element1.timestamp!.compareTo(element2.timestamp!),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
// Widget buildMessages() {
//   return Flexible(
//     child: StreamBuilder(
//       stream: _firestore
//           .collection('messages')
//           .orderBy("timestamp", descending: true)
//           .snapshots(),
//       builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//         if (snapshot.hasData) {
//           UserModal userModal =
//               snapshot.data!.docs as UserModal;
//           return ListView.builder(
//             padding: const EdgeInsets.all(10.0),
//             itemBuilder: (BuildContext context, int index) =>
//                 buildItem(index, snapshot.data.documents[index]),
//             itemCount: snapshot.data.documents.length,
//             reverse: true,
//             controller: listScrollController,
//           );
//         } else {
//           return Container();
//         }
//       },
//     ),
//   );
// }


