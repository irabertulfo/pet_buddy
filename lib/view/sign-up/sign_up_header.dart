import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pet_buddy/constants/image_paths.dart';
import 'package:pet_buddy/constants/sizes.dart';
import 'package:pet_buddy/utils/photo_upload.dart';

class SignUpHeader extends StatelessWidget {
  final Size size;
  final void Function(String, File) onImageSelected;

  const SignUpHeader({
    Key? key,
    required this.size,
    required this.onImageSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            PhotoUploadWidget(
              onImageSelected: _onImageSelected,
            ),
            Image(
              image: const AssetImage(petBuddyLogoImage),
              width: size.width * 0.45,
            ),
          ],
        ),
        const SizedBox(height: formHeight),
      ],
    );
  }

  void _onImageSelected(String filename, File file) {
    onImageSelected(filename, file);
  }
}
