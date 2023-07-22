// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pet_buddy/constants/texts.dart';
import 'package:pet_buddy/model/user_model.dart';
import 'package:pet_buddy/utils/firebase_storage.dart';
import 'package:pet_buddy/utils/firestore_database.dart';
import 'package:pet_buddy/utils/toast.dart';

class LoginController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final UserSingleton userSingleton = UserSingleton();

  Future<void> signInWithEmail(
      BuildContext context, String email, String password) async {
    FirestoreDatabase firestoreDatabase = FirestoreDatabase();

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        final userInfo = await firestoreDatabase.getUserInfoByUUID(user.uid);

        UserModel loggedInUser = UserModel(
          uid: user.uid,
          email: user.email!,
          firstName: userInfo!['firstName'],
          lastName: userInfo['lastName'],
          profileImagePath: userInfo['profileImagePath'],
          userType: userInfo['userType'],
        );

        userSingleton.setUser(loggedInUser);
      }
    } catch (error) {
      if (error is FirebaseAuthException) {
        Toast.show(context, error.message);
      }
    }
  }

  Future<void> signUp(
      BuildContext context,
      String email,
      String firstName,
      String lastName,
      String password,
      String profileImagePath,
      File? profileImage) async {
    FirestoreDatabase firestoreDatabase = FirestoreDatabase();
    FirebaseStorageService firebaseStorageService = FirebaseStorageService();

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        UserModel newUser = UserModel(
            uid: user.uid,
            email: email,
            firstName: firstName,
            lastName: lastName,
            profileImagePath: profileImagePath,
            userType: 'user');

        if (profileImage != null) {
          firebaseStorageService.uploadFile(profileImage, profileImagePath);
        }

        firestoreDatabase.createNewUser(newUser);
      }
    } catch (error) {
      if (error is FirebaseAuthException) {
        Toast.show(context, error.message);
      }
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);

        User? user = userCredential.user;

        if (user != null) {
          final userInfo =
              await FirestoreDatabase().getUserInfoByUUID(user.uid);

          UserModel loggedInUser = UserModel(
            uid: user.uid,
            email: user.email!,
            firstName: userInfo!['firstName'],
            lastName: userInfo['lastName'],
            profileImagePath: userInfo['profileImagePath'],
            userType: userInfo['userType'],
          );

          userSingleton.setUser(loggedInUser);
        }
      }
    } catch (error) {
      Toast.show(context, gmailNotRegistered);
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    userSingleton.clearUser();
  }
}
