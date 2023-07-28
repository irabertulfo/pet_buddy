import 'package:flutter/material.dart';
import 'package:pet_buddy/constants/texts.dart';
import 'package:pet_buddy/model/user_model.dart';
import 'package:pet_buddy/utils/firebase_storage.dart';
import 'package:pet_buddy/view/home/client/client_tab_bar.dart';
import 'package:pet_buddy/view/home/client/profile-photo.dart';

class HomeClientScreen extends StatefulWidget {
  HomeClientScreen({Key? key}) : super(key: key);

  @override
  State<HomeClientScreen> createState() => _HomeClientScreenState();
}

class _HomeClientScreenState extends State<HomeClientScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  UserModel? user = UserSingleton().user;

  FirebaseStorageService firebaseStorage = FirebaseStorageService();
  Future<String>? imageUrlFuture;

  @override
  void initState() {
    super.initState();
    imageUrlFuture =
        firebaseStorage.getImageDownloadUrl(user?.profileImagePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text(appTitle),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      body: const ClientTabBar(),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            FutureBuilder<String>(
              future: imageUrlFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // While the future is loading, show a circular progress indicator
                  return DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.grey,
                    ),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (snapshot.hasError) {
                  // If there's an error, display an error message
                  return DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.grey,
                    ),
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else {
                  // If the future completed successfully, build the drawer header with the profile picture
                  final imageUrl = snapshot.data;
                  return DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.grey,
                    ),
                    child: ProfilePicture(
                      imageUrl: imageUrl ?? "",
                      name: "user?.name",
                    ),
                  );
                }
              },
            ),
            ListTile(
              title: Text('Item 1'),
              onTap: () {
                // Handle item 1 tap
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              title: Text('Item 2'),
              onTap: () {
                // Handle item 2 tap
                Navigator.pop(context); // Close the drawer
              },
            ),
            // Add more ListTile widgets for other drawer items as needed
          ],
        ),
      ),
    );
  }
}
