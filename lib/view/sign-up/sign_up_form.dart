// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pet_buddy/controller/login/login_controller.dart';

import '../../constants/sizes.dart';
import '../../constants/texts.dart';
import '../../utils/toast.dart';

class SignUpForm extends StatefulWidget {
  final String? selectedImageFilename;
  final File? profileImageFile;

  const SignUpForm({
    Key? key,
    this.selectedImageFilename,
    this.profileImageFile,
  }) : super(key: key);

  @override
  SignUpFormState createState() => SignUpFormState();
}

class SignUpFormState extends State<SignUpForm> {
  final LoginController loginController = LoginController();
  final TextEditingController emailTextController = TextEditingController();
  final TextEditingController passwordTextController = TextEditingController();
  final TextEditingController firstNameTextController = TextEditingController();
  final TextEditingController lastNameTextController = TextEditingController();
  bool _isLoading = false;
  bool _showPassword = false;

  @override
  void dispose() {
    emailTextController.dispose();
    passwordTextController.dispose();
    super.dispose();
  }

  Future<void> _performSignUp(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final filename = widget.selectedImageFilename != null
          ? widget.selectedImageFilename!.split('/').last
          : '';
      await loginController.signUp(
        context,
        emailTextController.text,
        firstNameTextController.text,
        lastNameTextController.text,
        passwordTextController.text,
        "profile-images/$filename",
        widget.profileImageFile,
      );
      Navigator.pop(context);
      Toast.show(context, signUpSuccessful);
    } catch (e) {
      Toast.show(context, vagueError);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: formHeight - 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: emailTextController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.mail),
                labelText: email,
                hintText: email,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: formHeight),
            TextField(
              controller: firstNameTextController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.person_outline_outlined),
                labelText: firstName,
                hintText: firstName,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: formHeight),
            TextField(
              controller: lastNameTextController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.person_outline_outlined),
                labelText: lastName,
                hintText: lastName,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: formHeight),
            TextField(
              controller: passwordTextController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock),
                labelText: 'Password',
                hintText: 'Enter your password',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _showPassword = !_showPassword;
                    });
                  },
                  icon: Icon(
                      _showPassword ? Icons.visibility : Icons.visibility_off),
                ),
              ),
              obscureText: !_showPassword,
              onSubmitted: (_) {},
            ),
            const SizedBox(height: formHeight),
            SizedBox(
              height: buttonPrimaryHeight,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => _performSignUp(context),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(signUpTitle.toUpperCase()),
              ),
            ),
            const SizedBox(height: formHeight - 10),
            SizedBox(
              height: buttonPrimaryHeight,
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(back.toUpperCase()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
