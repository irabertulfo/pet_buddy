import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:async';
import 'package:pet_buddy/model/chat_config.dart';
import 'package:pet_buddy/model/user_model.dart';
import 'package:pet_buddy/utils/firestore_database.dart';

class ChatScreen extends StatelessWidget {
  final FirestoreDatabase firestoreDatabase = FirestoreDatabase();
  final UserModel? user = UserSingleton().user;

  ChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (user != null) {
      final adminMessagesStream =
          firestoreDatabase.listenToAdminMessages(user!.uid);
      return ChatWidget(
        config: chatConfig,
        firestoreDatabase: firestoreDatabase,
        adminMessagesStream: adminMessagesStream,
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

  const ChatWidget({
    Key? key,
    required this.config,
    required this.firestoreDatabase,
    required this.adminMessagesStream,
  }) : super(key: key);

  @override
  ChatWidgetState createState() => ChatWidgetState();
}

class ChatWidgetState extends State<ChatWidget> {
  UserModel? user = UserSingleton().user;
  TextEditingController textController = TextEditingController();
  List<ChatMessage> botChatMessages = [];
  List<ChatMessage> liveChatMessages = [];
  bool isLiveChatMode = false;

  FirestoreDatabase firestoreDatabase = FirestoreDatabase();
  StreamSubscription<DatabaseEvent>? adminMessagesSubscription;
  DatabaseReference? liveChatReference;

  @override
  void initState() {
    super.initState();
    _addTypingAnimation();
    _removeTypingAnimation();
    _addBotMessage("Hello, I am BuddyBot. How can I help you?");
    adminMessagesSubscription = widget.adminMessagesStream.listen((event) {
      final DataSnapshot snapshot = event.snapshot;
      final Map<dynamic, dynamic>? message =
          snapshot.value as Map<dynamic, dynamic>?;
      if (message != null && message['sender'] == 'admin') {
        setState(() {
          liveChatMessages.add(ChatMessage(
            message: message['message'],
            isUser: false,
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

    if (isLiveChatMode) {
      firestoreDatabase.sendMessage(user!.uid, message, 'user');
    } else {
      _addUserMessage(message);
      _addTypingAnimation();
      Timer(const Duration(seconds: 2), () {
        String response = _generateResponse(message);
        _removeTypingAnimation();
        _addBotMessage(response);
      });
    }

    textController.clear();

    if (isLiveChatMode) {
      _scrollToBottom();
    }
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

  void _addBotMessage(String message) {
    setState(() {
      botChatMessages.add(ChatMessage(
        message: message,
        isUser: false,
      ));
    });

    _scrollToBottom();
  }

  void _addTypingAnimation() {
    setState(() {
      botChatMessages.add(const ChatMessage(
        message: '',
        isUser: false,
        isTypingAnimation: true,
      ));
    });

    _scrollToBottom();
  }

  void _removeTypingAnimation() {
    int lastTypingIndex =
        botChatMessages.lastIndexWhere((message) => message.isTypingAnimation);
    if (lastTypingIndex >= 0) {
      setState(() {
        botChatMessages.removeAt(lastTypingIndex);
      });
    }
  }

  String _generateResponse(String message) {
    message = message.toLowerCase();

    for (String key in widget.config.keys) {
      if (message.contains(key)) {
        return '${widget.config[key]}';
      }
    }

    return "Sorry, I don't understand that question. Please switch to live chat.";
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isLiveChatMode ? 'Live Chat Mode' : 'Chat Bot Mode',
                style: const TextStyle(fontSize: 20),
              ),
              SwitchWidget(onSwitch: (value) {
                setState(() {
                  isLiveChatMode = value;
                  _scrollToBottom();
                });
              }),
            ],
          ),
        ),
        isLiveChatMode
            ? Expanded(
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
              )
            : Expanded(
                child: Container(
                  color: Colors.white,
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: botChatMessages.length,
                    itemBuilder: (BuildContext context, int index) {
                      return botChatMessages[index];
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

class SwitchWidget extends StatefulWidget {
  final Function(bool) onSwitch;

  const SwitchWidget({
    Key? key,
    required this.onSwitch,
  }) : super(key: key);

  @override
  SwitchWidgetState createState() => SwitchWidgetState();
}

class SwitchWidgetState extends State<SwitchWidget> {
  bool isSwitched = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Live Chat'),
        Switch(
          value: isSwitched,
          onChanged: (value) {
            setState(() {
              isSwitched = value;
              widget.onSwitch(isSwitched);
            });
          },
        ),
      ],
    );
  }
}
