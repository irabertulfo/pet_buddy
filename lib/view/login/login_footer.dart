import 'package:flutter/material.dart';

import '../../constants/image_paths.dart';
import '../../constants/sizes.dart';
import '../../constants/texts.dart';

class LoginFooter extends StatelessWidget {
  const LoginFooter({
    super.key,
  });

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
            onPressed: () {},
            label: const Text(signInWithGoogle),
          ),
        ),
        const SizedBox(
          height: formHeight - 20.0,
        ),
        TextButton(
          onPressed: () {},
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
