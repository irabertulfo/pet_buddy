import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:async';
import 'package:pet_buddy/model/chat_config.dart';
import 'package:pet_buddy/model/user_model.dart';
import 'package:pet_buddy/utils/firestore_database.dart';

class AdminConversation extends StatelessWidget {
  final FirestoreDatabase firestoreDatabase = FirestoreDatabase();
  final UserModel? user = UserSingleton().user;
  final UserModel? userInConvo;

  AdminConversation({Key? key, required this.userInConvo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (user != null) {
      final adminMessagesStream =
          firestoreDatabase.listenToAdminMessages(userInConvo!.uid);
      return ChatWidget(
        config: chatConfig,
        firestoreDatabase: firestoreDatabase,
        adminMessagesStream: adminMessagesStream,
        userInConvo: userInConvo,
      );
    } else {
      return const Center(
        child: Text('User not logged in.'),
      );
    }
  }
}

class ChatWidget extends StatefulWidget {
  final Map<String, String> config;
  final FirestoreDatabase firestoreDatabase;
  final Stream<DatabaseEvent> adminMessagesStream;
  final UserModel? userInConvo;

  const ChatWidget(
      {Key? key,
      required this.config,
      required this.firestoreDatabase,
      required this.adminMessagesStream,
      required this.userInConvo})
      : super(key: key);

  @override
  ChatWidgetState createState() => ChatWidgetState();
}

class ChatWidgetState extends State<ChatWidget> {
  UserModel? user = UserSingleton().user;
  TextEditingController textController = TextEditingController();
  List<ChatMessage> botChatMessages = [];
  List<ChatMessage> liveChatMessages = [];

  FirestoreDatabase firestoreDatabase = FirestoreDatabase();
  StreamSubscription<DatabaseEvent>? adminMessagesSubscription;
  DatabaseReference? liveChatReference;

  @override
  void initState() {
    super.initState();
    adminMessagesSubscription = widget.adminMessagesStream.listen((event) {
      final DataSnapshot snapshot = event.snapshot;
      final Map<dynamic, dynamic>? message =
          snapshot.value as Map<dynamic, dynamic>?;
      if (message != null &&
          (message['sender'] == 'admin' || message['sender'] == 'user')) {
        setState(() {
          liveChatMessages.add(ChatMessage(
            message: message['message'],
            isUser: message['sender'] != 'user',
          ));
        });
        _scrollToBottom();
      }
    });

    if (user != null) {
      liveChatReference = FirebaseDatabase.instance.ref().child(user!.uid);
      liveChatReference!.onChildAdded.listen((event) {
        final DataSnapshot snapshot = event.snapshot;
        final Map<dynamic, dynamic>? message =
            snapshot.value as Map<dynamic, dynamic>?;
        if (message != null && message['sender'] != 'admin') {
          setState(() {
            liveChatMessages.add(ChatMessage(
              message: message['message'],
              isUser: message['sender'] == 'user',
            ));
          });
          _scrollToBottom();
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    adminMessagesSubscription?.cancel();
    liveChatReference?.onDisconnect();
  }

  void _handleSendMessage(String message) {
    if (message.trim().isEmpty) {
      return;
    }

    firestoreDatabase.sendMessage(widget.userInConvo!.uid, message, 'admin');
    _addUserMessage(message);
    textController.clear();
    _scrollToBottom();
  }

  void _addUserMessage(String message) {
    setState(() {
      botChatMessages.add(ChatMessage(
        message: message,
        isUser: true,
      ));
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${widget.userInConvo!.firstName} ${widget.userInConvo!.lastName}',
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            color: Colors.white,
            child: ListView.builder(
              controller: _scrollController,
              itemCount: liveChatMessages.length,
              itemBuilder: (BuildContext context, int index) {
                return liveChatMessages[index];
              },
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8.0),
          color: Colors.grey[200],
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: textController,
                  onSubmitted: _handleSendMessage,
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                  decoration: const InputDecoration(
                    hintText: 'Ask a question...',
                    border: InputBorder.none,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  _handleSendMessage(textController.text);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String message;
  final bool isUser;
  final bool isTypingAnimation;

  const ChatMessage({
    Key? key,
    required this.message,
    required this.isUser,
    this.isTypingAnimation = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (isTypingAnimation)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(),
            ),
          if (!isTypingAnimation)
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: isUser ? Colors.blue : Colors.green,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
