import 'package:flutter/material.dart';

import '../../constants/image_paths.dart';
import '../../constants/texts.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({
    Key? key,
    required this.size,
  }) : super(key: key);

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image(
          image: const AssetImage(petBuddyLogoImage),
          height: size.height * 0.2,
        ),
        Text(
          loginTitle,
          style: Theme.of(context).textTheme.displaySmall,
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            loginSubtitle,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}
