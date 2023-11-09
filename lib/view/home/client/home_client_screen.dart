import 'package:flutter/material.dart';
import 'package:pet_buddy/constants/texts.dart';
import 'package:pet_buddy/controller/login/login_controller.dart';
import 'package:pet_buddy/model/user_model.dart';
import 'package:pet_buddy/utils/firebase_storage.dart';
import 'package:pet_buddy/view/home/client/about-us/about_us_screen.dart';
import 'package:pet_buddy/view/home/client/client_tab_bar.dart';
import 'package:pet_buddy/view/home/client/profile_photo.dart';

class HomeClientScreen extends StatefulWidget {
  const HomeClientScreen({Key? key}) : super(key: key);

  @override
  State<HomeClientScreen> createState() => _HomeClientScreenState();
}

class _HomeClientScreenState extends State<HomeClientScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  UserModel? user = UserSingleton().user;

  LoginController loginController = LoginController();

  FirebaseStorageService firebaseStorage = FirebaseStorageService();
  Future<String>? imageUrlFuture;

  @override
  void initState() {
    super.initState();
    imageUrlFuture =
        firebaseStorage.getImageDownloadUrl(user?.profileImagePath);
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () {
                Navigator.of(context).pop();
                _logout(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _logout(BuildContext context) {
    loginController.logout(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Exit'),
            content: const Text('Are you sure you want to exit the app?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Exit'),
              ),
            ],
          ),
        );
      },
      child: Scaffold(
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
                    return const DrawerHeader(
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return DrawerHeader(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                      ),
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else {
                    final imageUrl = snapshot.data;
                    return DrawerHeader(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                      ),
                      child: ProfilePicture(
                        imageUrl: imageUrl ?? "",
                        name: '${user!.firstName} ${user?.lastName}',
                      ),
                    );
                  }
                },
              ),
              ListTile(
                title: const Text('About Us'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AboutUsScreen()),
                  );
                },
              ),
              ListTile(
                title: const Text('Logout'),
                onTap: () {
                  _showLogoutConfirmationDialog(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
