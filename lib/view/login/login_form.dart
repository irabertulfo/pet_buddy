import 'package:flutter/material.dart';
import 'package:pet_buddy/controller/login/login_controller.dart';

import '../../constants/sizes.dart';
import '../../constants/texts.dart';
import '../../utils/toast.dart';

class LoginForm extends StatefulWidget {
  final Function(bool) setResetPasswordVisible;
  const LoginForm({Key? key, required this.setResetPasswordVisible});

  @override
  LoginFormState createState() => LoginFormState();
}

class LoginFormState extends State<LoginForm> {
  final LoginController loginController = LoginController();
  final TextEditingController emailTextController = TextEditingController();
  final TextEditingController passwordTextController = TextEditingController();
  bool _isLoading = false;
  bool _showPassword = false;

  @override
  void dispose() {
    emailTextController.dispose();
    passwordTextController.dispose();
    super.dispose();
  }

  Future<void> _performLogin(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await loginController.signInWithEmail(
        context,
        emailTextController.text,
        passwordTextController.text,
      );
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
                prefixIcon: Icon(Icons.person_outline_outlined),
                labelText: email,
                hintText: email,
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
              onSubmitted: (_) {
                _performLogin(context);
              },
            ),
            const SizedBox(height: formHeight - 20),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  widget.setResetPasswordVisible(true);
                },
                child: const Text(forgotPassword),
              ),
            ),
            SizedBox(
              height: buttonPrimaryHeight,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => _performLogin(context),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(login.toUpperCase()),
              ),
            )
          ],
        ),
      ),
    );
  }
}
