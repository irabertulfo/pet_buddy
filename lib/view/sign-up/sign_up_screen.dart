import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pet_buddy/constants/sizes.dart';
import 'package:pet_buddy/view/sign-up/sign_up_header.dart';
import 'package:pet_buddy/view/sign-up/sign_up_form.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  String? selectedImageFilename;
  File? profileImageFile; // Add File variable

  void onImageSelected(String filename, File file) {
    setState(() {
      selectedImageFilename = filename;
      profileImageFile = file; // Store the selected file in the state
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(defaultSize),
            child: Column(
              children: [
                SignUpHeader(
                  size: size,
                  onImageSelected: onImageSelected,
                ),
                SignUpForm(
                  selectedImageFilename: selectedImageFilename,
                  profileImageFile:
                      profileImageFile, // Pass the file to SignUpForm
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
