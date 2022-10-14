import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter/services.dart';
import 'package:loction/components/colors.dart';

final _firestore = FirebaseFirestore.instance;
User? loggedInuser;
final focusNode = FocusNode();

class ChatScreen extends StatefulWidget {
  static String id = 'chat_screen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final controller = TextEditingController();
  final _auth = FirebaseAuth.instance;
  bool isEmojiVisible = false;
  bool isKeyboardVisible = false;
  var messageText;
  final ImagePicker _picker = ImagePicker();
  String? imageurl;
  final storageRef = FirebaseStorage.instance;
  bool i = true;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    var keyboardVisibilityController = KeyboardVisibilityController();
    keyboardVisibilityController.onChange.listen((bool isKeyboardVisible) {
      setState(() {
        this.isKeyboardVisible = isKeyboardVisible;
      });

      if (isKeyboardVisible && isEmojiVisible) {
        setState(() {
          isEmojiVisible = false;
        });
      }
    });
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
    controller.text = controller.text + emoji;
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
                Navigator.pop(context);
              }),
        ],
        title: Text('Messages'),
        backgroundColor: FixColors.primaryTeal,
      ),
      body: SafeArea(
        child: WillPopScope(
          onWillPop:  () async {
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
              MessagesStream(),
              Container(
                width: double.infinity,
                height: 50.0,
                decoration: new BoxDecoration(
                    border: new Border(
                        top:
                        new BorderSide(color: Colors.blueGrey, width: 0.5)),
                    color: Colors.white),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Material(
                      child: new Container(
                        margin: new EdgeInsets.symmetric(horizontal: 1.0),
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
                            icon: Icon(Icons.image))
                      ),
                      color: Colors.white,
                    ),
                    Flexible(
                      child: Container(
                        child: TextField(
                          textInputAction: TextInputAction.send,
                          keyboardType: TextInputType.multiline,
                          focusNode: focusNode,
                          onSubmitted: (value) {
                            controller.clear();
                            _firestore.collection('messages').add({
                              'sender': loggedInuser!.email,
                              'text': messageText,
                              'type': imageurl,
                              'timestamp': Timestamp.now(),
                            });
                          },
                          maxLines: null,
                          controller: controller,
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
                            controller.clear();
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

String giveUsername(String email) {
  return email.replaceAll(new RegExp(r'@g(oogle)?mail\.com$'), '');
}

class MessagesStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('messages')
          .orderBy("timestamp", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        List<Widget> messageWidgets = snapshot.data!.docs.map<Widget>((m) {
          final data = m.data as dynamic;
          final messageText = data['text'];
          final messageSender = data['sender'];
          final imageurl = data['type'];
          final currentUser = loggedInuser!.email;
          final timeStamp = data['timestamp'];
          return MessageBubble(
            sender: messageSender,
            text: messageText,
            type: imageurl,
            timestamp: timeStamp,
            isMe: currentUser == messageSender,
          );
        }).toList();

        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            children: messageWidgets,
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble({this.sender, this.text, this.timestamp, this.isMe,this.type});
  final String? sender;
  final String? text;
  final String? type;
  final Timestamp? timestamp;
  final bool? isMe;

  @override
  Widget build(BuildContext context) {
    final dateTime =
    DateTime.fromMillisecondsSinceEpoch(timestamp!.seconds * 1000);
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
        isMe! ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "${giveUsername(sender!)}",
            style: TextStyle(fontSize: 12.0, color: Colors.black54),
          ),
          Material(
            borderRadius: isMe!
                ? BorderRadius.only(
              bottomLeft: Radius.circular(30.0),
              topLeft: Radius.circular(30.0),
              bottomRight: Radius.circular(30.0),
            )
                : BorderRadius.only(
              bottomLeft: Radius.circular(30.0),
              topRight: Radius.circular(30.0),
              bottomRight: Radius.circular(30.0),
            ),
            elevation: 5.0,
            color:
            isMe! ? FixColors.primaryGrey : FixColors.lightBlue,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Column(
                crossAxisAlignment:
                isMe! ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (type == null) Text(
                    text!,
                    style: TextStyle(
                      fontSize: 18.0,
                      color: isMe! ? Colors.white : Colors.black54,
                    ),
                  ),
                  if (type != null)
                    Container(
                      height: 200,
                      width: 200,
                      child: CachedNetworkImage(
                        imageUrl: "${type}",
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
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(
                      "${DateFormat('h:mm a').format(dateTime)}",
                      style: TextStyle(
                        fontSize: 9.0,
                        color: isMe!
                            ? Colors.white.withOpacity(0.5)
                            : Colors.black54.withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}