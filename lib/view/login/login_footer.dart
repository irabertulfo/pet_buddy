import 'package:flutter/material.dart';

import 'package:pet_buddy/controller/login/login_controller.dart';
import 'package:pet_buddy/utils/toast.dart';
import 'package:pet_buddy/view/sign-up/sign_up_screen.dart';
import 'package:pet_buddy/utils/page_transition.dart';

import 'package:pet_buddy/constants/image_paths.dart';
import 'package:pet_buddy/constants/sizes.dart';
import 'package:pet_buddy/constants/texts.dart';

class LoginFooter extends StatefulWidget {
  const LoginFooter({
    super.key,
  });

  @override
  State<LoginFooter> createState() => _LoginFooterState();
}

class _LoginFooterState extends State<LoginFooter> {
  final LoginController loginController = LoginController();
  bool _isLoading = false;

  Future<void> _performGoogleSignIn(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await loginController.signInWithGoogle(context);
    } catch (e) {
      Toast.show(context, gmailNotRegistered);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: buttonPrimaryHeight,
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Image(
              image: AssetImage(googleLogoImage),
              width: buttonPrimaryHeight / 3,
            ),
            onPressed: _isLoading ? null : () => _performGoogleSignIn(context),
            label: _isLoading
                ? const CircularProgressIndicator()
                : const Text(signInWithGoogle),
          ),
        ),
        const SizedBox(
          height: formHeight - 20.0,
        ),
        TextButton(
          onPressed: () {
            PageTransition.pushUpNavigation(context, const SignUpScreen());
          },
          child: Text.rich(
            TextSpan(
              text: alreadyHaveAccount,
              style: Theme.of(context).textTheme.bodyLarge,
              children: const [
                TextSpan(
                  text: signUp,
                  style: TextStyle(color: Colors.blue),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}
