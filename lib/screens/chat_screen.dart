import 'package:flutter/material.dart';
import 'package:flash_chat_flutter/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

User? loggedInUser;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  static const String id = 'chat_screen';

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final messageTextColler = TextEditingController();
  late String messageText;

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
      }
    } catch (err) {
      print(err);
    }
  }

  void getMessages() async {
    try {
      final messages = await _firestore.collection('messages').get();
      for (var message in messages.docs) {}
    } catch (err) {
      print(err);
    }
  }

  void messageStream() async {
    try {
      await _firestore
          .collection('messages')
          .snapshots()
          .listen((querySnapshot) {
        List<Map<String, dynamic>> messages = [];

        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          messages.add(data);
        }
      });
    } catch (err) {
      print("Error fetching messages: $err");
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          Row(
            children: [
              Text(
                'Logout: ',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              IconButton(
                  icon: const Icon(Icons.close),
                  color: Colors.white,
                  onPressed: () {
                    _auth.signOut();
                    Navigator.pop(context);
                  }),
            ],
          ),
        ],
        title: const Text(
          '⚡️Chat',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: SafeArea(
        child: Container(
          color: Colors.black,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('messages').snapshots(),
                builder: (context, snapshot) {
                  List<Widget> messagesWidgets = [];

                  if (!snapshot.hasData) {
                    return Expanded(
                      child: Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.lightBlueAccent,
                        ),
                      ),
                    );
                  }

                  final messages = snapshot.data?.docs.reversed;

                  for (var message in messages!) {
                    final data = message.data() as Map<String, dynamic>;
                    final messageText = data['text'] ?? '';
                    final messageSender = data['sender'] ?? '';

                    final currentUser = loggedInUser?.email;

                    messagesWidgets.add(MessageBubble(
                      message: messageText,
                      sender: messageSender,
                      isMe: currentUser == messageSender,
                    ));
                  }

                  return Expanded(
                    child: ListView(
                      // reverse: true,
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 20.0),
                      children: messagesWidgets,
                    ),
                  );
                },
              ),
              Container(
                decoration: kMessageContainerDecoration,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: messageTextColler,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        onChanged: (value) {
                          messageText = value;
                        },
                        decoration: kMessageTextFieldDecoration,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        messageTextColler.clear();
                        _firestore.collection('messages').add({
                          'text': messageText,
                          'sender': loggedInUser?.email,
                        });
                      },
                      child: const Text(
                        'Send',
                        style: kSendButtonTextStyle,
                      ),
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

class MessageBubble extends StatelessWidget {
  final dynamic message;
  final dynamic sender;
  final bool isMe;

  const MessageBubble(
      {super.key,
      required this.message,
      required this.sender,
      required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.black54,
            ),
          ),
          Material(
            elevation: 5.0,
            borderRadius: isMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                  )
                : BorderRadius.only(
                    topRight: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                  ),
            color: isMe ? Colors.blue : Colors.white,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                message,
                style: TextStyle(
                    fontSize: 15.0,
                    color: isMe
                        ? Colors.white
                        : Colors.black54), // Add styling as needed
              ),
            ),
          ),
        ],
      ),
    );
  }
}
