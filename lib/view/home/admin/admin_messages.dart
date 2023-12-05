import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pet_buddy/model/user_messages.dart';
import 'package:pet_buddy/utils/firebase_storage.dart';
import 'package:pet_buddy/utils/firestore_database.dart';
import 'package:pet_buddy/view/home/admin/admin_conversation.dart';

class AdminInbox extends StatefulWidget {
  const AdminInbox({super.key});

  @override
  State<AdminInbox> createState() => _AdminInboxState();
}

class _AdminInboxState extends State<AdminInbox> {
  FirestoreDatabase firestore = FirestoreDatabase();
  FirebaseStorageService firebaseStorage = FirebaseStorageService();

  @override
  void initState() {
    super.initState();
    userMessagesStream = firestore.listenToRootNodes();
  }

  late Stream<List<UserModelWithMessages>> userMessagesStream;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Column(
        children: [
          const Text(
            "Messages",
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.zero,
              child: StreamBuilder<List<UserModelWithMessages>>(
                stream: userMessagesStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var userMessages = snapshot.data!;
                    userMessages.sort((a, b) {
                      var latestMessageOfA =
                          a.messages.values.first["timestamp"];
                      var latestMessageOfB =
                          b.messages.values.first["timestamp"];

                      for (var message in a.messages.values) {
                        if (message["timestamp"] >= latestMessageOfA) {
                          latestMessageOfA = message["timestamp"];
                        }
                      }

                      for (var message in b.messages.values) {
                        if (message["timestamp"] >= latestMessageOfA) {
                          latestMessageOfB = message["timestamp"];
                        }
                      }
                      return latestMessageOfB.compareTo(latestMessageOfA);
                    });

                    return ListView.builder(
                      itemCount: userMessages.length,
                      itemBuilder: (context, index) {
                        final userModel = userMessages[index].userModel;
                        var latestMessage =
                            userMessages[index].messages.values.first;

                        for (var message
                            in userMessages[index].messages.values) {
                          if (message["timestamp"] >=
                              latestMessage["timestamp"]) {
                            latestMessage = message;
                          }
                        }

                        return FutureBuilder<String>(
                          future: firebaseStorage
                              .getImageDownloadUrl(userModel.profileImagePath),
                          builder: (context, urlSnapshot) {
                            if (urlSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return ListTile(
                                leading: const CircleAvatar(
                                  child: CircularProgressIndicator(),
                                ),
                                title: Text(
                                  '${userModel.firstName} ${userModel.lastName}',
                                ),
                              );
                            } else if (urlSnapshot.hasError) {
                              return const ListTile(
                                title: Text('Error loading profile image'),
                              );
                            } else {
                              final imageUrl = urlSnapshot.data;
                              String messageText = latestMessage["message"];
                              final sender = latestMessage["sender"];
                              final timestamp = latestMessage["timestamp"];

                              if (messageText.length > 10) {
                                messageText =
                                    '${messageText.substring(0, 10)}...';
                              }

                              final time = DateTime.fromMillisecondsSinceEpoch(
                                  timestamp);
                              final timeFormatted =
                                  DateFormat("h:mm a").format(time);

                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(imageUrl!),
                                ),
                                title: Text(
                                  '${userModel.firstName} ${userModel.lastName}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: (sender == "admin")
                                    ? Text(
                                        'You: $messageText',
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                      )
                                    : Text(
                                        '${userModel.firstName}: $messageText',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.amber,
                                            fontWeight: FontWeight.bold)),
                                trailing: Text(
                                  timeFormatted,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Dialog(
                                        child: AdminConversation(
                                          userInConvo: userModel,
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            }
                          },
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return const Center(
                      child: Text(
                        'You have no messages right now.',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
