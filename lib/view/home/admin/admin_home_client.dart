import 'package:flutter/material.dart';
import 'package:pet_buddy/constants/texts.dart';
import 'package:pet_buddy/model/user_model.dart';
import 'package:pet_buddy/utils/firebase_storage.dart';
import 'package:pet_buddy/view/home/admin/admin_tab_bar.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  AdminHomeScreenState createState() => AdminHomeScreenState();
}

class AdminHomeScreenState extends State<AdminHomeScreen> {
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
        title: Text("Welcome, ${user?.firstName}"),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      body: const AdminTabBar(),
    );
  }
}
