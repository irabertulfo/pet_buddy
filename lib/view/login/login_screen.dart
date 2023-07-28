import 'package:flutter/material.dart';
import 'package:pet_buddy/constants/sizes.dart';

import 'login_footer.dart';
import 'login_form.dart';
import 'login_header.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

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
                const LoginForm(),
                const LoginFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
