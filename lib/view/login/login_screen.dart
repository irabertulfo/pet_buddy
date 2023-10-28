import 'package:flutter/material.dart';
import 'package:pet_buddy/constants/sizes.dart';
import 'package:pet_buddy/view/login/reset_password.dart';

import 'login_footer.dart';
import 'login_form.dart';
import 'login_header.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool resetPasswordVisible = false;

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
                LoginHeader(size: size),
                (resetPasswordVisible)
                    ? ResetPasswordScreen(setResetPasswordVisible: (isVisible) {
                        setState(() {
                          resetPasswordVisible = isVisible;
                        });
                      })
                    : LoginForm(setResetPasswordVisible: (isVisible) {
                        setState(() {
                          resetPasswordVisible = isVisible;
                        });
                      }),
                const LoginFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
